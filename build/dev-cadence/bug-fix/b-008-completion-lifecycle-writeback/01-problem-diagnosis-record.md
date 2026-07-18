# B-008 问题诊断记录（终态写回）

## 问题来源

- Work Item: [B-008 Bug Fix 完成后未更新 Backlog](../../../../docs/bugs/B-008-bug-fix-completion-does-not-update-backlog.md)
- Card Version: `1`
- Prior Run: `build/dev-cadence/bug-fix/b-008-bug-fix-backlog-sync/manifest.md`

## 报告症状

B-005、B-007、B-008 的旧运行清单都已 `integrated`，但 Bug 卡片和 Backlog 仍为 `Draft`。当前 Bug Fix Completion 专用段只具体要求移动 Backlog 行，没有明确要求同步卡片 `Status`、修复结果引用和 Change Log。

## 预期与实际

- 预期：成功 merge 后，Bug 卡片与 Backlog 必须作为一个原子写入单元进入 `Done`，卡片保存可追溯的修复结果引用；其他 Completion 结果不写 `Done`。
- 实际：S-017 新增的共享规则提到卡片与 Backlog 原子回写，但 Completion 专用操作步骤和专项测试仍只锁定 Backlog 移动，执行代理可以遗漏卡片更新。

## 根因与影响

根因是通用 lifecycle contract 与 Bug Fix Completion 的具体步骤、测试断言没有闭环。影响限于 `bug-fix` 成功 merge 后的卡片/Backlog 终态同步。

## 结论

B-008 仍存在可执行契约缺口。应在 Completion 专用段明确卡片状态、交付引用和 Change Log 与 Backlog 原子写入，并扩展专项测试。

## 假设与未决问题

- 假设：只有 normalized finishing result `merge` 触发 `Done`，其他结果保持未完成。
- Open Questions: 无。
