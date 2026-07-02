# Dev Cadence 架构

对使用者来说，Dev Cadence 可以先理解为 Human、Dev Cadence runtime 和 AI agents 的三方协作：Human 决定目标和是否接受风险，Dev Cadence 控制交付节奏并记录证据，AI agents 完成具体工程工作。

在内部责任边界上，Dev Cadence runtime 进一步区分 Supervisor 和 Harness。其他概念，例如 Skills、Gates、Artifacts 和执行工具，都是这些角色使用的机制或产物，不是并列的架构角色。

当前 Codex Plugin 的发布资源边界见 [Codex Plugin 模块边界](codex-plugin-boundaries.md)。

## 责任边界模型

```text
┌──────────────────────────────────────────────────────────────┐
│                          Human                               │
│             Risk acceptance / final decisions                │
└──────────────────────────────┬───────────────────────────────┘
                               │ decisions, constraints
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                       Supervisor                             │
│                 Workflow control / next step                 │
└───────────────┬──────────────────────────────┬───────────────┘
                │ execution request            │ run result
                ▼                              ▲
┌──────────────────────────────────────────────────────────────┐
│                         Harness                              │
│              Safe execution boundary / recording             │
└───────────────┬──────────────────────────────┬───────────────┘
                │ controlled context           │ artifacts/evidence
                ▼                              ▲
┌──────────────────────────────────────────────────────────────┐
│                      Worker Agents                           │
│                 Concrete engineering work                    │
└──────────────────────────────────────────────────────────────┘
```

一句话区分：

```text
Human 决定是否接受风险。
Supervisor 决定下一步该做什么。
Harness 负责这一步怎么被安全执行和记录。
Worker Agents 负责完成具体研发工作。
```

核心约束：

1. Human 是最终意图、风险接受和最终验收的来源。
2. Supervisor 控制 workflow state、routing、预算、循环和升级，不亲自写代码。
3. Harness 包住一次执行，负责上下文、权限、工具边界、日志和证据记录。
4. Worker Agents 交付具体研发产物，不能自行宣布完成或接受风险。
5. Chat 不是事实来源，已确认 artifact 和实际执行证据才是后续执行依据。

## 角色边界

| 角色 | 负责 | 不负责 |
|---|---|---|
| Human | 目标、约束、权限、风险接受、最终验收 | 执行 workflow 机械步骤、替 Agent 产出证据 |
| Supervisor | 状态判断、路由、预算、循环、门禁、升级、下一步决策 | 写业务代码、产出 Worker artifact、替 Human 接受风险 |
| Harness | 上下文注入、工具和权限策略、沙箱、命令日志、证据采集、执行记录 | 定义需求、做架构取舍、判断业务完成、替 Reviewer 或 Human 放行 |
| Worker Agents | 需求、设计、计划、实现、测试、Review、研究等具体研发产物 | 控制 workflow state、批准 gate、替 Harness 记录执行、宣布最终完成 |

`Supervisor`、`Harness`、`Developer`、`Tester`、`Reviewer` 或未指定 agent 不能被记录为 final Human accepter。最终验收必须来自具名 Human。

## 定义索引

- [角色总览](roles/)：Human、Supervisor、Harness 和 Worker Agents 的目录入口。
- [Human](roles/01-human.md)：目标、权限、风险接受和最终验收。
- [Supervisor](roles/02-supervisor.md)：workflow state、routing、gates、escalation 和 handoff。
- [Harness](roles/03-harness.md)：执行边界、工具权限、日志和证据采集。
- [Worker Agents](roles/agents/)：Planner、Architect、Developer、Tester、Reviewer 和 Researcher。
- [Artifacts](artifacts/)：`specs/records/{task_id}/` 下的稳定任务产物。
- [Harness runs](runs/)：`runs/{run_id}/` 下的运行证据。
- [Gates](gates/)：G1-G6 和 Human Gate 的风险控制说明。
- [Context Pack](../references/context-pack.md)：Worker 执行所需的最小上下文。
- [Codex Plugin 模块边界](codex-plugin-boundaries.md)：Skills、references、templates、scripts 和发布包边界。
