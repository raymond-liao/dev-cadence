# S-036 最小验证阶段门禁

## 基本信息

- ID：`S-036`
- Version：`1`
- Status：`Done`
- Priority：`P2`
- Change Type：Feature

## 目标

为 Feature、Bug Fix 和 Refactor 增加对称的最终验证决策门禁，阻止缺少必要证据或存在阻塞失败的 run 进入 Business Acceptance。

## 背景

最终验证如果没有统一决策值，失败、缺少必要证据和非阻塞风险可能被混合处理。三个 workflow 需要使用一致的 `ready`、`ready_with_risk` 和 `not_ready` 语义，并在 `not_ready` 时返回最早受影响阶段。

## ✅ 范围

- 在三个开发 workflow 的最终验证阶段增加 `Verification Decision Gate`。
- 定义 `ready`、`ready_with_risk` 和 `not_ready`。
- 只允许 `ready` 和 `ready_with_risk` 进入 Business Acceptance。
- 必要验收证据缺失、原 Bug 仍可复现、行为漂移或结构目标未满足时使用 `not_ready`。
- `not_ready` 时记录阻塞证据，返回最早受影响阶段并使后续阶段重新进入待处理状态。
- 用对称契约测试验证三个 workflow 的门禁和报告字段。

## ❌ 非范围

- 不实现最终验证版本绑定。
- 不实现风险稳定 ID 的跨阶段传递。
- 不实现 Business Acceptance 终态映射。

## 验收标准

1. 三个 workflow 使用相同的最终验证决策集合和进入验收门禁。
2. 缺少必要执行证据或存在阻塞失败时不能使用 `ready_with_risk` 绕过。
3. `not_ready` 明确返回最早受影响阶段并失效后续当前证据。
4. 最终验证报告记录规范化的 `Verification Decision`。

## 依赖

- 无强制前置依赖。

## 历史交付证据

- Implementation Commit：`4dbbb6a6f1fab7c60d79147528468ec8db55bfb4`。
- 主要修改：三个开发 workflow skill 和 `tests/workflow-symmetry.sh`。
- 实施计划：`docs/superpowers/plans/2026-07-13-minimal-workflow-stage-gate.md`。
- 版本在该提交中完成更新。

## Open Questions

- 无。

## 相关文档

- [最小验证阶段门禁实施计划](../superpowers/plans/2026-07-13-minimal-workflow-stage-gate.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 根据既有实现、计划和 Git 历史补录已完成 Story。 | 原能力已在 `4dbbb6a` 完成交付，但 Backlog 仅保留纯文本完成项。 |
