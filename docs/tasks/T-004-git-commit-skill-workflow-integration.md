# T-004 Git 提交阶段接入 git-commit Skill

## 基本信息

- ID：`T-004`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Workflow Governance

## 任务目标

确保 `feature-dev`、`bug-fix` 和 `refactor` 流程进入实际 Git 提交节点时，统一调用 `git-commit` skill 执行提交，使提交信息、暂存范围和敏感文件检查遵循同一套规则。

## 背景

仓库已经有 `git-commit` skill，定义了 Conventional Commit、变更分析、文件暂存和敏感文件检查规则。但三个 Delivery Workflow 的 Git Checkpoints 目前只定义了何时创建提交以及如何记录提交证据，没有明确要求在实际创建提交时调用该 skill，导致规则存在但流程不一定真正使用它。

## ✅ 范围

- 在 `feature-dev`、`bug-fix` 和 `refactor` 的 Git Checkpoints 规则中明确实际提交节点必须调用 `git-commit` skill。
- 保留各 workflow 对提交时机、提交范围、检查结果和 commit hash 记录的既有要求。
- 明确 `git-commit` skill 负责提交动作和提交信息规则，workflow 负责业务阶段与交付证据。
- 保持三个 Delivery Workflow 的接入规则对称。
- 更新必要的契约检查，并验证 source、dist 和安装包同步。

## ❌ 非范围

- 不重新设计 `git-commit` skill 的 Conventional Commit 规范。
- 不改变 workflow 的阶段顺序、用户确认门或 checkpoint 状态模型。
- 不把 merge、push、branch、worktree 或 PR 操作纳入本任务。
- 不改变实施提交的提交前审查和身份验证规则。

## 完成条件

1. 三个 Delivery Workflow 都明确要求在实际创建 Git 提交时调用 `git-commit` skill。
2. 用户请求提交和 workflow 自动创建 checkpoint commit 的接入语义没有歧义。
3. workflow 仍记录提交范围、检查结果和 commit hash，`git-commit` skill 不取代交付证据。
4. 契约检查验证三个 workflow 的规则对称且 source、dist、安装包保持同步。
5. 空白检查和完整契约验证通过。

## Task Relationships

- Related：[`S-017 工作项卡片与开发 Workflow 接入`](../stories/S-017-work-item-development-workflow-integration.md)。
- Follows：[`T-003 Executing-Plans 实施提交前审查`](T-003-executing-plans-pre-commit-review.md)。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无。

## 相关文档

- [`S-017 工作项卡片与开发 Workflow 接入`](../stories/S-017-work-item-development-workflow-integration.md)
- [`T-003 Executing-Plans 实施提交前审查`](T-003-executing-plans-pre-commit-review.md)
- [`工作项规划流程`](../workflows/work-item-planning.md)
- [`Backlog`](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-17 | 创建 Git 提交 skill 接入任务。 | 确保流程进入提交节点时真正使用统一的提交规则。 |
