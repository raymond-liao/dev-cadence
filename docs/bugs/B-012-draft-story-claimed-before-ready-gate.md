# B-012 Draft Story 在 Ready 门禁前被提前领取

## 基本信息

- ID：`B-012`
- Version：`1`
- Status：`In Progress`
- Priority：`P1`
- Change Type：Bug

## 问题目标

确保 Draft Story 在进入 Work Item Analysis 并经用户确认达到 `Ready` 前不会被领取为 `In Progress`，使卡片成熟度、Backlog 投影和 Delivery Workflow 入口资格保持一致。

## 期望行为

用户明确要求实施一个 `Draft` Story 时，入口必须先执行 `Draft Story -> work-item-analysis -> user-confirmed Ready Story`。Work Item Analysis 期间不得领取卡片或把 Backlog 行改为 `In Progress`。只有 Story 定义经用户确认并原子更新为 `Ready` 后，新的或继续中的实施请求才能领取该 Story，并在准备任务工作区后进入 `feature-dev`。

## 已观察行为

当前入口同时存在“选中工作项后领取为 `In Progress`”和“`Draft Story -> work-item-analysis -> Ready Story -> feature-dev`”两条规则，但没有规定成熟度路由必须先于领取判断。现有契约测试只分别检查两条文本存在，不验证严格顺序。代理因此可能在识别到显式实施意图后直接把 Draft Story 和 Backlog 行更新为 `In Progress`，随后才发现 Story 尚未满足 `Ready` 门禁。

## ✅ 包含范围

- 明确工作项类型和成熟度路由先于领取资格判断。
- 对 Draft Story 先执行 Work Item Analysis，并在用户确认前保持卡片与 Backlog 状态不变。
- 只有 user-confirmed `Ready Story` 才能被领取为 `In Progress` 并进入 `feature-dev`。
- 保持 Task 和 Bug 的既有非统一门禁，不把 Story Ready 规则机械复制给其他类型。
- 增加顺序敏感的契约验证，覆盖 Draft Story、Ready Story、Task 和 Bug 路由。
- 保持 source、dist、安装包和相关入口规则同步。

## ❌ 排除范围

- 不改变 Work Item Analysis 对 Story 定义和 Ready 决策的所有权。
- 不要求 Task 或 Bug 达到 `Ready` 才能进入其允许的下游 Workflow。
- 不改变领取后的 branch/worktree 准备时点；该问题由 B-011 负责。
- 不修改卡片 Version 与 Change Log 的执行状态写回语义。
- 不自动修复已经被错误提前领取的历史卡片。

## 验收标准

1. 入口在任何领取写入前先解析工作项类型、当前状态和成熟度路由。
2. Draft Story 进入 Work Item Analysis 时，卡片和 Backlog 不变为 `In Progress`。
3. Work Item Analysis 只有在用户确认完整定义后才把 Story 更新为 `Ready`，该更新不等同于领取。
4. 只有 user-confirmed `Ready Story` 能被后续实施请求领取并进入 `feature-dev`。
5. Task 和 Bug 继续使用各自明确的非统一门禁。
6. 自动化契约测试会在“claim 规则”和“Draft -> Ready 路由”分别存在但执行顺序错误时失败。
7. source、dist、安装包和根目录版本保持同步。

## 已知复现条件

- Backlog 首项是 Status `Draft` 的 Story。
- 用户明确要求开始实施该 Story。
- 入口先按实施意图执行领取，再检查 Story 成熟度。
- 卡片与 Backlog 被更新为 `In Progress`，但 Story 从未经过用户确认达到 `Ready`。

## Relationships

- Affects：[S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)。
- Related：[S-037 工作项分析 Workflow](../stories/S-037-work-item-analysis-workflow.md)。
- Related：[B-011 领卡后未立即准备配置要求的 worktree](B-011-worktree-preparation-delayed-after-claim.md)。
- Blocks：无。

## Open Questions

- 无。

## 相关文档

- [S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)
- [S-037 工作项分析 Workflow](../stories/S-037-work-item-analysis-workflow.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-19T11:15:39+0800 | Raymond Liao <raymond-liao@outlook.com> | 创建 Draft Story 提前领取 Bug 卡。 | S-041 启动过程证明，当前入口可以在 Story 经过 Work Item Analysis 并确认为 Ready 前把卡片与 Backlog 提前更新为 In Progress。 |
| 1 | 2026-07-19T15:03:31+08:00 | Raymond Liao <raymond-liao@outlook.com> | 将状态更新为 `In Progress`。 | 用户明确要求同时并行修复 B-012、B-010 和 B-014；本次只改变执行状态，不改变卡片定义。 |
