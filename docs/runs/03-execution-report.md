# execution-report.md

## 目的

`execution-report.md` 记录一次 run 的执行摘要、状态、变更文件、跳过检查、风险和交接说明。

## 写入阶段

Harness run 结束时。

## 写入者

Harness 汇总 Worker output 和执行结果。

## 记录内容

- run status
- summary
- changed files
- skipped checks
- known limitations
- risks
- handoff notes
- verification status when applicable

## Gate 影响

`execution-report.md` 是 run 级摘要，但不能替代 `tool-log.md`、`test-log.md`、`diff-summary.md`、`permission-decisions.md` 或 `pre-implementation-status.md`。

## 如何阅读

先看 summary 和 status，再跟随链接或路径检查实际证据文件。
