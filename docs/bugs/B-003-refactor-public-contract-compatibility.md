# B-003 Refactor 公共契约兼容性

## 基本信息

- ID：`B-003`
- Version：`1`
- Status：`Done`
- Priority：`P1`
- Change Type：Bug

## 问题目标

修正 Refactor workflow 中允许收窄公共 API、同时又要求保持外部行为兼容的规则矛盾。

## 预期行为

Refactor 只能收窄内部接口；公共 API 和外部数据形状必须保持兼容。主动改变外部契约应转入 `feature-dev`，恢复损坏的既有契约应转入 `bug-fix`。

## 已观察行为

Refactor 方法目录曾把 `narrow public API` 列为可用方法，与行为保持和公共契约兼容原则冲突，可能允许在 Refactor 中实施未经确认的外部行为变化。

## ✅ 范围

- 将公共 API 收窄修正为内部接口收窄。
- 明确公共 API 和外部数据形状必须保持兼容。
- 允许通过兼容适配器保护外部契约。
- 明确主动契约变化和缺陷恢复的 workflow 路由。
- 增加契约测试防止矛盾措辞回归。

## ❌ 非范围

- 不禁止内部接口和内部数据结构重构。
- 不在 Refactor 中实现主动公共契约变化。
- 不改变 feature-dev 或 bug-fix 的阶段结构。

## 验收标准

1. Refactor 方法目录不再允许 `narrow public API`。
2. 规则明确只允许收窄内部接口并保持外部契约兼容。
3. 主动外部契约变化和缺陷恢复分别路由到正确 workflow。
4. 契约测试覆盖禁止公共 API 收窄和外部兼容性要求。

## 依赖

- 无强制前置依赖。

## 历史交付证据

- Fix Commit：`8f577ea8b3c2639c089fa6b691997801c46a61dc`。
- 主要修改：`src/skills/refactor/SKILL.md`。
- 验证契约：`tests/workflow-symmetry.sh`。
- 版本在该提交中从 `0.8.3` 更新为 `0.8.4`。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 根据既有修复和 Git 历史补录已完成 Bug。 | 原缺陷已在 `8f577ea` 修复，但 Backlog 仅保留纯文本完成项。 |
