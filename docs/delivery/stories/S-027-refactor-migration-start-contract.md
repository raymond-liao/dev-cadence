# S-027 Refactor 迁移与旧路径删除契约

## 基本信息

- ID：`S-027`
- Version：`4`
- Status：`Done`
- Priority：`P2`
- Change Type：Feature

## 目标

仅在渐进迁移、兼容层或多调用方场景中管理调用方清单、兼容策略、迁移批次、待迁移范围和旧路径删除安全。

## 背景

复杂 Refactor 如果没有迁移起点，会在实施中丢失调用方和兼容边界；但对简单重构强制相同记录会增加无效流程成本。

## 角色、场景和价值

- 角色：执行 Dev Cadence `refactor` workflow 的交付负责人。
- 场景：重构无法作为一次原子、已验证的变更完成，且需要保留兼容层或旧路径，或需要将已知调用方分批迁移。
- 价值：交付负责人能够在开始时界定迁移范围，并在删除旧路径前以可复核的迁移状态和证据避免遗漏调用方或过早删除兼容路径。

## ✅ 范围

- 当重构需要跨批次迁移、保留兼容层或旧路径、或不能在一次原子变更中完成多个已知调用方的切换时，启动迁移契约；其他重构明确记录为不适用。
- 在 `02-refactor-solution.md` 记录初始调用方清单、兼容策略、迁移批次和待迁移范围；不创建竞争所有权的独立迁移清单。
- 在 `04-refactor-record.md` 维护每个调用方的来源、目标路径或适配器、所属批次及 `pending`、`migrated`、`blocked` 或 `not_applicable` 状态，并记录剩余待迁移范围。
- 在 `05-regression-test-report.md` 记录旧路径删除前的剩余引用检查、调用方状态、适配器保留或删除决策，以及可重复的删除安全证据。

## ❌ 非范围

- 不强制简单、单调用方或原子重构建立迁移计划。
- 不允许通过兼容层引入未确认的行为变化。
- 不改变公共 API 兼容性规则。
- 不把行为变更包装为 Refactor。

## 可观察行为与业务规则

1. 适用迁移契约的 Refactor 在进入实施前必须有完整的初始调用方、兼容策略、批次和待迁移范围；不适用时必须说明不适用原因，且不要求创建迁移清单。
2. 每个迁移批次完成后，`04-refactor-record.md` 必须更新受影响调用方和剩余范围；`blocked` 调用方不得被表述为已迁移。
3. 删除旧路径前，必须同时满足：剩余引用检查未发现未处置引用；所有已知调用方均为 `migrated` 或 `not_applicable`；适配器保留或删除决策明确；删除安全证据可重复执行。
4. 任一条件不满足时，Refactor 不得删除旧路径，必须保留旧路径或兼容层并记录阻塞原因。

## 验收标准

1. 对适用迁移契约的 Refactor，`02-refactor-solution.md` 包含初始调用方清单、兼容策略、迁移批次和待迁移范围；简单、单调用方或原子重构只记录不适用原因，不创建迁移清单。
2. `04-refactor-record.md` 能按调用方和批次追溯来源、目标路径或适配器、当前迁移状态和剩余范围，并在每个完成批次后更新。
3. `05-regression-test-report.md` 在删除旧路径前同时证明剩余引用已处置、所有已知调用方为 `migrated` 或 `not_applicable`、适配器决策明确且删除安全证据可重复。
4. 任一删除条件缺失、存在 `pending` 或 `blocked` 调用方、或删除安全证据不足时，workflow 拒绝删除旧路径并保留阻塞原因。

## Story Relationships

- Supersedes：历史工作项 `S-028` Refactor 旧路径删除门禁；来源卡已删除。

## 依赖

- 无强制前置依赖。

## 已确认决策

- [Q-016 迁移状态的持久化位置](../open-questions.md#q-016)：状态由单次 Refactor 的既有记录链持有，初始范围位于 `02-refactor-solution.md`，实施状态位于 `04-refactor-record.md`，删除安全证据位于 `05-regression-test-report.md`；不创建独立迁移清单。

## 下游交付

- Ready Story 交由 `feature-dev` 实施，因为本卡为 `refactor` workflow 增加新的可观察治理行为，而不是执行一次行为保持的代码重构。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Refactor 迁移开始契约 Story。 | 为高风险渐进迁移提供最小、条件化的治理记录。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 吸收 S-028，覆盖迁移启动到旧路径删除的完整生命周期。 | 两卡围绕同一迁移清单、兼容边界和删除证据；旧路径门禁不能脱离迁移状态独立交付。 |
| 3 | 2026-07-19T20:23:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 补全公共 API 兼容性和 Refactor 行为不变边界。 | 确保吸收 S-028 后不会扩大旧路径删除契约的权限。 |
| 4 | 2026-07-21T17:28:14+0800 | Raymond Liao <raymond-liao@outlook.com> | 确认条件化迁移契约、既有记录链所有权和旧路径删除门禁，并将 Story 标记为 Ready。 | 用户确认触发边界、Q-016 的记录位置、可执行验收条件及以 Feature Dev 交付新增 workflow 行为。 |
| 4 | 2026-07-24T15:18:05+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 In Progress。 | 用户明确请求开始实施 S-027。 |
| 4 | 2026-07-24T15:21:03+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Done。 | 实现已集成；完整契约、安装和分发同步验证通过。 |
