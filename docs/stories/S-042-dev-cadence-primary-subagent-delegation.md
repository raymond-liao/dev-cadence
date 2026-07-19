# S-042 Dev Cadence 全流程主执行子代理委派

## 基本信息

- ID：`S-042`
- Version：`1`
- Status：`Ready`
- Priority：`P1`
- Change Type：Enhancement

## 目标

当平台支持内部子代理时，将完整 Dev Cadence 任务交给主执行子代理，使主会话只承载用户决定、必须由用户处理的阻塞和最终结论，避免处理过程持续占用主会话上下文。

## 背景

当前 Dev Cadence 的部分流程要求完整草稿和分析过程保留在主会话中，并要求主代理保留路由、验证或 Git 集成等执行责任。长时间任务会因此持续把仓库调查、方案草拟、日志、diff、测试、Review 和 Git 过程加载到主会话，最终出现上下文不足、重复分析或无法可靠继续的问题。

Dev Cadence 已经为交付记录、权威资产和子代理任务提供文件产物。本 Story 将执行边界调整为：主会话负责用户交互，主执行子代理负责完整任务；未确认草稿可以使用系统临时或缓存文件承载，但不得冒充权威资产。

## User Story

作为使用 AI 完成软件交付的用户，我希望 Dev Cadence 将不需要我参与的调查、草拟、修改、实现、验证和 Git 操作留在子代理中，以便主会话长期保持高价值上下文，并只在需要我决定时与我交互。

## ✅ 范围

- `using-dev-cadence` 在平台支持内部子代理时将完整 Dev Cadence 请求委派给主执行子代理。
- 主执行子代理读取入口 Skill，选择或恢复 workflow，并连续执行所有不需要用户交互的工作。
- 区分主执行子代理和普通子任务代理，避免完整任务递归派发或普通子任务重复选择 workflow。
- 主执行子代理可以继续派发边界明确的调查、实现、Review 或测试子代理。
- 仓库调查、草稿、文件修改、实现、测试、Review、验证、阶段记录和 Git 操作均可由子代理完成。
- 只有需要用户决定、必须由用户提供信息的阻塞或任务完成时，主执行子代理才返回主会话。
- 未确认草稿可以写入系统 `tmp` 或 cache，并必须明确标记为非权威内容；正式权威资产在用户确认前保持不变。
- 返回主会话时只提供当前结论、用户选项、每个选项的影响、风险和证据路径，不回传完整日志、diff 或处理过程。
- merge、PR、push、discard、分支删除等操作继续遵守现有用户授权门禁；授权后由主执行子代理执行和验证。
- 用户回应交回原主执行子代理；原子代理无法恢复时，允许新主执行子代理从文件证据恢复并继续。
- 平台不支持内部子代理时，主会话可以直接执行现有 workflow。
- 同步 source、dist、安装包、根目录 `version` 和契约测试。

## ❌ 非范围

- 不修改根 `AGENTS.md`。
- 不修改 `src/AGENTS-snippet.md`。
- 不新增 workflow、Skill、脚本、配置项或公开状态。
- 不修改 vendored Superpowers。
- 不承诺系统 `tmp` 或 cache 在系统清理、跨机器或执行环境销毁后仍可恢复。
- 不取消用户确认门，不改变现有业务决定的所有权，也不扩大 Git 操作授权。
- 不把未确认草稿提升为权威资产或长期业务来源。
- 不在本 Story 中实现平台自身缺失的子代理能力。

## 验收标准

1. 主会话读取入口规则后即可委派完整任务，无需加载具体 workflow 或探索仓库。
2. 主执行子代理能够选择或恢复 workflow；普通子任务代理不会重复路由或递归派发完整任务。
3. 所有已安装 workflow 的非交互工作均可留在子代理侧连续执行。
4. 主执行子代理只在需要用户决定、必须由用户提供信息的阻塞或终态返回主会话。
5. Asset Workflow 允许使用临时非权威草稿，用户确认前不修改权威资产。
6. 主会话收到的确认信息包含当前结论、完整用户选项、每个选项的影响、风险和证据路径，不包含不必要的过程输出。
7. Git 操作由主执行子代理执行，但 merge、PR、push、discard、分支删除等现有用户授权边界保持不变。
8. 用户回应能够交回原主执行子代理，或由新主执行子代理从文件证据恢复。
9. 无内部子代理能力的平台继续使用现有主会话执行方式。
10. 契约测试覆盖角色边界、返回条件、临时草稿边界、Git 授权、fallback 以及 source、dist 和安装结果同步。

## Story Relationships

- Changes：[S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)建立的会话提案边界。
- Changes：[S-012 Asset 与 Delivery Workflow 记录边界](S-012-asset-delivery-workflow-record-boundary.md)建立的 Asset Workflow 恢复边界。
- Changes：[S-013 Discovery 过程记录简化](S-013-simplify-discovery-process-records.md)建立的无草稿文件边界。
- Changes：[S-014 Discovery User Journey 与 Feature 基线](S-014-user-journey-analysis.md)建立的确认前提案边界。
- Related：[S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)。
- Related：[S-037 工作项分析 Workflow](S-037-work-item-analysis-workflow.md)。
- Related：[T-004 Git 提交阶段接入 git-commit Skill](../tasks/T-004-git-commit-skill-workflow-integration.md)。

## 依赖

- 无。

## Open Questions

- 无。

## 相关文档

- [S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)
- [S-012 Asset 与 Delivery Workflow 记录边界](S-012-asset-delivery-workflow-record-boundary.md)
- [S-013 Discovery 过程记录简化](S-013-simplify-discovery-process-records.md)
- [S-014 Discovery User Journey 与 Feature 基线](S-014-user-journey-analysis.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [S-037 工作项分析 Workflow](S-037-work-item-analysis-workflow.md)
- [T-004 Git 提交阶段接入 git-commit Skill](../tasks/T-004-git-commit-skill-workflow-integration.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
| ---: | --- | --- | --- | --- |
| 1 | 2026-07-19T12:54:45+08:00 | Raymond Liao <raymond-liao@outlook.com> | 创建 Dev Cadence 全流程主执行子代理委派 Story。 | 用户确认主会话只保留用户交互和最终结论，其他 Dev Cadence 工作由主执行子代理完成。 |
