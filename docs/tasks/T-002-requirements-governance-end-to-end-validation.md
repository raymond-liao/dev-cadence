# T-002 需求治理端到端验证与安装契约

## 基本信息

- ID：`T-002`
- Version：`3`
- Status：`Blocked`
- Priority：`P2`
- Change Type：Quality Engineering

## 任务目标

验证从想法、User Journey、Feature、PRD、Business Architecture、工作项规划、分析、估算和迭代安排到三个开发 workflow 交付及 Backlog 回写的完整链路，并覆盖构建、安装包、入口路由和现有目标仓库兼容。

## 背景

各阶段的局部契约通过并不能证明整条需求治理链路可以在安装后的目标仓库中闭环。需要一项独立技术任务验证跨 workflow 路由、资产传递和兼容性。

## ✅ 范围

- 覆盖想法到首次 User Journey、Feature、PRD、Business Architecture、工作项规划和开发 workflow 移交。
- 验证 Discovery 创建并维护 Journey 与 Feature，Work Item Planning 只引用已确认 Feature 并在 `System` Feature 下创建 Story 或必要 Task。
- 验证重要 Product Requirement 和关键 Business Architecture 内容能够追溯到已确认 Journey 或 Feature。
- 验证 Work Item Planning 创建 Story Map、Milestone、轻量工作项和统一 Backlog，并保持 Offline/System Feature 边界。
- 验证基准卡确认、相对 Size、首个 Iteration 容量校准和剩余 Iteration 安排。
- 验证 Work Item Analysis 对 Story、Task 和 Bug 的单项或代表性批量分析，以及重复、冲突和部分确认边界。
- 验证 Story 的 `Draft -> Ready -> In Progress -> Done` 路径，及 Task、Bug 不使用统一 `Ready` 硬门禁。
- 分别覆盖 feature-dev、bug-fix 和 refactor 的代表性路径。
- 验证工作项状态、交付引用和 Backlog 回写。
- 验证 source、dist、安装包和入口路由一致性。
- 验证现有目标仓库在升级后的兼容行为。

## ❌ 非范围

- 不在验证任务中补做缺失产品能力。
- 不以 demo 记录替代自动化或可重复契约检查。
- 不扩展发布与生产交付范围。

## 完成条件

1. 从模糊想法到 User Journey、Feature、PRD、Business Architecture、Story Map、Milestone、工作项、Size、Iteration Plan、分析、开发交付和 Backlog 回写的完整链路在临时目标仓库中可重复执行和验证。
2. Story、Task 和 Bug 的规划、分析和 Delivery 路由使用各自明确的成熟度与启动规则。
3. 三个开发 workflow 均覆盖精确卡片版本消费、生命周期变化和 Backlog 回写。
4. Journey、Feature、产品设计和工作项之间的权威职责及追溯关系得到验证，不出现重复 Feature 定义。
5. 构建、安装和兼容性检查对失败提供可定位证据。

## Task Relationships

- Follows：`S-015`、`S-016`、`S-017`、`S-037`、`S-038`、`S-039`、`S-004`。

## 依赖

- `S-015` 工作项规划 Workflow 与工作项契约。
- `S-016` 统一 Backlog 看板。
- `S-017` 工作项卡片与开发 Workflow 接入。
- `S-037` 工作项分析 Workflow。
- `S-038` 工作项相对 Size 估算。
- `S-039` Iteration Plan 与容量校准。
- `S-004` 实施与测试失败分类和阶段返回。

## Open Questions

- Q-022：哪些代表性路径足以覆盖升级兼容，而不会把测试固化为单一实现？

## 相关文档

- [S-004 实施与测试失败分类和阶段返回](../stories/S-004-failure-classification-stage-routing.md)
- [S-014 Discovery User Journey 与 Feature 基线](../stories/S-014-user-journey-analysis.md)
- [S-015 工作项规划 Workflow 与工作项契约](../stories/S-015-work-item-planning-workflow-contract.md)
- [S-016 统一 Backlog 看板](../stories/S-016-unified-backlog-board.md)
- [S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)
- [S-037 工作项分析 Workflow](../stories/S-037-work-item-analysis-workflow.md)
- [S-038 工作项相对 Size 估算](../stories/S-038-work-item-relative-size-estimation.md)
- [S-039 Iteration Plan 与容量校准](../stories/S-039-iteration-plan-capacity-calibration.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建需求治理端到端验证任务。 | 用安装后的完整链路验证跨 workflow 契约和兼容性。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-15 | legacy: recorded-by unknown | 将 User Journey、Feature 和三资产产品设计基线纳入端到端验证范围。 | Discovery 已确认 Journey 和 Feature 的上游权威职责，完整治理链路必须验证其向规划与交付阶段的传递。 |
| 3 | legacy: recorded-at precision unknown; original 2026-07-15 | legacy: recorded-by unknown | 将工作项分析、相对 Size、Iteration Plan、类型化启动门禁和共享卡片回写纳入端到端验证，并将状态更新为 Blocked。 | Planning 和 Analysis 的完整方案已经形成，最终验证必须覆盖从产品基线到分批交付的全部权威资产与路由边界。 |
