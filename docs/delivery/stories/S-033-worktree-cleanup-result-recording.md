# S-033 Worktree 清理结果记录

## 基本信息

- ID：`S-033`
- Version：`1`
- Status：`Superseded`
- Priority：`P1`
- Change Type：Feature

## 目标

在 Completion 后持久化记录 worktree 和 task branch 的实际清理结果，使交付记录能够说明工作区由谁管理以及最终保留状态。

## 背景

现有 Completion 路径可能执行或跳过 worktree 与分支清理，但 manifest 和业务验收记录没有统一保存最终结果，后续无法可靠判断资源是否仍存在或由谁负责。

## ✅ 范围

- 在 manifest 和业务验收记录中写明 worktree 是否删除或保留。
- 记录 worktree 的管理方和清理责任。
- 记录 task branch 是否删除或保留。
- 覆盖三个开发 workflow 的对称 Completion 契约。

## ❌ 非范围

- 不定义 worktree 所有权识别算法。
- 不实现记录迁移或 worktree 删除前的记录保存。
- 不修改具体 merge 或 discard 命令。

## 验收标准

1. 三个 workflow 的 Completion 记录包含统一的 worktree、管理方和 task branch 结果字段。
2. 保留、删除和不适用场景都有明确值，不能只依赖命令输出。
3. manifest 与业务验收记录对同一次清理结果保持一致。

## 依赖

- `S-030` Worktree 清理安全与证据。
- `S-031` 保存 Worktree 运行记录。

## Story Relationships

- Superseded By：[S-030 Worktree 清理安全与证据](S-030-worktree-ownership-detection.md)。

## 处置

本卡的 Completion 清理结果记录已并入 S-030 的 worktree 清理安全链，不再作为独立交付项实施。

## Open Questions

- 无。

## 相关文档

- [S-030 Worktree 清理安全与证据](S-030-worktree-ownership-detection.md)
- [S-031 保存 Worktree 运行记录](S-031-preserve-worktree-run-records.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Worktree 清理结果记录 Story。 | 将 Completion 后的实际资源状态纳入持久化交付证据。 |
| 1 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Superseded，并将职责迁移至 S-030。 | 清理结果依赖同一所有权证据和记录保存前置条件，独立卡片会割裂一次 Completion 操作。 |
