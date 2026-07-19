#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"
FEATURE_SKILL="$ROOT_DIR/src/skills/feature-dev/SKILL.md"
BUG_FIX_SKILL="$ROOT_DIR/src/skills/bug-fix/SKILL.md"
REFACTOR_SKILL="$ROOT_DIR/src/skills/refactor/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  rg --no-ignore -n "$pattern" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_match "entry work-item claiming section" '^## Work Item Intake And Claiming$' "$ENTRY_SKILL"
assert_match "implementation-only claim trigger" 'claim.*only.*explicit.*implementation|explicit.*implementation.*claim' "$ENTRY_SKILL"
assert_match "pending order authority" '`待处理`.*sole authoritative|sole authoritative.*`待处理`' "$ENTRY_SKILL"
assert_match "claim before branch" '(?i)claim.*before.*branch|branch.*after.*claim|分支.*领取.*之后' "$ENTRY_SKILL"
assert_match "claim before worktree" '(?i)claim.*before.*worktree|worktree.*after.*claim|worktree.*领取.*之后' "$ENTRY_SKILL"
assert_match "card backlog atomic sync" 'card.*Backlog.*atomically|Backlog.*card.*原子|原子.*卡片.*Backlog' "$ENTRY_SKILL"
assert_match "story analysis readiness route" 'Draft Story.*work-item-analysis.*Ready Story.*feature-dev' "$ENTRY_SKILL"
assert_match "feature ready story gate" 'feature-dev.*confirmed.*Ready Story|Ready Story.*feature-dev.*confirmed' "$ENTRY_SKILL"
assert_match "task non-unified gate" 'Task.*does not.*Ready|Task.*non-unified|Task.*非统一' "$ENTRY_SKILL"
assert_match "bug diagnosis non-unified gate" 'Bug.*bug-fix.*without.*Ready|Bug.*非统一.*bug-fix' "$ENTRY_SKILL"
assert_match "missing card intent routing" 'missing.*card.*work-item-planning.*work-item-analysis.*bug-fix|缺卡.*work-item-planning.*work-item-analysis.*bug-fix' "$ENTRY_SKILL"
assert_match "no claim for analysis" 'analysis.*must not.*claim|分析.*不得.*领取' "$ENTRY_SKILL"
assert_match "no duplicate claim" 'already.*`In Progress`.*must not.*claim|已经.*`In Progress`.*不得.*领取' "$ENTRY_SKILL"
assert_match "no new claiming skill" 'must not create.*claim.*skill|不得新增.*领取.*skill' "$ENTRY_SKILL"
assert_match "claim keeps current version and records event" 'claim.*current.*Version.*Change Log.*important event|current.*Version.*Change Log.*important event.*claim' "$ENTRY_SKILL"
assert_match "claim writeback idempotence" 'claim.*idempotent.*Change Log|idempotent.*Change Log.*claim' "$ENTRY_SKILL"

for status in 'card path' 'Version' 'selected scope'; do
  assert_match "Delivery $status" "$status" "$FEATURE_SKILL"
  assert_match "Bug Fix $status" "$status" "$BUG_FIX_SKILL"
  assert_match "Refactor $status" "$status" "$REFACTOR_SKILL"
done

assert_match "Feature ready gate" 'only.*confirmed.*`Ready Story`|`Ready Story`.*confirmed' "$FEATURE_SKILL"
assert_match "Feature lifecycle writeback" 'start.*rework.*Business Acceptance.*Completion.*writeback|开始.*返工.*验收.*Completion.*回写' "$FEATURE_SKILL"
assert_match "Bug lifecycle writeback" 'start.*rework.*Business Acceptance.*Completion.*writeback|开始.*返工.*验收.*Completion.*回写' "$BUG_FIX_SKILL"
assert_match "Refactor lifecycle writeback" 'start.*rework.*Business Acceptance.*Completion.*writeback|开始.*返工.*验收.*Completion.*回写' "$REFACTOR_SKILL"

for path in "$FEATURE_SKILL" "$BUG_FIX_SKILL" "$REFACTOR_SKILL"; do
  assert_match "card version freshness" 'current.*card.*Version|当前.*卡片.*Version' "$path"
  assert_match "visible fact conflict" 'visible-fact.*conflict|可见事实.*冲突' "$path"
  assert_match "idempotent lifecycle writeback" 'idempotent|幂等' "$path"
  assert_match "no false Done" 'must not.*`Done`|不得.*`Done`|not.*mark.*Done' "$path"
  assert_match "lifecycle keeps current version" 'lifecycle.*current.*Version.*does not increment|current.*Version.*does not increment.*lifecycle' "$path"
  assert_match "lifecycle Change Log important event" 'lifecycle.*Change Log.*important event|Change Log.*important event.*lifecycle' "$path"
  assert_match "lifecycle Change Log duplicate prevention" 'same.*lifecycle.*event.*must not.*duplicate.*Change Log|must not.*duplicate.*Change Log.*same.*lifecycle.*event' "$path"
done

assert_not_match "new lifecycle skill" 'src/skills/work-item-lifecycle|work-item-lifecycle' "$ENTRY_SKILL"

printf 'S-017 work-item development workflow contract checks passed.\n'
