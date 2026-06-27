# code-review

## 什么时候使用

`code-review` 用于审查已有 diff、branch、pull request 或 patch。

## 标准路径

```text
intake -> classify -> review -> acceptance
```

当用户要求验证，或 review 依赖尚不存在的证据时，加入 `test`。

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

## 参考

- 运行时规则：[references/workflows.md](../../references/workflows.md)
- Review discipline：[review-discipline.md](../../references/review-discipline.md)
