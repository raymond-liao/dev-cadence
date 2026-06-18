# AI-Native Software Delivery Framework

## 1. 背景与目标

本方案的目标不是设计某个具体业务系统，而是设计一套 AI-Native 软件交付协作框架。

核心目标是建立一种：

```text
Human + Harness-Mediated Multi-Agent Team
```

的软件开发模式，让 AI 能够在 Harness 约束下像研发团队一样协作完成软件开发工作，而不是仅仅作为代码生成工具。

这里的 Harness 不是新的研发角色，而是 Agent 执行的运行边界，负责上下文注入、工具约束、权限控制、日志记录和证据采集。

本框架重点关注：

- AI 如何组织
- AI 如何协作
- AI 如何决策
- Agent 如何分工
- Agent 如何形成工作流
- Agent 如何形成开发闭环
- Harness 如何约束和记录 Agent 执行
- 如何管理上下文和知识
- 如何与开发者协同工作

本框架不重点讨论：

- 具体业务系统实现
- Spring Boot、DDD、数据库等项目工程细节
- 某个单一技术栈的代码结构

## 2. 核心判断

推荐将 AI-Native 软件交付协作框架设计为：

```text
Supervisor-Controlled
Harness-Mediated
Artifact-First
Spec-Driven
Quality-Gated
Multi-Agent Development Framework
```

核心不是让多个 Agent 自由聊天，而是让 Agent 像研发岗位一样，通过规范文档、任务单、代码变更、测试报告、Review 报告进行协作。

关键原则：

1. Agent 之间不直接辩论，只通过结构化产物交接。
2. Supervisor 只负责任务流转、预算、状态和门禁，不亲自写代码。
3. Developer 只能交付代码变更和验证证据，不能自行宣布完成。
4. Tester 和 Reviewer 独立于 Developer。
5. Chat 不是事实来源，spec、ADR、测试报告、Review 报告才是事实来源。
6. 所有循环必须有最大次数、退出条件和升级到人的规则。
7. 所有 Agent 执行必须经过 Harness，不能让 Supervisor 直接把任务裸交给 shell、MCP、CI 或 coding agent。

## 3. 推荐总体架构

```text
Human
  ↓
Supervisor / Orchestrator
  ↓
Spec & Plan Gate
  ↓
Execution Harness
  ↓
Role Agents
  Planner / Architect / Developer / Tester / Reviewer
  ↓
Fix Loop
  ↓
Human Merge / Release
```

### 3.1 架构分层

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

### 3.2 核心职责

Supervisor 负责：

- 识别任务类型
- 判定并路由工作流
- 调度 Agent
- 控制上下文包
- 控制循环次数
- 执行质量门禁
- 触发人工确认

Supervisor 不负责：

- 写代码
- 直接做架构决策
- 代替 Reviewer 放行
- 绕过测试和审批

### 3.3 Harness 核心职责

Harness 是 Supervisor 和具体执行器之间的执行外壳。

它不决定任务目标，也不替代 Agent 思考，而是负责把一次 Agent 执行变成可控、可审计、可复现的运行单元。

```text
Supervisor
  ↓
Agent Blueprint + Context Pack
  ↓
Execution Harness
  ↓
Codex CLI / Claude Code / OpenHands / shell / CI / MCP
  ↓
Execution Report + Evidence
  ↓
Supervisor Gate
```

Harness 负责：

- 装载 Agent Blueprint
- 注入 Context Pack
- 建立工作区和沙箱
- 绑定允许使用的工具
- 执行权限策略
- 控制预算、时间和循环上限
- 记录工具调用、命令、日志和 diff
- 采集测试证据和 Review 证据
- 输出结构化 Execution Report

Harness 不负责：

- 定义需求
- 做架构决策
- 写业务代码
- 判断最终是否完成
- 替代 Reviewer 放行
- 替代 Human Gate 批准权限、合并或发布

Harness 的存在是为了避免一个常见错误：Supervisor 直接驱动 coding agent 或 shell，导致上下文、权限、日志、证据和产物没有统一边界。

## 4. 角色与职责分层

本框架中的“角色”分为四类，不应全部理解为 Agent。

```text
Human Decision Roles
  负责目标、边界、关键批准和最终责任

Control Role
  Supervisor / Orchestrator
  负责流程控制，不直接执行研发工作

Runtime Boundary
  Execution Harness
  负责执行约束、权限、日志和证据

Worker Agent Roles
  Planner / Architect / Developer / Tester / Reviewer
  Optional: Researcher
  负责具体研发任务产物
```

一句话区分：

```text
Human 决定是否接受风险。
Supervisor 决定下一步该做什么。
Harness 负责这一步怎么被安全执行和记录。
Worker Agents 负责完成具体研发工作。
```

### 4.1 哪些不是 Agent

以下职责不应设计成普通 Worker Agent：

| 名称 | 类型 | 为什么不是 Agent |
|---|---|---|
| Human | Decision Role | 人承担目标、风险、合并、发布和最终责任 |
| Supervisor | Control Role | 它控制流程和门禁，不产出业务实现 |
| Harness | Runtime Boundary | 它约束和记录执行，不做语义判断 |
| Quality Gate | Policy | 它是检查规则，不是独立工作者 |
| Permission Policy | Policy | 它定义权限边界，不负责完成任务 |

这样区分是为了避免一个错误设计：让某个“全能 Agent”既决定流程、又执行命令、又采集证据、又宣布完成。

### 4.2 Worker Agent 拓扑对比

| 拓扑 | 适合场景 | 优点 | 风险 | 建议 |
|---|---|---|---|---|
| Single Agent | 小修小改 | 成本低，速度快 | 自测自审，质量弱 | 可用于简单任务 |
| Planner + Executor | 中等任务 | 简单可控 | Review 仍弱 | 可用于轻量场景 |
| Role-Based Team | 需求到交付 | 边界清楚 | 容易变成 Agent 聊天室 | 必须用文档交接 |
| Supervisor + Worker | 复杂研发流 | 可控、可审计、可门禁 | 实现成本高 | 推荐主架构 |
| Graph Workflow | 企业级流程 | 支持状态、回放、分支、循环 | 需要工程化 | 推荐底座 |
| Swarm / Peer Agents | 探索研究 | 发散能力强 | 无限讨论、责任不清 | 不推荐用于交付 |

### 4.3 推荐组织方式

推荐采用：

```text
Supervisor + Harness + Role-Based Worker Agents + Graph Workflow
```

也就是：

```text
Supervisor
  ↓
Harness
  ↓
Worker Agents
  ├── Planner
  ├── Architect
  ├── Developer
  ├── Tester
  ├── Reviewer
  └── Optional: Researcher
```

Agent 之间不应该自由互相调用，而应该由 Supervisor 基于工作流状态进行调度。

实际执行时，Supervisor 不直接驱动 Worker Agent 使用工具，而是通过 Harness 为每次执行建立 run context、工具边界和执行记录。

## 5. Agent 角色边界

本章只描述 Worker Agent。

Supervisor、Harness、Human Gate、Quality Gate 都不是 Worker Agent。

### 5.0 Core / Optional Agent

推荐区分：

| 类型 | Agent | 说明 |
|---|---|---|
| Core | Planner | 负责需求澄清、验收标准和任务拆分 |
| Core | Architect | 负责技术方案、架构约束和 ADR |
| Core | Developer | 负责实现和修复 |
| Core | Tester | 负责测试设计、测试执行和验证证据 |
| Core | Reviewer | 负责代码审查、架构一致性、安全和质量判断 |
| Optional | Researcher | research-spike 或技术选型时启用 |

### 5.1 Planner Agent

负责：

- 理解需求
- 澄清目标
- 拆分任务
- 生成任务计划
- 定义验收标准

输出：

- `requirements.md`
- `tasks.md`
- acceptance criteria

不负责：

- 写代码
- 做具体技术实现
- Review 代码

### 5.2 Architect Agent

负责：

- 技术方案设计
- 架构约束定义
- 关键决策记录
- 风险识别
- 与既有系统约束对齐

输出：

- `design.md`
- ADR
- architecture constraints

不负责：

- 执行编码
- 替代 Developer 做实现
- 替代 Reviewer 放行

### 5.3 Developer Agent

负责：

- 编码实现
- 修改代码
- 运行必要测试
- 修复明确缺陷
- 提供实现说明

输出：

- code diff
- implementation notes
- test command
- test result

不负责：

- 自行变更需求
- 自行改变架构约束
- 自行宣布任务完成

### 5.4 Tester Agent

负责：

- 测试设计
- 测试执行
- 缺陷反馈
- 回归验证

输出：

- `test_plan.md`
- `test_report.md`
- defect list

不负责：

- 替代 Developer 修代码
- 替代 Reviewer 做架构审查

### 5.5 Reviewer Agent

负责：

- Code Review
- 架构一致性检查
- 安全和质量检查
- 可维护性检查
- 门禁判断

输出：

- `review_report.md`
- blocking issues
- approval / rejection decision

不负责：

- 大规模重写代码
- 替代 Tester 执行测试
- 绕过质量门禁

### 5.6 Researcher Agent

负责：

- 技术调研
- 方案比较
- 风险分析
- 外部资料整理
- 形成决策建议

输出：

- `research_report.md`
- options comparison
- recommendation
- open questions

不负责：

- 直接做架构最终决策
- 直接进入编码实现
- 替代 Human 或 Architect 批准方案

## 6. Workflow 设计

### 6.1 标准开发工作流

```text
Intake
  ↓
Requirement Spec
  ↓
Architecture Decision
  ↓
Task Breakdown
  ↓
Implementation
  ↓
Test
  ↓
Review
  ↓
Fix Loop
  ↓
Acceptance
  ↓
Merge / Release
```

### 6.2 阶段输入输出

| 阶段 | 输入 | 输出 | Gate |
|---|---|---|---|
| Requirement | 用户目标 | `requirements.md` | 人确认范围 |
| Design | requirements | `design.md`、ADR | 架构约束确认 |
| Planning | design | `tasks.md` | 任务可执行 |
| Build | task | code diff、实现说明 | 测试可跑 |
| Test | diff | `test_report.md` | 测试证据完整 |
| Review | diff + tests | `review_report.md` | 无阻塞问题 |
| Fix | review issues | patch | 回到 Verification / Review |
| Accept | 所有产物 | `acceptance.md` | 人合并 |

### 6.3 可执行状态机

标准工作流应进一步表达为状态机。

Supervisor 根据当前状态决定下一步，Harness 负责执行每个 Agent stage 并记录证据。

| State | Owner | Input | Output | Gate | Next |
|---|---|---|---|---|---|
| `intake` | Supervisor | user request | `00-brief.md` | 目标、约束、任务类型已记录 | `classify` |
| `classify` | Supervisor | brief | task class / workflow type | 已判定 `S0/S1/S2/incident/research-spike` | `requirements` 或 lightweight path |
| `requirements` | Planner | brief | `requirements.md` | 人确认范围和验收标准 | `planning` 或 `design` |
| `design` | Architect / Planner | requirements | `design.md` / ADR | 高风险任务完成架构确认 | `planning` |
| `planning` | Planner | requirements + design | `tasks.md` | 任务可执行，验收标准明确 | `implementation` |
| `implementation` | Developer via Harness | tasks + context pack | code diff + `implementation.md` + execution report | 有实现说明、diff 和初步验证证据 | `test` |
| `test` | Tester via Harness | diff + implementation + execution report | `test_report.md` | 测试证据完整，缺陷已结构化记录 | `review` 或 `fix` |
| `review` | Reviewer via Harness | diff + implementation + test report | `review_report.md` | 无 blocker / major，或进入修复 | `acceptance` 或 `fix` |
| `fix` | Developer via Harness | review issues | patch + execution report | 修复针对明确 issue，未扩大范围 | `test` |
| `acceptance` | Human + Supervisor | all artifacts | `acceptance.md` | 人确认风险并批准合并/结束 | `done` |
| `blocked` | Supervisor + Human | blocker | escalation decision | 人决定继续、降级、拆分、终止 | selected state |

关键规则：

- 每个 Agent 执行状态都必须经过 Harness。
- 每个 Harness run 都必须生成 `run-context.md`、`execution-report.md`、`tool-log.md` 和 `permission-decisions.md`；有文件变更时还必须生成 `diff-summary.md`；有命令或测试时还必须生成 `test-log.md`。
- Supervisor 只能根据产物和 Gate 决定下一步，不能代替 Agent 产出内容。
- Human Gate 的决定必须写入 `requirements.md`、ADR 或 `acceptance.md`。
- `S2` 任务在实现前必须记录必要的需求、架构、风险或权限 Human Gate。
- 非 `verified` 的验证状态不能自动进入 Review approved 或 final acceptance，除非具名 Human Gate 接受剩余风险。
- `acceptance.md` 不能写成 Supervisor、Harness 或 Worker Agent 验收，必须记录具名 Human accepter。
- `fix` 状态最多循环 3 次，超限进入 `blocked`。

### 6.4 工作流判定与路由

不同任务应走不同工作流，但不要求用户手动选择。

用户只需要描述目标、背景、约束和期望结果。Supervisor 根据请求内容和风险自动判定 `selected_workflow`，记录 `selection_reason`；如果用户明确说“只做 review”“先调研”“按 incident 处理”，则将其作为 `workflow_hint` 处理，而不是要求用户承担流程选择责任。

```text
feature-dev
bugfix
refactor
code-review
research-spike
release
incident-fix
```

每种工作流都应定义：

- 触发条件
- 必需 Agent
- 可选 Agent
- 必需产物
- 质量门禁
- 人工审批点
- 最大循环次数

### 6.5 任务分级与工作流强度

目标版 Skill 应支持完整角色体系，但不要求每个任务都走同样重量的流程。

任务应先由 Supervisor 分类，再决定需要哪些 Agent、产物和 Human Gate。

| Class | 适用场景 | 必需 Agent | 必需产物 | Human Gate |
|---|---|---|---|---|
| `S0 trivial` | 文案、注释、低风险配置、可快速回滚的小修 | Developer，Reviewer 按需 | brief、implementation、test evidence 或 not verified reason、acceptance | final acceptance |
| `S1 normal` | 普通 feature、bugfix、code-review、局部重构 | Planner、Developer、Tester、Reviewer | requirements、tasks、implementation、test_report、review_report、acceptance | requirement acceptance、final acceptance |
| `S2 high-risk` | 架构、安全、权限、CI、数据迁移、跨模块变更 | Planner、Architect、Developer、Tester、Reviewer | requirements、design/ADR、tasks、implementation、test_report、review_report、acceptance | 实现前 requirement / architecture / risk approval，必要时 permission approval，最终 human acceptance |
| `research-spike` | 技术选型、未知风险探索、方案比较 | Researcher、Architect 按需 | research_report、options comparison、recommendation、open questions | decision review |
| `incident` | 紧急生产修复或高压故障恢复 | Supervisor、Developer、Tester/Reviewer 按需 | triage、minimal patch、smoke test、emergency approval、post-incident backfill | emergency approval、post-incident acceptance |

这不是把目标版 Skill 拆成简化版，而是让同一个目标版 Skill 根据风险自动调整流程强度。

核心规则：

- 角色可以存在，但某个任务可以不启用全部角色。
- 跳过某个阶段必须写明原因和剩余风险。
- 低风险任务可以轻量，但仍必须保留 diff、验证证据或不可验证说明、最终验收。
- 高风险任务不能轻量化；必须启用 Architect、权限门禁和更严格的 Harness policy。

### 6.6 Incident-fix 快速路径

`incident-fix` 不应照搬完整 feature-dev 流程。

推荐路径：

```text
triage
  ↓
minimal safe patch
  ↓
smoke test
  ↓
human emergency approval
  ↓
deploy / merge
  ↓
post-incident review
  ↓
backfill spec / test / ADR if needed
```

incident-fix 的重点是：

- 快速恢复服务或关键能力。
- 记录临时绕过了哪些普通门禁。
- 记录谁批准、何时批准、批准的风险是什么。
- 保留回滚或降级方案。
- 事后补齐测试、文档、ADR 或复盘结论。

## 7. Loop 设计

### 7.1 推荐三层 Loop

软件开发最适合三层闭环。

```text
Micro Loop:
Developer → run test → fix → run test

Quality Loop:
Developer → Tester → Reviewer → Fix → Tester → Reviewer

Spec Loop:
Requirement / Design → Human / Architect → Revision
```

### 7.2 Fix Loop

```text
Developer
  ↓
Tester
  ↓
Reviewer
  ↓
Issues?
  ├── No → Done
  └── Yes → Developer Fix → Tester → Reviewer
```

### 7.3 Loop 控制规则

```text
max_fix_iterations = 3
max_agent_turns_per_stage = N
no_peer_debate = true
all_rejections_require_evidence = true
unresolved_conflict_goes_to_human = true
```

### 7.4 Issue 格式

Reviewer 或 Tester 反馈问题时，必须使用结构化格式：

```text
severity: blocker | major | minor
evidence: file / test / spec reference
reason:
required_change:
owner:
```

不允许输出：

```text
感觉不好
建议再优化一下
可能有问题
我认为还不够优雅
```

除非能够提供明确证据、影响范围和修改要求。

## 8. Human-in-the-Loop 设计

### 8.1 人的核心职责

人不应该介入每一步，但必须控制高风险边界。

| 人介入点 | 原因 |
|---|---|
| 需求确认 | 防止 Agent 自行扩展范围 |
| 架构确认 | 防止错误方向被自动放大 |
| 权限批准 | 网络、数据库、生产环境、密钥、删除操作 |
| Merge | 最终责任仍在人 |
| Release | 生产风险需要人确认 |
| Loop 超限 | Agent 反复修不好时停止消耗 |

### 8.2 人工确认类型

Human Gate 不应全部理解为阻塞审批。

| Type | 含义 | 典型场景 | 是否阻塞 |
|---|---|---|---|
| `approval_required` | 没有人明确批准不能继续 | merge、release、生产操作、密钥、数据库写入、CI workflow 修改、删除操作 | 是 |
| `review_required` | 人需要审查方案或风险，给出修改意见或确认方向 | 架构方案、高风险重构、安全影响、跨模块设计 | 通常阻塞关键阶段 |
| `info_required` | AI 缺少必要信息，必须由人补充事实或取舍 | 需求歧义、验收标准不清、业务规则冲突 | 阻塞相关阶段 |
| `notify_only` | 只需要告知人，不需要等待批准 | 低风险测试重跑、状态更新、已自动恢复的非关键失败 | 否 |

这样可以避免两个极端：所有事项都等待人审批，或者高风险操作被 AI 自动推进。

### 8.3 人机协作原则

- AI 负责准备材料，人负责关键决策。
- AI 可以提出建议，但不能越权批准。
- 人的决策必须写入 spec、ADR 或 acceptance 产物。
- 人的口头确认不应只停留在聊天记录中。

## 9. Context Architecture

### 9.1 四层上下文

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

### 9.2 Context Pack

每个 Agent 不应默认获得完整聊天记录，而应获得最小必要上下文包。

```text
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

Context Pack 由 Supervisor 准备，由 Harness 注入到具体执行器。

Agent 不能绕过 Context Pack 自行扩大上下文范围。需要额外上下文时，必须通过 Supervisor 追加，并写入任务产物或 run state。

### 9.3 Harness Run Context

Context Pack 描述“Agent 应该知道什么”，Harness Run Context 描述“这次执行允许怎么做”。

```text
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

Harness Run Context 必须在每次执行前确定，并随 Execution Report 一起保存。

它解决的是执行边界问题：

- 这个 Agent 能读哪些文件？
- 能写哪些目录？
- 能不能访问网络？
- 能不能执行 shell？
- 能不能调用 MCP？
- 能不能访问密钥？
- 测试命令和日志如何记录？
- diff 和证据如何回传？

### 9.4 避免上下文漂移

避免上下文漂移的关键是：写入记忆前必须经过产物化。

聊天内容不能直接进入长期记忆。只有被确认的以下内容才能沉淀：

- requirements
- design
- ADR
- review conclusion
- test result
- acceptance decision

### 9.5 Source of Truth 优先级与冲突处理

当代码、文档、任务产物和聊天信息不一致时，Agent 不应自行选择对自己最方便的解释。

推荐优先级：

| Priority | Source | 说明 |
|---:|---|---|
| 1 | 当前代码、测试结果、CI 结果、实际运行日志 | 代表系统当前真实状态 |
| 2 | 已批准的 requirements、design、ADR、acceptance | 代表当前任务或架构的正式决策 |
| 3 | `specs/{task_id}/` 当前任务产物 | 代表本任务上下文和交接状态 |
| 4 | 项目 README、CONTRIBUTING、runbook、历史 ADR | 代表项目长期规则 |
| 5 | issue、PR、聊天记录、临时讨论 | 只能作为线索，不能直接作为长期事实 |

当前用户指令可以改变任务方向，但需要写入 `requirements.md`、ADR、`tasks.md` 或 `acceptance.md` 后，才能成为后续 Agent 的稳定事实来源。

冲突处理规则：

- 发现事实冲突时，必须标记 `context_conflict`。
- 如果冲突影响范围、架构、安全、权限、测试或验收，必须进入 Human Gate。
- Human 的裁决必须写回正式产物，不能只停留在聊天记录。
- 长期记忆只能引用已确认产物，并保留来源、时间和决策人。

## 10. Spec Driven Development

### 10.1 推荐目录结构

```text
AGENTS.md
.gitignore

.ai/
  config.yaml
  local.yaml
  control/
    supervisor.md
  agents/
    planner.md
    architect.md
    developer.md
    tester.md
    reviewer.md
    researcher.md   # optional
  workflows/
    feature-dev.md
    bugfix.md
    code-review.md
    refactor.md
    research-spike.md
    release.md
    incident-fix.md
  policies/
    task-classes.md
    quality-gates.md
    permission-policy.md
    context-policy.md
    escalation-policy.md
    harness-policy.md
  templates/
    context-pack.md
    run-context.md
    execution-report.md

specs/
  feature-x/
    00-brief.md
    01-requirements.md
    02-design.md
    03-tasks.md
    04-test-plan.md
    05-implementation.md
    06-test-report.md
    07-review-report.md
    08-acceptance.md
    runs/
      run-001/
        run-context.md
        execution-report.md
        tool-log.md
        test-log.md
        diff-summary.md
        permission-decisions.md
    decisions/
      ADR-001.md
```

`.ai/config.yaml` 保存团队默认配置：

```yaml
artifact_language: en
```

`.ai/local.yaml` 保存用户本地偏好，初始化时默认生成注释示例：

```yaml
# Local Dev Cadence preferences.
# Uncomment and change this value to override generated artifact prose language for your local work.
# Supported values:
# - en: English
# - zh: Chinese, Simplified Chinese by default
# artifact_language: en
```

`artifact_language` 支持 `en` 和 `zh`。它只控制 spec、测试报告、review 报告等任务产物中的自然语言正文；文件名、YAML 字段、状态枚举、workflow ID 和 gate ID 仍保持英文。如果用户取消注释 `.ai/local.yaml` 中的 `artifact_language`，它优先于 `.ai/config.yaml`。初始化或更新时应把 `.ai/local.yaml` 加入 `.gitignore`。

### 10.2 核心文档

#### `requirements.md`

用于记录：

- 用户目标
- 范围
- 非目标
- 约束
- 验收标准
- 需要人工确认的问题

#### `design.md`

用于记录：

- 技术方案
- 架构约束
- 关键组件
- 数据流
- 风险
- 替代方案

#### `tasks.md`

用于记录：

- 任务拆分
- 执行顺序
- 每个任务的输入
- 每个任务的输出
- 验收标准

#### ADR

用于记录：

- 决策背景
- 决策内容
- 替代方案
- 影响
- 后续约束

## 11. Quality Gate

### 11.1 最小质量门禁

| Gate | 检查项 | 通过条件 |
|---|---|---|
| Gate 1 | requirements accepted | 范围、非目标、验收标准已确认 |
| Gate 2 | design accepted when required | 高风险任务已有 design/ADR，且架构约束被确认 |
| Gate 3 | task executable | task 有输入、输出、目标文件、验收标准和 forbidden actions |
| Gate 4 | test evidence complete and reproducible | 测试命令、环境、结果、覆盖范围、失败或跳过原因完整 |
| Gate 5 | review has no blocker / major issue | Reviewer 给出结构化结论，且无 blocker / major 未解决 |
| Gate 6 | human approves merge / release | 人确认剩余风险并批准结束、合并或发布 |

每个 Gate 都应记录：

```text
gate_id:
required_inputs:
required_outputs:
pass_condition:
fail_condition:
evidence_fields:
human_override:
escalation:
```

质量门禁不能只读取 Agent 自述，还必须读取对应 Harness run 的 `execution-report.md`、`tool-log.md`、`test-log.md`、`diff-summary.md` 和 `permission-decisions.md`。

缺少任一必需 Harness evidence 的 Agent 执行，不能进入 `approved`。`execution-report.md` 中的摘要不能替代 `tool-log.md`、`test-log.md`、`diff-summary.md` 或 `permission-decisions.md`。

### 11.2 验证状态

测试和验证不应只有 pass / fail。

推荐验证状态：

```text
verified
partially_verified
not_verified
blocked_by_environment
```

任何非 `verified` 状态必须写明：

- 缺口是什么。
- 剩余风险是什么。
- 建议如何补测。
- 是否允许进入人工验收。
- 如果允许，谁接受了该风险。

非 `verified` 状态不能自行通过质量门禁。必须进入 Human Gate，由具名 Human 接受缺口和剩余风险后，才能继续 Review 或 Acceptance。

### 11.3 Developer 必须提交的内容

```text
- changed files
- rationale
- test commands
- test result
- known limitations
```

### 11.4 Developer 不能提交的内容

```text
- “我认为已经完成”
- 未验证的结论
- 没有测试证据的质量声明
```

### 11.5 Review 判断

Reviewer 的结论只能是：

```text
approved
approved_with_minor_notes
changes_requested
blocked
```

对于 `changes_requested` 或 `blocked`，必须给出证据和修改要求。

## 12. Tooling 分析

截至 2026 年，建议将工具分为三类：

1. 编排框架
2. 执行 Harness
3. 编码执行器

不要把这三类工具混在一起评估。

三者的关系是：

```text
Orchestration Framework
  负责状态机、分支、循环、Human-in-the-Loop

Execution Harness
  负责把一次 Agent 执行安全、可审计、可复现地跑起来

Coding Executor
  负责具体读写代码、运行命令、调用工具、生成 diff
```

如果缺少 Harness，编排层会直接调用 coding executor，导致权限、上下文、日志、证据和 sandbox 边界不清。

### 12.1 编排框架

| 工具 | 定位 | 评价 |
|---|---|---|
| LangGraph | 图式 Agent 编排底座 | 适合做 Supervisor、状态机、循环、Human-in-the-Loop |
| Microsoft Agent Framework | 企业级 Agent SDK | 适合 Microsoft / Azure / .NET 企业栈 |
| AutoGen | 历史型多 Agent 框架 | 新项目不建议作为核心，可关注迁移到 Microsoft Agent Framework |
| CrewAI | 高层 role / task 编排 | 适合快速搭建轻量流程，但复杂状态和强门禁能力相对有限 |
| OpenAI Agents SDK | 自研 Agent Runtime | 适合构建产品级 agent runtime，支持 handoff、guardrail、tracing |

### 12.2 执行 Harness

Harness 的定位是“Agent 执行运行时外壳”，不是编排框架，也不是 coding agent 本身。

| 能力 | 说明 |
|---|---|
| Context Injection | 将 Supervisor 准备的 Context Pack 注入到执行器 |
| Workspace Isolation | 限制 Agent 读写范围，避免污染其他项目或任务 |
| Tool Binding | 绑定本次运行允许使用的 shell、MCP、CI、Git、测试工具 |
| Permission Gate | 对网络、数据库、密钥、删除、生产环境等高风险动作触发人工审批 |
| Evidence Capture | 采集 diff、命令、日志、测试结果、截图、Review 证据 |
| Execution Report | 输出结构化运行报告，供 Supervisor 做 Gate 判断 |
| Budget Control | 控制 token、时间、命令次数、Fix Loop 次数 |
| Audit Trail | 记录谁在什么上下文下触发了什么工具和产物 |

repo-local 阶段的 Harness 可以很轻量：

```text
Harness = workspace policy + tool policy + run log + evidence report
```

不需要一开始实现完整运行时平台。

Harness 产物建议包括：

```text
run_context.md
execution_report.md
tool_log.md
test_log.md
diff_summary.md
permission_decisions.md
```

### 12.3 编码执行器

| 工具 | 定位 | 评价 |
|---|---|---|
| Codex CLI | 本地 / 云编码 Agent | 适合作为 Developer、Tester 或 Reviewer 执行器 |
| Claude Code | 成熟编码 Agent | 适合作为 Developer、Tester、Reviewer、自动化编码执行器 |
| OpenHands | 自主编码执行平台 | 适合作为沙箱化 Developer Worker，不建议作为总编排层 |
| OpenManus | 通用 Agent 原型 | 适合研究和原型，不建议作为企业研发协作核心 |
| MetaGPT | SOP 化软件公司范式 | 适合借鉴思想，不建议直接作为企业控制面 |

### 12.4 推荐组合

通用推荐：

```text
Orchestration: LangGraph
Harness: repo-local execution harness / sandbox / tool policy / evidence capture
Execution: Codex CLI / Claude Code / OpenHands
Context: Git + specs + ADR + code index
Tools: MCP
Quality: CI + Tester Agent + Reviewer Agent
Human Gate: requirement / architecture / merge / release
```

Microsoft 企业栈推荐：

```text
Orchestration: Microsoft Agent Framework
Model: Azure OpenAI
Harness: enterprise sandbox + approval workflow + execution trace
Code Platform: GitHub / Azure DevOps
Integration: MCP / A2A
Governance: Entra ID / RBAC / audit
```

## 13. 交付形态：团队 Skill

本框架的最终产出不应只是一个说明文档，也不应一开始就做成完整平台。

推荐将可共享产物设计为一个团队 Skill：

```text
AI-Native Software Delivery Framework Skill
```

这个 Skill 的作用是把本方案中的 Agent 角色、工作流、上下文规则、质量门禁和 spec 模板，沉淀为团队成员可以在不同代码仓库中复用的 AI 协作规范。

### 13.1 为什么交付为 Skill

团队 Skill 适合承载本框架的原因：

- 它可以被团队成员直接安装和共享。
- 它可以把研发协作规则变成 AI 可执行的工作说明。
- 它可以在不同项目中生成一致的 `.ai/` 和 `specs/` 结构。
- 它不绑定某个具体业务系统或技术栈。
- 它允许框架先以轻量方式落地，再逐步演进为平台。

也就是说，Skill 是本框架从“理念”进入“团队日常使用”的第一种交付形态。

### 13.2 Skill 的职责边界

这个 Skill 负责：

- 初始化项目内的 AI 协作目录结构。
- 生成 Agent Blueprint 模板。
- 生成标准 workflow 模板。
- 生成 spec / ADR / review / test report 模板。
- 生成 Harness policy、run context 和 execution report 模板。
- 指导 Supervisor 如何调度 Planner、Architect、Developer、Tester、Reviewer 以及可选的 Researcher。
- 定义质量门禁、上下文包和人工确认点。

这个 Skill 不负责：

- 直接替代项目管理系统。
- 直接实现企业级 Agent 编排平台。
- 直接替代 CI、代码平台或发布系统。
- 为某个具体技术栈生成固定工程结构。
- 绕过人的需求确认、架构确认、权限确认和 merge 决策。

### 13.3 Skill 自身结构

推荐 Skill 自身采用以下结构：

```text
skills/dev-cadence/
  SKILL.md
  agents/
    openai.yaml
  references/
    principles.md
    supervisor-state-machine.md
    task-classes.md
    agent-blueprints.md
    workflows.md
    context-pack.md
    harness.md
    quality-gates.md
    human-gates.md
    spec-templates.md
    skill-layout.md
```

其中：

| 文件 | 作用 |
|---|---|
| `SKILL.md` | 定义 Skill 何时触发、如何初始化框架、如何进行工作流判定与路由 |
| `agents/openai.yaml` | 定义 Skill 在 OpenAI/Codex 相关界面中的展示元数据 |
| `principles.md` | 记录本框架的核心原则和不可突破的边界 |
| `supervisor-state-machine.md` | 记录 Supervisor 状态机、状态流转、跳过状态和 blocked 规则 |
| `agent-blueprints.md` | 记录各类 Agent Blueprint 的模板和职责边界 |
| `task-classes.md` | 记录 S0/S1/S2、research-spike、incident 等任务分级规则 |
| `workflows.md` | 记录 feature-dev、bugfix、refactor、code-review、incident-fix 等工作流 |
| `context-pack.md` | 记录 Agent 最小上下文包格式、来源优先级和冲突规则 |
| `harness.md` | 记录 Harness 职责、run context、工具策略和执行报告格式 |
| `quality-gates.md` | 记录质量门禁、循环限制、人工升级规则 |
| `human-gates.md` | 记录 approval_required、review_required、info_required、notify_only 的触发规则 |
| `spec-templates.md` | 记录 requirements、design、tasks、test report、review report 模板 |
| `skill-layout.md` | 记录 Skill 包结构和目标仓库 `AGENTS.md`、`.ai/`、`specs/` 落地结构 |

Skill 的设计重点是渐进式加载：`SKILL.md` 保持精简，只放工作流入口和路由规则；详细模板和规范放在 `references/` 中，只有需要时再读取。

系统层级 Skill 的触发边界必须收窄：隐式触发只覆盖仓库级 AI 交付规则的初始化或安装，用户初始化时不需要写 `$dev-cadence`。更新、同步、修复、检查、诊断等维护动作必须要求用户明确点名 `$dev-cadence` 或 `dev-cadence`。普通开发请求只有在仓库已经通过 `AGENTS.md` 和 `.ai/` 初始化后，才由仓库本地规则自动进入流程。

仓库本地规则必须区分 workflow 推断和产品意图推断：Agent 可以自动判定 workflow，但不能猜测不明确的产品意图。只要目标、范围、非目标、参考行为或验收标准存在多种合理解释，就必须进入 `info_required` Human Gate，在实现前向用户澄清。未经确认的假设只能记录在 `assumptions` 或 `open_questions` 中，不能写成 `scope`、`non_goals` 或 `acceptance_criteria`。

实现前必须有 Requirements Readiness Check：预期行为、参考行为、范围、非目标、验收标准和验证方式都要明确且可追溯。用户说“不符合预期”“不一致”“和某端一样”“match/align/parity”或“修复这个问题”时，如果没有明确比较维度和预期结果，必须先问用户；不能通过读代码自行推断。用户否定前一次结果时，之前的 G1 失效，必须回到 requirements。

但澄清不能变成把问题丢回给用户。Agent 应先做有限的只读分析，检查相关代码、文档或既有 spec，提出 2-4 个候选解释、证据路径和推荐选项，再请用户确认。代码证据只能支持候选解释，不能替代用户确认；当需要澄清时，G1 必须记录 named Human 的选择或显式延期，不能记录为 repository evidence、code inspection、Supervisor 或 Worker Agent。澄清阶段不得修改产品代码。

### 13.4 Skill 在代码仓库中生成的结构

当团队在某个代码仓库中使用该 Skill 时，推荐生成以下结构：

```text
.ai/
  config.yaml
  local.yaml
  control/
    supervisor.md
  agents/
    planner.md
    architect.md
    developer.md
    tester.md
    reviewer.md
    researcher.md
  workflows/
    feature-dev.md
    bugfix.md
    refactor.md
    code-review.md
    research-spike.md
    release.md
    incident-fix.md
  policies/
    task-classes.md
    human-gates.md
    quality-gates.md
    permission-policy.md
    context-policy.md
    escalation-policy.md
    harness-policy.md
  templates/
    context-pack.md
    run-context.md
    execution-report.md

specs/
  {task_id}/
    00-brief.md
    01-requirements.md
    02-design.md
    03-tasks.md
    04-test-plan.md
    05-implementation.md
    06-test-report.md
    07-review-report.md
    08-acceptance.md
    runs/
      {run_id}/
        run-context.md
        execution-report.md
        tool-log.md
        test-log.md
        diff-summary.md
        permission-decisions.md
    decisions/
      ADR-001.md
```

`AGENTS.md` 是仓库级自动入口，用于让 Codex 在普通开发请求中默认读取 `.ai/control/supervisor.md`。

`.ai/` 目录用于保存长期稳定的协作规则和团队默认配置。

`specs/` 目录用于保存每个任务的运行产物。

`.ai/config.yaml` 默认包含 `artifact_language: en`。`.ai/local.yaml` 默认包含注释掉的本地偏好示例，并由 `.gitignore` 忽略。如果用户希望后续任务产物正文使用中文，可以取消注释并改为 `artifact_language: zh`。该配置只影响自然语言正文，不改变 artifact 路径、结构化字段、状态枚举或门禁 ID。

Agent 之间不依赖聊天记录交接，而是通过 `specs/{task_id}/` 下的结构化产物交接。

`specs/{task_id}/runs/` 用于保存每次 Harness 执行记录。

它记录一次 Agent 运行时用了什么上下文、允许了什么工具、执行了什么命令、产生了什么 diff、测试结果是什么、是否触发过权限审批。

### 13.5 Skill 的使用方式

推荐 Skill 支持三类使用方式，但系统层级 Skill 的隐式触发只负责框架初始化或安装；更新、同步、修复、检查、诊断等维护动作必须显式点名 Skill。日常使用不应要求用户每次显式输入 Skill 名称，而应由已初始化仓库中的 `AGENTS.md` 自动路由。

初始化或安装不要求用户点名 Skill，只要意图是设置仓库级 AI 交付规则即可。更新、同步、修复、检查、诊断等维护动作必须显式点名 Skill。初始化完成后的普通任务不再点名 Skill。这样系统层 Skill 不会因为普通产品开发请求而误触发。

初始化、同步、修复或诊断本框架时，Skill 本身必须默认限制写入范围：只允许写入根目录 `AGENTS.md`、`.gitignore` 中的 `.ai/local.yaml` 忽略项、`.ai/**`，以及必要时的 `specs/.gitkeep`。除非用户在同一轮明确要求执行具体交付任务，否则不得修改产品代码、测试、迁移、构建脚本、部署文件、应用配置，也不得创建 `specs/{task_id}/` 任务目录。

#### 初始化项目

用于第一次在仓库中引入 AI-Native 软件交付协作框架。

输入：

```text
project_type:
team_size:
tech_stack:
preferred_workflows:
risk_level:
```

输出：

```text
AGENTS.md
.ai/
specs/
```

其中 `AGENTS.md` 必须作为自动入口：普通 feature、bugfix、refactor、review、research 或 incident 请求，应自动进入 `.ai/control/supervisor.md`，再由 Supervisor 判定 `selected_workflow`。

如果仓库已有 `AGENTS.md`，初始化过程应保留原有项目指令，只追加或合并 AI delivery workflow 入口。

#### 创建任务工作区

用于为一个具体需求、缺陷或重构任务创建 spec 工作区。初始化完成后，这一步应由仓库级 `AGENTS.md` 和 `.ai/control/supervisor.md` 自动触发，而不是要求用户手动指定 Skill。

输入：

```text
task_id:
workflow_hint:
selected_workflow:
selection_reason:
user_goal:
constraints:
```

输出：

```text
specs/{task_id}/00-brief.md
specs/{task_id}/01-requirements.md
specs/{task_id}/03-tasks.md
```

#### 执行工作流

用于根据任务类型启动对应的 Agent 协作流程。

典型流程：

```text
Human
  ↓
Supervisor routes selected_workflow and reads .ai/workflows/{selected_workflow}.md
  ↓
Supervisor creates context pack
  ↓
Supervisor creates harness run context
  ↓
Harness invokes role Agent by Blueprint
  ↓
Agent writes required artifact
  ↓
Harness writes execution report
  ↓
Supervisor checks gate
  ↓
Next stage or human escalation
```

Supervisor 发起一次 Agent 执行时，只传递参数，不转述、不简化、不重写对方 Blueprint。

实际执行由 Harness 根据 run context 装载 Blueprint、注入 Context Pack、绑定工具并记录 execution report。

标准调用形式：

```text
Please read `.ai/agents/developer.md` and execute strictly according to that Blueprint.

Parameters:
- task_id:
- spec_path:
- workflow_hint:
- selected_workflow:
- selection_reason:
- target_files:
- constraints:
- run_context_path:
```

### 13.6 Skill 的版本化

团队 Skill 应该像代码一样版本化。

建议版本化内容包括：

- Agent Blueprint
- workflow 定义
- spec 模板
- harness policy
- run context 模板
- execution report 模板
- task class 规则
- human gate 规则
- quality gate 规则
- permission policy
- context policy
- escalation policy

每次框架规则调整，都应该能回答：

- 哪个规则变了？
- 为什么变？
- 影响哪些工作流？
- 是否需要更新历史任务模板？
- 是否需要增加新的质量回归样例？

### 13.7 从 Skill 到平台

Skill 是主要交付形态，但不是最终平台形态的全部。

推荐演进路径：

```text
README 方案
  ↓
Team Skill
  ↓
Repo-local .ai/ + specs
  ↓
Repo-local Harness
  ↓
Workflow Automation
  ↓
Agent Orchestration Platform
  ↓
Enterprise Control Plane
```

在平台化之前，先通过 Skill 固化协作规范，可以避免过早工程化。

当多个团队、多个仓库、多个 Agent 工作流都稳定后，再把高频、稳定、可度量的部分下沉到编排平台中。

平台化准入条件：

- 目标版 Skill 已在一批真实任务中跑通，覆盖 feature-dev、bugfix、code-review、refactor 和 incident-fix 中的主要路径。
- 任务分级、Human Gate、Quality Gate 和 Harness execution report 的规则变化已经趋稳。
- 关键指标可以记录，包括 cycle time、test evidence completeness、fix loop count、defect escape、human intervention frequency、workflow friction。
- 高风险权限、密钥、数据库、CI、发布等操作已有明确审批和审计规则。
- 团队确认 repo-local Skill 的流程收益大于流程负担。
- 平台能力来自稳定重复的流程需求，而不是为了提前工程化而工程化。

## 14. 目标版 Skill 方案

### 14.1 目标

本方案直接面向目标版 Skill 设计，不再把 Skill 拆成单独的试验版和最终版。

目标版 Skill 不等于完整平台。它仍然是 repo-local 的团队协作能力，但应完整表达本框架的核心职责分离：

- Agent 是否能通过 spec 协作
- Architect 是否能约束关键设计决策
- Developer、Tester、Reviewer 是否能形成有效质量闭环
- Harness 是否能稳定约束上下文、工具、权限和证据采集
- Human Gate 是否能控制风险
- 质量门禁是否能减少错误交付

### 14.2 目标版 Agent

目标版 Skill 默认包含 5 个核心 Worker Agent：

```text
Planner
Architect
Developer
Tester
Reviewer
```

Supervisor 不是 Worker Agent，而是 Skill 内部的流程控制逻辑。

Harness 也不是 Agent，不参与需求、设计、实现或 Review 判断。

目标版 Skill 中 Harness 是执行边界：

```text
Context Pack + Run Context + Tool Policy + Execution Report
```

Researcher 是可选 Agent，只在 `research-spike` 或技术选型场景启用。

### 14.3 目标版工作流

目标版 Skill 应支持以下工作流：

```text
feature-dev
bugfix
code-review
refactor
research-spike
release
incident-fix
```

### 14.4 目标版文档产物

目标版 Skill 应沉淀以下业务产物：

```text
requirements.md
design.md
tasks.md
implementation.md
test_plan.md
test_report.md
review_report.md
acceptance.md
decisions/ADR-001.md
```

同时每次 Agent 执行必须沉淀 Harness 执行产物：

```text
runs/{run_id}/run-context.md
runs/{run_id}/execution-report.md
runs/{run_id}/tool-log.md
runs/{run_id}/test-log.md
runs/{run_id}/diff-summary.md
runs/{run_id}/permission-decisions.md
```

### 14.5 质量闭环

目标版 Skill 的质量闭环为：

```text
Developer → Tester → Reviewer → Fix → Tester → Reviewer
```

最多 3 次，失败后升级给人。

每一轮 Developer、Tester 或 Reviewer 执行都必须形成一份 Harness execution report。

### 14.6 Harness

目标版 Skill 中的 Harness 不需要做成独立平台，但必须定义 repo-local 运行契约。

必需能力：

- 为每次 Agent 执行生成 `run_id`
- 记录 `blueprint_path` 和 `context_pack_path`
- 限制可读写路径
- 定义允许和禁止的工具
- 对高风险工具调用触发人工审批
- 记录命令、日志、diff、测试结果
- 输出 `execution_report.md`

Harness 产物：

```text
specs/{task_id}/runs/{run_id}/
  run-context.md
  execution-report.md
  tool-log.md
  test-log.md
  diff-summary.md
  permission-decisions.md
```

质量门禁不应只读取 Agent 自述，还必须读取 Harness execution report 和对应 evidence 文件。缺少 evidence 时，状态应进入 `blocked` 或 Human Gate，而不是进入 acceptance。

## 15. 企业级演进路线图

### Level 1: Repo-local

目标：

- 在单个代码仓库内落地 AI 协作规范。

能力：

- spec
- ADR
- agent prompt
- repo-local Harness policy
- execution report
- CI 脚本
- review checklist

### Level 2: Team Workflow

目标：

- 在团队级别统一 Agent 工作流。

能力：

- LangGraph / Microsoft Agent Framework 编排
- 统一任务状态
- 统一 Agent 调用
- 自动测试
- 自动 Review

### Level 3: Platform

目标：

- 建立 AI 研发协作平台。

能力：

- RBAC
- SSO
- 审计日志
- 成本统计
- Agent 版本管理
- Prompt 版本管理
- Workflow 版本管理

### Level 4: Enterprise Control Plane

目标：

- 与企业研发体系深度集成。

能力：

- MCP / A2A
- 企业知识库
- 项目管理系统
- 代码平台
- 发布系统
- 合规策略
- 安全策略

### Level 5: Continuous Improvement

目标：

- 让 Agent 工作流基于真实失败案例持续改进。

能力：

- 失败案例库
- 回归评测集
- agent performance metrics
- prompt / workflow A/B testing
- 自动化质量分析

## 16. Skill 编制前置规格

第 16 节不再作为开放讨论清单处理。

在正式编制目标版 Skill 之前，以下内容已经先沉淀为英文前置规格：

```text
docs/skill-authoring-prespec.md
```

该文档用于稳定 Skill 编制前必须明确的执行契约，包括：

1. `Supervisor` state machine
2. Task class rules
3. Context Pack contract
4. Harness Run Context contract
5. Agent Blueprint contracts
6. Spec template contracts
7. Quality Gate and Human Gate contracts
8. Target Skill package shape
9. Repo-local `.ai/` and `specs/` output structure

第一版 Skill 已根据该前置规格创建：

```text
skills/dev-cadence/
```

该 Skill 当前包含 `SKILL.md`、`agents/openai.yaml` 和按主题拆分的 `references/` 文件，可作为后续真实任务验证和迭代的起点。

仍然后置的主题包括：

1. Workflow DSL 设计
2. 与 Codex CLI / Claude Code / OpenHands 的深度适配
3. 基于 LangGraph 或 Microsoft Agent Framework 的最小原型
4. 企业级 RBAC、SSO、审计和成本控制
5. 自动 issue / PR 调度
6. 自动发布执行

这些主题不应阻塞第一版 repo-local Skill。它们应在 Skill 规则经过真实任务验证后再进入平台化设计。

## 17. 一句话总结

本框架不应模拟 AI 会议室，而应模拟有流程、有工单、有产物、有门禁、有负责人、有升级机制的软件研发组织。
