# B-015 问题诊断记录

- 状态：🔄 `in_progress`
- 记录时间：`2026-07-19T19:12:59+0800`
- 最近确认：`2026-07-19T19:19:20+0800`，选项 1：确认当前诊断并进入 Repair Solution。
- 最近更新：`2026-07-19T19:29:26+0800`，用户要求核对 `worktree.enabled: false` 是否也存在同类 Bug；此前诊断确认被新范围调查暂时挂起。
- 工作项：[B-015 工作项领取未在 main 持久化](../../../../docs/bugs/B-015-work-item-claim-not-persisted-on-main.md)
- 工作项类型：`Bug`
- 卡片 Version：`3`
- 卡片可见状态：`In Progress`
- 选定范围：仅诊断 `worktree.enabled: true` 时工作项领取状态未先在 `main` 持久化的问题；不诊断禁用 worktree 的专用分支行为，不修改工作项生命周期集合、Backlog 排序、Delivery 阶段或完成回写。

## 报告的症状

在启用 worktree 时，任务 worktree 中的工作项卡片和 Backlog 已显示 `In Progress`，但主 checkout 仍显示同一工作项为 `Draft` 并保留在“待处理”。这使主 checkout 无法反映已经领取的工作项，后续从主 checkout 观察或选择工作项时会得到过期状态。

## 期望行为

显式实施或修复请求选定工作项后，入口必须先在 `main` 原子同步权威卡片和 `docs/backlog.md` 为 `In Progress`，并以该已持久化状态作为任务 worktree 的基线。创建 worktree 后，任务 worktree 与 `main` 必须看到相同的领取状态；主 checkout 不得继续显示该项为 `Draft` 或“待处理”。本诊断只覆盖 `worktree.enabled: true`，与 B-015 卡片的范围一致。

## 实际行为与复现证据

1. 当前 `src/skills/using-dev-cadence/SKILL.md` 规定“在切换 branch 或创建 worktree 前”原子同步卡片和 Backlog，并要求领取后准备 workspace；但没有规定这次写入必须针对 `main` checkout，也没有规定要在创建 worktree 前验证主 checkout 的持久化状态。
2. 当前 `tests/work-item-development-workflow-contract.sh` 验证领取先于 branch/worktree、卡片与 Backlog 原子同步，以及 workspace preparation 先于下游路由；它没有断言 `main` checkout 是领取写入目标。
3. 基线 `bash tests/work-item-development-workflow-contract.sh` 通过，说明现有契约可以在缺少主 checkout 身份约束时判定入口规则合格。
4. 最小 RED 检查在入口规则中搜索“claim 与 main checkout / 主分支”的组合不变量，结果为 `RED: entry contract has no main-checkout claim invariant`。
5. 已复现的入口状态差异与 B-015 卡片记录一致：若领取写入发生在新任务 worktree，写入只存在于该 worktree；返回 `main` 时仍可见旧的 `Draft` / “待处理”状态。

## 影响范围

- 入口规则：`src/skills/using-dev-cadence/SKILL.md`。
- 领取时序与身份的契约测试：`tests/work-item-development-workflow-contract.sh`，以及与 source/dist/安装包同步相关的既有检查。
- 生成分发包：`dist/.dev-cadence/`；根目录 `version` 是否递增需在修复方案阶段按仓库规则评估。
- 主 checkout 的 Backlog 可见性、后续工作项选择和任务 worktree 基线一致性。

## 对 `worktree.enabled: false` 的追加调查

当前没有一条独立的运行时复现证明 `false` 已经发生与 `true` 相同的状态分叉，但也没有证据证明它安全：

1. 入口规则对两种配置都要求“领取先于 branch/worktree”，但没有明确领取写入目标必须是 primary checkout，也没有要求在创建专用 branch 前取得主 checkout 的持久化提交。
2. `worktree.enabled: false` 只补充“立即准备专用任务 branch、不得创建 worktree”；`tests/work-item-development-workflow-contract.sh` 也只对这段文字做存在性断言。
3. 如果执行者在主 checkout 修改卡片和 Backlog 后不提交就切换到专用 branch，后续在该 branch 提交领取状态，`main` 分支指针仍保留旧状态；再次检出 `main` 时仍可能看到 `Draft` / “待处理”。这是同一缺失不变量在无 worktree 路径上的可构造失败路径。
4. 因此当前证据只能得出“`false` 尚未完成独立运行时复现”，不能得出“`false` 没有 Bug”。

这项追加调查改变了已确认的修复边界：需要用户决定将 B-015 扩展为两种配置共同满足 primary checkout 持久化不变量，还是保持 B-015 只修复已复现的 `true` 路径并另行登记/验证 `false` 路径。

## 最近变更与模式对比

- `5fb6654` 已补充“workspace preparation 必须在下游路由前完成”的入口门，但该变更只约束准备时序，没有约束领取写入的 checkout 身份。
- 现有规则中的“claim before branch/worktree”和“verify ... in the selected workspace”把领取动作与后续工作区验证分开，允许执行者把原子领取写入放在当前任务 worktree，而不是主 checkout。
- B-011 的历史实施现场暴露了这个差异：任务分支中的状态变化不能自动反映到 `main`；后续 B-011 规则修复了 workspace preparation 时序，但没有补上 B-015 要求的主 checkout 持久化不变量。

## 根因假设与置信度

**根因：** 工作项领取规则缺少“写入目标必须是 `main` checkout”的身份不变量。规则虽然规定领取早于 branch/worktree，并要求卡片与 Backlog 原子同步，但没有把主 checkout作为领取状态的唯一持久化源，也没有以主 checkout提交状态作为创建任务 worktree的基线验证。因此执行者可以在任务 worktree中完成表面上合规的原子写入，造成主 checkout仍为旧状态。

**证据：** 当前入口规则与契约测试均缺少主 checkout约束；基线契约测试通过；最小 RED 检查明确找不到该不变量；历史 B-011 现场与卡片复现条件呈现相同的跨 worktree 状态分叉。

**置信度：** 高。

## 复现条件

1. `.dev-cadence.yaml` 设置 `worktree.enabled: true`。
2. 用户发出明确的工作项实施或修复请求。
3. 入口创建任务 worktree，或在任务 worktree上下文执行领取写入。
4. 领取卡片和 Backlog 的原子更新只写入任务 worktree。
5. 返回 `main` 检查同一工作项，仍显示 `Draft` 并留在“待处理”。

## 开放问题与假设

- 开放问题：无。
- 假设：B-015 只要求 `worktree.enabled: true` 的主 checkout 持久化；`worktree.enabled: false` 的专用分支行为明确排除在外。

## 诊断结论

🔄 已确认 `true` 路径存在工作项领取持久化目标缺少入口身份契约的 Bug；对 `false` 路径的追加调查发现同一契约缺口，但尚无独立运行时复现。原 Repair Solution 确认因范围问题暂不继续，需先决定是否扩大 B-015 修复边界；尚未编写修复计划或修改规则源码。
