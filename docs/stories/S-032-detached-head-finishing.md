# S-032 Detached HEAD Finishing

## 基本信息

- ID：`S-032`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Feature

## 目标

为外部管理的 detached HEAD 工作区定义可完成的 Finishing 路径，避免错误假定当前存在可 push 或可删除的命名分支。

## 背景

部分执行环境以 detached HEAD 提供隔离工作区。现有分支导向的 Completion 假设在这种环境中不成立，可能导致无法创建 PR、错误清理或丢失交付引用。

## ✅ 范围

- 识别外部管理的 detached HEAD 环境。
- 定义创建分支、创建 PR、保留和 discard 路径。
- 为每条路径规定必要确认、Git 身份和结果验证。
- 保持三个开发 workflow 的 Finishing 规则对称。

## ❌ 非范围

- 不改变普通 checkout 或命名 worktree 的既有路径。
- 不接管外部工具负责的 worktree 生命周期。
- 不自动假定 detached HEAD 可以直接 push 或删除分支。

## 验收标准

1. detached HEAD 不再被当作普通命名分支处理。
2. 创建分支、PR、保留和 discard 均有明确前置条件与验证结果。
3. Completion 记录保存最终 commit、分支选择和管理边界。

## 依赖

- 无强制前置依赖。

## Open Questions

- Q-019：外部环境是否需要提供可持久化的 workspace identity？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Detached HEAD Finishing Story。 | 为外部管理隔离环境补齐可验证的完成路径。 |
