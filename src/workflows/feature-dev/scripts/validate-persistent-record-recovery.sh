#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

target() {
  printf 'Recovery Target: %s\nReason: %s\n' "$1" "$2"
  exit 0
}

sha256_file() {
  shasum -a 256 "$1" | awk '{print $1}'
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

extract_code() {
  local value="$1"
  if [[ "$value" =~ \`([^\`]*)\` ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    trim "$value"
  fi
}

valid_relative_path() {
  local path="$1"
  [[ -n "$path" && "$path" != /* && "$path" != ../* && "$path" != */../* && "$path" != .. ]]
}

valid_sha() {
  [[ "$1" =~ ^[0-9a-f]{64}$ ]]
}

stage_value() {
  local stage="$1"
  local column="$2"
  awk -F'|' -v wanted="$stage" -v column="$column" '
    function clean(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }
    $0 ~ /^\|/ && clean($2) == wanted {
      value = clean($(column))
      if (match(value, /`[^`]+`/)) {
        value = substr(value, RSTART + 1, RLENGTH - 2)
      }
      print value
      exit
    }
  ' "$manifest"
}

identity_value() {
  local stage="$1"
  local column="$2"
  awk -F'|' -v wanted="$stage" -v column="$column" '
    function clean(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }
    /^## Confirmed Stage Record Identities$/ { in_table = 1; next }
    /^## / { in_table = 0 }
    in_table && $0 ~ /^\|/ && clean($2) == wanted {
      print clean($(column))
      exit
    }
  ' "$manifest"
}

record_has_any() {
  local record="$1"
  shift
  local field
  for field in "$@"; do
    rg -F -- "$field" "$record" >/dev/null && return 0
  done
  return 1
}

checkpoint_matches() {
  local checkpoint="$1"
  local path="$2"
  local expected_sha="$3"
  [[ "$checkpoint" == skipped || "$checkpoint" == skipped:* ]] && return 0
  git -C "$repo_root" cat-file -e "$checkpoint:$path" 2>/dev/null || return 1
  [[ "$(git -C "$repo_root" show "$checkpoint:$path" | shasum -a 256 | awk '{print $1}')" == "$expected_sha" ]]
}

validate_direct_inputs() {
  local record="$1"
  local count=0
  local path sha
  while IFS='|' read -r _ path sha _; do
    path="$(trim "$path")"
    sha="$(trim "$sha")"
    [[ "$path" == Path || "$path" == 路径 || "$path" == --- || -z "$path" ]] && continue
    valid_relative_path "$path" && valid_sha "$sha" && [[ -f "$repo_root/$path" ]] || return 1
    [[ "$(sha256_file "$repo_root/$path")" == "$sha" ]] || return 1
    count=$((count + 1))
  done < <(awk '
    /^## (直接依赖输入身份|Direct Input Identities)$/ { in_table = 1; next }
    /^## / { in_table = 0 }
    in_table && /^\|/ { print }
  ' "$record")
  [[ "$count" -gt 0 ]]
}

validate_requirements_fields() {
  local record="$1"
  local field
  local -a fields=(
    '工作项|Work Item'
    '工作项类型|Work-item Type'
    '工作项 Version|Work-item Version'
    '当前 Status|Current Status'
    'selected scope|Selected Scope'
    '## 目标|## Goal'
    '## ✅ 范围|## In Scope'
    '## ❌ 非范围|## Out of Scope'
    '## 验收标准|## Acceptance Criteria'
    '## 业务规则|## Business Rules'
    '假设|Assumptions'
    'Open Questions'
    '直接依赖输入身份|Direct Input Identities'
  )
  for field in "${fields[@]}"; do
    IFS='|' read -r -a alternatives <<<"$field"
    record_has_any "$record" "${alternatives[@]}" || {
      [[ "$field" == '## 验收标准|## Acceptance Criteria' ]] && return 2
      return 1
    }
  done
  return 0
}

validate_solution_fields() {
  local record="$1"
  local field
  local -a fields=(
    '已确认需求来源|Confirmed Requirements Source'
    'Requirements SHA-256'
    '已选方案|Selected Approach'
    '备选方案|Alternatives'
    '受影响边界|Affected Boundaries'
    '关键约束|Key Constraints'
    'Open Questions'
    '验收标准到验证策略映射|Acceptance Criteria to Verification Strategy Mapping'
  )
  for field in "${fields[@]}"; do
    IFS='|' read -r -a alternatives <<<"$field"
    record_has_any "$record" "${alternatives[@]}" || return 1
  done
}

read_required_metadata() {
  local label="$1"
  local record="$2"
  local value
  value="$(awk -v label="$label" '
    index($0, label ":") {
      sub("^[^-]*" label ":[[:space:]]*", "")
      if (match($0, /`[^`]+`/)) print substr($0, RSTART + 1, RLENGTH - 2)
      else print $0
      exit
    }
  ' "$record")"
  printf '%s' "$value"
}

[[ "$#" -eq 1 ]] || fail "usage: $0 RUN_DIR"
run_dir="$1"
[[ -d "$run_dir" && -f "$run_dir/manifest.md" ]] || fail "run directory must contain manifest.md"
manifest="$run_dir/manifest.md"
repo_root="$(git -C "$run_dir" rev-parse --show-toplevel)"

requirements_status="$(stage_value 'Requirements Confirmation' 3)"
solution_status="$(stage_value 'Technical Solution' 3)"
[[ -n "$requirements_status" && -n "$solution_status" ]] || fail "manifest is missing required stage rows"

if [[ "$solution_status" == confirmed && "$requirements_status" != confirmed ]]; then
  target 'Requirements Confirmation' 'stage confirmation is not continuous'
fi
if [[ "$requirements_status" != confirmed ]]; then
  target 'Requirements Confirmation' 'requirements are not confirmed'
fi

requirements_path="$(identity_value 'Requirements Confirmation' 3)"
requirements_sha="$(identity_value 'Requirements Confirmation' 4)"
requirements_artifact="$(stage_value 'Requirements Confirmation' 4)"
requirements_checkpoint="$(stage_value 'Requirements Confirmation' 6)"
valid_relative_path "$requirements_path" || target 'Requirements Confirmation' 'invalid requirements record path'
valid_sha "$requirements_sha" || target 'Requirements Confirmation' 'invalid requirements SHA-256'
[[ -f "$repo_root/$requirements_path" ]] || target 'Requirements Confirmation' 'requirements record is missing'
[[ "$(extract_code "$requirements_artifact")" == "$requirements_path" ]] ||
  target 'Requirements Confirmation' 'requirements record path mismatch'
[[ "$(sha256_file "$repo_root/$requirements_path")" == "$requirements_sha" ]] ||
  target 'Requirements Confirmation' 'requirements SHA-256 mismatch'
checkpoint_matches "$requirements_checkpoint" "$requirements_path" "$requirements_sha" ||
  target 'Requirements Confirmation' 'requirements checkpoint mismatch'
if validate_requirements_fields "$repo_root/$requirements_path"; then
  :
else
  requirements_fields_status=$?
  [[ "$requirements_fields_status" -eq 2 ]] && target 'Requirements Confirmation' 'missing Acceptance Criteria'
  target 'Requirements Confirmation' 'requirements record is incomplete'
fi
validate_direct_inputs "$repo_root/$requirements_path" ||
  target 'Requirements Confirmation' 'direct input SHA-256 mismatch'

if [[ "$solution_status" != confirmed ]]; then
  target 'Technical Solution' 'requirements identity is valid'
fi

solution_path="$(identity_value 'Technical Solution' 3)"
solution_sha="$(identity_value 'Technical Solution' 4)"
solution_artifact="$(stage_value 'Technical Solution' 4)"
solution_checkpoint="$(stage_value 'Technical Solution' 6)"
valid_relative_path "$solution_path" || target 'Technical Solution' 'invalid technical solution record path'
valid_sha "$solution_sha" || target 'Technical Solution' 'invalid technical solution SHA-256'
[[ -f "$repo_root/$solution_path" ]] || target 'Technical Solution' 'technical solution record is missing'
[[ "$(extract_code "$solution_artifact")" == "$solution_path" ]] ||
  target 'Technical Solution' 'technical solution record path mismatch'
[[ "$(sha256_file "$repo_root/$solution_path")" == "$solution_sha" ]] ||
  target 'Technical Solution' 'technical solution SHA-256 mismatch'
checkpoint_matches "$solution_checkpoint" "$solution_path" "$solution_sha" ||
  target 'Technical Solution' 'technical solution checkpoint mismatch'
validate_solution_fields "$repo_root/$solution_path" ||
  target 'Technical Solution' 'technical solution record is incomplete'
[[ "$(read_required_metadata '已确认需求来源' "$repo_root/$solution_path")" == "$requirements_path" ]] &&
  [[ "$(read_required_metadata 'Requirements SHA-256' "$repo_root/$solution_path")" == "$requirements_sha" ]] ||
  target 'Technical Solution' 'solution requirements identity mismatch'

target 'Implementation Plan' 'requirements and technical solution identities are valid'
