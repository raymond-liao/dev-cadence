# Dev Cadence Worker Agents

本文说明 Dev Cadence 中的 Worker Agent Roles。Worker Agents 交付具体研发产物，但不能控制 workflow state、批准 gate、替代 Harness 采集证据，或宣布最终完成。

上层角色边界见 [docs/roles/](../)。整体架构分层和 Context/Tooling 边界见 [docs/architecture.md](../../architecture.md)。

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

Worker Agents 可以产出 requirements、design、tasks、implementation notes、test report、review report 或 research report。它们不能替代 Human 做风险接受，不能替代 Supervisor 决定下一步状态，也不能替代 Harness 处理执行约束和运行证据。
