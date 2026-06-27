# Dev Cadence 门禁

本文说明 Dev Cadence 的 Quality Gates 和 Human Gates。运行时规则见 [../../references/quality-gates.md](../../references/quality-gates.md) 和 [../../references/human-gates.md](../../references/human-gates.md)。

Gate 的作用是决定工作是否可以进入下一阶段。缺失证据是一种 workflow state，不是 approval。

## Gate 目录

| Gate | 名称 | 说明 |
|---|---|---|
| [G1](g1-requirements-readiness.md) | Requirements readiness | 目标、范围、非目标、验收标准和验证方式清楚 |
| [G2](g2-design-readiness.md) | Design readiness | 高风险或架构敏感任务已有设计或 ADR approval |
| [G3](g3-plan-readiness.md) | Plan readiness | 任务可执行，含目标文件、验收映射、验证计划和 forbidden actions |
| [G4](g4-verification.md) | Verification | 测试或验证证据完整、可复现，或具名 Human 接受缺口 |
| [G5](g5-review.md) | Review | Review 无未解决 blocker 或 major issue |
| [G6](g6-human-acceptance.md) | Human acceptance | 具名 Human 接受最终结果和剩余风险 |

## Quality Gate 与 Human Gate

Quality Gate 检查证据是否足够继续。Human Gate 记录人在自动化或 Agent 判断不应单独继续时作出的明确决策。

Human override 可以接受剩余风险，但不能抹掉缺失证据。override 必须命名 Human decision owner，不能写成 Supervisor、Harness 或 Worker Agent。

## 状态值

Gate status 使用：

```text
passed
failed
blocked
skipped
```

`blocked` 表示缺少输入、证据、权限或 Human decision。它不是失败的同义词，也不是 approval。

## 完成前规则

当 task artifacts 存在时，完成、通过、批准、验收或 ready 声明前必须运行：

```bash
scripts/check-gates.mjs --task-id <task_id>
```

该脚本只读；它报告 gate 状态，但不替代 Reviewer 或 Human acceptance。
