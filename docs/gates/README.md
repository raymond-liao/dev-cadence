# Dev Cadence 门禁

Gate 用来判断工作能不能进入下一阶段。缺证据表示流程被挡住了，不表示已经批准。

Workflow 怎么走见 [workflows](../workflows/)。Gate 判断会读取 [task artifacts](../artifacts/) 和 [run evidence](../runs/)；运行时 Quality Gate 规则见 [quality-gates.md](../../references/quality-gates.md)，Human Gate 规则见 [human-gates.md](../../references/human-gates.md)。

## Gate 目录

| Gate | 名称 | 说明 |
|---|---|---|
| [G1](g1-requirements-readiness.md) | Requirements readiness | 目标、范围、非目标、验收标准和验证方式清楚 |
| [G2](g2-design-readiness.md) | Design readiness | 高风险或架构敏感任务已有设计或 ADR |
| [G3](g3-plan-readiness.md) | Plan readiness | 任务可执行，含目标文件、验收映射、验证计划和 forbidden actions |
| [G4](g4-verification.md) | Verification | 测试或验证证据完整、可复现，或 Human 接受缺口 |
| [G5](g5-review.md) | Review | Review 没有未解决的 blocker 或 major finding |
| [G6](g6-human-acceptance.md) | Human acceptance | Human 接受最终结果和剩余风险 |

## Quality Gate 与 Human Gate

Quality Gate 看证据够不够继续。Human Gate 记录那些不能只靠自动化或 Agent 判断继续推进的人工决策。

Human 可以接受剩余风险继续推进，但这不会抹掉缺失证据。决策记录必须写清楚是哪位 Human 做出的，不能写成 Supervisor、Harness 或 Worker Agent。

## 检查结果

每个门禁检查只回答一个问题：现在能不能进入下一阶段。

- `passed`：这一步需要的证据已经够了，可以继续。只有 G6 通过才表示最终验收完成。
- `blocked`：还缺输入、证据、权限或 Human 决策。先补齐缺口，或者升级给 Human 判断。
- `failed`：已有证据说明现在不能通过，例如验证失败、Review 要求修改，或产物和实际变更对不上。先修复问题，再重新检查。
- `skipped`：当前任务不需要这一步检查。必须写清楚为什么跳过，不能用它代替缺失证据。

## 完成前规则

当 task artifacts 存在时，完成、通过、批准、验收或 ready 声明前必须运行：

```bash
scripts/check-gates.mjs --task-id <task_id>
```

该脚本只读；它报告检查结果，但不替代 Reviewer 或 Human 验收。

提交前检查和报告生成命令见 [../validation.md](../validation.md)。
