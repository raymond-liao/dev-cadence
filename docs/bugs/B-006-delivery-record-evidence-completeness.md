# B-006 Delivery 记录证据完整性

## 基本信息

- ID：`B-006`
- Version：`1`
- Status：`Done`
- Priority：`P2`
- Change Type：Bug

## 问题目标

修复 Delivery Workflow 在完成实施和验证记录时未完整落盘或未保持相互一致的问题，确保运行记录能够独立恢复实际变更、阶段检查点和最终 Review 状态。

## 预期行为

当一个 Delivery Workflow 阶段完成并产生提交时，实施记录应列出实际 Changed Files，manifest 应指向对应阶段的真实 checkpoint commit，SDD 进度应反映最终 Review 结果并保留完整的相关提交追踪。

## 已观察行为

S-014 的运行记录中，`04-implementation-record.md` 的 Changed Files 仍为 `pending`；manifest 的 System Testing checkpoint 停留在较早提交；`sdd/progress.md` 仍显示最终整分支 Review 为 pending，且遗漏了后续实施修复提交。记录因此无法完整、准确地表达已完成的交付证据。

## ✅ 范围

- 生成或更新实施记录时落盘实际 Changed Files 清单，不保留已完成阶段的占位符。
- 在阶段记录提交后同步 manifest 中对应的 checkpoint commit，并保持提交身份可追溯。
- 在最终 Review 完成后同步 SDD 进度、Review 结论和相关修复提交。
- 增加契约或验证，阻止完成状态下出现上述过期或缺失记录。

## ❌ 非范围

- 不改变 Delivery Workflow 的阶段顺序、用户确认门禁或状态枚举。
- 不把 Business Acceptance 的用户决策自动标记为已确认。
- 不在本 Bug 中修改 S-014 的产品设计内容或实现代码行为。

## 验收标准

1. 实施记录进入可 Review 或完成状态时，Changed Files 不再是 `pending`，且清单与实际范围一致。
2. manifest 的每个已完成阶段都指向真实 checkpoint commit，或明确记录适用的 `skipped` 原因。
3. 最终 Review 完成后，SDD 进度不再保留 `pending` 的最终 Review 状态，并包含所有影响交付结论的相关提交。
4. 契约验证能够检测占位符、过期 checkpoint 和遗漏的最终 Review 状态。

## 已知复现条件

- Delivery Workflow 在最终 Review 或系统测试后继续产生记录提交，但没有同步更新先前阶段记录中的文件清单、checkpoint 或 SDD 进度。
- 运行记录被分多次提交，后续修复提交未回填到汇总记录。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)
- [S-014 Discovery User Journey 与 Feature 基线](../stories/S-014-user-journey-analysis.md)
- [Feature Dev Workflow](../workflows/feature-dev.md)
- [Bug Fix Workflow](../workflows/bug-fix.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-16 | `-` | 创建 Delivery 记录证据完整性 Bug。 | S-014 暴露了 Changed Files、阶段 checkpoint 和最终 Review 进度未闭环的问题。 |
| 1 | 2026-07-17 | `Raymond Liao <raymond-liao@outlook.com>` | 状态更新为 `Done`。 | B-006 已完成业务验收、本地合并和终态验证。 |
