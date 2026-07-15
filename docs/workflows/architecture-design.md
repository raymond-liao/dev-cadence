# 架构设计流程

本文说明 Dev Cadence 的 `architecture-design` Asset Workflow。目标仓库中的权威执行规则位于 `src/skills/architecture-design/SKILL.md`；本文只解释用户可见的流程与边界。

## 目的

当用户明确提出架构设计、架构方案或架构评审目标时，围绕该目标调查必要现状、比较有意义的方案，并形成一份可确认的架构文档：

```text
docs/architecture/<goal-slug>.md
```

## 触发与输入

该流程只由明确的架构目标触发。缺少架构文档、Discovery 提到技术内容、Feature 需要局部技术方案等仓库状态或相邻活动都不会自动触发它。

设计开始前确认目标、设计对象、范围、非范围、关键约束、详细程度和产物名称。文件名只表达用户确认的具体目标，并生成可移植的 kebab-case slug；不得从 Product、Capability、Work Item 或其他预设架构尺度/Scope 分类派生文件名，也不得添加这些分类前缀。

## 调查与方案

根据目标按需调查代码、现有文档、组件边界、数据和接口、外部依赖、部署环境与质量属性。必要现状不存在时可以基于用户背景继续，但必须记录关键假设。

存在实质差异时比较两到三个方案；没有有意义的备选时不凑数。推荐不等于选择，只有用户确认或明确授权决策后才标记 `✅ Selected`。

## 架构文档

文档按目标裁剪，可包含当前现状、驱动因素、组件职责、数据与交互、外部边界、关键决策、质量属性、风险、开放问题和验证方式。架构图是文档的一部分，优先使用 Mermaid，不作为独立的核心产出物。

## 边界

`architecture-design` 不创建 `build/dev-cadence/` manifest、stage record、confirmation record 或 checkpoint commit。它不拆分工作项、不生成实施计划、不修改代码、不执行系统测试或发布部署。

独立架构文档可以为交付流程提供输入，但不能替代 Feature Dev 的 Technical Solution、Bug Fix 的 Repair Solution 或 Refactor 的 Refactor Solution。
