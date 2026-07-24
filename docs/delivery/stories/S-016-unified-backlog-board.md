# S-016 统一 Backlog 看板

## 基本信息

- ID：`S-016`
- Version：`5`
- Status：`Done`
- Priority：`P1`
- Change Type：Feature

## 目标

使用一份统一 Backlog 管理全部工作项的状态、优先级、关系、阻塞和建议实施顺序，不再维护 Product Backlog、Sprint Backlog 或其他重复工作项集合。

## 背景

将 Product Backlog、当前 Sprint 选择和 Sprint Backlog 维护为多份资产，会重复保存相同工作项并增加同步成本。统一 Backlog 应提供全局工作队列和当前实施状态视图，同时保持状态模型足够简单。

Backlog 只表达工作项级生命周期。进入实施后的需求确认、方案、实现、测试和验收等内部状态由对应 workflow 自己管理，不进入 Backlog 状态模型。

## User Story

作为规划和跟踪产品交付的用户，我希望在一份 Backlog 中查看所有工作项的状态、优先级、关系和建议顺序，以便避免维护重复列表并清楚判断下一项工作。

## ✅ 范围

- 使用一份统一 Backlog 表达全部候选、进行中、受阻、完成和已关闭工作项。
- Backlog 关联具体工作项卡片，并可引用对应 Story Map、Milestone 或 Iteration Plan。
- 工作项状态统一使用 `Draft`、`Ready`、`In Progress`、`Blocked`、`Done`、`Superseded` 和 `Dropped`。
- Backlog 汇总工作项类型、状态、优先级、Size、关系、阻塞和建议实施顺序，但不复制卡片详细定义。
- Work Item Planning 负责 Backlog 的首次创建、文档结构、规划排序和无关工作项不受影响的增量更新规则。
- Story 只有完成 Work Item Analysis、用户确认定义并且没有阻止开发的开放问题时才能进入 `Ready`。
- Task 不强制在实施前达到 `Ready`；Bug 不以 `Ready` 或已知根因为进入 `bug-fix` 的硬前置条件。
- 工作项进入对应 Delivery Workflow 后更新为 `In Progress`；开发、验证和业务验收闭环后更新为 `Done`。
- 明确决策不再处理的工作项使用 `Dropped`；被新工作项替代时使用 `Superseded`。
- 硬依赖、阻塞、替代和关联关系必须显式记录，不得只依赖 Story Map 位置推断。
- Backlog 只在工作项生命周期发生变化时更新，不跟踪 workflow 内部阶段。
- Backlog 的创建、结构、排序和规划使用方式由 Work Item Planning 定义。
- `进行中`、`待处理`、`已完成` 和 `已关闭` 使用统一 Markdown Table 展示工作项。
- 生命周期表只展示 `ID`、`Title`、`Version`、`Status` 和 `Priority`；`Title` 链接到权威工作项卡片。
- `已关闭` 行在 `Title` 单元格中追加简短关闭摘要：`Superseded` 记录目标卡片和合并原因，`Dropped` 记录放弃原因；详细依据仍由权威卡片持有。
- `待处理` 表的行顺序就是建议实施顺序，不增加单独的 `Order` 列。
- `Change Type`、`Size`、依赖和阻塞不重复放入生命周期表，继续由卡片或关系规划结构承载。

## ❌ 非范围

- 不为 Product Backlog、Sprint 和 Sprint Backlog 分别保存重复工作项集合。
- 不增加 `Selected`、`Awaiting Acceptance`、`Awaiting Integration` 或其他未经确认的工作项状态。
- 不在 Backlog 中展示 Requirements、Solution、Implementation、Testing 或 Business Acceptance 等 workflow 内部阶段。
- 不把普通代码提交、Review 中间过程或测试执行过程写入 Backlog。
- 不复制工作项卡片正文、验收条件或 Delivery Workflow 运行记录。
- 不在本 Story 中实现相对 Size 估算算法或 Iteration Plan 容量校准。

## 验收标准

1. 项目只维护一份统一 Backlog 工作项集合，不复制 Product Backlog 或 Sprint Backlog。
2. Backlog 能够汇总全部工作项的卡片引用、类型、状态、优先级、Size、关系、阻塞和建议顺序。
3. 工作项状态严格限制为 `Draft`、`Ready`、`In Progress`、`Blocked`、`Done`、`Superseded` 和 `Dropped`。
4. Story、Task 和 Bug 的 `Ready` 与 Delivery 启动规则保持各自边界，不使用统一的机械状态推进。
5. Work Item Planning 创建并维护 Backlog 结构和规划顺序，其他 workflow 只同步自身职责范围内的生命周期变化。
6. workflow 内部阶段、临时等待状态和实施细节不会成为 Backlog 状态或正文。
7. Backlog 增量更新不会机械重排无关工作项，硬依赖和阻塞均有显式记录。
8. Backlog 只在工作项级事实变化时更新，不作为高频运行日志。
9. 四个生命周期区块都使用统一的五列表格，并保持现有工作项顺序。
10. 生命周期表不重复复制卡片的 `Change Type`、`Size`、依赖或阻塞字段。
11. `已关闭` 在不增加新列的前提下，能直接看到 `Superseded` 的目标卡片与合并原因，或 `Dropped` 的放弃原因。

## 已确认需求决策

- [Q-007 已关闭历史合并事件展示](../open-questions.md#q-007) 已解决：保留 `ID | Title | Version | Status | Priority` 五列结构，在 `Title` 单元格中追加简短关闭摘要。
- `Superseded` 摘要必须链接目标卡片并说明合并原因；`Dropped` 摘要必须说明放弃原因。详细处置和历史仍由权威卡片持有，Backlog 不复制卡片正文。

## Story Relationships

- Depends On：`S-015` 工作项规划 Workflow 与工作项契约。
- Precedes：`S-017` 工作项卡片与开发 Workflow 接入。
- Related：`S-037` 工作项分析 Workflow。
- Related：`S-038` 工作项相对 Size 估算。

## 依赖

- `S-015` 工作项规划 Workflow 与工作项契约。

## Open Questions

- 无。

## 相关文档

- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [S-017 工作项卡片与开发 Workflow 接入](S-017-work-item-development-workflow-integration.md)
- [S-037 工作项分析 Workflow](S-037-work-item-analysis-workflow.md)
- [S-038 工作项相对 Size 估算](S-038-work-item-relative-size-estimation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建统一 Backlog 看板卡片。 | 用一份最小状态看板替代重复的 Product Backlog、Sprint 和 Sprint Backlog 工作项集合。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 将 Work Item Planning 和 Story Map 的文本前置条件统一绑定到 S-015。 | S-015 已同时负责 workflow、工作项契约和 Story Map，S-016 应使用稳定工作项 ID 表达单一依赖。 |
| 3 | legacy: recorded-at precision unknown; original 2026-07-15 | legacy: recorded-by unknown | 扩展统一状态、规划关系和 Backlog 职责，并将状态更新为 Blocked。 | 工作项规划与分析方案已经确认不同工作项的成熟度和启动规则，Backlog 必须作为统一投影视图而不是机械状态看板。 |
| 4 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 确认生命周期区块使用五列表格，并以行顺序表达待处理项的建议顺序。 | 降低 Backlog 展示字段和重复状态来源，保留卡片与关系规划结构的职责边界。 |
| 4 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 记录实施、系统测试和 Business Acceptance，并将状态更新为 Done。 | 用户选择 `1. Accept`，S-016 交付结果已验收。 |
| 5 | 2026-07-19T20:32:11+0800 | Raymond Liao <raymond-liao@outlook.com> | 确认 `已关闭` 在 `Title` 单元格中展示简短关闭摘要，并解决 Q-007。 | 保持五列表格的同时，让用户无需逐张打开卡片即可理解工作项为何被合并或放弃。 |
