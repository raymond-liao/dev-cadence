# G3 Plan Readiness

## 目的

G3 确保任务在修改产品文件前已经可执行且范围受控。

## 检查阶段

`planning` 之后、implementation 之前。

## 必要输入

- [01-requirements.md](../artifacts/01-requirements.md)
- 存在时读取 [02-design.md](../artifacts/02-design.md)
- [03-tasks.md](../artifacts/03-tasks.md)
- verification plan 和 target files

## 通过条件

[03-tasks.md](../artifacts/03-tasks.md) 包含 inputs、outputs、target files、acceptance mapping、verification plan、forbidden actions 和 task-class escalation rules。通常由 [Planner](../roles/agents/01-planner.md) 负责准备可执行计划。

## 常见阻塞

- Target files 或 planned components 缺失。
- Acceptance criteria 没有映射到 tasks。
- Verification plan 没有覆盖 affected components。
- Task class 在执行中升级，但新的 gates 和 Human decisions 没有记录。
- Actual changed files 超出 planned scope，且 artifacts 未 reconcile。

## 人工 Override

具名 Human 可以接受 narrowed 证据或 scope changes，但通常仍应更新 requirements、design、tasks 和 verification plan；如果不更新，必须显式记录 accepted gap。
