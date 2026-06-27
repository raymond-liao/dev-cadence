# Dev Cadence Worker Agents

Worker Agents 负责交付具体研发产物，例如 requirements、design、tasks、implementation notes、test report、review report 或 research report。它们不能控制 workflow state、批准 gate、替代 Harness 采集证据，或宣布最终完成。

上层角色边界由 [Human、Supervisor 和 Harness](../) 定义；整体架构分层和 Context/Tooling 边界见 [Dev Cadence 架构](../../architecture.md)。

## Agent 目录

| Agent | 说明 |
|---|---|
| [Planner](01-planner.md) | 需求、范围、验收标准和可执行任务拆解 |
| [Architect](02-architect.md) | 高风险任务的技术方案、架构约束和 ADR |
| [Developer](03-developer.md) | 在批准范围内实现变更并记录实现证据 |
| [Tester](04-tester.md) | 独立验证行为、复现和修复结果 |
| [Reviewer](05-reviewer.md) | 检查 spec compliance、code quality 和残余风险 |
| [Researcher](06-researcher.md) | 为未知技术方向提供证据、比较和建议 |

## 通用边界

Worker Agents 的输出是后续流程的输入，不自动等于 gate approval 或 Human acceptance。需求和计划落在 [task artifacts](../../artifacts/)；实现、测试、diff 和权限证据落在 [runs](../../runs/)；被采纳的研究结论必须进入 [design](../../artifacts/02-design.md) 或 ADR 后，才算正式设计决策。

如果 Worker 发现范围、架构、权限、测试信心或剩余风险已经超出当前授权，应把问题写入对应 artifact 或 run evidence，由 [Supervisor](../02-supervisor.md) 决定下一步是否进入 [Gate](../../gates/) 或 Human decision。
