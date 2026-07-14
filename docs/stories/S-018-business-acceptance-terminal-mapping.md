# S-018 Business Acceptance 终态映射

## 基本信息

- ID：`S-018`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Feature

## 目标

让三个开发 workflow 的 `accepted`、`accepted_with_risk` 和 `rejected` 分别进入明确的 Completion 路径。

## 背景

业务验收决策如果没有明确映射到 manifest 终态和后续动作，run 可能停留在不一致状态，或将带风险接受和拒绝错误地当作普通完成。

## ✅ 范围

- 定义三个验收决策各自允许的 Completion 路径。
- 明确每种决策对应的 manifest 终态和后续动作。
- 记录 `accepted_with_risk` 的风险引用和责任。
- 用对称契约测试覆盖三个开发 workflow。

## ❌ 非范围

- 不改变业务验收决策枚举。
- 不自动替用户选择验收结果。
- 不在本 Story 中处理 manual recovery 或 `not-a-bug` 终态。

## 验收标准

1. 三种业务验收决策都具有明确且互不混淆的 Completion 行为。
2. manifest 终态与验收记录保持一致。
3. `rejected` 不会被报告为成功完成，`accepted_with_risk` 不会丢失风险。

## 依赖

- 最终验证和业务验收记录契约保持可用。

## Open Questions

- `rejected` 应返回返工阶段还是进入独立关闭终态，是否需要按原因区分？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 Business Acceptance 终态映射 Story。 | 闭环验收决策、manifest 终态和后续动作。 |
