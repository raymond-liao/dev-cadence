# S-030 Worktree 清理安全与证据

## 基本信息

- ID：`S-030`
- Version：`4`
- Status：`Ready`
- Priority：`P0`
- Change Type：Feature

## 目标

以可验证的创建来源保护 worktree 清理：只允许 Dev Cadence 清理由本次运行创建且已验证的 worktree。

## 背景

仅依赖目录名称或路径约定判断所有权会误删外部管理的工作区，也会漏掉使用自定义目录创建的 Dev Cadence worktree。删除前必须以本次运行的创建证据和当前 Git worktree 身份验证所有权。

## 用户、场景与价值

- 角色：执行 Dev Cadence Completion 的目标仓库维护者。
- 场景：维护者选择删除 task worktree 时，Dev Cadence 必须先判定该 worktree 是否由当前运行创建。
- 价值：防止误删外部或来源不明的工作区，同时允许安全清理由 Dev Cadence 创建的工作区。

## ✅ 范围

- 将当前运行的 worktree 创建证据保存在 run manifest 中，并记录 workspace 相对路径、task branch 和 Git 身份。
- 清理前将 manifest 中的创建证据与 `git worktree list --porcelain` 的路径、branch 和 Git 身份逐项比对；不得以目录名称或路径约定代替该验证。
- 支持 `.dev-cadence.yaml` 配置的自定义 worktree 目录。
- 对证据缺失或冲突的工作区采用保守处理并要求明确确认。
- 仅在验证为 Dev Cadence 为当前运行创建的 worktree 后，允许进入既有删除路径。

## ❌ 非范围

- 不自动接管历史上来源不明的 worktree。
- 不改变外部管理 worktree 的清理责任。
- 不保存、复制、迁移或归档 manifest、stage record 或其他 active run record；删除 Dev Cadence-owned worktree 时，这些源记录可随 worktree 一并删除。
- 不创建 cleanup、audit 或资源结果的持久化记录，也不要求 manifest 或业务验收记录写入清理结果字段。
- 不修改具体 merge 或 discard 命令。
- 不定义 detached HEAD 的完整 Finishing 路径。

## 可观察行为与业务规则

- run manifest 是当前运行 worktree 创建证据的权威来源；配置派生路径和独立元数据不是所有权证据。
- 当 manifest 创建证据缺失，或与当前 Git worktree 的路径、branch 或 Git 身份冲突时，Dev Cadence 不得删除该 worktree；必须保持工作区并返回既有阻断或确认路径。
- 自定义 worktree 目录不得改变验证规则。
- 外部管理、历史来源不明或无法验证为当前运行创建的 worktree 不属于 Dev Cadence 删除范围。
- 本 Story 不产生任何清理后运行记录。该规则同时适用于正常 Completion 和 `whole-run discard`。

## 验收标准

1. Dev Cadence 是否可删除 worktree 由当前运行的 manifest 创建证据与当前 Git worktree 身份的一致性决定，而非目录名称或路径约定。
2. manifest 证据和 `git worktree list --porcelain` 的路径、branch 或 Git 身份任一缺失或冲突时，不会删除该 worktree，并进入既有阻断或明确确认路径。
3. 自定义 worktree 目录不会破坏所有权识别。
4. 外部管理、历史来源不明或无法验证为当前运行创建的 worktree 不会被 Dev Cadence 删除。
5. 正常 Completion 和 `whole-run discard` 都不会归档 active run records 或创建 cleanup/audit 记录；删除 Dev Cadence-owned worktree 时，源记录可随该 worktree 删除。

## 历史关系

- [S-031 保存 Worktree 运行记录](S-031-preserve-worktree-run-records.md) 和 [S-033 Worktree 清理结果记录](S-033-worktree-cleanup-result-recording.md) 曾合并至本卡。当前已确认范围明确排除记录保存和清理结果记录，不实现这两项职责。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无开发阻塞问题。Q-017 已确认由 run manifest 保存创建证据；Q-018 因本卡不归档运行记录而失效。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Worktree 所有权识别 Story。 | 以创建来源替代不可靠的目录命名推断，降低误删风险。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 吸收 S-031 和 S-033，形成 worktree 清理前、中、后的安全与证据闭环。 | 所有权、记录保存和结果记录属于同一次 Completion 清理操作，拆分会产生顺序依赖和重复所有者。 |
| 3 | 2026-07-19T20:23:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 补全记录集合、稳定位置、完整性验证、恢复信息、统一结果值和清理边界。 | 完整保留 S-031 和 S-033 的删除安全与交付证据契约。 |
| 4 | 2026-07-20T20:21:54+0800 | Raymond Liao <raymond-liao@outlook.com> | 将范围收敛为删除前的 worktree 所有权验证，并将状态更新为 Ready。 | 用户确认不在任何 Completion 或 discard 路径归档运行记录或持久化清理结果；manifest 创建证据与 Git 身份比对足以界定交付范围。 |
