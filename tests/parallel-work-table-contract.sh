#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
BACKLOG="$ROOT_DIR/docs/backlog.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  rg --no-ignore -n "$pattern" "$path" >/dev/null || fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_match "parallel view source contract" '^## Parallel Work View Contract$' "$SKILL"
assert_match "candidate view boundary" 'candidate view|candidate.*not.*status model|not.*implementation.*board' "$SKILL"
assert_match "status-only dimension" 'status.*card lifecycle|状态.*生命周期' "$SKILL"
assert_match "entry qualification dimension" 'entry qualification|入口门禁|下一步 Workflow' "$SKILL"
assert_match "Story entry rule" 'Story.*`Ready`.*`feature-dev`|Story.*Ready.*feature-dev' "$SKILL"
assert_match "Task entry rule" 'Task.*`feature-dev`.*`bug-fix`.*`refactor`|Task.*feature-dev.*bug-fix.*refactor' "$SKILL"
assert_match "Bug diagnosis rule" 'Bug.*`bug-fix`.*diagnos|Bug.*bug-fix.*诊断' "$SKILL"
assert_match "Blocked dependency rule" 'Blocked.*depend|Blocked.*依赖' "$SKILL"
assert_match "no automatic start" 'must not.*automatically start|不得自动启动|not.*directly modify code' "$SKILL"

assert_match "five-column parallel table" '^\| 序号 \| 可并行工作项 \| 前置条件 \| 状态 \| 下一步 Workflow / 入口门禁 \|$' "$BACKLOG"
assert_not_match "old four-column parallel table" '^\| 序号 \| 可并行工作项 \| 前置条件 \| 状态 \|$' "$BACKLOG"
assert_match "Draft Bug entry qualification" 'B-005.*B-007.*B-008.*bug-fix.*诊断|B-005.*B-007.*B-008.*bug-fix.*diagnos' "$BACKLOG"
assert_match "Draft Story entry qualification" 'feature-dev.*Ready|`Ready`.*feature-dev|Ready.*feature-dev' "$BACKLOG"
assert_match "Task entry qualification" 'Task.*feature-dev.*bug-fix.*refactor|feature-dev / bug-fix / refactor' "$BACKLOG"
assert_match "Blocked entry qualification" 'Blocked.*依赖|Blocked.*depend' "$BACKLOG"
assert_match "parallel authorization preserved" '用户明确允许并行实施时才使用此表' "$BACKLOG"
assert_not_match "new global readiness status" '可启动|可实施' "$BACKLOG"

printf 'Parallel work table contract checks passed.\n'
