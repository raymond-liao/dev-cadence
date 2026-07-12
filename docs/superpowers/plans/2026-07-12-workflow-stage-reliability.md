# Workflow Stage Reliability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the stage-gate and evidence-continuity gaps in `feature-dev`, `bug-fix`, and `refactor` without changing Completion, finishing, or worktree lifecycle behavior.

**Architecture:** Add one symmetric verification gate to the final verification stage of all three workflows, then add narrowly scoped record contracts for each workflow's unique risks. Contract tests extract the relevant Markdown subsection so required rules must remain under the correct stage instead of merely existing somewhere in the file.

**Tech Stack:** Markdown workflow skills, Bash, POSIX `awk`, ripgrep, Git, repository build and contract scripts.

---

### Task 1: Add The Common Verification Gate

**Files:**
- Modify: `tests/workflow-symmetry.sh`
- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`

- [ ] **Step 1: Add failing section-aware contract tests**

Add this helper after `assert_executing_plans_contract` in `tests/workflow-symmetry.sh`:

```bash
assert_verification_gate() {
  local label="$1"
  local path="$2"
  local expected_parent="$3"
  local section="$TMP_DIR/$label-verification-gate.md"
  local pattern

  extract_h4_section "$path" "#### Verification Decision Gate" "$expected_parent" >"$section" ||
    fail "missing $label verification decision gate"

  for pattern in \
    'Verification Decision.*ready.*ready_with_risk.*not_ready' \
    'Only .*ready.*ready_with_risk.*may enter .*Business Acceptance' \
    'executed check failed.*not_ready' \
    'earliest affected.*stage' \
    'set .*in_progress.*later affected stages.*pending' \
    'Tested commit' \
    'tracked working tree.*before.*after' \
    'tested commit did not change' \
    'stale.*rerun' \
    'Carry-Forward Items' \
    'stable source ID' \
    'source record' \
    'current disposition' \
    'verification evidence' \
    'residual risk'
  do
    assert_match "$label verification rule '$pattern'" "$pattern" "$section"
  done
}
```

Invoke it with the correct stage parent:

```bash
assert_verification_gate "feature" "$FEATURE_SKILL" "### System Testing"
assert_verification_gate "bug-fix" "$BUG_FIX_SKILL" "### Regression Verification"
assert_verification_gate "refactor" "$REFACTOR_SKILL" "### Regression Verification"

assert_workflows "agent-discovered stage rollback" \
  "implementation, review, or verification discovers" \
  "implementation, review, or verification discovers" \
  "implementation, review, or verification discovers"
assert_workflows "acceptance receives carry-forward items" \
  "Business Acceptance summary.*remaining carry-forward" \
  "Business Acceptance summary.*remaining carry-forward" \
  "Business Acceptance summary.*remaining carry-forward"
```

- [ ] **Step 2: Run the tests and verify RED**

Run:

```bash
bash tests/workflow-symmetry.sh
```

Expected: FAIL with `missing feature verification decision gate`.

- [ ] **Step 3: Add common internal-discovery rollback rules**

In each workflow's `Active Task Change Handling`, extend the trigger so it applies when the user requests a change **or** implementation, review, or verification discovers evidence that invalidates a confirmed stage. Require the existing earliest-affected-stage rollback, manifest status updates, record refresh, and reconfirmation for both sources of change.

- [ ] **Step 4: Add the verification gate to all three workflows**

Under `### System Testing` in `feature-dev` and `### Regression Verification` in `bug-fix` and `refactor`, add `#### Verification Decision Gate` with this normalized contract:

```markdown
- `ready`: executed evidence shows the confirmed goal is satisfied and no blocking gap remains.
- `ready_with_risk`: no executed evidence disproves the confirmed goal, but explicitly listed skipped checks, uncovered areas, or non-blocking open items remain.
- `not_ready`: an executed check failed, evidence shows a confirmed goal is unmet, required evidence is inconsistent, or a blocking gap remains.

Only `ready` and `ready_with_risk` may enter Business Acceptance. An acceptance criterion failure, an original bug that still reproduces, observed behavior drift, or an unmet required structural goal is `not_ready`, not a residual-risk shortcut.
```

For `not_ready`, require the earliest affected stage, `in_progress`/`pending` manifest rollback, affected record updates and reconfirmation, and fresh review/verification before Business Acceptance.

Require final verification to test a committed revision with no in-scope tracked changes, record `Tested commit`, tested branch, tracked working-tree state before and after, and confirm the commit did not change. If identity changes, mark the result stale and rerun.

Require a `Carry-Forward Items` table containing stable source ID, source record, current disposition, verification evidence or unverified reason, and residual risk. Every skipped implementation check, unresolved review finding, accepted review risk, and known implementation risk must appear.

- [ ] **Step 5: Carry remaining items into Business Acceptance**

In each `### Business Acceptance`, require the Business Acceptance summary to include every remaining carry-forward item from the verification report. Do not alter the three acceptance options or Completion behavior.

- [ ] **Step 6: Run the focused tests and verify GREEN**

Run:

```bash
bash tests/workflow-symmetry.sh
```

Expected: `Workflow symmetry checks passed.`

- [ ] **Step 7: Commit the common gate**

```bash
git add tests/workflow-symmetry.sh src/skills/feature-dev/SKILL.md src/skills/bug-fix/SKILL.md src/skills/refactor/SKILL.md
git commit -m "fix(flow): gate acceptance on verification evidence"
```

### Task 2: Close Feature Development Record Gaps

**Files:**
- Modify: `tests/workflow-symmetry.sh`
- Modify: `src/skills/feature-dev/SKILL.md`

- [ ] **Step 1: Add failing feature-specific contract tests**

Add `assert_feature_stage_contract` that extracts these sections:

```bash
extract_h4_section "$FEATURE_SKILL" "#### Requirements Record Contract" "### Requirements Confirmation" >"$requirements_section"
extract_h4_section "$FEATURE_SKILL" "#### Technical Solution Record Contract" "### Technical Solution" >"$solution_section"
```

Assert the requirements section contains `Confirmed Scope`, `Non-Goals`, `Acceptance Criteria`, stable acceptance-criterion IDs, `Assumptions And Open Questions`, and manifest confirmation.

Assert the solution section contains `Requirements Source`, `Recommended Approach`, `Alternatives And Tradeoffs`, `Affected Modules And Boundaries`, `Testing Strategy`, `Risks And Constraints`, and conditional `Codebase Exploration Findings`.

Assert the System Testing report requires `Technical Solution Coverage` and that material technical constraints map to evidence.

- [ ] **Step 2: Run the tests and verify RED**

Run:

```bash
bash tests/workflow-symmetry.sh
```

Expected: FAIL because `#### Requirements Record Contract` is missing.

- [ ] **Step 3: Add the durable requirements contract**

Under `### Requirements Confirmation`, add `#### Requirements Record Contract`. Require `01-requirements.md` to contain:

```text
Confirmed Scope
Non-Goals
Acceptance Criteria
Assumptions And Open Questions
```

Each acceptance criterion must have a stable ID such as `AC-1`, and the manifest must record user confirmation separately from the checkpoint commit.

- [ ] **Step 4: Add the durable technical-solution contract**

Under `### Technical Solution`, add `#### Technical Solution Record Contract`. Require `02-technical-solution.md` to contain the exact sources and sections asserted in Step 1. Preserve the existing enhanced-exploration behavior.

- [ ] **Step 5: Extend System Testing evidence**

Add `Technical Solution Coverage` to the system test report. Map material architecture, integration, security, compatibility, migration, and operational constraints to test case IDs or explicit risk states. Keep `Requirement Coverage` unchanged.

- [ ] **Step 6: Run the focused tests and verify GREEN**

```bash
bash tests/workflow-symmetry.sh
```

Expected: `Workflow symmetry checks passed.`

- [ ] **Step 7: Commit the feature rules**

```bash
git add tests/workflow-symmetry.sh src/skills/feature-dev/SKILL.md
git commit -m "fix(feature-flow): persist confirmed delivery evidence"
```

### Task 3: Close Bug Fix Diagnosis And Proof Gaps

**Files:**
- Modify: `tests/workflow-symmetry.sh`
- Modify: `src/skills/bug-fix/SKILL.md`

- [ ] **Step 1: Add failing bug-specific contract tests**

Extract `#### Diagnosis Entry Gate` under `### Problem Diagnosis` and assert:

```text
Diagnosis Conclusion
confirmed_bug
ambiguous
not_a_bug_candidate
Root Cause State
validated
hypothesis
Root Cause Evidence
Reproduction State
Repair Solution may begin only
```

Extract `#### Repair Proof Evidence` under `### Repair Implementation` and assert stable proof IDs, RED command/check, expected failure, actual failure evidence, implementation change, GREEN command/check, and actual passing evidence.

Assert root-cause invalidation returns to Problem Diagnosis and requires reconfirming Diagnosis, Solution, and Plan. Assert the regression report includes `Preserved Behavior Coverage`.

- [ ] **Step 2: Run the tests and verify RED**

```bash
bash tests/workflow-symmetry.sh
```

Expected: FAIL because `#### Diagnosis Entry Gate` is missing.

- [ ] **Step 3: Add the diagnosis entry gate**

Under `### Problem Diagnosis`, add the normalized diagnosis fields from the approved design. Permit entry to Repair Solution only for `Diagnosis Conclusion: confirmed_bug` and `Root Cause State: validated`. Keep ambiguous or insufficiently evidenced diagnoses `in_progress` or `blocked`. Record `not_a_bug_candidate` without defining its deferred terminal path.

- [ ] **Step 4: Add root-cause rollback**

Require implementation, review, or verification that disproves the root cause or repair boundary to return to Problem Diagnosis, mark affected later stages pending, and refresh and reconfirm Problem Diagnosis, Repair Solution, and Repair Plan.

- [ ] **Step 5: Add auditable RED/GREEN proof records**

Add `#### Repair Proof Evidence` before `#### Common Implementation Rules`. Require the Repair Plan and Repair Record to use stable proof IDs and record the exact RED/GREEN fields asserted in Step 1. A generic statement such as “tests passed” is not sufficient.

- [ ] **Step 6: Extend regression coverage**

Add `Preserved Behavior Coverage` to `05-regression-test-report.md`, mapping each behavior that the Repair Solution requires to remain unchanged to executed test IDs and a status of `covered`, `skipped`, `not covered`, or `accepted risk`.

- [ ] **Step 7: Run the focused tests and verify GREEN**

```bash
bash tests/workflow-symmetry.sh
```

Expected: `Workflow symmetry checks passed.`

- [ ] **Step 8: Commit the bug-fix rules**

```bash
git add tests/workflow-symmetry.sh src/skills/bug-fix/SKILL.md
git commit -m "fix(bug-flow): require validated diagnosis evidence"
```

### Task 4: Anchor Refactor Baselines And Migrations

**Files:**
- Modify: `tests/workflow-symmetry.sh`
- Modify: `src/skills/refactor/SKILL.md`

- [ ] **Step 1: Add failing refactor-specific contract tests**

Extract `#### Baseline Identity` and `#### Contract-Preserving Migration` under `### Refactor Solution`.

Assert baseline identity includes baseline commit SHA, baseline tree SHA, clean tracked working tree, stable baseline IDs, expected observable result, evidence command/test, sensitivity evidence, and the rule that current behavior cannot redefine the pre-refactor expectation.

Assert migration evidence includes caller/consumer inventory, compatibility strategy, migrated and remaining callers, legacy references, adapter decision, and old-path deletion evidence.

Assert the method catalog no longer contains `narrow public API`, contains `narrow internal interface`, and requires compatibility preservation for external data shapes.

Assert existing tests may protect a baseline only when their relevant assertions detect the protected behavior; otherwise a sensitivity check or stronger characterization evidence is required.

- [ ] **Step 2: Run the tests and verify RED**

```bash
bash tests/workflow-symmetry.sh
```

Expected: FAIL because `#### Baseline Identity` is missing.

- [ ] **Step 3: Remove the public-contract contradiction**

In `Common Refactoring Methods`, replace `narrow public API` with `narrow internal interface`. State that public APIs and external data shapes must remain compatible through adapters or move to feature/bug-fix work after user confirmation.

- [ ] **Step 4: Add baseline identity and adequacy rules**

Under `### Refactor Solution`, add `#### Baseline Identity`. Require the exact baseline fields asserted in Step 1 to be captured immediately before the first structural edit, after baseline tests are established. Require later baseline additions to be verified against the captured baseline revision or recorded as unverified risk.

Clarify that an existing test is adequate only when its relevant assertion detects the mapped behavior; otherwise run a reversible sensitivity check or add stronger characterization evidence.

- [ ] **Step 5: Add migration evidence**

Add `#### Contract-Preserving Migration` under `### Refactor Solution`. Require the solution to define the caller inventory and compatibility strategy; the plan to enumerate migration and deletion steps; the refactor record to track migrated/remaining callers and legacy references; and the regression report to record adapter retention/deletion and old-path deletion evidence.

- [ ] **Step 6: Run the focused tests and verify GREEN**

```bash
bash tests/workflow-symmetry.sh
```

Expected: `Workflow symmetry checks passed.`

- [ ] **Step 7: Commit the refactor rules**

```bash
git add tests/workflow-symmetry.sh src/skills/refactor/SKILL.md
git commit -m "fix(refactor-flow): anchor behavior baseline evidence"
```

### Task 5: Update Backlog, Version, Distribution, And Verification

**Files:**
- Modify: `docs/workflow-reliability-backlog.md`
- Modify: `version`
- Modify: `docs/superpowers/plans/2026-07-12-workflow-stage-reliability.md`
- Generated, ignored: `dist/.dev-cadence/**`

- [ ] **Step 1: Update the backlog item**

Replace the fifth item with:

```markdown
- [x] 补齐各 Workflow 的专属阶段可靠性规则：完善 feature-dev、bug-fix 和 refactor 的阶段门禁、证据传递与返工回环；终态规则留待 Completion 状态机任务。
```

Leave the second, third, and fourth items unchecked.

- [ ] **Step 2: Increment the version**

Change `version` from:

```text
0.8.1
```

to:

```text
0.8.2
```

- [ ] **Step 3: Mark completed plan steps**

Update this plan's completed steps from `- [ ]` to `- [x]`. Do not mark verification or review steps complete before their commands have passed.

- [ ] **Step 4: Build the distribution package**

```bash
bash scripts/build.sh
```

Expected: exit 0 and `dist/.dev-cadence` synchronized from `src`.

- [ ] **Step 5: Verify source/distribution synchronization**

```bash
rg --no-ignore -n "Verification Decision|Diagnosis Conclusion|Baseline commit SHA" src/skills dist/.dev-cadence/skills
```

Expected: matching rules in both source and distribution skill copies.

- [ ] **Step 6: Run syntax and whitespace checks**

```bash
bash -n tests/workflow-symmetry.sh
git diff --check
bash scripts/check-whitespace.sh
```

Expected: all commands exit 0.

- [ ] **Step 7: Run the complete repository checks**

```bash
bash scripts/check-all.sh
```

Expected:

```text
Package contract checks passed.
Workflow symmetry checks passed.
Skill description contract checks passed.
Install contract checks passed.
Whitespace contract checks passed.
```

- [ ] **Step 8: Request an independent code review**

Review the full range from `5d5b675` to the final implementation commit. Require findings first, ordered by severity, and confirm that deferred Completion, finishing, and worktree behavior were not changed.

- [ ] **Step 9: Fix validated findings and rerun all checks**

Apply only validated findings in scope. Repeat Steps 4-7 after any change. If rule or test files changed, commit them separately:

```bash
git add src/skills/feature-dev/SKILL.md src/skills/bug-fix/SKILL.md src/skills/refactor/SKILL.md tests/workflow-symmetry.sh
git commit -m "fix(flow): address stage reliability review"
```

- [ ] **Step 10: Commit release metadata**

```bash
git add docs/workflow-reliability-backlog.md docs/superpowers/plans/2026-07-12-workflow-stage-reliability.md version
git commit -m "chore(release): prepare workflow reliability 0.8.2"
```
