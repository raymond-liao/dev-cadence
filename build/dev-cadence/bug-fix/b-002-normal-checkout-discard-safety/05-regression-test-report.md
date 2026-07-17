# B-002 Regression Test Report

## Problem And Repair Sources

- Diagnosis: `build/dev-cadence/bug-fix/b-002-normal-checkout-discard-safety/01-problem-diagnosis-record.md`.
- Repair Solution: `build/dev-cadence/bug-fix/b-002-normal-checkout-discard-safety/02-repair-solution.md`.
- Repair Plan: `build/dev-cadence/bug-fix/b-002-normal-checkout-discard-safety/03-repair-plan.md`.
- Repair Record: `build/dev-cadence/bug-fix/b-002-normal-checkout-discard-safety/04-repair-record.md`.

## Test Environment

- Repository: `dev-cadence`.
- Branch: `codex/b-002-normal-checkout-discard-safety`.
- Package version: `0.22.0`.
- Date: `2026-07-18T+08:00`.
- Tools: Bash, Git, Ripgrep, repository build and contract scripts.

## Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
|---|---|---|---|---|---|
| RT-01 | Whole-run Discard contract, including all remediated safety rules | Automated contract | `bash tests/finishing-discard-contract.sh` | ✅ `passed` | `Finishing Discard contract checks passed.` |
| RT-02 | Three Delivery Workflow Completion contracts remain symmetric | Automated contract | `bash tests/workflow-symmetry.sh` | ✅ `passed` | `Workflow symmetry checks passed.` |
| RT-03 | Installable-package source contract | Automated contract | `bash tests/package-contract.sh` | ✅ `passed` | `Package contract checks passed.` |
| RT-04 | Source/dist package build and complete repository contract suite | Build and regression | `bash scripts/build.sh && bash scripts/check-all.sh` | ✅ `passed` | all package, workflow, routing, finishing, install, and whitespace contracts passed at `0.22.0` |
| RT-05 | Whitespace contract | Automated contract | `bash scripts/check-whitespace.sh` | ✅ `passed` | `Whitespace contract checks passed.` |
| RT-06 | Whole-run key-rule source/dist synchronization | Source inspection | `rg --no-ignore` and four `cmp -s` checks | ✅ `passed` | key rules found in source and generated distribution; all four copies matched |
| RT-07 | Independent whole-repair review | Review | reviewed `969fba1..98c87bb` | ✅ `passed` | `04-code-review-report.md` records no Critical or Important finding |

## Bug Fix Coverage

| Confirmed point | Test cases | Status |
|---|---|---|
| Ordinary checkout and whole-run Discard identity/ownership safety | RT-01, RT-07 | covered |
| External/unknown path classification and preservation | RT-01, RT-07 | covered |
| Typed confirmation and post-confirmation revalidation | RT-01, RT-07 | covered |
| Owned worktree, detached HEAD, and records-last constraints | RT-01, RT-07 | covered |
| Three-workflow no-write terminal routing | RT-02, RT-07 | covered |
| Package release and source/dist synchronization | RT-03, RT-04, RT-06 | covered |

## Impact Scope Coverage

| Affected area | Test cases | Status |
|---|---|---|
| Vendored finishing workflow rule | RT-01, RT-04, RT-07 | covered |
| `feature-dev` Completion | RT-02, RT-04, RT-06 | covered |
| `bug-fix` Completion | RT-02, RT-04, RT-06 | covered |
| `refactor` Completion | RT-02, RT-04, RT-06 | covered |
| Installable distribution | RT-03, RT-04, RT-06 | covered |

## Failed Or Skipped Checks

- Failed: None.
- Skipped: no live destructive Discard was executed, because it requires the future Completion decision and must not be triggered during Regression Verification.

## Residual Risks

- The safety behavior is expressed as agent-executed Markdown workflow contracts; this run validates their required content and package synchronization, not a live destructive Git operation.

## Verification Decision

🟢 `ready`

## Recommendation

The repaired workflow can enter Business Acceptance.
