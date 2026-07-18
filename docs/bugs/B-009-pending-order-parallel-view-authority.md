# B-009 待处理排序与并行视图职责不一致

## 基本信息

- ID：`B-009`
- Version：`1`
- Status：`In Progress`
- Priority：`P1`
- Change Type：Bug

## 问题目标

修正统一 Backlog 同时维护“待处理”行顺序和“当前可并行实施表”独立顺序，并在并行表中重复保存 Workflow 入口规则的问题，避免 AI 从不同视图得到不同的下一工作项或使用过期路由信息。

## 预期行为

“待处理”从上到下是唯一权威的建议实施顺序。“当前可并行实施表”仅按待处理顺序和依赖关系形成便于 AI 读取的派生视图，不得维护独立排序。待处理首项暂时不能推进时，必须先通过 Work Item Planning 确认并调整待处理顺序，再开始后续工作项，不能保留原顺序并静默跳过。

并行表不再展示“下一步 Workflow / 入口门禁”列。表中状态只表达工作项生命周期，不表达 Workflow 入口资格；具体路由继续由 `using-dev-cadence` 根据用户请求、卡片类型、状态和既有门禁规则判断。

## 已观察行为

当前“待处理”首项是 `S-017`，但“当前可并行实施表”在其前面列出 `B-005`、`B-007` 和 `B-008`，导致同一 Backlog 存在两个不同的下一项判断。并行表还逐行保存“下一步 Workflow / 入口门禁”，重复了 `using-dev-cadence` 和各 Workflow 的路由职责。

## ✅ 范围

- 明确“待处理”行顺序是 Backlog 唯一权威的建议实施顺序。
- 将“当前可并行实施表”定义为按待处理顺序和依赖关系生成的派生视图，保持工作项相对顺序一致。
- 明确待处理首项不能推进时，必须先确认并调整排序，不得静默领取后续工作项。
- 删除并行表的“下一步 Workflow / 入口门禁”列，并以表级说明明确生命周期状态与入口资格的边界。
- 保持 Workflow 路由规则由 `using-dev-cadence` 和对应 Workflow skill 负责，不在 Backlog 逐行复制。
- 协调 `S-017`，使工作项领取以待处理顺序为准，并把并行表仅作为依赖与并行关系的辅助视图。
- 更新 Work Item Planning 源规则、Backlog 展示、分发包和相关契约验证。

## ❌ 非范围

- 不在本 Bug 中修正 `B-005`、`B-007` 或 `B-008` 的历史完成状态与 Backlog 回写。
- 不改变工作项状态枚举、Priority 定义或各 Workflow 已确认的入口门禁。
- 不实现自动优先级评分、自动重排或无人确认的任务选择。
- 不实现 `S-017` 的完整工作项领取和 Delivery Workflow 接入。
- 不新增独立 Workflow、排序 skill 或共享能力 skill。

## 验收标准

1. “待处理”从上到下是唯一权威的建议实施顺序，其他 Backlog 视图不得形成独立顺序。
2. “当前可并行实施表”中的工作项相对顺序与待处理一致，并只补充依赖和并行分组信息。
3. 待处理首项不能推进时，入口不会静默选择后续工作项；必须先完成经确认的排序调整。
4. 并行表不再包含“下一步 Workflow / 入口门禁”列，表级说明明确状态不等于入口资格。
5. Workflow 路由继续由 `using-dev-cadence` 和对应 Workflow skill 判断，Backlog 不复制逐项路由规则。
6. `S-017` 的工作项领取定义以待处理顺序为准，不再把并行表作为另一套领取顺序。
7. source、dist、Backlog 示例和相关契约验证保持一致。

## 已知复现条件

- 打开 `docs/backlog.md`，比较“待处理”和“当前可并行实施表”的首项及相对顺序。
- 检查并行表的“下一步 Workflow / 入口门禁”列，并与 `using-dev-cadence` 的路由规则比较。

## 依赖

- 无强制前置依赖。

## Relationships

- Affected workflow：Work Item Planning。
- Precedes：`S-017` 工作项卡片与开发 Workflow 接入。
- Related：`S-016` 统一 Backlog 看板。
- Related：`B-007` 当前可并行实施表混用卡片状态与流程入口资格。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)
- [S-016 统一 Backlog 看板](../stories/S-016-unified-backlog-board.md)
- [S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)
- [B-007 当前可并行实施表混用卡片状态与流程入口资格](B-007-parallel-work-table-entry-qualification.md)
- [工作项规划流程](../workflows/work-item-planning.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-18T09:03:20+0800 | Raymond Liao <raymond-liao@outlook.com> | 创建待处理排序权威与并行视图职责 Bug，并将状态设为 Ready。 | 用户已确认待处理行顺序应作为唯一实施顺序，并行表只服务 AI 阅读且不应复制 Workflow 入口门禁；卡片没有未决问题。 |
| 1 | 2026-07-18T13:40:19+0800 | Raymond Liao <raymond-liao@outlook.com> | 将状态更新为 In Progress。 | 用户明确要求开始实施 B-009，并使用子任务执行。 |
