# Dev Cadence 工作流

Workflow 描述一类任务从 intake 到 acceptance 的推进路径。它回答的是：这个请求应该先澄清需求、直接 review、先 research，还是按 incident 快速处理。

用户不需要手动选择 workflow。[Supervisor](../roles/02-supervisor.md) 会根据请求、风险和用户提示记录 `selected_workflow` 和 `selection_reason`。如果任务风险更高，[task class](../../references/task-classes.md) 会加强同一个 workflow 的 [gate](../gates/) 和 [artifact](../artifacts/) 要求。

## Workflow 目录与路由

| Workflow | 什么时候用 |
|---|---|
| [`feature-dev`](01-feature-dev.md) | 新功能或用户可见行为变更 |
| [`bugfix`](02-bugfix.md) | 修正已知错误行为 |
| [`code-review`](03-code-review.md) | 审查已有 diff、branch、PR 或 patch |
| [`refactor`](04-refactor.md) | 意图保持行为不变的结构调整 |
| [`research-spike`](05-research-spike.md) | 技术选型、未知风险探索、方案比较 |
| [`incident-fix`](06-incident-fix.md) | 紧急生产恢复或关键故障处理 |
每个 workflow 单页说明使用场景、标准路径、主要角色、主要产物、gate 重点和 Human 介入点。

`release`、deploy、pipeline/CI/CD 和 production action 不是独立 workflow；按实际交付内容选择 `feature-dev`、`bugfix`、`refactor`、`code-review`、`research-spike` 或 `incident-fix`，并作为 S2 / Human Gate / CI-CD boundary 处理。

用户明确说“只做 review”“先调研”“按 incident 处理”时，该表达应记录为 `workflow_hint`。Supervisor 仍要根据风险校准最终 `selected_workflow`。

Task class 不替代 workflow；它只决定流程强度。普通 bugfix 仍是 `bugfix`，但如果触及数据迁移、安全、权限、CI/CD、生产或跨模块风险，就应提升为更严格的 class。

完整分级矩阵和高风险触发条件见 [task-classes.md](../../references/task-classes.md)。

## 标准路径

普通 feature、bugfix 和 refactor 通常走：

```text
intake -> requirements -> planning -> implementation -> verification -> review -> acceptance
```

需要架构判断、公共契约变更、数据模型变更或跨模块影响时，在 planning 前加入 `design`。实现或验证发现问题时进入 `fix` loop，再回到 verification 和 review。`research-spike` 和 `incident-fix` 有各自的轻量或快速路径，见对应 workflow 单页。完整运行时规则见 [workflows.md](../../references/workflows.md)，状态机细则见 [supervisor-state-machine.md](../../references/supervisor-state-machine.md)。

## 路线图总览

| 步骤 | Dev Cadence 角色 | 做什么 | 常用 Skill |
|---|---|---|---|
| intake | Human / Supervisor | Human 提出请求；Supervisor 记录目标、约束、`workflow_hint` 和已知风险。 | `using-dev-cadence` |
| classify | Supervisor | 选择 `selected_workflow`、`selection_reason` 和 task class；决定 gate 与 artifact 强度。 | `using-dev-cadence` |
| requirements / clarify | Supervisor / Human | 澄清目标、范围、非目标、验收标准和关键取舍；Human 确认边界。 | `cadence-clarify` |
| design? | Supervisor / Worker | 在架构、公共契约、数据模型或跨模块影响存在时形成设计输入。 | `cadence-clarify` / `cadence-plan` |
| planning | Worker | 拆分可执行任务、目标文件、验证计划、风险和 review checkpoints。 | `cadence-plan` |
| implementation / fix | Harness / Worker | Harness 约束执行边界并采集证据；Worker 实现、修复或按 incident 最小变更。 | `cadence-tdd` / `cadence-executing-plans` / `cadence-debug` |
| verification | Harness / Worker | 运行测试、smoke check 或其他验证；记录 skipped checks 与 residual risk。 | `cadence-verify` |
| review | Reviewer | 检查 spec compliance、code quality、测试证据和剩余风险。 | `cadence-request-code-review` |
| rework loop | Supervisor / Harness / Worker / Reviewer | 对有效 findings 或验证失败进行修复、复验、复审，再回到对应 gate。 | `cadence-code-review` / `cadence-tdd` / `cadence-verify` |
| acceptance | Supervisor / Human | Supervisor 汇总证据与 gate 状态；Human 做最终 acceptance。 | `cadence-verify` |

```text
Supervisor routes workflow
  -> Harness executes controlled Worker runs
  -> Worker produces bounded changes or evidence
  -> Reviewer checks when required
  -> Supervisor enforces gates
  -> Human gives final acceptance
```

关键边界：

- [Supervisor](../roles/02-supervisor.md) 控制状态流转。
- [Harness](../roles/03-harness.md) 负责执行和证据采集。
- [Worker Agents](../roles/agents/) 不能自行宣布最终完成。
- [Gate](../gates/) 决定是否允许进入下一阶段。
- Human acceptance 不能被测试通过、review approval 或 commit request 替代。
