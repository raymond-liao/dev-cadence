# AI-Native Software Delivery Framework 系统调研报告

## 0. 当前 README 核对结论（2026-06-08）

本报告保留了调研阶段的分析过程，其中多处使用了 “MVP Skill”“Reviewer-Tester” 等早期建议。

根据后续方案讨论，当前根目录 `README.md` 已经做出新的设计取舍：

- 框架名称调整为 `AI-Native Software Delivery Framework`。
- 核心目标调整为 `Human + Harness-Mediated Multi-Agent Team`。
- 不再单独设计一个简化版 Skill MVP，而是直接面向目标版 Skill。
- 目标版 Skill 默认保留 Planner、Architect、Developer、Tester、Reviewer 五个核心 Worker Agent，Researcher 作为可选 Agent。
- Tester 和 Reviewer 不再合并；二者作为独立职责进入目标版质量闭环。
- Harness 不作为 Agent，而作为 Supervisor 和执行器之间的运行边界。

因此，本报告中关于 “MVP Skill”“四角色三工作流”“Reviewer-Tester” 的内容，应理解为调研阶段对试运行成本和风险控制的历史建议，不再作为当前 README 的目标架构。

仍然被当前 README 采纳的关键研究结论包括：

- 引入 Harness run context 和 execution report。
- 使用可执行状态机而不是只写角色职责。
- 增加任务分级，避免低风险任务过度流程化、高风险任务门禁不足。
- 区分 Human Gate 类型：`approval_required`、`review_required`、`info_required`、`notify_only`。
- 将 `tests pass` 升级为可复现测试证据门禁，并增加验证状态。
- 增加 Source of Truth 优先级、`context_conflict` 和长期记忆更新规则。
- 为 `incident-fix` 定义快速路径和事后补偿路径。
- 平台化必须等待 repo-local Skill 规则在真实任务中稳定后再推进。

## 1. 执行摘要

本次调研基于当前根目录 `README.md` 方案，即 `SRC-PROPOSAL-README`，并结合多智能体编排、Human-in-the-loop、guardrails、tracing、AI coding agent 评测和产品化 coding agent 工作流等外部资料进行分析。

核心结论：

1. 当前方案的主判断成立：AI Native 研发协作应从“单 Agent 写代码”升级为 `Human + Harness-Mediated Multi-Agent Team`，并以产物、门禁和人类关键决策为核心。
2. 当前方案最强的设计是 `Supervisor-Controlled + Artifact-First + Spec-Driven + Quality-Gated`。补充 Harness 后，更准确的表达应是 `Supervisor-Controlled + Harness-Mediated + Artifact-First + Spec-Driven + Quality-Gated`。
3. 目标版 Skill 最大采用风险不是技术不可行，而是流程过重。需要引入任务分级，避免低风险小任务被完整流程拖慢，也避免高风险任务门禁不足。
4. 前一版分析漏掉了一个关键层：Execution Harness。Harness 应位于 Supervisor 和具体 coding executor / shell / CI / MCP 之间，负责上下文注入、沙箱、工具策略、权限审批、执行日志和证据采集。
5. 最终交付为团队 Skill 是合理的第一阶段，但 Skill 必须包含 repo-local Harness 规则和 execution report 模板；否则 Skill 只有角色和流程说明，无法稳定约束执行。
6. README 已重点补强：Harness 层、任务分级、workflow 状态机、Human Gate 分类、验证状态、Context Pack 冲突规则、Tester/Reviewer 职责边界和平台化准入条件。

建议把下一阶段目标定义为：

```text
先把 README 方案收敛成可执行的目标版 Skill 规范。
先用真实任务验证 repo-local Skill 规则，再平台化。
```

## 2. 当前方案画像

当前方案的核心命题是：

```text
Supervisor-Controlled
Harness-Mediated
Artifact-First
Spec-Driven
Quality-Gated
Multi-Agent Development Framework
```

这一命题来自 `SRC-PROPOSAL-README`，并在 `framework_map.md` 中被拆解为架构、角色、工作流、上下文、质量门禁、人类控制、Skill 交付和 MVP 路线。

方案的基本组织方式是：

```text
Human
  ↓
Supervisor / Orchestrator
  ↓
Spec & Plan Gate
  ↓
Planner / Architect
  ↓
Execution Harness
  ↓
Developer
  ↓
Tester / Reviewer
  ↓
Fix Loop
  ↓
Human Merge / Release
```

当前方案已经明确了几个正确边界：

- Supervisor 控流程，不写代码。
- Developer 交付代码和验证证据，不自行宣布完成。
- Tester / Reviewer 独立于 Developer。
- Chat 不是事实来源，spec、ADR、测试报告、Review 报告才是事实来源。
- 循环必须有上限，超限必须升级给人。
- 第一阶段交付为团队 Skill，而不是完整平台。

这些边界是后续 Skill 化和平台化的基础。

但当前画像还缺一个关键构件：Harness。

Harness 不是一个新角色 Agent，而是一次 Agent 执行的运行边界。它负责：

- 装载 Blueprint。
- 注入 Context Pack。
- 限制 workspace。
- 绑定工具。
- 执行权限策略。
- 记录工具调用和命令日志。
- 采集 diff、测试结果和 Review 证据。
- 输出 execution report。

没有 Harness，Supervisor 的调度会直接落到 coding agent、shell、CI 或 MCP，导致上下文、权限、日志和证据没有统一归属。

## 3. 核心判断验证

### 3.1 Artifact-first 是正确主线

当前方案强调 Agent 之间通过结构化产物交接，而不是自由聊天。这一点是正确的。

原因：

- 软件交付需要审计、回滚、Review 和责任归属。
- AI 对话上下文不稳定，且容易混入未确认假设。
- 产物化可以让需求、设计、实现、测试和 Review 被人类复查。

外部资料也支持这一方向。GitHub Copilot cloud agent 的产品化工作流围绕 branch、PR、日志、Review 和 CI 权限展开；其文档明确要求 Copilot 产出的 PR 仍应像其他贡献一样严格 Review，并且 GitHub Actions workflow 运行需要额外谨慎处理（`SRC-011`、`SRC-012`）。

结论：Artifact-first 是当前方案最应保留和强化的核心原则。

### 3.2 Supervisor-controlled 优于自由多 Agent 群聊

当前方案反对 Agent 自由辩论，推荐由 Supervisor 通过工作流状态调度角色 Agent。

这一判断合理。Microsoft Agent Framework 把多 Agent 编排区分为 Sequential、Concurrent、Handoff、Group Chat、Magentic 等模式（`SRC-003`）。OpenAI Agents SDK 也强调应用可以拥有 orchestration、tool execution、approvals 和 state（`SRC-004`）。LangGraph persistence 进一步说明状态持久化、checkpoint、resume 和 human-in-the-loop 对长流程 Agent 很重要（`SRC-001`）。

但当前 README 还缺两层：Supervisor 的状态机，以及 Harness run context。

如果只有角色职责，没有状态、输入、输出、门禁和失败转移，Supervisor 容易退化为“一个很长的提示词”。`ANA-CMP-002` 已指出这个缺口。

如果只有 Context Pack，没有 Harness run context，Agent 知道“应该做什么”，但系统没有明确“允许怎么做”。

两者需要分工：

| 概念 | 解决的问题 | 典型字段 |
|---|---|---|
| Context Pack | Agent 应该知道什么 | goal、acceptance criteria、relevant files、constraints |
| Harness Run Context | Agent 本次执行允许怎么做 | allowed tools、allowed paths、network policy、timeout、required evidence |

建议 README 增加状态机表：

| State | Input | Output | Owner | Gate | Failure / Escalation |
|---|---|---|---|---|---|
| intake | user goal | brief | Supervisor | goal captured | ask human |
| requirements | brief | requirements | Planner | human accepted | revise scope |
| design | requirements | design / ADR | Planner / Architect | design accepted if required | human architecture review |
| implementation | tasks | diff + implementation notes | Developer | test evidence exists | return to Developer |
| verification | diff | test report | Reviewer-Tester | verified or risk accepted | blocked / human |
| review | diff + tests | review report | Reviewer-Tester | no blocker / major | fix loop |
| acceptance | all artifacts | acceptance | Human | merge approved | blocked |

每个 Agent 执行状态都应关联 Harness 产物：

```text
run-context.md
execution-report.md
tool-log.md
test-log.md
diff-summary.md
permission-decisions.md
```

### 3.3 外部资料支持机制，不等于证明本框架有效

需要避免过度结论。

外部资料可以支持以下判断：

- 状态持久化和 checkpoint 对 HITL、恢复和调试有价值（`SRC-001`）。
- Human-in-the-loop 可用于 approve、edit、reject、respond 等工具调用决策（`SRC-002`）。
- Guardrails 应分布在输入、输出和工具调用边界，而不是只靠最终检查（`SRC-005`）。
- Tracing 有助于记录 LLM generation、tool call、handoff 和 guardrail（`SRC-006`）。
- SWE-bench 说明真实 GitHub issue 需要仓库上下文、跨文件修改和测试验证（`SRC-007`）。
- SWE-bench-Live 说明静态 benchmark 可能过时，需要动态、持续评估（`SRC-008`）。

但这些资料不能证明本方案一定提升团队效率或质量。

因此，README 中应把质量收益写成 MVP 要验证的假设，而不是已经成立的结论。

## 4. 与软件研发实践的对齐分析

当前方案与成熟软件研发实践高度一致，但需要更细颗粒度的落地规则。

| 方案元素 | 对齐的软件研发实践 | 当前强点 | 需要补强 |
|---|---|---|---|
| requirements / tasks | 需求分析、用户故事、验收标准 | 防止一句话需求直接编码 | 任务分级和最小字段 |
| design / ADR | 架构评审、ADR | 防止 Agent 擅自改架构 | 何时必须 ADR |
| implementation notes | PR 描述、变更说明 | 让代码 diff 有意图说明 | 输出格式和失败证据 |
| test_report | QA、CI、回归测试 | 把测试变成门禁 | 不可验证、部分验证状态 |
| review_report | PR Review、branch protection | 独立质量判断 | blocker 分类和证据要求 |
| Human Gate | Change approval、release approval | 人控制高风险边界 | 审批、咨询、通知要区分 |
| Context Pack | runbook、任务单、代码索引 | 减少上下文污染 | 冲突解析和优先级 |
| Harness | sandbox、CI log、tool policy、audit trail | 让 Agent 执行可控、可审计、可复现 | run context、工具策略、execution report |

`ANA-CMP-001` 的关键结论是：Artifact-first 模型与 SDLC / PR 流程一致，但需要任务分级控制 MVP 成本。

建议 README 增加任务分级矩阵：

| Class | 场景 | 必需产物 | 必需 Agent | Human Gate |
|---|---|---|---|---|
| `S0 trivial` | 文案、注释、小配置、低风险小修 | task note、implementation、test evidence 或 not verified reason | Developer、Reviewer-Tester 可简化 | human acceptance |
| `S1 normal` | 普通 feature、bugfix | requirements、tasks、implementation、test_report、review_report | Planner、Developer、Reviewer-Tester | requirement acceptance、final acceptance |
| `S2 high-risk` | 架构、安全、权限、CI、数据迁移、跨模块变更 | requirements、design/ADR、tasks、test_report、review_report、acceptance | Planner/Architect、Developer、Reviewer-Tester | requirement、architecture、permission、merge |
| `incident` | 紧急生产修复 | triage、minimal patch、smoke test、emergency approval、post-incident backfill | Supervisor、Developer、Reviewer-Tester | emergency approval、postmortem acceptance |

这能解决两个问题：

- 小任务不过度流程化。
- 高风险任务自动触发更强门禁。

Harness 对任务分级也有影响：

- `S0 trivial` 可以使用轻量 Harness，只记录 diff、命令和测试证据。
- `S1 normal` 需要标准 run context 和 execution report。
- `S2 high-risk` 必须启用更严格的 tool policy、permission gate 和 audit trail。
- `incident` 可以走快速 Harness，但必须记录 emergency approval 和 post-incident backfill。

## 5. 多 Agent 协作架构评估

### 5.0 Harness 是缺失的执行中间层

重新分析需求后，Harness 应被视为架构中的独立层。

它解决的是执行治理问题，不是协作决策问题。

| 层 | 主要问题 |
|---|---|
| Supervisor | 谁在什么阶段调度哪个 Agent |
| Agent Blueprint | 这个 Agent 应该扮演什么角色、产出什么 |
| Context Pack | 这个 Agent 本轮应知道什么 |
| Harness Run Context | 这个 Agent 本轮允许怎么运行 |
| Coding Executor | 具体如何读写代码、运行命令、调用工具 |
| Execution Report | 这次运行实际做了什么，有什么证据 |

因此，Harness 不应被设计成第六个角色 Agent。

它应作为每次 Agent 执行的“运行契约和审计外壳”。

### 5.1 角色边界是 MVP 的首要风险控制点

`ANA-RISK-001` 指出，MVP 不应优先追求更多 Agent，而应先验证角色边界是否稳定。

当前方案的边界是正确的：

- Supervisor 不写代码。
- Developer 不自审自批。
- Reviewer 不替代 Tester。
- Tester 不修代码。

但 MVP 中 `Reviewer-Tester` 合并角色会带来风险。合并可以降低成本，但不能合并责任。

建议在 README 中明确：

```text
Reviewer-Tester 是 MVP 的角色合并，不是职责合并。
其输出必须分为 Verification 和 Review 两部分。
```

推荐 `review_report.md` 至少包含：

```text
verification_status:
test_commands:
test_results:
coverage_scope:
review_findings:
blocking_issues:
major_issues:
minor_notes:
residual_risk:
decision:
```

其中 `decision` 只能是：

```text
approved
approved_with_minor_notes
changes_requested
blocked
```

### 5.2 Fix Loop 必须硬性封顶

当前 README 已有：

```text
max_fix_iterations = 3
```

这条规则应保留，并写入每个任务的 run state。

原因：

- 自动修复容易反复尝试同一问题。
- 多轮修复可能扩大改动范围。
- 超过 3 次通常说明需求、设计、测试环境或实现路径存在根本问题。

建议每轮 Fix Loop 记录：

```text
iteration_number:
source_issue_id:
required_change:
changed_files:
test_result:
remaining_risk:
next_decision:
```

第 3 次仍未通过时必须升级给人。

### 5.3 Incident-fix 需要快速路径和补偿路径

当前 README 列出了 `incident-fix`，但没有展开。

建议定义为：

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

重点不是让紧急修复走完整 feature-dev 流程，而是：

- 快速恢复。
- 记录绕过了哪些普通门禁。
- 记录谁批准。
- 事后补齐测试、文档和复盘。

## 6. Team Skill 交付形态设计

### 6.1 Skill 是合适的第一交付形态

`ANA-SKILL-001` 的结论是：Skill 是合适的第一交付形态，但必须保持文件系统边界。

加入 Harness 后，这个结论需要修正为：

```text
Skill 不只是规则和模板包，还必须包含最小 Harness 规则。
```

原因：

- 当前框架首先要固化团队协作规则。
- 规则可以先用 `SKILL.md`、reference、template 和 repo-local 文件表达。
- Harness 可以先以 repo-local policy 和 report 模板存在，不需要一开始建设 runtime、控制台、RBAC、SSO、审计和成本系统。

Skill 的定位应是：

```text
在现有代码仓库中建立 AI Native 研发协作规则、模板、门禁和任务产物。
```

不是：

```text
自动化平台、项目管理系统、CI 替代品、发布系统或企业治理控制面。
```

### 6.2 历史建议：MVP Skill 推荐范围

`ANA-SKILL-002` 原建议 MVP 收敛为四角色、三工作流、六产物。补充 Harness 后，应调整为四角色、三工作流、六个业务产物加最小执行产物。

本节保留调研阶段的历史建议，用于说明早期如何控制试运行成本。当前 README 已经覆盖该建议，不再采用单独 Skill MVP，也不再合并 Tester 和 Reviewer。

推荐 MVP Skill 默认包含：

```text
roles:
  Supervisor
  Planner
  Developer
  Reviewer-Tester

workflows:
  feature-dev
  bugfix
  code-review

artifacts:
  requirements.md
  design.md
  tasks.md
  implementation.md
  test_report.md
  review_report.md
  execution_report.md
```

但 `design.md` 的强制性应由任务等级决定：

- `S0 trivial`：不要求。
- `S1 normal`：有设计选择时要求轻量 design note。
- `S2 high-risk`：必须要求 design 或 ADR。
- `incident`：事后补齐设计或 ADR，如果涉及架构或生产风险。

### 6.3 Skill 包结构建议

建议后续 Skill 设计采用：

```text
ai-native-development-framework/
  SKILL.md
  references/
    principles.md
    agent-roles.md
    workflows.md
    harness.md
    quality-gates.md
    context-pack.md
    human-control-points.md
    versioning-policy.md
  templates/
    ai/
      agents/
        supervisor.md
        planner.md
        developer.md
        reviewer-tester.md
      workflows/
        feature-dev.md
        bugfix.md
        code-review.md
      policies/
        permissions.md
        escalation.md
        quality-gates.md
        harness-policy.md
      templates/
        run-context.md
        execution-report.md
    specs/
      requirements.md
      design.md
      tasks.md
      implementation.md
      test_report.md
      review_report.md
      acceptance.md
```

可选脚本只做结构检查，不做平台编排：

```text
scripts/
  inspect_repo.sh
  validate_task_structure.sh
```

### 6.4 Skill 生成的 repo-local 结构

建议目标仓库生成：

```text
.ai/
  agents/
    supervisor.md
    planner.md
    developer.md
    reviewer-tester.md
  workflows/
    feature-dev.md
    bugfix.md
    code-review.md
  policies/
    permissions.md
    task-classes.md
    quality-gates.md
    escalation.md
    harness-policy.md
  templates/
    context-pack.md
    task-status.md
    run-context.md
    execution-report.md

specs/
  {task_id}/
    requirements.md
    design.md
    tasks.md
    implementation.md
    test_report.md
    review_report.md
    acceptance.md
    runs/
      {run_id}/
        run-context.md
        execution-report.md
        tool-log.md
        test-log.md
        diff-summary.md
        permission-decisions.md
```

其中 `.ai/` 是长期规则，`specs/` 是任务运行产物。

`specs/{task_id}/runs/` 是 Harness 执行记录。它应成为 Supervisor 做质量门禁的证据来源之一。

### 6.5 Skill 版本治理

Skill 应像代码一样版本化。

最低需要：

```text
.ai/version.md
.ai/policies/quality-gates.md
.ai/policies/escalation.md
.ai/policies/permissions.md
specs/{task_id}/acceptance.md
```

升级规则：

- 不自动覆盖团队已修改文件。
- 先生成差异说明。
- 权限、质量门禁、人工审批点变化必须标记为 governance change。
- 失败案例和 Review 争议应进入下一轮 Skill 规则修订。

## 7. 历史建议：MVP 范围与验证计划

本章保留调研阶段的试运行设计，可作为目标版 Skill 的实验指标来源。它不再代表当前 README 的目标架构。

### 7.1 推荐 MVP 定义

MVP 不应实现平台，也不应追求完整 Agent 组织。

推荐定义：

```text
在单个真实代码仓库内，
用四角色、三工作流、六个业务产物和最小 Harness 执行产物，
验证 AI 是否能通过 spec、test、review 和 human gate
形成可审计的软件交付闭环。
```

MVP 包含：

- repo-local `.ai/` 规则。
- `specs/{task_id}/` 任务产物。
- repo-local Harness policy 和 execution report。
- Supervisor、Planner、Developer、Reviewer-Tester。
- feature-dev、bugfix、code-review。
- 最大 3 次 Fix Loop。
- 明确 Human Gate。
- 明确验证状态。

Harness 在 MVP 中不应做成平台，但必须有最小运行契约：

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
required_evidence:
```

每次 Developer 或 Reviewer-Tester 执行后，必须生成：

```text
execution_report.md
tool-log.md
test-log.md
diff-summary.md
permission-decisions.md
```

MVP 不包含：

- 自动监听 issue / PR。
- 自动发布。
- 跨仓库治理。
- RBAC / SSO。
- 成本控制台。
- Agent 版本注册表。
- 长期数据库 memory。

### 7.2 MVP 实验建议

建议至少做 6-9 个真实任务试运行，覆盖：

- 2-3 个 feature-dev。
- 2-3 个 bugfix。
- 2-3 个 code-review。

对比基线：

- 当前团队常规人工流程。
- 单 Agent ad hoc coding 流程。

核心问题不是“能不能完成任务”，而是：

- 是否减少需求漂移？
- 是否提升测试证据完整度？
- 是否让 Review 更早发现 blocker？
- 是否增加过多流程成本？
- 是否让人工审批更清晰？

### 7.3 MVP 指标

建议记录：

| Metric | 含义 | 初始目标 |
|---|---|---|
| task cycle time | 从 brief 到 acceptance 的耗时 | p75 不超过基线 1.5 倍 |
| defect escape rate | Gate 后仍被发现的问题比例 | 不高于基线 |
| review blocker discovery | Review 发现真实 blocker / major 的比例 | 有证据可解释 |
| test evidence completeness | 测试命令、环境、结果、限制是否完整 | merge 候选任务达到 100% |
| human intervention frequency | 每个任务人工确认次数 | 低风险任务不超过 2 次 |
| context pack size | Agent 接收上下文大小 | 比完整聊天减少 40% 以上 |
| fix loop count | 修复迭代次数 | 平均不超过 2，硬上限 3 |
| spec change count | 实现后 spec 修改次数 | 标准任务不超过 1 |
| workflow friction score | 开发者主观流程负担 | median 不超过 3/5 |
| artifact completion rate | 必需产物字段完整度 | MVP 任务达到 90% 以上 |
| harness evidence completeness | execution report、tool log、test log、diff summary 是否完整 | merge 候选任务达到 100% |
| unauthorized tool attempt count | 被 Harness 拦截的越权工具调用次数 | 高风险操作 100% 拦截 |
| execution reproducibility | 是否能根据 run context 和日志复现关键步骤 | 高风险任务必须可复现 |

这些指标来自 `ANA-RISK-005`、`ANA-RISK-006` 和 `risk_and_evaluation.md`。

## 8. 风险、失败模式与质量门禁

### 8.1 主要风险矩阵

| 风险 | 影响 | 建议控制 |
|---|---|---|
| Supervisor 越权写代码或放行 | 高 | Supervisor Blueprint 写入禁止事项，门禁验收时检查 |
| Developer 自审自批 | 高 | Developer 不得声明最终完成，必须交测试证据 |
| Reviewer-Tester 泛化 approval | 高 | approval 必须列检查范围、证据和剩余风险 |
| Spec drift | 高 | Context Pack 包含 acceptance、constraints、forbidden_actions |
| Context pollution | 高 | 长期记忆只接收已确认产物 |
| Fix Loop 无边界 | 高 | `max_fix_iterations = 3`，超限升级 |
| Tool permission abuse | 高 | 高风险工具人工审批 |
| Missing Harness boundary | 高 | 每次 Agent 执行必须有 run context 和 execution report |
| Missing test evidence | 高 | Gate 4 改为可复现测试证据 |
| Workflow overhead | 中 | 任务分级和轻量路径 |
| Skill 规则陈旧 | 中 | Skill 版本化和失败案例回归 |
| 过早平台化 | 高 | 平台化准入条件 |

### 8.2 质量门禁建议

当前 README 的 Gate 设计应从原则升级成可执行检查表。

建议每个 Gate 包含：

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

尤其要把：

```text
tests pass
```

改为：

```text
test evidence complete and reproducible
```

并增加验证状态：

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

质量门禁不应只读取 Agent 自述，还必须读取 Harness 记录：

- `run-context.md`
- `execution-report.md`
- `tool-log.md`
- `test-log.md`
- `diff-summary.md`
- `permission-decisions.md`

如果缺少 Harness execution report，任务不能进入 `approved`。

### 8.3 Human Gate 分类

README 当前把人的介入点列得比较清楚，但还需要区分类型。

建议新增：

| Type | 用途 | 示例 |
|---|---|---|
| `approval_required` | 没有人批准不能继续 | merge、release、权限、CI workflow 修改 |
| `review_required` | 人需要审查，但可给修改意见 | 架构设计、高风险 Review |
| `info_required` | AI 需要人补充信息 | 需求歧义、验收标准不清 |
| `notify_only` | 只通知，不阻塞 | 低风险测试重跑、状态更新 |

这能避免所有 Human Gate 都变成阻塞审批。

## 9. 与当前 README 的核对状态

本次复核后，调研中仍然成立的机制级建议已经进入当前 README。

| 调研建议 | 当前 README 状态 | 说明 |
|---|---|---|
| Execution Harness | 已纳入 | Harness 被定义为运行边界，不是 Agent |
| Context Pack / Harness Run Context 区分 | 已纳入 | Context Pack 解决“知道什么”，Run Context 解决“允许怎么运行” |
| Workflow 状态机 | 已纳入 | 已定义 intake、classify、requirements、design、planning、implementation、test、review、fix、acceptance、blocked |
| 任务分级 | 已纳入 | 已定义 `S0 trivial`、`S1 normal`、`S2 high-risk`、`research-spike`、`incident` |
| Human Gate 分类 | 已纳入 | 已定义 `approval_required`、`review_required`、`info_required`、`notify_only` |
| 验证状态 | 已纳入 | 已定义 `verified`、`partially_verified`、`not_verified`、`blocked_by_environment` |
| `tests pass` 升级为证据门禁 | 已纳入 | Gate 4 已改为 `test evidence complete and reproducible` |
| Context 冲突规则 | 已纳入 | 已定义 Source of Truth 优先级和 `context_conflict` |
| incident-fix 快速路径 | 已纳入 | 已定义 triage、minimal patch、smoke test、emergency approval 和事后补偿 |
| 平台化准入条件 | 已纳入 | 已要求真实任务验证、指标可记录、规则趋稳、团队确认收益 |
| Reviewer-Tester MVP 合并 | 已覆盖 | 当前 README 不再采用该建议，改为目标版 Tester / Reviewer 独立职责 |
| Skill MVP 范围 | 已覆盖 | 当前 README 不再设计单独 Skill MVP，改为目标版 Skill |

结论：当前 README 与调研方向一致。差异主要来自后续方案决策：为了避免用户误解和重复执行 Skill，README 已经取消“先 MVP Skill、再目标版 Skill”的两阶段表述，并保留完整 Worker Agent 角色。

## 10. 下一步行动

当前不建议直接建设平台，也不需要回到早期 Skill MVP 方案。

推荐下一步：

1. 基于 README 起草目标版 Skill 的 `SKILL.md` 和 `references/` 文件。
2. 将 `.ai/agents/`、`.ai/workflows/`、`.ai/policies/`、`.ai/templates/`、`specs/{task_id}/` 模板具体化。
3. 为 `feature-dev`、`bugfix`、`code-review`、`refactor`、`research-spike`、`incident-fix` 分别写出工作流模板。
4. 设计 repo-local Harness policy、run-context 和 execution-report 模板。
5. 用少量真实任务试运行目标版 Skill 的规则，观察任务分级、Human Gate、Quality Gate 和 Harness 证据是否可执行。
6. 根据试运行结果修订 Skill，而不是先做 LangGraph / Microsoft Agent Framework 平台原型。

短期仍不建议做：

- 企业级控制台。
- 自动 issue / PR 调度。
- 自动发布。
- 跨仓库治理。
- RBAC / SSO / 成本控制台。

这些能力应等 repo-local Skill 规则被真实任务验证后，再进入平台化讨论。

## References

- `SRC-PROPOSAL-README`: repository root `README.md`
- `SRC-001`: LangGraph Persistence documentation
- `SRC-002`: LangChain Human-in-the-loop documentation
- `SRC-003`: Microsoft Agent Framework workflow orchestrations documentation
- `SRC-004`: OpenAI Agents SDK guide
- `SRC-005`: OpenAI Agents SDK guardrails documentation
- `SRC-006`: OpenAI Agents SDK tracing documentation
- `SRC-007`: SWE-bench paper
- `SRC-008`: SWE-bench-Live paper
- `SRC-009`: Failure modes of LLMs resolving GitHub issues paper
- `SRC-010`: Human-Agent Collaboration framework paper
- `SRC-011`: GitHub Copilot cloud agent documentation
- `SRC-012`: GitHub Copilot output review documentation
- `ANA-CMP-*`: `workspace/02.analysis/comparative_analysis.md`
- `ANA-SKILL-*`: `workspace/02.analysis/skill_delivery_design.md`
- `ANA-RISK-*`: `workspace/02.analysis/risk_and_evaluation.md`
