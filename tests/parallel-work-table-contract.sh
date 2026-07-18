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
assert_match "derived pending order" '待处理.*sole authoritative|待处理.*唯一权威|derived view.*待处理|派生视图.*待处理' "$SKILL"
assert_match "no independent ordering" 'must not maintain an independent ordering|不得维护独立排序' "$SKILL"
assert_match "blocked first item requires reorder" 'first.*cannot.*proceed.*reorder|首项.*不能推进.*调整排序|不得静默跳过' "$SKILL"
assert_match "routing owner" 'using-dev-cadence.*workflow.*route|Workflow.*using-dev-cadence|路由.*using-dev-cadence' "$SKILL"
assert_match "Story entry rule" 'Story.*`Ready`.*`feature-dev`|Story.*Ready.*feature-dev' "$SKILL"
assert_match "Task entry rule" 'Task.*`feature-dev`.*`bug-fix`.*`refactor`|Task.*feature-dev.*bug-fix.*refactor' "$SKILL"
assert_match "Bug diagnosis rule" 'Bug.*`bug-fix`.*diagnos|Bug.*bug-fix.*诊断' "$SKILL"
assert_match "Blocked dependency rule" 'Blocked.*depend|Blocked.*依赖' "$SKILL"
assert_match "no automatic start" 'must not.*automatically start|不得自动启动|not.*directly modify code' "$SKILL"

assert_match "four-column parallel table" '^\| 并行组 \| 可并行工作项 \| 前置条件 \| 状态 \|$' "$BACKLOG"
assert_not_match "removed workflow entry column" '^\| 并行组 \| 可并行工作项 \| 前置条件 \| 状态 \| 下一步 Workflow / 入口门禁 \|$' "$BACKLOG"
assert_not_match "removed row workflow qualification" '^\|.*\| (bug-fix|feature-dev|refactor).*\|$' "$BACKLOG"
assert_match "parallel authorization preserved" '用户明确允许并行实施时才使用此表' "$BACKLOG"
assert_not_match "new global readiness status" '可启动|可实施' "$BACKLOG"

parallel_line_for() {
  local item="$1"
  awk -F'|' -v item="$item" '
    /^## 当前可并行实施表$/ { in_view = 1 }
    /^## Dependency Table$/ { in_view = 0 }
    in_view && /^\|/ && index($3, item) { print NR; exit }
  ' "$BACKLOG"
}

test -z "$(parallel_line_for '[S-017](stories/S-017-work-item-development-workflow-integration.md)')" ||
  fail "completed S-017 remains in the parallel view"
test "$(parallel_line_for '[S-041](stories/S-041-change-log-contract-and-history-governance.md)')" -lt \
  "$(parallel_line_for '[S-029](stories/S-029-feature-persistent-record-contract.md)')" ||
  fail "parallel view does not follow pending order for S-041 and S-029"

printf 'Parallel work table contract checks passed.\n'
