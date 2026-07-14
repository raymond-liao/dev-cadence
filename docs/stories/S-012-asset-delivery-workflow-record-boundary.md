# S-012 Asset 与 Delivery Workflow 记录边界

## 基本信息

- ID：`S-012`
- Version：`2`
- Status：`Done`
- Priority：`P1`
- Change Type：Enhancement

## 目标

将 Dev Cadence workflow 明确分为 Asset Workflow 和 Delivery Workflow，使 PRD、工作项和架构等长期业务资产直接承载业务事实，而 manifest、stage record、checkpoint 和实施证据只用于 Feature Dev、Bug Fix 和 Refactor 软件交付过程。

## 背景

当前 Dev Cadence 对 Discovery 使用了与 Feature Dev 类似的 run manifest、阶段记录和 checkpoint 模型。该模型适合绑定代码版本、Review、测试、验收和 Git 集成结果，但对 PRD、Story、Backlog 和 Architecture 等长期资产会产生重复记录：业务结论保存在权威文档中，形成过程又复制到 `build/dev-cadence/`，增加维护和状态同步成本。

资产型工作需要保留版本、变化原因、开放问题和当前结论，但不需要恢复代码实施现场。交付型工作则必须能够在中断后重建已确认需求、方案、实现版本、测试证据和集成状态，两类 workflow 应采用不同记录契约。

## User Story

作为 Dev Cadence 使用者，我希望只有 Feature、Bug 和 Refactor 软件交付过程维护独立运行记录，以便产品设计、工作项和架构文档保持简洁，同时实施工作仍具有完整、可恢复和可审计的证据链。

## ✅ 范围

- 定义 Asset Workflow：Discovery、Work Item Planning 和 Architecture Design。
- 定义 Delivery Workflow：Feature Dev、Bug Fix 和 Refactor。
- Asset Workflow 只创建或更新 `docs/` 下的长期权威资产，不创建 `build/dev-cadence/` run manifest、stage record、确认记录或其他过程副本。
- Asset Workflow 可以在会话内保留分析步骤和用户确认门禁，但不得为了保存这些步骤创建持久化过程文件。
- Asset Workflow 的当前业务事实、版本、变化原因、开放问题、拒绝方向、关系和状态写入对应权威资产。
- Asset Workflow 不创建阶段 checkpoint 或空提交，不把 commit hash、审批人、审批时间和 workflow 运行状态写入业务资产。
- Asset Workflow 的 Git 提交遵守用户请求和仓库普通提交规则；不把普通资产提交描述为流程 checkpoint。
- Delivery Workflow 继续维护 run manifest 和必要阶段记录，用于恢复实施现场、绑定需求与方案版本、记录代码提交、Review、测试、业务验收、Git 集成和清理结果。
- Delivery Workflow 的 Requirements、Diagnosis、Refactor Scope 和 Solution 记录属于当前软件交付 run，不因为 Asset Workflow 简化而删除。
- `using-dev-cadence` 的 Active Workflow Continuation 必须区分两类 workflow：Delivery Workflow 通过 manifest 恢复，Asset Workflow 通过当前会话、用户目标和权威资产识别延续上下文。
- 新增 workflow 时必须明确属于 Asset 或 Delivery 类别，并采用对应记录契约，不得自行混合两种模型。
- 更新共享规则、已安装 workflow 说明和契约测试，验证分类、记录边界和禁止事项。

## ❌ 非范围

- 不删除或弱化 Feature Dev、Bug Fix 和 Refactor 的 manifest、阶段记录、Review、测试、验收或 Completion 证据。
- 不把 Delivery Workflow 的过程状态迁移到 Story、PRD 或 Architecture 文档。
- 不要求业务资产保存 Git commit hash、审批元数据或工作流运行状态。
- 不在本 Story 中完整改写 Discovery；具体迁移由 S-013 执行。
- 不在本 Story 中实现 Work Item Planning 或 Architecture Design workflow。
- 不迁移、删除或重写历史 `build/dev-cadence/` 运行记录。
- 不改变现有业务资产的 ID、Version、Status、Change Log 或关系契约，除非为落实记录边界确有必要。

## 验收标准

1. Dev Cadence 明确定义 Asset Workflow 和 Delivery Workflow，并列出当前属于两类的 workflow。
2. Discovery、Work Item Planning 和 Architecture Design 只维护长期业务资产，不要求独立 manifest、stage record、确认记录或阶段 checkpoint。
3. Asset Workflow 的分析和确认可以在会话内执行，但不会复制为持久化过程文件。
4. PRD、Story、Backlog 和 Architecture 通过自身 Version、Change Log、状态、关系、Open Questions 或 Rejected Directions 表达长期业务事实。
5. Asset Workflow 不把 commit hash、审批人、审批时间或 workflow 状态写入业务资产。
6. Feature Dev、Bug Fix 和 Refactor 继续保存恢复实施现场和验证交付结果所需的完整证据链。
7. Delivery Workflow 的需求与方案阶段记录被明确保留为实施 run 的组成部分，不被误认为独立资产型过程。
8. Active Workflow Continuation 能够按 workflow 类别使用 manifest 或权威资产识别当前上下文。
9. 新增 workflow 必须选择一种记录模型，不能同时维护重复的长期资产和过程事实来源。
10. 契约测试覆盖 workflow 分类、Asset 禁止记录、Delivery 保留记录和入口延续规则。

## Story Relationships

- Follows：`S-006` Discovery 产品与技术内容边界。
- Precedes：`S-013` Discovery 过程记录简化。
- Precedes：`S-002` 产品设计基线增量更新与版本治理。
- Precedes：`S-011` 目标驱动的架构设计 Workflow。
- Precedes：Work Item Planning workflow。

## 依赖

- `S-006` Discovery 产品与技术内容边界。

## 后续工作

- S-013 按本 Story 的 Asset Workflow 契约简化现有 Discovery。
- S-002、S-011 和 Work Item Planning 在实现时直接采用 Asset Workflow 契约。
- 后续新增交付 workflow 时，单独评估其是否需要完整 Delivery 证据链。

## Open Questions

- 无。

## 相关文档

- [S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)
- [S-006 Discovery 产品与技术内容边界](S-006-discovery-product-technical-content-boundary.md)
- [S-011 目标驱动的架构设计 Workflow](S-011-goal-driven-architecture-workflow.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 Asset 与 Delivery Workflow 记录边界 Story。 | 让长期业务资产避免重复过程记录，同时保留软件交付所需的实施证据链。 |
| 2 | 2026-07-14 | 完成 workflow 分类、记录模型、延续识别和 Delivery 证据保留契约。 | 为 S-013、S-011 和后续 Asset Workflow 提供统一持久化边界，同时保持现有软件交付证据链。 |
