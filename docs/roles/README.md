# Dev Cadence 角色

Dev Cadence 把“谁决定风险”“谁控制流程”“谁执行并记录证据”“谁交付具体产物”分开，避免一个 Agent 同时做决策、执行和验收。

整体角色边界见 [architecture.md](../architecture.md#角色边界)。Supervisor 状态机见 [supervisor-state-machine.md](../../references/supervisor-state-machine.md)，Harness 运行边界见 [harness.md](../../references/harness.md)，Worker Agent 契约见 [agent-blueprints.md](../../references/agent-blueprints.md)。

## 角色目录

| Role | 说明 |
|---|---|
| [Human](01-human.md) | 目标、风险、权限、合并、发布和最终验收 |
| [Supervisor](02-supervisor.md) | 流程控制、状态流转、门禁和升级 |
| [Harness](03-harness.md) | 执行约束、权限、日志和证据采集 |
| [Worker Agents](agents/) | Planner、Architect、Developer、Tester、Reviewer、Researcher |

## 通用边界

Human 决定是否接受风险；Supervisor 决定下一步状态；Harness 负责安全执行和证据采集；Worker Agents 交付具体研发产物。

Supervisor、Harness、Developer、Tester、Reviewer 或未指定 agent 不能被记录为 final Human accepter。最终验收必须命名 Human，相关 gate 见 [../gates/g6-human-acceptance.md](../gates/g6-human-acceptance.md)。
