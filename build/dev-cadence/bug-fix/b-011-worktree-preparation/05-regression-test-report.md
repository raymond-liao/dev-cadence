# B-011 回归测试报告

## Problem And Repair Sources

- Problem Diagnosis: [问题诊断记录](01-problem-diagnosis-record.md)
- Repair Solution: [修复方案](02-repair-solution.md)
- Repair Plan: [修复计划](03-repair-plan.md)
- Repair Record: [修复实施记录](04-repair-record.md)
- Code Review: [代码审查报告](04-code-review-report.md)

## Test Environment

- Repository: `dev-cadence`
- Branch: `codex/fix-b011-worktree-preparation`
- Date: `2026-07-19`
- Runtime and tools: Bash, Git, repository build and contract scripts.
- Relevant configuration: `.dev-cadence.yaml` with `worktree.enabled: true` and `worktree.directory: .worktrees`; this run used `.worktrees/b-011-worktree-preparation`.
- Servers: None.

## Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| RV-01 | Entry prevents downstream routing until workspace preparation and covers both `worktree.enabled` paths. | Contract | `bash tests/work-item-development-workflow-contract.sh` | passed | `S-017 work-item development workflow contract checks passed.` |
| RV-02 | All Delivery workflow Plan stages verify/reuse rather than first create a workspace. | Contract | `bash tests/workflow-symmetry.sh` | passed | `Workflow symmetry checks passed.` |
| RV-03 | Generated installed package and temporary-target installation remain synchronized. | Package/install | `bash scripts/build.sh`; `bash tests/package-contract.sh && bash tests/install-contract.sh` | passed | Package and install contract checks passed for `0.26.3`. |
| RV-04 | Full repository delivery regression suite remains green. | Regression | `bash scripts/check-whitespace.sh && bash scripts/check-all.sh` | passed | Build, all listed contract tests, package/install, whitespace, confirmation gates, and Bug Fix Backlog synchronization checks passed. |
| RV-05 | Source and generated package both contain the entry and Plan-stage invariants. | Source inspection | two `rg --no-ignore` searches from Task 4 | passed | Entry rule matched source and dist; Plan boundary matched all three source and dist workflow skills. |
| RV-06 | Delivery-record evidence is structurally valid. | Record validation | `bash .dev-cadence/skills/using-dev-cadence/scripts/validate-delivery-record.sh build/dev-cadence/bug-fix/b-011-worktree-preparation` | passed | `Delivery record validation passed`. |

## Bug Fix Coverage

| Confirmed point | Test cases | Status |
| --- | --- | --- |
| Original symptom: after a claim, downstream work could start before workspace preparation. | RV-01 | covered |
| Root cause: entry had no strict claim → workspace preparation → downstream ordering contract. | RV-01 | covered |
| Acceptance: `true` creates or verifies the configured worktree before routing. | RV-01, RV-05 | covered |
| Acceptance: `false` prepares a dedicated branch and does not create a worktree. | RV-01, RV-05 | covered |
| Acceptance: Plan stages do not first create a branch or worktree. | RV-02, RV-05 | covered |

## Impact Scope Coverage

| Affected area | Test cases | Status |
| --- | --- | --- |
| Entry routing and atomic claim handoff | RV-01 | covered |
| Feature, bug-fix, and refactor workspace consumption | RV-02, RV-05 | covered |
| Packaged installation guidance and version | RV-03, RV-04 | covered |
| Delivery record integrity | RV-06 | covered |

## Failed Or Skipped Checks

None.

## Residual Risks

None.

## Verification Decision

Verification Result: ✅ `passed`

`ready`

## Recommendation

The fix can enter Business Acceptance.
