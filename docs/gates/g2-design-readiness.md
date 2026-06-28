# G2 Design Readiness

## 目的

G2 用来确保高风险或架构敏感的工作，在实现前已经有被接受的设计或 ADR。

## 检查阶段

需要设计的任务，在 `design` 之后、planning 或 implementation 之前检查。

## 必要输入

- [01-requirements.md](../artifacts/01-requirements.md)
- 需要时的 [02-design.md](../artifacts/02-design.md) 或 ADR
- S2 工作所需的架构或风险决策

## 通过条件

高风险或架构敏感任务已经有 [02-design.md](../artifacts/02-design.md) 或 ADR，且实现必须遵守的约束已经写清楚。通常由 [Architect](../roles/agents/02-architect.md) 准备设计证据。

## 常见阻塞

- S2 任务缺少设计或 ADR。
- 公共 API、数据、安全、权限、CI/CD、生产环境或跨模块变更没有被覆盖。
- 架构方向依赖业务优先级或风险接受，但还没有 Human 决策。
- 长期决策没有记录备选方案或后果。

## 人工 Override

Human 可以批准架构方向或风险方向，但接受了什么风险、后续要做什么必须写清楚。人工批准不能抹掉缺失的设计证据。
