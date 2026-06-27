# incident-fix

## 什么时候使用

`incident-fix` 用于紧急生产恢复或关键活动故障。

完整运行时规则见 [workflows.md](../../references/workflows.md)。Emergency approval 和 post-incident acceptance 属于 [Human Gate](../gates/) 边界，执行证据记录在 [runs](../runs/) 中。

## 标准路径

```text
intake -> classify -> triage -> emergency approval -> implementation -> smoke test -> review? -> acceptance -> post-incident backfill
```

优先选择最小、可回滚的修复。即时风险降低后，再补齐缺失的普通 artifacts。

## 主要角色

- Supervisor 控制 emergency state 和 approval 边界。
- Developer 应用最小范围 patch。
- Tester 执行 smoke verification。
- Reviewer 在时间和风险允许时参与，或在 post-incident backfill 中参与。
- Human 给出 emergency approval 和 post-incident acceptance。

## 主要产物

- [00-brief.md](../artifacts/00-brief.md)
- triage notes
- emergency Human Gate decision
- [05-implementation.md](../artifacts/05-implementation.md)
- smoke 证据或 [06-test-report.md](../artifacts/06-test-report.md)
- 执行 review 时写 [07-review-report.md](../artifacts/07-review-report.md)
- [08-acceptance.md](../artifacts/08-acceptance.md)
- post-incident follow-up notes

## Gate 重点

incident work 只有在明确 emergency Human Gate approval 下才能绕过普通顺序。缺失 artifacts 和不完整验证仍然是已记录风险，不能因为 emergency handling 被抹掉。

## Human 介入点

emergency risk acceptance、production-sensitive actions 和最终 post-incident acceptance 都需要 Human approval。
