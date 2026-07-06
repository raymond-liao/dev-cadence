# incident-fix

## 什么时候使用

`incident-fix` 用于紧急生产恢复或关键活动故障。

完整运行时规则见 [workflows.md](../../references/workflows.md)。Emergency approval 和 post-incident acceptance 属于 [Human Gate](../gates/) 边界，执行证据记录在 [runs](../runs/) 中。

## 标准路径

```text
intake -> classify -> triage -> emergency approval -> implementation -> smoke test -> review? -> acceptance -> post-incident backfill
```

优先选择最小、可回滚的修复。即时风险降低后，再补齐缺失的普通 artifacts。

## 路线图

| 步骤 | Dev Cadence 角色 | 做什么 | 使用 Skill |
|---|---|---|---|
| intake | Human / Supervisor | Human 报告 incident；Supervisor 记录摘要、影响范围、生产敏感边界和初始风险。 | `using-dev-cadence` |
| classify | Supervisor | 选择 `incident-fix`，确认 task class、emergency state 与 gate 边界。 | `using-dev-cadence` |
| triage | Harness / Worker | 诊断症状、疑似原因、复现/观测信号和最小可回滚修复方向。 | `cadence-debug` |
| emergency approval | Human / Supervisor | Human 明确接受 emergency risk；Supervisor 记录允许绕过的普通顺序与残余风险。 | `using-dev-cadence` |
| implementation | Harness / Worker | 在批准范围内应用最小 patch，避免扩大变更面。 | `cadence-tdd` / `cadence-executing-plans` |
| smoke test | Harness / Worker | 执行 smoke verification，记录命令、日志、结果和未验证项。 | `cadence-verify` |
| review? | Reviewer | 时间和风险允许时审查修复范围、回滚性、证据和残余风险；否则进入 backfill。 | `cadence-request-code-review` |
| acceptance | Supervisor / Human | 汇总 emergency 修复证据；Human 做 post-incident acceptance 或要求补救。 | `cadence-verify` |
| post-incident backfill | Supervisor / Harness / Worker / Reviewer | 补齐缺失 artifacts、review、follow-up 和长期修复任务。 | `using-dev-cadence` / `cadence-plan` |

```text
Supervisor intake/classify
  -> Harness + Worker triage/debug
  -> Human emergency approval
  -> Harness executes minimal fix
  -> smoke verification
  -> optional Reviewer review
  -> Human acceptance
  -> post-incident artifact/review backfill
```

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
