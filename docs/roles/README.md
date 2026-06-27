# Dev Cadence 角色

本文说明 Dev Cadence 中的角色边界。运行时角色契约见 [../../references/agent-blueprints.md](../../references/agent-blueprints.md)、[../../references/harness.md](../../references/harness.md) 和 [../../references/supervisor-state-machine.md](../../references/supervisor-state-machine.md)。

本目录是角色目录。整体架构分层和 Context/Tooling 边界见 [../architecture.md](../architecture.md)。

## 角色目录

| Role | 说明 |
|---|---|
| [Human](01-human.md) | 目标、风险、权限、合并、发布和最终验收 |
| [Supervisor](02-supervisor.md) | 流程控制、状态流转、门禁和升级 |
| [Harness](03-harness.md) | 执行约束、权限、日志和证据采集 |
| [Worker Agents](agents/) | Planner、Architect、Developer、Tester、Reviewer、Researcher |

## 角色类型

| 类型 | 角色 | 核心边界 |
|---|---|---|
| Human Decision Roles | Human | 接受目标、风险、权限、合并、发布和最终责任 |
| Control Role | Supervisor / Orchestrator | 决定下一步状态，不直接写代码 |
| Runtime Boundary | Harness | 执行约束和证据采集，不做语义批准 |
| Worker Agent Roles | [Planner / Architect / Developer / Tester / Reviewer / Researcher](agents/) | 交付具体研发产物，不能自行宣布最终完成 |

## 通用规则

Supervisor、Harness、Developer、Tester、Reviewer 或未指定 agent 不能被记录为 final Human accepter。最终验收必须命名 Human。
