# 07-review-report.md

## 目的

`07-review-report.md` 记录 spec compliance review、code quality findings、security 或 architecture notes、residual risk、decision 和 G5 Review 状态。

## 写入阶段

`review`。

## 写入者

Reviewer。

## 必要输入

- diff summary
- [05-implementation.md](05-implementation.md)
- [06-test-report.md](06-test-report.md)
- 存在时读取 [02-design.md](02-design.md) 或 ADR
- relevant code

## 记录内容

- review scope
- evidence reviewed
- scope reconciliation 和 verification coverage checks
- findings by severity
- blockers 和 major issues
- minor notes
- security 和 architecture notes
- review decision
- residual risk
- Gate G5 record

## Gate 影响

只有 G4 已通过或由具名 Human Gate override、scope reconciliation 完成，并且 Reviewer decision 是 `approved` 或 `approved_with_minor_notes` 时，G5 才能通过。

## 如何阅读

Findings 应放在最前面。阅读它可以知道变更已批准、需要修复，还是处于 blocked。

## 模板来源

- [templates/spec/07-review-report.md](../../templates/spec/07-review-report.md)
- [references/spec-templates.md](../../references/spec-templates.md)
