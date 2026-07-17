#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FINISHING_SKILL="$ROOT_DIR/src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_literal() {
  local label="$1"
  local literal="$2"
  rg --no-ignore -F -n -- "$literal" "$FINISHING_SKILL" >/dev/null || fail "missing $label"
}

assert_no_match() {
  local label="$1"
  local pattern="$2"
  if rg --no-ignore -n "$pattern" "$FINISHING_SKILL" >/dev/null; then
    fail "unexpected $label"
  fi
}

assert_literal "whole-run mode" "Dev Cadence Whole-Run Discard"
assert_literal "run directory context" "Run directory"
assert_literal "owned worktree evidence" "Worktree created by this run"
assert_literal "current-run-only choice" "Discard the current run only"
assert_literal "expanded workspace choice" "Discard the entire owned workspace or branch"
assert_literal "cancel choice" "Cancel"
assert_literal "no persistent record warning" "no persistent run record will remain"
assert_literal "successful normalized result" '`whole_run_discarded`'
assert_literal "cancelled normalized result" '`discard_cancelled`'
assert_literal "blocked normalized result" '`discard_blocked`'
assert_literal "records deleted last" "Delete the run directory last"
assert_literal "owned worktree only" "must not remove an external or unknown worktree"
assert_literal "postcondition verification" "Verify the exact branch, worktree, path, and run-directory postconditions"
assert_literal "detached HEAD exclusion" "must not proceed from or move into detached HEAD"
assert_literal "attached branch postcondition" "successful postconditions require an attached, verified non-task branch"
assert_literal "exhaustive path classification before choices" "Before presenting the three choices, exhaustively enumerate every changed path and classify it as current-run, external, or unknown. Treat unknown as external."
assert_literal "post-confirmation identity comparison" 'Immediately after final user confirmation and before any destructive command, repeat the complete identity snapshot and compare it with the confirmed snapshot. Any mismatch returns `discard_blocked` without changing Git or filesystem state.'
assert_literal "post-confirmation complete path reclassification" 'Immediately after final user confirmation and before any destructive command, re-enumerate and reclassify every changed path as current-run, external, or unknown and compare the complete classified path set with the confirmed snapshot. Any change, addition, deletion, or classification mismatch returns `discard_blocked` without changing Git or filesystem state.'
assert_literal "current-run-only branch and worktree preservation" 'If deleting the task branch or owned worktree would affect external or unknown changes, retain that branch or worktree and delete only independently deletable current-run objects. Return `discard_blocked` when preservation cannot be proven.'
assert_literal "preservation-aware discard success" "the run directory was deleted, every independently deletable current-run object was deleted, and all unselected external or unknown changes were preserved"
assert_literal "whole-run typed first confirmation" 'For the first destructive confirmation, require the user to type the exact literal `discard`. A missing or invalid response returns `discard_cancelled` or `discard_blocked` without changing Git or filesystem state.'
assert_literal "retained worktree safe deletion sequence" 'When an owned worktree is retained to preserve external or unknown paths, verify all branch and path postconditions, preserve those paths byte-for-byte, and delete the run directory last from outside the retained workspace. Return `whole_run_discarded` only after verifying that the run directory is absent.'
assert_no_match "unscoped hard reset" '^[[:space:]]*git reset --hard([[:space:]]|$)'
assert_no_match "unscoped clean" '^[[:space:]]*git clean -fd([[:space:]]|$)'

printf 'Finishing Discard contract checks passed.\n'
