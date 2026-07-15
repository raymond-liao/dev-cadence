# S-039 Iteration Plan 与容量校准

## 基本信息

- ID：`S-039`
- Version：`1`
- Status：`Blocked`
- Priority：`P1`
- Change Type：Enhancement

## 目标

为 Work Item Planning 增加基于团队假设、首个迭代容量校准、优先级、依赖和 Size 的完整 Iteration Plan，形成可审阅的分批实施路线。

## 背景

Path 表达业务路径分类，Milestone 表达阶段性业务目标，两者都不能直接替代团队实际分批实施计划。在容量尚未校准时一次安排全部迭代，会把未经验证的团队吞吐量假设扩散到整个路线。

Work Item Planning 需要先用默认团队画像形成一个候选迭代，经用户判断工作量是否合适后，把确认的工作项组合、Size 分布和团队画像作为容量基准，再安排剩余工作。

## User Story

作为安排产品交付的用户，我希望先校准一个候选迭代，再形成完整的分批实施路线，以便计划尊重业务优先级、依赖、风险和团队实际容量。

## ✅ 范围

- 在 Story Map 中维护 Iteration Planning Basis 和完整 Iteration Plan，不创建独立 Sprint Plan 文件。
- 首次规划默认使用 `Team Size: 8`、跨职能交付团队、正常可用性和未校准容量，不从 Git 历史推断团队信息。
- 容量未校准时只形成一个候选迭代，不直接安排全部 Iteration。
- 候选迭代综合当前优先 Milestone、Story Map 顺序、Story 成熟度、Task/Bug 不确定性、硬依赖、Size、团队假设和可验证阶段性结果。
- 展示候选 Iteration Goal、工作项、类型、Size、选择原因、Size 分布、团队假设和已知不确定性，并由用户判断工作量是否合适。
- 根据用户对工作量、团队规模、角色构成和可用性的反馈主动调整当前候选，不要求用户自行计算容量。
- 首个迭代确认后，以其工作项组合、Size 分布和团队画像作为容量基准安排剩余工作。
- 后续 Iteration 尊重硬依赖、Story Map 优先级、Milestone 目标、专业能力瓶颈和风险分布，每个 Iteration 都有明确 Goal。
- 一个 Milestone 可以跨多个 Iteration，一个 Iteration 也可以推进多个 Milestone；不得把 Path 或 Milestone 机械映射成 Iteration。
- Bug 和独立 Task 可以进入 Iteration Plan，但不会因此进入 Story Map 主表。
- 团队画像或实际交付能力明显变化时，重新形成并确认一个候选迭代后再更新剩余计划。
- 未完成工作项不自动移动到下一 Iteration，必须在后续 Work Item Planning 中重新确认。

## ❌ 非范围

- 不使用跨团队通用的 `Size -> 人日` 换算。
- 不在容量尚未校准时一次安排全部 Iteration。
- 不创建独立 Sprint Plan、Sprint Backlog 或重复工作项集合。
- 不把 Iteration 绑定固定日期，除非用户明确要求。
- 不在 Iteration Plan 中保存实际开发进度或 Delivery Workflow 内部阶段。
- 不负责创建工作项、定义 Backlog 基础结构或执行相对 Size 估算。

## 验收标准

1. Iteration Planning Basis 和完整 Iteration Plan 保存在 Story Map 内，不产生重复 Sprint 资产。
2. 首次规划只形成一个基于明确团队假设的候选迭代，并在用户反馈后校准容量。
3. 剩余 Iteration 只有在容量基准确认后才形成，并参考工作项总量和 Size 分布而不是卡片数量。
4. 每个 Iteration 具有明确 Goal、工作项范围、Size 分布、依赖、风险和不确定性。
5. Iteration 安排尊重硬依赖、Story Map 优先级、Milestone 目标和专业能力瓶颈。
6. Path、Milestone 和 Iteration 保持不同职责，不进行机械映射。
7. Bug 和独立 Task 可以进入 Iteration Plan，但不会污染 Story Map 主表。
8. 团队或容量事实变化、未完成工作重新安排时需要重新确认，不自动滚动。
9. 契约测试覆盖默认假设、首个迭代校准、剩余安排和增量重校准。

## Story Relationships

- Follows：`S-016` 统一 Backlog 看板。
- Follows：`S-038` 工作项相对 Size 估算。
- Precedes：`T-002` 需求治理端到端验证与安装契约。
- Related：`S-015` 工作项规划 Workflow 与工作项契约。

## 依赖

- `S-016` 统一 Backlog 看板。
- `S-038` 工作项相对 Size 估算。

## Open Questions

- 无。

## 相关文档

- [工作项规划流程](../workflows/work-item-planning.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [S-016 统一 Backlog 看板](S-016-unified-backlog-board.md)
- [S-038 工作项相对 Size 估算](S-038-work-item-relative-size-estimation.md)
- [T-002 需求治理端到端验证与安装契约](../tasks/T-002-requirements-governance-end-to-end-validation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-15 | 创建 Iteration Plan 与容量校准卡片。 | 将团队容量校准和完整分批实施路线作为可独立交付、验证的 Planning 增强。 |
