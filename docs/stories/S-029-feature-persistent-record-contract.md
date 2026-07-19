# S-029 Feature 持久化记录契约

## 基本信息

- ID：`S-029`
- Version：`1`
- Status：`Draft`
- Priority：`P3`
- Change Type：Feature

## 目标

确保 feature-dev 的 requirements 和 technical solution 记录能够在会话中断后重建已确认范围、验收标准和方案约束。

## 背景

如果关键确认只存在于对话中，恢复运行时可能无法判断用户确认了什么，进而错误扩大范围或采用过期方案。持久化记录需要保存足够的业务和技术决策语义。

## ✅ 范围

- 定义 requirements 记录恢复范围和验收标准所需的最小字段。
- 定义 technical solution 记录恢复已确认方案和约束所需的最小字段。
- 验证中断后可仅依赖仓库记录继续 workflow。
- 保持记录职责与工作项卡片、manifest 分离。

## ❌ 非范围

- 不复制完整聊天记录。
- 不改变 Bug Fix 或 Refactor 的记录契约。
- 不在本 Story 中实现工作项卡片接入。

## 验收标准

1. requirements 记录足以恢复已确认范围、非范围和验收标准。
2. technical solution 记录足以恢复方案选择、关键约束和未决事项。
3. 契约测试覆盖会话中断后的恢复所需字段。

## 依赖

- `S-017` 工作项卡片与开发 Workflow 接入。

## Open Questions

- 无。

## 相关文档

- [S-017 工作项卡片与开发 Workflow 接入](S-017-work-item-development-workflow-integration.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Feature 持久化记录契约 Story。 | 提升会话中断后的可靠恢复和审计质量。 |
