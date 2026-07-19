# S-031 保存 Worktree 运行记录

## 基本信息

- ID：`S-031`
- Version：`1`
- Status：`Superseded`
- Priority：`P0`
- Change Type：Feature

## 目标

在删除 Dev Cadence 所有的 worktree 前，将必须保留的 manifest 和 stage record 保存到不会随 worktree 删除的位置，并验证记录仍可访问。

## 背景

当运行记录位于即将删除的 worktree 内时，清理动作会同时删除交付审计证据。Completion 必须先完成记录保存和可访问性验证，再允许删除工作区。

## ✅ 范围

- 定义必须保留的 manifest 和 stage record 集合。
- 定义目标仓库内不会随 worktree 删除的保存位置。
- 在删除前复制或迁移记录并验证完整性与可访问性。
- 在 Completion 记录中保存原位置、目标位置和验证结果。

## ❌ 非范围

- 不改变外部管理 worktree 的清理责任。
- 不以 `.superpowers/` 或本地服务状态替代正式记录。
- 不在本 Story 中定义 worktree 所有权识别。

## 验收标准

1. Dev Cadence 所有的 worktree 不会在正式记录仍仅存在于其目录内时被删除。
2. 保存后的 manifest 和 stage record 可从目标仓库稳定访问。
3. 保存失败会阻止删除并产生明确的恢复信息。

## 依赖

- `S-030` Worktree 清理安全与证据。

## Story Relationships

- Superseded By：[S-030 Worktree 清理安全与证据](S-030-worktree-ownership-detection.md)。

## 处置

本卡的记录保存与可访问性验证已并入 S-030 的 worktree 清理安全链，不再作为独立交付项实施。

## Open Questions

- [Q-018 并行 worktree 的记录保存路径](../open-questions.md#q-018) 已迁移至 S-030。

## 相关文档

- [S-030 Worktree 清理安全与证据](S-030-worktree-ownership-detection.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建保存 Worktree 运行记录 Story。 | 防止工作区清理造成不可恢复的交付记录丢失。 |
| 1 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Superseded，并将职责迁移至 S-030。 | 记录保存是同一次清理操作的前置安全条件，应与所有权和清理结果统一维护。 |
