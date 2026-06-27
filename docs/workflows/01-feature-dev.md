# feature-dev

## 什么时候使用

`feature-dev` 用于新增用户可见行为或系统行为。

完整运行时规则见 [workflows.md](../../references/workflows.md)；风险增强规则见 [task-classes.md](../../references/task-classes.md)。

## 标准路径

```text
intake -> classify -> requirements -> design? -> planning -> implementation -> test -> review -> acceptance
```

当功能改变 public contract、架构、数据模型或跨模块行为时，必须进入 `design`。

## 主要角色

- Supervisor 负责分类请求并控制状态流转。
- Planner 负责澄清需求并写出可执行任务。
- Architect 在 `S2` 或设计敏感任务中参与。
- Developer 通过 Harness 实现限定范围内的变更。
- Tester 验证变更行为。
- Reviewer 检查 spec compliance 和 code quality。
- Human 确认需求并做最终验收。

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

- G1 确认目标、范围、非目标、验收标准和验证方式。
- G2 在架构敏感设计需要确认时启用。
- G3 确认任务可执行且范围受控。
- G4 确认验证证据覆盖变更组件。
- G5 确认 Review 没有未解决的 blocker 或 major issue。
- G6 记录具名 Human acceptance。

## Human 介入点

需求确认、高风险设计或权限边界、不完整验证 override，以及最终验收都需要 Human decision。
