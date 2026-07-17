# B-008 Regression Test Report

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
- Branch: `codex/b-008-bug-fix-backlog-sync`
- Verification HEAD: `c8864138d2a612c358ce75894d26fa203c41f777`
- Package version: `0.22.0` on this branch; batch target is `0.23.0` after integration with B-005.
- Runtime and tools: Bash, Git, `rg`, repository contract scripts
- Workspace: `.worktrees/b-008-bug-fix-backlog-sync`

## Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| RV-01 | 只有成功 `merge` 才允许 Backlog `Done` 写回 | Automated source contract | `bash tests/bug-fix-backlog-sync-contract.sh` | ✅ `passed` | `Bug Fix Backlog synchronization contract checks passed.` |
| RV-02 | 构建、安装包、工作流契约和全量回归保持通过 | Full regression | `bash scripts/check-all.sh` | ✅ `passed` | 包契约、安装契约、Delivery 记录和其他全量检查均通过。 |
| RV-03 | 源规则与分发包同步生成 | Build | `bash scripts/build.sh` | ✅ `passed` | Exit `0`; generated package refreshed from `src/`. |
| RV-04 | 空白和补丁格式无错误 | Static check | `bash scripts/check-whitespace.sh`; `git diff --check` | ✅ `passed` | Exit `0`, no output. |

## Bug Fix Coverage

| Confirmed problem or acceptance point | Test Cases | Status |
| --- | --- | --- |
| 成功 merge 后按 Bug ID 和 Version 定位并同步 Done | RV-01, RV-02 | `covered` |
| 非 merge 和 discard 结果不产生 Done 回写 | RV-01, RV-02 | `covered` |
| 冲突时停止且不部分写入 | RV-01 | `covered` |
| 原子移动、无关行顺序和并行表移除有明确规则 | RV-01, RV-02 | `covered` |
| manifest、Business Acceptance 和 follow-up 保留实际同步证据 | RV-01, RV-02 | `covered` |

## Failed Or Skipped Checks

None.

## Residual Risks

契约测试不执行真实 Backlog 文件写回；规则已明确实际运行时必须重新读取可见事实、遇冲突停止，并保持原子更新和幂等行为。

## Verification Decision

`ready`

Executed evidence satisfies the confirmed repair goal and acceptance points.

## Recommendation

✅ Ready to enter Business Acceptance.
