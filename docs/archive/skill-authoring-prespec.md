# Skill 编制前置规格

> 历史归档：本文是 Skill/Plugin 编制前的设计输入，不再作为当前执行计划。当前 Plugin/Skill 模块边界见 [../plugin-skill-modularization.md](../plugin-skill-modularization.md)。

## 1. 目标

本文定义 `dev-cadence` 的编制前置规格。

目标是在调整包结构之前，先稳定 Skill 或 Plugin 必须实现的契约。本文不是 Skill 本身，而是 Skill 入口、references、templates、adapters 和 repo-local artifact 契约的设计输入。

状态说明：目标架构草案见 [Dev Cadence 目标形态方案草案](dev-cadence-target-model.md)。通用框架规则放在 plugin-owned resources 中；目标仓库只保留薄入口、本地覆盖配置和任务 artifacts。

历史阶段完成状态见 [Dev Cadence 路线图](dev-cadence-roadmap.md)。本文不追踪逐项执行进度。

## 2. 设计假设

- 受众：可复用的团队 Plugin，包含一个 bootstrap Skill 和少量面向工作动作/纪律的 Skills。
- 语言：Skill instructions、templates、Blueprint 文件和生成 artifacts 使用英文标识；说明性文档可以使用中文。
- 执行模型：executor-agnostic Harness，并提供可用于 Codex-style coding agents 的示例。
- 交付模型：从 Plugin-owned rules、templates、adapters 和 repo-local artifacts 开始，而不是先做平台。
- 演进方向：优先使用 plugin-owned reusable rules 加 thin repo-local contract，而不是把完整框架复制到每个目标仓库。见 [Dev Cadence 目标形态方案草案](dev-cadence-target-model.md)。
- 第一批工作流：`feature-dev`、`bugfix`、`code-review`、`refactor`、`research-spike`、`incident-fix`。
- 核心 Worker Agents：`Planner`、`Architect`、`Developer`、`Tester`、`Reviewer`。
- 可选 Worker Agent：`Researcher`。
- 非 Agent 角色：`Human`、`Supervisor`、`Harness`、`Quality Gate`、`Human Gate`。
- 触发边界：`using-dev-cadence` 是唯一代表 Dev Cadence 整体的入口 Skill/router，通过 Codex 原生 Skill 触发或用户显式要求使用 Dev Cadence 进入流程。
- `cadence-sync` 只处理 initialize、inspect、sync、repair、diagnose 和 thin repo-local contract 写入。
- 普通 feature、bugfix、review、refactor、research 和 incident 工作由 `using-dev-cadence` 路由到 `cadence-clarify`、`cadence-plan`、`cadence-execute`、`cadence-tdd`、`cadence-debug`、`cadence-review` 和 `cadence-verify`。
- `implementation_discipline: default` 和 `verification_discipline: default` 表示 Dev Cadence 内置交付纪律，不依赖外部 Skill。
- 未初始化仓库中的产品实现请求不应因为缺少 thin repo-local contract 而被阻塞；需要持久 artifact 时再创建 `specs/` 或调用 `cadence-sync`。
- Repo contract 边界：setup、sync、repair、diagnosis 默认只能写 root `AGENTS.md`、root `.gitignore` 中的 `.dev-cadence.yaml` 忽略项、root `.dev-cadence.yaml` 和 `specs/.gitkeep`；除非用户同一轮明确要求交付工作，否则不得修改产品代码或 task-specific specs。

## 3. 不可协商原则

1. Agent 协作必须 artifact-first。Chat 不是稳定事实来源。
2. Supervisor 控制 workflow state，但不写代码、不做最终架构决策、不批准自己的工作。
3. Harness 通过 context injection、tool policy、permission policy、logging 和 evidence capture 中介每一次 Worker Agent 执行。
4. Worker Agents 通过结构化 artifacts 交接，而不是通过对话摘要交接。
5. Developer 不能声明最终完成。
6. Tester 和 Reviewer 必须保持独立职责。
7. Fix loops 最多 3 次。
8. 高风险动作需要 Human Gate approval。
9. 缺失证据是一种 workflow state，不是 approval。
10. 不完整验证必须 blocked，直到具名 Human 接受剩余风险。
11. Supervisor、Harness、Developer、Tester、Reviewer 不能被记录为 final accepter。
12. Workflow 可以推断，但不明确的产品意图不能猜。目标、范围、非目标、参考行为或验收标准有歧义时，实现前必须向用户澄清。
13. Assumptions 必须单独记录；未经具名 Human 决策，不能变成 scope、non_goals 或 acceptance criteria。
14. 实现前必须做 Requirements Readiness Check。诸如 "not as expected"、"inconsistent"、"same as"、"match"、"align"、"parity"、"fix this issue" 等宽泛或比较性表述，如果没有明确 expected behavior 和 comparison dimension，不足以开始实现。
15. 澄清应基于分析。Agent 应先检查相关代码、文档、specs 或行为，再给出候选解释和推荐选项，而不是让用户从零发现歧义。
16. 仓库证据可以支持候选解释，但不能替代用户意图澄清、需求接受或 G1 通过。需要澄清时，G1 必须记录选择或延期该解释的 Human。
17. 如果用户否定或修正先前结果，必须重新打开并澄清 requirements 后才能继续实现。
18. 默认交付纪律是强制规则，不是建议；例外必须由具名 Human Gate 记录原因、剩余风险和后续处理。
19. Testable behavior changes 默认必须执行严格 Red-Green-Refactor：先写失败测试并确认失败原因，再写最小实现，再在测试保持通过时重构。
20. Bugfix 和 incident 不应先猜修复；必须先复现、刻画或记录无法复现的证据缺口。
21. Review 应先检查 spec compliance，再检查 code quality；critical 或 major finding 未解决时不能继续进入 acceptance。
22. Completion claim 必须先有验证证据；缺失验证不能用自述替代。
23. 平台自动化应延后，直到 Plugin-owned rules、thin repo-local contracts 和 artifact workflows 在真实任务中得到验证。

## 4. 目标 Codex Plugin 发布结构

`dev-cadence` 当前 Codex Plugin 发布形态应使用 progressive disclosure。`using-dev-cadence` 负责 bootstrap 和路由，`cadence-*` Skills 负责具体工作动作，references/templates/scripts 承载共享治理协议和可复用资源。

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
  templates/
  scripts/
```

发布用 Plugin 内容不应包含通用 README、installation guide、changelog 或叙事性研究文档，除非插件发布格式要求。这些内容属于框架仓库，不属于 runtime Skill body。

`delivery-disciplines.md` 应作为默认交付纪律的路由入口。具体规则放在细分 reference 中，任务 artifact 模板放在 `templates/spec/`，Harness evidence 模板放在 `templates/runs/`，prompt template 放在 `templates/prompts/`，由 Harness 在创建 artifact、记录 evidence 或装载 Worker/reviewer run 时使用。`scripts/check-skill-package.mjs`、`scripts/check-discipline-routes.mjs` 和 `scripts/check-spec-artifacts.mjs` 应提供轻量 `dev-cadence` source self-check，覆盖语言边界、metadata、脚本语法、discipline route、artifact template、prompt template、bundled resource 和 task artifact。

`visual-companion.md` 与 `scripts/visual-companion/` 是 intent/design 阶段的可选视觉对齐能力。它可以用于 mockup、diagram、layout comparison 等场景，但不能替代 requirements，也不能成为 G1 必需条件。环境不可用时必须降级为 text-only clarification。

Codex Plugin 应能安全地安装在 system scope。`using-dev-cadence` 通过 Codex 原生 Skill 触发或用户显式要求使用 Dev Cadence 进入流程，并必须路由到具体 `cadence-*` Skills；`cadence-sync` 不得把普通 feature、bugfix、review、refactor、research 或 incident execution 描述为 repo contract 工作。
## 5. 仓库本地输出结构

应用到目标仓库时，`cadence-sync` 可创建或更新 thin repo-local contract：

```text
AGENTS.md
.gitignore
.dev-cadence.yaml

specs/
  .gitkeep
```

`AGENTS.md` 将 Codex 中的普通交付工作路由到 `dev-cadence`。`.dev-cadence.yaml` 保存被忽略的用户本地覆盖配置。默认配置由 `dev-cadence` 持有，不在目标仓库生成 `.ai/` 目录。`specs/` 保存任务 artifacts 和 Harness evidence。`.dev-cadence/visual-companion/` 只保存可选 visual companion session，应由 `.gitignore` 忽略。

Dev Cadence Core 本身不绑定 Codex。`dev-cadence` 当前优先支持 Codex Plugin 发布形态；其他 agent runtime 可以实现同一 Core contract，并继续沿用 `dev-cadence` 名字，但不需要继承 Codex 的 Skill 触发、AGENTS.md 入口或 plugin package 结构。

`.dev-cadence.yaml` 应生成带注释的本地偏好字段：

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

`default` discipline 表示使用 Dev Cadence 内置交付纪律：澄清意图、可执行 planning、严格 Red-Green-Refactor、复现优先 debugging、两阶段 review、完成前验证，以及只对独立问题域并行执行。

内置交付纪律应由 Dev Cadence 自己持有，不依赖外部 Skill。默认加载路径是 `delivery-disciplines.md`，再按状态进入细分 reference、optional visual companion 和 prompt template。

`artifact_language` 支持 `en` 和 `zh`。`.dev-cadence.yaml` 中未注释的 `dev_cadence.artifact_language` 会覆盖插件默认值。初始化和更新应把 `.dev-cadence.yaml` 加入 `.gitignore`，并保留已有 ignore rules。

仓库不应要求用户为每个 feature、bugfix、refactor、review、research 或 incident request 显式调用 Skill 名称。`using-dev-cadence` 从请求中推断 `selected_workflow`，并路由到具体 `cadence-*` Skill。Root `AGENTS.md` 只保存薄入口和项目特定约束，不复制完整框架规则。

Framework initialization、synchronization、repair、diagnosis 不是 delivery task。除非同一轮用户明确要求具体交付任务，否则它们不应创建 `specs/{task_id}/`，也不应修改产品源代码、测试、迁移、构建脚本、部署文件或应用配置。

## 6. Supervisor 状态机

Supervisor 必须基于显式 workflow state 工作，而不是依赖对话判断。

| 状态 | 负责人 | 必需输入 | 必需输出 | Gate | 下一状态 |
|---|---|---|---|---|---|
| `intake` | Supervisor | user request | `00-brief.md` | goal、constraints 和 requested outcome 已记录 | `classify` |
| `classify` | Supervisor | `00-brief.md` | task class and workflow type | task class 是 `S0`、`S1`、`S2`、`research-spike`、`incident` 之一 | `requirements` or lightweight path |
| `requirements` | Planner | brief, task class | `01-requirements.md` | scope、non-goals、constraints、acceptance criteria 清晰 | `design` or `planning` |
| `design` | Architect | requirements, project constraints | `02-design.md` or ADR | 仅 high-risk 或 design-sensitive 工作需要 design | `planning` |
| `planning` | Planner | requirements, design if present | `03-tasks.md` | tasks 可执行且有边界 | `implementation` |
| `implementation` | Developer via Harness | tasks, context pack, run context | code diff, `05-implementation.md`, execution report | implementation notes 和初始验证证据存在 | `test` |
| `test` | Tester via Harness | diff, implementation notes, test plan | `04-test-plan.md`, `06-test-report.md`, execution report | verification status 有证据记录 | `review` or `fix` |
| `review` | Reviewer via Harness | diff, test report, implementation notes | `07-review-report.md`, execution report | 无未解决 blocker 或 major issue | `acceptance` or `fix` |
| `fix` | Developer via Harness | structured issue list | patch, updated implementation notes, execution report | fix 限定在已知问题内且 loop count 未超限 | `test` |
| `acceptance` | Human with Supervisor recording | all artifacts and reports | `08-acceptance.md` | named Human 接受结果和剩余风险 | `done` |
| `blocked` | Supervisor and Human | blocker evidence | escalation decision | human 决定 continue、split、defer 或 stop | selected state |

### 状态机规则

- 每个 Worker Agent state 都必须通过 Harness 执行。
- 每个 Harness run 都必须产出 `run-context.md`、`execution-report.md`、`tool-log.md` 和 `permission-decisions.md`；变更文件的 run 还必须产出 `diff-summary.md`；执行命令或测试的 run 还必须产出 `test-log.md`。
- Supervisor 不能用自己的总结替代缺失的 Worker Agent artifacts。
- 跳过任何 state 都必须记录原因和剩余风险。
- 任何影响 scope、architecture、security、permissions、test validity 或 acceptance 的冲突都必须进入 Human Gate。
- `S2` 工作在实现前必须记录所需 Human Gate approvals。
- 任何非 `verified` 的 verification status 都必须在 review approval 或 final acceptance 前进入 Human Gate。
- Final acceptance 必须命名 Human accepter；`accepted_by: supervisor` 或任何 Worker Agent 都无效。
- `fix` 每个任务最多运行三次，超限后 escalation。

## 7. 任务分级

Task class 决定 workflow 强度。

| 分级 | 适用场景 | 必需 Agents | 必需 Artifacts | Human Gate |
|---|---|---|---|---|
| `S0 trivial` | 文本编辑、注释、低风险配置、很小且可回滚的修改 | Developer; Reviewer optional | brief, implementation notes, test evidence or not-verified reason, acceptance | final acceptance |
| `S1 normal` | 普通 feature、bugfix、本地 refactor、普通 code review | Planner, Developer, Tester, Reviewer | requirements, tasks, implementation, test report, review report, acceptance | requirement acceptance, final acceptance |
| `S2 high-risk` | architecture、security、permissions、CI、data migration、cross-module changes | Planner, Architect, Developer, Tester, Reviewer | requirements, design or ADR, tasks, implementation, test report, review report, acceptance | requirement, architecture or risk approval before implementation, permission approval when needed, final human acceptance |
| `research-spike` | 技术选型、未知可行性、比较研究 | Researcher, Architect optional | research report, options comparison, recommendation, open questions | decision review |
| `incident` | 紧急生产或关键故障修复 | Supervisor, Developer, Tester and Reviewer as needed | triage, minimal patch, smoke test, emergency approval, post-incident backfill | emergency approval, post-incident acceptance |

## 8. Context Pack 契约

Context Pack 定义 Agent 应该知道什么。它不定义 Agent 被允许做什么。

```yaml
task_id:
workflow_hint:
selected_workflow:
selection_reason:
task_class:
agent_role:
goal:
current_state:
acceptance_criteria:
non_goals:
constraints:
relevant_specs:
relevant_decisions:
relevant_files:
previous_outputs:
known_risks:
forbidden_assumptions:
expected_output:
handoff_target:
```

### Context 规则

- Context Pack 应只包含当前 Agent 所需的最小充分上下文。
- Chat history 可以作为线索，但除非写入已批准 artifact，否则不能成为稳定上下文。
- 如果来源冲突，Agent 必须标记 `context_conflict`。
- 来源优先级是：current code and test results、approved specs and ADRs、current task artifacts、stable project docs，然后才是 chat or issue discussion。

## 9. Harness Run Context 契约

Harness Run Context 定义本次 Agent 执行被允许如何运行。

```yaml
run_id:
task_id:
agent_role:
blueprint_path:
context_pack_path:
workspace_path:
allowed_read_paths:
allowed_write_paths:
denied_paths:
allowed_tools:
denied_tools:
network_policy:
secret_policy:
permission_policy:
budget:
timeout:
max_iterations:
required_evidence:
expected_artifacts:
log_paths:
```

### Harness 规则

- Harness 不是 Agent，不能做语义批准决策。
- Harness 为 Supervisor 和 gates 记录执行证据。
- Harness 必须捕获 command logs、tool logs、diff summary、test logs、permission decisions 和 final execution report。
- 高风险动作必须在执行前触发 permission checks。
- 缺失 Harness evidence 会阻止 approval。

## 10. Agent Blueprint 契约

每个 Agent Blueprint 应遵循同一结构：

```text
# {Agent Name} Blueprint

## Role

## Responsibilities

## Inputs

## Required Outputs

## Forbidden Actions

## Evidence Requirements

## Handoff Format

## Escalation Conditions
```

### Planner（规划者）

职责：

- 澄清 goal、scope、non-goals、constraints 和 acceptance criteria；
- 将工作拆成可执行任务；
- 识别缺失信息。

必需输出：

- `01-requirements.md`；
- 请求 planning 时输出 `03-tasks.md`。

禁止动作：

- 编写实现代码；
- 做超出任务规划范围的架构决策；
- 批准最终完成。

### Architect（架构师）

职责：

- 定义技术方案、架构约束、备选方案和风险；
- 当任务改变持久架构时创建 ADR。

必需输出：

- `02-design.md`；
- 需要时输出 `decisions/ADR-*.md`。

禁止动作：

- 实现解决方案；
- 绕过 Reviewer 或 Human Gate；
- 把设计偏好当作 approval。

### Developer（开发者）

职责：

- 实现有边界的修改；
- 对 testable behavior changes 执行严格 Red-Green-Refactor；
- 在可行时运行相关本地验证；
- 修复 workflow 分配的结构化问题；
- 记录 implementation notes 和 known limitations。

必需输出：

- code diff；
- `05-implementation.md`；
- Red evidence、Green evidence、Refactor evidence，或具名 Human Gate 例外与替代反馈；
- test command and result 或 not-verified reason；
- Harness execution report。

禁止动作：

- 不更新 requirements 就改变 scope；
- 没有 design 或 ADR approval 就改变 architecture；
- 批准最终完成；
- 隐藏 skipped verification。

### Tester（测试者）

职责：

- 设计并执行验证；
- 记录 coverage、environment、command、result 和 defects；
- 分类 verification status。

必需输出：

- `04-test-plan.md`；
- `06-test-report.md`；
- 如果验证失败，输出 structured defect list。

禁止动作：

- 修复 implementation code；
- 批准 architecture 或 code quality；
- 没有可复现证据就报告 pass。

### Reviewer（审查者）

职责：

- review code、architecture fit、maintainability、security 和 risk；
- 按 severity 分类 findings；
- 决定 changes 是 approved、approved with minor notes、changes requested 还是 blocked。

必需输出：

- `07-review-report.md`；
- 带 evidence 的 structured findings；
- decision 和 residual risk。

禁止动作：

- 替代 Tester verification；
- 进行大范围 rewrite；
- 在 blocker 或 major issues 未解决时批准。

### Researcher（研究者）

职责：

- 收集并比较选项；
- 识别 evidence、constraints、tradeoffs 和 open questions；
- 向 Architect 或 Human review 推荐路径。

必需输出：

- research report；
- options comparison；
- recommendation；
- open questions。

禁止动作：

- 做最终架构决策；
- 开始实现；
- 批准交付。

## 11. Spec Template 契约

Skill 应为每个任务 artifact 提供简洁模板。

### `00-brief.md`

必需字段：

```yaml
task_id:
requested_by:
date:
goal:
background:
constraints:
initial_risks:
workflow_hint:
selected_workflow:
selection_reason:
```

### `01-requirements.md`

必需字段：

```yaml
status:
goal:
scope:
non_goals:
users_or_stakeholders:
acceptance_criteria:
constraints:
open_questions:
human_decisions:
```

### `02-design.md`

必需字段：

```yaml
status:
problem:
chosen_approach:
alternatives_considered:
architecture_constraints:
affected_components:
data_or_control_flow:
risks:
required_adrs:
human_decisions:
```

### `03-tasks.md`

必需字段：

```yaml
status:
task_class:
selected_workflow:
tasks:
dependencies:
target_files:
forbidden_actions:
acceptance_mapping:
verification_plan:
red_green_refactor_plan:
```

### `04-test-plan.md`

必需字段：

```yaml
status:
scope:
test_strategy:
test_commands:
test_data:
environment:
coverage_targets:
risks:
```

### `05-implementation.md`

必需字段：

```yaml
status:
changed_files:
rationale:
implementation_notes:
red_evidence:
green_evidence:
refactor_evidence:
tdd_exception:
substitute_feedback:
test_commands:
test_results:
known_limitations:
follow_up_needed:
```

### `06-test-report.md`

必需字段：

```yaml
status:
verification_status:
commands_run:
environment:
results:
coverage_scope:
defects:
skipped_checks:
residual_risk:
recommendation:
```

### `07-review-report.md`

必需字段：

```yaml
status:
review_scope:
evidence_reviewed:
findings:
blockers:
major_issues:
minor_notes:
security_notes:
architecture_notes:
decision:
residual_risk:
```

允许的 decisions：

```text
approved
approved_with_minor_notes
changes_requested
blocked
```

### `08-acceptance.md`

必需字段：

```yaml
status:
accepted_by_human:
accepted_at:
accepted_scope:
evidence_reviewed:
human_gate_decisions:
residual_risk_accepted:
merge_or_release_decision:
follow_up:
```

## 12. Quality Gate 契约

每个 gate 必须定义 required inputs、required outputs、pass condition、fail condition、evidence fields、human override rules 和 escalation。

| Gate | 名称 | 通过条件 |
|---|---|---|
| `G1` | requirements accepted | scope、non-goals、constraints 和 acceptance criteria 已批准，或轻量工作明确接受 |
| `G2` | design accepted when required | high-risk 或 architecture-sensitive task 有 design 或 ADR approval |
| `G3` | task executable | tasks 包含 inputs、outputs、target files、acceptance mapping、verification plan 和 forbidden actions |
| `G4` | test evidence complete and reproducible | verification status 是 `verified`，或具名 Human Gate 接受不完整验证 |
| `G5` | review has no unresolved blocker or major issue | G4 已通过或由 Human Gate override，且 Reviewer decision 是 `approved` 或 `approved_with_minor_notes` |
| `G6` | human accepts result | named Human 已接受最终输出和剩余风险 |

Verification status 必须是：

```text
verified
partially_verified
not_verified
blocked_by_environment
```

任何非 `verified` 状态都必须记录 gap、residual risk、recommended follow-up，以及是否允许 Human acceptance。没有具名 Human Gate override 时，它不能通过 G4。

## 13. Human Gate 契约

Human Gate type 必须显式记录。

| 类型 | 含义 | 典型用途 |
|---|---|---|
| `approval_required` | 没有明确批准就不能继续 | merge, release, production, secret access, database write, CI workflow change, destructive operation |
| `review_required` | 关键方向锁定前需要 human review | architecture, security, high-risk refactor |
| `info_required` | 缺失信息阻塞正确执行 | ambiguous requirement, unclear acceptance criterion, conflicting business rule |
| `notify_only` | 通知 human，但 workflow 不阻塞 | low-risk retry, status update, non-critical environment issue |

Human decisions 必须写入 requirements、design、ADR 或 acceptance artifacts。不要把 Supervisor、Harness、Developer、Tester、Reviewer 或未指定 agent 记录为 Human decision owner。

## 14. Workflow 覆盖范围

第一版 Skill 应定义这些 workflows：

- `feature-dev`：从 requirements 到 acceptance 的完整路径。
- `bugfix`：复现或刻画 defect、实现 fix、验证 regression。
- `code-review`：review existing diff，并产出 structured findings。
- `refactor`：保持行为不变，并要求明确 verification strategy。
- `research-spike`：产出 evidence-backed recommendation，不实现。
- `incident-fix`：triage、minimal patch、smoke test、emergency approval、post-incident backfill。

`release` 可以在 plugin-owned references 中作为 placeholder workflow 存在，但详细 release automation 应延后。

## 15. 延后主题

以下主题不应阻塞 Plugin 编制：

- 超出 Markdown 或简单结构块的 Workflow DSL。
- LangGraph 或 Microsoft Agent Framework 原型。
- Codex CLI、Claude Code 或 OpenHands 的深度 adapter design。
- Enterprise RBAC、SSO、audit dashboard 或 cost control。
- 自动 issue 或 PR listeners。
- 自动 release execution。

这些主题应在 Dev Cadence 用于真实任务，并且 plugin-owned rules、thin repo-local contract 和 adapter model 稳定后再回看。

## 16. Plugin 编制前的待决问题

这些决策可以在起草 `dev-cadence` 发布包时确定：

1. `release` 应作为最小 workflow 纳入，还是只作为 future work 引用。
2. `Researcher` 应作为 plugin-owned references 中的默认 Worker blueprint，还是只在启用 `research-spike` 时加载。
3. 是否需要为外部 adapter 建立 registry，还是先只保留简单配置扩展点。
4. Templates 应使用纯 Markdown headings、YAML-frontmatter 加 Markdown body，还是 YAML-like field blocks。
5. 哪个真实任务应作为第一次 validation run。
