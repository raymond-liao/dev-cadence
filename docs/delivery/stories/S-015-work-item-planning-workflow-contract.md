# S-015 工作项规划 Workflow 与工作项契约

## 基本信息

- ID：`S-015`
- Version：`4`
- Status：`Done`
- Priority：`P1`
- Change Type：Feature

## 目标

新增 `work-item-planning` workflow 和统一工作项契约，支持从已确认的 User Journey、PRD 和 Business Architecture 进行整体规划，也支持接入单个明确工作请求；由该 workflow 创建和维护 Story Map，并创建可移交给交付 workflow 的 Story、Task 和 Bug 卡片。

## 背景

当前仓库已经使用 Story、Task 和 Bug 卡片管理规划，但安装包尚未提供正式的 Work Item Planning workflow。缺少统一入口时，卡片创建、整体产品拆分、Story Map 维护和交付移交容易由不同 workflow 各自处理，形成重复规则和不一致资产。

只有零散工作项卡片和 Backlog 排序时，也难以判断产品能力是否覆盖完整业务线。Discovery 已经确认 User Journey 和 Feature 的权威职责；Work Item Planning 必须使用这些已确认业务事实组织 Story Map、Story、必要 Task 和交付切片，不能再次创建或解释 Feature。

## User Story

作为规划产品交付的用户，我希望通过统一的 Work Item Planning workflow 建立 Story Map 和工作项卡片，以便形成整体开发计划，并将准备好的工作项交给对应的开发 workflow。

## ✅ 范围

- 新增可安装的 `work-item-planning` workflow skill。
- 支持从已确认的 User Journey、PRD 和 Business Architecture 建立或增量维护一组工作项的整体规划。
- 支持接入没有现有卡片的单个明确功能、Bug 或技术任务。
- 定义 Story、Task 和 Bug 的稳定 ID、卡片结构、版本、状态、关系和变更历史。
- 由 `work-item-planning` 创建组合规划和单项登记产生的轻量卡片，复用已有卡片并避免重复建卡；其他 workflow 仍可在自身职责范围内创建或更新卡片。
- 由 `work-item-planning` 创建和维护 Story Map。
- Story Map 从已确认 User Journey 提取完整的 `Offline` 和 `System` Feature 主干，保留业务顺序并支持 MVP 和后续增量切片。
- `Offline` Feature 只保留业务上下文，不在其下创建系统 Story 或 Task；`System` Feature 下可以创建 Story 和使 Feature 或 Milestone 成立所必需的 Task。
- Story Map 和工作项只引用已确认 Feature；Work Item Planning 不创建 Feature 卡片，也不改变 Feature ID、Type、标题、业务身份或顺序。
- 发现 Feature 缺失、含义不清或业务顺序需要变化时返回 Discovery，不在规划阶段补写产品结论。
- 使用 `docs/product-planning/story-map.md` 维护当前唯一的全局 Story Map，并通过普通 Markdown Table 表达 `Path x Feature` 规划结构。
- 使用 `Happy Path`、`Alternative Path` 和 `Sad Path` 作为规划分类，并由代理据此提出 Milestone 候选。
- 定义稳定的 `M-nnn` Milestone、用户确认的 MVP、明确工作项范围和来源 Path；Milestone 不复制卡片正文或状态。
- 定义轻量卡片的最小字段、统一状态、版本规则、关系、并发写回检查和跨 workflow 共享修改边界。
- 支持用户明确要求的产品设计变化协调，只在用户确认后原子更新受影响的 Story Map、Milestone、卡片关系和 Backlog 引用。
- 直接工作项接入不强制创建或重画完整 Story Map。
- 工作项规划完成后，由用户确认卡片并移交对应的 Feature Dev、Bug Fix 或 Refactor workflow。
- 更新入口发现、安装包、构建和契约验证，使该 workflow 可以在目标仓库中使用。

## ❌ 非范围

- 不在本 Story 中实现 Feature、Bug Fix 或 Refactor 的开发、测试和验收过程。
- 不替代交付 workflow 的 Requirements、Diagnosis、Solution 或 Implementation Plan。
- 不创建或修改 User Journey、Feature、PRD 或 Business Architecture。
- 不在产品设计基线不完整时声称已经形成完整 Story Map。
- 不把 Story Map 当作工作项执行状态看板或 workflow 运行记录。
- 不在本 Story 中实现统一 Backlog 看板的具体结构；该能力由 S-016 负责。
- 不在本 Story 中实现完整的相对 Size 估算流程；该能力由 S-038 负责。
- 不在本 Story 中实现 Iteration Plan 和容量校准；该能力由 S-039 负责。
- 不在本 Story 中实现 Work Item Analysis；该能力由 S-037 负责。
- 不在本 Story 中实现工作项卡片与现有交付 workflow 的完整状态和交付引用回写。
- 不为新增 Story Map 向所有既有 workflow 增加禁止编辑条款。

## 验收标准

1. 安装包提供可被入口选择的 `work-item-planning` workflow。
2. workflow 同时支持整体规划和单个明确工作请求的接入。
3. workflow 能创建和复用 Story、Task 与 Bug 卡片，并使用稳定 ID、版本、状态、关系和 Change Log。
4. `work-item-planning` 能创建和更新 Story Map。
5. Story Map 使用 `docs/product-planning/story-map.md`，能按已确认 User Journey 的业务顺序引用全部 `Offline` 和 `System` Feature，并表达关联 Story、必要 Task、Path、Milestone、MVP 和后续增量切片。
6. Work Item Planning 不创建或重新定义 Feature；Feature 缺失、含义或顺序需要变化时返回 Discovery。
7. 直接工作项接入不会被强制扩展为整体 Story Map 重规划。
8. Story Map 不承载交付 workflow 的内部阶段或运行状态。
9. 轻量卡片使用统一状态、独立版本、显式关系和 Change Log，并允许其他 workflow 在明确职责范围内创建或更新。
10. 用户确认前只维护会话提案；确认后才原子写入受影响的 Story Map、Milestone、卡片和必要 Backlog 引用。
11. 规划完成的工作项能够经用户确认后移交对应后续 workflow。
12. source、dist、安装包、入口路由和契约测试保持同步。

## Story Relationships

- Follows：`S-002` 产品设计基线增量更新与版本治理。
- Follows：`S-014` Discovery User Journey 与 Feature 基线。
- Follows：`S-012` Asset 与 Delivery Workflow 记录边界。
- Precedes：`S-016` 统一 Backlog 看板。
- Precedes：`S-037` 工作项分析 Workflow。
- Precedes：`S-038` 工作项相对 Size 估算。
- Precedes：`S-017` 工作项卡片与开发 Workflow 接入。
- Depends On：`S-014` Discovery User Journey 与 Feature 基线。

## 依赖

- `S-002` 产品设计基线增量更新与版本治理。
- `S-014` Discovery User Journey 与 Feature 基线。
- `S-012` Asset 与 Delivery Workflow 记录边界。
- `T-001` 工作项范围章节语义标识。

## Open Questions

- 无。

## 相关文档

- [S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)
- [S-012 Asset 与 Delivery Workflow 记录边界](S-012-asset-delivery-workflow-record-boundary.md)
- [S-014 Discovery User Journey 与 Feature 基线](S-014-user-journey-analysis.md)
- [S-016 统一 Backlog 看板](S-016-unified-backlog-board.md)
- [S-037 工作项分析 Workflow](S-037-work-item-analysis-workflow.md)
- [S-038 工作项相对 Size 估算](S-038-work-item-relative-size-estimation.md)
- [S-039 Iteration Plan 与容量校准](S-039-iteration-plan-capacity-calibration.md)
- [T-001 工作项范围章节语义标识](../tasks/T-001-work-item-scope-semantic-markers.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Work Item Planning Story Map 卡片。 | 为整体产品开发计划增加用户活动、任务、Story 和交付切片结构。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 合并 Work Item Planning workflow、工作项契约与 Story Map 范围。 | Story Map 是 Work Item Planning 的核心规划能力，不应作为独立交付项。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-15 | legacy: recorded-by unknown | 将状态更新为 Ready。 | S-002、S-012 和 T-001 均已完成，S-015 的全部前置依赖已满足。 Legacy migration: original Version 3; normalized to Version 2. |
| 3 | legacy: recorded-at precision unknown; original 2026-07-15 | legacy: recorded-by unknown | 将 User Journey 和 Feature 改为必需的上游产品设计输入，并将状态更新为 Blocked。 | S-014 已重新定义 Discovery 对 Journey 和 Feature 的权威职责；Work Item Planning 必须等待该职责实现后再创建 Story Map 和工作项。 Legacy migration: original Version 4; normalized to Version 3. |
| 4 | legacy: recorded-at precision unknown; original 2026-07-15 | legacy: recorded-by unknown | 补全 Story Map、Path、Milestone、轻量卡片和共享修改契约，并将 Size、Iteration Plan 和 Work Item Analysis 拆分为后继工作项。 | 工作项规划流程设计已经明确核心资产边界和后续能力，需要让实施卡完整承接已确认方案而不覆盖 Journey-led 上游关系。 Legacy migration: original Version 5; normalized to Version 4. |
| 4 | legacy: recorded-at precision unknown; original 2026-07-16 | legacy: recorded-by unknown | S-014 已完成，User Journey 与 Feature 基线依赖全部满足，状态更新为 Ready。 | Work Item Planning 现在可以基于已确认的三资产产品设计基线进入实施。 Legacy migration: original Version 6; normalized to Version 4. |
| 4 | legacy: recorded-at precision unknown; original 2026-07-16 | legacy: recorded-by unknown | S-014 实施与验证已完成但仍等待 Business Acceptance，状态回到 Blocked。 | Work Item Planning 依赖的产品设计交付尚未完成业务验收。 Legacy migration: original Version 7; normalized to Version 4. |
| 4 | legacy: recorded-at precision unknown; original 2026-07-16 | legacy: recorded-by unknown | 用户要求继续执行并行实施表的下一个工作项，S-015 进入 In Progress。 | S-014 已通过 Business Acceptance；本次只改变执行状态，不改变已确认的工作项定义。 Legacy migration: original Version 7; normalized to Version 4. |
| 4 | legacy: recorded-at precision unknown; original 2026-07-16 | legacy: recorded-by unknown | 实施、系统测试和 Business Acceptance 已完成，S-015 状态更新为 Done。 | 用户选择 `1. Accept`；无新增剩余风险。 Legacy migration: original Version 7; normalized to Version 4. |
| 4 | 2026-07-19T13:07:24+0800 | Raymond Liao <raymond-liao@outlook.com> | Normalized legacy status and delivery events to reuse the active definition Version. | Old current 7 -> new current 4; original row versions 1,2,3,4,5,6,7,7,7 -> normalized row versions 1,2,2,3,4,4,4,4,4. |
