# bugfix

## 什么时候使用

`bugfix` 用于修正错误行为。

完整运行时规则见 [workflows.md](../../references/workflows.md)。调试纪律见 [cadence-debug](../../skills/cadence-debug/SKILL.md)，根因追踪见 [root-cause-tracing.md](../../skills/cadence-debug/root-cause-tracing.md)。

## 标准路径

```text
intake -> classify -> requirements -> planning -> implementation -> test -> review -> acceptance
```

如果根因未知，应先经过 debugging discipline，再进入实现。

## 路线图

| 步骤 | Dev Cadence 角色 | 做什么 | 使用 Skill |
|---|---|---|---|
| intake | Human / Supervisor | Human 报告错误行为；Supervisor 建立 brief，记录 observed behavior 和影响范围。 | `using-dev-cadence` |
| classify | Supervisor | 选择 `bugfix`，记录原因、task class、gate、证据要求和安全边界。 | `using-dev-cadence` |
| requirements | Supervisor / Human | 澄清 expected behavior、比较维度、验收标准；不清楚时保持 blocked。 | `cadence-clarify` |
| debugging | Harness / Worker | 在修复前复现或 characterization，调查根因；根因未知时不得直接修。 | `cadence-debug` |
| planning | Worker | 制定受控修复计划、目标文件、回归测试/验证计划和风险说明。 | `cadence-plan` |
| implementation | Harness / Worker | Harness 约束执行边界；Worker 针对已确认根因做最小修复，优先先写失败回归测试。 | `cadence-tdd` / `cadence-executing-plans` |
| test | Harness / Worker | 验证原始症状已修复，运行回归检查；无法复现时记录证据缺口。 | `cadence-verify` |
| review | Reviewer | 检查 diff、根因证据、验证证据和剩余风险；有效 findings 进入修复循环。 | `cadence-request-code-review` / `cadence-code-review` |
| acceptance | Supervisor / Human | Supervisor 汇总修复、验证、review 和残余风险；Human 做具名最终验收。 | `cadence-verify` |

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
