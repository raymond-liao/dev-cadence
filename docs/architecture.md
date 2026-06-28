# Dev Cadence 架构

Dev Cadence 的架构关注角色、分层、上下文和执行边界：Human 决定风险，Supervisor 控制流程，Harness 约束执行，Worker Agents 交付具体研发产物。当前 Codex Plugin 的发布资源边界见 [Plugin Skill 模块化](plugin-skill-modularization.md)。

## 核心模型

Dev Cadence 的核心不是让多个 Agent 自由聊天，而是让 Agent 像研发岗位一样，通过规范文档、任务单、代码变更、测试报告、Review 报告和 Harness evidence 协作。

推荐架构：

```text
Human
  -> Supervisor / Orchestrator
  -> Spec & Plan Gate
  -> Execution Harness
  -> Role Agents
  -> Quality Gate
  -> Human Acceptance
```

核心约束：

1. Agent 之间不直接辩论，只通过结构化产物交接。
2. Supervisor 控制状态、路由、预算、循环和门禁，不亲自写代码。
3. Worker Agents 交付具体研发产物，不能自行宣布完成。
4. Harness 负责执行边界、工具约束、权限控制、日志和证据。
5. Chat 不是事实来源，已确认 artifact 才是后续执行依据。

## 架构分层

```text
Interaction Layer
  Human, issue, PR, chat, project management system

Control Layer
  Supervisor / Orchestrator

Agent Layer
  Planner, Architect, Developer, Tester, Reviewer

Context Layer
  Specs, ADR, knowledge base, code index, memory

Harness Layer
  context injection, sandbox, tool policy, execution log, evidence capture

Execution Layer
  Git, CI, test runner, coding agent, shell, MCP tools

Governance Layer
  permissions, audit, cost, approval, security policy
```

不要把编排、Harness 和 coding executor 混在一起。缺少 Harness 时，Supervisor 会直接调用 shell、MCP、CI 或 coding agent，导致上下文、权限、日志、证据和 sandbox 边界不清。

## 角色边界

Dev Cadence 中的“角色”分为四类：

| 类型 | 角色 | 职责 |
|---|---|---|
| Human Decision Roles | Human | 目标、风险、权限、合并、发布和最终验收 |
| Control Role | Supervisor / Orchestrator | 流程控制、状态流转、门禁和升级 |
| Runtime Boundary | Execution Harness | 执行约束、权限、日志和证据 |
| Worker Agent Roles | Planner / Architect / Developer / Tester / Reviewer / Researcher | 具体研发任务产物 |

一句话区分：

```text
Human 决定是否接受风险。
Supervisor 决定下一步该做什么。
Harness 负责这一步怎么被安全执行和记录。
Worker Agents 负责完成具体研发工作。
```

`Supervisor`、`Harness`、`Quality Gate`、`Human Gate` 和 `Permission Policy` 不应设计成普通 Worker Agent。这样可以避免某个“全能 Agent”既决定流程、又执行命令、又采集证据、又宣布完成。

## Worker Agent 边界

Planner 负责把目标和约束整理成需求、范围、非目标和可执行计划。它不能代替 Human 接受风险，也不能直接提交代码。

Architect 负责高风险任务的架构约束、关键取舍、ADR 和跨模块影响分析。它不直接实现代码，也不替代 Reviewer 放行。

Developer 负责在 Harness 限定范围内实现变更、运行验证并提交实现证据。它不能自行宣布完成，不能跳过测试，也不能扩大需求范围。

Tester 负责验证行为、复现 bug、确认修复和记录测试证据。Tester 不应只复述 Developer 自测结果。

Reviewer 负责检查 spec compliance 和 code quality，给出结构化 findings。Reviewer 不应代替 Human 做最终验收。

Researcher 只在 `research-spike`、技术选型或未知风险探索中启用，输出比较、证据和建议，不直接推进产品变更。

## Harness

Harness 是 Supervisor 和具体执行器之间的执行外壳。它不决定任务目标，也不替代 Agent 思考，而是把一次 Agent 执行变成可控、可审计、可复现的运行单元。

```text
Supervisor
  -> Agent Blueprint + Context Pack
  -> Execution Harness
  -> Codex CLI / Claude Code / OpenHands / shell / CI / MCP
  -> Execution Report + Evidence
  -> Supervisor Gate
```

Harness 负责：

- 装载 Agent Blueprint。
- 注入 Context Pack。
- 建立工作区和沙箱。
- 绑定允许使用的工具。
- 执行权限策略。
- 控制预算、时间和循环上限。
- 记录工具调用、命令、日志和 diff。
- 采集测试证据、Review 证据和权限决策。
- 输出结构化 Execution Report。

Harness 不负责定义需求、做架构决策、写业务代码、判断最终完成、替代 Reviewer 放行或替代 Human Gate。

## Context Architecture

Dev Cadence 使用四层上下文：

```text
1. Source of Truth
   Git repo, specs, ADR, tests, PR, issues

2. Run State
   当前任务状态、阶段、负责人、预算、阻塞项

3. Retrieval Context
   代码索引、项目文档、历史 ADR、知识库

4. Ephemeral Context
   当前 Agent 本轮需要的最小上下文包
```

每个 Agent 不应默认获得完整聊天记录，而应获得最小必要 Context Pack：

```yaml
task_id:
goal:
acceptance_criteria:
relevant_specs:
relevant_files:
constraints:
previous_decisions:
forbidden_actions:
expected_output:
```

Context Pack 由 Supervisor 准备，由 Harness 注入到具体执行器。Agent 需要额外上下文时，必须通过 Supervisor 追加，并写入任务产物或 run state。

## Harness Run Context

Context Pack 描述“Agent 应该知道什么”，Harness Run Context 描述“这次执行允许怎么做”。

```yaml
run_id:
agent_role:
blueprint_path:
context_pack_path:
workspace_path:
allowed_tools:
denied_tools:
allowed_paths:
denied_paths:
network_policy:
secret_policy:
budget:
timeout:
max_iterations:
required_evidence:
```

Run Context 必须在每次执行前确定，并随 Execution Report 一起保存。它回答这次 Agent 能读写哪些路径、能否访问网络、能否执行 shell、能否调用 MCP、如何记录测试命令、如何回传 diff 和证据。

## 事实源优先级

当代码、文档、任务产物和聊天信息不一致时，Agent 不能自行选择对自己最方便的解释。

| Priority | Source | 说明 |
|---:|---|---|
| 1 | 当前代码、测试结果、CI 结果、实际运行日志 | 系统当前真实状态 |
| 2 | 已批准的 requirements、design、ADR、acceptance | 当前任务或架构的正式决策 |
| 3 | `specs/records/{task_id}/` 当前任务产物 | 本任务上下文和交接状态 |
| 4 | 项目 README、CONTRIBUTING、runbook、历史 ADR | 项目长期规则 |
| 5 | issue、PR、聊天记录、临时讨论 | 线索，不是长期事实 |

冲突处理规则：

- 发现事实冲突时，标记 `context_conflict`。
- 如果冲突影响范围、架构、安全、权限、测试或验收，进入 Human Gate。
- Human 裁决必须写回正式产物，不能只停留在聊天记录。
- 长期记忆只能引用已确认产物，并保留来源、时间和决策人。

## Tooling 边界

工具应分为三类：

| 类型 | 职责 | 示例 |
|---|---|---|
| Orchestration Framework | 状态机、分支、循环、Human-in-the-Loop | LangGraph、Microsoft Agent Framework、OpenAI Agents SDK |
| Execution Harness | 安全、可审计、可复现地执行一次 Agent run | repo-local harness、sandbox、tool policy、evidence capture |
| Coding Executor | 读写代码、运行命令、调用工具、生成 diff | Codex CLI、Claude Code、OpenHands |

repo-local 阶段的 Harness 可以很轻量：

```text
Harness = workspace policy + tool policy + run log + evidence report
```

不需要一开始实现完整运行时平台。
