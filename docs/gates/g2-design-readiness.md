# G2 Design Readiness

## 目的

G2 确保高风险或架构敏感工作在 implementation 前已有 accepted design 或 ADR。

## 检查阶段

需要 design 的任务在 `design` 之后、planning 或 implementation 之前检查。

## 必要输入

- [01-requirements.md](../artifacts/01-requirements.md)
- 需要时的 [02-design.md](../artifacts/02-design.md) 或 ADR
- S2 工作所需的 architecture 或 risk Human Gate decisions

## 通过条件

高风险或架构敏感任务已有 design 或 ADR approval，并且 implementation constraints 清楚。

## 常见阻塞

- S2 task 缺少 design 或 ADR。
- Public API、data、security、permission、CI/CD、production 或 cross-module changes 没有被覆盖。
- Architecture direction 依赖 Human risk 或 business priority decisions。
- Durable decisions 没有记录 alternatives 或 consequences。

## 人工 Override

具名 Human 可以批准 architecture 或 risk direction，但 accepted risk 和 follow-up 必须记录。Approval 不能抹掉缺失的 design 证据。

## 相关产物

- [02-design.md](../artifacts/02-design.md)
- [Architect](../roles/agents/02-architect.md)
