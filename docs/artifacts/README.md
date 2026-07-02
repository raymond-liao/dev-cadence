# Dev Cadence 产物

`specs/records/{task_id}/` 是一个任务的持久交接包：需求、设计、计划、实现说明、验证、Review 和最终验收都放在这里。后续 Agent、Reviewer 和 Human 应优先读这些文件，而不是依赖聊天记录。

如果要看某次执行的命令、测试、diff 或权限证据，进入 [runs](../runs/)；如果要看 G1-G6 如何使用这些产物，进入 [gates](../gates/)。

## 产物目录

每个 artifact 单页回答“什么时候产生、谁写、记录什么、影响哪个 gate、如何阅读”。

| 产物 | 说明 |
|---|---|
| [`00-brief.md`](00-brief.md) | 用户请求、目标、背景、初始分类和非目标 |
| [`01-requirements.md`](01-requirements.md) | 范围、验收标准、约束、歧义和 G1 状态 |
| [`02-design.md`](02-design.md) | 方案、架构约束、风险、替代方案和 G2 状态 |
| [`research-report.md`](research-report.md) | research spike 的证据、方案比较、建议和 open questions |
| [`03-tasks.md`](03-tasks.md) | 可执行任务、目标文件、顺序、forbidden actions 和 G3 状态 |
| [`04-test-plan.md`](04-test-plan.md) | 验证策略、命令、覆盖范围和预期证据 |
| [`05-implementation.md`](05-implementation.md) | diff 摘要、实现说明、运行证据和已知限制 |
| [`06-test-report.md`](06-test-report.md) | 测试命令、结果、覆盖范围、失败或跳过原因和 G4 状态 |
| [`07-review-report.md`](07-review-report.md) | spec compliance、code quality findings 和 G5 状态 |
| [`08-acceptance.md`](08-acceptance.md) | 具名 Human acceptance、剩余风险和 G6 状态 |
| [Runs](../runs/) | `runs/{run_id}/` 下的 Harness 执行证据 |

生成这些 task artifact 时，使用 [templates/spec/](../../templates/spec/) 下的同名模板；模板契约见 [spec-templates.md](../../references/spec-templates.md)。Spec artifacts 使用 Markdown-first 形态：稳定 headings、labels、tables 和 checklists 服务 Human review 与 checker 解析；fenced YAML 只保留给兼容旧记录或局部机器字段，不作为新 artifact 的主体。

## Artifact-First 原则

Dev Cadence 不把聊天记录当作持久事实来源。需求、设计、计划、实现、验证、Review 和验收必须沉淀为 artifact，供后续 Agent、Reviewer 和 Human 读取。

Artifact 的作用：

- 固化当前任务事实，减少上下文漂移。
- 让 Worker Agent 之间通过文件交接，而不是通过自由聊天交接。
- 让 Quality Gate 和 Human Gate 有可审查依据。
- 为后续复盘、回滚、审计和维护提供证据。

事实源优先级和冲突处理规则见 [../architecture.md#事实源优先级](../architecture.md#事实源优先级)。

## 默认任务布局

默认任务目录：

```text
specs/records/{task_id}/
  00-brief.md
  01-requirements.md
  02-design.md
  research-report.md
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

Run evidence 的逐项说明见 [../runs/](../runs/)；G1-G6 的检查含义见 [../gates/](../gates/)。

## 任务报告

可以从现有 `specs/records/` artifact 生成静态 HTML 浏览视图：

```bash
node scripts/generate-spec-report.mjs --specs-dir specs/records --report-dir specs/report
```

HTML report 输出到 `specs/report/`，用于浏览 task summary、gate summary、artifact 链接、run evidence 和 Markdown 详情页。它是派生视图，不是事实源；Gate、review、acceptance 和提交前检查仍以 `specs/records/` 下的 Markdown artifact 为准，旧 YAML-style 记录只作为兼容输入处理。

报告命令和输出文件说明见 [Dev Cadence 当前验证](../validation.md#生成-specs-html-report)。目标仓库契约包含 `.dev-cadence/` runtime、`AGENTS.md`、本地 `.dev-cadence.yaml` 偏好和 `specs/` artifact space；初始化与同步规则由 [Codex Plugin 模块边界](../codex-plugin-boundaries.md#target-repository-contract) 和 [repository-rule-sync.md](../../references/repository-rule-sync.md) 说明。

## 模板与语言

`.dev-cadence.yaml` 可通过 `dev_cadence.artifact_language` 覆盖任务 artifact 的自然语言正文，支持 `en` 和 `zh`。文件名、YAML 字段、状态枚举、workflow ID 和 gate ID 保持英文。

Task artifact 和 run evidence 模板由 plugin 持有；Skill 专属 prompt 放在 owning Skill 下，例如 `skills/cadence-request-code-review/`：

```text
templates/spec/
templates/runs/
skills/*/
```

生成任务 artifact 或派生 report 的脚本必须读取 `.dev-cadence.yaml`，不能只依赖 Agent 记忆；完整验证命令见 [Dev Cadence 当前验证](../validation.md)。
