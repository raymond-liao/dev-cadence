# B-007 Regression Test Report

- Status: ✅ `completed`
- Verification Result: `passed`
- Verification Decision: `ready`
- Executed At: `2026-07-18T07:54:25+0800`

## Problem And Repair Sources

- [问题诊断记录](01-problem-diagnosis-record.md)
- [修复方案](02-repair-solution.md)
- [修复计划](03-repair-plan.md)
- [修复实施记录](04-repair-record.md)
- [代码审查报告](04-code-review-report.md)

## Test Environment

- Repository: `dev-cadence`
- Branch: `codex/b-007-parallel-work-table-qualification`
- Verification HEAD: `89eb65313bc0f39a4991e5d5cec4967efb8719f3`
- Package version: `0.22.0` on this branch; batch target is `0.23.0` after integration with B-005.
- Runtime and tools: Bash, Git, `rg`, repository contract scripts
- Workspace: `.worktrees/b-007-parallel-work-table-qualification`

## Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| RV-01 | 并行视图为候选视图并分离状态与入口门禁 | Automated source/backlog contract | `bash tests/parallel-work-table-contract.sh` | ✅ `passed` | `Parallel work table contract checks passed.` |
| RV-02 | 构建、安装包、工作流契约和全量回归保持通过 | Full regression | `bash scripts/check-all.sh` | ✅ `passed` | 包契约、安装契约、对称性、并行视图和其他全量检查均通过。 |
| RV-03 | 源规则与分发包同步生成 | Build | `bash scripts/build.sh` | ✅ `passed` | Exit `0`; generated package refreshed from `src/`. |
| RV-04 | 空白和补丁格式无错误 | Static check | `bash scripts/check-whitespace.sh`; `git diff --check` | ✅ `passed` | Exit `0`, no output. |

## Bug Fix Coverage

| Confirmed problem or acceptance point | Test Cases | Status |
| --- | --- | --- |
| 状态字段只表达卡片生命周期 | RV-01, RV-02 | `covered` |
| 下一步 Workflow / 入口门禁独立表达入口资格 | RV-01, RV-02 | `covered` |
| Story、Task、Bug、Blocked 的入口差异明确 | RV-01, RV-02 | `covered` |
| 不自动启动 Workflow 或直接修改代码 | RV-01, RV-02 | `covered` |
| 原有序号、状态和用户授权规则保持不变 | RV-01, RV-02 | `covered` |

## Failed Or Skipped Checks

None.

## Residual Risks

契约测试验证源规则和当前 Backlog 投影，不执行真实并行调度；后续新增工作项行仍需显式填写入口门禁列。

## Verification Decision

`ready`

Executed evidence satisfies the confirmed repair goal and acceptance points.

## Recommendation

✅ Ready to enter Business Acceptance.
