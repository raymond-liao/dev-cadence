# G1 Requirements Readiness

## 目的

G1 用来避免需求还没说清楚就开始实现。目标、范围、不做什么、验收标准和验证方式会影响最终结果，必须先讲清楚。

## 检查阶段

`requirements` 之后，planning 或 implementation 之前。

## 必要输入

- [00-brief.md](../artifacts/00-brief.md)
- [01-requirements.md](../artifacts/01-requirements.md)
- Requirements Readiness Check
- 当歧义会影响实现或验收时，需要 Human 澄清

## 通过条件

范围、不做事项、约束、验收标准和验证方式已经清楚。关键歧义已经由 Human 选择、确认或明确延后。

## 常见阻塞

- 期望行为不清楚。
- 参考行为或比较维度只是从代码里推出来的，还没有被确认。
- 缩小范围或标记非目标只是 Agent 自己的假设。
- 澄清结果被归因给 Supervisor、Harness、Worker Agent 或仓库证据。
- 用户后续纠正使之前的需求失效。

## 人工 Override

Human 可以选择某个解释，也可以明确把问题延后。这个决定必须记录到 [01-requirements.md](../artifacts/01-requirements.md)；仓库证据本身不能让 G1 通过。
