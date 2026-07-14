# T-002 需求治理端到端验证与安装契约

## 基本信息

- ID：`T-002`
- Version：`1`
- Status：`Draft`
- Priority：`P2`
- Change Type：Quality Engineering

## 任务目标

验证从想法、PRD、工作项规划到三个开发 workflow 交付及 Backlog 回写的完整链路，并覆盖构建、安装包、入口路由和现有目标仓库兼容。

## 背景

各阶段的局部契约通过并不能证明整条需求治理链路可以在安装后的目标仓库中闭环。需要一项独立技术任务验证跨 workflow 路由、资产传递和兼容性。

## ✅ 范围

- 覆盖想法到首次 PRD、工作项规划和开发 workflow 移交。
- 分别覆盖 feature-dev、bug-fix 和 refactor 的代表性路径。
- 验证工作项状态、交付引用和 Backlog 回写。
- 验证 source、dist、安装包和入口路由一致性。
- 验证现有目标仓库在升级后的兼容行为。

## ❌ 非范围

- 不在验证任务中补做缺失产品能力。
- 不以 demo 记录替代自动化或可重复契约检查。
- 不扩展发布与生产交付范围。

## 完成条件

1. 完整链路在临时目标仓库中可重复执行和验证。
2. 三个开发 workflow 均覆盖卡片消费与 Backlog 回写。
3. 构建、安装和兼容性检查对失败提供可定位证据。

## Task Relationships

- Follows：`S-015`、`S-016`、`S-017`、`S-004`。

## 依赖

- `S-015` 工作项规划 Workflow 与工作项契约。
- `S-016` 统一 Backlog 看板。
- `S-017` 工作项卡片与开发 Workflow 接入。
- `S-004` 实施与测试失败分类和阶段返回。

## Open Questions

- 哪些代表性路径足以覆盖升级兼容，而不会把测试固化为单一实现？

## 相关文档

- [S-004 实施与测试失败分类和阶段返回](../stories/S-004-failure-classification-stage-routing.md)
- [S-015 工作项规划 Workflow 与工作项契约](../stories/S-015-work-item-planning-workflow-contract.md)
- [S-016 统一 Backlog 看板](../stories/S-016-unified-backlog-board.md)
- [S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建需求治理端到端验证任务。 | 用安装后的完整链路验证跨 workflow 契约和兼容性。 |
