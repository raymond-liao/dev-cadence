# B-013 Story Ready 错误依赖 Feature 关联

## 基本信息

- ID：`B-013`
- Version：`2`
- Status：`Ready`
- Priority：`P1`
- Change Type：Bug

## 问题目标

确保 Story 的 `Ready` 判断依据完整、已确认的工作项定义，而不是强制要求关联产品级 Feature。

## 期望行为

Story 在角色、目标、价值、范围、可观察行为、验收条件、依赖和阻塞性问题明确并经用户确认后，可以进入 `Ready`。已有 Feature 可以作为可选追踪关系；缺少 Feature 本身不构成阻塞。

## 已观察行为

当前 `work-item-analysis` 要求 Story 必须具有主 System Feature，并规定缺少 Feature identity 时返回 `discovery`。因此定义完整的仓库内部 Story 也无法进入 `Ready`，必须先建立与其目标无关的完整产品设计基线。

## 影响与严重程度

- 影响：不依赖产品级 Feature 的独立 Story 即使定义完整，也会被错误阻止进入 `Ready`，并产生与其目标无关的 Discovery 工作。
- 严重程度：`P1`。该问题会阻断 Story 从工作项分析进入交付的正常闭环，但不造成数据丢失或不可逆状态。

## 已知环境

- Dev Cadence `0.26.3`。
- source、dist 和当前安装包中的 `work-item-analysis` 均把主 Feature 作为 Story `Ready` 的必备条件。

## 证据分类

- 当前证据支持按 Bug 处理：用户已确认“所有 Story 必须关联 Feature”是错误的通用约束；本项纠正既有 Story `Ready` 行为，不新增或重新解释产品级 Feature 结论。
- S-042 是该错误规则的历史回归案例，不是被 B-013 阻塞的工作项。

## ✅ 包含范围

- 从 Story `Ready` 的通用必备条件中移除主 System Feature。
- 来自 Story Map 或已有 Feature 定义的 Story 必须保留已确认的主 Feature 追踪关系。
- 不依赖产品级 Feature 的独立或 direct-intake Story 可以不关联 Feature。
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
- 不改变 Story Map 继续按 System Feature 组织 Story 的规划结构。
- 不把 S-042 改成 Task。
- 不修改 S-042 的定义、版本或 `Ready` 状态。
- 不调查与该门禁无关的 Work Item Analysis 行为。

## 验收标准

1. Story `Ready` 的通用条件不再强制要求主 System Feature。
2. 来自 Story Map 或已有 Feature 定义的 Story 保留已确认的主 Feature；不依赖产品级 Feature 的独立 Story 没有 Feature 引用时仍可完成分析。
3. 缺少产品设计基线或 Feature identity 不会单独触发 `discovery`。
4. Story 需要新建或修改产品级结论时仍必须返回 `discovery`。
5. 定义完整的仓库内部 Story 可以在用户确认后进入 `Ready`。
6. 角色、目标、价值、范围、行为、验收条件、依赖和阻塞性问题仍是 Ready 判断依据。
7. Task、Bug 和 Delivery Workflow 入口资格不受影响。
8. 契约测试覆盖无 Feature 的独立 Story、已有 Feature 引用、真实产品结论缺口和 S-042 历史回归场景。
9. source、dist、安装包和根目录版本保持同步。

## 已知复现条件

- 仓库没有 `docs/product-design/` 或 `F-nnn` Feature。
- 创建一张角色、目标、价值、范围、行为、验收条件、依赖和阻塞性问题均已明确，但不依赖产品级 Feature 的独立 Draft Story。
- 请求通过 Work Item Analysis 将该 Story 更新为 `Ready`；[S-042 Dev Cadence 全流程主执行子代理委派](../stories/S-042-dev-cadence-primary-subagent-delegation.md)保留为历史回归参考。
- 当前规则因缺少主 System Feature 而阻止 Ready，并要求返回 Discovery。

## Relationships

- Affects：[S-037 工作项分析 Workflow](../stories/S-037-work-item-analysis-workflow.md)。
- Related：[B-012 Draft Story 在 Ready 门禁前被提前领取](B-012-draft-story-claimed-before-ready-gate.md)。
- Related：[S-042 Dev Cadence 全流程主执行子代理委派](../stories/S-042-dev-cadence-primary-subagent-delegation.md)，作为无 Feature 独立 Story 的历史回归案例。
- Blocks：无。

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
| 2 | 2026-07-19T19:51:19+0800 | Raymond Liao <raymond-liao@outlook.com> | 明确 Feature 追踪的适用边界、Bug 证据分类和影响，将 S-042 改为历史回归关联，并将状态更新为 `Ready`。 | 用户确认 B-013 不应阻塞已为 `Ready` 的 S-042；卡片定义已足以进入后续诊断。 |
