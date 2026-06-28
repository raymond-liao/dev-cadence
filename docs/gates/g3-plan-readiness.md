# G3 Plan Readiness

## 目的

G3 用来确认任务已经拆到可以执行，并且修改范围受控。

## 检查阶段

`planning` 之后、implementation 之前。

## 必要输入

- [01-requirements.md](../artifacts/01-requirements.md)
- 存在时读取 [02-design.md](../artifacts/02-design.md)
- [03-tasks.md](../artifacts/03-tasks.md)
- 验证计划和目标文件

## 通过条件

[03-tasks.md](../artifacts/03-tasks.md) 已经写清楚输入、输出、目标文件、验收标准对应关系、验证计划、禁止动作和任务升级条件。通常由 [Planner](../roles/agents/01-planner.md) 准备可执行计划。

## 常见阻塞

- 目标文件或计划修改的组件缺失。
- 验收标准没有映射到具体任务。
- 验证计划没有覆盖受影响的组件。
- 执行中任务等级升高，但新的 gate 和 Human 决策没有记录。
- 实际修改文件超出计划范围，产物还没有更新对齐。

## 人工 Override

Human 可以接受收窄后的证据或范围变化，但通常仍应更新需求、设计、任务和验证计划；如果不更新，必须明确写出接受了哪个缺口。
