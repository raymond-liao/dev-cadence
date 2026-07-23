# 交付资产

本目录保存 Dev Cadence 源码仓库自身的交付工作项及其汇总视图。这里记录要实施、正在实施或已经结束的工作，不是 workflow 执行规则或运行证据的存放位置。

## 入口

- [Backlog](backlog.md)：工作项状态、优先级、依赖和建议实施顺序的权威汇总。
- [Open Question Registry](open-questions.md)：跨工作项仍需追踪的问题索引。

## 工作项类型

- [`stories/`](stories/)：具有用户或系统可见价值的 Story 卡片。
- [`tasks/`](tasks/)：支持交付、验证或治理的 Task 卡片。
- [`bugs/`](bugs/)：记录既有预期行为未正确工作的 Bug 卡片。

每张卡片使用稳定 ID，并保存自身的定义、状态和验收要求。完成、关闭或被替代的卡片继续保留在原目录中，由卡片和 Backlog 表达生命周期，不通过移动或删除文件改变身份。

## 边界

- workflow 的可执行规则以 [`src/workflows/`](../../src/workflows/) 为权威来源。
- 跨 workflow 契约以 [`src/references/`](../../src/references/) 为权威来源。
- workflow 运行记录和交付证据保存在 [`build/dev-cadence/`](../../build/dev-cadence/)。
- 产品分析资产不属于 Dev Cadence；外部需求只有在满足本项目工作项要求后才进入 Backlog 和实施流程。
