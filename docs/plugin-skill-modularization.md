# Plugin Skill 模块化

## 目标

本文记录 `dev-cadence` 当前 Codex Plugin 的模块边界，以及它和目标仓库薄契约的关系。
> 状态提示：旧的四入口 Skill 方案和目标模型草案已归档到 [docs/archive/](archive/)。当前发布结构是 `using-dev-cadence` + `cadence-*` 工作纪律 Skills，旧的 `init/deliver/maintain/authoring` 不再作为主要 Skill 边界。

目标是让 Dev Cadence Core 保持平台无关，同时让 `dev-cadence` 当前 Codex Plugin 发布形态更容易演进、与其他 Codex Skill 组合使用，并避免在每个目标仓库里生成大段重复规则。

当前安装和卸载命令见 [Dev Cadence 安装](installation.md)，验证命令见 [Dev Cadence 当前验证](validation.md)。历史计划和完成状态见 [docs/archive/](archive/)。

本文是当前 Codex Plugin 模块边界的维护者权威。`docs/framework.md` 只保留框架概念和长期演进解释；运行时可加载或调用的稳定材料以 `skills/`、`references/`、`templates/` 和 `scripts/` 为准。

## 核心决策

```text
Dev Cadence Core
  -> 定义平台无关 workflow、roles、gates、Harness、artifacts 和 adapter contract

dev-cadence
  -> 跨运行时保持一致的项目 slug、包名和插件名
  -> 当前 Codex 发布形态持有可复用 workflow rules、gates、templates 和 adapters
  -> 安装薄 repo-local entrypoint、本地覆盖配置和 artifact space
```

仓库里的任务产物仍然是持久证据。Dev Cadence Core 规则通过 Codex Plugin 的 references、templates、scripts 和 adapters 在 Codex 中落地，不复制到每个目标仓库。后续其他 agent runtime 可以实现同一 Core contract，而不必继承 Codex Plugin 的目录和触发机制。

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

本文早期推荐过按 `init/deliver/maintain/authoring` 拆分入口 Skill。该方案已被当前 `using-dev-cadence` + `cadence-*` 发布结构取代，历史草案见 [docs/archive/dev-cadence-target-model.md](archive/dev-cadence-target-model.md)。

当前推荐模型是：

```text
using-dev-cadence
  Dev Cadence 入口 Skill 和任务路由。

cadence-clarify / cadence-plan / cadence-execute / cadence-tdd
cadence-debug / cadence-review / cadence-verify
  按 Agent 工作动作和交付纪律拆分。

cadence-sync
  初始化、检查、同步、修复或诊断 thin repo-local contract。
```

`Supervisor`、`Harness`、`Quality Gate`、`Human Gate`、artifact schema 和 task class policy 保持为 shared references，不作为用户 Skill 发布。`authoring` 不进入普通用户发布 Skill 集合。

## Codex Plugin 持有的资源

Codex Plugin 应持有 Dev Cadence Core 在 Codex 中运行所需的可复用流程材料：

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
  repository-rule-sync.md
  adapters.md
  skill-layout.md
  spec-templates.md

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
  package-codex-plugin.mjs
  check-skill-package.mjs
  check-discipline-routes.mjs
  check-spec-artifacts.mjs
  check-gates.mjs
  check-before-commit.mjs
  generate-spec-report.mjs
  init-task-artifacts.mjs
  run-delivery-dry-run.mjs
  summarize-acceptance.mjs
  sync-repo-contract.mjs
  visual-companion/
    start-server.sh
    stop-server.sh
    server.cjs
    helper.js
    frame-template.html
```

这些文件在相关入口 Skill 需要时加载。它们不应复制到目标仓库，也不应被理解为 Dev Cadence Core 只能在 Codex 中运行。

`delivery-disciplines.md` 是默认交付纪律的路由入口。它不承载所有细节，而是按状态加载细分 reference，例如意图澄清、planning、TDD、debugging、review、verification 和 Dev Cadence authoring。`spec-templates.md` 说明 task artifact 与 Harness evidence 模板结构；实际模板放在 `templates/spec/` 和 `templates/runs/`。Worker 和 reviewer 的可复用提示词放在 `templates/prompts/`，由 Harness 在创建 artifact、记录 evidence 或调度具体 run 时使用。`repository-rule-sync.md` 说明 thin repo-local contract 的初始化、检查、同步和修复规则。`scripts/check-skill-package.mjs`、`scripts/check-discipline-routes.mjs`、`scripts/check-spec-artifacts.mjs`、`scripts/check-gates.mjs` 和 `scripts/check-before-commit.mjs` 提供 `dev-cadence` source self-check，校验语言边界、入口 metadata、脚本语法、discipline route、artifact template、prompt template、gate state、bundled resource 和 task artifact 是否一致。`scripts/generate-spec-report.mjs` 从现有 task artifact 生成 co-located 静态 HTML 浏览视图，但不改变 Markdown/YAML 事实源。

`visual-companion.md` 和 `scripts/visual-companion/` 提供可选浏览器视觉对齐能力，用于 mockup、diagram 和视觉方案对比。它帮助 Human 和 AI 对齐难以纯文字表达的需求，但不能成为 G1 的硬条件。缺少 Node、浏览器或可访问 URL 时，流程必须降级为 text-only clarification。

业务仓库可以选择提交 repo-scoped marketplace 和 plugin payload，用于让团队成员从该业务仓库根目录执行 `codex plugin marketplace add .` 和 `codex plugin add dev-cadence@<marketplace-name>` 安装同一份插件。这是分发方式，不是 `cadence-sync` 默认写入的 thin repo-local contract；此时 `source.path` 必须从业务仓库根目录解析到实际 plugin payload，例如 `./.agents/plugins/dev-cadence`。

## 薄仓库契约

初始化目标仓库时，只创建最小持久契约：

```text
AGENTS.md
.gitignore
.dev-cadence.yaml

specs/
  .gitkeep
```

`AGENTS.md` 应把 Codex 中的交付工作路由到 `dev-cadence` Codex Plugin。它不应包含完整框架。

`.dev-cadence.yaml` 保存未提交的个人覆盖配置，并保持 Git 忽略。默认配置由 `dev-cadence` 持有，例如：

```yaml
dev_cadence:
  artifact_language: en
  specs_dir: specs
  implementation_discipline: default
  verification_discipline: default
  review_profile: normal
```

`.dev-cadence/visual-companion/` 只用于持久化 visual companion session，应加入 `.gitignore`，不作为框架 runtime authority。

`specs/{task_id}/` 仍然是任务产物、证据和验收记录的持久来源。

## 运行时权威

运行时规则按以下层级解析：

1. 当前用户请求和显式仓库指令。
2. 仓库本地 `AGENTS.md` 和 `.dev-cadence.yaml`。
3. `specs/{task_id}/` 下的任务产物。
4. `dev-cadence` 的 references、templates、内置交付纪律和 adapters。
5. 被显式配置的外部 adapter。

Codex Plugin 提供默认流程规则。Repo-local overlays 可以增加更严格或更项目化的约束，但不能削弱 Dev Cadence Core 定义的 named Human acceptance、证据要求或权限门禁等硬安全规则。

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

本文件中的早期实施计划已完成并归档。当前安装入口见 [Dev Cadence 安装](installation.md)，验证入口见 [Dev Cadence 当前验证](validation.md)，历史路线图和目标草案见 [docs/archive/](archive/)。
