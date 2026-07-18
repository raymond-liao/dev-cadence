# S-023 Manual Recovery 终态

## 基本信息

- ID：`S-023`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Feature

## 目标

当正常 Completion 无法继续时，允许三个开发 workflow 记录恢复原因、保留状态和最终 `abandoned` 结果。

## 背景

不可恢复的环境或 Git 状态可能使正常 Completion 路径无法完成。若 run 只能停留在 `pending`，其真实终态、保留资产和后续责任无法审计。

## ✅ 范围

- 为三个开发 workflow 定义对称的 manual recovery 路径。
- 记录正常 Completion 无法继续的原因和已尝试恢复动作。
- 记录代码、分支、worktree 和运行记录的保留状态。
- 将 manifest 更新为明确的 `abandoned` 终态。
- 要求用户确认放弃正常 Completion。

## ❌ 非范围

- 不修改具体 merge、discard 或 worktree 命令。
- 不把可恢复失败直接标记为 `abandoned`。
- 不删除为后续人工恢复所需的证据。

## 验收标准

1. 三个 workflow 在正常 Completion 确实无法继续时可以结束为 `abandoned`。
2. 终态记录包含原因、用户确认、保留状态和后续责任。
3. 可恢复场景仍优先执行正常恢复，不会被 manual recovery 绕过。

## 依赖

- 无强制前置依赖。

## Open Questions

- Q-012：哪些失败类别允许进入 manual recovery，哪些必须继续阻塞？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 Manual Recovery 终态 Story。 | 为无法正常完成的 run 提供明确、可审计的退出路径。 |
