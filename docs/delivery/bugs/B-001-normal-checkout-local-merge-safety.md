# B-001 普通 Checkout 本地 Merge 安全性

## 基本信息

- ID：`B-001`
- Version：`1`
- Status：`Done`
- Priority：`P0`
- Change Type：Bug

## 问题目标

修复普通 checkout 的本地 Merge 路径，确保合并对象、预期版本和执行结果在操作前后都可验证。

## 预期行为

Merge 前应固定 base branch、feature branch 和预期 SHA，安全处理离线仓库与 already-integrated 分支，并在合并后验证实际结果。

## 已观察行为

现有规则未完整固定分支与 SHA 身份，也未闭环覆盖离线和已集成场景，可能合并错误版本或错误报告完成。

## ✅ 范围

- 在执行前固定 base branch、feature branch 和预期 SHA。
- 验证当前 checkout、工作区状态和合并前置条件。
- 安全处理离线仓库与 already-integrated 分支。
- 合并后验证目标分支包含预期提交且工作区状态符合预期。

## ❌ 非范围

- 不处理远程 PR 合并策略。
- 不处理 detached HEAD 的完整 Finishing。
- 不在本 Bug 中重写 Discard 路径。

## 验收标准

1. 分支或 SHA 身份不明确时不会执行本地 Merge。
2. 离线与 already-integrated 场景具有明确、非破坏性结果。
3. 合并完成声明由执行后的 Git 验证支持。

## 已知复现条件

- 普通 checkout 选择本地 Merge，且远程不可用、feature 已被集成或分支身份可能变化。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建普通 Checkout 本地 Merge 安全性 Bug。 | 将可能错误合并或错误报告完成的路径建立为独立卡片。 |
