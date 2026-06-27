# 04-test-plan.md

## 目的

`04-test-plan.md` 记录 verification strategy、test commands、environment、coverage targets、skipped checks 和 risks。

## 写入阶段

`planning` 或 `test`，取决于任务流程。

## 写入者

Planner 或 Tester。

## 必要输入

- [01-requirements.md](01-requirements.md)
- [03-tasks.md](03-tasks.md)
- changed components 或 planned target files

## 记录内容

- test strategy
- commands 和 expected evidence
- test data 和 environment
- coverage targets
- changed-component coverage
- skipped component checks
- risks

## Gate 影响

这个 artifact 通过定义验证方式支撑 G3 和 G4，确保 changed surfaces 有对应 verification。

## 如何阅读

阅读它可以知道 review 或 acceptance 前应该完成哪些验证。

## 模板来源

- [templates/spec/04-test-plan.md](../../templates/spec/04-test-plan.md)
- [references/spec-templates.md](../../references/spec-templates.md)
