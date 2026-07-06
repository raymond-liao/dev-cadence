# code-review

## 什么时候使用

`code-review` 用于审查已有 diff、branch、pull request 或 patch。

完整运行时规则见 [workflows.md](../../references/workflows.md)。Review 纪律见 [review-discipline.md](../../references/review-discipline.md)，G5 细则见 [G5 Review](../gates/g5-review.md)。

## 标准路径

```text
intake -> classify -> review -> acceptance
```

当用户要求验证，或 review 依赖尚不存在的证据时，加入 `test`。

## 路线图

| 步骤 | Dev Cadence 角色 | 做什么 | 使用 Skill |
|---|---|---|---|
| intake | Human / Supervisor | Human 提供 diff、branch、PR 或 patch；Supervisor 记录 review 范围。 | `using-dev-cadence` |
| classify | Supervisor | 选择 `code-review`，判断 task class、证据需求和是否需要额外 `test`。 | `using-dev-cadence` |
| review | Reviewer | 只读检查实际 diff、相关 artifacts、测试证据与剩余风险，输出 findings 和 review decision。 | `cadence-request-code-review` |
| test（按需） | Harness / Worker | 当用户要求验证或 approval 依赖缺失证据时，运行/检查验证并记录结果。 | `cadence-verify` |
| fix feedback（仅当用户要求修复） | Harness / Worker | 逐条验证 review finding；只修复有效问题，完成后交回 re-review。 | `cadence-code-review` |
| acceptance | Supervisor / Human | Supervisor 汇总 review 结论和剩余风险；Human 决定接受或继续修复。 | `cadence-verify` |

## 主要角色

- Supervisor 记录 review 范围和任务分级。
- Reviewer 检查 diff、相关 artifacts、测试和剩余风险。
- Tester 在证据缺失或用户要求时执行验证。
- Human 接受 review 结果，或决定是否带着风险继续。

## 主要产物

- [00-brief.md](../artifacts/00-brief.md)
- 执行验证时写 [06-test-report.md](../artifacts/06-test-report.md)
- [07-review-report.md](../artifacts/07-review-report.md)
- [08-acceptance.md](../artifacts/08-acceptance.md)

## Gate 重点

- G5 要求结构化 review decision：`approved`、`approved_with_minor_notes`、`changes_requested` 或 `blocked`。
- 当 review approval 依赖验证证据时，G4 也必须满足。
- G6 在 review 结果被接受或用于继续推进时记录 final Human acceptance。

## Human 介入点

接受剩余风险、决定是否修复 findings、以及最终验收都需要 Human decision。除非用户明确要求修复 findings，否则 review workflow 不应改代码。
