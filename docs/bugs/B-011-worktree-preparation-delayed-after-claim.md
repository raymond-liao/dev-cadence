# B-011 领卡后未立即准备配置要求的 worktree

## 基本信息

- ID：`B-011`
- Version：`1`
- Status：`In Progress`
- Priority：`P1`
- Change Type：Bug

## 问题目标

确保入口完成工作项领取后，按照仓库配置立即准备专用 branch 或 worktree，再把任务交给下游 Delivery Workflow，避免早期阶段在主 checkout 占用任务分支并产生运行记录。

## 期望行为

当显式实施请求触发工作项领取时，入口先原子同步卡片与 Backlog 为 `In Progress`。领取成功后，如果 `worktree.enabled: true`，入口必须立即创建或验证配置指定目录中的任务 worktree；如果 `worktree.enabled: false`，入口必须立即准备专用任务分支。只有选定工作区准备完成后，才能进入下游 Delivery Workflow 及其 Requirements、Solution、Plan、checkpoint 或实现阶段。

## 已观察行为

当前入口只规定领取必须早于 branch/worktree，却没有要求在进入下游 Workflow 前立即完成工作区准备。Feature Dev、Bug Fix 和 Refactor 又把 `using-git-worktrees` 放在各自的 Plan 阶段，同时早期阶段 checkpoint 要求先进入专用分支。结果是配置已启用 worktree 时，代理仍可能先在主 checkout 创建并占用任务分支，写入 Requirements 或 Solution 记录并提交 checkpoint，直到 Plan 阶段才尝试创建 worktree。

## ✅ 包含范围

- 明确入口在领取成功后、进入下游 Delivery Workflow 前准备配置选定的 branch/worktree。
- `worktree.enabled: true` 时立即创建或验证隔离 worktree；`false` 时使用专用任务分支。
- 让 Delivery Workflow 的早期阶段记录和 checkpoint 从一开始就在选定工作区中执行。
- 调整 Feature Dev、Bug Fix 和 Refactor 对 `using-git-worktrees` 的调用边界，使 Plan 阶段验证既有隔离工作区而不是首次延迟创建。
- 增加端到端契约验证，覆盖 `claim -> workspace preparation -> downstream workflow` 的严格顺序。
- 保持 source、dist、安装包和三个 Delivery Workflow 的对称契约同步。

## ❌ 排除范围

- 不改变卡片与 Backlog 的原子领取语义。
- 不改变 `worktree.enabled: false` 时允许专用任务分支的配置语义。
- 不重新设计 worktree 所有权识别、运行记录保存或 Completion 清理规则。
- 不修改 Delivery Workflow 的业务阶段、确认门或 Business Acceptance 语义。
- 不在本 Bug 中处理 Draft Story 的 Ready 门禁；该问题由 B-012 负责。

## 验收标准

1. 入口明确要求领取成功后立即准备配置选定的任务 branch/worktree，并在完成前阻止下游 Workflow 启动。
2. `worktree.enabled: true` 时，Requirements、Solution、Plan、checkpoint 和实现均在任务 worktree 中执行。
3. `worktree.enabled: false` 时，入口准备专用任务分支，不创建 worktree。
4. Plan 阶段不会成为启用 worktree 时首次创建隔离工作区的时点，只验证或复用入口已准备的工作区。
5. Feature Dev、Bug Fix 和 Refactor 使用对称的工作区准备契约。
6. 自动化契约测试会在只保证“claim 早于 worktree”但允许中间进入下游 Workflow 时失败。
7. source、dist、安装包和根目录版本保持同步。

## 已知复现条件

- 目标仓库配置 `worktree.enabled: true`。
- 用户从 Backlog 明确要求开始实施一个工作项。
- 入口完成领取后进入 Feature Dev Requirements Confirmation。
- 早期 checkpoint 规则在主 checkout 创建并占用任务分支，而 worktree 尚未创建。

## Relationships

- Affects：[S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)。
- Related：[B-012 Draft Story 在 Ready 门禁前被提前领取](B-012-draft-story-claimed-before-ready-gate.md)。
- Blocks：无。

## Open Questions

- 无。

## 相关文档

- [S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-19T11:15:39+0800 | Raymond Liao <raymond-liao@outlook.com> | 创建领卡后工作区准备时点 Bug 卡。 | S-041 启动过程证明，当前规则允许启用 worktree 时先在主 checkout 创建任务分支和早期 checkpoint，再把 worktree 延迟到 Plan 阶段。 |
