# B-008 Bug Fix 完成后未更新 Backlog

## 基本信息

- ID：`B-008`
- Version：`2`
- Status：`Draft`
- Priority：`P1`
- Change Type：Bug

## 问题目标

修复 Bug Fix Delivery Workflow 在完成业务验收和 Completion 后未同步更新 Backlog 汇总状态的问题，避免已完成的 Bug 仍显示为待处理。

## 预期行为

当 Bug Fix 完成 Business Acceptance 且 Completion 成功合并到 base branch 后，系统应原子地把对应 Bug 卡片和 Backlog 更新为 `Done`：卡片记录修复结果与集成引用，Backlog 条目从“待处理”或“进行中”移动到“已完成”，并从当前并行视图移除。

## 已观察行为

Bug Fix 流程可以完成实现、验证、业务验收和本地集成，但对应 Bug 在 `docs/backlog.md` 中仍保留 `Draft` 状态和“待处理”位置，需要人工修正。

## ✅ 范围

- 覆盖 `bug-fix` workflow 成功 merge 后的 Bug 卡片与 Backlog 状态、位置和交付引用同步。
- 保持 Bug 卡片、Backlog 汇总状态和实际集成结果一致。
- 明确 PR、保留分支、取消、阻塞和 whole-run Discard 不写入 `Done`。
- 为状态同步添加可验证的规则或契约证据。

## ❌ 非范围

- 不改变 Business Acceptance 的用户决策门。
- 不把 workflow 内部阶段映射为新的 Backlog 状态。
- 不修改 `feature-dev` 或 `refactor` 的 Backlog 同步行为，除非后续诊断证明存在同一缺陷并获得单独范围确认。
- 不自动重排无关的 Backlog 工作项。

## 验收标准

1. 完成并成功 merge 的 Bug Fix 会把对应 Bug 卡片与 Backlog 原子更新为 `Done`，并将 Backlog 条目移动到“已完成”。
2. Completion 未完成、被取消、被阻塞或 whole-run Discard 后，不会错误写入不存在或未完成的 Backlog 状态。
3. Bug 卡片保存修复结果和集成引用，并追加不增加需求 Version 的执行 Change Log。
4. Bug 卡片与 Backlog 任一事实冲突时不产生部分写入。
5. 重复执行不会重复卡片引用、Change Log 或 Backlog 行。
6. 变更具有可重复运行的验证证据。

## 已知复现条件

- 完成任一 Bug Fix 的业务验收与 Completion 集成后，检查 `docs/backlog.md` 中对应 Bug 条目。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)
- [B-002 Delivery Workflow Discard 整体运行删除安全性](B-002-normal-checkout-discard-safety.md)
- [B-006 Delivery 记录证据完整性](B-006-delivery-record-evidence-completeness.md)

## Relationships

- Affected workflow: `bug-fix`.
- Related Bugs: `B-002`, `B-006`.

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 2 | 2026-07-18T19:29:42+0800 | Raymond Liao <raymond-liao@outlook.com> | 将完成同步明确为成功 merge 后的 Bug 卡片与 Backlog 原子写回，并补充交付引用、执行 Change Log、冲突和幂等要求。 | 原规则和专项测试只具体约束 Backlog，未阻止卡片保持 Draft。 |
| 1 | 2026-07-18T06:54:19+0800 | Raymond Liao <raymond-liao@outlook.com> | 创建 Bug 卡片。 | 用户发现 Bug Fix 跑完后未更新 Backlog。 |
