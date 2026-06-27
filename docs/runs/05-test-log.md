# test-log.md

## 目的

`test-log.md` 记录测试或验证命令、环境、输出摘要和结果。

## 写入阶段

Run 中执行测试、验证命令或相关检查时。

## 写入者

Harness，包含 Tester 或 Developer via Harness 的验证输出。

## 记录内容

- commands
- environment
- output summary
- result
- failures
- skipped checks

## Gate 影响

`test-log.md` 支撑 [06-test-report.md](../artifacts/06-test-report.md) 和 G4 Verification。只有测试报告没有命令证据时，G4 可能保持 blocked。

## 如何阅读

确认命令、环境和结果是否足以支持 [06-test-report.md](../artifacts/06-test-report.md) 中的 verification status。

## 模板来源

- [templates/runs/test-log.md](../../templates/runs/test-log.md)
- [references/spec-templates.md](../../references/spec-templates.md)
