# G6 Human Acceptance

## 目的

G6 用来确认最终输出和剩余风险已经被 Human 接受。

## 检查阶段

`acceptance` 阶段；在声明最终完成、准备提交、合并或发布之前。

## 必要输入

- 所有必需的 task artifacts
- 验证状态
- Review 结论
- 已查看的证据
- 剩余风险和跳过的检查
- [08-acceptance.md](../artifacts/08-acceptance.md)

## 通过条件

[08-acceptance.md](../artifacts/08-acceptance.md) 写清楚接受结果的 Human，并记录接受范围、看过哪些证据、还有什么剩余风险，以及最终决定。

## 常见阻塞

- `accepted_by_human` 为空。
- 接受人是 Supervisor、Harness、Developer、Tester、Reviewer 或未指定 agent。
- 剩余风险未记录。
- S2 工作缺少必需的需求、架构、权限或最终 Human 决策。
- 只有提交请求，但没有 [08-acceptance.md](../artifacts/08-acceptance.md)。

## 人工 Override

G6 本身就是最终 [Human](../roles/01-human.md) 决策。它必须记录在 [08-acceptance.md](../artifacts/08-acceptance.md)，不能用 Agent 自称完成、Review 通过、测试通过或提交请求来替代。
