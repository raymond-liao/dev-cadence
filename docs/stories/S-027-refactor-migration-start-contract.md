# S-027 Refactor 迁移与旧路径删除契约

## 基本信息

- ID：`S-027`
- Version：`3`
- Status：`Draft`
- Priority：`P2`
- Change Type：Refactor

## 目标

仅在渐进迁移、兼容层或多调用方场景中管理调用方清单、兼容策略、迁移批次、待迁移范围和旧路径删除安全。

## 背景

复杂 Refactor 如果没有迁移起点，会在实施中丢失调用方和兼容边界；但对简单重构强制相同记录会增加无效流程成本。

## ✅ 范围

- 定义触发迁移开始契约的场景。
- 记录调用方清单、兼容策略、迁移批次和待迁移范围。
- 在实施过程中维护迁移完成状态。
- 在删除旧路径前验证剩余引用、调用方迁移状态、适配器保留或删除决策及可重复的删除安全证据。

## ❌ 非范围

- 不强制简单、单调用方或原子重构建立迁移计划。
- 不允许通过兼容层引入未确认的行为变化。
- 不改变公共 API 兼容性规则。
- 不把行为变更包装为 Refactor。

## 验收标准

1. 复杂迁移在开始时具有可追踪的调用方和批次边界。
2. 简单重构不会被迫创建无意义的迁移记录。
3. 待迁移范围能够支持后续删除安全判断。
4. 未完成迁移或删除安全证据不足时，旧路径不能被删除。

## Story Relationships

- Supersedes：[S-028 Refactor 旧路径删除门禁](S-028-refactor-legacy-path-removal-gate.md)。

## 依赖

- 无强制前置依赖。

## Open Questions

- [Q-016 迁移状态的持久化位置](../open-questions.md#q-016)：迁移状态应保存在实施记录还是独立清单中？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Refactor 迁移开始契约 Story。 | 为高风险渐进迁移提供最小、条件化的治理记录。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 吸收 S-028，覆盖迁移启动到旧路径删除的完整生命周期。 | 两卡围绕同一迁移清单、兼容边界和删除证据；旧路径门禁不能脱离迁移状态独立交付。 |
| 3 | 2026-07-19T20:23:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 补全公共 API 兼容性和 Refactor 行为不变边界。 | 确保吸收 S-028 后不会扩大旧路径删除契约的权限。 |
