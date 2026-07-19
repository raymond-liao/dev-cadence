# B-015 工作项领取未在 main 持久化

## 基本信息

- ID：`B-015`
- Version：`3`
- Status：`In Progress`
- Priority：`P1`
- Change Type：Bug

## 问题目标

确保在 `worktree.enabled: true` 时，工作项领取的卡片和 Backlog 状态先在 `main` 持久化，再从该状态创建任务 worktree，使主 checkout 始终反映已领取的工作项。

## 期望行为

当 `worktree.enabled: true` 且显式实施请求选定一个工作项时，入口必须先在 `main` 原子更新卡片和 `docs/backlog.md`，并持久化该领取状态；随后任务 worktree 必须以该持久化状态为基线创建。主 checkout 中的卡片与 Backlog 不得继续显示该项为 `Draft` 或“待处理”。

## 已观察行为

本问题在 `worktree.enabled: true` 的 B-011 实施期间被发现：任务 worktree 中的 B-011 卡片与 Backlog 显示 `In Progress`，而 `main` 中同一 B-011 仍显示 `Draft` 并保留在“待处理”。B-011 仅是发现该问题的现场；B-015 的复现、范围、依赖和阻塞均不依赖 B-011 的状态或实施结果。

## ✅ 包含范围

- 仅处理 `worktree.enabled: true` 时工作项领取必须先在 `main` 原子持久化卡片和 Backlog 状态。
- 让任务 worktree 从已持久化的领取状态创建。
- 增加可验证的契约，防止领取状态仅写入新任务 worktree。
- 保持领取状态、卡片与 Backlog 的原子同步语义。

## ❌ 排除范围

- 不改变任何既有工作项的当前交付范围、状态或实施结果。
- 不判断或修改 `worktree.enabled: false` 的专用任务分支行为。
- 不改变工作项生命周期状态集合、Backlog 排序模型或 Delivery Workflow 的业务阶段。
- 不处理任务完成后的 Backlog 回写；该问题由 B-008 负责。
- 不在本 Bug 中实施修复。

## 验收标准

1. 在 `worktree.enabled: true` 时，工作项领取在创建任务 worktree 前，先在 `main` 原子持久化卡片和 Backlog 的 `In Progress` 状态。
2. 后续任务 worktree 包含该已持久化的领取状态。
3. `main` 不会在任务已领取后继续显示同一工作项为 `Draft` 或“待处理”。
4. 契约验证会拒绝在 `worktree.enabled: true` 时仅在任务 worktree 写入领取状态的实现。

## 已知复现条件

- 配置 `worktree.enabled: true`。
- 从 `docs/backlog.md` 明确要求开始实施一个工作项。
- 入口创建任务 worktree。
- 领取卡片与 Backlog 的写入发生在任务 worktree 中。
- 返回 `main` 检查时，工作项仍显示为未领取。

## Relationships

- Affects：[S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)。
- Blocks：无。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-19T16:43:14+0800 | Raymond Liao <raymond-liao@outlook.com> | 创建工作项领取未在 main 持久化 Bug 卡。 | 当前 B-011 的活跃任务分支显示已领取，而 main 仍显示同一工作项为 Draft 和待处理，暴露领取状态未先在主分支持久化。 |
| 2 | 2026-07-19T16:49:04+0800 | Raymond Liao <raymond-liao@outlook.com> | 校正 B-011 在本卡中的定位。 | B-011 仅是发现本问题的实施现场；B-015 不与 B-011 构成因果、依赖、阻塞或范围关系。 |
| 3 | 2026-07-19T16:55:23+0800 | Raymond Liao <raymond-liao@outlook.com> | 将范围收窄到已验证的 worktree 配置。 | 当前证据仅覆盖 `worktree.enabled: true`；不把专用任务分支模式或其他 workflow 入口泛化为已确认事实。 |
| 3 | 2026-07-19T19:09:45+0800 | Raymond Liao <raymond-liao@outlook.com> | 领取 B-015 并将卡片状态同步为 `In Progress`。 | 显式实施请求已选定该 Bug；领取状态必须在创建任务 worktree 前持久化到主 checkout。 |
