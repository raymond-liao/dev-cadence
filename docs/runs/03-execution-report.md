# execution-report.md

## 目的

`execution-report.md` 记录一次 run 的执行摘要、状态、变更文件、跳过检查、风险和交接说明。

## 写入阶段

Harness run 结束时。

## 写入者

Harness 汇总 Worker output 和执行结果。

## 记录内容

- stable labels: `Run ID`、`Task ID`、`Agent role`、`Status`、start/end time
- `What happened`: inputs and outputs
- `Files changed`: planned/actual/unplanned/deleted files and scope reconciliation status
- authorization baseline: pre-implementation status path, implementation authorization, post-hoc flag
- verification run: commands/tests and verification status
- git activity: commit intent、allowed git actions used、checkpoint parent/message/commit/range、finalization actions performed、forbidden finalization actions confirmed not performed；non-branch runs record `N/A`/`none` rather than invented Git activity
- permission activity, skipped checks, errors/blockers, residual risk
- handoff target

## Gate 影响

`execution-report.md` 是 run 级摘要，但不能替代 `tool-log.md`、`test-log.md`、`diff-summary.md`、`permission-decisions.md` 或 `pre-implementation-status.md`。

## 如何阅读

先看 `What happened`、`Files changed`、`Verification run` 和 `Git activity`，确认本次实际做了什么、有没有越界、验证是否足够，以及是否只执行了授权 Git 动作或明确没有 branch-based Git activity。Checkpoint activity 不是 finalization；merge/push/release/delete branch/remove worktree 必须有单独授权和证据。再跟随证据路径检查 tool/test/diff/permission 记录。
