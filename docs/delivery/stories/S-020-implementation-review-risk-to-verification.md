# S-020 实施、验证与 Business Acceptance 风险追溯

## 基本信息

- ID：`S-020`
- Version：`3`
- Status：`Superseded`
- Priority：`P2`
- Change Type：Feature

## 目标

使用稳定 ID 让跳过的实施检查、未解决 review finding 和已接受风险从实施与 Review 一直可追溯到最终验证和 Business Acceptance。

## 处置

本 Story 已由 [T-005 最终验证带入限制呈现](../tasks/T-005-final-verification-carried-limitations.md) 替代。用户确认采用不建立风险 ID、状态机或 registry 的最小方案；T-005 仅在 `ready_with_risk` 时要求最终验证呈现可供 Business Acceptance 引用的带入限制。

## 背景

实施和 Review 阶段产生的风险如果只保存在原阶段记录中，最终验证可能错误地按无已知风险执行和汇报；若验证后的风险又只停留在报告中，业务验收同样无法基于完整限制做出决定。

## ✅ 范围

- 为跳过检查、未解决 finding 和已接受风险保留稳定 ID。
- 将这些 ID 及其状态传递到最终验证输入与报告。
- 记录验证对每项风险执行的检查和剩余结论。
- 将验证后仍未解决的 ID、跳过检查和残余风险呈现在 Business Acceptance 摘要与记录中，并记录用户的处理决定。
- 对三个开发 workflow 建立对称契约。

## ❌ 非范围

- 不自动关闭 review finding。
- 不把风险传递等同于风险已被接受。
- 不自动把存在风险的结果判定为接受或拒绝。
- 不重新执行最终验证；本 Story 只传递并呈现已有验证结果。

## 验收标准

1. 实施和 Review 的未闭环风险不会在进入验证时丢失。
2. 最终验证报告可按稳定 ID 追溯风险来源和当前状态。
3. 跳过检查明确影响验证结论或剩余风险，并在业务验收中保持可见。
4. 业务验收决定可以追溯到用户所见的风险集合及其处理结果。

## Story Relationships

- Superseded By：[T-005 最终验证带入限制呈现](../tasks/T-005-final-verification-carried-limitations.md)。
- Supersedes：[S-021 验证风险传递到 Business Acceptance](S-021-verification-risk-to-business-acceptance.md)。

## 依赖

- 实施和 Review 记录需提供稳定风险身份。

## Open Questions

- 无。[Q-010 跨阶段风险 ID 命名空间](../open-questions.md#q-010) 已确认不适用，因为替代任务不创建跨阶段风险 ID。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建实施与 Review 风险传递 Story。 | 防止已知风险在最终验证前断链。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 吸收 S-021，形成实施、验证到业务验收的端到端风险追溯。 | 风险传播共享同一稳定身份、记录链和验收上下文；按两个阶段跳拆卡会制造重复所有者。 |
| 3 | 2026-07-19T20:23:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 补全不重新执行最终验证的边界，并修正标题。 | 确保吸收 S-021 后仍仅负责端到端风险追溯，不与最终验证执行重叠。 |
| 3 | 2026-07-21T14:52:12+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Superseded，并将最小必要范围迁移至 T-005。 | 用户确认当前需求不需要独立风险管理模型，改由轻量 Task 处理最终验证的带入限制呈现。 |
