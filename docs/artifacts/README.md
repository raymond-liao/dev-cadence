# Dev Cadence 产物

本文说明 Dev Cadence 的任务产物、Harness 运行证据、thin repo-local contract 和事实源规则。模板细节见 [Spec Templates](../../references/spec-templates.md)。

本目录是产物目录。每个 artifact 的单页说明回答“它什么时候产生、谁写、记录什么、影响哪个 gate、如何阅读”。

## 产物目录

| 产物 | 说明 |
|---|---|
| [`00-brief.md`](00-brief.md) | 用户请求、目标、背景、初始分类和非目标 |
| [`01-requirements.md`](01-requirements.md) | 范围、验收标准、约束、歧义和 G1 状态 |
| [`02-design.md`](02-design.md) | 方案、架构约束、风险、替代方案和 G2 状态 |
| [`03-tasks.md`](03-tasks.md) | 可执行任务、目标文件、顺序、forbidden actions 和 G3 状态 |
| [`04-test-plan.md`](04-test-plan.md) | 验证策略、命令、覆盖范围和预期证据 |
| [`05-implementation.md`](05-implementation.md) | diff 摘要、实现说明、运行证据和已知限制 |
| [`06-test-report.md`](06-test-report.md) | 测试命令、结果、覆盖范围、失败或跳过原因和 G4 状态 |
| [`07-review-report.md`](07-review-report.md) | spec compliance、code quality findings 和 G5 状态 |
| [`08-acceptance.md`](08-acceptance.md) | 具名 Human acceptance、剩余风险和 G6 状态 |
| [Runs](../runs/) | `runs/{run_id}/` 下的 Harness 执行证据 |

## Artifact-First 原则

Dev Cadence 不把聊天记录当作持久事实来源。需求、设计、计划、实现、验证、Review 和验收必须沉淀为 artifact，供后续 Agent、Reviewer 和 Human 读取。

Artifact 的作用：

- 固化当前任务事实，减少上下文漂移。
- 让 Worker Agent 之间通过文件交接，而不是通过自由聊天交接。
- 让 Quality Gate 和 Human Gate 有可审查依据。
- 为后续复盘、回滚、审计和维护提供证据。

## Thin Repo-Local Contract

在目标业务仓库中启用 Dev Cadence 时，默认只生成薄契约：

```text
AGENTS.md
.gitignore
.dev-cadence.yaml

specs/
  .gitkeep
```

`AGENTS.md` 是仓库级入口，用于把 Codex 中的交付工作路由到 `dev-cadence`。它不应复制完整框架。

`.dev-cadence.yaml` 保存用户本地偏好，默认加入 `.gitignore`。默认规则、模板和交付纪律由 `dev-cadence` plugin 持有，不复制到目标仓库。

`specs/` 保存每个任务的过程产物、执行证据和验收记录。

## Task Artifact 布局

默认任务目录：

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
  runs/
    {run_id}/
      run-context.md
      pre-implementation-status.md
      execution-report.md
      tool-log.md
      test-log.md
      diff-summary.md
      permission-decisions.md
  decisions/
    ADR-001.md
```

这些文件是默认交接接口。任务可以根据风险跳过部分阶段，但必须在 artifact 中记录跳过原因、剩余风险和 Human decision。

## 核心 Artifacts

| Artifact | 作用 |
|---|---|
| `00-brief.md` | 记录用户请求、目标、上下文、初始分类和非目标 |
| `01-requirements.md` | 记录范围、验收标准、约束、歧义和 G1 状态 |
| `02-design.md` | 记录方案、架构约束、风险、替代方案和 G2 状态 |
| `03-tasks.md` | 记录可执行任务、目标文件、顺序、forbidden actions 和 G3 状态 |
| `04-test-plan.md` | 记录验证策略、命令、覆盖范围和预期证据 |
| `05-implementation.md` | 记录 diff 摘要、实现说明、运行证据和已知限制 |
| `06-test-report.md` | 记录测试命令、结果、覆盖范围、失败或跳过原因和 G4 状态 |
| `07-review-report.md` | 记录 spec compliance、code quality findings 和 G5 状态 |
| `08-acceptance.md` | 记录具名 Human acceptance、剩余风险和 G6 状态 |

ADR 用于记录影响长期架构或高风险行为的决策。ADR 不是每个任务都必须有，但 S2/high-risk 任务通常需要。

## Harness 运行证据

每次 Worker 或 adapter 执行都应有独立 run 目录：

```text
specs/{task_id}/runs/{run_id}/
```

Run 运行证据包括：

| Evidence | 作用 |
|---|---|
| `run-context.md` | 本次执行的 role、输入 artifact、允许路径、工具、预算和约束 |
| `pre-implementation-status.md` | S1/S2 实现或修复前的 worktree 基线、授权范围和 gate 状态 |
| `execution-report.md` | 执行摘要、状态、变更文件、跳过检查、风险和交接说明 |
| `tool-log.md` | 工具调用、命令和关键日志索引 |
| `test-log.md` | 测试/验证命令、环境、输出摘要和结果 |
| `diff-summary.md` | 文件变更、行为变化、风险区域和回滚提示 |
| `permission-decisions.md` | 高风险操作的审批请求、决策人、时间和理由 |

`execution-report.md` 的摘要不能替代 `pre-implementation-status.md`、`tool-log.md`、`test-log.md`、`diff-summary.md` 或 `permission-decisions.md`。S1/S2 的实现或修复工作必须在修改产品文件、测试、构建脚本、部署配置或应用配置之前记录 `pre-implementation-status.md`。缺少必要证据时，Quality Gate 应保持 blocked，除非具名 Human 明确接受剩余风险。

这些文件的逐项说明见 [docs/runs/](../runs/)。

## Specs HTML 报告

可以从现有 `specs/` artifact 生成一个静态 HTML 浏览视图：

```bash
node scripts/generate-spec-report.mjs --specs-dir specs
```

默认生成文件：

```text
specs/
  index.html
  .dev-cadence-report/
    style.css
  {task_id}/
    index.html
    runs/
      {run_id}/
        index.html
```

`specs/index.html` 使用类似 JaCoCo 的紧凑 summary 表格，包含任务、状态、门禁、问题、运行和更新时间列；有 gate failure、非 G6 待验收 warning、blocked 或 unknown 的任务整行用红色背景提示。纯 `pending acceptance` 只显示黄色状态 badge，不作为红色问题行。`specs/{task_id}/index.html` 显示单个任务的门禁汇总、artifact 链接、run 链接和 open issue 明细；`runs/{run_id}/index.html` 显示 Harness 运行证据详情。每个 Markdown artifact 还会生成对应 `.html` 详情页，顶部保留 JaCoCo 风格面包屑，并提供原始 Markdown 链接回原始文件。

HTML report 是派生浏览视图，不是事实源。Gate、review、acceptance 和提交前检查仍以 Markdown/YAML artifact 为准；生成报告不能替代 `check-gates.mjs`、`check-before-commit.mjs` 或具名 Human acceptance。

## Artifact 语言

`.dev-cadence.yaml` 可覆盖任务 artifact 的自然语言正文：

```yaml
dev_cadence:
  artifact_language: en
  specs_dir: specs
  implementation_discipline: default
  verification_discipline: default
  review_profile: normal
```

`artifact_language` 支持 `en` 和 `zh`。它控制 spec、测试报告、review 报告等任务产物中的自然语言正文，也控制派生 HTML report 的 UI 文案；文件名、YAML 字段、状态枚举、workflow ID、gate ID 和原始 Markdown source view 保持英文或原样。

生成任务 artifact 或派生 report 的脚本必须读取 `.dev-cadence.yaml` 中的 `artifact_language`，不能只依赖 Agent 记忆或提交前 warning。`check-spec-artifacts.mjs --warnings-as-errors` 是防线，不是主要生成策略。

当 G6 尚未验收时，会话和 `check-before-commit.mjs` 输出必须说明用户要审批什么：目标、变更范围、验证状态、跳过的检查、review 结论、blocker、剩余风险、可查看证据，以及需要写入 `08-acceptance.md` 的字段。

## 模板来源

模板由 plugin 持有：

```text
templates/spec/
templates/runs/
templates/prompts/
```

`templates/spec/` 保存任务 artifact 模板，`templates/runs/` 保存 Harness 运行证据模板，`templates/prompts/` 保存 Worker 和 reviewer prompt 模板。目标仓库不应复制这些通用模板，只保存由具体任务生成的 artifact。

模板契约说明见 [Spec Templates](../../references/spec-templates.md)。初始化和 dry run 脚本见 `scripts/init-task-artifacts.mjs` 和 `scripts/run-delivery-dry-run.mjs`。

## 事实源与冲突

推荐优先级：

| Priority | Source | 说明 |
|---:|---|---|
| 1 | 当前代码、测试结果、CI 结果、实际运行日志 | 系统当前真实状态 |
| 2 | 已批准的 requirements、design、ADR、acceptance | 正式决策 |
| 3 | `specs/{task_id}/` 当前任务产物 | 当前任务上下文和交接状态 |
| 4 | README、runbook、历史 ADR、项目规则 | 项目长期规则 |
| 5 | issue、PR、聊天记录、临时讨论 | 线索，不是长期事实 |

冲突处理规则：

- 发现事实冲突时，标记 `context_conflict`。
- 如果冲突影响范围、架构、安全、权限、测试或验收，必须进入 Human Gate。
- Human 裁决必须写回正式产物。
- 长期记忆只能引用已确认产物，并保留来源、时间和决策人。

## 验证与提交前检查

维护 `dev-cadence` 自身文档、模板或脚本时，常用检查：

```bash
bash tests/run-all.sh
node scripts/check-spec-artifacts.mjs templates
node scripts/check-gates.mjs --task-id {task_id}
node scripts/check-before-commit.mjs --task-id {task_id}
node scripts/generate-spec-report.mjs --specs-dir specs
```

完整验证命令说明见 [Dev Cadence 当前验证](../validation.md)。文档类变更仍需人工检查 Markdown 渲染、链接、路径和术语一致性。
