# S-017 工作项卡片与开发 Workflow 接入

## 基本信息

- ID：`S-017`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Feature

## 目标

打通工作项卡片与 `feature-dev`、`bug-fix`、`refactor`，实现缺卡路由、版本引用、职责边界和生命周期回写。

## 背景

工作项卡片只有被入口选择器和开发 workflow 稳定消费，才能成为长期权威定义。当前开发流程尚未统一检查卡片、引用版本或回写交付状态。

## ✅ 范围

- 更新 `using-dev-cadence` 检查请求对应的工作项卡片。
- 缺卡时路由到 Work Item Planning，不由开发 workflow 自行建卡。
- 在开发 workflow 第一阶段记录卡片路径、版本和本次选定范围。
- 明确卡片与第一阶段记录的权威职责边界。
- 在开始、返工、验收和 Completion 后回写状态与交付引用。
- 对三个开发 workflow 建立类型和路由契约。

## ❌ 非范围

- 不在本 Story 中实现卡片创建 workflow。
- 不重新设计 Story Map 或 Backlog 看板。
- 不把 workflow 内部阶段提升为工作项状态。

## 验收标准

1. 有卡请求复用现有卡片，缺卡请求先进入 Work Item Planning。
2. 每个开发 run 引用精确卡片版本和本次范围。
3. 工作项状态与交付引用在关键生命周期节点正确回写。
4. 卡片升版后能够判断当前 run 是否受影响。

## Story Relationships

- Follows：`S-016` 统一 Backlog 看板。
- Precedes：`T-002` 需求治理端到端验证与安装契约。

## 依赖

- `S-015` 工作项规划 Workflow 与工作项契约。
- `S-016` 统一 Backlog 看板。

## Open Questions

- 开发 run 进行中卡片升版时，影响判断由哪个 workflow 阶段负责？

## 相关文档

- [工作项规划流程](../workflows/work-item-planning.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [S-016 统一 Backlog 看板](S-016-unified-backlog-board.md)
- [T-002 需求治理端到端验证与安装契约](../tasks/T-002-requirements-governance-end-to-end-validation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建工作项卡片与开发 Workflow 接入 Story。 | 建立工作项权威定义到开发交付的完整消费和回写链路。 |
