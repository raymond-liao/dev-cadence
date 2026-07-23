# B-011 修复方案

- 状态：🔄 `in_progress`
- 记录时间：`2026-07-19T16:48:26+0800`
- 已确认诊断：[B-011 问题诊断记录](01-problem-diagnosis-record.md)
- 工作项：[B-011 领卡后未立即准备配置要求的 worktree](../../../../docs/delivery/bugs/B-011-worktree-preparation-delayed-after-claim.md)

## 要修复的根因

入口只规定领取早于 branch/worktree，却没有建立“workspace preparation 完成后才能进入下游 Delivery Workflow”的门。与此同时，三个 Delivery Workflow 把首次工作区创建或验证放在 Plan 阶段，导致工作区所有权与时序分散。

## ❓ Decision Pending：推荐方案 — 入口拥有工作区准备门

在 `using-dev-cadence` 的 Work Item Intake And Claiming 中，保留卡片与 Backlog 的原子领取及“领取先于 branch/worktree”的顺序；随后在路由任何下游 Delivery Workflow 之前，入口必须完成并验证配置选定的 workspace handoff。

- 当 `worktree.enabled: true`：入口按配置目录创建或验证任务专用 worktree，并在该 worktree 中继续后续 Delivery Workflow。
- 当 `worktree.enabled: false`：入口立即准备任务专用 branch；不创建 worktree，并从该 branch 继续后续 Delivery Workflow。
- workspace handoff 必须保留已领取卡片与 Backlog 的相同 Version、`In Progress` 可见状态和选定范围；入口在目标 workspace 验证该身份后才可 route downstream。
- 三个 Delivery Workflow 的 Plan 阶段只验证或复用入口已准备的 workspace，不得成为首次创建隔离 worktree 或任务 branch 的时点。

## 影响边界

### 将修改

- `src/skills/using-dev-cadence/SKILL.md`：增加严格的 `claim -> workspace preparation -> downstream workflow` 入口不变量及两条配置路径。
- `src/skills/feature-dev/SKILL.md`、`src/skills/bug-fix/SKILL.md`、`src/skills/refactor/SKILL.md`：同步配置说明、Superpowers 映射和 Plan 阶段边界，使其只验证/复用入口工作区。
- `tests/work-item-development-workflow-contract.sh`：新增否定性契约，确保仅有“claim 早于 worktree”而允许中间下游路由时失败。
- `tests/workflow-symmetry.sh`：验证三个 Delivery Workflow 的既有工作区契约保持对称。
- `src/AGENTS-snippet.md`、`README.md`、`README.zh-CN.md`：使 `worktree.enabled: false` 的用户说明与“专用 branch、不创建 worktree”一致。
- `version`：行为修复将从 `0.26.2` 提升为 `0.26.3`。

### 将生成或同步

- `bash scripts/build.sh` 生成 `dist/.dev-cadence/`，使 source 与安装包一致；不直接编辑 `dist/`。
- `bash scripts/install.sh` 现有安装替换流程和安装契约用于验证同步，不改变其实现。

### 不修改

- 卡片与 Backlog 的原子领取语义、状态模型或排序。
- Delivery Workflow 的业务阶段、确认门、Business Acceptance、Completion、worktree 所有权识别或清理规则。
- Vendored Superpowers 副本。

## 备选方案

### 方案 B：仅在三个 Delivery Workflow 的早期阶段创建工作区

不推荐。它仍将入口时序分散到三个流程，无法保证任何下游阶段开始前已完成 workspace preparation，并会重复三份 bootstrap 规则。

### 方案 C：仅强化 Git Checkpoints 的专用分支要求

不推荐。它只能在首次提交前补建 branch，不能阻止 Requirements、Solution 或运行记录先在错误 workspace 启动，也无法满足启用 worktree 时的隔离要求。

## 回归范围与验收

- 入口的严格顺序同时覆盖 `worktree.enabled: true` 与 `false`。
- `true` 路径从 Requirements/Diagnosis 等首个下游阶段起即处于 task worktree。
- `false` 路径从首个下游阶段起即处于 task branch，且没有 worktree。
- 三个 Delivery Workflow 的 Plan 阶段不能首次创建 workspace。
- 新契约测试在缺少严格中间门时失败；构建、source/dist 同步和安装替换继续通过。

## 风险与待决事项

- ⚠️ workspace handoff 必须以卡片 Version、状态和 Backlog 行为身份校验；不得通过复制或部分写入制造两个不一致的领取状态。
- 无需新增 workflow 或共享 skill；入口仍是唯一的领取与 workspace bootstrap 所有者。
- 用户需确认推荐方案后，才编写 Repair Plan 或修改源码。
