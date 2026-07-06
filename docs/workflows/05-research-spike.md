# research-spike

## 什么时候使用

`research-spike` 用于可行性确认、技术比较、设计方案研究或基于证据的建议。

完整运行时规则见 [workflows.md](../../references/workflows.md)。执行入口是 `cadence-research`，执行角色见 [Researcher](../roles/agents/06-researcher.md)。

## 标准路径

```text
intake -> classify -> research -> design? -> acceptance
```

除非新交付任务已被批准，否则 research spike 不应实现产品变更。

## 路线图

| 步骤 | Dev Cadence 角色 | 做什么 | 使用 Skill |
|---|---|---|---|
| intake | Human / Supervisor | Human 提出研究问题；Supervisor 记录边界、`workflow_hint` 和初始证据需求。 | `using-dev-cadence` |
| classify | Supervisor | 选择 `research-spike`，确认 task class、风险和是否需要 Human Gate。 | `using-dev-cadence` |
| research | Harness / Worker | Harness 约束只读研究边界；Worker 收集证据、比较方案、记录 tradeoffs、recommendation 与 open questions。 | `cadence-research` |
| design? | Supervisor / Worker | 仅当研究升级为设计方向时，整理设计影响；不得直接实现产品变更。 | `cadence-clarify` / `cadence-plan` |
| acceptance | Supervisor / Human | Supervisor 汇总证据、建议和残余风险；Human 决定采纳、延后或要求后续交付任务。 | `cadence-verify` |

```text
Supervisor intake/classify
  -> Harness dispatches bounded research
  -> Worker produces evidence-backed recommendation
  -> optional design handoff if direction is adopted
  -> Human decision / acceptance
```

## 主要角色

- Supervisor 记录研究问题和边界。
- Researcher 收集证据、比较方案并记录缺口。
- Architect 可以参与设计影响评审。
- Human 做出或延后决策。

## 主要产物

- [00-brief.md](../artifacts/00-brief.md)
- `research-report.md`
- 当研究升级为设计方向时写 [02-design.md](../artifacts/02-design.md) 或 ADR
- [08-acceptance.md](../artifacts/08-acceptance.md) 或 decision record

## Gate 重点

research spike 不自动要求完整 implementation gate chain，但仍必须记录证据、open questions，以及影响方向或风险时的 Human decision。

## Human 介入点

当建议依赖业务优先级、风险承受度、成本、排期或长期技术方向时，需要 Human review。
