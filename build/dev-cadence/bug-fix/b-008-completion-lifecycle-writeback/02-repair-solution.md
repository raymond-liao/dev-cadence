# B-008 修复方案（终态写回）

## ✅ Selected

扩展 Bug Fix 的 `Backlog Synchronization After Completion`：成功 merge 且身份检查通过后，先把 Bug 卡片 `Status` 更新为 `Done`，写入修复结果/集成引用和 Change Log，再把 Backlog 行移到已完成并移除并行表项；这些变更必须作为一个原子、幂等写入单元完成，任何冲突都不得部分写入。

## 修复边界

- 修改 `src/skills/bug-fix/SKILL.md` 和 `tests/bug-fix-backlog-sync-contract.sh`。
- 更新 B-008 卡片 Version `1 -> 2`，使范围和验收标准与 merge-only 终态一致。
- 同步 `docs/backlog.md` 中 B-008 的版本引用。
- 不扩散到 feature-dev/refactor，不新增工作项状态。

## 验收标准

1. 专项测试明确验证 Bug 卡片 `Done`、修复结果/集成引用、Change Log 和 Backlog 原子写回。
2. 卡片与 Backlog 任一可见事实冲突时零部分写入。
3. 非 merge 结果不写 `Done`。
4. 重复执行不会重复卡片记录或 Backlog 行。

## 风险

终态写回发生在 merge 后，冲突处理必须保守停止并请求用户决定；不得为追求自动闭环覆盖用户并发修改。
