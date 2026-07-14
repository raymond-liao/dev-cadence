# S-001 首次 Discovery 与产品设计基线

## 基本信息

- ID：`S-001`
- Version：`6`
- Status：`Done`
- Priority：`P1`
- Change Type：New

## 目标

让目标仓库能够从一个不完整的想法、反馈、业务问题或产品方向开始，通过独立的 `discovery` workflow 形成并确认第一版 PRD 和 Business Architecture，为后续工作项规划提供稳定的产品设计基线。

## 背景

当前 Dev Cadence 从功能开发、Bug 修复或重构任务开始，缺少把模糊想法整理成产品需求基线的上游流程。用户不应被要求在进入 workflow 前自行提供完整需求。

## User Story

作为需要规划软件产品或新能力的用户，我希望在开始开发前明确要解决的问题、目标、范围和约束，以便团队对要做什么形成一致理解。

## 范围

- 新增 `discovery` workflow skill。
- 支持从模糊输入探索背景、目标用户、问题、价值、成功标准、范围、非范围、约束和开放问题。
- 在 `docs/product-design/` 下创建 PRD 和 Business Architecture。
- 创建两份文档的版本 `1` 和各自的 Change Log。
- PRD 保存产品目标、用户价值、范围、能力、需求、约束、开放问题、拒绝方向和未来范围。
- Business Architecture 保存业务角色、业务域、能力、流程、业务对象、状态、规则、异常和外部边界。
- 统一使用 `Open Questions` 保存未解决事项，不建立 `Draft Ideas` 或 `Pending Decisions`。
- 获取用户对两份文档组成的完整产品设计基线的一次确认，并把确认证据保存在 workflow 运行记录中。
- 将 `discovery` 接入 `using-dev-cadence`、构建流程和安装包。

## 非范围

- 不实现已有产品设计文档的增量更新和升版；由 `S-002` 处理。
- 不创建 Feature、Story、Bug 或 Technical Task 卡片。
- 不维护工作项 Roadmap。
- 不实现 `work-item-planning` workflow。
- 不设计技术架构。
- 不修改目标仓库应用代码。

## 验收标准

1. 用户可以从一个不完整想法启动 `discovery`，不需要预先提供完整需求或验收标准。
2. workflow 能形成 `docs/product-design/prd.md` 版本 `1`，包含产品目标、用户、价值、成功标准、范围、非范围、能力、需求、约束、`Open Questions`、`Rejected Directions`、`Future Scope` 和 Change Log。
3. workflow 能形成 `docs/product-design/business-architecture.md` 版本 `1`，包含业务角色、业务域、业务能力、价值流、流程、业务对象、状态、规则、策略、异常、外部边界、`Open Questions`、`Rejected Directions` 和 Change Log。
4. 未解决内容只保存在 `Open Questions`，不会被静默提升为已确认的产品或业务架构内容。
5. 用户确认完整产品设计基线前，workflow 不宣称 Discovery 完成；确认信息只记录在 run manifest 和确认记录中。
6. `discovery` 不创建工作项卡片、不设计技术架构，也不修改应用代码。
7. 源 skill、入口选择器和构建后的安装包包含一致的 Discovery workflow。

## Story Relationships

- Blocks：无；`S-002` 的前置依赖已满足。

## 依赖

- 无前置 Story。

## 后续工作

- `S-002` 在该产品设计基线能力上增加增量更新和版本治理。
- Work Item Planning workflow 读取确认后的 PRD 和 Business Architecture 并建立工作项。

## Open Questions

- 无。

## 相关文档

- [需求探索流程](../workflows/discovery.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-13 | 创建首次 Discovery 与 PRD 基线 Story。 | 将原 Discovery workflow 大任务拆成可独立交付的首次建立和增量维护能力。 |
| 2 | 2026-07-13 | 补充 User Story、Story Relationships 和 Open Questions。 | 明确用户价值、后续阻塞关系和当前问题状态。 |
| 3 | 2026-07-13 | 重写 User Story，移除 Dev Cadence、PRD 和 workflow 实现表述。 | User Story 应表达用户目标和价值，而不是内部实现方式或交付物。 |
| 4 | 2026-07-13 | 将状态更新为 In Progress。 | 已启动对应的 feature-dev workflow run。 |
| 5 | 2026-07-13 | 将范围更新为 PRD 与 Business Architecture 两文档基线，并完成待验收实现。 | Discovery skill、入口路由、产品设计文档契约、构建安装契约和公开说明已实现，等待 Business Acceptance。 |
| 6 | 2026-07-14 | 将状态更新为 Done，并解除 S-002 的前置阻塞。 | 用户选择 `1. Accept`，S-001 已通过 Business Acceptance。 |
