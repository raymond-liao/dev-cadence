# S-034 发布与生产交付能力规划

## 基本信息

- ID：`S-034`
- Version：`1`
- Status：`Dropped`
- Priority：`P3`
- Change Type：Feature

## 目标

规划 Dev Cadence 的 Release、Deployment、Post-deploy Verification 和 Incident/Hotfix 能力边界，为后续独立设计和实施建立工作项入口。

## 背景

当前 Dev Cadence 负责开发工作项从需求到业务验收的交付闭环，但尚未覆盖发布、部署、生产验证和事故处置。该方向需要先明确各 workflow 的职责和衔接，不能直接混入现有开发 workflow。

## ✅ 范围

- 分析 Release、Deployment、Post-deploy Verification 和 Incident/Hotfix 的职责边界。
- 定义这些能力与现有开发 workflow Completion 的输入输出关系。
- 识别需要拆分的后续 Feature、Story 或 Technical Task。
- 明确生产环境证据、审批、回滚和事故记录的所有者。

## ❌ 非范围

- 不在本 Story 中实现任何发布或生产 workflow。
- 不修改现有开发 workflow 的 Completion 行为。
- 不接入具体 CI/CD、云平台或事故管理产品。

## 验收标准

1. 四类能力的目标、边界、关系和主要持久化资产得到明确说明。
2. 后续可实施工作被拆分为独立卡片并形成建议顺序。
3. 规划不会把生产交付阶段直接塞入现有开发 workflow。

## 依赖

- 无强制前置依赖。

## 处置

当前没有已确认的发布、部署或生产交付目标。本卡仅枚举未来可能需要拆分的能力，不构成可独立交付的当前用户目标；未来出现明确目标时，应从 Discovery、Architecture Design 或 Work Item Planning 重新形成新的范围，而不是恢复本卡的旧假设。

## Open Questions

- [Q-020 发布与生产 workflow 拆分](../open-questions.md#q-020) 和 [Q-021 首个生产交付切片](../open-questions.md#q-021) 已随本卡 Dropped 转为 Superseded；在新的明确目标出现前不再保持为待决问题。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建发布与生产交付能力规划 Story。 | 将长期方向转成可追踪工作项，同时保持当前只规划、不实施的边界。 |
| 1 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Dropped，并终止 Q-020、Q-021 的当前待决状态。 | 本卡缺少当前已确认的产品目标和独立交付结果；保留为待处理项会制造无主的长期方向。 |
