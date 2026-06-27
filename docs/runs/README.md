# Dev Cadence Runs

本文说明 `specs/{task_id}/runs/{run_id}/` 下的 Harness 运行证据。运行时模板见 [templates/runs/](../../templates/runs/) 和 [references/spec-templates.md](../../references/spec-templates.md)。

Runs 记录一次 Worker 或 adapter execution 的上下文、工具使用、命令、diff、验证和权限决策。它们是执行级证据，和 [task artifacts](../artifacts/) 一起支撑 Quality Gates、Review 和 Human acceptance。

## Runs 目录

| 运行证据 | 说明 |
|---|---|
| [`run-context.md`](01-run-context.md) | 本次执行的 role、输入 artifact、允许路径、工具、预算和约束 |
| [`pre-implementation-status.md`](02-pre-implementation-status.md) | S1/S2 implementation 或 fix 前的 worktree baseline 和授权状态 |
| [`execution-report.md`](03-execution-report.md) | 执行摘要、状态、变更文件、跳过检查、风险和交接说明 |
| [`tool-log.md`](04-tool-log.md) | 工具调用、命令和关键日志索引 |
| [`test-log.md`](05-test-log.md) | 测试/验证命令、环境、输出摘要和结果 |
| [`diff-summary.md`](06-diff-summary.md) | 文件变更、行为变化、风险区域和回滚提示 |
| [`permission-decisions.md`](07-permission-decisions.md) | 高风险操作的审批请求、决策人、时间和理由 |

## 默认目录结构

```text
specs/{task_id}/runs/{run_id}/
  run-context.md
  pre-implementation-status.md
  execution-report.md
  tool-log.md
  test-log.md
  diff-summary.md
  permission-decisions.md
```

## Gate 影响

缺少 required Harness 运行证据会阻塞 G4 和 G5。对 S1/S2 implementation 或 fix runs，缺少或 post-hoc 的 `pre-implementation-status.md` 需要具名 Human override，review 或 acceptance 才能通过。
