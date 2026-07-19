# B-015 修复方案

- 状态：🔄 `in_progress`
- 记录时间：`2026-07-19T19:19:20+0800`
- 工作项：[B-015 工作项领取未在 main 持久化](../../../../docs/bugs/B-015-work-item-claim-not-persisted-on-main.md)
- 工作项类型：`Bug`
- 卡片 Version：`3`
- 诊断来源：[B-015 问题诊断记录](01-problem-diagnosis-record.md)

## 根因

入口领取规则只约束了卡片与 Backlog 的原子性及其相对于 branch/worktree 的顺序，没有约束领取写入必须发生在主 checkout，也没有要求任务 worktree 从该主 checkout 的已持久化状态创建。因而在 worktree 上下文中执行领取时，任务 worktree 可以显示 `In Progress`，而 `main` 仍保留 `Draft` / “待处理”。

## 推荐修复方案：强化现有入口的主 checkout 持久化不变量

在现有 `using-dev-cadence` 领取入口中补齐一个连续的、不可跳过的交接契约：

1. 对 `worktree.enabled: true` 的请求，先解析目标仓库的 primary checkout（当前仓库为 `main`），将权威卡片和 `docs/backlog.md` 在该 checkout 中原子同步为 `In Progress`。
2. 在创建任务 worktree 前，将这次主 checkout 领取状态持久化，并记录其提交身份；该领取提交是入口的生命周期交接，不是任务 branch 上的 Repair Implementation 或阶段 checkpoint。
3. 仅从上述已持久化的主 checkout 状态创建或验证任务 worktree；创建后验证卡片 Version、`In Progress` 状态和匹配的 Backlog 行。
4. 保留现有“领取先于 branch/worktree”“workspace preparation 先于下游路由”“卡片与 Backlog 原子同步”“幂等且不重复 Change Log 事件”等契约。
5. 在 `tests/work-item-development-workflow-contract.sh` 增加主 checkout 持久化目标和时序断言，并通过构建、安装和 source/dist 同步检查验证安装包行为。

该方案复用现有入口、配置传播和 worktree 所有权，不新增 claiming skill 或第二套工作项状态源。

## 修复点与边界

预计修改：

- `src/skills/using-dev-cadence/SKILL.md`：定义 primary checkout 领取、持久化交接、从该状态创建 worktree 的顺序与验证。
- `tests/work-item-development-workflow-contract.sh`：覆盖主 checkout 身份、持久化提交和 worktree 基线顺序，拒绝“只在任务 worktree 写入领取状态”的规则文本。
- `version`：按仓库规则评估并递增补丁版本，使安装包行为变化可识别。
- `dist/.dev-cadence/`：由 `bash scripts/build.sh` 生成，不直接编辑。

不修改：

- `worktree.enabled: false` 的专用 branch 路径。
- 工作项生命周期状态集合、Backlog 排序模型、Delivery Workflow 业务阶段和完成后的 Backlog 回写。
- 卡片的业务目标、范围、验收条件和 Version 需求定义。
- `src/vendor/superpowers/**` 与新增共享 claiming skill。

## 受影响行为

- 主 checkout 会在任务 worktree 创建前反映领取状态，后续选择工作项时不再看到过期的 `Draft` / “待处理”。
- 任务 worktree 的初始 HEAD 和文件状态包含主 checkout 的领取结果。
- 启用 worktree 的入口会多一个必须完成的主 checkout 持久化交接；如果原子写入或持久化失败，不得创建 worktree 或路由下游 Workflow。
- 禁用 worktree、下游 Delivery Workflow 阶段、工作项业务内容和完成回写保持不变。

## 修复验收标准

1. `worktree.enabled: true` 时，领取写入明确发生在 `main` / primary checkout，而不是任务 worktree。
2. 主 checkout 的卡片和 Backlog 在创建任务 worktree 前已为 `In Progress`，且 Version 仍为 3。
3. 任务 worktree 从该已持久化状态创建，并通过 Version、状态和 Backlog 行验证。
4. 契约测试会拒绝只描述任务 worktree 写入、或把 worktree 创建置于主 checkout 持久化之前的规则。
5. 卡片与 Backlog 的原子性、幂等性、Change Log 版本语义和现有领取资格门保持不变。
6. source、dist、安装包和根版本通过既有契约检查保持同步。

## 回归范围

- `tests/work-item-development-workflow-contract.sh`：入口领取和 workspace handoff。
- `tests/configuration-contract.sh`：primary checkout 配置传播与 worktree 配置不变。
- `tests/install-contract.sh`、`tests/package-contract.sh`：安装包与 source/dist 同步。
- `tests/run-all.sh`、`bash scripts/check-all.sh`、`bash scripts/check-whitespace.sh`：全量契约、构建与格式检查。
- 手工 source inspection：确认主 checkout 持久化、worktree 创建、下游路由和验证顺序没有反转。

## 保持不变的行为

- 只有明确的 implementation / repair / refactor 请求可以领取；讨论、分析、规划和状态查询不得领取。
- Draft Story、Ready Story、Task、Bug 的现有入口资格不变。
- 领取不增加卡片 Version；重要领取事件使用当前 Version 且不得重复记录。
- Backlog 待处理行顺序和派生并行视图不被重排。

## 备选方案与取舍

### 方案 B：新增独立 claim helper 脚本

新增脚本统一解析 primary checkout、执行原子写入、创建提交并返回基线 SHA。它可以提供更强的运行时一致性，但会引入新的共享能力所有权、脚本接口、错误补偿和测试面；当前仓库没有现成的工作项领取执行脚本，超出 B-015 的最小规则修复边界，暂不采用。

### 方案 C：先建 worktree，再同时回写 main

这会让任务 worktree 先于主 checkout 成为状态源，无法保证 worktree 从已持久化的主状态创建，也无法消除当前复现中的状态分叉，拒绝采用。

## 风险与需要确认的决定

- 需要确认“主 checkout 持久化”包含一个可验证的主 checkout 提交；否则未提交文件变更不能可靠成为新 worktree 的基线。
- 入口领取提交发生在 dedicated task branch 创建前，必须在规则和记录中明确它是生命周期交接提交，避免与下游实现提交或阶段 checkpoint 混淆。
- 版本递增会改变可安装包版本，但不改变业务工作项 Version；根 `version` 预计从 `0.26.3` 递增到下一个补丁版本，最终在实施前按仓库状态复核。

## 当前结论

推荐采用“强化现有入口的 primary checkout 持久化不变量”方案。该方案直接修复已确认根因，覆盖 B-015 的四项验收标准，并将改动限制在入口规则、契约测试、构建分发与版本同步范围内。
