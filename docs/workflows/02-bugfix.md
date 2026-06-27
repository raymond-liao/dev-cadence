# bugfix

## 什么时候使用

`bugfix` 用于修正错误行为。

## 标准路径

```text
intake -> classify -> requirements -> planning -> implementation -> test -> review -> acceptance
```

如果根因未知，应先经过 debugging discipline，再进入实现。

## 主要角色

- Supervisor 负责任务分类并阻止不安全捷径。
- Planner 记录 observed behavior、expected behavior 和 acceptance criteria。
- Developer 先复现或 characterization，再修复限定范围内的原因。
- Tester 验证修复和回归覆盖。
- Reviewer 检查 diff、证据和剩余风险。
- Human 接受最终结果和剩余风险。

## 主要产物

- [00-brief.md](../artifacts/00-brief.md)
- [01-requirements.md](../artifacts/01-requirements.md)
- [03-tasks.md](../artifacts/03-tasks.md)
- [04-test-plan.md](../artifacts/04-test-plan.md)
- [05-implementation.md](../artifacts/05-implementation.md)
- [06-test-report.md](../artifacts/06-test-report.md)
- [07-review-report.md](../artifacts/07-review-report.md)
- [08-acceptance.md](../artifacts/08-acceptance.md)

## Gate 重点

- G1 在 expected behavior 或比较维度不清楚时保持 blocked。
- G3 要求有受控修复计划和验证计划。
- G4 要求可复现验证，或记录证据缺口。
- G5 对未解决 blocker 或 major finding 保持 blocked。
- G6 记录具名 Human acceptance。

## Human 介入点

expected behavior 不清楚、无法复现但需要接受风险、或最终验收时，需要 Human decision。

## 参考

- 运行时规则：[references/workflows.md](../../references/workflows.md)
- Debugging discipline：[root-cause-tracing.md](../../references/root-cause-tracing.md)
