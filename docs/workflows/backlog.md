# Backlog 流程

本文说明 Dev Cadence 的 `backlog` workflow。实际执行规则以 `src/workflows/backlog/SKILL.md` 为准。

## 目的

Backlog 流程负责把实施工作可靠地接入 Dev Cadence。它创建或接收 Story、Task、Bug 卡片，校验卡片契约，维护 `docs/backlog.md`，并把满足条件的工作项交给单卡分析或 Delivery Workflow。

## 适用场景

- 从一个新需求创建 Story、Task 或 Bug 卡片。
- 校验并登记用户提供的已有卡片。
- 调整工作项 Priority、关系、生命周期或待处理顺序。
- Dropped、Superseded、替换或关闭一个工作项。

## 不适用场景

- 产品探索、PRD、User Journey 或 Feature 定义。
- Story Map、Milestone、MVP 或产品组合规划。
- 一张卡片的详细需求分析：使用 `work-item-analysis`。
- 技术方案、诊断、实现、测试或验收：使用对应 Delivery Workflow。

## 卡片准入

```text
新需求
-> 创建 Dev Cadence 卡片和必要 Backlog 行
-> 必要时进入 work-item-analysis

合规已有卡片
-> 校验通过
-> 不重建、不重复分析
-> 登记 Backlog

不合规已有卡片
-> 保持原始输入不变
-> 将来源中的 ID 和路径视为已占用但不视为权威身份
-> 分配全新未占用 ID 和路径
-> 作为新需求进入标准建卡流程
```

合规不仅表示 Markdown 格式相似，还要求卡片的类型、ID、字段、Version、Status、Change Log 和类型成熟度足以支持目标路由。

如果不合规来源已经位于 `docs/stories/`、`docs/tasks/` 或 `docs/bugs/` 下，Backlog 仍保持该文件原状且不登记它；新建的 Dev Cadence 卡片使用全新未占用 ID 和路径，避免覆盖、重命名或身份冲突。

## 阶段

```text
Necessary Clarification -> Backlog Proposal -> Backlog Result Confirmation
```

Necessary Clarification 不是正式确认门。Backlog Result Confirmation 是一次资产写入门：卡片及其必要 Backlog 行必须原子写入，不能产生孤立卡片或孤立 Backlog 行。

## 资产所有权

- `docs/backlog.md`：Backlog 结构、生命周期分区和待处理建议顺序。
- `docs/stories/**`、`docs/tasks/**`、`docs/bugs/**`：工作项卡片。
- `backlog`：准入、Priority、规划关系和生命周期位置。
- `work-item-analysis`：单卡详细定义。
- Delivery Workflow：交付事实、验证证据和结果。

`待处理` 的行顺序是唯一权威建议实施顺序。Priority 不自动覆盖该顺序。

生命周期分区固定按状态映射：`Draft`、`Ready`、`Blocked` 位于 `待处理`，`In Progress` 位于 `进行中`，`Done` 位于 `已完成`，`Superseded`、`Dropped` 位于 `已关闭`。跨分区状态变化必须原子更新卡片并移动 Backlog 行。

## 交接

- 需要详细定义的卡片交给 `work-item-analysis`。
- Ready Story 在用户明确要求实施时交给 `feature-dev`。
- Task 根据目标交给 `feature-dev`、`bug-fix` 或 `refactor`。
- Bug 在用户明确要求修复时交给 `bug-fix`。

登记卡片不会自动认领或开始实施。
