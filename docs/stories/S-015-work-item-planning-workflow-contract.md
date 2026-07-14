# S-015 工作项规划 Workflow 与工作项契约

## 基本信息

- ID：`S-015`
- Version：`2`
- Status：`Draft`
- Priority：`P1`
- Change Type：Feature

## 目标

新增 `work-item-planning` workflow 和统一工作项契约，支持从产品设计进行整体规划，也支持接入单个明确工作请求；由该 workflow 创建和维护 Story Map，并创建可移交给交付 workflow 的 Feature、Story、Bug 和 Technical Task 卡片。

## 背景

当前仓库已经使用 Feature、Story 和 Technical Task 卡片管理规划，但安装包尚未提供正式的 Work Item Planning workflow。缺少统一入口时，卡片创建、整体产品拆分、Story Map 维护和交付移交容易由不同 workflow 各自处理，形成重复规则和不一致资产。

只有零散工作项卡片和 Backlog 排序时，也难以判断产品能力是否覆盖完整用户目标。Work Item Planning 需要使用 Story Map 组织用户活动、用户任务、Story 和交付切片，再建立对应工作项卡片。

## User Story

作为规划产品交付的用户，我希望通过统一的 Work Item Planning workflow 建立 Story Map 和工作项卡片，以便形成整体开发计划，并将准备好的工作项交给对应的开发 workflow。

## ✅ 范围

- 新增可安装的 `work-item-planning` workflow skill。
- 支持从已确认产品设计建立或增量维护一组工作项的整体规划。
- 支持接入没有现有卡片的单个明确功能、Bug 或技术任务。
- 定义 Feature、Story、Bug 和 Technical Task 的稳定 ID、卡片结构、版本、状态、关系和变更历史。
- 将 `work-item-planning` 作为工作项卡片的创建入口，复用已有卡片并避免重复建卡。
- 由 `work-item-planning` 创建和维护 Story Map。
- Story Map 使用用户活动、用户任务和 Story 表达产品规划结构，并支持 MVP 和后续增量切片。
- Story Map 可以读取 PRD、Business Architecture 和已有 User Journey 等相关产品分析输入；User Journey 是可选输入。
- 直接工作项接入不强制创建或重画完整 Story Map。
- 工作项规划完成后，由用户确认卡片并移交对应的 Feature Dev、Bug Fix 或 Refactor workflow。
- 更新入口发现、安装包、构建和契约验证，使该 workflow 可以在目标仓库中使用。

## ❌ 非范围

- 不在本 Story 中实现 Feature、Bug Fix 或 Refactor 的开发、测试和验收过程。
- 不替代交付 workflow 的 Requirements、Diagnosis、Solution 或 Implementation Plan。
- 不要求所有 Story Map 都必须先创建 User Journey。
- 不把 Story Map 当作工作项执行状态看板或 workflow 运行记录。
- 不在本 Story 中实现统一 Backlog 看板的具体结构；该能力由 S-016 负责。
- 不在本 Story 中实现工作项卡片与现有交付 workflow 的完整状态和交付引用回写。
- 不为新增 Story Map 向所有既有 workflow 增加禁止编辑条款。
- 不在本卡片阶段确定 Story Map 的最终文件路径或完整 Markdown 布局。

## 验收标准

1. 安装包提供可被入口选择的 `work-item-planning` workflow。
2. workflow 同时支持整体规划和单个明确工作请求的接入。
3. workflow 能创建和复用 Feature、Story、Bug 与 Technical Task 卡片，并使用稳定 ID、版本、状态、关系和 Change Log。
4. `work-item-planning` 能创建和更新 Story Map。
5. Story Map 能表达用户活动、用户任务、关联 Story、MVP 和后续增量切片。
6. Story Map 可以读取相关产品设计资产，并将 User Journey 作为可选输入。
7. 直接工作项接入不会被强制扩展为整体 Story Map 重规划。
8. Story Map 不承载交付 workflow 的内部阶段或运行状态。
9. 规划完成的工作项能够经用户确认后移交对应交付 workflow。
10. source、dist、安装包、入口路由和契约测试保持同步。

## Story Relationships

- Follows：`S-002` 产品设计基线增量更新与版本治理。
- Follows：`S-012` Asset 与 Delivery Workflow 记录边界。
- Precedes：`S-016` 统一 Backlog 看板。
- Precedes：工作项卡片与现有开发 workflow 接入。
- Related：`S-014` User Journey 分析。

## 依赖

- `S-002` 产品设计基线增量更新与版本治理。
- `S-012` Asset 与 Delivery Workflow 记录边界。
- `T-001` 工作项范围章节语义标识。

## Open Questions

- Story Map 的持久化路径和 Markdown 布局。
- 一个仓库维护一张全局 Story Map，还是允许按产品目标维护多张 Story Map。
- 工作项卡片的最终目录结构和模板。
- 增量规划时如何标识本次受影响的活动、任务和切片。

## 相关文档

- [工作项规划流程](../workflows/work-item-planning.md)
- [S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)
- [S-012 Asset 与 Delivery Workflow 记录边界](S-012-asset-delivery-workflow-record-boundary.md)
- [S-014 User Journey 分析](S-014-user-journey-analysis.md)
- [S-016 统一 Backlog 看板](S-016-unified-backlog-board.md)
- [T-001 工作项范围章节语义标识](../tasks/T-001-work-item-scope-semantic-markers.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 Work Item Planning Story Map 卡片。 | 为整体产品开发计划增加用户活动、任务、Story 和交付切片结构。 |
| 2 | 2026-07-14 | 合并 Work Item Planning workflow、工作项契约与 Story Map 范围。 | Story Map 是 Work Item Planning 的核心规划能力，不应作为独立交付项。 |
