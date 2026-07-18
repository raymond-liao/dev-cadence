# S-031 保存 Worktree 运行记录

## 基本信息

- ID：`S-031`
- Version：`1`
- Status：`Draft`
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

- `S-030` Worktree 所有权识别。

## Open Questions

- Q-018：多 worktree 并行运行时，保存目录如何避免任务 slug 冲突？

## 相关文档

- [S-030 Worktree 所有权识别](S-030-worktree-ownership-detection.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建保存 Worktree 运行记录 Story。 | 防止工作区清理造成不可恢复的交付记录丢失。 |
