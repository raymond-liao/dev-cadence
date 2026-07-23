# B-002 Delivery Workflow Discard 整体运行删除安全性

## 基本信息

- ID：`B-002`
- Version：`2`
- Status：`Done`
- Priority：`P0`
- Change Type：Bug

## 问题目标

统一三个 Delivery Workflow 的 Discard 契约，使用户能够在明确知道影响范围的前提下删除整个当前 workflow run，同时避免误删其他任务或用户改动。

## 预期行为

Discard 前必须识别当前 run 的 branch、commit 范围、tracked/untracked 改动、运行记录和 worktree 创建归属。确认提示必须明确说明当前 run 的实现、branch、当前 run 创建的 worktree 和完整运行记录都会被删除，删除后不保留持久化终态记录。

当存在当前 run 以外的改动时，必须让用户选择只删除当前 run、删除整个 owned workspace 或 branch（包含列出的外部改动），或者取消。只有用户明确确认的对象可以被删除。

## 已观察行为

现有 finishing 规则只展示 branch、commit 和 worktree，未按当前 Delivery Workflow run 识别实现改动与运行记录，也未安全处理外部改动。三个 Delivery Workflow 又要求 Discard 后继续更新已被删除的 manifest 和 Business Acceptance 记录，导致删除语义与 Completion 记录契约冲突。

## ✅ 范围

- 覆盖 `feature-dev`、`bug-fix` 和 `refactor` 的 Completion Discard 契约。
- 固定当前 run 的 branch、commit 范围、tracked/untracked 改动、运行记录目录和当前 checkout/worktree 状态。
- 只将当前 run 创建的 worktree 识别为可自动删除的 owned worktree。
- 在确认中明确列出将删除的实现、branch、owned worktree 和完整运行记录，并说明删除后没有持久化终态记录。
- 当存在外部改动时提供“只删除当前 run”“删除整个 owned workspace 或 branch”“取消”三个明确选项。
- 用户选择删除整个 run 后，三个 Delivery Workflow 不再更新 manifest、Business Acceptance 或其他已删除记录。
- 执行后通过 Git 和文件系统状态验证实际删除结果，并只在当前会话报告结果。

## ❌ 非范围

- 不处理 detached HEAD 的完整 Finishing。
- 不改变用户未选择 Discard 时的其他 Completion 路径。
- 不为 Discard 新增 tombstone、删除记录、`abandoned` manifest 或其他持久化终态记录。
- 不迁移或保留已确认删除的当前 run 记录。
- 不自动删除外部管理或无法证明由当前 run 创建的 worktree。

## 验收标准

1. Discard 不会在当前 run、branch、commit 范围、改动归属、运行记录目录或 worktree 创建归属不明确时执行。
2. 确认提示完整列出当前 run 将被删除的实现、branch、owned worktree 和运行记录，并明确说明删除后不保留持久化记录。
3. 外部改动存在时，用户必须从三个固定选项中选择，且未选择的外部改动保持不变。
4. worktree 只有在证明由当前 run 创建且用户选择相应删除范围后才会被删除。
5. 三个 Delivery Workflow 对删除整个 run 使用一致的无记录终态语义，不会在删除后尝试更新不存在的记录。
6. 执行后通过 Git 和文件系统状态验证实际结果，并在当前会话准确报告成功、部分失败或阻塞。

## 已知复现条件

- Delivery Workflow 在 Completion 选择 Discard，当前环境可能是新建 task branch 或当前 run 创建的 worktree，并可能同时存在当前 run 以外的改动。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建普通 Checkout Discard 安全性 Bug。 | 将可能造成不可逆 Git 状态的缺陷建立为独立卡片。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 扩展为三个 Delivery Workflow 的整体 run 删除契约。 | 用户确认 Discard 应删除当前 run 的实现、owned branch/worktree 和完整运行记录；外部改动必须通过明确选项处理。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-18 | legacy: recorded-by unknown | Delivery Workflow 完成 Business Acceptance 和集成，状态更新为 `Done`。 | B-002 已完成交付、回归验证、业务验收并合并到 `main`。 |
