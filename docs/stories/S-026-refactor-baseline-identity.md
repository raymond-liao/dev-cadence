# S-026 Refactor 基线身份

## 基本信息

- ID：`S-026`
- Version：`1`
- Status：`Draft`
- Priority：`P2`
- Change Type：Refactor

## 目标

将 Refactor 行为基线绑定到重构前的精确版本，防止使用重构后的行为重新定义原始预期。

## 背景

行为保持验证只有在基线身份稳定时才有意义。如果基线随实现变化而漂移，回归可能被错误吸收到“当前行为”中。

## ✅ 范围

- 记录重构前的 commit、branch 和 tracked working-tree 状态。
- 将 characterization、contract test 或其他行为证据关联到该基线。
- 当基线变化时要求重新建立或明确失效。
- 在最终验证中引用同一基线身份。

## ❌ 非范围

- 不把未确认的现有缺陷自动定义为期望行为。
- 不允许 Refactor 主动改变公共行为。
- 不替代最终验证版本绑定。

## 验收标准

1. Refactor 开始前保存可复现的行为基线身份。
2. 基线后的代码变化不会静默重定义原始预期。
3. 实施和验证证据可追溯到同一重构前版本。

## 依赖

- 无强制前置依赖。

## Open Questions

- Q-015：未提交但已跟踪的基线差异应如何形成稳定身份？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Refactor 基线身份 Story。 | 防止行为基线随重构结果漂移。 |
