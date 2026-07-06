# Dev Cadence Runs

Runs 记录一次 Worker 或 adapter 执行留下的证据：它拿到了什么上下文、允许做什么、运行了哪些命令、测试结果是什么、改了哪些文件，以及是否发生过权限决策。它们不是任务默认摘要；任务主线仍看 `specs/records/{task_id}/` 下的 task artifacts。Run evidence 是下钻用的 execution provenance / evidence exhibits，必须能让 Human、Reviewer、Verifier 直接看懂执行边界和实际动作。

当你需要判断某次实现、验证或 Review 是否可信时，看 `specs/records/{task_id}/runs/{run_id}/`。任务主线的需求、计划、实现说明和验收记录在 [task artifacts](../artifacts/) 中；[G4 Verification](../gates/g4-verification.md) 和 [G5 Review](../gates/g5-review.md) 会读取这些 run evidence。

## Runs 目录

| 运行证据 | 说明 |
|---|---|
| [`run-context.md`](01-run-context.md) | 本次执行的 role、输入 artifact、允许路径、Git lifecycle context、工具、预算和约束 |
| [`pre-implementation-status.md`](02-pre-implementation-status.md) | S1/S2 implementation 或 fix 前的 worktree/base revision baseline、dirty preflight 和授权状态 |
| [`execution-report.md`](03-execution-report.md) | 执行摘要、状态、变更文件、Git activity、跳过检查、风险和交接说明 |
| [`tool-log.md`](04-tool-log.md) | 工具调用、命令和关键日志索引 |
| [`test-log.md`](05-test-log.md) | 测试/验证命令、环境、输出摘要和结果 |
| [`diff-summary.md`](06-diff-summary.md) | 文件变更、checkpoint/review range 证据、行为变化、风险区域和回滚提示 |
| [`permission-decisions.md`](07-permission-decisions.md) | 高风险或 Git lifecycle 操作的审批请求、动作分类、决策人/owner、时间和理由 |

生成这些 run evidence 时，使用 [templates/runs/](../../templates/runs/) 下的同名模板；模板契约见 [spec-templates.md](../../references/spec-templates.md)，Harness 运行边界见 [harness.md](../../references/harness.md)。Run templates 使用 Markdown/schema-lite：用稳定 labels、tables、checklists 和 command/log blocks 保留 checker-critical 字段，但不要退回整篇 fenced YAML schema stub。

## 默认目录结构

```text
specs/records/{task_id}/runs/{run_id}/
  run-context.md
  pre-implementation-status.md
  execution-report.md
  tool-log.md
  test-log.md
  diff-summary.md
  permission-decisions.md
```

## Gate 影响

缺少 required Harness 运行证据会阻塞 G4 和 G5。对 S1/S2 implementation 或 fix runs，缺少或 post-hoc 的 `pre-implementation-status.md` 需要具名 Human override，review 或 acceptance 才能通过。Checkpoint commit 只记录实现/修复切片证据，不代表 G5/G6、最终验收、merge、push、release 或 done；最终 merge/push/release 仍必须在 G6 后由 Supervisor/controller 或具名 Human-authorized owner 执行。
