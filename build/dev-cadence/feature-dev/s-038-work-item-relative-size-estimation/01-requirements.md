# S-038 需求确认

## 工作项身份

- Work Item: [S-038 工作项相对 Size 估算](../../../../../docs/stories/S-038-work-item-relative-size-estimation.md)
- Work Item Type: `Story`
- Work Item Version: `1`
- Current Status: 🔄 `in_progress`
- Selected Scope: S-038 的已确认相对 Size 估算能力。

## 目标

让 Work Item Planning 能以一张用户确认的代表性工作项为 `M` 基准，对 Story、必要 Task、独立 Task 与进入 Iteration Plan 的 Bug 使用一致、可解释且可重新校准的相对 Size，从而比较 Path 和 Milestone 的规模分布。

## ✅ 范围

- 在 Work Item Planning 中使用 `XS / S / M / L / XL / ?` 作为唯一的相对 Size 集合。
- 在已有 Story Map 和轻量工作项形成后，提出具备清晰范围、适中规模和代表性的基准卡候选及理由；用户确认后将其固定为 `M`。
- 相对基准卡估算 Story Map 内 Story、必要 Task、独立 Task 和进入 Iteration Plan 的 Bug，并展示每张卡的 Size、Path/Milestone 分布、`?`、`XL` 与显著不确定性。
- 增量规划默认复用有效基准卡；基准卡删除、`Superseded` 或范围实质变化时，重新选择并要求用户确认。
- 用户可调整单张卡的 Size，或更换基准卡后重新估算。
- 将已确认 Size 同步至卡片、Story Map、Backlog 和相应 Change Log；仅 Size 变化不得递增卡片定义 Version。
- 其他 workflow 在发现范围变化可能使 Size 失效时，只标记需重新估算，不得自行修改 Size。

## ❌ 非范围

- 不将 Size 换算为人日、工期或跨团队通用容量。
- 信息不足时不猜测 Size；此类项保持 `?`。
- 不创建 Story Map、Milestone、工作项卡片或 Backlog 基础结构。
- 不形成 Iteration Plan 或校准团队容量；该范围仍属于 S-039。
- 不修改工作项目标、范围、验收条件或产品设计基线。

## 验收标准

1. Work Item Planning 使用唯一的 `XS / S / M / L / XL / ?` 相对 Size 集合。
2. 基准候选、选择理由和 `M` 赋值经用户确认。
3. 其余工作项相对基准估算，并呈现 Path、Milestone、`?`、`XL` 和不确定性汇总。
4. 信息不足项保持 `?`，不产生虚假精度或人日换算。
5. 已确认 Size 在卡片、Story Map 与 Backlog 同步，Size-only 修改不递增卡片版本。
6. 基准卡失效或范围变化会触发重新估算，而不是被其他 workflow 静默改写。
7. 契约测试覆盖首次估算、基准复用、基准失效和不确定性呈现。

## 业务规则

- Size 同时表达相对工作量、复杂度与已知不确定性，不表达时间。
- `?` 是有效且必须保留的估算结果，不得为完成规划而强制替换为确定等级。
- `XL` 与明显不确定项必须在汇总中显式呈现。
- Size 的所有权属于 Work Item Planning；其他 workflow 只能标记重新估算需要。

## 假设

- S-015 的 Work Item Planning、Story Map、轻量卡片与 Backlog 边界已可复用。
- S-039 仍独立拥有 Iteration Plan 和容量校准，不会随本卡创建。
- 实现将修改可安装 workflow 规则和契约测试；根目录 `version` 是否更新将在实现变更形成后按仓库规则评估。

## Open Questions

无。

## Direct Input Identities

| Source | SHA-256 |
| --- | --- |
| `docs/stories/S-038-work-item-relative-size-estimation.md` | `25d3fcc4e5187f19095fcdab641a8c19be3f2553ce4b56e02ae272eafe974a49` |
| `docs/stories/S-015-work-item-planning-workflow-contract.md` | `ff32002e373516df15c2683867037c91aef7b8b29310e2178513a92cba8ece36` |
