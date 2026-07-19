# S-028 Refactor 旧路径删除门禁

## 基本信息

- ID：`S-028`
- Version：`1`
- Status：`Draft`
- Priority：`P2`
- Change Type：Refactor

## 目标

在 Refactor 删除旧路径前验证剩余引用、迁移完成状态、适配器保留决策和删除安全证据。

## 背景

渐进迁移中，功能表面可通过测试但仍存在未迁移调用方。缺少删除门禁会导致旧路径过早移除并产生回归。

## ✅ 范围

- 仅在存在旧路径、兼容层或渐进迁移时启用门禁。
- 验证剩余引用和调用方迁移状态。
- 记录适配器保留或删除决策。
- 要求可重复的删除安全证据后才能移除旧路径。

## ❌ 非范围

- 不要求简单、一次性重构建立迁移清单。
- 不改变公共 API 兼容性规则。
- 不把行为变更包装为 Refactor。

## 验收标准

1. 有旧路径的 Refactor 在删除前完成引用与迁移验证。
2. 未完成迁移或证据不足会阻止删除。
3. 门禁只适用于确有迁移风险的场景。

## 依赖

- `S-027` Refactor 迁移开始契约。

## Open Questions

- 无。

## 相关文档

- [S-027 Refactor 迁移开始契约](S-027-refactor-migration-start-contract.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Refactor 旧路径删除门禁 Story。 | 防止未完成迁移时提前删除兼容路径。 |
