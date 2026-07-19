#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/src/skills/bug-fix/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_match() {
  local label="$1"
  local pattern="$2"
  rg --no-ignore -n "$pattern" "$SKILL" >/dev/null || fail "missing $label in src/skills/bug-fix/SKILL.md"
}

assert_match "completion synchronization section" '^## Backlog Synchronization After Completion$'
assert_match "merge success trigger" '`merge`.*Backlog|successful.*merge.*Backlog|实际.*merge.*回写'
assert_match "Done result" '`Done`|`已完成`'
assert_match "Bug identity lookup" 'Bug ID.*Version|Bug.*ID.*Version|卡片.*Version'
assert_match "conflict stop" 'conflict.*stop|冲突.*停止|visible-fact conflict'
assert_match "atomic lifecycle move" 'atomically.*待处理|原子.*已完成|atomic.*Backlog'
assert_match "unrelated order preservation" 'unrelated.*order|无关.*排序|待处理.*排序'
assert_match "parallel row removal" 'parallel.*remove|并行表.*删除|并行.*移除'
assert_match "Bug card Done writeback" 'Bug card.*Status.*Done|card.*status.*Done|Bug 卡片.*Status.*Done'
assert_match "repair and integration references" 'repair result.*integration reference|修复结果.*集成引用'
assert_match "execution Change Log entry" 'Change Log.*execution|执行.*Change Log'
assert_match "execution keeps current version" 'execution.*current.*Version.*does not increment|current.*Version.*does not increment.*execution'
assert_match "execution Change Log idempotence" 'same.*execution.*event.*must not.*duplicate.*Change Log|must not.*duplicate.*Change Log.*same.*execution.*event'
assert_match "atomic card and Backlog write" 'atomic.*card.*Backlog|card and Backlog.*atomic|atomically.*card.*Backlog|卡片.*Backlog.*原子'
assert_match "zero partial writes" 'no partial.*card.*Backlog|zero partial write|不得部分写入'

for outcome in 'pull request' 'keep' 'discard_cancelled' 'discard_blocked' 'whole_run_discarded'; do
  assert_match "no Done for $outcome" "$outcome.*not.*Done|$outcome.*不.*Done|$outcome.*不.*回写"
done

assert_match "completion evidence" 'manifest.*Business Acceptance.*follow-up|manifest.*验收.*回写|actual sync result'

printf 'Bug Fix Backlog synchronization contract checks passed.\n'
