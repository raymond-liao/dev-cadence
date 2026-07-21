#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

extract_backtick_value() {
  local value="$1"
  if [[ "$value" != *\`* ]]; then
    return 1
  fi

  value="${value#*\`}"
  value="${value%%\`*}"
  printf '%s\n' "$value"
}

extract_status_value() {
  local cell
  cell="$(trim "$1")"
  if [[ "$cell" == *\`* ]]; then
    extract_backtick_value "$cell"
  else
    printf '%s\n' "$cell"
  fi
}

require_manual_recovery_field() {
  local record_path="$1"
  local field="$2"

  rg -q "^- ${field}: .+" "$record_path" ||
    fail "manual recovery record is missing ${field}"
}

require_abandoned_evidence() {
  local acceptance_path="$1"
  local expected_acceptance_path="$2"
  local acceptance_status="$3"
  local acceptance_checkpoint="$4"
  local recovery_path="$5"
  local decision
  local blocking_category

  [[ "$acceptance_path" == "$expected_acceptance_path" && -f "$acceptance_path" ]] ||
    fail "abandoned manifest is missing Business Acceptance record"
  [[ "$acceptance_status" == "confirmed" ]] ||
    fail "abandoned manifest requires confirmed Business Acceptance stage"
  [[ "$acceptance_checkpoint" != "pending" ]] ||
    fail "abandoned manifest requires Business Acceptance checkpoint"
  decision="$(rg -n '^- User Decision:' "$acceptance_path" | head -n 1 | sed 's/^[0-9]*:- User Decision: *//' || true)"
  case "$decision" in
    \`accepted\`|\`accepted_with_risk\`)
      ;;
    *)
      fail "abandoned manifest requires accepted Business Acceptance decision"
      ;;
  esac
  [[ -f "$recovery_path" ]] || fail "abandoned manifest is missing manual recovery record"
  for field in "Blocking Category" "Blocking Evidence" "Blocked Completion Action" \
    "Recovery Attempt" "Recovery Result" "Why Further Recovery Is Not Viable" \
    "User Confirmation" "Code Preservation" "Branch Preservation" \
    "Worktree Preservation" "Run Record Preservation" "Follow-up Owner" "Next Step"; do
    require_manual_recovery_field "$recovery_path" "$field"
  done

  blocking_category="$(rg -n '^- Blocking Category:' "$recovery_path" | head -n 1 | sed 's/^[0-9]*:- Blocking Category: *//' || true)"
  case "$blocking_category" in
    \`git\`|\`branch\`|\`worktree\`|\`permission\`|\`external_environment\`)
      ;;
    *)
      fail "manual recovery record has invalid Blocking Category"
      ;;
  esac
}

artifact_exists_in_stage_table=0
implementation_record_path=""
verification_record_path=""
business_acceptance_path=""
business_acceptance_status=""
business_acceptance_checkpoint=""
terminal_mode=0
terminal_stage_gap=""

if [[ $# -lt 1 || $# -gt 2 ]]; then
  fail "usage: validate-delivery-record.sh RUN_DIR [--terminal]"
fi

run_dir="$1"

if [[ $# -eq 2 ]]; then
  if [[ "$2" != "--terminal" ]]; then
    fail "usage: validate-delivery-record.sh RUN_DIR [--terminal]"
  fi
  terminal_mode=1
fi

manifest_path="$run_dir/manifest.md"
[[ -f "$manifest_path" ]] || fail "missing manifest.md in run directory"

overall_status_line="$(rg -n '^- Overall Status:' "$manifest_path" | head -n 1 || true)"
overall_status=""
if [[ -n "$overall_status_line" ]]; then
  if [[ "$overall_status_line" == *\`* ]]; then
    overall_status="$(extract_backtick_value "$overall_status_line")"
  else
    overall_status="$(trim "${overall_status_line#*:}")"
  fi
fi

repo_root="$(git -C "$run_dir" rev-parse --show-toplevel 2>/dev/null)" || fail "run directory is not inside a Git repository"
run_dir_abs="$(cd "$run_dir" && pwd -P)"
repo_root_abs="$(cd "$repo_root" && pwd -P)"

case "$run_dir_abs" in
  "$repo_root_abs"/*|"$repo_root_abs")
    ;;
  *)
    fail "run directory is outside the repository root"
    ;;
esac

valid_status() {
  case "$1" in
    pending|in_progress|confirmed|blocked|skipped)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

checkpoint_is_allowed() {
  local checkpoint="$1"
  [[ "$checkpoint" =~ ^[0-9a-f]{7,40}$ ]] || [[ "$checkpoint" == skipped:* ]] || [[ "$checkpoint" == "skipped" ]]
}

while IFS=$'\t' read -r raw_stage raw_status raw_artifact _raw_confirmation raw_checkpoint _raw_notes; do
  stage="$(trim "$raw_stage")"
  status="$(extract_status_value "$raw_status")"
  artifact_cell="$(trim "$raw_artifact")"
  checkpoint_cell="$(trim "$raw_checkpoint")"

  valid_status "$status" || fail "unknown stage status '$status' for stage '$stage'"

  if [[ "$terminal_mode" -eq 1 && "$status" != "confirmed" && "$status" != "skipped" ]]; then
    terminal_stage_gap="$stage ($status)"
  fi

  artifact_path="pending"
  if [[ "$artifact_cell" == *\`* ]]; then
    artifact_path="$(extract_backtick_value "$artifact_cell")"
  elif [[ "$artifact_cell" != *pending* ]]; then
    fail "artifact cell is not pending and does not contain a path for stage '$stage'"
  fi

  checkpoint_value="pending"
  if [[ "$checkpoint_cell" == *\`* ]]; then
    checkpoint_value="$(extract_backtick_value "$checkpoint_cell")"
  else
    checkpoint_value="$(trim "$checkpoint_cell")"
  fi

  if [[ "$status" == "confirmed" || ( "$terminal_mode" -eq 1 && "$status" == "skipped" ) ]]; then
    [[ "$checkpoint_value" != "pending" ]] || fail "stage '$stage' has terminal status '$status' but pending checkpoint"
    checkpoint_is_allowed "$checkpoint_value" || fail "stage '$stage' has invalid checkpoint value '$checkpoint_value'"
  fi

  if [[ "$artifact_path" != "pending" ]]; then
    artifact_exists_in_stage_table=1
    [[ -f "$repo_root_abs/$artifact_path" ]] || fail "artifact path does not exist: $artifact_path"
  fi

  if [[ "$checkpoint_value" =~ ^[0-9a-f]{7,40}$ ]]; then
    git -C "$repo_root_abs" cat-file -e "$checkpoint_value:$artifact_path" 2>/dev/null ||
      fail "checkpoint tree is missing stage artifact: $checkpoint_value $artifact_path"
  fi

  if [[ "$stage" == "Business Acceptance" ]]; then
    business_acceptance_path="$repo_root_abs/$artifact_path"
    business_acceptance_status="$status"
    business_acceptance_checkpoint="$checkpoint_value"
  fi

  case "$artifact_path" in
    */04-implementation-record.md|*/04-repair-record.md|*/04-refactor-record.md)
      implementation_record_path="$repo_root_abs/$artifact_path"
      ;;
    */05-system-test-report.md|*/05-regression-test-report.md)
      verification_record_path="$repo_root_abs/$artifact_path"
      ;;
  esac
done < <(
  awk -F'|' '
    /^\| Stage \| Status \| Artifact \| User Confirmation \| Checkpoint Commit \| Notes \|$/ { in_table=1; next }
    in_table && /^\| ---/ { next }
    in_table && /^\|/ {
      print $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7
      next
    }
    in_table && !/^\|/ { exit }
  ' "$manifest_path"
)

[[ "$artifact_exists_in_stage_table" -eq 1 ]] || fail "manifest does not contain any stage artifact rows"

[[ -n "$implementation_record_path" ]] || fail "implementation record artifact not found in manifest"
[[ -f "$implementation_record_path" ]] || fail "implementation record does not exist: ${implementation_record_path#"$repo_root_abs/"}"

if [[ "$terminal_mode" -eq 1 ]]; then
  case "$overall_status" in
    accepted|rejected|accepted_with_risk|integrated|abandoned)
      ;;
    *)
      fail "terminal manifest has non-terminal overall status '$overall_status'"
      ;;
  esac
  [[ -z "$terminal_stage_gap" ]] || fail "terminal manifest has non-terminal stage: $terminal_stage_gap"
  [[ -n "$verification_record_path" ]] || fail "terminal manifest is missing verification record artifact"
  [[ -f "$verification_record_path" ]] || fail "terminal verification record does not exist"
fi

final_sha_line="$(rg -n 'Final (Implementation|Repair|Refactor) SHA:' "$implementation_record_path" | head -n 1 || true)"
[[ -n "$final_sha_line" ]] || fail "implementation record is missing final implementation SHA"

final_sha_value="pending"
if [[ "$final_sha_line" == *\`* ]]; then
  final_sha_value="$(extract_backtick_value "$final_sha_line")"
else
  final_sha_value="$(trim "${final_sha_line#*:}")"
fi

[[ "$final_sha_value" != "pending" ]] || fail "implementation record has pending final implementation SHA"

base_sha_line="$(rg -n 'Implementation Base SHA:' "$implementation_record_path" | head -n 1 || true)"

if [[ "$final_sha_value" == "skipped: no tracked changes" ]]; then
  [[ -n "$base_sha_line" ]] || fail "skipped no-tracked-changes record is missing Implementation Base SHA"
  if [[ "$base_sha_line" == *\`* ]]; then
    base_sha_value="$(extract_backtick_value "$base_sha_line")"
  else
    base_sha_value="$(trim "${base_sha_line#*:}")"
  fi
  [[ "$base_sha_value" =~ ^[0-9a-f]{7,40}$ ]] || fail "skipped no-tracked-changes record has invalid Implementation Base SHA '$base_sha_value'"
  git -C "$repo_root_abs" rev-parse --verify "$base_sha_value^{commit}" >/dev/null 2>&1 ||
    fail "skipped no-tracked-changes record references unknown Implementation Base SHA '$base_sha_value'"

  run_dir_rel="${run_dir_abs#"$repo_root_abs/"}"
  changed_paths="$(git -C "$repo_root_abs" diff --name-only "$base_sha_value..HEAD")"
  if [[ -n "$changed_paths" ]]; then
    while IFS= read -r changed_path; do
      [[ -z "$changed_path" ]] && continue
      case "$changed_path" in
        "$run_dir_rel"/*)
          ;;
        *)
          fail "skipped no-tracked-changes proof found non-record changes: $changed_path"
          ;;
      esac
    done <<<"$changed_paths"
  fi
else
  [[ "$final_sha_value" =~ ^[0-9a-f]{7,40}$ ]] || fail "implementation record has invalid final implementation SHA '$final_sha_value'"
  git -C "$repo_root_abs" rev-parse --verify "$final_sha_value^{commit}" >/dev/null 2>&1 ||
    fail "implementation record references unknown final implementation SHA '$final_sha_value'"
  [[ -n "$base_sha_line" ]] || fail "committed implementation record is missing Implementation Base SHA"
  changed_files_section="$(awk '
    /^## Changed Files/ { in_section=1; next }
    in_section && /^## / { exit }
    in_section { print }
  ' "$implementation_record_path")"
  [[ -n "$(printf '%s' "$changed_files_section" | tr -d '[:space:]')" ]] || fail "implementation record is missing Changed Files content"
  if printf '%s' "$changed_files_section" | rg -n '^pending$|`pending`|pending' >/dev/null; then
    fail "implementation record has pending Changed Files"
  fi

  declared_changed_paths="$(printf '%s\n' "$changed_files_section" | sed -n 's/^[[:space:]]*-[[:space:]]*`\([^`]*\)`[[:space:]]*$/\1/p' | LC_ALL=C sort -u)"
  [[ -n "$declared_changed_paths" ]] || fail "implementation record has no concrete Changed Files paths"

  run_dir_rel="${run_dir_abs#"$repo_root_abs/"}"
  if [[ "$base_sha_line" == *\`* ]]; then
    base_sha_value="$(extract_backtick_value "$base_sha_line")"
  else
    base_sha_value="$(trim "${base_sha_line#*:}")"
  fi
  git -C "$repo_root_abs" rev-parse --verify "$base_sha_value^{commit}" >/dev/null 2>&1 ||
    fail "implementation record references unknown Implementation Base SHA '$base_sha_value'"
  actual_changed_paths="$(git -C "$repo_root_abs" diff --name-only "$base_sha_value..$final_sha_value")"
  actual_changed_paths="$(printf '%s\n' "$actual_changed_paths" | awk -v run_dir="$run_dir_rel/" 'index($0, run_dir) != 1 && NF' | LC_ALL=C sort -u)"
  [[ "$declared_changed_paths" == "$actual_changed_paths" ]] ||
    fail "Changed Files do not match final implementation commit range"
fi

if rg -n 'sdd/progress\.md|sdd/[^[:space:])`]*' "$implementation_record_path" >/dev/null; then
  fail "terminal implementation record depends on ignored SDD scratch evidence"
fi

if [[ "$terminal_mode" -eq 1 ]]; then
  review_conclusion="$(rg -n '^(?:- )?(Final Review|Review Result):' "$implementation_record_path" | head -n 1 || true)"
  [[ -n "$review_conclusion" ]] || fail "terminal implementation record is missing final review conclusion"
  review_value="$(trim "${review_conclusion##*:}")"
  if [[ "$review_value" == *\`* ]]; then
    review_value="$(extract_backtick_value "$review_value")"
  fi
  [[ -n "$review_value" && "$review_value" != "pending" ]] || fail "terminal implementation record is missing final review conclusion"

  if [[ -n "$verification_record_path" && -f "$verification_record_path" ]]; then
    test_conclusion="$(rg -n '^(?:- )?(Test Result|Verification Result):' "$verification_record_path" | head -n 1 || true)"
    [[ -n "$test_conclusion" ]] || fail "terminal verification record is missing test conclusion"
    test_value="$(trim "${test_conclusion##*:}")"
    if [[ "$test_value" == *\`* ]]; then
      test_value="$(extract_backtick_value "$test_value")"
    fi
    [[ -n "$test_value" && "$test_value" != "pending" ]] || fail "terminal verification record is missing test conclusion"
  fi
fi

if [[ "$terminal_mode" -eq 1 && "$overall_status" == "abandoned" ]]; then
  require_abandoned_evidence \
    "$business_acceptance_path" \
    "$run_dir_abs/06-business-acceptance-record.md" \
    "$business_acceptance_status" \
    "$business_acceptance_checkpoint" \
    "$run_dir_abs/07-manual-recovery-record.md"
fi

printf 'Delivery record validation passed: %s\n' "$run_dir"
