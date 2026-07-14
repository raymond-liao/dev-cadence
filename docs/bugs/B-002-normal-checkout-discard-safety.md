# B-002 普通 Checkout Discard 安全性

## 基本信息

- ID：`B-002`
- Version：`1`
- Status：`Draft`
- Priority：`P0`
- Change Type：Bug

## 问题目标

修复普通 checkout 的 Discard 路径，避免删除错误分支、遗漏未提交改动或在未明确确认时执行不可逆操作。

## 预期行为

Discard 前应确认精确 branch 和 commit 范围，处理当前分支与未提交改动，获得明确 discard 确认，并在执行后验证目标分支的实际状态。

## 已观察行为

现有规则未完整固定删除对象、未提交状态和执行后验证契约，存在错误删除或结果不确定的风险。

## ✅ 范围

- 固定待丢弃 branch、commit 范围和当前 checkout 状态。
- 检查 tracked 与 untracked 未提交改动。
- 在不可逆动作前要求明确 discard 确认。
- 执行后验证目标分支确实删除或按决策保留。
- 覆盖普通 checkout 的适用 Completion 路径。

## ❌ 非范围

- 不处理 worktree 所有权识别。
- 不处理 detached HEAD 的完整 Finishing。
- 不改变用户未选择 Discard 时的其他 Completion 路径。

## 验收标准

1. Discard 不会在目标 branch、commit 范围或工作区状态不明确时执行。
2. 未提交改动得到显式处理和确认。
3. 执行后通过 Git 状态验证实际结果。

## 已知复现条件

- 普通 checkout 处于 task branch，且可能存在未提交改动、当前分支删除限制或目标分支歧义。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建普通 Checkout Discard 安全性 Bug。 | 将可能造成不可逆 Git 状态的缺陷建立为独立卡片。 |
