# S-014 User Journey 分析

## 基本信息

- ID：`S-014`
- Version：`1`
- Status：`Draft`
- Priority：`P3`
- Change Type：Feature

## 目标

提供独立的 User Journey 产品分析能力，帮助用户围绕特定角色和目标梳理旅程阶段、行为、触点、问题和机会，并将分析结果作为后续产品规划的可选输入。

## 背景

User Journey 是产品分析工具，不等同于 Story Map。它关注用户完成目标时经历的完整过程和体验；Story Map 则使用产品分析输入组织用户活动、任务、Story 和交付切片。

并非所有 Story Map 都需要先创建 User Journey。该能力应作为后续可选 workflow 或 skill 单独设计，不阻塞 Work Item Planning 和 Story Map 的建立。

## User Story

作为进行产品分析的用户，我希望在需要时梳理特定角色完成目标的完整旅程，以便识别关键触点、问题和机会，并为后续产品规划提供上下文。

## ✅ 范围

- 支持围绕明确的用户角色和用户目标进行 User Journey 分析。
- 根据实际问题分析旅程阶段、用户行为、触点、问题和机会。
- 允许 Work Item Planning 在存在 User Journey 时将其作为 Story Map 的可选输入。
- 将该能力设计为后续可独立选择的 workflow 或 skill，不自动成为其他 workflow 的必经阶段。

## ❌ 非范围

- 不要求所有产品或 Story Map 都必须先创建 User Journey。
- 不在本 Story 中定义 Story Map、Backlog 或工作项卡片的创建和维护规则。
- 不负责技术架构、实施计划、代码修改、测试或发布。
- 不在本卡片阶段确定最终文档路径、模板或完整执行阶段。

## 验收标准

1. User Journey 被定义为独立、可选的产品分析能力。
2. 分析对象至少包含明确的用户角色和用户目标。
3. 分析可以按实际需要覆盖旅程阶段、行为、触点、问题和机会。
4. Work Item Planning 可以使用已有 User Journey，但缺少 User Journey 不阻止 Story Map 规划。
5. 该能力不会自动成为 Discovery、Work Item Planning 或交付 workflow 的必经阶段。

## Story Relationships

- Related：Story Map。
- Related：Work Item Planning workflow。
- Related：Discovery 产品设计基线。

## 依赖

- 无硬性前置依赖。

## Open Questions

- 最终采用独立 workflow 还是辅助 skill。
- User Journey 的持久化路径和最小文档结构。
- 多角色协作场景使用联合 Journey 还是按角色分别维护。

## 相关文档

- [工作项规划流程](../workflows/work-item-planning.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 User Journey 分析卡片。 | 将 User Journey 作为可选产品分析能力保留到后续设计。 |
