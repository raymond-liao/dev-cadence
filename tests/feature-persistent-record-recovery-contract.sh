#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$ROOT_DIR/src/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/feature-record-recovery.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local needle="$1"
  local haystack="$2"
  printf '%s' "$haystack" | rg -F -- "$needle" >/dev/null ||
    fail "expected output to contain '$needle', got: $haystack"
}

sha256_file() {
  shasum -a 256 "$1" | awk '{print $1}'
}

write_file() {
  local repo="$1"
  local path="$2"
  shift 2
  mkdir -p "$(dirname "$repo/$path")"
  printf '%s\n' "$*" >"$repo/$path"
}

commit_paths() {
  local repo="$1"
  local message="$2"
  shift 2
  git -C "$repo" add "$@"
  git -C "$repo" commit -q -m "$message"
  git -C "$repo" rev-parse --short HEAD
}

init_repo() {
  local scenario="$1"
  local repo="$TMP_ROOT/$scenario"
  mkdir -p "$repo"
  git -C "$repo" init -q
  git -C "$repo" config user.name "Feature Recovery Contract"
  git -C "$repo" config user.email "feature-recovery@example.com"
  write_file "$repo" README.md "# fixture"
  commit_paths "$repo" seed README.md >/dev/null
  printf '%s\n' "$repo"
}

write_requirements() {
  local repo="$1"
  local path="$2"
  local card_sha="$3"
  local backlog_sha="$4"
  local include_acceptance="$5"
  local acceptance="## 验收标准\n\n- 恢复目标可验证。"
  [[ "$include_acceptance" == yes ]] || acceptance=""

  write_file "$repo" "$path" "# Requirements

- 工作项: \`docs/stories/S-029.md\`
- 工作项类型: \`Story\`
- 工作项 Version: \`4\`
- 当前 Status: \`In Progress\`
- selected scope: \`persistent record recovery\`

## 目标

- 定义恢复契约。

## ✅ 范围

- 校验确认记录。

## ❌ 非范围

- 不变更其他 workflow。

$acceptance

## 业务规则

- 最早失效阶段必须恢复。

## 假设

- 输入文件使用 Git 管理。

## Open Questions

- None.

## 直接依赖输入身份

| Path | SHA-256 |
| --- | --- |
| docs/stories/S-029.md | $card_sha |
| docs/backlog.md | $backlog_sha |"
}

write_solution() {
  local repo="$1"
  local path="$2"
  local requirements_path="$3"
  local requirements_sha="$4"
  local source_path="$requirements_path"
  local source_sha="$requirements_sha"
  local match="$5"
  if [[ "$match" == no ]]; then
    source_sha="$(printf '%064d' 0)"
  fi

  write_file "$repo" "$path" "# Technical Solution

- 已确认需求来源: \`$source_path\`
- Requirements SHA-256: \`$source_sha\`

## 已选方案

- Feature-only validator.

## 备选方案

- Shared validator.

## 受影响边界

- feature-dev only.

## 关键约束

- Read-only.

## Open Questions

- None.

## 验收标准到验证策略映射

- Fixture tests prove recovery."
}

write_manifest() {
  local repo="$1"
  local run_path="$2"
  local requirements_path="$3"
  local requirements_sha="$4"
  local requirements_checkpoint="$5"
  local solution_path="$6"
  local solution_sha="$7"
  local solution_checkpoint="$8"
  local requirements_status="$9"
  local solution_status="${10}"

  write_file "$repo" "$run_path/manifest.md" "# Dev Cadence Run Manifest

## Stage Table

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Requirements Confirmation | \`$requirements_status\` | \`$requirements_path\` | \`confirmed\` | \`$requirements_checkpoint\` | fixture |
| Technical Solution | \`$solution_status\` | \`$solution_path\` | \`confirmed\` | \`$solution_checkpoint\` | fixture |

## Confirmed Stage Record Identities

| Stage | Record Path | SHA-256 |
| --- | --- | --- |
| Requirements Confirmation | $requirements_path | $requirements_sha |
| Technical Solution | $solution_path | $solution_sha |"
}

create_fixture() {
  local scenario="$1"
  local repo run_path requirements_path solution_path card_sha backlog_sha requirements_sha solution_sha
  local requirements_checkpoint solution_checkpoint requirements_status=confirmed solution_status=pending

  repo="$(init_repo "$scenario")"
  run_path="build/dev-cadence/feature-dev/$scenario"
  requirements_path="$run_path/01-requirements.md"
  solution_path="$run_path/02-technical-solution.md"
  write_file "$repo" docs/stories/S-029.md "# S-029\n\n- Status: In Progress"
  write_file "$repo" docs/backlog.md "# Backlog\n\n- S-029"
  commit_paths "$repo" inputs docs/stories/S-029.md docs/backlog.md >/dev/null
  card_sha="$(sha256_file "$repo/docs/stories/S-029.md")"
  backlog_sha="$(sha256_file "$repo/docs/backlog.md")"

  write_requirements "$repo" "$requirements_path" "$card_sha" "$backlog_sha" yes
  requirements_sha="$(sha256_file "$repo/$requirements_path")"
  requirements_checkpoint="$(commit_paths "$repo" requirements "$requirements_path")"
  solution_checkpoint=skipped
  solution_sha="$(printf '%064d' 0)"

  case "$scenario" in
    two-confirmed|solution-identity-mismatch|solution-before-requirements)
      write_solution "$repo" "$solution_path" "$requirements_path" "$requirements_sha" \
        "$([[ "$scenario" == solution-identity-mismatch ]] && printf no || printf yes)"
      solution_sha="$(sha256_file "$repo/$solution_path")"
      solution_checkpoint="$(commit_paths "$repo" solution "$solution_path")"
      solution_status=confirmed
      ;;
    requirements-skipped)
      requirements_checkpoint=skipped
      ;;
    missing-acceptance)
      write_requirements "$repo" "$requirements_path" "$card_sha" "$backlog_sha" no
      requirements_sha="$(sha256_file "$repo/$requirements_path")"
      requirements_checkpoint="$(commit_paths "$repo" requirements "$requirements_path")"
      ;;
  esac

  write_manifest "$repo" "$run_path" "$requirements_path" "$requirements_sha" \
    "$requirements_checkpoint" "$solution_path" "$solution_sha" "$solution_checkpoint" \
    "$requirements_status" "$solution_status"

  case "$scenario" in
    requirements-sha-mismatch)
      sed -i.bak "s/$requirements_sha/$(printf '%064d' 0)/" "$repo/$run_path/manifest.md"
      rm "$repo/$run_path/manifest.md.bak"
      ;;
    work-item-drift)
      write_file "$repo" docs/stories/S-029.md "# S-029\n\n- Status: Done"
      ;;
    dependency-drift)
      write_file "$repo" docs/backlog.md "# Backlog\n\n- moved"
      ;;
    solution-before-requirements)
      sed -i.bak 's/| Requirements Confirmation | `confirmed`/| Requirements Confirmation | `pending`/' "$repo/$run_path/manifest.md"
      rm "$repo/$run_path/manifest.md.bak"
      ;;
  esac

  printf '%s\n' "$repo/$run_path"
}

expect_fixture() {
  local scenario="$1"
  local expected_target="$2"
  local expected_reason="$3"
  local output run_dir
  run_dir="$(create_fixture "$scenario")"
  output="$(bash "$VALIDATOR" "$run_dir")" || fail "$scenario should succeed: $output"
  assert_contains "Recovery Target: $expected_target" "$output"
  assert_contains "Reason: $expected_reason" "$output"
}

run_fixtures() {
  test -x "$VALIDATOR" || fail "missing validator: $VALIDATOR"
  expect_fixture requirements-only "Technical Solution" "requirements identity is valid"
  expect_fixture two-confirmed "Implementation Plan" "requirements and technical solution identities are valid"
  expect_fixture requirements-skipped "Technical Solution" "requirements identity is valid"
  expect_fixture missing-acceptance "Requirements Confirmation" "missing Acceptance Criteria"
  expect_fixture requirements-sha-mismatch "Requirements Confirmation" "requirements SHA-256 mismatch"
  expect_fixture solution-identity-mismatch "Technical Solution" "solution requirements identity mismatch"
  expect_fixture solution-before-requirements "Requirements Confirmation" "stage confirmation is not continuous"
  expect_fixture work-item-drift "Requirements Confirmation" "direct input SHA-256 mismatch"
  expect_fixture dependency-drift "Requirements Confirmation" "direct input SHA-256 mismatch"
  printf 'Feature persistent-record recovery fixture checks passed.\n'
}

run_source_contract() {
  local source="$ROOT_DIR/src/workflows/feature-dev/SKILL.md"
  for required in \
    "Confirmed Stage Record Identities" \
    "validate-persistent-record-recovery.sh" \
    "SHA-256" \
    "Requirements Confirmation" \
    "Technical Solution" \
    "Pre-Implementation Design Freshness Gate"; do
    rg -F -- "$required" "$source" >/dev/null || fail "source workflow missing: $required"
  done
  printf 'Feature persistent-record source contract checks passed.\n'
}

case "${1:-source}" in
  fixtures) run_fixtures ;;
  source) run_source_contract ;;
  *) fail "usage: $0 [fixtures|source]" ;;
esac
