# Minimal Workflow Stage Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add one normalized final-verification decision gate to `feature-dev`, `bug-fix`, and `refactor` without implementing any deferred reliability work.

**Architecture:** Add a `#### Verification Decision Gate` subsection under each workflow's existing final verification stage. Reuse the existing `extract_h4_section` test helper so contract checks prove the rule is under the correct stage, then synchronize the distribution package and release metadata.

**Tech Stack:** Markdown workflow skills, Bash, POSIX `awk`, ripgrep, Git.

---

### Task 1: Add The Failing Gate Contract

**Files:**
- Modify: `tests/workflow-symmetry.sh`

- [x] **Step 1: Add the gate assertion helper**

Add `assert_verification_decision_gate` after `assert_executing_plans_contract`. It must extract `#### Verification Decision Gate` with the existing `extract_h4_section` helper and assert:

```bash
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
```

- [x] **Step 2: Add one assertion per workflow**

Add these calls near the existing final-verification contract assertions:

```bash
assert_verification_decision_gate \
  "feature" \
  "$FEATURE_SKILL" \
  "### System Testing" \
  'required acceptance criterion without executed evidence.*`not_ready`'
assert_verification_decision_gate \
  "bug-fix" \
  "$BUG_FIX_SKILL" \
  "### Regression Verification" \
  'original bug still reproduces|required bug-fix outcome lacks executed evidence.*`not_ready`'
assert_verification_decision_gate \
  "refactor" \
  "$REFACTOR_SKILL" \
  "### Regression Verification" \
  'behavior drift|unmet required structural goal.*`not_ready`'
```

- [x] **Step 3: Run the focused test and verify RED**

Run:

```bash
bash tests/workflow-symmetry.sh
```

Expected: exit non-zero with `expected one verification decision gate` for `feature-dev`. The failure must be caused by the missing gate, not a shell syntax error.

### Task 2: Add The Minimal Symmetric Gate

**Files:**
- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`
- Test: `tests/workflow-symmetry.sh`

- [x] **Step 1: Add the feature gate**

Under `### System Testing`, add `#### Verification Decision Gate`. Define the three decision values, require missing evidence for a required acceptance criterion to be `not_ready`, allow only `ready` and `ready_with_risk` to enter Business Acceptance, and define the manifest rollback and reconfirmation sequence from the design.

Add this field to the system test report structure:

```markdown
- `Verification Decision`: exactly one of `ready`, `ready_with_risk`, or `not_ready`, determined by the Verification Decision Gate.
```

- [x] **Step 2: Add the bug-fix gate**

Under `### Regression Verification`, add the same gate semantics. Require an original bug that still reproduces or a required bug-fix outcome without executed evidence to be `not_ready`.

Add the same `Verification Decision` field to the regression test report structure.

- [x] **Step 3: Add the refactor gate**

Under `### Regression Verification`, add the same gate semantics. Require observed behavior drift or an unmet required structural goal to be `not_ready`.

Add the same `Verification Decision` field to the regression test report structure.

- [x] **Step 4: Run the focused test and verify GREEN**

Run:

```bash
bash tests/workflow-symmetry.sh
```

Expected: exit 0 with `Workflow symmetry checks passed.`

### Task 3: Complete Release Metadata And Verification

**Files:**
- Modify: `docs/backlog.md`
- Modify: `version`
- Modify: `docs/superpowers/plans/2026-07-13-minimal-workflow-stage-gate.md`
- Generated, ignored: `dist/.dev-cadence/**`

- [x] **Step 1: Complete the active backlog item**

Move the minimal verification stage gate item from `进行中` to `已完成` and change its checkbox to `- [x]`. Leave all pending tasks unchanged.

- [x] **Step 2: Increment the installed package version**

Change `version` from `0.8.2` to `0.8.3` because workflow behavior changes.

- [x] **Step 3: Mark this plan's completed steps**

Change only steps whose commands have passed from `- [ ]` to `- [x]`.

- [x] **Step 4: Build and verify the distribution package**

Run:

```bash
bash scripts/build.sh
rg --no-ignore -n "Verification Decision|ready_with_risk|not_ready" src/skills dist/.dev-cadence/skills
```

Expected: build exits 0 and matching gate rules appear in source and distribution copies for all three workflows.

- [x] **Step 5: Run repository checks**

Run:

```bash
bash -n tests/workflow-symmetry.sh
git diff --check
bash scripts/check-whitespace.sh
bash scripts/check-all.sh
```

Expected: every command exits 0; the full check reports package, workflow symmetry, skill description, install, and whitespace checks passed.

- [x] **Step 6: Review the final diff for scope**

Run:

```bash
git diff -- src/skills tests/workflow-symmetry.sh docs/backlog.md docs/superpowers/plans/2026-07-13-minimal-workflow-stage-gate.md version
```

Expected: no tested-revision identity, carry-forward evidence, feature record expansion, bug diagnosis/RED-GREEN, refactor baseline/migration, Completion, finishing, worktree, vendored skill, or README changes.
