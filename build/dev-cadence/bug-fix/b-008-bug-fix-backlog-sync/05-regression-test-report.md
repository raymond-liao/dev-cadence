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

## 2026-07-18 卡片写回复验

### Problem And Repair Sources

- Diagnosis: [问题诊断记录](01-problem-diagnosis-record.md)
- Solution: [修复方案](02-repair-solution.md)
- Plan: [修复计划](03-repair-plan.md)
- Repair: [修复实施记录](04-repair-record.md)

### Test Environment

- Repository: `dev-cadence`
- Branch: `codex/b-005-b-007-b-008-contract-closure`
- Package version: `0.25.1`

### Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| B008-R1 | Completion 缺少卡片交付引用 | RED contract | `bash tests/bug-fix-backlog-sync-contract.sh` before repair | ✅ `passed` as RED | Failed with missing repair and integration references. |
| B008-G1 | 卡片与 Backlog 原子幂等写回 | GREEN contract | `bash tests/bug-fix-backlog-sync-contract.sh` | ✅ `passed` | Backlog synchronization contract passed. |
| B008-G2 | source/dist 关键规则一致 | Source inspection | `rg --no-ignore` across `src` and `dist/.dev-cadence` | ✅ `passed` | Required rules found in both trees. |
| B008-G3 | 完整构建与安装契约 | Full suite | `bash scripts/check-all.sh` | ✅ `passed` | All repository checks passed at `0.25.1`. |

### Bug Fix Coverage

- 原症状：B008-R1、B008-G1，`covered`。
- 卡片 `Done` 与交付引用：B008-G1，`covered`。
- Backlog 移动、冲突、非 merge 和幂等：B008-G1，`covered`。

### Impact Scope Coverage

- Bug Fix Completion：`covered`。
- B-008 card/Backlog Version：source inspection，`covered`。
- package source/dist：B008-G2、B008-G3，`covered`。

### Failed Or Skipped Checks

None.

### Residual Risks

契约测试不执行真实 Completion 文件写回；执行规则要求运行时重新读取事实并在冲突时零部分写入。

### Verification Decision

🟢 `ready`

### Recommendation

可进入当前 Business Acceptance。
