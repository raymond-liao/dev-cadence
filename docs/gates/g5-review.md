# G5 Review

## 目的

G5 确保 review 已检查 spec compliance、code quality、scope reconciliation、verification coverage 和 residual risk。

## 检查阶段

review 之后，Human acceptance 之前。

## 必要输入

- [05-implementation.md](../artifacts/05-implementation.md)
- [06-test-report.md](../artifacts/06-test-report.md)
- [07-review-report.md](../artifacts/07-review-report.md)
- diff summary 和 relevant code
- G4 status 或 Human override

## 通过条件

G4 已通过或由 Human Gate override，scope reconciliation 完成，且 Reviewer decision 是 `approved` 或 `approved_with_minor_notes`。

## 常见阻塞

- G4 未通过且没有明确 override。
- Reviewer decision 是 `changes_requested` 或 `blocked`。
- Blocker 或 major findings 未解决。
- Scope reconciliation 漏掉属于任务的 tracked 或 untracked files。
- Required Harness 运行证据缺失。

## 人工 Override

具名 Human 只有在 decision 和 follow-up 被记录时，才能接受 major findings 的 residual risk。Critical 或 major findings 通常需要 fix 和 re-review 后才能进入 acceptance。

## 相关产物

- [07-review-report.md](../artifacts/07-review-report.md)
- [Reviewer](../roles/agents/05-reviewer.md)
