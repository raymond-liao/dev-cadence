# S-032 Detached HEAD Finishing

## 基本信息

- ID：`S-032`
- Version：`2`
- Status：`Draft`
- Priority：`P1`
- Change Type：Feature

## 目标

补齐外部管理 detached HEAD 工作区的 Finishing 执行路径，使菜单选项、分支创建、PR、保留和 discard 的实际行为保持一致。

## 背景

部分执行环境以 detached HEAD 提供隔离工作区。现有规则已区分该菜单，但执行步骤仍沿用命名分支的本地 merge 假设，可能导致无法创建 PR、错误清理或丢失交付引用。

## ✅ 范围

- 识别外部管理的 detached HEAD 环境。
- 定义创建分支、创建 PR、保留和 discard 路径。
- 为每条路径规定必要确认、Git 身份和结果验证。
- 保持三个开发 workflow 的 Finishing 规则对称。
- 确保 detached HEAD 菜单的每一个选项均映射到适用的执行步骤，而不是复用命名分支的 merge 路径。

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
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 收敛为修复并验证现有 detached HEAD Finishing 规则的菜单与执行断链。 | 当前规则已具备环境识别和菜单，剩余工作是让每个选项拥有一致、可执行的后续路径。 |
