# B-014 单项建卡被错误套用双确认门

## 基本信息

- ID：`B-014`
- Version：`1`
- Status：`Done`
- Priority：`P3`
- Change Type：Bug

## 问题目标

让明确的单卡建卡请求只经过一次有价值的完整结果确认，避免重复确认用户已经表达清楚的输入与范围。

## 期望行为

`work-item-planning` 的 `direct intake` 模式用于用户已经提出一个明确 Story、Task 或 Bug 的单项建卡请求。该模式在必要澄清完成后，应一次性展示卡片内容、ID、路径、Priority、关系和 Backlog 位置；用户确认后原子写入卡片及必要规划引用。

## 已观察行为

当前 `work-item-planning` 对 `portfolio planning` 和 `direct intake` 共用以下阶段：

```text
Planning Inputs And Scope Confirmation
-> Planning Structure Proposal
-> Planning Result Confirmation
```

因此，明确的单项建卡请求仍要先确认一次输入范围，再确认一次完整卡片。S-042 和 B-013 的建卡过程均复现了该问题。

## ✅ 包含范围

- `direct intake` 改为单一合并确认门。
- 不清楚的内容继续通过必要问题澄清，但澄清不形成额外正式门禁。
- 合并确认一次展示完整卡片和必要 Backlog 变化。
- 用户可以确认完整结果、只确认命名子集或要求修改。
- `portfolio planning` 保留输入范围与规划结果两道确认门。
- 更新 Work Item Planning、契约测试、source、dist、安装包和根目录 `version`。

## ❌ 排除范围

- 不取消所有建卡确认。
- 不改变 Portfolio Planning 的双确认门。
- 不绕过用户对 Priority、Backlog 位置、依赖和批量规划的决定权。
- 不修改 Work Item Analysis、Delivery Workflow 或 Business Acceptance 门禁。
- 不自动改写已经创建的历史卡片。

## 验收标准

1. 明确的单项建卡请求只出现一次正式确认。
2. 必要澄清不会被包装成独立范围确认门。
3. 合并确认包含完整卡片及全部必要 Backlog 变化。
4. 用户确认后卡片和 Backlog 原子写入。
5. Portfolio Planning 继续使用两道确认门。
6. 契约测试分别覆盖 Direct Intake 单确认和 Portfolio Planning 双确认。
7. source、dist、安装包和版本保持同步。

## 已知复现条件

- 用户已经在当前会话中明确一个 Story、Task 或 Bug 的目标和范围。
- 用户明确要求创建该单张卡片并登记到 Backlog。
- Work Item Planning 先要求确认输入与范围，然后再次要求确认完整卡片和 Backlog 结果。

## Relationships

- Affects：[S-015 工作项规划 Workflow 与工作项契约](../stories/S-015-work-item-planning-workflow-contract.md)。
- Related：[S-042 Dev Cadence 全流程主执行子代理委派](../stories/S-042-dev-cadence-primary-subagent-delegation.md)。
- Related：[B-013 Story Ready 错误依赖 Feature 关联](B-013-story-ready-feature-reference-required.md)。
- Blocks：无。

## 依赖

- 无。

## Open Questions

- 无。

## 相关文档

- [S-015 工作项规划 Workflow 与工作项契约](../stories/S-015-work-item-planning-workflow-contract.md)
- [S-042 Dev Cadence 全流程主执行子代理委派](../stories/S-042-dev-cadence-primary-subagent-delegation.md)
- [B-013 Story Ready 错误依赖 Feature 关联](B-013-story-ready-feature-reference-required.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
| ---: | --- | --- | --- | --- |
| 1 | 2026-07-19T13:08:29+08:00 | Raymond Liao <raymond-liao@outlook.com> | 创建单项建卡双确认门 Bug 卡。 | 用户确认明确的单项建卡请求只需要一次完整结果确认，当前两道正式门禁产生了重复交互。 |
| 1 | 2026-07-19T15:03:31+08:00 | Raymond Liao <raymond-liao@outlook.com> | 将状态更新为 `In Progress`。 | 用户明确要求同时并行修复 B-012、B-010 和 B-014；本次只改变执行状态，不改变卡片定义。 |
| 1 | 2026-07-19T16:22:40+08:00 | Raymond Liao <raymond-liao@outlook.com> | 将状态更新为 `Done`。 | B-014 已完成业务验收并本地合并到 `main`；Version 保持为 `1`。 |
