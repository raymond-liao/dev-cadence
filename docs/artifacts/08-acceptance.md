# 08-acceptance.md

## 目的

`08-acceptance.md` 记录具名 Human acceptance、accepted scope、evidence reviewed、residual risk accepted、merge 或 release decision、follow-up 和 G6 Human acceptance 状态。

## 写入阶段

`acceptance`。

## 写入者

Human decision 由 Supervisor 记录。decision owner 必须是具名 Human。

## 必要输入

- 所有 required task artifacts
- [Harness 运行证据](../runs/)
- verification status
- review decision
- blockers、skipped checks 和 residual risk

## 记录内容

- `accepted_by_human`
- `accepted_at`
- accepted scope
- evidence reviewed
- Human Gate decisions
- residual risk accepted
- merge or release decision
- follow-up
- Gate G6 record

## Gate 影响

除非 final acceptance 命名 Human accepter 并记录 accepted residual risk，否则 G6 保持 blocked。

## 如何阅读

阅读它可以确认任务是否真的被接受。commit request 或 agent completion claim 不能替代这个 artifact。
