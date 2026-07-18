# B-005 Regression Test Report

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
- Branch: `codex/b-005-confirmation-gates`
- Verification HEAD: `7aa14044f329e8e970a92b3ea436b3ddb17b8a97`
- Package version: `0.23.0`
- Runtime and tools: Bash, Git, `rg`, repository contract scripts
- Workspace: `.worktrees/b-005-confirmation-gates`

## Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| RV-01 | 六个源 Workflow 都包含摘要、范围、风险、证据链接和选择结果语义 | Automated source contract | `bash tests/confirmation-gates-contract.sh` | ✅ `passed` | `Confirmation gates contract checks passed.` |
| RV-02 | 构建、安装包、工作流契约和全量回归保持通过 | Full regression | `bash scripts/check-all.sh` | ✅ `passed` | 包契约、安装契约、对称性、确认门和其他全量检查均通过。 |
| RV-03 | 源规则与分发包同步生成 | Build | `bash scripts/build.sh` | ✅ `passed` | Exit `0`; version `0.23.0` installed by contract check. |
| RV-04 | 空白和补丁格式无错误 | Static check | `bash scripts/check-whitespace.sh`; `git diff --check` | ✅ `passed` | Exit `0`, no output. |

## Bug Fix Coverage

| Confirmed problem or acceptance point | Test Cases | Status |
| --- | --- | --- |
| 六个 Workflow 先呈现当前结论、范围、风险/问题和证据边界 | RV-01, RV-02 | `covered` |
| Delivery Workflow 具有确认推进与修改后留在当前阶段的选项效果 | RV-01, RV-02 | `covered` |
| Asset Workflow 保留 Journey、Planning、Architecture 的专属语义 | RV-01, RV-02 | `covered` |
| Business Acceptance 与 Completion 不被通用确认门替换 | RV-01, RV-02 | `covered` |
| 版本和安装分发包同步为 `0.23.0` | RV-02, RV-03 | `covered` |

## Failed Or Skipped Checks

None.

## Residual Risks

规则契约测试不模拟实际代理会话；确认门具体措辞仍可能在未来独立扩展时漂移，但六套 owning Workflow 的最小语义受测试保护。

## Verification Decision

`ready`

Executed evidence satisfies the confirmed repair goal and acceptance points.

## Recommendation

✅ Ready to enter Business Acceptance.

## 2026-07-18 回归复验

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
| B005-R1 | 终态菜单同消息呈现缺口 | RED contract | `bash tests/confirmation-gates-contract.sh` before repair | ✅ `passed` as RED | Failed with missing same-message menu. |
| B005-G1 | 三条 Delivery workflow 固定菜单与委托边界 | GREEN contract | `bash tests/confirmation-gates-contract.sh` | ✅ `passed` | Confirmation gates contract checks passed. |
| B005-G2 | Delivery workflow 对称性 | Regression | `bash tests/workflow-symmetry.sh` | ✅ `passed` | Workflow symmetry checks passed. |
| B005-G3 | 完整构建与安装契约 | Full suite | `bash scripts/check-all.sh` | ✅ `passed` | All repository checks passed at `0.25.1`. |

### Bug Fix Coverage

- 原症状：B005-R1、B005-G1，`covered`。
- 根因：B005-G1、B005-G2，`covered`。
- source/dist 同步：B005-G3 和关键规则 `rg --no-ignore` 检查，`covered`。

### Impact Scope Coverage

- Business Acceptance 菜单：`covered`。
- delegated continuation 边界：`covered`。
- Completion 菜单交接：`covered`。

### Failed Or Skipped Checks

None.

### Residual Risks

规则测试不启动真实代理会话；它验证未来代理必须读取的可执行契约。

### Verification Decision

🟢 `ready`

### Recommendation

可进入当前 Business Acceptance。
