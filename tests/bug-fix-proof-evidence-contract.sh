#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/src/workflows/bug-fix/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_match() {
  local label="$1"
  local pattern="$2"

  rg --no-ignore -n "$pattern" "$SKILL" >/dev/null ||
    fail "missing $label in src/workflows/bug-fix/SKILL.md"
}

assert_match "proof ID format" '`B-nnn-P-nn`'
assert_match "proof ID derives from Bug card" 'Bug card ID.*proof ID|proof ID.*Bug card ID'
assert_match "one proof ID per independently verifiable claim" 'each independently verifiable defect claim.*one stable proof ID'
assert_match "proof ID is not evidence granularity" 'Do not create a proof ID.*command.*commit.*test case'
assert_match "diagnosis creates proof ID" 'create.*proof ID.*01-problem-diagnosis-record\.md|01-problem-diagnosis-record\.md.*create.*proof ID'
assert_match "reproducible RED evidence" 'RED evidence'
assert_match "unavailable RED handling" 'RED.*unavailable.*alternative causal evidence.*reason.*limitation'
assert_match "no fabricated RED" 'Do not fabricate RED'
assert_match "plan references same proof ID" '03-repair-plan\.md.*same proof ID.*planned RED/GREEN checks'
assert_match "repair record references implementation evidence" '04-repair-record\.md.*same proof ID.*implementation commit.*Changed Files'
assert_match "regression report references verification evidence" '05-regression-test-report\.md.*same proof ID.*`RV-\*`.*Coverage.*verification conclusion'
assert_match "reproducible proof preserves ID across RED and GREEN" 'reproducible.*RED.*GREEN.*same proof ID'
assert_match "manifest proof index" 'Proof Index'
assert_match "proof index stable anchor" 'stable Markdown heading anchor'
assert_match "proof index navigation only" 'only navigation links.*does not copy evidence body'

printf 'Bug Fix proof evidence contract checks passed.\n'
