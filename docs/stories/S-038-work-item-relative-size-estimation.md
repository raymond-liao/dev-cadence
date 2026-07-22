# S-038 工作项相对 Size 估算

## 基本信息

- ID：`S-038`
- Version：`1`
- Status：`In Progress`
- Priority：`P1`
- Change Type：Enhancement

## 目标

为 Work Item Planning 增加基于确认基准卡的相对 Size 估算，使 Story、Task 和进入 Iteration Plan 的 Bug 使用一致、可解释且可重新校准的规模判断。

## 背景

只有工作项数量无法表达组合规划的工作量、复杂度和不确定性。直接把 Size 换算成人日会制造跨团队不成立的精度，也无法处理信息不足或范围变化。

Work Item Planning 需要先选择一张范围相对清楚、规模适中且有代表性的工作项作为 `M`，再相对估算其余工作项，并明确展示 `?`、`XL` 和高不确定性判断。

## User Story

作为规划产品交付的用户，我希望基于一张确认的代表性工作项相对估算其余工作，以便比较 Milestone 和 Path 的规模，并为后续迭代安排提供可信输入。

## ✅ 范围

- 在 Work Item Planning 中使用 `XS / S / M / L / XL / ?` 作为统一相对 Size。
- Size 综合表达相对工作量、复杂度和已知不确定性，不表示工期或人日。
- 在形成 Story Map 和轻量工作项后，提出代表性基准卡和选择理由，并由用户确认后固定为 `M`。
- 相对基准卡估算 Story Map 中的 Story、必要 Task，以及进入 Iteration Plan 的 Bug 和独立 Task。
- 展示每张卡片的 Size、各 Path 和 Milestone 的分布、所有 `?` 和 `XL`，以及与基准卡相比明显不确定的估算。
- 信息不足时保留 `?`，不得为了完成估算而猜测。
- 增量规划默认复用现有基准卡；基准卡删除、Superseded 或范围实质变化时重新选择并确认。
- 用户可以调整单张卡片 Size，或更换基准卡后重新估算。
- 将已确认 Size 同步到卡片、Story Map、Backlog 和相关 Change Log；仅 Size 变化不递增卡片定义版本。
- 其他 workflow 发现范围变化可能导致 Size 失效时只标记需要重新估算，不自行修改 Size。

## ❌ 非范围

- 不把 Size 转换为人日、工期或跨团队通用容量。
- 不在信息不足时猜测 `?` 工作项。
- 不创建 Story Map、Milestone、工作项卡片或 Backlog 基础结构。
- 不形成 Iteration Plan 或校准团队容量；该能力由 S-039 负责。
- 不修改工作项目标、范围、验收条件或产品设计基线。

## 验收标准

1. Work Item Planning 使用统一的 `XS / S / M / L / XL / ?` Size 集合。
2. 基准卡的候选、选择理由和 `M` 赋值经过用户确认。
3. 其余工作项相对基准卡估算，并展示 Path、Milestone、`?`、`XL` 和不确定性汇总。
4. 信息不足的工作项保持 `?`，不产生虚假精度或人日换算。
5. 已确认 Size 在卡片、Story Map 和 Backlog 中保持同步，Size 单独变化不递增卡片版本。
6. 基准卡失效或范围变化时能够触发重新估算，而不是由其他 workflow 静默修改。
7. 契约测试覆盖首次估算、基准复用、基准失效和不确定性呈现。

## Story Relationships

- Follows：`S-015` 工作项规划 Workflow 与工作项契约。
- Precedes：`S-039` Iteration Plan 与容量校准。
- Precedes：`T-002` 需求治理端到端验证与安装契约。
- Related：`S-016` 统一 Backlog 看板。

## 依赖

- `S-015` 工作项规划 Workflow 与工作项契约。

## Open Questions

- 无。

## 相关文档

- [工作项规划流程](../workflows/work-item-planning.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [S-016 统一 Backlog 看板](S-016-unified-backlog-board.md)
- [S-039 Iteration Plan 与容量校准](S-039-iteration-plan-capacity-calibration.md)
- [T-002 需求治理端到端验证与安装契约](../tasks/T-002-requirements-governance-end-to-end-validation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-15 | legacy: recorded-by unknown | 创建工作项相对 Size 估算卡片。 | 将可独立确认和验证的估算能力从核心 Planning 与 Iteration Plan 中分离。 |
| 1 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 解除 Blocked 状态，恢复为 Draft。 | 唯一显式前置 S-015 已完成；本卡尚未完成定义分析，不能直接标记 Ready。 |
| 1 | 2026-07-21T15:24:51+0800 | Raymond Liao <raymond-liao@outlook.com> | 完成工作项定义分析，状态改为 Ready。 | 角色、目标、价值、范围、可观察行为、验收标准、直接依赖和开发阻塞性 Open Questions 已明确，并已获用户确认。 |
| 1 | 2026-07-22T09:54:27+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 In Progress，并在 Backlog 中移入进行中。 | 用户明确启动 S-038 的 Feature Dev 交付；本次只改变执行状态。 |
