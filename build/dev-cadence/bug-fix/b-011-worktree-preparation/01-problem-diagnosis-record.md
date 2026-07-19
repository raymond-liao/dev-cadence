# B-011 问题诊断记录

- 状态：🔄 `in_progress`
- 记录时间：`2026-07-19T16:36:08+0800`
- 工作项：[B-011 领卡后未立即准备配置要求的 worktree](../../../../docs/bugs/B-011-worktree-preparation-delayed-after-claim.md)
- 工作项类型：`Bug`
- 卡片 Version：`1`
- 卡片可见状态：`In Progress`
- 选定范围：仅处理 B-011 已确认的领取后工作区准备时点与对应契约验证；不改变领取原子性、业务阶段、确认门或 Completion 语义。

## 报告的症状

当 `worktree.enabled: true`，显式实施请求可在主 checkout 完成领取后立即进入下游 Delivery Workflow 的早期阶段；专用 worktree 直到各 Workflow 的 Plan 阶段才被要求创建或验证。因此 Requirements、Solution、早期 checkpoint 或相等阶段可能发生在主 checkout。

## 期望行为

领取必须先原子同步卡片和 Backlog。领取完成后、进入下游 Delivery Workflow 前，入口必须依据配置准备专用 workspace：启用 worktree 时创建或验证指定目录中的 worktree；禁用时准备专用任务分支。下游各阶段必须从一开始就在该选定 workspace 中运行。

## 实际行为与可复现证据

1. `src/skills/using-dev-cadence/SKILL.md` 的 Work Item Intake And Claiming 仅要求「领取在 branch/worktree 之前」并在领取成功后允许入口准备 workspace 后路由下游；没有要求 workspace preparation 完成后才可进入下游 Workflow。
2. `src/skills/feature-dev/SKILL.md`、`src/skills/bug-fix/SKILL.md` 与 `src/skills/refactor/SKILL.md` 都将 `using-git-worktrees` 的创建或验证职责放在各自的 Plan 阶段。
3. `tests/work-item-development-workflow-contract.sh` 当前仅验证 claim 相对 branch/worktree 的先后关系；它不验证 workspace preparation 必须位于下游 Workflow 之前。
4. 在未修改源码的基线执行中，`bash tests/work-item-development-workflow-contract.sh` 与 `bash tests/workflow-symmetry.sh` 均通过，证明现有测试允许上述契约缺口继续存在。

## 影响范围

- 入口选择器 `src/skills/using-dev-cadence/SKILL.md`。
- 三个 Delivery Workflow：`src/skills/feature-dev/SKILL.md`、`src/skills/bug-fix/SKILL.md`、`src/skills/refactor/SKILL.md`。
- 领取与工作区时序的端到端契约测试，至少包括 `tests/work-item-development-workflow-contract.sh` 及其对称性覆盖。
- 构建产物 `dist/.dev-cadence/` 与安装包同步，以及根目录 `version` 评估。

## 根因假设与置信度

**根因：** 工作区准备的所有权和时序被拆分在入口与各 Delivery Workflow 之间：入口只规定领取早于 workspace，而三个 Workflow 又把首次 workspace 创建/验证延后到 Plan 阶段。两个规则组合后没有形成「完成 workspace preparation 才能 route downstream」的不变量，契约测试也没有对该不变量做否定性验证。

**证据：** 上述四项源码和基线测试结果相互一致；没有发现配置、Git worktree 工具或单一 Workflow 的运行时故障证据。

**置信度：** 高。

## 复现条件

1. 目标仓库设定 `worktree.enabled: true`。
2. 用户对 Backlog 中的工作项发出显式实施或修复请求。
3. 入口完成领取，但在下游 Workflow 的 Plan 阶段之前尚未建立隔离 worktree。
4. 早期阶段按当前规则运行并可创建运行记录或 checkpoint。

## 开放问题与假设

- 开放问题：无。
- 假设：B-011 卡片定义的三个 Delivery Workflow 对称性保持不变；后续 Repair Solution 将只决定最小的入口与 Plan 边界调整方式。

## 诊断结论

✅ 已确认这是规则契约与测试覆盖缺口导致的 Bug，不是已知运行时环境问题。当前阶段仅完成诊断；尚未提出修复方案、编写计划或修改规则源码。
