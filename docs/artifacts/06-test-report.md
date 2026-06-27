# 06-test-report.md

## 目的

`06-test-report.md` 记录 verification commands、environment、results、coverage、defects、skipped checks、residual risk 和 G4 Verification 状态。

## 写入阶段

`test` 或 verification checkpoint。

## 写入者

Tester 或 Developer via Harness，取决于 workflow 和 task weight。

## 必要输入

- [04-test-plan.md](04-test-plan.md)
- [05-implementation.md](05-implementation.md)
- 实际 diff 或 changed component list
- test command output 或 manual verification 证据

## 记录内容

- verification status
- commands run
- environment
- results
- coverage scope 和 changed-component coverage
- defects
- skipped checks
- residual risk
- recommendation
- Gate G4 record

## Gate 影响

只有 verification 完整且可复现，或具名 Human Gate 接受不完整验证时，G4 才能通过。

## 如何阅读

阅读它可以判断实现是否有可信验证证据，以及还剩哪些缺口。

## 模板来源

- [templates/spec/06-test-report.md](../../templates/spec/06-test-report.md)
- [references/spec-templates.md](../../references/spec-templates.md)
