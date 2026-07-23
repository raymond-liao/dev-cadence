# B-012 回归测试报告

- Workflow: `bug-fix`
- Work Item: [B-012 Draft Story 在 Ready 门禁前被提前领取](../../../../docs/delivery/bugs/B-012-draft-story-claimed-before-ready-gate.md)
- Repair Record: [B-012 修复记录](04-repair-record.md)
- Status: ✅ `confirmed`

## Verification Scope

验证入口领取顺序、Draft/Ready Story、Task、Bug 四场景门禁、source/dist 同步、安装包契约和全量仓库回归。

## Commands And Results

- `bash tests/work-item-development-workflow-contract.sh`: ✅ `passed`
- `bash tests/work-item-analysis-contract.sh`: ✅ `passed`
- `bash tests/work-item-planning-contract.sh`: ✅ `passed`
- `bash tests/routing-contract.sh`: ✅ `passed`
- `bash tests/package-contract.sh`: ✅ `passed`
- `bash tests/install-contract.sh`: ✅ `passed`
- `bash scripts/check-whitespace.sh`: ✅ `passed`
- `bash scripts/check-all.sh`: ✅ `passed`
- `bash scripts/build.sh`: ✅ `passed`; source/dist ordered intake matrix matches

## Decision

✅ `passed`. Draft Story cannot be claimed before explicit Ready confirmation; Ready Story, Task, and Bug qualification behavior remains covered. No residual regression risk was found within the confirmed scope.

## Problem And Repair Sources

- Diagnosis: `01-problem-diagnosis-record.md`
- Repair Solution: `02-repair-solution.md`
- Repair Plan: `03-repair-plan.md`
- Repair Record: `04-repair-record.md`

## Test Environment

- Repository: `dev-cadence`
- Branch: `codex/parallel-b012-b010-b014`
- Configuration: `output_language: zh-CN`, worktree-enabled source configuration
- Tooling: repository Bash contracts and `scripts/build.sh`; no server required

## Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| B012-T1 | Draft/Ready/Task/Bug ordered claim matrix | contract | `bash tests/work-item-development-workflow-contract.sh` | passed | ordered matrix and four eligibility assertions |
| B012-T2 | Work Item Analysis Story readiness | contract | `bash tests/work-item-analysis-contract.sh` | passed | Analysis owns Ready decision |
| B012-T3 | Routing and planning regression | contract | `bash tests/routing-contract.sh` and `bash tests/work-item-planning-contract.sh` | passed | existing route/ordering contracts |
| B012-T4 | Source/dist/build/install | build/install | `bash scripts/build.sh`, `bash tests/package-contract.sh`, `bash tests/install-contract.sh` | passed | source/dist matrix and installed package |
| B012-T5 | Full repository regression | full suite | `bash scripts/check-all.sh` | passed | all repository contracts |

## Bug Fix Coverage

| Point | Tests | Status |
| --- | --- | --- |
| Draft Story is not claimed before confirmed Ready | B012-T1 | covered |
| Root cause ordering is enforced before claim write | B012-T1 | covered |
| Ready Story, Task, and Bug non-unified gates remain | B012-T1, B012-T2, B012-T3 | covered |

## Impact Scope Coverage

| Area | Tests | Status |
| --- | --- | --- |
| Entry routing source and dist | B012-T1, B012-T4 | covered |
| Work Item Analysis handoff | B012-T2 | covered |
| Package/install behavior | B012-T4, B012-T5 | covered |

## Failed Or Skipped Checks

None.

## Residual Risks

None within the confirmed scope.

## Verification Decision

`ready`

## Recommendation

The fix may enter Business Acceptance.
