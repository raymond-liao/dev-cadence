# B-005 修复方案（回归）

## 修复目标

消除终态菜单“规则中存在、实际提示中缺失”的执行漏洞，并禁止把中间阶段委托继续推断为 Business Acceptance 或 Completion 决策。

## ✅ Selected

在 `feature-dev`、`bug-fix`、`refactor` 的 Business Acceptance 段增加对称的 Decision Prompt Contract：摘要、完整固定编号菜单和选择请求必须在同一条消息中展示；未展示菜单时不得记录决策；delegated continuation 不能替代终态选择。Completion 前再明确必须呈现 finishing flow 的实际菜单，不能由委托继续自动选择。

## 修复边界

- 修改三个 Delivery workflow skill。
- 扩展 `tests/confirmation-gates-contract.sh` 的语义断言。
- 不修改 Asset Workflow、Business Acceptance 选项集合、状态枚举或 vendored Superpowers。

## 验收标准

1. 三个 Delivery workflow 都要求同一消息展示业务验收摘要和完整编号菜单。
2. 三个 workflow 都明确 delegated continuation 不构成 Business Acceptance 或 Completion 决策。
3. 专项契约在修复前因缺失规则失败，修复后通过。
4. `src` 与构建后的 `dist` 保持同步。

## 回归范围与风险

检查前置确认门、Business Acceptance 归一化、Completion 入口以及三条 Delivery workflow 对称性。主要风险是措辞只满足正则却不形成清晰执行契约，因此测试只锁定关键语义，不锁整段自然语言。
