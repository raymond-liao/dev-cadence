# B-006 Delivery Record Evidence Completeness Repair Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Prevent new Delivery Workflow runs from reaching a terminal state with incomplete records, unbound checkpoints, or reliance on temporary SDD evidence.

**Architecture:** Add one installed Bash validator under `src/skills/using-dev-cadence/scripts/` and have `feature-dev`, `bug-fix`, and `refactor` invoke the same validation contract. Keep the validator as an internal package helper rather than adding a new user-routable workflow. Add fixture-based contract tests that create Git commits and exercise both valid and invalid run records.

**Tech Stack:** Bash, Git, `rg`, Markdown records, existing shell contract-test suite.

## Global Constraints

- Modify `src/` skill sources; do not edit `dist/.dev-cadence/**` directly.
- Keep `feature-dev`, `bug-fix`, and `refactor` structurally symmetric.
- Do not rewrite S-014 historical records or change product/business code.
- Do not change Delivery stage order, confirmation gates, or status enums.
- Treat SDD progress files as ignored runtime scratch, not terminal evidence.
- Bump `version` from `0.21.0` to `0.22.0` because installed workflow behavior changes.
- Use TDD: every validator or executable-contract change starts with a failing test.
- Keep all commits on `codex/b-006-delivery-record-evidence-completeness`; do not push.

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Delivery record validator | Detect invalid terminal records, missing links, and checkpoint/tree mismatches | `src/skills/using-dev-cadence/scripts/validate-delivery-record.sh`, `tests/delivery-record-contract.sh`, `tests/run-all.sh` | Focused valid/invalid fixture tests |
| Task 2: Workflow rule integration | Make all three Delivery Workflow rules require and invoke the same evidence contract | `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, `src/skills/refactor/SKILL.md`, `tests/workflow-symmetry.sh` | Focused symmetry and source-contract tests |
| Task 3: Package and regression verification | Ship the helper, bump version, rebuild distribution, and run the complete suite | `version`, `tests/package-contract.sh`, `tests/install-contract.sh`, generated `dist/.dev-cadence/**` | Build, install, package, whitespace, and full checks |

## Detailed Tasks

### Task 1: Delivery Record Validator

**Files:**

- Create: `src/skills/using-dev-cadence/scripts/validate-delivery-record.sh`
- Create: `tests/delivery-record-contract.sh`
- Modify: `tests/run-all.sh`

**Interfaces:**

- Consumes: `RUN_DIR` containing `manifest.md` and relative Delivery stage records; Git object database containing the checkpoint commits.
- Invocation: `bash .dev-cadence/skills/using-dev-cadence/scripts/validate-delivery-record.sh RUN_DIR --terminal`.
- Produces: exit `0` for a valid run, exit `1` with a specific failure message for an invalid run.

- [ ] **Step 1: Write the failing fixture contract**

  Create a temporary Git repository in `tests/delivery-record-contract.sh`. Build one valid run and four invalid variants:

  - valid: terminal manifest, real stage artifacts, a checkpoint commit whose tree contains its stage record, final SHA, concrete Changed Files, review result, and test result;
  - invalid placeholder: terminal implementation record with `Changed Files: pending`;
  - invalid link: manifest points to a missing stage record;
  - invalid tree: manifest points to a real commit that does not contain the referenced stage record;
  - invalid review: final record retains a pending final Review or references `sdd/progress.md` as terminal evidence.

  The test must call the installed-path equivalent from the source tree during source testing:

  ```bash
  bash "$ROOT_DIR/src/skills/using-dev-cadence/scripts/validate-delivery-record.sh" "$run_dir" --terminal
  ```

  Assert the valid fixture succeeds and each invalid fixture fails with a message identifying its violated contract.

- [ ] **Step 2: Run the focused test and verify RED**

  Run:

  ```bash
  bash tests/delivery-record-contract.sh
  ```

  Expected: FAIL because `src/skills/using-dev-cadence/scripts/validate-delivery-record.sh` does not exist yet. Do not implement the validator before observing this failure.

- [ ] **Step 3: Implement the minimal validator**

  Implement `validate-delivery-record.sh` with `set -euo pipefail` and these checks, in this order:

  1. Require exactly one run directory and optional `--terminal`; reject missing `manifest.md`.
  2. Resolve the repository root with `git -C "$RUN_DIR" rev-parse --show-toplevel` and reject paths outside that repository.
  3. Parse each manifest stage row, extract its status, artifact path, and checkpoint value, and reject unknown status values.
  4. For `confirmed` or `accepted` stages, reject a `pending` checkpoint; allow only a real commit SHA or an explicit `skipped: <reason>` value.
  5. For a real checkpoint SHA, run `git -C "$REPO_ROOT" cat-file -e "$CHECKPOINT_SHA:$ARTIFACT_PATH"` and fail if the stage artifact is absent from that commit tree.
  6. Require every non-pending artifact path to exist in the current run directory and reject broken local references.
  7. Locate the implementation/repair/refactor record and require a concrete final implementation SHA plus a non-pending Changed Files section when the run has tracked implementation commits; accept explicit `skipped: no tracked changes` for an empty tracked-change case.
  8. Reject terminal records that make `sdd/progress.md` or another ignored SDD scratch path a required final evidence source.
  9. In `--terminal` mode, reject any remaining terminal-stage `pending` checkpoint or final Review/verification placeholder.

  Print `Delivery record validation passed: <run-dir>` on success and one `FAIL: ...` line per first violated condition on failure.

- [ ] **Step 4: Run the focused test and verify GREEN**

  Run:

  ```bash
  bash tests/delivery-record-contract.sh
  ```

  Expected: the valid fixture passes and all four invalid fixtures fail for the intended reason.

- [ ] **Step 5: Add the focused test to the suite and commit**

  Add this command to `tests/run-all.sh` after the existing asset/delivery record contract:

  ```bash
  bash "$ROOT_DIR/tests/delivery-record-contract.sh"
  ```

  Run `git diff --check`, then commit only Task 1 files:

  ```bash
  git add src/skills/using-dev-cadence/scripts/validate-delivery-record.sh tests/delivery-record-contract.sh tests/run-all.sh
  git commit -m "test(flow): validate delivery record evidence"
  ```

### Task 2: Workflow Rule Integration

**Files:**

- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`
- Modify: `tests/workflow-symmetry.sh`

**Interfaces:**

- Consumes: the validator interface from Task 1.
- Produces: symmetric rules that generate and validate durable evidence before each workflow can reach its terminal state.

- [ ] **Step 1: Add failing symmetry assertions**

  Add assertions to `tests/workflow-symmetry.sh` for all three skills requiring:

  - final implementation SHA and Changed Files together for committed changes;
  - explicit `skipped: no tracked changes` for empty tracked-change stages;
  - checkpoint tree validation using `git cat-file -e`;
  - the installed validator path `.dev-cadence/skills/using-dev-cadence/scripts/validate-delivery-record.sh`;
  - SDD scratch not being terminal evidence.

  Run:

  ```bash
  bash tests/workflow-symmetry.sh
  ```

  Expected: FAIL because the three source skills do not yet contain the complete shared contract.

- [ ] **Step 2: Update the three workflow rules symmetrically**

  In each skill, replace the alternative evidence wording with the committed-change/no-tracked-change contract. Add the same checkpoint sequence after the existing “write or update the stage record” rule:

  ```text
  Write or update the stage record -> create the stage checkpoint -> verify the checkpoint tree contains the stage record -> bind the verified SHA in manifest -> run the installed delivery-record validator.
  ```

  Add the installed helper invocation at the terminal readiness gate:

  ```bash
  bash .dev-cadence/skills/using-dev-cadence/scripts/validate-delivery-record.sh \
    build/dev-cadence/<workflow>/<task-slug> --terminal
  ```

  State that `sdd/progress.md` and other ignored SDD scratch files are not required terminal evidence. Keep each workflow’s existing record names, status values, user gates, implementation ledger, and completion semantics unchanged.

- [ ] **Step 3: Run focused rule tests and verify GREEN**

  Run:

  ```bash
  bash tests/workflow-symmetry.sh
  bash tests/asset-delivery-record-contract.sh
  bash tests/document-conventions-contract.sh
  ```

  Expected: all focused tests pass, and the three source skills contain the same evidence contract with their workflow-specific record names preserved.

- [ ] **Step 4: Commit the rule integration**

  Run `git diff --check`, then commit only Task 2 files:

  ```bash
  git add src/skills/feature-dev/SKILL.md src/skills/bug-fix/SKILL.md src/skills/refactor/SKILL.md tests/workflow-symmetry.sh
  git commit -m "fix(flow): enforce delivery record evidence"
  ```

### Task 3: Package, Version, And Regression Verification

**Files:**

- Modify: `version` from `0.21.0` to `0.22.0`
- Modify: `tests/package-contract.sh`
- Modify: `tests/install-contract.sh`
- Generated: `dist/.dev-cadence/**` via `bash scripts/build.sh`; never edit directly

**Interfaces:**

- Consumes: Task 1 validator and Task 2 source rules.
- Produces: an installable package with source/dist parity and complete regression evidence.

- [ ] **Step 1: Add package/install assertions before the package change**

  Add the validator path to the package required-files list and assert that installation copies it to `.dev-cadence/skills/using-dev-cadence/scripts/validate-delivery-record.sh`.

  Run the package contract before rebuilding:

  ```bash
  bash tests/package-contract.sh
  ```

  Expected: `tests/package-contract.sh` FAIL because the generated dist package does not yet contain the new helper. `tests/install-contract.sh` is rerun after the build because its installation path may rebuild the package itself.

- [ ] **Step 2: Bump the package version and rebuild**

  Set `version` to `0.22.0`, then run:

  ```bash
  bash scripts/build.sh
  ```

  Expected: `dist/.dev-cadence/skills/using-dev-cadence/scripts/validate-delivery-record.sh` exists and is byte-identical to the source helper.

- [ ] **Step 3: Run package and full regression checks**

  Run:

  ```bash
  bash tests/package-contract.sh
  bash tests/install-contract.sh
  bash tests/delivery-record-contract.sh
  bash scripts/check-whitespace.sh
  bash scripts/check-all.sh
  ```

  Expected: all checks pass; the installed package reports `0.22.0`; no absolute paths, temporary artifacts, stale SDD terminal references, or source/dist mismatches are reported.

- [ ] **Step 4: Commit package changes and self-review**

  Run `git diff --check`, inspect `git diff --stat`, and confirm only the version, package/install contracts, generated dist, and in-scope source/test files changed. Commit with:

  ```bash
  git add version tests/package-contract.sh tests/install-contract.sh
  git commit -m "chore(release): ship delivery record validator"
  ```

  Do not force-add `dist/.dev-cadence/**`; it is ignored generated output and is verified from the build result.

## Plan Completion Conditions

- All Task 1-3 checkboxes are complete and each task commit is present on the B-006 branch.
- The validator passes valid fixtures and rejects every required invalid fixture.
- All three Delivery Workflow skills contain the same durable evidence and checkpoint-tree contract.
- Source and installed package are synchronized at version `0.22.0`.
- `bash scripts/check-all.sh` and `bash scripts/check-whitespace.sh` pass.
- No S-014 historical record or application behavior was modified.

## Self-Review

- Scope coverage: terminal evidence, checkpoint tree identity, SDD boundary, validator, tests, source/dist parity, and version are covered by Tasks 1-3.
- Placeholder scan: no `TBD`, `TODO`, or unspecified file/task remains in the implementation steps.
- Interface consistency: Task 1 defines the validator path and `RUN_DIR --terminal` interface; Task 2 invokes that same path; Task 3 packages and installs that same file.
