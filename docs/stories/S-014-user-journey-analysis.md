# S-014 Discovery User Journey 与 Feature 基线

## 基本信息

- ID：`S-014`
- Version：`3`
- Status：`Done`
- Priority：`P1`
- Change Type：Enhancement

## 目标

让 `discovery` 在形成 PRD 和 Business Architecture 前，先围绕一条稳定业务线分析并确认 User Journey 与 Feature，使产品需求、业务架构和后续工作项规划都能够追溯到一致的业务过程与能力定义。

## 背景

当前安装包中的 Discovery 会从背景、目标和范围分析直接形成 PRD 与 Business Architecture，缺少一份在两者之前稳定表达业务阶段、参与角色、线下活动、系统能力和业务顺序的权威资产。PRD、Business Architecture 和后续 Story Map 因此可能各自解释业务流程或重复定义 Feature。

最新 Discovery 流程设计已经确认：User Journey 是 Discovery 维护的产品设计资产，不是独立可选 workflow；Feature 由 Discovery 在 Journey 中创建和维护，Work Item Planning 只能引用已确认 Feature。完整产品设计基线由 User Journey、PRD 和 Business Architecture 三份相互一致的权威资产组成。

## User Story

作为需要规划软件产品或新能力的用户，我希望在产品需求定稿前先确认产品支持的完整业务线和能力顺序，以便 PRD、业务架构与后续交付规划建立在同一份业务事实之上。

## ✅ 范围

- 将 User Journey 分析和确认纳入 `discovery` workflow，替换当前从背景探索直接进入 PRD 与 Business Architecture 的阶段结构。
- 使用 `docs/product-design/user-journey.md` 作为当前唯一的 User Journey 权威文档，并与 PRD、Business Architecture 共同组成完整产品设计基线。
- 围绕一条稳定业务线定义业务边界、业务阶段、参与角色、线下与系统 Feature 及其从左到右的默认业务顺序。
- 使用普通 Markdown Table 表达 Journey Map；行表示角色，列表示业务顺序，连续空表头继承左侧最近的非空业务阶段。
- 为 User Journey 分配仓库全局唯一的稳定 `J-nnn` ID，为 Feature 分配仓库全局唯一的稳定 `F-nnn` ID。
- Feature Definitions 至少使用 `ID | Type | Title | Description`，Type 只允许 `Offline` 和 `System`。
- 只要业务身份不变，Feature 改名或 Type 调整时保留原 ID；同一业务能力被多个角色使用时复用同一 Feature。
- Discovery 创建和维护 Feature；Work Item Planning 和其他 workflow 只能引用已确认 Feature，不得重新定义其 ID、Type、标题、业务身份或顺序。
- 使用两道确认门：先确认并持久化 User Journey，再基于已确认 Journey 推导并最终确认 PRD 与 Business Architecture。
- 每条重要 Product Requirement 引用来源 Journey ID 和相关 Feature ID，但 PRD 不复制完整 Journey Map。
- Business Architecture 在描述关键角色、流程、规则、对象或状态时引用相关 Journey 或 Feature，但不重新定义 Journey 或 Feature 的业务身份。
- User Journey、PRD 和 Business Architecture 独立管理版本；只有受影响资产发生实质变化时才递增对应版本。
- 增量 Discovery 先判断新输入是否实质影响 User Journey；不影响时不得重新确认、升版或改写 Journey。
- 已有 PRD 或 Business Architecture 但没有 User Journey 时，将现有文档作为可信分析输入，先形成并确认第一份 Journey，再只协调实际受影响的产品设计资产。
- 每道确认门前只在会话中维护完整提案；确认前不得在正式路径写入对应未确认内容，也不得创建 manifest、阶段记录、确认记录或草稿过程文件。
- 更新 Discovery 源 skill、入口路由、公开说明、契约测试、构建后安装包和版本号，使源码、分发包和用户可见行为一致。

## ❌ 非范围

- 不创建或维护 Story Map、Milestone、Iteration Plan 或统一 Backlog。
- 不把 System Feature 拆分为 Story 或 Task；该职责属于后续 Work Item Planning。
- 不创建 Story、Task 或 Bug 卡片。
- 不实现 Work Item Planning、Work Item Analysis 或 Delivery Workflow 的行为。
- 不设计技术架构、代码模块、数据库、API、部署拓扑或其他实现机制。
- 不修改目标仓库应用代码、数据库迁移或业务功能。
- 当前不设计多 Journey 目录、根索引、拆分阈值或多个竞争的 Journey 文档。

## 验收标准

1. 用户可以从不完整想法开始，经背景探索、User Journey 分析、Journey 确认、PRD 与 Business Architecture 推导和最终产品设计确认完成 Discovery。
2. User Journey 未确认时，workflow 不开始正式推导 PRD 与 Business Architecture，也不写入权威 Journey 文档。
3. 初次 Discovery 能创建版本 `1` 的 `docs/product-design/user-journey.md`，并包含 Journey ID、业务线边界、Journey Map、Feature Definitions、`Open Questions`、`Rejected Directions` 和 Change Log。
4. Journey Map 和 Feature Definitions 能稳定表达角色、业务阶段、业务顺序、`Offline`/`System` Type、`J-nnn` 和 `F-nnn` ID。
5. PRD 中的重要 Product Requirement 能追溯到 Journey 和 Feature；Business Architecture 能引用同一业务身份而不重复定义 Journey 或 Feature。
6. User Journey、PRD 和 Business Architecture 各自独立管理版本，只有实质受影响的资产升版。
7. 增量输入不影响 Journey 时，Journey 不被重新确认、改写或升版；影响 Journey 时先确认 Journey 修订，再协调 PRD 与 Business Architecture。
8. 已有 PRD 或 Business Architecture 但没有 Journey 时，workflow 不废弃或推倒重建既有资产，只协调实际受影响内容。
9. 两道确认门之前，磁盘上的对应权威资产和支撑资产保持不变；用户反馈或拒绝只更新会话提案。
10. Discovery 不创建 Story Map、Story、Task、Bug 或工作项 Backlog，也不设计技术实现。
11. `src/`、`dist/.dev-cadence/`、入口路由、README 和 Discovery 契约测试对三资产、两道确认门和 Feature 所有权保持一致。
12. 可安装包版本按新增权威资产和 workflow 门禁的行为变化完成升级。

## Story Relationships

- Extends：`S-001` 首次 Discovery 与产品设计基线。
- Extends：`S-002` 产品设计基线增量更新与版本治理。
- Depends On：`S-001`、`S-002`、`S-005`、`S-006`、`S-013`，均已完成。
- Blocks：`S-015` 工作项规划 Workflow 与工作项契约。

## 依赖

- `S-001` 首次 Discovery 与产品设计基线。
- `S-002` 产品设计基线增量更新与版本治理。
- `S-005` 全局 Open Question Registry。
- `S-006` Discovery 产品与技术内容边界。
- `S-013` Discovery 过程记录简化。

## Open Questions

- 无。

## 相关文档

- [需求探索流程](../workflows/discovery.md)
- [产品需求形成与 Story Map 衔接设计](../product-requirements-derivation.md)
- [S-001 首次 Discovery 与产品设计基线](S-001-initial-discovery-prd-baseline.md)
- [S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)
- [S-005 全局 Open Question Registry](S-005-open-question-registry.md)
- [S-006 Discovery 产品与技术内容边界](S-006-discovery-product-technical-content-boundary.md)
- [S-013 Discovery 过程记录简化](S-013-simplify-discovery-process-records.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 User Journey 分析卡片。 | 将 User Journey 作为可选产品分析能力保留到后续设计。 |
| 2 | 2026-07-15 | 将卡片重定义为 Discovery 内的 User Journey 与 Feature 基线增强，并更新优先级、依赖和验收范围。 | 最新 Discovery 流程已确认 Journey 是 PRD 与 Business Architecture 的前置权威资产，Feature 必须由 Discovery 统一创建和维护。 |
| 3 | 2026-07-16 | 三资产两门契约已实现并验证，完成 User Journey 与 Feature 基线交付。 | Discovery 源码、分发包、入口路由、公开说明和契约验证已同步通过。 |
