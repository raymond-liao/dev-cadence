# T-005 最终验证带入限制呈现

## 基本信息

- ID：`T-005`
- Version：`1`
- Status：`Ready`
- Priority：`P2`
- Change Type：Workflow Governance
- Nature：Technical

## 任务目标

在最终验证结论为 `ready_with_risk` 时，以轻量“带入限制”表让 Business Acceptance 能看到并引用仍影响交付的限制，而不引入独立风险管理模型。

## 背景

实施、Review 和最终验证已经分别记录 finding、跳过检查和残余风险，但 Business Acceptance 需要能定位仍影响交付的具体限制。为此新增全局风险 ID、状态机或 registry 会与现有 finding、检查和 S-018 的终态映射重叠，维护成本高于当前需要。

## ✅ 范围

- 当最终验证结论为 `ready_with_risk` 时，在最终验证报告中提供“带入限制”表。
- 每个表项必须包含来源引用、验证结论和残余影响。
- Business Acceptance 摘要和记录在用户选择 `accepted_with_risk` 时，必须引用被接受的带入限制表项，并记录既有契约要求的处理、责任人或后续动作。
- 在 `feature-dev`、`bug-fix` 和 `refactor` 中采用相同的最小呈现契约。
- 保持现有 Review finding、失败检查和残余风险记录的原有职责；带入限制表只提供最终验证到验收的阅读与引用路径。

## ❌ 非范围

- 不新增跨阶段风险 ID、风险命名空间、风险状态机或全局风险 registry。
- 不替代或自动关闭原始 Review finding。
- 不重新执行最终验证，也不把带入限制自动判定为接受或拒绝。
- 不修改 S-018 拥有的 Delivery 终态映射或 Business Acceptance 的整体决定语义。

## 完成条件

1. 三个开发 workflow 的最终验证在且仅在 `ready_with_risk` 时要求“带入限制”表。
2. 每个带入限制表项都能通过现有来源引用定位到实施、Review 或验证证据，并明确其验证结论和残余影响。
3. `accepted_with_risk` 的 Business Acceptance 摘要与记录逐项引用用户接受的带入限制；不存在隐式风险接受。
4. 实现不创建全局风险 ID、状态机或 registry，且不改变原始 finding 的关闭语义。
5. 现有失败检查和残余风险仍作为报告摘要保留，带入限制表不重复定义它们的生命周期。

## Task Relationships

- Supersedes：[S-020 实施、验证与 Business Acceptance 风险追溯](../stories/S-020-implementation-review-risk-to-verification.md)。
- Continues：已由 S-020 吸收的 [S-021 验证风险传递到 Business Acceptance](../stories/S-021-verification-risk-to-business-acceptance.md) 的最小必要范围。
- Related：[S-018 Delivery 终态映射与 Manual Recovery](../stories/S-018-business-acceptance-terminal-mapping.md)。

## 依赖

- 无强制前置依赖。S-018 继续拥有终态映射；本任务只提供验收可引用的限制证据。

## Open Questions

- 无。[Q-010 跨阶段风险 ID 命名空间](../open-questions.md#q-010) 已确认不适用：本任务不创建跨阶段风险 ID。

## 相关文档

- [Backlog](../backlog.md)
- [S-018 Delivery 终态映射与 Manual Recovery](../stories/S-018-business-acceptance-terminal-mapping.md)
- [S-021 验证风险传递到 Business Acceptance](../stories/S-021-verification-risk-to-business-acceptance.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-21T14:52:12+0800 | Raymond Liao <raymond-liao@outlook.com> | 将 S-020 转换为最终验证带入限制呈现 Task，并采用最小追溯方案。 | 用户确认不引入独立风险管理模型，只在 `ready_with_risk` 时呈现可被 Business Acceptance 引用的限制。 |
| 1 | 2026-07-21T15:06:35+0800 | Raymond Liao <raymond-liao@outlook.com> | 将任务状态从 `Draft` 更新为 `Ready`。 | 用户确认该任务的目标、范围、完成条件和关系已足以进入交付准备状态。 |
