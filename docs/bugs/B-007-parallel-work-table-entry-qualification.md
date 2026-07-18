# B-007 当前可并行实施表混用卡片状态与流程入口资格

## 基本信息

- ID：`B-007`
- Version：`2`
- Status：`Draft`
- Priority：`P1`
- Change Type：Bug

## 问题目标

修正“当前可并行实施表”把工作项卡片生命周期状态、依赖可用性和下游 Workflow 入口资格混为一个 `状态` 字段的问题，避免用户误判 Draft 工作项是否可以启动对应流程。

## 预期行为

并行实施视图应保留工作项卡片的规范状态，并在表级说明中明确 `状态` 只表达卡片生命周期，不表达下游 Workflow 入口资格。具体路由和门禁由 `using-dev-cadence` 与对应 workflow skill 负责；Bug 卡片为 `Draft` 时是否可以进入 `bug-fix` 诊断，必须由这些权威规则判断，不能从并行表状态直接推断。

## 已观察行为

当前表名为“当前可并行实施表”，表内同时存在 `Draft` 和 `Blocked` 工作项，末尾说明又把 `Draft` 概括为不能直接进入实施。与此同时，现行规则允许 Bug 在没有 `Ready` 或已知根因时进入 `bug-fix`，导致表格中的 `Draft` 看起来像不可启动，但实际又可能可以启动诊断。

## ✅ 范围

- 明确并行视图展示的是工作项候选、流程启动资格还是代码实施资格，并使标题、说明和字段语义一致。
- 保留 `Draft`、`Ready`、`In Progress`、`Blocked`、`Done`、`Superseded` 和 `Dropped` 作为唯一工作项状态。
- 将卡片生命周期、依赖状态与 Workflow 路由的权威来源分开表达，不在并行表逐行复制入口门禁。
- 明确并行表状态不能替代 Story、Task 和 Bug 各自的路由与入口规则。
- 保留依赖表和并行序号的排序、依赖和用户授权边界。
- 增加对应的源规则、Backlog 展示和契约验证。

## ❌ 非范围

- 不新增 `可实施`、`可启动` 或其他全局工作项状态。
- 不改变 Bug、Story 或 Task 各自已经确认的 Workflow 入口门禁。
- 不把 Workflow 内部阶段投影为 Backlog 状态。
- 不自动启动并行工作项，不改变用户授权要求。
- 不机械重排无关的 Backlog 或并行序号。
- 不恢复已由 B-009 移除的“下一步 Workflow / 入口门禁”列。

## 验收标准

1. 并行视图的 `状态` 字段只表达卡片生命周期，表级说明明确它不表达下游入口资格。
2. Workflow 路由由 `using-dev-cadence` 和对应 workflow skill 负责，并行表不逐行复制路由结论。
3. `Draft` Story、`Draft` Task 和 `Draft` Bug 的入口差异继续由各自权威规则判断。
4. `Blocked` 只表达明确依赖阻塞，不被解释为 Workflow 阶段或新的成熟度状态。
5. 规范工作项状态枚举保持不变，依赖表、并行序号和用户授权语义保持不变。
6. source、dist、安装包和相关契约验证保持一致。

## 已知复现条件

- 打开 `docs/backlog.md` 的“当前可并行实施表”。
- 观察表中 `Draft` 工作项与“不能直接进入实施”的统一说明。
- 对比 Work Item Planning 中允许 Bug 在非 `Ready` 状态进入 `bug-fix` 的规则。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无。Q-005 已由 B-009 解决：保留“当前可并行实施表”名称和四列表结构，通过表级职责边界而不是逐行入口列分离语义。

## 相关文档

- [Backlog](../backlog.md)
- [S-016 统一 Backlog 看板](../stories/S-016-unified-backlog-board.md)
- [S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)
- [工作项规划流程](../workflows/work-item-planning.md)
- [工作项分析流程](../workflows/work-item-analysis.md)

## Relationships

- Superseding decision: [B-009 待处理排序与并行视图职责不一致](B-009-pending-order-parallel-view-authority.md)。

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 2 | 2026-07-18 | 按 B-009 的已验收决定改用四列表级职责边界，移除逐行入口资格列要求并关闭 Q-005。 | B-009 已将路由所有权集中到 `using-dev-cadence` 和 owning workflow，原卡片要求已过期。 |
| 1 | 2026-07-17 | 创建并行视图状态与 Workflow 入口资格混用 Bug。 | 用户指出 Draft Bug 仍可能进入 bug-fix，当前表的“状态”语义不足以表达该差异。 |
