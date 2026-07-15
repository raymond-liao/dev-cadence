# S-017 工作项卡片与开发 Workflow 接入

## 基本信息

- ID：`S-017`
- Version：`2`
- Status：`Blocked`
- Priority：`P1`
- Change Type：Feature

## 目标

打通 Work Item Planning、Work Item Analysis、工作项卡片与 `feature-dev`、`bug-fix`、`refactor`，实现按意图路由、版本引用、职责边界和生命周期回写。

## 背景

工作项卡片只有被入口选择器和开发 workflow 稳定消费，才能成为长期权威定义。当前开发流程尚未统一检查卡片、引用版本或回写交付状态。

## ✅ 范围

- 更新 `using-dev-cadence`，根据用户目标、工作项类型、现有卡片和成熟度选择 Work Item Planning、Work Item Analysis 或 Delivery Workflow。
- 明确 `Draft Story -> work-item-analysis -> Ready Story -> feature-dev` 的默认路由和 Story 开发门禁。
- Task 可以选择先进入 Work Item Analysis，也可以在对应 Delivery Workflow 第一阶段补充并确认目标、范围和完成条件。
- Bug 可以选择先进入 Work Item Analysis，也可以直接进入 `bug-fix`；缺少 `Ready`、完整复现步骤或已知根因不得阻止诊断启动。
- 缺少卡片时按当前意图选择创建入口：规划或登记进入 Work Item Planning，定义分析进入 Work Item Analysis，直接 Bug 调查由 Bug Fix 创建或补充 Bug 卡片。
- 在开发 workflow 第一阶段记录卡片路径、版本和本次选定范围。
- 明确卡片与第一阶段记录的权威职责边界。
- 写回前检查当前卡片版本；卡片升版时判断当前 run 是否受影响并返回最早受影响阶段。
- 在开始、返工、验收和 Completion 后回写状态与交付引用。
- 对三个开发 workflow 建立类型和路由契约。

## ❌ 非范围

- 不在本 Story 中实现卡片创建 workflow。
- 不在本 Story 中实现 Work Item Analysis 的分析规则。
- 不重新设计 Story Map 或 Backlog 看板。
- 不把 workflow 内部阶段提升为工作项状态。

## 验收标准

1. 入口能够按用户意图、工作项类型和卡片成熟度选择 Planning、Analysis 或对应 Delivery Workflow。
2. `feature-dev` 只接收经过用户确认的 `Ready Story`，Task 和 Bug 使用各自明确的非统一门禁。
3. 已有卡片被复用；缺卡时由当前职责对应的 workflow 创建，不产生重复 ID 或平行卡片。
4. 每个开发 run 引用精确卡片路径、版本和本次范围，不复制完整卡片形成第二份权威定义。
5. 工作项状态、交付结果和 Backlog 投影在关键生命周期节点正确回写。
6. 卡片升版后能够判断当前 run 是否受影响并路由到最早受影响阶段。

## Story Relationships

- Follows：`S-015` 工作项规划 Workflow 与工作项契约。
- Follows：`S-016` 统一 Backlog 看板。
- Follows：`S-037` 工作项分析 Workflow。
- Precedes：`T-002` 需求治理端到端验证与安装契约。

## 依赖

- `S-015` 工作项规划 Workflow 与工作项契约。
- `S-016` 统一 Backlog 看板。
- `S-037` 工作项分析 Workflow。

## Open Questions

- 开发 run 进行中卡片升版时，影响判断由哪个 workflow 阶段负责？

## 相关文档

- [工作项规划流程](../workflows/work-item-planning.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [S-016 统一 Backlog 看板](S-016-unified-backlog-board.md)
- [S-037 工作项分析 Workflow](S-037-work-item-analysis-workflow.md)
- [T-002 需求治理端到端验证与安装契约](../tasks/T-002-requirements-governance-end-to-end-validation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建工作项卡片与开发 Workflow 接入 Story。 | 建立工作项权威定义到开发交付的完整消费和回写链路。 |
| 2 | 2026-07-15 | 增加 Work Item Analysis、按类型启动门禁、缺卡职责路由和版本变化处理，并将状态更新为 Blocked。 | 工作项规划与分析方案已经确认共享卡片维护权，开发入口不能继续把所有缺卡请求机械路由到 Planning。 |
