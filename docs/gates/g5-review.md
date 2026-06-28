# G5 Review

## 目的

G5 用来确认 Review 已经检查需求符合度、代码质量、范围对齐、验证覆盖和剩余风险。

## 检查阶段

Review 之后，Human 验收之前。

## 必要输入

- [05-implementation.md](../artifacts/05-implementation.md)
- [06-test-report.md](../artifacts/06-test-report.md)
- [07-review-report.md](../artifacts/07-review-report.md)
- diff summary 和相关代码
- G4 状态，或 Human 对验证缺口的接受记录

## 通过条件

G4 已通过，或 Human 已接受验证缺口；变更范围已经对齐；[07-review-report.md](../artifacts/07-review-report.md) 中的 Review 结论是 `approved` 或 `approved_with_minor_notes`。通常由 [Reviewer](../roles/agents/05-reviewer.md) 准备 Review 结论。

## 常见阻塞

- G4 未通过，也没有 Human 接受验证缺口。
- Review 结论是 `changes_requested` 或 `blocked`。
- blocker 或 major finding 还没有解决。
- 范围对齐漏掉了属于任务的 tracked 或 untracked 文件。
- 必需的 Harness 运行证据缺失。

## 人工 Override

Human 只有在决策和后续处理都写清楚时，才能接受 major finding 带来的剩余风险。critical 或 major finding 通常需要修复并重新 Review 后，才能进入验收。
