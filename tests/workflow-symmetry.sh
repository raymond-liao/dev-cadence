#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FEATURE_SKILL="$ROOT_DIR/src/skills/feature-dev/SKILL.md"
BUG_FIX_SKILL="$ROOT_DIR/src/skills/bug-fix/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"

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

assert_pair() {
  local label="$1"
  local feature_pattern="$2"
  local bug_pattern="$3"

  assert_match "feature $label" "$feature_pattern" "$FEATURE_SKILL"
  assert_match "bug-fix $label" "$bug_pattern" "$BUG_FIX_SKILL"
}

assert_match "entry active workflow continuation section" "## Active Workflow Continuation" "$ENTRY_SKILL"
assert_match "entry unfinished workflow check" "unfinished Dev Cadence workflow" "$ENTRY_SKILL"
assert_match "entry no new run for same task" "Do not create a new workflow run" "$ENTRY_SKILL"
assert_match "entry out-of-scope confirmation" "expand the current task or start a separate task" "$ENTRY_SKILL"

assert_pair "configuration section" "## Configuration" "## Configuration"
assert_pair "target config source" "\\.dev-cadence\\.yaml" "\\.dev-cadence\\.yaml"
assert_pair "output language rule" "output_language" "output_language"
assert_pair "worktree preference rule" "worktree\\.enabled" "worktree\\.enabled"
assert_pair "git checkpoints section" "## Git Checkpoints" "## Git Checkpoints"
assert_pair "commit after confirmation rule" "After the user confirms a stage output" "After the user confirms a stage output"
assert_pair "no push rule" "Do not push unless the user explicitly asks" "Do not push unless the user explicitly asks"

assert_pair "manifest creation rule" "Create and maintain a run manifest" "Create and maintain a run manifest"
assert_pair "manifest status values" "Use stage status values" "Use stage status values"
assert_pair "terminal checkpoint rule" "must not contain .*pending.* checkpoint commit values" "must not contain .*pending.* checkpoint commit values"
assert_pair "portable path rule" "do not persist local absolute paths" "do not persist local absolute paths"
assert_pair "manifest update cadence" "whenever a stage record is created or updated" "whenever a stage record is created or updated"

assert_pair "active task change handling" "## Active Task Change Handling" "## Active Task Change Handling"
assert_pair "current run reuse" "current workflow run" "current workflow run"
assert_pair "existing records update" "update the existing stage records and manifest" "update the existing stage records and manifest"
assert_pair "affected stage rollback" "return to the earliest affected stage" "return to the earliest affected stage"
assert_pair "out-of-scope branch decision" "expand the current feature or start a separate task" "expand the current bug fix or start a separate task"

assert_pair "plan overview requirement" "Task Overview" "Task Overview"
assert_pair "plan overview table" "\\| Task \\| Goal \\| Files \\| Verification \\|" "\\| Task \\| Goal \\| Files \\| Verification \\|"
assert_pair "plan confirmation gate" "Ask the user to confirm the plan before implementation starts" "Ask the user to confirm the plan before implementation starts"
assert_pair "sdd task directory variable" "DEV_CADENCE_TASK_DIR=build/dev-cadence/feature-dev/<feature-slug>" "DEV_CADENCE_TASK_DIR=build/dev-cadence/bug-fix/<bug-slug>"
assert_pair "completed plan checklist sync" "Mark completed implementation-plan steps as .*\\[x\\]" "Mark completed repair-plan steps as .*\\[x\\]"

assert_pair "code review evidence section" "Code Review Evidence" "Code Review Evidence"
assert_pair "review inputs checklist" "## Review Inputs" "## Review Inputs"
assert_pair "review perspectives checklist" "## Review Perspectives" "## Review Perspectives"
assert_pair "review validation state" "validation state: .*validated.*not validated.*fixed.*accepted risk" "validation state: .*validated.*not validated.*fixed.*accepted risk"
assert_pair "code review report path" "03-code-review-report\\.md" "04-code-review-report\\.md"

assert_pair "verification freshness rule" "Do not claim the system is ready without fresh verification evidence" "Do not claim the bug is fixed or regression-free without fresh verification evidence"
assert_pair "test cases table contract" "Test Cases.*ID.*Scenario.*Type.*Execution.*Result.*Evidence" "Test Cases.*ID.*Scenario.*Type.*Execution.*Result.*Evidence"
assert_pair "coverage honesty rule" "Coverage must be honest" "Coverage must be honest"

assert_pair "business acceptance numbered options" "fixed numbered options" "fixed numbered options"
assert_pair "ambiguous acceptance rejection" "Do not infer acceptance from ambiguous positive feedback" "Do not infer acceptance from ambiguous positive feedback"
assert_pair "decision identity" "Decision By" "Decision By"
assert_pair "decision timestamp" "Decision At" "Decision At"
assert_pair "final follow-up actions" "Final Follow-Up Actions" "Final Follow-Up Actions"

assert_pair "completion finishing flow" "finishing-a-development-branch/SKILL\\.md" "finishing-a-development-branch/SKILL\\.md"
assert_pair "terminal readiness checklist" "Before marking the run terminal" "Before marking the run terminal"
assert_pair "terminal manifest readiness" "Manifest has a terminal overall status" "Manifest has a terminal overall status"
assert_pair "no stale future-tense records" "No stage record contains stale future-tense" "No stage record contains stale future-tense"

printf 'Workflow symmetry checks passed.\n'
