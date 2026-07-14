#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FEATURE_SKILL="$ROOT_DIR/src/skills/feature-dev/SKILL.md"
BUG_FIX_SKILL="$ROOT_DIR/src/skills/bug-fix/SKILL.md"
REFACTOR_SKILL="$ROOT_DIR/src/skills/refactor/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"
AGENTS_SNIPPET="$ROOT_DIR/src/AGENTS-snippet.md"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

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

assert_literal() {
  local label="$1"
  local literal="$2"
  local path="$3"

  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null || fail "missing $label in ${path#"$ROOT_DIR/"}"
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

assert_workflow_delivery_contract() {
  local label="$1"
  local path="$2"
  local workflow_dir="$3"
  local slug_placeholder="$4"
  local stage_sequence="$5"
  local task_dir="build/dev-cadence/$workflow_dir/<$slug_placeholder>"
  local record

  shift 5

  assert_literal "$label stage sequence" "$stage_sequence" "$path"
  assert_literal "$label task directory" "$task_dir/" "$path"
  assert_literal "$label manifest path" "$task_dir/manifest.md" "$path"
  assert_literal "$label SDD artifact path" "$task_dir/sdd/" "$path"
  assert_match "$label manifest stage table fields" 'stage table with stage name, status, artifact path, user confirmation, checkpoint commit, and notes' "$path"

  for record in "$@"; do
    assert_literal "$label stage record $record" "$task_dir/$record" "$path"
  done
}

assert_workflow_evidence_contract() {
  local label="$1"
  local path="$2"
  local verification_source="$3"
  local primary_coverage="$4"
  local secondary_coverage="$5"
  local acceptance_source="$6"
  local verification_report_source="$7"

  assert_literal "$label verification source field" "$verification_source" "$path"
  assert_literal "$label primary coverage field" "$primary_coverage" "$path"
  if [[ -n "$secondary_coverage" ]]; then
    assert_literal "$label secondary coverage field" "$secondary_coverage" "$path"
  fi
  assert_literal "$label acceptance source field" "$acceptance_source" "$path"
  assert_literal "$label acceptance verification source field" "$verification_report_source" "$path"
  assert_literal "$label acceptance decision field" '`User Decision`' "$path"
  assert_literal "$label accepted residual risks field" '`Accepted Residual Risks`' "$path"
}

assert_consolidated_brainstorming_confirmation() {
  local label="$1"
  local path="$2"
  local solution_stage="$3"
  local section="$TMP_DIR/$label-consolidated-brainstorming-confirmation.md"
  local pattern

  awk '
    $0 == "## Consolidated Brainstorming Confirmation" {
      count++
      capturing = (count == 1)
    }
    capturing && $0 != "## Consolidated Brainstorming Confirmation" && /^#{1,2} / {
      capturing = 0
    }
    capturing { print }
    END { if (count != 1) exit 1 }
  ' "$path" >"$section" || fail "expected one consolidated brainstorming confirmation section in ${path#"$ROOT_DIR/"}"

  for pattern in \
    '## Consolidated Brainstorming Confirmation' \
    "Requirements Confirmation.*$solution_stage" \
    'clarifying question.*decision input.*not.*stage confirmation' \
    'approach selection.*decision input.*not.*stage confirmation' \
    'Do not request approval after each subsection' \
    'complete stage output.*single consolidated review' \
    'one final confirmation interaction.*completed version' \
    'materially changes.*remaining.*design' \
    'written stage record review.*stage confirmation.*same interaction' \
    'overrides.*vendored brainstorming.*approval after each design subsection'
  do
    assert_match "$label consolidated confirmation rule '$pattern'" "$pattern" "$section"
  done

  awk '
    /Write or update the required stage record/ { record = NR }
    /Update the manifest.*create or record the stage checkpoint/ { checkpoint = NR }
    /complete stage output.*single consolidated review/ { review = NR }
    /one final confirmation interaction/ { confirmation = NR }
    /record the user confirmation separately in the manifest/ { manifest_confirmation = NR }
    END {
      exit !(record < checkpoint && checkpoint < review && review < confirmation &&
             confirmation < manifest_confirmation)
    }
  ' "$section" || fail "invalid consolidated confirmation order in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"

  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

extract_h4_section() {
  local path="$1"
  local heading="$2"
  local expected_parent="$3"

  awk -v heading="$heading" -v expected_parent="$expected_parent" '
    function fence_marker(line, text) {
      text = line
      sub(/^[[:space:]]*/, "", text)
      if (substr(text, 1, 3) == "```") return "`"
      if (substr(text, 1, 3) == "~~~") return "~"
      return ""
    }
    function fence_size(line, marker, text, size) {
      text = line
      sub(/^[[:space:]]*/, "", text)
      while (substr(text, size + 1, 1) == marker) size++
      return size
    }
    function closes_fence(line, marker, minimum_size, text, size) {
      text = line
      sub(/^[[:space:]]*/, "", text)
      while (substr(text, size + 1, 1) == marker) size++
      return size >= minimum_size && substr(text, size + 1) ~ /^[[:space:]]*$/
    }
    function atx_heading(line, text, indent) {
      text = line
      while (indent < 3 && substr(text, 1, 1) == " ") {
        text = substr(text, 2)
        indent++
      }
      if (substr(text, 1, 1) == " " || substr(text, 1, 1) == "\t") return ""
      return text
    }
    {
      marker = fence_marker($0)
      if (in_fence) {
        if (capturing) print
        if (marker == in_fence && closes_fence($0, in_fence, opening_fence_size)) {
          in_fence = ""
          opening_fence_size = 0
        }
        next
      }
      if (marker) {
        if (capturing) print
        in_fence = marker
        opening_fence_size = fence_size($0, marker)
        next
      }
      markdown_line = atx_heading($0)
    }
    markdown_line ~ /^#{1,2} / { parent = "" }
    markdown_line ~ /^### / { parent = markdown_line }
    markdown_line == heading {
      count++
      if (count == 1) {
        parent_ok = (parent == expected_parent)
        capturing = parent_ok
        if (capturing) print $0
      } else {
        capturing = 0
      }
      next
    }
    capturing && markdown_line ~ /^#{1,4} / { capturing = 0 }
    capturing { print }
    END { if (count != 1 || !parent_ok) exit 1 }
  ' "$path"
}

assert_h4_section_parser_rejects_stale_parent() {
  local fixture="$TMP_DIR/h4-stale-parent.md"
  local heading="#### Executing-Plans Pre-Commit Review"

  cat >"$fixture" <<'EOF'
### Development Implementation

Implementation details.

## Another Stage

#### Executing-Plans Pre-Commit Review

This heading is not part of Development Implementation.
EOF

  if extract_h4_section "$fixture" "$heading" "### Development Implementation" >/dev/null 2>&1; then
    fail "H4 section parser accepted a stale H3 parent across an H2 boundary"
  fi
}

assert_h4_section_parser_rejects_indented_parent_boundary() {
  local fixture="$TMP_DIR/h4-indented-parent-boundary.md"
  local heading="#### Executing-Plans Pre-Commit Review"

  cat >"$fixture" <<'EOF'
### Development Implementation

  ## Another Stage

#### Executing-Plans Pre-Commit Review
EOF

  if extract_h4_section "$fixture" "$heading" "### Development Implementation" >/dev/null 2>&1; then
    fail "H4 section parser ignored an indented H2 boundary"
  fi
}

assert_h4_section_parser_rejects_duplicate_heading() {
  local fixture="$TMP_DIR/h4-duplicate-heading.md"
  local heading="#### Executing-Plans Pre-Commit Review"

  cat >"$fixture" <<'EOF'
### Development Implementation

#### Executing-Plans Pre-Commit Review

First section.

#### Common Implementation Rules

Common rules.

#### Executing-Plans Pre-Commit Review

Duplicate section.
EOF

  if extract_h4_section "$fixture" "$heading" "### Development Implementation" >/dev/null 2>&1; then
    fail "H4 section parser accepted duplicate headings"
  fi
}

assert_h4_section_parser_ignores_fenced_headings() {
  local fixture="$TMP_DIR/h4-fenced-heading.md"
  local expected="$TMP_DIR/h4-fenced-heading-expected.md"
  local actual="$TMP_DIR/h4-fenced-heading-actual.md"
  local heading="#### Executing-Plans Pre-Commit Review"

  cat >"$fixture" <<'EOF'
### Development Implementation

~~~text
#### Executing-Plans Pre-Commit Review
### This is code, not a parent heading
~~~

#### Executing-Plans Pre-Commit Review

Review rules.

##### Nested Details

Nested content remains in the section.

#### Common Implementation Rules

Common rules are outside the section.
EOF

  cat >"$expected" <<'EOF'
#### Executing-Plans Pre-Commit Review

Review rules.

##### Nested Details

Nested content remains in the section.

EOF

  extract_h4_section "$fixture" "$heading" "### Development Implementation" >"$actual" ||
    fail "H4 section parser counted a heading inside a fenced code block"
  cmp -s "$expected" "$actual" || fail "H4 section parser extracted the wrong Markdown section"
}

assert_h4_section_parser_respects_fence_length() {
  local fixture="$TMP_DIR/h4-long-fence.md"
  local expected="$TMP_DIR/h4-long-fence-expected.md"
  local actual="$TMP_DIR/h4-long-fence-actual.md"
  local heading="#### Executing-Plans Pre-Commit Review"

  cat >"$fixture" <<'EOF'
### Development Implementation

````text
```
#### Executing-Plans Pre-Commit Review
### This is still code
````

#### Executing-Plans Pre-Commit Review

Actual review rules.

#### Common Implementation Rules
EOF

  cat >"$expected" <<'EOF'
#### Executing-Plans Pre-Commit Review

Actual review rules.

EOF

  extract_h4_section "$fixture" "$heading" "### Development Implementation" >"$actual" ||
    fail "H4 section parser mishandled a longer fenced code block"
  cmp -s "$expected" "$actual" || fail "H4 section parser closed a fenced code block too early"
}

assert_executing_plans_contract() {
  local label="$1"
  local path="$2"
  local expected_parent="$3"
  local heading="#### Executing-Plans Pre-Commit Review"
  local section="$TMP_DIR/$label-executing-plans.md"
  local sdd_section="$TMP_DIR/$label-sdd.md"
  local common_section="$TMP_DIR/$label-common-implementation.md"
  local pattern

  extract_h4_section "$path" "$heading" "$expected_parent" >"$section" ||
    fail "expected one executing-plans section under $expected_parent in ${path#"$ROOT_DIR/"}"

  for pattern in \
    'applies only when .*executing-plans.* is selected' \
    'does not apply to .*subagent-driven-development' \
    'plan-task-<n>' \
    'progress-<n>-<k>' \
    'final-review-fix-<k>' \
    'recovery-fix-<review-id>-<k>' \
    'reviewed-pending-commit' \
    'recovery-required' \
    'EXPECTED_PARENT_SHA=.*git rev-parse HEAD' \
    'REVIEWED_TREE_SHA=.*git write-tree' \
    'COMMIT_PARENT_SHA=.*COMMIT_SHA.*\^' \
    'COMMITTED_TREE_SHA=.*COMMIT_SHA.*\{tree\}' \
    'Immediately before committing, repeat both identity checks' \
    'COMMIT_PARENT_SHA.*equals.*EXPECTED_PARENT_SHA' \
    'COMMITTED_TREE_SHA.*equals.*REVIEWED_TREE_SHA' \
    'git rev-list --reverse --first-parent' \
    'classify each first-parent commit' \
    'recorded stage checkpoint' \
    'does not enter the implementation ledger' \
    'unclassified commit' \
    'first try to reconcile.*pending entry' \
    'Expected parent.*actual immediate parent' \
    'Committed parent' \
    'Identity: exact.*Expected parent.*actual immediate parent' \
    'Identity: retrospective.*Committed parent' \
    'current plan task must remain .*in_progress' \
    'final plan-task entry is .*verified' \
    'Identity: retrospective' \
    'Expected parent equals .*HEAD' \
    'set .*COMMIT_SHA.*direct first-parent child' \
    'recompute only .*COMMIT_PARENT_SHA.*COMMITTED_TREE_SHA' \
    'do not reset .*COMMIT_SHA.*HEAD' \
    'If the index differs, record why the pending snapshot was invalidated' \
    'no blocking finding remains' \
    'not validated.*remain visible' \
    'accepted risk' \
    'IMPLEMENTATION_BASE_SHA\.\.FINAL_IMPLEMENTATION_SHA' \
    'exclude changes introduced only by recorded stage checkpoints' \
    'latest verified implementation commit' \
    'After any verified implementation commit created during final-review remediation' \
    'final-review-fix.*recovery-fix' \
    'validated finding that requires code changes' \
    'next unused .*<k>' \
    'one unit covers one commit' \
    'Source finding IDs and Affected tasks' \
    'Reopen an affected task only when' \
    'If the fix expands confirmed scope' \
    'Stage checkpoint commits remain governed by the Git Checkpoints rules' \
    'Do not mix implementation changes into a stage checkpoint commit'
  do
    assert_match "$label executing-plans rule '$pattern'" "$pattern" "$section"
  done

  assert_not_match "$label SDD task directory inside executing-plans" 'DEV_CADENCE_TASK_DIR' "$section"
  extract_h4_section "$path" "#### Subagent-Driven Development" "$expected_parent" >"$sdd_section" || fail "missing $label SDD section"
  extract_h4_section "$path" "#### Common Implementation Rules" "$expected_parent" >"$common_section" || fail "missing $label common implementation section"
  assert_match "$label SDD task directory" 'DEV_CADENCE_TASK_DIR' "$sdd_section"
  assert_not_match "$label common implementation record inside SDD" 'At the end of this stage' "$sdd_section"
  assert_not_match "$label common review evidence inside SDD" 'Code Review Evidence' "$sdd_section"
  assert_match "$label common implementation record" 'At the end of this stage' "$common_section"
  assert_match "$label common review evidence" 'Code Review Evidence' "$common_section"
  assert_match "$label common rules apply to both execution paths" 'apply to both .*executing-plans.*subagent-driven-development' "$common_section"
  awk '
    /EXPECTED_PARENT_SHA=\$\(git rev-parse HEAD\)/ && !capture { capture = NR }
    /^[[:space:]]*git diff --cached$/ { review = NR }
    /test .*git rev-parse HEAD.*EXPECTED_PARENT_SHA/ { precommit_parent = NR }
    /test .*git write-tree.*REVIEWED_TREE_SHA/ { precommit_tree = NR }
    /Persist the complete ledger entry/ { pending = NR }
    /Immediately before committing, repeat both identity checks/ { immediate_check = NR }
    /Create the implementation commit/ { commit = NR }
    /COMMIT_SHA=\$\(git rev-parse HEAD\)/ { identity = NR }
    /COMMIT_PARENT_SHA.*equals.*EXPECTED_PARENT_SHA/ { committed_parent = NR }
    /COMMITTED_TREE_SHA.*equals.*REVIEWED_TREE_SHA/ { committed_tree = NR }
    END {
      exit !(capture < review && review < precommit_parent && precommit_parent <= precommit_tree &&
             precommit_tree < pending && pending < immediate_check && immediate_check < commit &&
             commit < identity &&
             identity < committed_parent && committed_parent <= committed_tree)
    }
  ' "$section" || fail "invalid executing-plans review order in ${path#"$ROOT_DIR/"}"
}

assert_verification_decision_gate() {
  local label="$1"
  local path="$2"
  local expected_parent="$3"
  local required_failure_pattern="$4"
  local section="$TMP_DIR/$label-verification-decision-gate.md"
  local pattern

  extract_h4_section "$path" "#### Verification Decision Gate" "$expected_parent" >"$section" ||
    fail "expected one verification decision gate under $expected_parent in ${path#"$ROOT_DIR/"}"

  for pattern in \
    'Verification Decision' \
    '`ready`' \
    '`ready_with_risk`' \
    '`not_ready`' \
    'Only `ready` and `ready_with_risk` may enter Business Acceptance' \
    "$required_failure_pattern" \
    'blocking evidence.*earliest affected stage' \
    'earliest affected stage.*`in_progress`' \
    'later affected stages.*`pending`' \
    'superseded' \
    'update and reconfirm' \
    'repeat implementation review and verification'
  do
    assert_match "$label verification decision gate '$pattern'" "$pattern" "$section"
  done
}

assert_h4_section_parser_rejects_stale_parent
assert_h4_section_parser_rejects_indented_parent_boundary
assert_h4_section_parser_rejects_duplicate_heading
assert_h4_section_parser_ignores_fenced_headings
assert_h4_section_parser_respects_fence_length

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
assert_workflows "active run commit red flags" "### ⚠️ Commit Red Flags" "### ⚠️ Commit Red Flags" "### ⚠️ Commit Red Flags"
assert_workflows "commit completion rationalization" "User asked to commit, so the workflow is complete" "User asked to commit, so the workflow is complete" "User asked to commit, so the workflow is complete"
assert_workflows "no push rule" "Do not push unless the user explicitly asks" "Do not push unless the user explicitly asks" "Do not push unless the user explicitly asks"
assert_workflows "documentation test exemption" "Root-level .*\\*\\.md.*docs/.*do not require new or updated automated tests" "Root-level .*\\*\\.md.*docs/.*do not require new or updated automated tests" "Root-level .*\\*\\.md.*docs/.*do not require new or updated automated tests"
assert_workflows "no documentation-only test churn" "Do not add or modify automated tests solely because these documentation files changed" "Do not add or modify automated tests solely because these documentation files changed" "Do not add or modify automated tests solely because these documentation files changed"
assert_workflows "executable behavior remains tested" "If the same task changes executable behavior, test that executable behavior" "If the same task changes executable behavior, test that executable behavior" "If the same task changes executable behavior, test that executable behavior"
assert_match "target repository documentation test exemption" "Root-level .*\\*\\.md.*docs/.*do not require new or updated automated tests" "$AGENTS_SNIPPET"

assert_workflows "manifest creation rule" "Create and maintain a run manifest" "Create and maintain a run manifest" "Create and maintain a run manifest"
assert_workflows "manifest status values" "Use stage status values" "Use stage status values" "Use stage status values"
assert_workflows "terminal checkpoint rule" "must not contain .*pending.* checkpoint commit values" "must not contain .*pending.* checkpoint commit values" "must not contain .*pending.* checkpoint commit values"
assert_workflows "no tracked changes checkpoint rule" "skipped: no tracked changes" "skipped: no tracked changes" "skipped: no tracked changes"
assert_workflows "portable path rule" "do not persist local absolute paths" "do not persist local absolute paths" "do not persist local absolute paths"
assert_workflows "manifest update cadence" "whenever a stage record is created or updated" "whenever a stage record is created or updated" "whenever a stage record is created or updated"

assert_consolidated_brainstorming_confirmation "feature" "$FEATURE_SKILL" "Technical Solution"
assert_consolidated_brainstorming_confirmation "refactor" "$REFACTOR_SKILL" "Refactor Solution"
assert_not_match "bug-fix brainstorming confirmation override" "## Consolidated Brainstorming Confirmation" "$BUG_FIX_SKILL"

assert_workflow_delivery_contract \
  "feature" \
  "$FEATURE_SKILL" \
  "feature-dev" \
  "feature-slug" \
  "Requirements Confirmation -> Technical Solution -> Implementation Plan -> Development Implementation -> System Testing -> Business Acceptance" \
  "01-requirements.md" \
  "02-technical-solution.md" \
  "03-implementation-plan.md" \
  "04-implementation-record.md" \
  "04-code-review-report.md" \
  "05-system-test-report.md" \
  "06-business-acceptance-record.md"
assert_workflow_delivery_contract \
  "bug-fix" \
  "$BUG_FIX_SKILL" \
  "bug-fix" \
  "bug-slug" \
  "Problem Diagnosis -> Repair Solution -> Repair Plan -> Repair Implementation -> Regression Verification -> Business Acceptance" \
  "01-problem-diagnosis-record.md" \
  "02-repair-solution.md" \
  "03-repair-plan.md" \
  "04-repair-record.md" \
  "04-code-review-report.md" \
  "05-regression-test-report.md" \
  "06-business-acceptance-record.md"
assert_workflow_delivery_contract \
  "refactor" \
  "$REFACTOR_SKILL" \
  "refactor" \
  "refactor-slug" \
  "Requirements Confirmation -> Refactor Solution -> Refactor Plan -> Refactor Implementation -> Regression Verification -> Business Acceptance" \
  "01-requirements.md" \
  "02-refactor-solution.md" \
  "03-refactor-plan.md" \
  "04-refactor-record.md" \
  "04-code-review-report.md" \
  "05-regression-test-report.md" \
  "06-business-acceptance-record.md"

assert_workflows "active task change handling" "## Active Task Change Handling" "## Active Task Change Handling" "## Active Task Change Handling"
assert_workflows "current run reuse" "current workflow run" "current workflow run" "current workflow run"
assert_workflows "existing records update" "update the existing stage records and manifest" "update the existing stage records and manifest" "update the existing stage records and manifest"
assert_workflows "affected stage rollback" "return to the earliest affected stage" "return to the earliest affected stage" "return to the earliest affected stage"
assert_workflows "out-of-scope branch decision" "expand the current feature or start a separate task" "expand the current bug fix or start a separate task" "split the request into a separate task"
assert_workflows "active task red flags" "### ⚠️ Active Task Red Flags" "### ⚠️ Active Task Red Flags" "### ⚠️ Active Task Red Flags"
assert_workflows "new document rationalization" "start a new requirements document" "start a new diagnosis document" "start a new refactor document"

assert_workflows "plan overview requirement" "Task Overview" "Task Overview" "Task Overview"
assert_workflows "plan overview table" "\\| Task \\| Goal \\| Files \\| Verification \\|" "\\| Task \\| Goal \\| Files \\| Verification \\|" "\\| Task \\| Goal \\| Files \\| Verification \\|"
assert_workflows "plan confirmation gate" "Ask the user to confirm the plan before implementation starts" "Ask the user to confirm the plan before implementation starts" "Ask the user to confirm the plan before implementation starts"
assert_workflows "pre-implementation freshness gate" "Pre-Implementation Design Freshness Gate" "Pre-Implementation Design Freshness Gate" "Pre-Implementation Design Freshness Gate"
assert_workflows "freshness identity inputs" "work item card version.*current code state" "work item card version.*current code state" "work item card version.*current code state"
assert_workflows "freshness authoritative sources" "product design.*architecture.*Decision.*dependenc" "product design.*architecture.*Decision.*dependenc" "product design.*architecture.*Decision.*dependenc"
assert_workflows "freshness evidence recording" "Record the input identities, conclusion, and evidence summary" "Record the input identities, conclusion, and evidence summary" "Record the input identities, conclusion, and evidence summary"
assert_workflows "freshness requirements rollback" "requirements.*acceptance criteria changed.*earliest affected" "diagnosis.*expected behavior.*earliest affected" "requirements.*behavior baseline.*earliest affected"
assert_workflows "freshness solution rollback" "architecture.*data.*interface.*security.*Technical Solution" "architecture.*data.*interface.*security.*Repair Solution" "architecture.*data.*interface.*security.*Refactor Solution"
assert_workflows "freshness plan rollback" "task split.*file list.*order.*verification steps.*Implementation Plan" "task split.*file list.*order.*verification steps.*Repair Plan" "task split.*file list.*order.*verification steps.*Refactor Plan"
assert_workflows "freshness superseded evidence" "mark.*later.*confirmation.*verification.*superseded" "mark.*later.*confirmation.*verification.*superseded" "mark.*later.*confirmation.*verification.*superseded"
assert_workflows "freshness unrelated changes" "Unrelated.*formatting.*do not invalidate" "Unrelated.*formatting.*do not invalidate" "Unrelated.*formatting.*do not invalidate"

assert_workflows "failure routing section" "Failure Classification And Stage Routing" "Failure Classification And Stage Routing" "Failure Classification And Stage Routing"
assert_workflows "canonical failure classifications" 'implementation_bug.*test_bug.*environment_issue.*unclear_requirement.*design_conflict.*architecture_conflict.*missing_dependency' 'implementation_bug.*test_bug.*environment_issue.*unclear_requirement.*design_conflict.*architecture_conflict.*missing_dependency' 'implementation_bug.*test_bug.*environment_issue.*unclear_requirement.*design_conflict.*architecture_conflict.*missing_dependency'
assert_workflows "stable failure identity" "stable failure ID" "stable failure ID" "stable failure ID"
assert_workflows "failure record fields" 'evidence.*classification rationale.*remediation round.*return target.*result' 'evidence.*classification rationale.*remediation round.*return target.*result' 'evidence.*classification rationale.*remediation round.*return target.*result'
assert_workflows "implementation bug routing" 'implementation_bug.*Development Implementation' 'implementation_bug.*Repair Implementation' 'implementation_bug.*Refactor Implementation'
assert_workflows "test bug routing" 'test_bug.*test asset owner.*Development Implementation' 'test_bug.*test asset owner.*Repair Implementation' 'test_bug.*test asset owner.*Refactor Implementation'
assert_workflows "effective tests cannot be weakened" 'Do not delete, skip, or weaken an effective test' 'Do not delete, skip, or weaken an effective test' 'Do not delete, skip, or weaken an effective test'
assert_workflows "unclear requirement routing" 'unclear_requirement.*Requirements Confirmation' 'unclear_requirement.*Problem Diagnosis' 'unclear_requirement.*Requirements Confirmation'
assert_workflows "design conflict routing" 'design_conflict.*Technical Solution' 'design_conflict.*Repair Solution' 'design_conflict.*Refactor Solution'
assert_workflows "architecture conflict reassessment" 'architecture_conflict.*Architecture.*Decision' 'architecture_conflict.*Architecture.*Decision' 'architecture_conflict.*Architecture.*Decision'
assert_workflows "environment issue blocking" 'environment_issue.*current business stage.*`blocked`.*overall status.*`in_progress`' 'environment_issue.*current business stage.*`blocked`.*overall status.*`in_progress`' 'environment_issue.*current business stage.*`blocked`.*overall status.*`in_progress`'
assert_workflows "missing dependency routing" 'missing_dependency.*requirement dependency.*Requirements Confirmation.*solution dependency.*Technical Solution.*execution dependency.*Implementation Plan or Development Implementation.*block the run.*unblock conditions' 'missing_dependency.*requirement dependency.*Problem Diagnosis.*solution dependency.*Repair Solution.*execution dependency.*Repair Plan or Repair Implementation.*block the run.*unblock conditions' 'missing_dependency.*requirement dependency.*Requirements Confirmation.*solution dependency.*Refactor Solution.*execution dependency.*Refactor Plan or Refactor Implementation.*block the run.*unblock conditions'
assert_workflows "retry evidence gate" 'new evidence, a corrective action, or an environment change' 'new evidence, a corrective action, or an environment change' 'new evidence, a corrective action, or an environment change'
assert_workflows "failure rerun result" 'closed.*reclassified.*blocked' 'closed.*reclassified.*blocked' 'closed.*reclassified.*blocked'
assert_workflows "blocking review finding linkage" 'validated blocking.*review finding.*source finding ID' 'validated blocking.*review finding.*source finding ID' 'validated blocking.*review finding.*source finding ID'
assert_workflows "failure rollback state" 'earliest affected stage.*`in_progress`.*later affected stages.*`pending`.*`superseded`' 'earliest affected stage.*`in_progress`.*later affected stages.*`pending`.*`superseded`' 'earliest affected stage.*`in_progress`.*later affected stages.*`pending`.*`superseded`'
assert_workflows "failure record ownership" 'complete failure record.*observed the failure.*manifest.*routing or blocking summary' 'complete failure record.*observed the failure.*manifest.*routing or blocking summary' 'complete failure record.*observed the failure.*manifest.*routing or blocking summary'
assert_workflows "failure results are not work item status" 'failure lifecycle results.*must not become Backlog or work-item statuses' 'failure lifecycle results.*must not become Backlog or work-item statuses' 'failure lifecycle results.*must not become Backlog or work-item statuses'
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
assert_executing_plans_contract "feature" "$FEATURE_SKILL" "### Development Implementation"
assert_executing_plans_contract "bug-fix" "$BUG_FIX_SKILL" "### Repair Implementation"
assert_executing_plans_contract "refactor" "$REFACTOR_SKILL" "### Refactor Implementation"

assert_workflows "verification freshness rule" "Do not claim the system is ready without fresh verification evidence" "Do not claim the bug is fixed or regression-free without fresh verification evidence" "Do not claim the refactor is complete, safe, or regression-free without fresh verification evidence"
assert_verification_decision_gate \
  "feature" \
  "$FEATURE_SKILL" \
  "### System Testing" \
  'required acceptance criterion without executed evidence.*`not_ready`'
assert_verification_decision_gate \
  "bug-fix" \
  "$BUG_FIX_SKILL" \
  "### Regression Verification" \
  '(original bug still reproduces|required bug-fix outcome lacks executed evidence).*`not_ready`'
assert_verification_decision_gate \
  "refactor" \
  "$REFACTOR_SKILL" \
  "### Regression Verification" \
  '(behavior drift|unmet required structural goal).*`not_ready`'
assert_workflows "test cases table contract" "Test Cases.*ID.*Scenario.*Type.*Execution.*Result.*Evidence" "Test Cases.*ID.*Scenario.*Type.*Execution.*Result.*Evidence" "Test Cases.*ID.*Scenario.*Type.*Execution.*Result.*Evidence"
assert_workflows "coverage honesty rule" "Coverage must be honest" "Coverage must be honest" "Coverage must be honest"
assert_workflow_evidence_contract \
  "feature" \
  "$FEATURE_SKILL" \
  '`Requirement, Technical Solution, And Implementation Sources`' \
  '`Requirement Coverage`' \
  "" \
  '`Accepted Requirement And Solution Sources`' \
  '`System Test Report Source`'
assert_workflow_evidence_contract \
  "bug-fix" \
  "$BUG_FIX_SKILL" \
  '`Problem And Repair Sources`' \
  '`Bug Fix Coverage`' \
  '`Impact Scope Coverage`' \
  '`Accepted Problem Source`' \
  '`Regression Test Report Source`'
assert_workflow_evidence_contract \
  "refactor" \
  "$REFACTOR_SKILL" \
  '`Refactor Sources`' \
  '`Behavior Baseline Coverage`' \
  '`Structural Goal Coverage`' \
  '`Accepted Refactor Sources`' \
  '`Regression Test Report Source`'

assert_workflows "business acceptance numbered options" "fixed numbered options" "fixed numbered options" "fixed numbered options"
assert_workflows "business acceptance feedback table" "### ❓ Ambiguous Acceptance Feedback" "### ❓ Ambiguous Acceptance Feedback" "### ❓ Ambiguous Acceptance Feedback"
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

assert_match "refactor principles" "## Refactoring Principles" "$REFACTOR_SKILL"
assert_match "refactor method catalog" "## Common Refactoring Methods" "$REFACTOR_SKILL"
assert_not_match "refactor public API narrowing" "narrow public API" "$REFACTOR_SKILL"
assert_match "refactor internal interface narrowing" "narrow internal interface" "$REFACTOR_SKILL"
assert_match "refactor external contract compatibility" "Public APIs and external data shapes must remain compatible" "$REFACTOR_SKILL"
assert_match "refactor baseline requirement" "Behavior Baseline" "$REFACTOR_SKILL"
assert_match "refactor no feature mixing" "Do not mix new features, unrelated bug fixes, or stylistic preferences into refactoring work" "$REFACTOR_SKILL"
assert_match "refactor tests-after red flag" "Code first, tests later" "$REFACTOR_SKILL"
assert_match "refactor baseline verification" "compare results against the Behavior Baseline" "$REFACTOR_SKILL"
assert_match "refactor covered baseline green loop" "When the Behavior Baseline already covers the protected behavior" "$REFACTOR_SKILL"
assert_match "refactor no invented red" "Do not invent a failing test" "$REFACTOR_SKILL"
assert_match "refactor characterization sensitivity check" "reversible test-sensitivity check" "$REFACTOR_SKILL"
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
