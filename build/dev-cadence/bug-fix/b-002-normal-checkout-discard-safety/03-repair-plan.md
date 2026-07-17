# B-002 Whole-Run Discard Repair Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Discard delete the explicitly confirmed current Delivery Workflow run, including owned branch/worktree and process records, without deleting unselected external changes or attempting post-deletion record updates.

**Architecture:** The vendored finishing skill owns the destructive-choice protocol, Git/worktree identity revalidation, execution order, and normalized result. The three Delivery Workflow Completion sections provide current-run ownership context and branch on the normalized result: successful whole-run deletion stops without persistent record updates, while merge/PR/keep and failed/cancelled Discard retain existing record behavior.

**Tech Stack:** Markdown workflow skills, Bash contract tests, Git worktree/branch commands, repository build scripts.

## Global Constraints

- Apply the whole-run Discard semantic symmetrically to `feature-dev`, `bug-fix`, and `refactor`.
- A successful `whole_run_discarded` result leaves no manifest, stage record, tombstone, `abandoned` status, or cleanup-result record.
- External or unknown changes are never deleted unless the user selects the expanded deletion option and provides the second exact confirmation.
- A worktree is removable only when current-run creation evidence matches current Git worktree identity.
- Detached HEAD remains outside B-002.
- Merge, PR, Keep, cancelled Discard, and failed Discard retain their current persistent-record behavior.
- Do not introduce unscoped `git reset --hard`, unscoped `git clean -fd`, force-push, amend, or history rewriting.
- Modify source files under `src/`; regenerate `dist/.dev-cadence/` with `bash scripts/build.sh` and never edit `dist/` directly.
- Update the installed package version from `0.21.0` to `0.22.0` because this changes user-visible Completion behavior.

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Whole-run finishing contract | Add a test-first whole-run Discard mode to the vendored finishing skill while retaining ordinary finishing behavior | `tests/finishing-discard-contract.sh`, `tests/run-all.sh`, `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md` | `bash tests/finishing-discard-contract.sh` |
| Task 2: Delivery Completion result routing | Make all three Delivery Workflows pass run context and stop without record writes after `whole_run_discarded` | `tests/workflow-symmetry.sh`, `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, `src/skills/refactor/SKILL.md` | `bash tests/workflow-symmetry.sh` |
| Task 3: Package release and regression verification | Version, build, and verify the complete installable package and source/dist synchronization | `version`, generated `dist/.dev-cadence/**` | `bash scripts/check-whitespace.sh`, `bash scripts/check-all.sh`, focused `rg --no-ignore` checks |

## Detailed Tasks

### Task 1: Whole-run finishing contract

**Files:**

- Create: `tests/finishing-discard-contract.sh`
- Modify: `tests/run-all.sh`
- Modify: `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`

**Interfaces:**

- Consumes: optional current-run context supplied by a Dev Cadence Delivery Workflow.
- Produces: normalized finishing results `whole_run_discarded`, `discard_cancelled`, or `discard_blocked`; ordinary finishing behavior remains available when no current-run context is supplied.

- [ ] **Step 1: Write the failing finishing contract test**

Create `tests/finishing-discard-contract.sh` with this contract:

```bash
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
assert_no_match "unscoped hard reset" '^[[:space:]]*git reset --hard([[:space:]]|$)'
assert_no_match "unscoped clean" '^[[:space:]]*git clean -fd([[:space:]]|$)'

printf 'Finishing Discard contract checks passed.\n'
```

Append this exact invocation to `tests/run-all.sh` after the existing skill contract checks and before install/whitespace checks:

```bash
bash "$ROOT_DIR/tests/finishing-discard-contract.sh"
```

- [ ] **Step 2: Run the focused test to verify RED**

Run:

```bash
bash tests/finishing-discard-contract.sh
```

Expected: FAIL at `missing whole-run mode` because the vendored finishing skill has no `Dev Cadence Whole-Run Discard` contract.

- [ ] **Step 3: Add the whole-run Discard mode to the finishing skill**

Preserve Steps 1-4 and ordinary non-Dev-Cadence behavior. Before the existing Option 4 implementation, add a `Dev Cadence Whole-Run Discard` subsection with this exact context contract:

```markdown
### Dev Cadence Whole-Run Discard

Use this mode only when the caller supplies all current-run fields:

- Workflow
- Task slug
- Run directory
- Task branch
- Expected HEAD SHA
- Base branch
- Expected base SHA
- Owned commit range
- Owned tracked and untracked paths
- Workspace path
- Worktree created by this run

If any field is missing or conflicts with current Git or filesystem state, do not execute Discard. Return `discard_blocked` with the mismatched fields.
```

Replace the Dev Cadence Discard confirmation flow with a complete identity snapshot and these exact choices when external or unknown changes exist:

```markdown
1. Discard the current run only
2. Discard the entire owned workspace or branch
3. Cancel
```

Require the first destructive confirmation to state the exact run directory, task branch and SHA, owned commit range, owned paths, and owned worktree. It must include this warning:

```text
Successful Discard deletes the complete current run; no persistent run record will remain.
```

For choice 2, list every additional external or unknown path and require a second exact confirmation that names the expanded deletion scope. Choice 3 returns `discard_cancelled` without changing Git or filesystem state.

Define ownership and execution requirements in the skill:

```markdown
- Current-run creation evidence and `git worktree list --porcelain` must agree on path, branch, and Git identity.
- Directory naming is not ownership evidence.
- The workflow-only choice must preserve external and unknown paths byte-for-byte and path-for-path.
- Move a normal checkout or owned worktree off the task branch before deleting that exact branch.
- Delete the run directory last in a normal checkout.
- Remove a current-run-owned worktree last after branch and path postconditions pass.
- The finishing flow must not remove an external or unknown worktree.
- Verify the exact branch, worktree, path, and run-directory postconditions before returning success.
```

Return exactly one normalized result:

```markdown
- `whole_run_discarded`: every confirmed current-run object was deleted and all unselected external/unknown changes were preserved.
- `discard_cancelled`: the user cancelled before destructive execution.
- `discard_blocked`: identity changed, preservation could not be proven, or any destructive/postcondition step failed.
```

Keep existing ordinary Option 4 behavior for callers that do not supply Dev Cadence current-run context, except retain the already-required typed `discard` confirmation.

- [ ] **Step 4: Run focused GREEN verification**

Run:

```bash
bash tests/finishing-discard-contract.sh
```

Expected: `Finishing Discard contract checks passed.`

- [ ] **Step 5: Build and run required pre-commit checks**

Run:

```bash
bash scripts/build.sh
bash tests/package-contract.sh
bash scripts/check-whitespace.sh
bash scripts/check-all.sh
```

Expected: all checks pass after the build synchronizes the vendored source into `dist/.dev-cadence/vendor/`. Do not edit `dist/` manually and do not force-add ignored distribution output.

- [ ] **Step 6: Commit Task 1**

Stage only the Task 1 source and test files:

```bash
git add tests/finishing-discard-contract.sh tests/run-all.sh src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md
git commit -m "fix(flow): define whole-run discard contract"
```

### Task 2: Delivery Completion result routing

**Files:**

- Modify: `tests/workflow-symmetry.sh`
- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`

**Interfaces:**

- Consumes: confirmed current-run records and ownership identity from each Delivery Workflow.
- Produces: symmetric caller context for Task 1 and conditional Completion behavior keyed by `whole_run_discarded`, `discard_cancelled`, and `discard_blocked`.

- [ ] **Step 1: Add failing symmetry assertions**

Add these assertions after the existing `completion finishing flow` assertion in `tests/workflow-symmetry.sh`:

```bash
assert_workflows "whole-run discard context" \
  "Run directory.*Task branch.*Expected HEAD SHA|Expected HEAD SHA.*Run directory" \
  "Run directory.*Task branch.*Expected HEAD SHA|Expected HEAD SHA.*Run directory" \
  "Run directory.*Task branch.*Expected HEAD SHA|Expected HEAD SHA.*Run directory"

assert_workflows "whole-run discard result" \
  'whole_run_discarded' \
  'whole_run_discarded' \
  'whole_run_discarded'

assert_workflows "whole-run no record update" \
  'do not update.*manifest.*Business Acceptance|do not update.*Business Acceptance.*manifest' \
  'do not update.*manifest.*Business Acceptance|do not update.*Business Acceptance.*manifest' \
  'do not update.*manifest.*Business Acceptance|do not update.*Business Acceptance.*manifest'

assert_workflows "cancelled or blocked discard retains run" \
  'discard_cancelled.*discard_blocked.*retain|discard_blocked.*discard_cancelled.*retain' \
  'discard_cancelled.*discard_blocked.*retain|discard_blocked.*discard_cancelled.*retain' \
  'discard_cancelled.*discard_blocked.*retain|discard_blocked.*discard_cancelled.*retain'
```

- [ ] **Step 2: Run the symmetry test to verify RED**

Run:

```bash
bash tests/workflow-symmetry.sh
```

Expected: FAIL at `whole-run discard context` because none of the three Completion sections provides the required context.

- [ ] **Step 3: Update each Delivery Workflow Completion context**

In each of `feature-dev`, `bug-fix`, and `refactor`, extend `Pass this Dev Cadence context into the finishing flow` with the same required fields:

```markdown
- Current-run Discard context: Workflow, Task slug, Run directory, Task branch, Expected HEAD SHA, Base branch, Expected base SHA, Owned commit range, Owned tracked and untracked paths, Workspace path, and Worktree created by this run.
- Successful whole-run Discard intentionally deletes the current run records and leaves no persistent terminal record.
```

Require each workflow to derive these values from its confirmed manifest and stage records, then revalidate them against current Git/filesystem state immediately before invoking finishing.

- [ ] **Step 4: Add symmetric Completion result routing**

Replace the unconditional post-finishing update paragraph in all three workflows with this semantic block, adapting only workflow-specific record names:

```markdown
Handle the normalized finishing result:

- `whole_run_discarded`: the current run directory no longer exists. Do not update the manifest, Business Acceptance record, checkpoint fields, or any other run record. Do not run the terminal-record readiness checklist. Report the verified deletion result in the current conversation and stop this workflow.
- `discard_cancelled` or `discard_blocked`: retain the current run and its records, report the reason, and remain in Completion without claiming a terminal result.
- merge, pull request, or keep: update the manifest and Business Acceptance record with the final integration result, then complete the existing terminal-record readiness checklist.
```

Update the earlier `Final Follow-Up Actions` rule so it applies only when the run records remain. It must not require a post-deletion update after `whole_run_discarded`.

- [ ] **Step 5: Run symmetry GREEN verification**

Run:

```bash
bash tests/workflow-symmetry.sh
```

Expected: `Workflow symmetry checks passed.`

- [ ] **Step 6: Run focused finishing contract regression**

Run:

```bash
bash tests/finishing-discard-contract.sh
```

Expected: `Finishing Discard contract checks passed.`

- [ ] **Step 7: Build and run required pre-commit checks**

Run:

```bash
bash scripts/build.sh
bash scripts/check-whitespace.sh
bash scripts/check-all.sh
```

Expected: all checks pass with source and distribution copies synchronized.

- [ ] **Step 8: Commit Task 2**

```bash
git add tests/workflow-symmetry.sh src/skills/feature-dev/SKILL.md src/skills/bug-fix/SKILL.md src/skills/refactor/SKILL.md
git commit -m "fix(flow): route whole-run discard completion"
```

### Task 3: Package release and regression verification

**Files:**

- Modify: `version`
- Generate: `dist/.dev-cadence/**` through `bash scripts/build.sh`
- Update during execution: `build/dev-cadence/bug-fix/b-002-normal-checkout-discard-safety/04-repair-record.md`

**Interfaces:**

- Consumes: green Task 1 and Task 2 contracts.
- Produces: installable Dev Cadence `0.22.0` with synchronized source and distribution rules.

- [ ] **Step 1: Update the package version**

Change `version` from:

```text
0.21.0
```

to:

```text
0.22.0
```

- [ ] **Step 2: Build the distribution package**

Run:

```bash
bash scripts/build.sh
```

Expected: exit code `0`; `dist/.dev-cadence/version` contains `0.22.0`, source workflow skills are copied to `dist/.dev-cadence/skills/`, and the vendored finishing skill is copied to `dist/.dev-cadence/vendor/`.

- [ ] **Step 3: Verify source and distribution contain the key contracts**

Run:

```bash
rg --no-ignore -n "whole_run_discarded|no persistent run record will remain|Discard the current run only" src dist/.dev-cadence
```

Expected: matching rules in both `src/` and `dist/.dev-cadence/` for the finishing skill and all three Delivery Workflow Completion contracts.

- [ ] **Step 4: Run focused contracts**

Run:

```bash
bash tests/finishing-discard-contract.sh
bash tests/workflow-symmetry.sh
bash tests/package-contract.sh
```

Expected: all three scripts pass.

- [ ] **Step 5: Run required repository verification**

Run:

```bash
bash scripts/check-whitespace.sh
bash scripts/check-all.sh
```

Expected: all contract, install, and whitespace checks pass with no failures.

- [ ] **Step 6: Review the complete repair diff**

Run:

```bash
git status --short
git diff --stat
git diff -- tests/finishing-discard-contract.sh tests/run-all.sh tests/workflow-symmetry.sh src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md src/skills/feature-dev/SKILL.md src/skills/bug-fix/SKILL.md src/skills/refactor/SKILL.md version
```

Expected: only B-002 files and generated `dist/` output are present; no local absolute paths, temporary files, unrelated cards, or unrelated workflow behavior changes appear.

- [ ] **Step 7: Commit Task 3**

Do not force-add ignored `dist/` output. Stage only tracked source, test, version, and current-run record changes:

```bash
git add version build/dev-cadence/bug-fix/b-002-normal-checkout-discard-safety/04-repair-record.md
git commit -m "chore(release): prepare Dev Cadence 0.22.0"
```

## Repair Implementation Completion Conditions

- [ ] Every new contract test was observed failing for the expected missing-behavior reason before implementation.
- [ ] `tests/finishing-discard-contract.sh` passes.
- [ ] `tests/workflow-symmetry.sh` passes with all three Delivery Workflows using the same Completion result routing.
- [ ] `tests/package-contract.sh` passes after the build.
- [ ] `bash scripts/check-whitespace.sh` passes.
- [ ] `bash scripts/check-all.sh` passes.
- [ ] `rg --no-ignore` confirms source/dist synchronization for whole-run Discard rules.
- [ ] The B-002 repair record identifies changed files, implementation commits, RED/GREEN evidence, and skipped checks.
- [ ] No executable workflow rule is changed before this Repair Plan is confirmed.
