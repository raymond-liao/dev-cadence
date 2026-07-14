# S-030 Worktree 所有权识别

## 基本信息

- ID：`S-030`
- Version：`1`
- Status：`Draft`
- Priority：`P0`
- Change Type：Feature

## 目标

使用可验证的创建来源判断 worktree 清理所有权，并支持 `.dev-cadence.yaml` 配置的自定义 worktree 目录。

## 背景

仅依赖目录名称或路径约定判断所有权会误删外部管理的工作区，也会漏掉使用自定义目录创建的 Dev Cadence worktree。清理决策必须基于创建来源和明确配置。

## ✅ 范围

- 定义 Dev Cadence 创建 worktree 时必须保存的所有权证据。
- 清理时使用创建来源而不是目录名称判断所有权。
- 支持 `.dev-cadence.yaml` 配置的自定义 worktree 目录。
- 对证据缺失或冲突的工作区采用保守处理并要求明确确认。

## ❌ 非范围

- 不自动接管历史上来源不明的 worktree。
- 不在本 Story 中保存即将删除的运行记录。
- 不定义 detached HEAD 的完整 Finishing 路径。

## 验收标准

1. worktree 是否可由 Dev Cadence 清理由创建来源决定。
2. 自定义 worktree 目录不会破坏所有权识别。
3. 来源不明时不会执行未经确认的删除。

## 依赖

- 无强制前置依赖。

## Open Questions

- 所有权证据应保存在 manifest、配置派生记录还是独立元数据中？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 Worktree 所有权识别 Story。 | 以创建来源替代不可靠的目录命名推断，降低误删风险。 |
