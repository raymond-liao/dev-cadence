# Plugin Skill 模块化

## 目标

本文记录 `dev-cadence` 在调整 Skill 包结构之前的目标架构。

目标是让框架更容易演进，也更容易与其他 Codex Skill 组合使用，同时避免在每个目标仓库里生成大段重复规则。

当前剩余工作的稳定路线图见 [Dev Cadence 路线图](dev-cadence-roadmap.md)。后续执行状态以路线图为准，本文只记录目标架构。

## 核心决策

```text
dev-cadence plugin
  -> 持有可复用 workflow rules、gates、templates 和 adapters
  -> 安装薄 repo-local entrypoint、project config 和 artifact space
```

仓库里的任务产物仍然是持久证据。通用框架规则放在 Plugin 里，不复制到每个目标仓库。

## 为什么不把每个工作流步骤都拆成 Skill

不要为 `requirements-gate`、`planning`、`harness-run`、`test-verification`、`review`、`human-gate` 这类内部状态分别创建 Codex Skill。

这些是 Supervisor 状态和框架内部模块，不是用户直接请求的能力。拆成很多小 Skill 会带来：

- 触发噪声；
- 多个 Skill 同时匹配时职责不清；
- 更多版本兼容成本；
- 重复加载上下文；
- gate 语义更难统一治理。

采用下面的规则：

```text
Skill 边界跟随用户意图。
Reference 边界跟随 workflow 内部结构。
Template 边界跟随 artifact 类型。
Adapter 边界跟随可替换执行纪律。
```

## 推荐 Skill 集合

先提供少量面向用户意图的 Skill。

```text
dev-cadence-init
  使用薄入口、配置和 artifact 目录初始化仓库。

dev-cadence-deliver
  执行普通交付工作：feature、bugfix、refactor、review、research spike 和 incident handling。

dev-cadence-maintain
  检查、同步、修复、诊断或升级仓库本地 Dev Cadence 配置。

dev-cadence-authoring
  可选。维护本框架及其 Plugin package。
```

具体名称可以在实现时调整。重点是：Skill 是粗粒度入口，不是每个工作流状态。

## Plugin 持有的资源

Plugin 应持有可复用的流程材料：

```text
references/
  principles.md
  supervisor-state-machine.md
  task-classes.md
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
  agent-blueprints.md
  adapters.md
  skill-layout.md

templates/
  spec/
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
    run-context.md
    execution-report.md
    tool-log.md
    test-log.md
    diff-summary.md
    permission-decisions.md
  prompts/
    spec-document-reviewer.md
    plan-document-reviewer.md
    implementer.md
    spec-compliance-reviewer.md
    code-quality-reviewer.md
    code-reviewer.md

scripts/
  check-skill-package.mjs
  check-discipline-routes.mjs
  check-spec-artifacts.mjs
  visual-companion/
    start-server.sh
    stop-server.sh
    server.cjs
    helper.js
    frame-template.html
```

这些文件在相关入口 Skill 需要时加载。它们不应复制到目标仓库。

`delivery-disciplines.md` 是默认交付纪律的路由入口。它不承载所有细节，而是按状态加载细分 reference，例如意图澄清、planning、TDD、debugging、review、verification 和 Dev Cadence authoring。任务 artifact 模板放在 `templates/spec/`，Harness evidence 模板放在 `templates/runs/`，Worker 和 reviewer 的可复用提示词放在 `templates/prompts/`，由 Harness 在创建 artifact、记录 evidence 或调度具体 run 时使用。`scripts/check-skill-package.mjs`、`scripts/check-discipline-routes.mjs` 和 `scripts/check-spec-artifacts.mjs` 提供 package self-check，校验语言边界、入口 metadata、脚本语法、discipline route、artifact template、prompt template、bundled resource 和 task artifact 是否一致。

`visual-companion.md` 和 `scripts/visual-companion/` 提供可选浏览器视觉对齐能力，用于 mockup、diagram 和视觉方案对比。它帮助 Human 和 AI 对齐难以纯文字表达的需求，但不能成为 G1 的硬条件。缺少 Node、浏览器或可访问 URL 时，流程必须降级为 text-only clarification。

## 薄仓库契约

初始化目标仓库时，只创建最小持久契约：

```text
AGENTS.md
.gitignore

.ai/
  config.yaml
  local.yaml
  overrides/
    .gitkeep

specs/
  .gitkeep
```

`AGENTS.md` 应把交付工作路由到 `dev-cadence` Plugin。它不应包含完整框架。

`.ai/config.yaml` 保存项目默认配置，例如：

```yaml
dev_cadence:
  artifact_language: en
  specs_dir: specs
  implementation_discipline: default
  verification_discipline: default
  review_profile: normal
```

`.ai/local.yaml` 保存未提交的个人覆盖配置，并保持 Git 忽略。

`.ai/overrides/` 只用于更严格或项目特有的策略。它只能包含仓库特定规则，不能复制框架默认规则。

`.dev-cadence/visual-companion/` 只用于持久化 visual companion session，应加入 `.gitignore`，不作为框架 runtime authority。

`specs/{task_id}/` 仍然是任务产物、证据和验收记录的持久来源。

## 运行时权威

运行时规则按以下层级解析：

1. 当前用户请求和显式仓库指令。
2. 仓库本地 `AGENTS.md`、`.ai/config.yaml` 和 `.ai/overrides/**`。
3. `specs/{task_id}/` 下的任务产物。
4. Dev Cadence Plugin 的 references、templates、内置交付纪律和 adapters。
5. 被显式配置的外部 adapter。

Plugin 提供默认流程规则。Repo-local overlays 可以增加更严格或更项目化的约束，但不能削弱 named Human acceptance、证据要求或权限门禁等硬安全规则。

## 内置交付纪律与 Adapter 模型

Dev Cadence 默认内置一套严格交付纪律。Adapter 是未来替换某个 Worker 执行技术的扩展点，不是默认纪律的来源。

默认配置：

```yaml
dev_cadence:
  implementation_discipline: default
  verification_discipline: default
  review_profile: normal
```

`default` 表示使用 Dev Cadence 自己的内置规则：

- 实现前澄清意图、范围、非目标和验收标准；
- planning 必须拆成可执行小任务，包含具体文件、行为、验证命令和预期结果；
- testable behavior changes 默认执行严格 Red-Green-Refactor；
- bugfix 和 incident 先复现或刻画问题，再修复；
- review 先检查 spec compliance，再检查 code quality；
- completion claim 之前必须有验证证据；
- 只有在多个问题域彼此独立时才并行调度 Worker；
- 维护 Dev Cadence 自身 Skill 或 references 时，使用面向 Skill 行为的验证纪律。

Supervisor 和 Harness 仍由 Dev Cadence 拥有。Adapter 只控制某个 Worker 状态如何执行，不能改变 gate、证据、权限或最终验收语义。

这样 Dev Cadence 先拥有可独立运行的默认 workflow discipline，同时保留未来替换实现纪律的能力。

## Adapter 契约

每个 Worker adapter 都必须保留 Dev Cadence 的证据契约。

输入：

```yaml
task_id:
run_id:
agent_role:
current_state:
task_class:
goal:
acceptance_criteria:
non_goals:
target_files:
forbidden_actions:
verification_plan:
harness_run_context:
artifact_paths:
```

必须输出或可被捕获的证据：

```yaml
status:
changed_files:
commands_run:
test_or_verification_results:
skipped_checks:
residual_risk:
open_questions:
handoff_notes:
```

实现类 adapter 还要捕获：

```yaml
diff_summary:
test_first_evidence:
green_test_evidence:
refactor_notes:
```

Review 类 adapter 还要捕获：

```yaml
findings:
severity:
affected_locations:
decision:
required_fixes:
```

如果 adapter 无法提供必需证据，Dev Cadence 必须记录缺口；相关 Quality Gate 保持 blocked，除非具名 Human 接受剩余风险。

## 冲突规则

当外部 adapter 被显式选中时，该 Worker 状态内采用兼容范围内更严格的规则。

示例：

- Dev Cadence 默认要求严格 Red-Green-Refactor。没有先失败测试的生产代码不可接受，除非具名 Human 明确接受例外和剩余风险。
- 如果外部 adapter 提供更严格的测试、验证或 review 规则，采用更严格规则。
- Dev Cadence 仍控制 Human Gate、Quality Gate、Harness evidence、scope reconciliation 和 final acceptance。

Adapter 不能覆盖：

- final acceptance by a named Human；
- requirement readiness before product edits；
- permission gates for high-risk actions；
- required Harness evidence；
- scope reconciliation before review and acceptance。

## 实施计划

1. 记录 plugin-owned rule model 和 adapter contract。
2. 增加 `delivery-disciplines.md`、细分 discipline references、Worker/reviewer prompt templates、`adapters.md` 和 thin repo contract references。
3. 实现 `dev-cadence-init`，只生成 thin repo-local contract。
4. 实现 `dev-cadence-deliver`，在运行时加载 plugin-owned references。
5. 在真实任务中验证默认交付纪律，再决定是否接入外部 adapter。

## 待决问题

- Adapter 选择只放在 `.ai/config.yaml`，还是允许用户按任务选择？
- Plugin-owned rules 是否需要支持在仓库中显式 pin 版本？
- Harness evidence 有多少可以由脚本自动生成，有多少需要 agent 写入？
- 外部 adapter 应只用简单 ID 命名，还是建立结构化 adapter registry？
