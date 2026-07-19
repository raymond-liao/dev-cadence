# S-030 Worktree 清理安全与证据

## 基本信息

- ID：`S-030`
- Version：`3`
- Status：`Draft`
- Priority：`P0`
- Change Type：Feature

## 目标

以可验证的创建来源保护 worktree 清理：判断所有权、在删除前保存运行记录，并持久化最终资源结果。

## 背景

仅依赖目录名称或路径约定判断所有权会误删外部管理的工作区，也会漏掉使用自定义目录创建的 Dev Cadence worktree。若运行记录仍只存在于待删除工作区，清理还会破坏交付审计证据；清理结果不被持久化则无法判断资源和责任归属。

## ✅ 范围

- 定义 Dev Cadence 创建 worktree 时必须保存的所有权证据。
- 清理时使用创建来源而不是目录名称判断所有权。
- 支持 `.dev-cadence.yaml` 配置的自定义 worktree 目录。
- 对证据缺失或冲突的工作区采用保守处理并要求明确确认。
- 定义删除 Dev Cadence 所有的 worktree 前必须保留的 manifest 和 stage record 集合，以及目标仓库内不会随 worktree 删除的稳定保存位置。
- 删除前复制或迁移必须保留的记录，验证其完整性与可访问性，并在 Completion 记录中保存原位置、目标位置和验证结果。
- 在 manifest 和业务验收记录中使用统一字段，写明 worktree、管理方、清理责任和 task branch 的实际结果；保留、删除和不适用场景都必须具有明确值。

## ❌ 非范围

- 不自动接管历史上来源不明的 worktree。
- 不改变外部管理 worktree 的清理责任。
- 不以 `.superpowers/` 或本地服务状态替代正式运行记录。
- 不修改具体 merge 或 discard 命令。
- 不定义 detached HEAD 的完整 Finishing 路径。

## 验收标准

1. worktree 是否可由 Dev Cadence 清理由创建来源决定。
2. 自定义 worktree 目录不会破坏所有权识别。
3. 来源不明时不会执行未经确认的删除。
4. Dev Cadence 所有的 worktree 不会在正式记录仍仅存在于其中时被删除；保存失败会阻止删除并产生明确的恢复信息。
5. 保存后的 manifest 和 stage record 可从目标仓库的稳定位置访问，Completion 记录可追溯原位置、目标位置和验证结果。
6. 三个 workflow 的 manifest 与业务验收记录使用统一字段，一致说明 worktree 的管理方、清理责任、清理结果和 task branch 的最终状态，并显式覆盖保留、删除和不适用场景。

## Story Relationships

- Supersedes：[S-031 保存 Worktree 运行记录](S-031-preserve-worktree-run-records.md) 和 [S-033 Worktree 清理结果记录](S-033-worktree-cleanup-result-recording.md)。

## 依赖

- 无强制前置依赖。

## Open Questions

- [Q-017 Worktree 所有权证据位置](../open-questions.md#q-017)：所有权证据应保存在 manifest、配置派生记录还是独立元数据中？
- [Q-018 并行 worktree 的记录保存路径](../open-questions.md#q-018)：多 worktree 并行运行时，保存目录如何避免任务 slug 冲突？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Worktree 所有权识别 Story。 | 以创建来源替代不可靠的目录命名推断，降低误删风险。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 吸收 S-031 和 S-033，形成 worktree 清理前、中、后的安全与证据闭环。 | 所有权、记录保存和结果记录属于同一次 Completion 清理操作，拆分会产生顺序依赖和重复所有者。 |
| 3 | 2026-07-19T20:23:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 补全记录集合、稳定位置、完整性验证、恢复信息、统一结果值和清理边界。 | 完整保留 S-031 和 S-033 的删除安全与交付证据契约。 |
