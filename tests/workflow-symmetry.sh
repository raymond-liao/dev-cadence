#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FEATURE_SKILL="$ROOT_DIR/src/skills/feature-dev/SKILL.md"
BUG_FIX_SKILL="$ROOT_DIR/src/skills/bug-fix/SKILL.md"
REFACTOR_SKILL="$ROOT_DIR/src/skills/refactor/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"
AGENTS_SNIPPET="$ROOT_DIR/src/AGENTS-snippet.md"
REPO_AGENTS="$ROOT_DIR/AGENTS.md"
REFACTOR_FLOW_DOC="$ROOT_DIR/docs/refactor-business-flow.md"

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

assert_workflows() {
  local label="$1"
  local feature_pattern="$2"
  local bug_pattern="$3"
  local refactor_pattern="$4"

  assert_match "feature $label" "$feature_pattern" "$FEATURE_SKILL"
  assert_match "bug-fix $label" "$bug_pattern" "$BUG_FIX_SKILL"
  assert_match "refactor $label" "$refactor_pattern" "$REFACTOR_SKILL"
}

assert_match "entry active workflow continuation section" "## Active Workflow Continuation" "$ENTRY_SKILL"
assert_match "entry unfinished workflow check" "unfinished Dev Cadence workflow" "$ENTRY_SKILL"
assert_match "entry no new run for same task" "Do not create a new workflow run" "$ENTRY_SKILL"
assert_match "entry out-of-scope confirmation" "expand the current task or start a separate task" "$ENTRY_SKILL"
assert_match "entry active run commit continuation" "Commit the in-scope changes under the active workflow's Git rules" "$ENTRY_SKILL"
assert_match "entry active workflow red flag" "The user asked to commit, so the active workflow is complete" "$ENTRY_SKILL"
assert_match "entry refactor flow" "\\.dev-cadence/skills/refactor/SKILL\\.md" "$ENTRY_SKILL"
assert_match "entry refactor behavior-preserving rule" "improve internal structure without intentionally changing expected behavior" "$ENTRY_SKILL"
assert_match "entry mixed flow clarification" "mixes two or more of a defect report, requested behavior change, and structural cleanup" "$ENTRY_SKILL"
assert_match "installed trigger active task follow-up" "active-task follow-up" "$AGENTS_SNIPPET"
assert_match "installed trigger testing" "testing" "$AGENTS_SNIPPET"
assert_match "installed trigger verification" "verification" "$AGENTS_SNIPPET"
assert_match "installed trigger commit" "commit/checkpoint" "$AGENTS_SNIPPET"
assert_match "repo refactor directory responsibility" "src/skills/refactor/SKILL.md" "$REPO_AGENTS"
assert_match "repo refactor modification entry" "修改 refactor 工作流时" "$REPO_AGENTS"
assert_match "repo three-workflow symmetry" "feature-dev、bug-fix 和 refactor" "$REPO_AGENTS"

assert_workflows "configuration section" "## Configuration" "## Configuration" "## Configuration"
assert_workflows "target config source" "\\.dev-cadence\\.yaml" "\\.dev-cadence\\.yaml" "\\.dev-cadence\\.yaml"
assert_workflows "output language rule" "output_language" "output_language" "output_language"
assert_workflows "worktree preference rule" "worktree\\.enabled" "worktree\\.enabled" "worktree\\.enabled"
assert_workflows "git checkpoints section" "## Git Checkpoints" "## Git Checkpoints" "## Git Checkpoints"
assert_workflows "commit without confirmation rule" "Commits do not require user confirmation" "Commits do not require user confirmation" "Commits do not require user confirmation"
assert_workflows "commit is not stage confirmation" "A commit does not confirm the current stage" "A commit does not confirm the current stage" "A commit does not confirm the current stage"
assert_workflows "external git operation confirmation" "merge, create or update a PR, push, discard work, or delete a branch" "merge, create or update a PR, push, discard work, or delete a branch" "merge, create or update a PR, push, discard work, or delete a branch"
assert_workflows "active run commit request gate" "## User-Requested Commits During Active Runs" "## User-Requested Commits During Active Runs" "## User-Requested Commits During Active Runs"
assert_workflows "active run commit allowed" "commit current in-scope changes without asking" "commit current in-scope changes without asking" "commit current in-scope changes without asking"
assert_workflows "commit cannot bypass stages" "does not confirm a stage or bypass testing, verification, business acceptance, or Completion" "does not confirm a stage or bypass testing, verification, business acceptance, or Completion" "does not confirm a stage or bypass testing, verification, business acceptance, or Completion"
assert_workflows "active run commit red flags" "### Commit Red Flags" "### Commit Red Flags" "### Commit Red Flags"
assert_workflows "commit completion rationalization" "User asked to commit, so the workflow is complete" "User asked to commit, so the workflow is complete" "User asked to commit, so the workflow is complete"
assert_workflows "no push rule" "Do not push unless the user explicitly asks" "Do not push unless the user explicitly asks" "Do not push unless the user explicitly asks"

assert_workflows "manifest creation rule" "Create and maintain a run manifest" "Create and maintain a run manifest" "Create and maintain a run manifest"
assert_workflows "manifest status values" "Use stage status values" "Use stage status values" "Use stage status values"
assert_workflows "terminal checkpoint rule" "must not contain .*pending.* checkpoint commit values" "must not contain .*pending.* checkpoint commit values" "must not contain .*pending.* checkpoint commit values"
assert_workflows "no tracked changes checkpoint rule" "skipped: no tracked changes" "skipped: no tracked changes" "skipped: no tracked changes"
assert_workflows "portable path rule" "do not persist local absolute paths" "do not persist local absolute paths" "do not persist local absolute paths"
assert_workflows "manifest update cadence" "whenever a stage record is created or updated" "whenever a stage record is created or updated" "whenever a stage record is created or updated"
assert_match "feature requirements record" "01-requirements\\.md" "$FEATURE_SKILL"
assert_match "feature technical solution record" "02-technical-solution\\.md" "$FEATURE_SKILL"
assert_match "feature implementation plan record" "03-implementation-plan\\.md" "$FEATURE_SKILL"

assert_workflows "active task change handling" "## Active Task Change Handling" "## Active Task Change Handling" "## Active Task Change Handling"
assert_workflows "current run reuse" "current workflow run" "current workflow run" "current workflow run"
assert_workflows "existing records update" "update the existing stage records and manifest" "update the existing stage records and manifest" "update the existing stage records and manifest"
assert_workflows "affected stage rollback" "return to the earliest affected stage" "return to the earliest affected stage" "return to the earliest affected stage"
assert_workflows "out-of-scope branch decision" "expand the current feature or start a separate task" "expand the current bug fix or start a separate task" "split the request into a separate task"
assert_workflows "active task red flags" "### Active Task Red Flags" "### Active Task Red Flags" "### Active Task Red Flags"
assert_workflows "new document rationalization" "start a new requirements document" "start a new diagnosis document" "start a new refactor document"

assert_workflows "plan overview requirement" "Task Overview" "Task Overview" "Task Overview"
assert_workflows "plan overview table" "\\| Task \\| Goal \\| Files \\| Verification \\|" "\\| Task \\| Goal \\| Files \\| Verification \\|" "\\| Task \\| Goal \\| Files \\| Verification \\|"
assert_workflows "plan confirmation gate" "Ask the user to confirm the plan before implementation starts" "Ask the user to confirm the plan before implementation starts" "Ask the user to confirm the plan before implementation starts"
assert_match "feature plan path override" "This active workflow path overrides any generic default plan path" "$FEATURE_SKILL"
assert_workflows "sdd task directory variable" "DEV_CADENCE_TASK_DIR=build/dev-cadence/feature-dev/<feature-slug>" "DEV_CADENCE_TASK_DIR=build/dev-cadence/bug-fix/<bug-slug>" "DEV_CADENCE_TASK_DIR=build/dev-cadence/refactor/<refactor-slug>"
assert_workflows "completed plan checklist sync" "Mark completed implementation-plan steps as .*\\[x\\]" "Mark completed repair-plan steps as .*\\[x\\]" "Mark completed refactor-plan steps as .*\\[x\\]"

assert_workflows "code review evidence section" "Code Review Evidence" "Code Review Evidence" "Code Review Evidence"
assert_workflows "review inputs checklist" "## Review Inputs" "## Review Inputs" "## Review Inputs"
assert_workflows "review perspectives checklist" "## Review Perspectives" "## Review Perspectives" "## Review Perspectives"
assert_workflows "review validation state" "validation state: .*validated.*not validated.*fixed.*accepted risk" "validation state: .*validated.*not validated.*fixed.*accepted risk" "validation state: .*validated.*not validated.*fixed.*accepted risk"
assert_workflows "code review report path" "04-code-review-report\\.md" "04-code-review-report\\.md" "04-code-review-report\\.md"
assert_workflows "implementation returns to cadence" "Return control to Dev Cadence after implementation and review" "Return control to Dev Cadence after implementation and review" "Return control to Dev Cadence after implementation and review"
assert_workflows "implementation defers finishing" "Do not invoke .*finishing-a-development-branch.* during .*Implementation" "Do not invoke .*finishing-a-development-branch.* during .*Implementation" "Do not invoke .*finishing-a-development-branch.* during .*Implementation"

assert_workflows "verification freshness rule" "Do not claim the system is ready without fresh verification evidence" "Do not claim the bug is fixed or regression-free without fresh verification evidence" "Do not claim the refactor is complete, safe, or regression-free without fresh verification evidence"
assert_workflows "test cases table contract" "Test Cases.*ID.*Scenario.*Type.*Execution.*Result.*Evidence" "Test Cases.*ID.*Scenario.*Type.*Execution.*Result.*Evidence" "Test Cases.*ID.*Scenario.*Type.*Execution.*Result.*Evidence"
assert_workflows "coverage honesty rule" "Coverage must be honest" "Coverage must be honest" "Coverage must be honest"

assert_workflows "business acceptance numbered options" "fixed numbered options" "fixed numbered options" "fixed numbered options"
assert_workflows "business acceptance feedback table" "### Ambiguous Acceptance Feedback" "### Ambiguous Acceptance Feedback" "### Ambiguous Acceptance Feedback"
assert_workflows "looks good is not acceptance" "looks good.*Not an acceptance decision" "looks good.*Not an acceptance decision" "looks good.*Not an acceptance decision"
assert_workflows "ambiguous acceptance rejection" "Do not infer acceptance from ambiguous positive feedback" "Do not infer acceptance from ambiguous positive feedback" "Do not infer acceptance from ambiguous positive feedback"
assert_workflows "localized positive feedback row" "Localized positive feedback.*Not an acceptance decision" "Localized positive feedback.*Not an acceptance decision" "Localized positive feedback.*Not an acceptance decision"
assert_workflows "decision identity" "Decision By" "Decision By" "Decision By"
assert_workflows "decision timestamp" "Decision At" "Decision At" "Decision At"
assert_workflows "final follow-up actions" "Final Follow-Up Actions" "Final Follow-Up Actions" "Final Follow-Up Actions"

assert_workflows "completion finishing flow" "finishing-a-development-branch/SKILL\\.md" "finishing-a-development-branch/SKILL\\.md" "finishing-a-development-branch/SKILL\\.md"
assert_workflows "terminal readiness checklist" "Before marking the run terminal" "Before marking the run terminal" "Before marking the run terminal"
assert_workflows "terminal manifest readiness" "Manifest has a terminal overall status" "Manifest has a terminal overall status" "Manifest has a terminal overall status"
assert_workflows "no stale future-tense records" "No stage record contains stale future-tense" "No stage record contains stale future-tense" "No stage record contains stale future-tense"

assert_match "refactor stage sequence" "Requirements Confirmation -> Refactor Solution -> Refactor Plan -> Refactor Implementation -> Regression Verification -> Business Acceptance" "$REFACTOR_SKILL"
assert_match "refactor task directory" "build/dev-cadence/refactor/<refactor-slug>/" "$REFACTOR_SKILL"
assert_match "refactor requirements record" "01-requirements\\.md" "$REFACTOR_SKILL"
assert_match "refactor solution record" "02-refactor-solution\\.md" "$REFACTOR_SKILL"
assert_match "refactor plan record" "03-refactor-plan\\.md" "$REFACTOR_SKILL"
assert_match "refactor implementation record" "04-refactor-record\\.md" "$REFACTOR_SKILL"
assert_match "refactor review report" "04-code-review-report\\.md" "$REFACTOR_SKILL"
assert_match "refactor regression report" "05-regression-test-report\\.md" "$REFACTOR_SKILL"
assert_match "refactor acceptance record" "06-business-acceptance-record\\.md" "$REFACTOR_SKILL"
assert_match "refactor principles" "## Refactoring Principles" "$REFACTOR_SKILL"
assert_match "refactor method catalog" "## Common Refactoring Methods" "$REFACTOR_SKILL"
assert_match "refactor baseline requirement" "Behavior Baseline" "$REFACTOR_SKILL"
assert_match "refactor no feature mixing" "Do not mix new features, unrelated bug fixes, or stylistic preferences into refactoring work" "$REFACTOR_SKILL"
assert_match "refactor tests-after red flag" "Code first, tests later" "$REFACTOR_SKILL"
assert_match "refactor baseline verification" "compare results against the Behavior Baseline" "$REFACTOR_SKILL"
assert_match "refactor covered baseline green loop" "When the Behavior Baseline already covers the protected behavior" "$REFACTOR_SKILL"
assert_match "refactor no invented red" "Do not invent a failing test" "$REFACTOR_SKILL"
assert_match "refactor characterization sensitivity check" "reversible test-sensitivity check" "$REFACTOR_SKILL"
assert_match "refactor flow doc title" "重构业务流程讨论总结" "$REFACTOR_FLOW_DOC"
assert_match "refactor flow doc behavior-preserving definition" "不主动改变外部可观察行为" "$REFACTOR_FLOW_DOC"
assert_match "refactor flow doc requirements stage" "1\\. 需求确认 .*明确的重构需求" "$REFACTOR_FLOW_DOC"
assert_match "refactor flow doc solution stage" "2\\. 制定重构方案 .*技术方案" "$REFACTOR_FLOW_DOC"
assert_match "refactor flow doc plan stage" "3\\. 制定计划 .*重构实施计划" "$REFACTOR_FLOW_DOC"
assert_match "refactor flow doc implementation outputs" "4\\. 开发实施 .*可工作的交付物；配套测试资产；重构记录；代码审查报告" "$REFACTOR_FLOW_DOC"
assert_match "refactor flow doc regression stage" "5\\. 回归验证 .*回归测试报告" "$REFACTOR_FLOW_DOC"
assert_match "refactor flow doc acceptance stage" "6\\. 业务验收 .*业务验收记录" "$REFACTOR_FLOW_DOC"
assert_match "refactor flow doc baseline rule" "重构方案必须包含行为基线；回归验证必须回看行为基线" "$REFACTOR_FLOW_DOC"
assert_match "refactor skill requirements output alignment" "Confirmed refactor requirements" "$REFACTOR_SKILL"
assert_match "refactor skill solution output alignment" "Refactor technical solution" "$REFACTOR_SKILL"
assert_match "refactor skill plan output alignment" "refactor implementation plan" "$REFACTOR_SKILL"
assert_match "refactor skill implementation output alignment" "Working deliverable, supporting test assets, refactor record, code review report" "$REFACTOR_SKILL"
assert_match "refactor skill regression output alignment" "Regression test report" "$REFACTOR_SKILL"
assert_match "refactor skill acceptance output alignment" "Business acceptance record" "$REFACTOR_SKILL"

if rg --no-ignore -n "\p{Han}" "$FEATURE_SKILL" "$BUG_FIX_SKILL" "$REFACTOR_SKILL" | rg -v "zh-CN|Simplified Chinese" >/dev/null; then
  fail "English workflow skills contain mixed-language examples"
fi

if rg --no-ignore -n "01-requirements-and-solution\\.md" "$FEATURE_SKILL" >/dev/null; then
  fail "feature workflow still uses combined requirements-and-solution record"
fi

printf 'Workflow symmetry checks passed.\n'
