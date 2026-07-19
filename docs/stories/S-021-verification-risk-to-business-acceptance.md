# S-021 验证风险传递到 Business Acceptance

## 基本信息

- ID：`S-021`
- Version：`1`
- Status：`Superseded`
- Priority：`P2`
- Change Type：Feature

## 目标

确保最终验证报告中仍未解决的稳定 ID、跳过检查和剩余风险全部进入业务验收摘要与记录。

## 背景

业务验收只有看到完整的验证限制和剩余风险，才能做出 `accepted`、`accepted_with_risk` 或 `rejected` 决策。跨阶段丢失风险会使验收结论缺少必要上下文。

## ✅ 范围

- 从最终验证报告读取未解决稳定 ID、跳过检查和剩余风险。
- 在业务验收摘要和持久化记录中完整呈现这些内容。
- 记录用户对每项风险的接受、拒绝或后续处理决定。
- 对三个开发 workflow 建立对称契约测试。

## ❌ 非范围

- 不重新执行最终验证。
- 不自动把存在风险的结果判定为接受或拒绝。
- 不在本 Story 中定义风险进入验证阶段的来源契约。

## 验收标准

1. 最终验证中的所有未解决风险都能在业务验收中追溯。
2. 跳过检查不会从验收摘要中消失。
3. 用户验收决定明确关联到所见风险集合。

## 依赖

- 最终验证报告需使用稳定风险 ID。

## Story Relationships

- Superseded By：[S-020 实施、验证与 Business Acceptance 风险追溯](S-020-implementation-review-risk-to-verification.md)。

## 处置

本卡的验证到业务验收风险传递已并入 S-020 的端到端风险追溯范围，不再作为独立交付项实施。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建验证风险传递 Story。 | 保证业务验收基于完整、可追溯的最终验证风险。 |
| 1 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Superseded，并将职责迁移至 S-020。 | 风险从实施、验证到验收属于同一证据链，独立卡片会形成重复所有者。 |
| 1 | 2026-07-19T20:23:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 更正 Open Questions 中的 Q-010 迁移记录。 | Q-010 原本就由 S-020 拥有，未从本卡迁移。 |
