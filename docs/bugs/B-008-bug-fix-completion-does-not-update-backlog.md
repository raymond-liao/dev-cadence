# B-008 Bug Fix 完成后未更新 Backlog

## 基本信息

- ID：`B-008`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Bug

## 问题目标

修复 Bug Fix Delivery Workflow 在完成业务验收和 Completion 后未同步更新 Backlog 汇总状态的问题，避免已完成的 Bug 仍显示为待处理。

## 预期行为

当 Bug Fix 完成 Business Acceptance 和用户选择的 Completion 集成动作后，系统应将对应 Bug 在 Backlog 中的汇总状态更新为 `Done`，并将其从“待处理”移动到“已完成”。

## 已观察行为

Bug Fix 流程可以完成实现、验证、业务验收和本地集成，但对应 Bug 在 `docs/backlog.md` 中仍保留 `Draft` 状态和“待处理”位置，需要人工修正。

## ✅ 范围

- 覆盖 `bug-fix` workflow 的完成后 Backlog 状态与位置同步。
- 保持 Bug 卡片与 Backlog 汇总状态一致。
- 覆盖本地合并、保留分支和其他保留运行记录的 Completion 路径中适用的 Backlog 更新时机。
- 为状态同步添加可验证的规则或契约证据。

## ❌ 非范围

- 不改变 Business Acceptance 的用户决策门。
- 不把 workflow 内部阶段映射为新的 Backlog 状态。
- 不修改 `feature-dev` 或 `refactor` 的 Backlog 同步行为，除非后续诊断证明存在同一缺陷并获得单独范围确认。
- 不自动重排无关的 Backlog 工作项。

## 验收标准

1. 完成并集成的 Bug Fix 会将对应 Backlog 条目更新为 `Done` 并移动到“已完成”。
2. Completion 未完成、被取消、被阻塞或 whole-run Discard 后，不会错误写入不存在或未完成的 Backlog 状态。
3. Bug 卡片与 Backlog 汇总状态不再出现已交付但仍为 `Draft` 的矛盾。
4. 变更具有可重复运行的验证证据。

## 已知复现条件

- 完成任一 Bug Fix 的业务验收与 Completion 集成后，检查 `docs/backlog.md` 中对应 Bug 条目。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)
- [B-002 Delivery Workflow Discard 整体运行删除安全性](B-002-normal-checkout-discard-safety.md)
- [B-006 Delivery 记录证据完整性](B-006-delivery-record-evidence-completeness.md)

## Relationships

- Affected workflow: `bug-fix`.
- Related Bugs: `B-002`, `B-006`.

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-18T06:54:19+0800 | Raymond Liao <raymond-liao@outlook.com> | 创建 Bug 卡片。 | 用户发现 Bug Fix 跑完后未更新 Backlog。 |
