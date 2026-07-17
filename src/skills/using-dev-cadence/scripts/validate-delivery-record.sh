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

artifact_exists_in_stage_table=0
implementation_record_path=""
verification_record_path=""
terminal_mode=0

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
    pending|in_progress|confirmed|blocked|skipped|accepted|accepted_with_risk|rejected|integrated)
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

  if [[ "$status" == "confirmed" || "$status" == "accepted" ]]; then
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

final_sha_line="$(rg -n 'Final (Implementation|Repair|Refactor) SHA:' "$implementation_record_path" | head -n 1 || true)"
[[ -n "$final_sha_line" ]] || fail "implementation record is missing final implementation SHA"

final_sha_value="pending"
if [[ "$final_sha_line" == *\`* ]]; then
  final_sha_value="$(extract_backtick_value "$final_sha_line")"
else
  final_sha_value="$(trim "${final_sha_line#*:}")"
fi

[[ "$final_sha_value" != "pending" ]] || fail "implementation record has pending final implementation SHA"

if [[ "$final_sha_value" != "skipped: no tracked changes" ]]; then
  [[ "$final_sha_value" =~ ^[0-9a-f]{7,40}$ ]] || fail "implementation record has invalid final implementation SHA '$final_sha_value'"
  changed_files_section="$(awk '
    /^## Changed Files/ { in_section=1; next }
    in_section && /^## / { exit }
    in_section { print }
  ' "$implementation_record_path")"
  [[ -n "$(printf '%s' "$changed_files_section" | tr -d '[:space:]')" ]] || fail "implementation record is missing Changed Files content"
  if printf '%s' "$changed_files_section" | rg -n '^pending$|`pending`|pending' >/dev/null; then
    fail "implementation record has pending Changed Files"
  fi
fi

if rg -n 'sdd/progress\.md|sdd/[^[:space:])`]*' "$implementation_record_path" >/dev/null; then
  fail "terminal implementation record depends on ignored SDD scratch evidence"
fi

if [[ "$terminal_mode" -eq 1 ]]; then
  if rg -n 'Final Review: `pending`|Review Result: `pending`' "$implementation_record_path" >/dev/null; then
    fail "terminal implementation record retains pending final review"
  fi

  if [[ -n "$verification_record_path" && -f "$verification_record_path" ]]; then
    if rg -n 'Test Result: `pending`|Verification Result: `pending`' "$verification_record_path" >/dev/null; then
      fail "terminal verification record retains pending result"
    fi
  fi
fi

printf 'Delivery record validation passed: %s\n' "$run_dir"
