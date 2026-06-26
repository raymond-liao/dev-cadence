# Dev Cadence 框架概览

本文是 Dev Cadence 当前框架的短入口。角色、工作流和 artifact 细节分别拆到 [architecture.md](architecture.md)、[workflows.md](workflows.md) 和 [artifacts.md](artifacts.md)；当前 Codex Plugin 的模块边界、发布资源清单和 thin repo-local contract 以 [Plugin Skill 模块化](plugin-skill-modularization.md) 为准。

## 核心定位

Dev Cadence 是一套面向 coding agents 的 AI-native 软件交付协作框架。它不是某个业务项目模板，也不是单一 coding agent prompt，而是一套让 Human、Supervisor、Harness 和 Worker Agents 通过 artifact、证据和 gate 协作的软件交付节奏。

推荐模型：

```text
Supervisor-Controlled
Harness-Mediated
Artifact-First
Spec-Driven
Quality-Gated
Multi-Agent Development Framework
```

核心判断：

1. Agent 之间不直接辩论，只通过结构化产物交接。
2. Supervisor 控制流程、状态、预算和门禁，不亲自写代码。
3. Harness 约束上下文、工具、权限和证据采集。
4. Worker Agents 负责具体研发产物。
5. Chat 不是持久事实来源；spec、ADR、测试报告、Review 报告和 Harness evidence 才是事实来源。

## 角色边界

Dev Cadence 把角色分成四类：

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

`Supervisor`、`Harness`、`Quality Gate`、`Human Gate` 和 `Permission Policy` 不是普通 Worker Agent。这样可以避免让某个“全能 Agent”同时决定流程、执行命令、采集证据并宣布完成。

## 工作流

Dev Cadence 支持的核心 workflow 包括：

- `feature-dev`
- `bugfix`
- `code-review`
- `refactor`
- `research-spike`
- `incident-fix`
- `release`

用户不需要手动选择 workflow。Supervisor 根据请求、仓库状态和任务风险推断工作流，并在 artifact 中记录选择理由。

标准交付闭环：

```text
Human request
  -> clarify intent and scope
  -> requirements and design gate
  -> executable plan and test plan
  -> Harness-mediated implementation
  -> verification
  -> review
  -> Human acceptance
```

高风险、含糊需求、跨模块变更、权限敏感操作或用户验收缺失时，流程必须升级到 Human Gate，而不是让 Agent 自行放行。

## Artifacts

Dev Cadence 默认在目标仓库使用 `specs/{task_id}/` 保存任务事实、执行证据和验收记录：

```text
specs/{task_id}/
  00-brief.md
  01-requirements.md
  02-design.md
  03-tasks.md
  04-test-plan.md
  05-implementation.md
  06-test-report.md
  07-review-report.md
  08-acceptance.md
  runs/{run_id}/
    run-context.md
    execution-report.md
    tool-log.md
    test-log.md
    diff-summary.md
    permission-decisions.md
```

这些文件不是形式化负担，而是 Agent 之间的交接接口。缺少必要 artifact 或 evidence 时，Quality Gate 应保持 blocked，除非具名 Human 明确接受剩余风险。

模板定义见 [Spec Templates](../references/spec-templates.md)，实际模板位于 `templates/spec/` 和 `templates/runs/`。

## Context 与事实源

运行时规则优先级：

1. 当前用户请求和显式仓库指令。
2. 仓库本地 `AGENTS.md` 和 `.dev-cadence.yaml`。
3. 当前任务 artifacts：`specs/{task_id}/**`。
4. `dev-cadence` 的 references、templates、内置交付纪律和 adapter。
5. 被显式配置的外部 adapter。

冲突处理原则：

- 更具体的任务 artifact 优先于通用框架说明。
- Repo-local overlays 可以更严格，但不能削弱 Human acceptance、Quality Gate、权限审批或 Harness evidence。
- 聊天记录不能覆盖稳定 artifact；规则变化必须写回对应文档或模板。

## Quality Gate 与 Human Gate

最小质量门禁：

- G1 Requirements readiness：目标、范围、非目标、验收标准和验证方式清楚。
- G2 Design readiness：设计能解释关键行为、风险和取舍。
- G3 Plan readiness：任务可执行，含文件、行为、验证命令和预期结果。
- G4 Verification：测试、检查或人工验证有证据。
- G5 Review：spec compliance 和 code quality 已检查。
- G6 Human acceptance：具名 Human 接受结果或剩余风险。

Human Gate 负责目标、风险、权限、合并、发布和最终验收。Agent 不能代替 Human 接受需求变更、高风险权限、跳过验证、发布操作或最终交付风险。

## Codex Plugin 发布形态

当前 `dev-cadence` Codex Plugin 采用 root-level source layout：

```text
.codex-plugin/
skills/
references/
templates/
scripts/
```

发布内容分工：

- `skills/`：Codex Skill 入口和工作纪律入口。
- `references/`：运行时规则、gate、workflow、Harness、adapter 和 discipline。
- `templates/`：task artifact、Harness evidence 和 Worker prompt 模板。
- `scripts/`：package、检查、artifact 初始化、repo contract 同步和 optional visual companion 工具。

完整模块边界见 [Plugin Skill 模块化](plugin-skill-modularization.md)，安装命令见 [Dev Cadence 安装](installation.md)，验证命令见 [Dev Cadence 当前验证](validation.md)。

## 演进方向

Dev Cadence Core 应保持平台无关。Codex Plugin 是当前优先落地形态，不是最终平台形态的全部。后续可以在真实任务验证稳定后演进为：

```text
Codex Plugin publishing target
  -> Thin repo-local contract + specs
  -> Protocol Harness
  -> Workflow Automation
  -> Agent Orchestration Platform
  -> Enterprise Control Plane
```

平台化准入条件包括：真实任务覆盖足够、gate 规则趋稳、Harness evidence 可审计、权限审批清楚、团队确认流程收益大于流程负担。

## 相关文档

| 文档 | 作用 |
|---|---|
| [architecture.md](architecture.md) | 角色、分层、Harness、Context 和工具边界 |
| [workflows.md](workflows.md) | Workflow、任务分级、loop、Quality Gate 和 Human Gate |
| [artifacts.md](artifacts.md) | `specs/`、task artifacts、Harness evidence 和事实源规则 |
| [plugin-skill-modularization.md](plugin-skill-modularization.md) | 当前 Codex Plugin 模块边界 |
| [installation.md](installation.md) | 当前安装、更新和卸载命令 |
| [validation.md](validation.md) | 当前验证、发布包生成和 smoke test 命令 |
| [archive/](archive/) | 历史计划、验收和研究记录 |
| [../references/skill-layout.md](../references/skill-layout.md) | 发布包布局和版本规则 |
| [../references/workflows.md](../references/workflows.md) | Workflow 运行规则 |
| [../references/quality-gates.md](../references/quality-gates.md) | Quality Gate 规则 |
| [../references/human-gates.md](../references/human-gates.md) | Human Gate 规则 |
