# B-013 Story Ready 错误依赖 Feature 关联

## 基本信息

- ID：`B-013`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Bug

## 问题目标

确保 Story 的 `Ready` 判断依据完整、已确认的工作项定义，而不是强制要求关联产品级 Feature。

## 期望行为

Story 在角色、目标、价值、范围、可观察行为、验收条件、依赖和阻塞性问题明确并经用户确认后，可以进入 `Ready`。已有 Feature 可以作为可选追踪关系；缺少 Feature 本身不构成阻塞。

## 已观察行为

当前 `work-item-analysis` 要求 Story 必须具有主 System Feature，并规定缺少 Feature identity 时返回 `discovery`。因此定义完整的仓库内部 Story 也无法进入 `Ready`，必须先建立与其目标无关的完整产品设计基线。

## ✅ 包含范围

- 从 Story `Ready` 必备条件中移除主 System Feature。
- 保留对已有确认 Feature 的可选引用能力。
- 缺少 Feature 或产品设计基线不得单独触发 `discovery`。
- 只有 Story 确实依赖新的或变化的产品级结论时才返回 `discovery`。
- 保持角色、目标、价值、范围、行为、验收条件、依赖、Open Questions 和用户确认门。
- 更新 `work-item-analysis`、相关入口语义和契约测试。
- 保持 Task、Bug 及 Delivery Workflow 的现有类型边界。
- 同步 source、dist、安装包和根目录 `version`。

## ❌ 排除范围

- 不删除 Story 对已有 Feature 的可选追踪关系。
- 不允许 Work Item Analysis 创建、修改或重新解释 Feature。
- 不降低 Story 其他 Ready 条件。
- 不修改 User Journey、PRD、Business Architecture 或 Story Map。
- 不把 S-042 改成 Task。
- 不在本 Bug 中直接把 S-042 更新为 `Ready`。
- 不调查与该门禁无关的 Work Item Analysis 行为。

## 验收标准

1. Story `Ready` 条件不再包含强制主 System Feature。
2. Story 可以引用已有确认 Feature，但没有 Feature 引用时仍可完成分析。
3. 缺少产品设计基线或 Feature identity 不会单独触发 `discovery`。
4. Story 需要新建或修改产品级结论时仍必须返回 `discovery`。
5. 定义完整的仓库内部 Story 可以在用户确认后进入 `Ready`。
6. 角色、目标、价值、范围、行为、验收条件、依赖和阻塞性问题仍是 Ready 判断依据。
7. Task、Bug 和 Delivery Workflow 入口资格不受影响。
8. 契约测试覆盖无 Feature Story、可选 Feature 引用、真实产品结论缺口和 S-042 复现场景。
9. source、dist、安装包和根目录版本保持同步。

## 已知复现条件

- 仓库没有 `docs/product-design/` 或 `F-nnn` Feature。
- 创建定义完整的 [S-042 Dev Cadence 全流程主执行子代理委派](../stories/S-042-dev-cadence-primary-subagent-delegation.md)。
- 请求通过 Work Item Analysis 将 S-042 更新为 `Ready`。
- 当前规则因缺少主 System Feature 而阻止 Ready，并要求返回 Discovery。

## Relationships

- Affects：[S-037 工作项分析 Workflow](../stories/S-037-work-item-analysis-workflow.md)。
- Related：[B-012 Draft Story 在 Ready 门禁前被提前领取](B-012-draft-story-claimed-before-ready-gate.md)。
- Blocks：[S-042 Dev Cadence 全流程主执行子代理委派](../stories/S-042-dev-cadence-primary-subagent-delegation.md)进入 `Ready`。

## 依赖

- 无。

## Open Questions

- 无。

## 相关文档

- [S-037 工作项分析 Workflow](../stories/S-037-work-item-analysis-workflow.md)
- [B-012 Draft Story 在 Ready 门禁前被提前领取](B-012-draft-story-claimed-before-ready-gate.md)
- [S-042 Dev Cadence 全流程主执行子代理委派](../stories/S-042-dev-cadence-primary-subagent-delegation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
| ---: | --- | --- | --- | --- |
| 1 | 2026-07-19T13:02:09+08:00 | Raymond Liao <raymond-liao@outlook.com> | 创建 Story Ready Feature 强制关联 Bug 卡。 | 用户确认 Story 不必须关联 Feature，当前规则错误阻止定义完整的 Story 进入 Ready。 |
