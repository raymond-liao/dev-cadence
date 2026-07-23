# S-022 Bug `not-a-bug` 终态

## 基本信息

- ID：`S-022`
- Version：`1`
- Status：`Dropped`
- Priority：`P1`
- Change Type：Feature

## 目标

让已确认并非缺陷的问题能够结束 bug-fix run，并保存判断依据、用户确认和非 `pending` 的终态 manifest。

## 背景

诊断可能确认报告行为符合预期、属于需求变更或无法成立为缺陷。缺少专用终态会让 run 长期停留在待处理状态，或被迫伪装成已修复。

## ✅ 范围

- 定义 `not-a-bug` 判断所需证据和用户确认。
- 记录实际行为为何不构成既有预期偏差。
- 将 manifest 更新为明确的非 `pending` 终态。
- 指明需求变更等后续请求应路由到的流程。

## ❌ 非范围

- 不把根因未知或证据不足的问题标记为 `not-a-bug`。
- 不在该路径实施行为变更。
- 不把用户取消修复等同于 `not-a-bug`。

## 验收标准

1. 已确认非缺陷的问题能够正常结束 bug-fix run。
2. 终态记录包含判断依据和明确用户确认。
3. 证据不足的问题继续诊断或阻塞，不会错误关闭。

## 依赖

- Bug 诊断阶段能够形成明确的问题判断。

## Story Relationships

- 后续工作项：[S-024 Bug 诊断门禁](S-024-bug-diagnosis-gate.md) 已停止；本卡不恢复为独立交付项。

## 处置

本卡曾并入 S-024 的诊断门禁。S-024 已停止，本卡也不再作为独立交付项实施。

## Open Questions

- [Q-011 Bug 非缺陷终态命名](../open-questions.md#q-011) 已随 S-024 停止而标记为 `Invalid`。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Bug `not-a-bug` 终态 Story。 | 避免非缺陷调查停留在 `pending` 或伪装为已修复。 |
| 1 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Superseded，并将职责迁移至 S-024。 | 非缺陷判断与确认缺陷、证据不足共同构成诊断门禁的结果模型。 |
| 1 | 2026-07-21T14:44:22+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Dropped。 | S-024 已停止，且用户确认不恢复本卡为独立交付项。 |
