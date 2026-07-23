# B-012 问题诊断记录

- Workflow: `bug-fix`
- Work Item: [B-012 Draft Story 在 Ready 门禁前被提前领取](../../../../docs/delivery/bugs/B-012-draft-story-claimed-before-ready-gate.md)
- Card path: `docs/bugs/B-012-draft-story-claimed-before-ready-gate.md`
- Work-item type: `Bug`
- Card Version: `1`
- Visible Status: `In Progress`
- Selected scope: 确保工作项类型、状态和成熟度路由先于任何 claim 写入，并保留 Story、Task、Bug 的非统一门禁
- Status: ✅ `confirmed`
- Branch: `codex/parallel-b012-b010-b014`
- Diagnosis date: `2026-07-19`
- User confirmation: `confirm current version and advance to the next stage`
- Confirmed by: `Raymond Liao <raymond-liao@outlook.com>`
- Confirmed at: `2026-07-19T15:18:41+08:00`

## 报告症状

当 Backlog 首项为 `Draft` Story 且用户明确要求实施时，入口规则允许先把卡片和 Backlog 行领取为 `In Progress`，然后才发现 Story 尚未经过 Work Item Analysis 和用户确认达到 `Ready`。

## 期望行为

- Draft Story：先解析类型、状态和成熟度，进入 Work Item Analysis；分析期间不得领取；用户确认并原子更新为 `Ready` 后，新的或继续中的实施请求才能领取并进入 `feature-dev`。
- Ready Story：领取后准备任务工作区并进入 `feature-dev`。
- Task：不要求 `Ready`，由 Delivery Workflow 第一阶段确认目标、范围和完成条件。
- Bug：不要求 `Ready`、完整复现或已知根因，可领取后进入 `bug-fix` 诊断。

## 实际行为

`src/skills/using-dev-cadence/SKILL.md` 第 188-194 行先把明确实施意图提升为领取触发条件，并在选中工作项后无条件要求 claim；直到第 196 行才定义 `Draft Story -> work-item-analysis -> Ready Story -> feature-dev`。因此入口规则存在以下合法线性解释：

```text
明确实施意图 -> 选中 -> claim 写入 -> 才检查工作项类型与成熟度路由
```

下游 Feature Dev 的 Ready 门禁只能阻止继续交付，不能撤销已经发生的卡片和 Backlog 写入。

## 复现与证据

1. 读取 `src/skills/using-dev-cadence/SKILL.md` 第 188 行，确认明确实施请求可触发 claim。
2. 读取第 190-194 行，确认选择后立即、且在 branch/worktree 之前执行 claim。
3. 读取第 196 行，确认 Story 成熟度路由位于 claim 规则之后。
4. 对照 `src/skills/work-item-analysis/SKILL.md` 第 91-94、113-114 行：Work Item Analysis 自身正确地在确认前不写资产，并只在确认后更新 Story 为 `Ready`。
5. 对照 `src/skills/feature-dev/SKILL.md` 第 238 行：Feature Dev 有 Ready 防线，但位置在入口 claim 之后。
6. 运行 `bash tests/work-item-development-workflow-contract.sh`，测试通过。该测试第 33-43 行只分别检查 claim 触发、Draft-to-Ready 路由、Feature Ready 门禁和 Analysis 不领取等文本存在，没有验证它们的执行顺序或场景矩阵。

主线程还运行了相关基线契约，均通过；这证明现有测试无法识别 claim 段位于成熟度路由之前的组合缺陷。

## 影响范围

- 显式实施请求选中的 Draft Story 及其卡片、Backlog 生命周期投影。
- `src/skills/using-dev-cadence/SKILL.md`、构建后的分发包和安装入口。
- 工作项领取顺序契约及 Draft Story、Ready Story、Task、Bug 的路由契约测试。

修复不得改变 Ready Story、Task 和 Bug 的既有领取资格，不得改变 Work Item Analysis 对 Story `Ready` 决策的所有权，也不处理历史错误领取记录或 B-011 的工作区准备时点。

## 根因与置信度

根因已确认：入口缺少一个先于任何写入的类型、状态和成熟度分类步骤，使“明确实施意图”和“Story 成熟度”成为两个独立且顺序未约束的条件；现有契约测试只验证局部文本存在，没有验证成熟度路由必须先于 claim。

置信度：高。

## 未决问题与假设

- 无阻塞性业务问题。
- 仓库最终 Git 历史能证明规则歧义和测试缺口，但没有保留一次 Draft Story 已持久化为 `In Progress` 的最终提交；本诊断不把该缺失的历史提交当作根因证据。
- 本诊断不选择修复结构，也不修改源码或测试。
