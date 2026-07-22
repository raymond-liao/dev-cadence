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
final_verification_mode=0
terminal_stage_gap=""
final_sha_value=""
recorded_checkpoints=""
final_verification_end_head=""
base_sha_value=""

if [[ $# -lt 1 || $# -gt 2 ]]; then
  fail "usage: validate-delivery-record.sh RUN_DIR [--terminal|--final-verification]"
fi

run_dir="$1"

if [[ $# -eq 2 ]]; then
  case "$2" in
    --terminal)
      terminal_mode=1
      ;;
    --final-verification)
      final_verification_mode=1
      ;;
    *)
      fail "usage: validate-delivery-record.sh RUN_DIR [--terminal|--final-verification]"
      ;;
  esac
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
run_dir_rel="${run_dir_abs#"$repo_root_abs/"}"

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

extract_record_field() {
  local record_path="$1"
  local field="$2"
  local field_line
  local field_value

  field_line="$(rg -n "^- ${field}:" "$record_path" | head -n 1 || true)"
  [[ -n "$field_line" ]] || fail "final verification record is missing ${field}"
  field_value="$(trim "${field_line#*:}")"
  if [[ "$field_value" == *\`* ]]; then
    extract_backtick_value "$field_value"
  else
    printf '%s\n' "$field_value"
  fi
}

validate_final_verification() {
  local start_head start_branch start_final_sha start_snapshot start_state start_head_canonical
  local end_head end_branch end_final_sha end_snapshot end_state end_head_canonical
  local current_branch current_snapshot current_state snapshot_base_sha

  [[ -n "$implementation_record_path" && -f "$implementation_record_path" ]] ||
    fail "final verification requires implementation record evidence"
  [[ -n "$verification_record_path" && -f "$verification_record_path" ]] ||
    fail "final verification requires verification record evidence"
  start_head="$(extract_record_field "$verification_record_path" "Verification Start HEAD")"
  start_branch="$(extract_record_field "$verification_record_path" "Verification Start Branch")"
  start_final_sha="$(extract_record_field "$verification_record_path" "Verification Start FINAL_IMPLEMENTATION_SHA")"
  start_snapshot="$(extract_record_field "$verification_record_path" "Verification Start Tracked Snapshot")"
  start_state="$(extract_record_field "$verification_record_path" "Verification Start Tracked State")"
  end_head="$(extract_record_field "$verification_record_path" "Verification End HEAD")"
  end_branch="$(extract_record_field "$verification_record_path" "Verification End Branch")"
  end_final_sha="$(extract_record_field "$verification_record_path" "Verification End FINAL_IMPLEMENTATION_SHA")"
  end_snapshot="$(extract_record_field "$verification_record_path" "Verification End Tracked Snapshot")"
  end_state="$(extract_record_field "$verification_record_path" "Verification End Tracked State")"

  [[ -n "$start_head" && "$start_head" != "pending" ]] || fail "final verification has invalid start snapshot"
  [[ -n "$start_branch" && "$start_branch" != "pending" ]] || fail "final verification has invalid start snapshot"
  [[ -n "$start_final_sha" && "$start_final_sha" != "pending" ]] || fail "final verification has invalid start snapshot"
  [[ "$start_snapshot" =~ ^[0-9a-f]{40,64}$ ]] || fail "final verification has invalid start snapshot"
  [[ "$start_state" == "clean" || "$start_state" == "dirty" ]] || fail "final verification has invalid start snapshot"
  [[ "$end_state" == "clean" || "$end_state" == "dirty" ]] || fail "final verification has invalid end snapshot"
  [[ "$start_head" =~ ^[0-9a-f]{40}$ && "$end_head" =~ ^[0-9a-f]{40}$ ]] ||
    fail "final verification HEAD must be a full commit SHA"
  [[ "$start_head" == "$end_head" && "$start_branch" == "$end_branch" && \
    "$start_final_sha" == "$end_final_sha" && "$start_snapshot" == "$end_snapshot" && \
    "$start_state" == "$end_state" ]] || fail "final verification start and end snapshots differ"

  snapshot_base_sha="$end_final_sha"
  if [[ "$end_final_sha" == "skipped: no tracked changes" ]]; then
    [[ "$final_sha_value" == "skipped: no tracked changes" ]] ||
      fail "final verification final implementation SHA changed"
    [[ -n "$base_sha_value" ]] ||
      fail "final verification skipped candidate is missing Implementation Base SHA"
    snapshot_base_sha="$base_sha_value"
  else
    git -C "$repo_root_abs" rev-parse --verify "$end_final_sha^{commit}" >/dev/null 2>&1 ||
      fail "final verification references unknown final implementation SHA"
  fi
  start_head_canonical="$(git -C "$repo_root_abs" rev-parse --verify "$start_head^{commit}" 2>/dev/null)" ||
    fail "final verification references unknown start HEAD"
  end_head_canonical="$(git -C "$repo_root_abs" rev-parse --verify "$end_head^{commit}" 2>/dev/null)" ||
    fail "final verification references unknown end HEAD"
  [[ "$start_head_canonical" == "$end_head_canonical" ]] || fail "final verification start and end snapshots differ"
  [[ "$end_final_sha" == "$final_sha_value" ]] || fail "final verification final implementation SHA changed"
  git -C "$repo_root_abs" merge-base --is-ancestor "$snapshot_base_sha" HEAD ||
    fail "final verification final implementation SHA is not reachable"
  git -C "$repo_root_abs" merge-base --is-ancestor "$end_head_canonical" HEAD ||
    fail "final verification end HEAD is not reachable"
  final_verification_end_head="$end_head_canonical"

  current_branch="$(git -C "$repo_root_abs" branch --show-current)"
  [[ "$current_branch" == "$end_branch" ]] || fail "final verification branch changed"
  current_snapshot="$(git -C "$repo_root_abs" diff --binary "$snapshot_base_sha" -- . ":(exclude)$run_dir_rel" | git -C "$repo_root_abs" hash-object --stdin)"
  if git -C "$repo_root_abs" diff --quiet "$snapshot_base_sha" -- . ":(exclude)$run_dir_rel"; then
    current_state="clean"
  else
    current_state="dirty"
  fi
  [[ "$current_snapshot" == "$end_snapshot" ]] || fail "final verification tracked snapshot changed"
  [[ "$current_state" == "$end_state" ]] || fail "final verification tracked state changed"
}

checkpoint_is_recorded() {
  local commit="$1"
  local checkpoint full_checkpoint

  while IFS= read -r checkpoint; do
    [[ -z "$checkpoint" ]] && continue
    full_checkpoint="$(git -C "$repo_root_abs" rev-parse --verify "$checkpoint^{commit}" 2>/dev/null || true)"
    [[ "$full_checkpoint" == "$(git -C "$repo_root_abs" rev-parse "$commit")" ]] && return 0
  done <<<"$recorded_checkpoints"
  return 1
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

  if [[ "$artifact_path" != "pending" && -f "$repo_root_abs/$artifact_path" ]]; then
    artifact_exists_in_stage_table=1
  elif [[ "$status" != "pending" && "$status" != "skipped" ]]; then
    fail "artifact path does not exist: $artifact_path"
  fi

  if [[ "$checkpoint_value" =~ ^[0-9a-f]{7,40}$ && -f "$repo_root_abs/$artifact_path" ]]; then
    git -C "$repo_root_abs" cat-file -e "$checkpoint_value:$artifact_path" 2>/dev/null ||
      fail "checkpoint tree is missing stage artifact: $checkpoint_value $artifact_path"
    recorded_checkpoints+=$'\n'"$checkpoint_value"
  fi

  if [[ "$stage" == "Business Acceptance" ]]; then
    business_acceptance_path="$repo_root_abs/$artifact_path"
    business_acceptance_status="$status"
    business_acceptance_checkpoint="$checkpoint_value"
  fi

  case "$artifact_path" in
    */04-implementation-record.md|*/04-repair-record.md|*/04-refactor-record.md)
      [[ -f "$repo_root_abs/$artifact_path" ]] && implementation_record_path="$repo_root_abs/$artifact_path"
      ;;
    */05-system-test-report.md|*/05-regression-test-report.md)
      [[ -f "$repo_root_abs/$artifact_path" ]] && verification_record_path="$repo_root_abs/$artifact_path"
      ;;
  esac
done < <(
  awk -F'|' '
    /^\| Stage \| Status \| Artifact( Path)? \| User Confirmation \| Checkpoint Commit \| Notes \|$/ { in_table=1; next }
    in_table && /^\| ---/ { next }
    in_table && /^\|/ {
      print $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7
      next
    }
    in_table && !/^\|/ { exit }
  ' "$manifest_path"
)

[[ "$artifact_exists_in_stage_table" -eq 1 ]] || fail "manifest does not contain any stage artifact rows"

if [[ "$terminal_mode" -eq 1 ]]; then
  case "$overall_status" in
    accepted|rejected|accepted_with_risk|integrated|abandoned)
      ;;
    *)
      fail "terminal manifest has non-terminal overall status '$overall_status'"
      ;;
  esac
  [[ -z "$terminal_stage_gap" ]] || fail "terminal manifest has non-terminal stage: $terminal_stage_gap"
  [[ -n "$implementation_record_path" ]] || fail "implementation record artifact not found in manifest"
  [[ -f "$implementation_record_path" ]] || fail "implementation record does not exist: ${implementation_record_path#"$repo_root_abs/"}"
  [[ -n "$verification_record_path" ]] || fail "terminal manifest is missing verification record artifact"
  [[ -f "$verification_record_path" ]] || fail "terminal verification record does not exist"
fi

if [[ -n "$implementation_record_path" ]]; then
  [[ -f "$implementation_record_path" ]] || fail "implementation record does not exist: ${implementation_record_path#"$repo_root_abs/"}"

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
fi
fi

if [[ "$terminal_mode" -eq 1 && -n "$verification_record_path" && -f "$verification_record_path" ]]; then
  test_conclusion="$(rg -n '^(?:- )?(Test Result|Verification Result):' "$verification_record_path" | head -n 1 || true)"
  [[ -n "$test_conclusion" ]] || fail "terminal verification record is missing test conclusion"
  test_value="$(trim "${test_conclusion##*:}")"
  if [[ "$test_value" == *\`* ]]; then
    test_value="$(extract_backtick_value "$test_value")"
  fi
  [[ -n "$test_value" && "$test_value" != "pending" ]] || fail "terminal verification record is missing test conclusion"
fi

if [[ "$terminal_mode" -eq 1 && "$overall_status" == "abandoned" ]]; then
  require_abandoned_evidence \
    "$business_acceptance_path" \
    "$run_dir_abs/06-business-acceptance-record.md" \
    "$business_acceptance_status" \
    "$business_acceptance_checkpoint" \
    "$run_dir_abs/07-manual-recovery-record.md"
fi

if [[ "$final_verification_mode" -eq 1 || "$terminal_mode" -eq 1 ]]; then
  validate_final_verification

  while IFS= read -r commit; do
    [[ -z "$commit" ]] && continue
    checkpoint_is_recorded "$commit" || fail "final verification contains unapproved commit after verification"
    while IFS= read -r changed_path; do
      [[ -z "$changed_path" ]] && continue
      case "$changed_path" in
        "$run_dir_rel"/*)
          ;;
        *)
          fail "final verification checkpoint changes outside run directory"
          ;;
      esac
    done < <(git -C "$repo_root_abs" diff --name-only "$commit^1" "$commit")
  done < <(git -C "$repo_root_abs" rev-list --first-parent "$final_verification_end_head..HEAD")
fi

printf 'Delivery record validation passed: %s\n' "$run_dir"
