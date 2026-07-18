# B-005 问题诊断记录（回归）

## 问题来源

- Work Item: [B-005 已安装 Workflow 用户确认门摘要、选项与结果语义不完整](../../../../docs/bugs/B-005-refactor-confirmation-options-missing.md)
- Card Version: `4`
- Prior Run: `build/dev-cadence/bug-fix/b-005-confirmation-gates/manifest.md`

## 报告症状

S-017 实施期间进入 Business Acceptance 时，用户可见提示没有提供固定编号选项；运行记录随后把用户此前的 delegated continuation 当作验收依据。

## 预期与实际

- 预期：Business Acceptance 摘要与 `1. Accept`、`2. Reject`、`3. Accept with residual risk` 必须在同一条用户可见消息中出现，且必须等待用户选择。
- 实际：规则虽列出菜单，但没有禁止省略菜单或使用 delegated continuation 代替终态决策，现有契约测试也没有验证这两个边界。

## 影响范围

三个 Delivery Workflow 的 Business Acceptance 与 Completion 交接；不修改 Asset Workflow，也不修改 vendored Superpowers。

## 复现与证据

1. 检查 `build/dev-cadence/feature-dev/s-017-work-item-development-workflow-integration/manifest.md` 和业务验收记录。
2. 对照三个 Delivery skill 的 Business Acceptance 规则与 `tests/confirmation-gates-contract.sh`。
3. 现有测试只验证前置确认门，无法阻止终态菜单被省略或 delegated continuation 被当作验收。

## 根因判断

根因是终态提示只有菜单内容定义，没有正向规定“摘要与完整菜单必须同消息展示”，也没有明确规定 delegated continuation 只适用于中间门禁、不能形成 Business Acceptance 或 Completion 决策。置信度：高。

## 结论

B-005 已确认发生回归；需要补强三个 Delivery skill 的终态决策提示契约及契约测试。

## 假设与未决问题

- 假设：现有三项 Business Acceptance 归一化语义保持不变。
- Open Questions: 无。
