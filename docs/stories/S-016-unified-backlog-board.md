# S-016 统一 Backlog 看板

## 基本信息

- ID：`S-016`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Feature

## 目标

使用一份统一、类似看板的 Backlog 管理全部工作项及当前交付选择，不再分别维护 Product Backlog、Sprint 和 Sprint Backlog 的重复工作项集合。

## 背景

将 Product Backlog、当前 Sprint 选择和 Sprint Backlog 维护为多份资产，会重复保存相同工作项并增加同步成本。统一 Backlog 应提供全局工作队列和当前实施状态视图，同时保持状态模型足够简单。

Backlog 只表达工作项级生命周期。进入实施后的需求确认、方案、实现、测试和验收等内部状态由对应 workflow 自己管理，不进入 Backlog 状态模型。

## User Story

作为规划和跟踪产品交付的用户，我希望在一份 Backlog 看板中查看所有工作项及其当前工作项状态，以便避免在 Product Backlog、Sprint 和 Sprint Backlog 之间重复维护相同内容。

## ✅ 范围

- 使用一份统一 Backlog 表达全部候选工作项、当前交付选择和已完成工作项。
- Backlog 关联具体工作项卡片，并可引用对应 Story Map 位置或切片。
- 工作项状态只使用 `Draft`、`Ready`、`In Progress` 和 `Done`。
- Work Item Planning 创建工作项时使用 `Draft`，规划完成后更新为 `Ready`。
- 工作项进入 Feature Dev、Bug Fix 或 Refactor 后更新为 `In Progress`。
- 对应交付 workflow 完整结束后更新为 `Done`。
- Backlog 只在工作项生命周期发生变化时更新，不跟踪 workflow 内部阶段。
- Backlog 的创建、结构、排序和规划使用方式由 Work Item Planning 定义。

## ❌ 非范围

- 不为 Product Backlog、Sprint 和 Sprint Backlog 分别保存重复工作项集合。
- 不增加 `Blocked`、`Selected`、`Awaiting Acceptance`、`Awaiting Integration` 或其他未经确认的工作项状态。
- 不在 Backlog 中展示 Requirements、Solution、Implementation、Testing 或 Business Acceptance 等 workflow 内部阶段。
- 不把普通代码提交、Review 中间过程或测试执行过程写入 Backlog。
- 不在本卡片阶段确定最终 Markdown 看板布局。

## 验收标准

1. 项目只维护一份统一 Backlog 工作项集合，不复制 Product Backlog 或 Sprint Backlog。
2. Backlog 能够表达全部工作项及当前交付选择。
3. 工作项状态严格限制为 `Draft`、`Ready`、`In Progress` 和 `Done`。
4. Work Item Planning 负责工作项从创建到 `Ready` 的规划状态变化。
5. 负责实施该卡片的交付 workflow 将状态更新为 `In Progress`，并在完整结束后更新为 `Done`。
6. workflow 内部阶段、临时等待状态和实施细节不会成为 Backlog 状态。
7. Backlog 只在工作项级生命周期变化时更新，不作为高频运行日志。

## Story Relationships

- Related：Work Item Planning workflow。
- Related：Story Map。
- Related：工作项卡片与开发 workflow 接入。

## 依赖

- Work Item Planning workflow 和工作项契约。
- Story Map 的工作项关联方式。

## Open Questions

- Backlog 的最终 Markdown 布局和当前交付选择的表达方式。
- 卡片状态与 Backlog 展示之间的同步方式。
- `Done` 是否要求完成代码集成，还是以交付 workflow 的 Completion 结束为准。

## 相关文档

- [工作项规划流程](../workflows/work-item-planning.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建统一 Backlog 看板卡片。 | 用一份最小状态看板替代重复的 Product Backlog、Sprint 和 Sprint Backlog 工作项集合。 |
