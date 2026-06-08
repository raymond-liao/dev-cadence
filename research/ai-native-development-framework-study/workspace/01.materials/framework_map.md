# Framework Map

## Source

- `SRC-PROPOSAL-README`: repository root `README.md`

## Core Thesis

当前方案的核心论点是：AI Native 软件研发不应把 AI 当作单个代码生成器，而应组织为 `Human + Multi-Agent Team` 的研发协作模式。

方案推荐的核心形态是：

```text
Supervisor-Controlled
Artifact-First
Spec-Driven
Quality-Gated
Multi-Agent Development Framework
```

该论点来自 `SRC-PROPOSAL-README`。

## Goals and Non-Goals

### Goals

- 建立 AI 如何组织、协作、决策和形成开发闭环的框架。
- 明确 Agent 分工、工作流、上下文、知识和质量门禁。
- 让 AI 通过规范文档、任务单、代码变更、测试报告和 Review 报告协作。
- 让人控制需求、架构、权限、合并和发布等高风险边界。
- 最终产出一个团队可共享的 `AI Native Development Framework Skill`。

### Non-Goals

- 不设计具体业务系统。
- 不绑定 Spring Boot、DDD、数据库等特定工程细节。
- 不把第一阶段做成完整企业平台。
- 不让 Agent 自由聊天或互相辩论来替代结构化产物。

## Architecture Map

方案分为六层：

| 层 | 内容 |
|---|---|
| Interaction Layer | Human、issue、PR、chat、项目管理系统 |
| Control Layer | Supervisor / Orchestrator |
| Agent Layer | Planner、Architect、Developer、Tester、Reviewer |
| Context Layer | Specs、ADR、知识库、代码索引、memory |
| Execution Layer | Git、CI、test runner、coding agent、shell、MCP tools |
| Governance Layer | permissions、audit、cost、approval、security policy |

核心控制逻辑：

- Supervisor 负责识别任务、选择工作流、调度 Agent、控制上下文、执行门禁和升级给人。
- Supervisor 不写代码、不替代架构决策、不绕过 Reviewer 或测试。
- Worker Agent 通过产物交接，而不是自由对话。

## Agent Role Map

| Agent | 主要职责 | 主要产物 | 禁止事项 |
|---|---|---|---|
| Planner | 理解需求、澄清目标、拆分任务、定义验收标准 | `requirements.md`、`tasks.md` | 写代码、技术实现、代码 Review |
| Architect | 技术方案、架构约束、ADR、风险识别 | `design.md`、ADR | 编码、替代 Developer、替代 Reviewer |
| Developer | 代码实现、必要测试、缺陷修复、实现说明 | code diff、implementation notes、test result | 自行改需求、自行改架构、自行宣布完成 |
| Tester | 测试设计、测试执行、缺陷反馈、回归验证 | `test_plan.md`、`test_report.md`、defect list | 修代码、做架构审查 |
| Reviewer | Code Review、架构一致性、安全质量、门禁判断 | `review_report.md`、blocking issues、approval/rejection | 大规模重写、替代 Tester |

关键边界：Developer 只能交付代码变更和验证证据，不能自行宣布完成。

## Workflow and Artifact Map

标准工作流：

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

主要工作流类型：

- `feature-dev`
- `bugfix`
- `refactor`
- `code-review`
- `research-spike`
- `release`
- `incident-fix`

每个工作流需要定义：

- 触发条件
- 必需 Agent
- 可选 Agent
- 必需产物
- 质量门禁
- 人工审批点
- 最大循环次数

## Context and Memory Map

方案定义四层上下文：

| 层 | 内容 |
|---|---|
| Source of Truth | Git repo、specs、ADR、tests、PR、issues |
| Run State | 当前任务状态、阶段、负责人、预算、阻塞项 |
| Retrieval Context | 代码索引、项目文档、历史 ADR、知识库 |
| Ephemeral Context | 当前 Agent 本轮需要的最小上下文包 |

Context Pack 标准字段：

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

长期记忆只接受已产物化并确认的内容，例如 requirements、design、ADR、review conclusion、test result、acceptance decision。

## Quality Gate Map

最小质量门禁：

1. requirements accepted
2. design accepted
3. task has acceptance criteria
4. tests pass
5. reviewer has no blocker / major issue
6. human approves merge

Developer 必须提交：

- changed files
- rationale
- test commands
- test result
- known limitations

Reviewer 结论只能是：

- `approved`
- `approved_with_minor_notes`
- `changes_requested`
- `blocked`

所有 `changes_requested` 或 `blocked` 都必须给出证据和修改要求。

## Human Control Map

必须由人控制的边界：

- 需求确认
- 架构确认
- 权限批准
- Merge
- Release
- Loop 超限

人机协作原则：

- AI 准备材料，人做关键决策。
- AI 可以建议，不能越权批准。
- 人的决策必须写入 spec、ADR 或 acceptance 产物。
- 口头确认不能只停留在聊天记录。

## Skill Delivery Map

当前方案已经把最终可共享产物定义为：

```text
AI Native Development Framework Skill
```

Skill 职责：

- 初始化项目内 AI 协作目录结构。
- 生成 Agent Blueprint 模板。
- 生成 workflow 模板。
- 生成 spec / ADR / review / test report 模板。
- 指导 Supervisor 调度角色 Agent。
- 定义质量门禁、上下文包和人工确认点。

Skill 不负责：

- 替代项目管理系统。
- 直接实现企业级 Agent 编排平台。
- 替代 CI、代码平台或发布系统。
- 为某个技术栈生成固定工程结构。
- 绕过人的关键决策。

推荐 Skill 自身结构：

```text
ai-native-development-framework/
  SKILL.md
  references/
    principles.md
    agent-blueprints.md
    workflows.md
    quality-gates.md
    context-pack.md
    spec-templates.md
```

Skill 在目标代码仓库中生成：

```text
.ai/
  agents/
  workflows/
  policies/

specs/
  {task_id}/
```

## MVP Map

MVP 目标：

- 验证 Agent 是否能通过 spec 协作。
- 验证 Developer 和 Reviewer 是否能形成闭环。
- 验证 Human Gate 是否能控制风险。
- 验证质量门禁是否减少错误交付。

MVP Agent：

```text
Supervisor
Planner
Developer
Reviewer-Tester
```

MVP 工作流：

```text
feature-dev
bugfix
code-review
```

MVP 文档产物：

```text
requirements.md
design.md
tasks.md
implementation.md
test_report.md
review_report.md
```

MVP 闭环：

```text
Developer → Test/Review → Fix → Test/Review
```

最多 3 次，失败后升级给人。

## Enterprise Evolution Map

演进路线：

1. Repo-local：单仓库内落地 spec、ADR、agent prompt、CI、review checklist。
2. Team Workflow：统一任务状态、Agent 调用、自动测试和自动 Review。
3. Platform：RBAC、SSO、审计、成本、Agent 版本、Prompt 版本、Workflow 版本。
4. Enterprise Control Plane：MCP / A2A、企业知识库、项目管理、代码平台、发布、合规、安全。
5. Continuous Improvement：失败案例库、回归评测、Agent 指标、A/B testing、自动质量分析。

## Key Assumptions

### Confirmed Proposal Statements

- Agent 协作应通过结构化产物完成，而不是自由聊天。
- Supervisor 应控制流程和门禁，而不直接写代码。
- Tester 和 Reviewer 应独立于 Developer。
- 所有循环必须有最大次数和升级规则。
- Skill 是第一阶段比完整平台更轻量的交付形态。

### Implicit Assumptions

- 团队愿意把需求、设计、测试、Review 显式写入文件。
- AI Agent 能稳定遵守角色边界。
- 结构化产物增加的流程成本小于质量收益。
- 单仓库 `.ai/` + `specs/` 结构足以支撑第一阶段协作。
- 团队能持续维护 Skill、Blueprint、workflow 和 quality gate 的版本。
- 外部编码执行器能提供足够的命令执行、测试、文件编辑和审计能力。

## Open Questions

1. MVP 是否应该合并 Architect 到 Planner，还是保留单独架构角色？
2. Reviewer-Tester 合并是否会削弱质量独立性？
3. 对小任务是否需要完整 requirements/design/tasks 三件套？
4. Context Pack 应由人填写、Supervisor 自动生成，还是两者结合？
5. `.ai/` 规则和项目已有规则冲突时，哪个优先？
6. Skill 初始化时是否应读取现有项目结构、CI、测试命令和贡献规范？
7. 质量门禁是只描述规则，还是需要配套可执行脚本？
8. Agent 失败案例如何沉淀为回归评测？
9. 平台化之前，如何统计流程收益和成本？
10. Skill 的团队分发、版本升级和兼容策略如何设计？

## Initial Research Implications

- 当前方案已经具备较清晰的研发组织模型，但需要补强“如何验证有效”的评价体系。
- Skill 交付形态是合理的第一阶段，但需要更明确地区分 Skill、repo-local 规则和平台能力。
- MVP 应控制流程负担，避免把大型项目流程强加给小修小改。
- 风险重点不只是模型能力，而是权限、上下文漂移、质量门禁失效和人类审批弱化。
- 后续报告应给出 README 修订建议，而不是直接进入实现。

