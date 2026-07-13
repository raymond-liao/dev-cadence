# S-001 首次 Discovery 与 PRD 基线

## 基本信息

- ID：`S-001`
- Version：`3`
- Status：`Ready`
- Priority：`P1`
- Change Type：New

## 目标

让目标仓库能够从一个不完整的想法、反馈、业务问题或产品方向开始，通过独立的 `discovery` workflow 形成并确认第一版 PRD，为后续工作项规划提供稳定的需求基线。

## 背景

当前 Dev Cadence 从功能开发、Bug 修复或重构任务开始，缺少把模糊想法整理成产品需求基线的上游流程。用户不应被要求在进入 workflow 前自行提供完整需求。

## User Story

作为需要规划软件产品或新能力的用户，我希望在开始开发前明确要解决的问题、目标、范围和约束，以便团队对要做什么形成一致理解。

## 范围

- 新增 `discovery` workflow skill。
- 支持从模糊输入探索背景、目标用户、问题、价值、成功标准、范围、非范围、约束和开放问题。
- 定义 PRD 的默认路径和基础结构。
- 创建 PRD 版本 `1` 和初始 Change Log。
- 区分 `Confirmed`、`Draft`、`Open Question`、`Rejected` 和 `Future Scope`。
- 在 PRD 中保存产品级 Decision。
- 获取用户对 PRD 基线版本的确认。
- 将 `discovery` 接入 `using-dev-cadence`、构建流程和安装包。

## 非范围

- 不实现已有 PRD 的增量更新和升版；由 `S-002` 处理。
- 不创建 Feature、Story、Bug 或 Technical Task 卡片。
- 不维护工作项 Roadmap。
- 不实现 `work-item-planning` workflow。
- 不修改目标仓库应用代码。

## 验收标准

1. 用户可以从一个不完整想法启动 `discovery`，不需要预先提供完整需求或验收标准。
2. workflow 能形成包含目标、用户、价值、成功标准、范围、非范围、约束、开放问题和产品级 Decision 的 PRD 版本 `1`。
3. PRD 明确区分已确认、草稿、开放问题、已拒绝和未来范围，不会把未确认内容静默提升为已确认需求。
4. 用户确认 PRD 基线前，workflow 不宣称需求探索完成。
5. `discovery` 不创建工作项卡片或修改应用代码。
6. 源 skill、入口选择器和构建后的安装包包含一致的 Discovery workflow。

## Story Relationships

- Blocks：`S-002` PRD 增量更新与版本治理。

## 依赖

- 无前置 Story。

## 后续工作

- `S-002` 在该 PRD 基线能力上增加增量更新和版本治理。
- Work Item Planning workflow 读取确认后的 PRD 版本并建立工作项。

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
