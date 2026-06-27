# refactor

## 什么时候使用

`refactor` 用于意图保持行为不变的结构调整。

完整运行时规则见 [workflows.md](../../references/workflows.md)；风险增强规则见 [task-classes.md](../../references/task-classes.md)。

## 标准路径

```text
intake -> classify -> requirements -> design? -> planning -> implementation -> test -> review -> acceptance
```

涉及大范围、跨模块、public contract 或架构敏感重构时，必须进入 `design`。

## 主要角色

- Supervisor 负责分类风险并阻止无边界重构。
- Planner 记录行为保持要求和非目标。
- Architect 在重构影响架构或 contract 时参与。
- Developer 在批准范围内调整结构。
- Tester 验证行为保持不变。
- Reviewer 检查 scope、architecture fit、测试证据和 maintainability。
- Human 接受最终结果和剩余风险。

## 主要产物

- [00-brief.md](../artifacts/00-brief.md)
- [01-requirements.md](../artifacts/01-requirements.md)
- 需要时写 [02-design.md](../artifacts/02-design.md)
- [03-tasks.md](../artifacts/03-tasks.md)
- [04-test-plan.md](../artifacts/04-test-plan.md)
- [05-implementation.md](../artifacts/05-implementation.md)
- [06-test-report.md](../artifacts/06-test-report.md)
- [07-review-report.md](../artifacts/07-review-report.md)
- [08-acceptance.md](../artifacts/08-acceptance.md)

## Gate 重点

- G1 要求明确 behavior-preservation scope 和 non-goals。
- G2 用于架构敏感重构。
- G3 要求明确 target files 和 forbidden actions。
- G4 要求 characterization tests、regression tests，或明确 not-verified reason。
- G5 在出现未计划行为变化或 major review finding 时保持 blocked。
- G6 记录具名 Human acceptance。

## Human 介入点

范围扩大、行为变化、验证不完整或最终验收时，需要 Human decision。
