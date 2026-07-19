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

line_number() {
  local pattern="$1"
  local path="$2"
  rg --no-ignore -n "$pattern" "$path" | head -n 1 | cut -d: -f1
}

assert_order() {
  local label="$1"
  local before_pattern="$2"
  local after_pattern="$3"
  local path="$4"
  local before_line after_line

  before_line="$(line_number "$before_pattern" "$path")"
  after_line="$(line_number "$after_pattern" "$path")"
  [[ -n "$before_line" && -n "$after_line" && "$before_line" -lt "$after_line" ]] ||
    fail "expected $label in order in ${path#"$ROOT_DIR/"} (before=${before_line:-missing}, after=${after_line:-missing})"
}

assert_equal() {
  local label="$1"
  local expected="$2"
  local actual="$3"

  [[ "$expected" == "$actual" ]] ||
    fail "$label (expected=$expected, actual=$actual)"
}

assert_fixture_match() {
  local label="$1"
  local pattern="$2"
  local value="$3"

  [[ "$value" =~ $pattern ]] ||
    fail "$label (pattern=$pattern, actual=$value)"
}

assert_primary_checkout_claim_baseline_fixture() {
  local fixture_dir primary_dir card_path backlog_path main_card task_card
  local main_commit task_commit

  fixture_dir="$(mktemp -d)"
  primary_dir="$fixture_dir/primary"
  card_path="docs/cards/T-001.md"
  backlog_path="docs/backlog.md"
  trap 'rm -rf "$fixture_dir"' RETURN

  git -C "$fixture_dir" init --initial-branch=main primary >/dev/null
  git -C "$primary_dir" config user.email 'contract@example.test'
  git -C "$primary_dir" config user.name 'Workflow Contract'
  mkdir -p "$primary_dir/docs/cards"
  printf 'Status: Draft\n' >"$primary_dir/$card_path"
  printf '| T-001 | Draft | pending |\n' >"$primary_dir/$backlog_path"
  git -C "$primary_dir" add "$card_path" "$backlog_path"
  git -C "$primary_dir" commit -m 'test: seed pending work item' >/dev/null

  # This reproduces the rejected baseline: the claim is still uncommitted when
  # the task branch is created, so committing it there leaves main unchanged.
  printf 'Status: In Progress\n' >"$primary_dir/$card_path"
  printf '| T-001 | In Progress | claimed |\n' >"$primary_dir/$backlog_path"
  git -C "$primary_dir" switch -c task-from-uncommitted-claim >/dev/null
  git -C "$primary_dir" add "$card_path" "$backlog_path"
  git -C "$primary_dir" commit -m 'test: claim only on task branch' >/dev/null
  main_card="$(git -C "$primary_dir" show "main:$card_path")"
  assert_fixture_match "uncommitted claim must leave main card Draft" 'Status: Draft' "$main_card"
  main_card="$(git -C "$primary_dir" show "main:$backlog_path")"
  assert_fixture_match "uncommitted claim must leave main Backlog pending" 'Draft.*pending' "$main_card"
  main_commit="$(git -C "$primary_dir" rev-parse main)"
  task_commit="$(git -C "$primary_dir" rev-parse task-from-uncommitted-claim)"
  [[ "$main_commit" != "$task_commit" ]] ||
    fail "uncommitted claim task branch must not share main's branch pointer"

  # The accepted baseline persists the atomic claim on the primary checkout
  # before creating the task branch, making both branches share that commit.
  git -C "$primary_dir" switch main >/dev/null
  printf 'Status: In Progress\n' >"$primary_dir/$card_path"
  printf '| T-001 | In Progress | claimed |\n' >"$primary_dir/$backlog_path"
  git -C "$primary_dir" add "$card_path" "$backlog_path"
  git -C "$primary_dir" commit -m 'test: persist claim on primary checkout' >/dev/null
  git -C "$primary_dir" switch -c task-from-primary-claim >/dev/null
  main_commit="$(git -C "$primary_dir" rev-parse main)"
  task_commit="$(git -C "$primary_dir" rev-parse task-from-primary-claim)"
  assert_equal "persisted claim task branch must share main's branch pointer" "$main_commit" "$task_commit"
  main_card="$(git -C "$primary_dir" show "main:$card_path")"
  task_card="$(git -C "$primary_dir" show "task-from-primary-claim:$card_path")"
  assert_fixture_match "persisted main card must be In Progress" 'Status: In Progress' "$main_card"
  assert_equal "persisted claim card content must match on main and task branch" "$main_card" "$task_card"
  main_card="$(git -C "$primary_dir" show "main:$backlog_path")"
  task_card="$(git -C "$primary_dir" show "task-from-primary-claim:$backlog_path")"
  assert_fixture_match "persisted main Backlog must be In Progress" 'In Progress.*claimed' "$main_card"
  assert_equal "persisted claim Backlog content must match on main and task branch" "$main_card" "$task_card"

  trap - RETURN
  rm -rf "$fixture_dir"
  printf 'B-015 primary-checkout claim baseline fixture passed.\n'
}

assert_match "entry work-item claiming section" '^## Work Item Intake And Claiming$' "$ENTRY_SKILL"
assert_match "implementation-only claim trigger" 'claim.*only.*explicit.*implementation|explicit.*implementation.*claim' "$ENTRY_SKILL"
assert_match "pending order authority" '`待处理`.*sole authoritative|sole authoritative.*`待处理`' "$ENTRY_SKILL"
assert_match "ordered intake matrix" 'selection.*type.*status.*maturity.*eligibility.*claim|选择.*类型.*状态.*成熟度.*资格.*领取' "$ENTRY_SKILL"
assert_order "intake resolves eligibility before first claim" 'type.*status.*maturity.*eligibility|类型.*状态.*成熟度.*资格' 'claim it by atomically|原子.*领取' "$ENTRY_SKILL"
assert_match "draft story blocked before ready" 'Draft Story.*must not.*claim|Draft Story.*不得.*领取' "$ENTRY_SKILL"
assert_match "ready story claim qualification" 'Ready Story.*user-confirmed.*claim|Ready Story.*用户确认.*领取' "$ENTRY_SKILL"
assert_match "task claim qualification" 'Task.*eligible.*without.*Ready|Task.*可领取.*无需.*Ready' "$ENTRY_SKILL"
assert_match "bug claim qualification" 'Bug.*eligible.*without.*Ready|Bug.*可领取.*无需.*Ready' "$ENTRY_SKILL"
assert_match "claim before branch" '(?i)claim.*before.*branch|branch.*after.*claim|分支.*领取.*之后' "$ENTRY_SKILL"
assert_match "claim before worktree" '(?i)claim.*before.*worktree|worktree.*after.*claim|worktree.*领取.*之后' "$ENTRY_SKILL"
assert_match "workspace preparation gate" \
  'workspace preparation.*complete.*before.*route.*downstream' "$ENTRY_SKILL"
assert_match "enabled worktree handoff" \
  'worktree\.enabled: true.*immediately.*create or verify.*worktree' "$ENTRY_SKILL"
assert_match "disabled branch handoff" \
  'worktree\.enabled: false.*immediately.*prepare.*dedicated.*branch.*must not.*create.*worktree' "$ENTRY_SKILL"

assert_primary_checkout_claim_baseline_fixture

# Both workspace configuration paths must name the same persisted primary-checkout
# claim baseline. Keeping these assertions branch-specific prevents a true-only
# repair from accidentally satisfying the false path.
assert_match "enabled worktree path primary checkout claim write target" \
  'worktree\.enabled: true.*primary.*checkout.*claim.*write' "$ENTRY_SKILL"
assert_match "enabled worktree path claim persists before worktree creation" \
  'worktree\.enabled: true.*claim.*persist.*commit.*worktree' "$ENTRY_SKILL"
assert_match "enabled worktree path worktree starts from persisted claim commit" \
  'worktree\.enabled: true.*worktree.*from.*claim.*commit' "$ENTRY_SKILL"
assert_match "enabled worktree path failure blocks workspace and routing" \
  'worktree\.enabled: true.*claim.*persist.*fail.*must not.*worktree.*route' "$ENTRY_SKILL"
assert_match "disabled branch path primary checkout claim write target" \
  'worktree\.enabled: false.*primary.*checkout.*claim.*write' "$ENTRY_SKILL"
assert_match "disabled branch path claim persists before branch creation" \
  'worktree\.enabled: false.*claim.*persist.*commit.*dedicated.*branch' "$ENTRY_SKILL"
assert_match "disabled branch path branch starts from persisted claim commit" \
  'worktree\.enabled: false.*dedicated.*branch.*from.*claim.*commit' "$ENTRY_SKILL"
assert_match "disabled branch path failure blocks workspace and routing" \
  'worktree\.enabled: false.*claim.*persist.*fail.*must not.*branch.*route' "$ENTRY_SKILL"
assert_order "claim -> workspace preparation -> downstream routing" \
  'claim it by atomically' \
  'workspace preparation.*complete.*before.*route.*downstream' \
  "$ENTRY_SKILL"
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
