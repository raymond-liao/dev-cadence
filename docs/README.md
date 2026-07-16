# Dev Cadence 文档

Dev Cadence 帮助团队以清晰、可审阅、可信赖的方式开展 AI 参与的软件研发，覆盖从产品探索到验证交付的完整过程。

它为 AI 软件研发 agent 提供明确的工作流、确认门禁、长期资产和可验证的交付证据。

## 从这里开始

- [需求分析理念](requirements-analysis-philosophy.md)：说明 Dev Cadence 如何理解问题、需求、范围、证据和不确定性。
- [产品需求形成与 Story Map 衔接](product-requirements-derivation.md)：说明从 User Journey、Feature 到 PRD、Business Architecture 和 Story Map 的形成关系。
- [软件开发实施理念](implementation-philosophy.md)：说明设计、计划、编码、测试、评审和验证如何共同完成软件交付。
- [Backlog](backlog.md)：查看当前工作项、优先级、依赖和建议实施顺序。

## Workflow 说明

`workflows/` 保存面向维护者和使用者的业务流程说明：

- [需求探索流程](workflows/discovery.md)
- [架构设计流程](workflows/architecture-design.md)
- [工作项规划流程](workflows/work-item-planning.md)
- [工作项分析流程](workflows/work-item-analysis.md)
- [功能开发流程](workflows/feature-dev.md)
- [Bug 修复流程](workflows/bug-fix.md)
- [重构流程](workflows/refactor.md)

这些文档用于解释 workflow 的目的、适用场景、阶段和职责边界。实际执行规则以对应的 `src/skills/<workflow>/SKILL.md` 为权威来源；当两者不一致时，应修正规则源或说明文档，不能以说明文档替代执行规则。

## 工作项与 Backlog

- `stories/`：保存具有用户或系统可见价值的 Story 卡片。
- `tasks/`：保存支持交付、验证或治理的 Task 卡片。
- `bugs/`：保存既有预期行为未正确工作的 Bug 卡片。
- `backlog.md`：汇总工作项状态、优先级、依赖和当前建议顺序。

工作项文件使用稳定 ID。完成、关闭或被替代的工作项仍保留原文件和 ID，由卡片状态与 Backlog 表达生命周期，不通过移动文件改变身份。

## 文档职责边界

| 位置 | 职责 |
| --- | --- |
| `src/skills/**` | workflow 和共享能力的可执行规则源 |
| `docs/workflows/**` | 面向人的业务流程说明 |
| `docs/backlog.md`、`docs/stories/**`、`docs/tasks/**`、`docs/bugs/**` | 当前开发规划和工作项资产 |
| `build/dev-cadence/**` | Delivery Workflow 的 manifest、阶段记录、测试、Review 和验收证据 |
| `README.md`、`README.zh-CN.md` | 产品概览、安装方式和公开使用说明 |

目标仓库运行时产生的 PRD、Business Architecture、User Journey、Story Map、工作项和运行记录属于目标仓库自身资产。不要把目标仓库的业务内容写入本源码仓库的 `.dev-cadence/` 分发包。

## 维护规则

- 修改 workflow 行为时，先修改对应的 `src/skills/**/SKILL.md`，再按需要同步这里的流程说明。
- 移动或重命名文档时，更新所有受影响的仓库内 Markdown 链接，并检查旧路径是否仍被引用。
- 文档引用使用仓库相对路径，不持久化本机绝对路径或编辑器专用 URI。
- `docs/` 下的纯文档变化不要求新增或修改自动化测试；同一任务改变可执行行为时，只测试可执行行为。
- workflow 运行证据保存在 `build/dev-cadence/`，不使用 `docs/` 复制同一过程事实。
