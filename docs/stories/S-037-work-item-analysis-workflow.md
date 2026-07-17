# S-037 工作项分析 Workflow

## 基本信息

- ID：`S-037`
- Version：`1`
- Status：`Done`
- Priority：`P1`
- Change Type：Feature

## 目标

新增 `work-item-analysis` workflow，把轻量 Story、Task 或 Bug 完善为经过用户确认的权威工作项定义，并为后续 Delivery Workflow 提供明确、可追溯的输入。

## 背景

Work Item Planning 负责识别和组织需要交付的工作，可以只创建包含稳定 ID、标题、产品引用和初步规划信息的轻量卡片。Delivery Workflow 如果直接承担所有需求分析，会重复定义卡片边界，也无法支持在开发前集中审阅一组工作项。

Work Item Analysis 需要在产品规划与技术交付之间提供独立的工作项定义能力，同时保持与 Discovery、Work Item Planning 和 Bug Fix 的职责边界。

## User Story

作为准备实施工作项的用户，我希望先明确 Story、Task 或 Bug 的目标、范围和判断条件，以便开发 workflow 使用经过确认的权威定义，而不是在每次运行中重新解释需求。

## ✅ 范围

- 新增可安装的 `work-item-analysis` workflow skill。
- 支持单项分析和用户明确选择工作项集合的批量分析。
- 复用已有 Story、Task 或 Bug 卡片；没有卡片时可以创建轻量卡片并在同一次分析中完善。
- Story 分析明确角色、目标、价值、主要 System Feature、范围、产品行为、业务规则、验收条件、依赖和开放问题。
- Story 只有在目标、范围、主要 Feature、验收条件和阻止开发的问题均明确并经用户确认后才能进入 `Ready`。
- Task 分析明确目标、必要性、范围、完成条件、影响、依赖、风险和可选 `Nature`，但不把 Analysis 或 `Ready` 设为统一实施硬门禁。
- Bug 分析明确期望行为、已观察行为、影响、已知环境和复现信息，并区分 Bug、预期行为变更和信息不足。
- 明确 Work Item Analysis 不调查或确认技术根因；Bug 根因、修复边界和回归风险由 `bug-fix` 负责。
- 识别选定卡片之间的重复、重叠、依赖和冲突，展示处理建议并由用户决定，不自动删除、合并或替代卡片。
- 用户确认前只维护会话提案；确认后才原子更新被接受的卡片、独立版本和 Change Log。
- 更新入口发现、安装包、构建、README 和契约验证，使该 workflow 可以在目标仓库中使用。

## ❌ 非范围

- 不创建或修改 User Journey、Feature、PRD 或 Business Architecture。
- 不创建或修改 Story Map、Milestone、Size、Iteration Plan 或 Backlog 排序。
- 不设计技术方案、修改代码、执行实现测试或完成业务验收。
- 不调查 Bug 根因，不替代 `bug-fix` 的问题诊断阶段。
- 不自动把批量分析范围扩展到整个 Backlog。
- 不为分析过程创建 `build/dev-cadence/` manifest、阶段记录、确认记录或 checkpoint。

## 验收标准

1. 安装包提供可被入口选择的 `work-item-analysis` workflow。
2. workflow 支持 Story、Task 和 Bug 的单项分析及用户明确选择的批量分析。
3. 已有卡片被复用；缺卡时可以创建并完善轻量卡片，不产生重复 ID 或平行权威定义。
4. Story、Task 和 Bug 使用各自明确的分析字段和成熟度规则。
5. Story 只有在工作项定义完整并经用户确认后进入 `Ready`；Task 和 Bug 不被同一门禁机械阻塞。
6. Bug 分析与 Bug Fix 根因诊断保持清楚边界。
7. 重复、重叠、依赖和冲突由用户确认处理，未确认卡片保持原权威内容不变。
8. 分析只更新选定卡片，不改变产品基线、规划顺序或技术实现。
9. source、dist、安装包、入口路由和契约测试保持同步。

## Story Relationships

- Follows：`S-015` 工作项规划 Workflow 与工作项契约。
- Precedes：`S-017` 工作项卡片与开发 Workflow 接入。
- Precedes：`T-002` 需求治理端到端验证与安装契约。
- Related：`S-016` 统一 Backlog 看板。

## 依赖

- `S-015` 工作项规划 Workflow 与工作项契约。

## Open Questions

- 无。

## 相关文档

- [工作项分析流程](../workflows/work-item-analysis.md)
- [工作项规划流程](../workflows/work-item-planning.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [S-016 统一 Backlog 看板](S-016-unified-backlog-board.md)
- [S-017 工作项卡片与开发 Workflow 接入](S-017-work-item-development-workflow-integration.md)
- [T-002 需求治理端到端验证与安装契约](../tasks/T-002-requirements-governance-end-to-end-validation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-15 | 创建 Work Item Analysis workflow 卡片。 | 为轻量工作项到开发交付之间增加经过用户确认的权威定义阶段。 |
| 1 | 2026-07-17 | 记录实施、系统测试和 Business Acceptance，并将状态更新为 Done。 | 用户选择 `1. Accept`，S-037 交付结果已验收。 |
