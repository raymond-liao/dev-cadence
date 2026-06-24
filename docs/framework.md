# Dev Cadence 框架方案

本文是 Dev Cadence 的完整框架方案。项目入口、安装和验证说明见仓库根目录 `README.md`。

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

目标版 Plugin 应支持完整角色体系，但不要求每个任务都走同样重量的流程。

任务应先由 Supervisor 分类，再决定需要哪些 Agent、产物和 Human Gate。

| Class | 适用场景 | 必需 Agent | 必需产物 | Human Gate |
|---|---|---|---|---|
| `S0 trivial` | 文案、注释、低风险配置、可快速回滚的小修 | Developer，Reviewer 按需 | brief、implementation、test evidence 或 not verified reason、acceptance | final acceptance |
| `S1 normal` | 普通 feature、bugfix、code-review、局部重构 | Planner、Developer、Tester、Reviewer | requirements、tasks、implementation、test_report、review_report、acceptance | requirement acceptance、final acceptance |
| `S2 high-risk` | 架构、安全、权限、CI、数据迁移、跨模块变更 | Planner、Architect、Developer、Tester、Reviewer | requirements、design/ADR、tasks、implementation、test_report、review_report、acceptance | 实现前 requirement / architecture / risk approval，必要时 permission approval，最终 human acceptance |
| `research-spike` | 技术选型、未知风险探索、方案比较 | Researcher、Architect 按需 | research_report、options comparison、recommendation、open questions | decision review |
| `incident` | 紧急生产修复或高压故障恢复 | Supervisor、Developer、Tester/Reviewer 按需 | triage、minimal patch、smoke test、emergency approval、post-incident backfill | emergency approval、post-incident acceptance |

这不是把目标版 Plugin 拆成简化版，而是让同一个目标版 Plugin 根据风险自动调整流程强度。

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
.dev-cadence.yaml

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

这是目标版 thin repo-local contract。通用工作流、Agent blueprint、gate、Harness、默认配置和模板由 `dev-cadence` 持有；业务仓库只保存入口、本地覆盖配置和任务证据。

`.dev-cadence.yaml` 保存被 Git 忽略的用户本地偏好，初始化时默认生成注释示例：

```yaml
# Local Dev Cadence preferences.
# Uncomment and change this value to override generated artifact prose language for your local work.
# Supported values:
# - en: English
# - zh: Chinese, Simplified Chinese by default
# dev_cadence:
#   artifact_language: en
#   specs_dir: specs
#   implementation_discipline: default
#   verification_discipline: default
#   review_profile: normal
```

`artifact_language` 支持 `en` 和 `zh`。它只控制 spec、测试报告、review 报告等任务产物中的自然语言正文；文件名、YAML 字段、状态枚举、workflow ID 和 gate ID 仍保持英文。如果用户取消注释 `.dev-cadence.yaml` 中的 `dev_cadence.artifact_language`，它优先于插件默认值。初始化或更新时应把 `.dev-cadence.yaml` 加入 `.gitignore`。

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

## 13. 交付形态：Core 与 Codex Plugin

本框架的最终产出不应只是一个说明文档，也不应一开始就做成完整平台。

Dev Cadence 本身应被理解为一套平台无关的 AI-native 软件交付协议和协作框架，而不是某一个 Codex Plugin。

推荐分成两层：

```text
Dev Cadence Core
  -> 平台无关的工作流、角色、门禁、Harness、artifact 和 adapter 契约

dev-cadence
  -> Dev Cadence 的稳定 slug、包名和插件名；当前优先以 Codex Plugin 形态发布
```

也就是说，`dev-cadence` 是跨运行时保持一致的名字；Codex Plugin 只是当前阶段优先支持的发布形态。后续可以继续出现同名的 Claude Code plugin、OpenCode plugin、CI runner、LangGraph runtime、Microsoft Agent Framework runtime 或企业平台实现。

当前建议将第一版可共享实现设计为：

```text
dev-cadence
  + Codex Plugin manifest
  + 少量 user-facing skills
  + 发布包内 references/templates/adapters
  + thin repo-local contract
```

`dev-cadence` 当前 Codex 发布形态的作用是把 Dev Cadence Core 中的 Agent 角色、工作流、上下文规则、质量门禁、Harness 契约和 artifact 模板，沉淀为团队成员可以在 Codex 中跨代码仓库复用的 AI 协作规范。

关键设计是：

```text
Dev Cadence Core
  -> 定义稳定协议和治理边界

dev-cadence
  -> 在 Codex 发布形态中持有通用规则、模板、adapter 和 helper scripts
  -> 目标仓库只保留薄入口、本地覆盖配置和任务证据
```

`specs/{task_id}/` 仍然是任务事实、执行证据和验收记录的 durable source of truth。变化的是：通用框架规则不再默认复制到每个业务仓库。

### 13.1 为什么首个实现选择 Codex Plugin

Codex Plugin 适合作为首个实现形态的原因：

- 它可以被 Codex 用户直接安装和共享。
- 它可以包含多个 Skill、references、templates、scripts 和 adapter。
- 它可以把通用流程规则放在一个可升级的位置，而不是复制进每个仓库。
- 它可以让不同项目只保存本项目特有配置和证据。
- 它可以内置默认交付纪律，同时保留未来替换 Worker 执行纪律的 adapter 扩展点。
- 它不绑定某个具体业务系统或技术栈。
- 它允许框架先以轻量方式落地，再逐步演进为平台。

也就是说，`dev-cadence` 当前优先以 Codex Plugin 形态从“理念”进入“团队日常使用”；平台化和其他 agent runtime 的实现应在真实任务验证后再推进，并继续沿用 `dev-cadence` 这个稳定名字。

### 13.2 Skill 拆分原则

不要把每个内部流程状态都拆成 Codex Skill。

不推荐：

```text
dev-cadence-requirements-gate
dev-cadence-planning
dev-cadence-harness-run
dev-cadence-test-verification
dev-cadence-review
dev-cadence-human-gate
```

这些是 Supervisor 状态和框架模块，不是用户直接请求的能力。拆太细会导致触发噪声、上下文碎片、版本兼容负担和 gate 语义分散。

推荐原则：

```text
Skill 按用户意图拆。
Reference 按流程环节拆。
Template 按产物类型拆。
Adapter 按可替换执行纪律拆。
```

### 13.3 推荐 Skill 集合

Codex Plugin 发布形态采用一个入口 Skill 加一组短前缀工作纪律 Skills。

```text
using-dev-cadence
  Dev Cadence 入口 Skill 和任务路由，负责选择 workflow、task class、gates 和具体 discipline。

cadence-clarify
  澄清目标、范围、非目标、设计、验收和验证方式。

cadence-plan
  把已确认设计拆成可执行任务和测试计划。

cadence-execute
  通过 Harness evidence 执行已批准计划。

cadence-tdd
  对可测试行为变更执行 Red-Green-Refactor。

cadence-debug
  处理 bug、incident、失败测试、回归和未知根因。

cadence-review
  检查 spec compliance 和 code quality。

cadence-verify
  完成前验证测试、范围、风险和 Human acceptance。

cadence-sync
  初始化、检查、同步、修复或诊断 thin repo-local contract。
```

`using-dev-cadence` 是唯一代表 Dev Cadence 整体的 Skill。`Supervisor`、`Harness`、`Quality Gate`、`Human Gate`、artifact schema 和 task class policy 不作为用户 Skill 发布，它们保留为共享 references，由 bootstrap 和各个 `cadence-*` Skill 引用。

`authoring` 不作为普通用户发布 Skill。维护 Dev Cadence 自身的规则保留在源码仓库的文档、references 和测试流程中。

### 13.4 `dev-cadence` 当前 Codex 发布结构

推荐 `dev-cadence` 当前 Codex Plugin 发布形态采用以下结构：

```text
dev-cadence/
  .codex-plugin/
    plugin.json
  skills/
    using-dev-cadence/
      SKILL.md
      agents/openai.yaml
    cadence-clarify/
      SKILL.md
      agents/openai.yaml
    cadence-plan/
      SKILL.md
      agents/openai.yaml
    cadence-execute/
      SKILL.md
      agents/openai.yaml
    cadence-tdd/
      SKILL.md
      agents/openai.yaml
    cadence-debug/
      SKILL.md
      agents/openai.yaml
    cadence-review/
      SKILL.md
      agents/openai.yaml
    cadence-verify/
      SKILL.md
      agents/openai.yaml
    cadence-sync/
      SKILL.md
      agents/openai.yaml
  references/
    principles.md
    supervisor-state-machine.md
    task-classes.md
    agent-blueprints.md
    workflows.md
    delivery-disciplines.md
    intent-and-design-discipline.md
    visual-companion.md
    planning-discipline.md
    implementation-discipline.md
    testing-anti-patterns.md
    execution-orchestration.md
    debugging-discipline.md
    root-cause-tracing.md
    condition-based-waiting.md
    defense-in-depth.md
    review-discipline.md
    verification-discipline.md
    authoring-discipline.md
    skill-pressure-testing.md
    context-pack.md
    harness.md
    quality-gates.md
    human-gates.md
    adapters.md
    skill-layout.md
  templates/
    spec/
    runs/
    prompts/
  scripts/
    package-codex-plugin.mjs
    check-skill-package.mjs
    check-discipline-routes.mjs
    check-spec-artifacts.mjs
    init-task-artifacts.mjs
    sync-repo-contract.mjs
    run-delivery-dry-run.mjs
    summarize-acceptance.mjs
    visual-companion/
```

其中：

- `using-dev-cadence` 通过 Codex 原生 Skill 触发或用户显式要求使用 Dev Cadence 进入流程，让 Agent 在交付任务前检查 workflow、state、gate 和具体 discipline。
- `cadence-*` Skills 是工作动作和纪律入口，不是产品菜单。
- `references/` 承载 Supervisor、Harness、gates、workflow、task class 和 discipline 细节。
- `templates/spec/` 保存任务 artifacts 模板，`templates/runs/` 保存 Harness evidence 模板，`templates/prompts/` 保存 Worker/reviewer prompt 模板。
- `scripts/` 提供 package self-check、artifact 初始化、repo contract 同步、dry run、acceptance summary 和 optional visual companion 工具。
### 13.5 本地 Codex 发布包安装

本地开发时不要把源码仓库根目录直接作为 Codex plugin 安装源。应先生成发布包，再让本机 Codex marketplace source 指向发布目录：

```bash
node scripts/package-codex-plugin.mjs --clean
```

默认输出一个完整的本地 marketplace root：

```text
dist/codex/
  .agents/
    plugins/
      marketplace.json
  plugins/
    dev-cadence/
```

其中 `dist/codex/` 是 Codex marketplace root，Codex CLI 读取其中的 `.agents/plugins/marketplace.json`；`dist/codex/plugins/dev-cadence/` 是实际 plugin payload，只包含 Codex 运行需要的内容：

```text
.codex-plugin/
skills/
references/
templates/
scripts/
```

不包含源码仓库的 `README.md`、`AGENTS.md`、`docs/`、`research/`、`specs/`、`tests/`、`.git/` 等开发和历史材料。

源码仓库本身也不长期追踪运行过程目录。`specs/` 是 Dev Cadence 在目标仓库或本地 dry run 中生成的任务 artifact；`research/` 是临时探索工作区。稳定模板保留在 `templates/`，稳定设计依据和验证结论保留在 `docs/`，例如 `docs/research-findings.md` 和 `docs/validation-notes.md`。

这里的 `marketplace` 是 Codex CLI 的插件来源目录，不是公开市场发布。`codex plugin marketplace add ./dist/codex` 只会把该目录注册到本机 Codex 配置中，不会上传插件。本地相对路径必须带 `./`；否则 Codex CLI 可能会把 `dist/codex` 解析成 GitHub 仓库名。

本地安装时，让 Codex 指向生成后的 marketplace root：

```bash
codex plugin marketplace add ./dist/codex
codex plugin add dev-cadence@dev-cadence-local
```

更新发布包后，重新执行：

```bash
node scripts/package-codex-plugin.mjs --clean
codex plugin add dev-cadence@dev-cadence-local
```

安装或更新后新开 Codex thread，以便 Codex 重新加载 skills。

### 13.6 目标仓库薄契约

当团队在某个代码仓库中启用 Dev Cadence 时，默认只生成薄契约：

```text
AGENTS.md
.gitignore
.dev-cadence.yaml

specs/
  .gitkeep
```

`AGENTS.md` 是仓库级自动入口，用于让 Codex 在普通交付请求中默认使用 `dev-cadence`，而不是复制完整框架。

`.dev-cadence.yaml` 保存用户本地偏好，由 `.gitignore` 忽略。默认规则和默认配置由 `dev-cadence` 持有，不在目标仓库生成 `.ai/` 目录。

如果使用持久化 visual companion session，目标仓库还应忽略：

```text
.dev-cadence/visual-companion/
```

`specs/` 目录用于保存每个任务的运行产物：

```text
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

Agent 之间不依赖聊天记录交接，而是通过 `specs/{task_id}/` 下的结构化产物交接。`specs/{task_id}/runs/` 记录每次 Harness 执行用了什么上下文、允许了什么工具、执行了什么命令、产生了什么 diff、测试结果是什么、是否触发过权限审批。

### 13.7 Runtime Authority

运行时规则优先级应分层：

1. 当前用户请求和显式仓库指令。
2. 仓库本地 `AGENTS.md` 和 `.dev-cadence.yaml`。
3. 当前任务 artifacts：`specs/{task_id}/**`。
4. `dev-cadence` 的 references、templates、内置交付纪律和 adapter。
5. 被显式配置的外部 adapter。

Codex Plugin 提供默认流程规则。Repo-local overlays 可以增加更严格或更项目化的约束，但不能削弱 Dev Cadence Core 定义的 named Human acceptance、证据要求、权限门禁、Requirements Readiness Check 或 Harness evidence。

### 13.8 内置交付纪律与 Adapter 模型

Dev Cadence 默认内置一套严格交付纪律。Adapter 是未来替换某个 Worker 执行技术的扩展点，不是默认纪律的来源。

默认配置由插件持有；`.dev-cadence.yaml` 只保存本地覆盖：

```yaml
dev_cadence:
  artifact_language: en
  specs_dir: specs
  implementation_discipline: default
  verification_discipline: default
  review_profile: normal
```

`default` 表示 Dev Cadence 自己的内置规则：

- 实现前澄清意图、范围、非目标和验收标准。
- Planning 必须拆成可执行小任务，包含具体文件、行为、验证命令和预期结果。
- Testable behavior changes 默认执行严格 Red-Green-Refactor。
- Bugfix 和 incident 先复现或刻画问题，再修复。
- Review 先检查 spec compliance，再检查 code quality。
- Completion claim 之前必须有验证证据。
- 只有在多个问题域彼此独立时才并行调度 Worker。
- 维护 Dev Cadence 自身 Skill 或 references 时，使用面向 Skill 行为的验证纪律。

内置规则不是对外部 Skill package 的引用，而是 Dev Cadence 自己持有的 `cadence-*` Skills、references、artifact templates、prompt templates 和 optional scripts。当前默认 discipline 的加载入口是 `using-dev-cadence` 和 `delivery-disciplines.md`：前者负责 bootstrap 和任务路由，后者按状态加载 `intent-and-design-discipline.md`、`visual-companion.md`、`planning-discipline.md`、`implementation-discipline.md`、`debugging-discipline.md`、`review-discipline.md`、`verification-discipline.md` 等细分规则。Dev Cadence source 自身通过 `scripts/check-skill-package.mjs`、`scripts/check-discipline-routes.mjs` 和 `scripts/check-spec-artifacts.mjs` 做轻量本地校验，避免发布内容语言边界、路由引用、artifact template 或 prompt template 在后续演进中漂移。

日常实现阶段的默认路径是：

```text
using-dev-cadence
  ↓
cadence-execute / cadence-tdd
  ↓
Supervisor 确认 G1/G2/G3 已满足
  ↓
Harness 创建 Developer run context
  ↓
Developer 阶段执行 Red-Green-Refactor
  ↓
记录 failing-test evidence、implementation diff、passing-test evidence、refactor evidence
  ↓
回到 Dev Cadence 的 test/review/acceptance gates
```

也就是说：

```text
Dev Cadence 管“什么时候做什么、证据放哪里、谁能批准”。
内置交付纪律管“默认应该怎么做”。
Adapter 只在显式配置时替换某个 Worker 阶段的执行技术。
```

Adapter 不能覆盖最终 Human Gate、Quality Gate、Harness evidence、权限审批、Requirements Readiness Check 和 scope reconciliation。

### 13.9 从 Codex Plugin 到其他运行时和平台

`dev-cadence` 当前优先支持 Codex Plugin 发布形态，但这不是最终平台形态的全部，也不是 Dev Cadence Core 的唯一运行时形态。

推荐演进路径：

```text
README 方案
  ↓
Dev Cadence Core
  ↓
dev-cadence Codex Plugin publishing target
  ↓
Thin repo-local contract + specs
  ↓
Protocol Harness
  ↓
Workflow Automation
  ↓
Agent Orchestration Platform
  ↓
Enterprise Control Plane
```

在平台化或支持更多 agent runtime 之前，先通过 `dev-cadence` 的 Codex 发布形态固化协作规范，可以避免过早工程化。

平台化准入条件：

- `dev-cadence` 已以 Codex Plugin 形态在一批真实任务中跑通，覆盖 feature-dev、bugfix、code-review、refactor 和 incident-fix 中的主要路径。
- 任务分级、Human Gate、Quality Gate 和 Harness execution report 的规则变化已经趋稳。
- 默认交付纪律已经在真实任务中稳定运行，且 adapter 模型不会破坏治理边界。
- 关键指标可以记录，包括 cycle time、test evidence completeness、fix loop count、defect escape、human intervention frequency、workflow friction。
- 高风险权限、密钥、数据库、CI、发布等操作已有明确审批和审计规则。
- 团队确认流程收益大于流程负担。
- 平台能力来自稳定重复的流程需求，而不是为了提前工程化而工程化。

## 14. 目标版 Codex Plugin 方案

### 14.1 目标

目标版 Codex Plugin 不等于 Dev Cadence Core，也不等于完整平台。它应在 Codex 中完整表达本框架的核心职责分离：

- Supervisor 是否能控制状态、分级、workflow、gate 和升级。
- Harness 是否能约束上下文、工具、权限和证据采集。
- Worker Agents 是否能通过 artifacts 协作。
- Developer、Tester、Reviewer 是否能形成有效质量闭环。
- Human Gate 是否能控制需求、风险、权限和最终验收。
- Quality Gate 是否能减少错误交付。
- Adapter 是否能替换 Worker 执行纪律而不破坏治理边界。

### 14.2 目标版角色

目标版 Plugin 默认支持 5 个核心 Worker Agent：

```text
Planner
Architect
Developer
Tester
Reviewer
```

Supervisor 不是 Worker Agent，而是 Dev Cadence bootstrap 和 shared references 中定义的流程控制逻辑。

Harness 也不是 Agent，不参与需求、设计、实现或 Review 判断。它是执行边界：

```text
Context Pack + Run Context + Tool Policy + Permission Policy + Execution Evidence
```

Researcher 是可选 Agent，只在 `research-spike` 或技术选型场景启用。

### 14.3 目标版工作流

目标版 Plugin 应支持以下工作流：

```text
feature-dev
bugfix
code-review
refactor
research-spike
release
incident-fix
```

用户不需要选择工作流。Supervisor 根据请求推断 `selected_workflow`，记录 `selection_reason`，并保留用户表达的 `workflow_hint`。

### 14.4 目标版 artifact

目标版 Plugin 应沉淀以下任务产物：

```text
00-brief.md
01-requirements.md
02-design.md
03-tasks.md
04-test-plan.md
05-implementation.md
06-test-report.md
07-review-report.md
08-acceptance.md
decisions/ADR-001.md
```

同时每次 Worker 或 adapter 执行必须沉淀 Harness 执行产物：

```text
runs/{run_id}/run-context.md
runs/{run_id}/execution-report.md
runs/{run_id}/tool-log.md
runs/{run_id}/test-log.md
runs/{run_id}/diff-summary.md
runs/{run_id}/permission-decisions.md
```

这些 artifact 存在于目标仓库的 `specs/{task_id}/` 下，跟随代码版本演进。

### 14.5 质量闭环

目标版 Plugin 的质量闭环为：

```text
Developer -> Tester -> Reviewer -> Fix -> Tester -> Reviewer
```

最多 3 次，失败后升级给人。

每一轮 Developer、Tester、Reviewer 或外部 adapter 执行都必须形成一份 Harness execution report。缺少 evidence 时，状态应进入 `blocked` 或 Human Gate，而不是进入 acceptance。

### 14.6 Harness

目标版 Plugin 中的 Harness 可以先是协议化 Harness，不需要一开始做成独立运行时平台。

必需能力：

- 为每次 Worker 或 adapter 执行生成 `run_id`。
- 记录 Context Pack 和 Run Context。
- 限制可读写路径。
- 定义允许和禁止的工具。
- 对高风险工具调用触发人工审批。
- 记录命令、日志、diff、测试结果。
- 输出 execution report。

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

质量门禁不应只读取 Agent 自述，还必须读取 Harness execution report 和对应 evidence 文件。

### 14.7 实施切片

后续实现按目标架构直接推进：

1. 将 Plugin 化目标和 thin repo-local contract 固化到方案文档和 Skill references。
2. 实现 `using-dev-cadence` 入口 Skill，由它选择 workflow、task class、gates 和具体 `cadence-*` discipline。
3. 将 repo contract 初始化、inspect、sync、repair 和 diagnose 收敛到 `cadence-sync`。
4. 将日常交付拆到 `cadence-clarify`、`cadence-plan`、`cadence-execute`、`cadence-tdd`、`cadence-debug`、`cadence-review` 和 `cadence-verify`。
5. 增加并验证 `delivery-disciplines.md`、细分 discipline references、Worker/reviewer prompt templates 和 `adapters.md`，先跑通内置默认交付纪律，再决定是否接入外部 adapter。

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

## 16. Plugin 编制前置规格

第 16 节不再作为开放讨论清单处理。

在正式编制目标版 Plugin 之前，以下内容已经先沉淀为中文设计规格：

```text
docs/skill-authoring-prespec.md
docs/plugin-skill-modularization.md
```

这些文档用于稳定 Plugin 编制前必须明确的执行契约，包括：

1. `Supervisor` state machine
2. Task class rules
3. Context Pack contract
4. Harness Run Context contract
5. Agent Blueprint contracts
6. Spec template contracts
7. Quality Gate and Human Gate contracts
8. `dev-cadence` publishing package shape
9. Thin repo-local contract and `specs/` output structure

当前 `dev-cadence` Codex 发布源码已经采用 root-level plugin 结构：

```text
dev-cadence/
  .codex-plugin/plugin.json
  skills/
    using-dev-cadence/
    cadence-clarify/
    cadence-plan/
    cadence-execute/
    cadence-tdd/
    cadence-debug/
    cadence-review/
    cadence-verify/
    cadence-sync/
  references/
  templates/
  scripts/
```

该 `dev-cadence` Codex source 当前包含 Codex manifest、`using-dev-cadence` 入口 Skill、`cadence-*` 工作纪律 Skills、按主题拆分的 `references/` 文件、`templates/spec/` 下的任务 artifact templates、`templates/runs/` 下的 Harness evidence templates、`templates/prompts/` 下的 Worker/reviewer prompt templates，以及 `scripts/` 下的 source self-check、artifact 初始化、repo contract 同步和 visual companion 工具。

语言边界：

- 项目方案文档使用中文，包括 `README.md` 和 `docs/**`。
- 可发布 Plugin 内容使用英文，包括 `skills/**`、`references/**`、`templates/**` 和 `scripts/**`。
- 任务 artifact 的自然语言正文由 `artifact_language` 决定；文件名、YAML 字段、状态枚举、workflow ID 和 gate ID 保持英文。

仍然后置的主题包括：

1. Workflow DSL 设计
2. 与 Codex CLI / Claude Code / OpenHands 的深度适配
3. 基于 LangGraph 或 Microsoft Agent Framework 的最小原型
4. 企业级 RBAC、SSO、审计和成本控制
5. 自动 issue / PR 调度
6. 自动发布执行

这些主题不应阻塞第一版 Plugin 化实践。它们应在 Dev Cadence 规则、thin repo-local contract 和 adapter 模型经过真实任务验证后再进入平台化设计。

## 17. 一句话总结

本框架不应模拟 AI 会议室，而应模拟有流程、有工单、有产物、有门禁、有负责人、有升级机制的软件研发组织。
