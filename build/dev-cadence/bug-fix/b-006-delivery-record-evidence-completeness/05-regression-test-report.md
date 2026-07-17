# B-006 Regression Test Report

- Status: ✅ `completed`
- Verification Result: `passed`
- Verification Decision: `ready`
- Executed At: `2026-07-17T23:12:48+0800`

## Problem And Repair Sources

- [问题诊断记录](01-problem-diagnosis-record.md)
- [修复方案](02-repair-solution.md)
- [修复计划](03-repair-plan.md)
- [修复实施记录](04-repair-record.md)
- [代码审查报告](04-code-review-report.md)

## Test Environment

- Repository: `dev-cadence`
- Branch: `codex/b-006-delivery-record-evidence-completeness`
- Verification HEAD: `025491c`
- Package version: `0.22.0`
- Runtime and tools: Bash, Git, `rg`, repository contract scripts
- Relevant configuration: `.dev-cadence.yaml`; isolated workspace `.worktrees/b-006-delivery-record-evidence-completeness`

## Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| RV-01 | Validator accepts valid committed-change, no-tracked-change, and abandoned runs and rejects all incomplete evidence variants | Automated regression | `bash tests/delivery-record-contract.sh` | ✅ `passed` | `Delivery record contract checks passed.` |
| RV-02 | `feature-dev`, `bug-fix`, and `refactor` retain symmetric evidence contracts | Automated source contract | `bash tests/workflow-symmetry.sh` | ✅ `passed` | `Workflow symmetry checks passed.` |
| RV-03 | Source package rebuild succeeds | Build | `bash scripts/build.sh` | ✅ `passed` | Exit `0`; generated package refreshed from `src/`. |
| RV-04 | Distribution contains the validator and matches source | Package contract | `bash tests/package-contract.sh` | ✅ `passed` | `Package contract checks passed.` |
| RV-05 | Target installation contains the validator and version `0.22.0` | Install contract | `bash tests/install-contract.sh` | ✅ `passed` | Installed Dev Cadence `0.22.0`; install contract passed. |
| RV-06 | Repository whitespace contract remains valid | Static check | `bash scripts/check-whitespace.sh` | ✅ `passed` | Exit `0`. |
| RV-07 | Complete repository contract suite remains green | Full regression | `bash scripts/check-all.sh` | ✅ `passed` | All package, asset/delivery, architecture, discovery, planning, routing, symmetry, install, and whitespace checks passed. |
| RV-08 | Complete B-006 range contains no patch whitespace errors | Git inspection | `git diff --check 9834d2e..HEAD` | ✅ `passed` | Exit `0`, no output. |
| RV-09 | Historical S-014 run remains unchanged | Scope regression | `git diff --name-only 9834d2e..HEAD -- build/dev-cadence/feature-dev/s-014-user-journey-baseline` | ✅ `passed` | Empty result. |

## Bug Fix Coverage

| Confirmed problem or acceptance point | Test Cases | Status |
| --- | --- | --- |
| Terminal records reject pending or missing SHA, Changed Files, Review, and test conclusions | RV-01 | `covered` |
| Checkpoint commit tree contains the referenced stage artifact | RV-01 | `covered` |
| Final SHA resolves and Changed Files match the complete implementation range | RV-01 | `covered` |
| SDD scratch is not terminal evidence | RV-01 | `covered` |
| Three Delivery Workflow rules use the same contract | RV-02, RV-07 | `covered` |
| Installed distribution ships the validator at version `0.22.0` | RV-03, RV-04, RV-05 | `covered` |

## Impact Scope Coverage

| Affected area | Test Cases | Status |
| --- | --- | --- |
| Validator executable behavior | RV-01, RV-07 | `covered` |
| Feature/Bug Fix/Refactor workflow rules | RV-02, RV-07 | `covered` |
| Package and installation output | RV-03, RV-04, RV-05 | `covered` |
| Repository-wide contracts and whitespace | RV-06, RV-07, RV-08 | `covered` |
| S-014 historical evidence remains untouched | RV-09 | `covered` |

## Failed Or Skipped Checks

None.

## Residual Risks

None blocking. The validator intentionally parses the documented Markdown record contract; future label or table-schema changes must update the validator and its contract fixtures together.

## Verification Decision

`ready`

Executed evidence satisfies the confirmed repair goal and acceptance points, with no failed, skipped, or uncovered required check.

## Recommendation

✅ Ready to enter Business Acceptance.
