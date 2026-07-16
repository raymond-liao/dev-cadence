# S-015 工作项规划 Workflow 与工作项契约：需求确认

## 状态

✅ `confirmed`

## 确认依据

用户于 2026-07-16 要求继续执行 Backlog 当前“并行实施表”的下一个工作项，并要求尽量在子线程中完成任务。该指令作为本轮连续执行的需求、方案和实施计划确认授权；本记录保存可审计的范围边界。

## ✅ 纳入范围

- 新增可安装的 `work-item-planning` Asset Workflow skill。
- 支持组合规划和单项登记两种入口模式。
- 定义 Story Map、Milestone、MVP、Path、轻量 Story/Task/Bug 卡片、状态、版本、关系、Change Log、冲突检查和跨 workflow 修改边界。
- 明确 Discovery 对 User Journey/Feature 的所有权，以及 Work Item Planning 只能读取已确认上游资产、不得重定义 Feature 的边界。
- 明确用户确认前只形成会话提案，确认后原子写入规划资产；Asset Workflow 不创建 `build/dev-cadence/` manifest 或阶段记录。
- 更新入口路由、安装分发同步、契约测试和版本号。
- 将完成后的 S-015 状态、Backlog 和并行实施表同步到 `Done`/下一序号状态。

## ❌ 排除范围

- 不创建或修改实际的 `docs/product-design/` 产品基线内容。
- 不实现 `work-item-analysis`、统一 Backlog 看板、完整 Size 估算或 Iteration Plan 容量校准。
- 不实现 Story、Task、Bug 的开发、诊断、重构、测试或业务验收过程。
- 不修改既有 Delivery Workflow 的阶段模型或交付运行记录契约。
- 不直接编辑 `dist/.dev-cadence/**`。

## 验收标准

1. 入口能够路由到可安装的 `work-item-planning` skill。
2. skill 同时定义组合规划和单项登记模式。
3. skill 定义稳定 ID、独立 Version、统一状态、显式关系和 Change Log 的轻量卡片契约，并要求复用已有卡片。
4. skill 定义唯一 Story Map 路径、Backbone、Path、Milestone/MVP 和交付内部状态边界。
5. skill 明确只引用已确认的 Offline/System Feature，发现缺失、含义不清或顺序变化时返回 Discovery。
6. skill 定义确认前提案、确认后原子写回和并发版本冲突处理。
7. skill 定义移交至 `feature-dev`、`bug-fix`、`refactor` 的边界。
8. source、dist、安装包、入口路由、契约测试和版本号保持同步。

## 开放问题与假设

- S-014 的产品设计资产契约已完成，但本源码仓库不包含目标仓库中的实际 User Journey、PRD 或 Business Architecture；本次只实现规则，不伪造这些输入。
- `docs/workflows/work-item-planning.md` 是业务说明，新增 skill 是目标仓库执行规则的权威来源。
- 版本从 `0.18.0` 升至 `0.19.0`，因为新增可安装 workflow 会改变用户可见安装行为。

## 需求来源

- `docs/stories/S-015-work-item-planning-workflow-contract.md`
- `docs/workflows/work-item-planning.md`
- `docs/stories/S-014-user-journey-analysis.md`
