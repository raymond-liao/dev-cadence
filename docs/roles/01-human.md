# Human

## 目的

Human 负责产品意图、风险接受、权限批准、合并/发布责任和最终验收。

## 职责

- 在需要时确认目标、范围、非目标和验收标准。
- 批准高风险需求、架构、权限、数据、CI/CD、生产、merge 或 release 行为。
- 在验证或证据不完整时决定是否接受剩余风险。
- 在 [08-acceptance.md](../artifacts/08-acceptance.md) 中提供具名 final acceptance。

## 输入

- Task artifacts 和 Harness 运行证据。
- Gate 状态和 blockers。
- Agent 建议和 residual risk summary。

## 输出

- Human Gate decisions。
- 需求、架构、权限、merge、release 或 final acceptance decisions。
- 用于最终交付验收的 [08-acceptance.md](../artifacts/08-acceptance.md)。

## 不能被谁替代

- Supervisor。
- Harness。
- Developer、Tester、Reviewer 或任何 Worker Agent。
- Repository 证据或 source-code inspection。

## 升级条件

当 intent 模糊、证据不完整、风险较高、需要权限、loop 超限或需要最终验收时，升级到 Human。

## 相关产物

- [01-requirements.md](../artifacts/01-requirements.md)
- [02-design.md](../artifacts/02-design.md)
- [permission-decisions.md](../runs/07-permission-decisions.md)
- [08-acceptance.md](../artifacts/08-acceptance.md)
