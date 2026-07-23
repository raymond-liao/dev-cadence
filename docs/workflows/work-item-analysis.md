# 工作项分析流程

本文说明 Dev Cadence 的 `work-item-analysis` workflow。实际执行规则以 `src/workflows/work-item-analysis/SKILL.md` 为准。

## 目的

工作项分析用于明确一张已有 Story、Task 或 Bug 的实施定义。它不负责产品分析、跨卡组合规划、卡片准入或软件交付。

## 输入边界

- 每次只分析一张已有且符合结构契约的卡片。
- 缺失或不合规卡片返回 [`backlog`](backlog.md) 的标准新需求流程。
- 工作项分析不创建新卡，也不登记、移动或重排 Backlog 行。

## 阶段

```text
Necessary Clarification -> Work Item Definition Proposal -> Work Item Confirmation
```

Necessary Clarification 不是正式确认门。Work Item Confirmation 只更新当前卡片以及 Backlog 中对应行的机械 Version/Status 摘要，不改变 Backlog 顺序。

工作项分析只允许在 `Draft`、`Ready` 和 `Blocked` 三种定义成熟度状态之间更新；三者都保留在 `待处理`。`In Progress`、`Done`、`Superseded` 和 `Dropped` 属于执行或终态生命周期，必须交给 Backlog 或对应 Delivery Workflow，不能由单卡分析设置。

## Story

Story 分析明确角色、目标、价值、包含范围、排除范围、可观察行为、规则、验收条件、依赖和 Open Questions。

Story 是否达到 `Ready` 只取决于自身实施定义和用户确认，不要求 Feature、User Journey、PRD 或 Story Map 引用。

## Task

Task 分析明确目标、必要性、范围、完成条件、影响区域、约束、依赖、风险和 Open Questions。Task 不需要达到 `Ready`，但 Delivery Workflow 在改代码前仍须确认目标、范围和完成条件。

## Bug

Bug 分析明确预期行为、观察行为、影响、环境、复现信息和当前证据分类。技术根因、修复边界和回归证明属于 `bug-fix`，不属于工作项分析。

Bug 不要求 `Ready`、完整复现或已知根因才能进入 `bug-fix`。

## 交接

- Ready Story -> `feature-dev`
- Task -> `feature-dev` / `bug-fix` / `refactor`
- Bug -> `bug-fix`

分析确认不自动认领工作项或开始 Delivery Workflow。用户仍需明确提出实施、修复或重构请求。
