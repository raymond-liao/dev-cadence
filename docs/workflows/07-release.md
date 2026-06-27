# release

## 什么时候使用

`release` 用于记录发布决策、gate、证据要求或交接需要。

完整运行时规则见 [workflows.md](../../references/workflows.md)。发布批准属于 [Human Gate](../gates/) 边界，最终接受记录由 [G6 Human Acceptance](../gates/g6-human-acceptance.md) 控制。

## 当前范围

`release` 是当前 Skill 版本中的 placeholder workflow。Dev Cadence 可以记录 release readiness 和 required decisions，但不会自动执行发布；除非后续 Skill 版本加入明确的平台或 CI 集成规则。

## 主要角色

- Supervisor 记录 release scope 和 required gates。
- Tester 或 Developer 提供 release-readiness 证据。
- Reviewer 可以审查 release risk 和证据。
- Human 批准 merge、release 或 production action。

## 主要产物

- [00-brief.md](../artifacts/00-brief.md)
- release readiness notes
- 相关 verification 证据
- 相关 review 证据
- [08-acceptance.md](../artifacts/08-acceptance.md) 或 release decision record

## Gate 重点

release decision 属于 Human Gate 边界。Agent 可以准备证据和建议，但不能替 Human 批准 merge、release、production 或剩余交付风险。

## Human 介入点

merge、release、production changes，以及接受 skipped checks 或 residual risk，都需要 Human approval。
