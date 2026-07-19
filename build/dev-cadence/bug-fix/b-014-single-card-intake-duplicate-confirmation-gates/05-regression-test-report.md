# B-014 回归测试报告

- Workflow: `bug-fix`
- Work Item: [B-014 单项建卡被错误套用双确认门](../../../../docs/bugs/B-014-single-card-intake-duplicate-confirmation-gates.md)
- Repair Record: [B-014 修复记录](04-repair-record.md)
- Status: ✅ `confirmed`

## Verification Scope

验证 Direct Intake 单一正式确认、必要澄清边界、Portfolio Planning 双确认门、命名子集原子写入语义、source/dist 同步和全量仓库回归。

## Commands And Results

- `bash tests/work-item-planning-contract.sh`: ✅ `passed`
- `bash tests/confirmation-gates-contract.sh`: ✅ `passed`
- `bash tests/package-contract.sh`: ✅ `passed`
- `bash tests/install-contract.sh`: ✅ `passed`
- `bash scripts/check-whitespace.sh`: ✅ `passed`
- `bash scripts/check-all.sh`: ✅ `passed`
- `bash scripts/build.sh`: ✅ `passed`; source/dist 模式分支和门禁语义一致

## Decision

✅ `passed`. Direct Intake 只有一个正式结果确认，Portfolio Planning 双门保持不变，必要卡片与 Backlog 引用仍为原子单元；未发现残余回归风险。

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
| B014-T1 | Portfolio Planning two formal gates | contract | `bash tests/work-item-planning-contract.sh` | passed | mode-specific sequence and atomic subset assertions |
| B014-T2 | Direct Intake one formal gate | contract | `bash tests/confirmation-gates-contract.sh` | passed | one result gate and clarification boundary |
| B014-T3 | Source/dist/build/install | build/install | `bash scripts/build.sh`, `bash tests/package-contract.sh`, `bash tests/install-contract.sh` | passed | mode split synchronized |
| B014-T4 | Full repository regression | full suite | `bash scripts/check-all.sh` | passed | all repository contracts |

## Bug Fix Coverage

| Point | Tests | Status |
| --- | --- | --- |
| Direct Intake has one formal confirmation | B014-T2 | covered |
| Necessary clarification is not a formal gate | B014-T2 | covered |
| Portfolio Planning retains two formal gates | B014-T1, B014-T2 | covered |
| Card and necessary Backlog references stay atomic | B014-T1 | covered |

## Impact Scope Coverage

| Area | Tests | Status |
| --- | --- | --- |
| Work Item Planning source and docs | B014-T1, B014-T2 | covered |
| Source/dist/install package | B014-T3, B014-T4 | covered |
| Named subset and ordering semantics | B014-T1 | covered |

## Failed Or Skipped Checks

None.

## Residual Risks

None within the confirmed scope.

## Verification Decision

`ready`

## Recommendation

The fix may enter Business Acceptance.
