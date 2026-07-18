# B-007 当前可并行实施表混用卡片状态与流程入口资格

## 基本信息

- ID：`B-007`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Bug

## 问题目标

修正“当前可并行实施表”把工作项卡片生命周期状态、依赖可用性和下游 Workflow 入口资格混为一个 `状态` 字段的问题，避免用户误判 Draft 工作项是否可以启动对应流程。

## 预期行为

并行实施视图应保留工作项卡片的规范状态，同时单独表达当前可启动的下游 Workflow 和前置门禁。Bug 卡片为 `Draft` 时可以进入 `bug-fix` 的问题诊断，但不能因此跳过 Repair Solution、Repair Plan 或直接修改代码；Story、Task 和 Bug 继续使用各自的入口规则。

## 已观察行为

当前表名为“当前可并行实施表”，表内同时存在 `Draft` 和 `Blocked` 工作项，末尾说明又把 `Draft` 概括为不能直接进入实施。与此同时，现行规则允许 Bug 在没有 `Ready` 或已知根因时进入 `bug-fix`，导致表格中的 `Draft` 看起来像不可启动，但实际又可能可以启动诊断。

## ✅ 范围

- 明确并行视图展示的是工作项候选、流程启动资格还是代码实施资格，并使标题、说明和字段语义一致。
- 保留 `Draft`、`Ready`、`In Progress`、`Blocked`、`Done`、`Superseded` 和 `Dropped` 作为唯一工作项状态。
- 将卡片状态与“下一步入口/门禁”分开表达，至少覆盖 Story、Task 和 Bug 的差异。
- 明确 `Draft Bug -> bug-fix 诊断` 不等于可以直接进入修复实现。
- 保留依赖表和并行序号的排序、依赖和用户授权边界。
- 增加对应的源规则、Backlog 展示和契约验证。

## ❌ 非范围

- 不新增 `可实施`、`可启动` 或其他全局工作项状态。
- 不改变 Bug、Story 或 Task 各自已经确认的 Workflow 入口门禁。
- 不把 Workflow 内部阶段投影为 Backlog 状态。
- 不自动启动并行工作项，不改变用户授权要求。
- 不机械重排无关的 Backlog 或并行序号。

## 验收标准

1. 并行视图不再用单一 `状态` 字段同时表达卡片生命周期和下游入口资格。
2. `Draft` Bug 明确显示为可以启动 `bug-fix` 诊断，但不能直接修改代码。
3. `Draft` Story、`Draft` Task 和 `Draft` Bug 的下一步入口及门禁差异可被用户直接识别。
4. `Blocked` 明确表示依赖阻塞，不与工作项自身仍为 `Draft` 的成熟度混淆。
5. 规范工作项状态枚举保持不变，依赖表、并行序号和用户授权语义保持不变。
6. source、dist、安装包和相关契约验证保持一致。

## 已知复现条件

- 打开 `docs/backlog.md` 的“当前可并行实施表”。
- 观察表中 `Draft` 工作项与“不能直接进入实施”的统一说明。
- 对比 Work Item Planning 中允许 Bug 在非 `Ready` 状态进入 `bug-fix` 的规则。

## 依赖

- 无强制前置依赖。

## Open Questions

- Q-005：并行视图最终采用“当前可并行推进表”还是保留原名称，并将入口资格作为独立列展示？

## 相关文档

- [Backlog](../backlog.md)
- [S-016 统一 Backlog 看板](../stories/S-016-unified-backlog-board.md)
- [S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)
- [工作项规划流程](../workflows/work-item-planning.md)
- [工作项分析流程](../workflows/work-item-analysis.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-17 | 创建并行视图状态与 Workflow 入口资格混用 Bug。 | 用户指出 Draft Bug 仍可能进入 bug-fix，当前表的“状态”语义不足以表达该差异。 |
