# B-008 修复方案

- Status: `confirmed`
- Work Item: [B-008 Bug Fix 完成后未更新 Backlog](../../../../docs/bugs/B-008-bug-fix-completion-does-not-update-backlog.md)
- Diagnosis Source: [B-008 问题诊断记录](01-problem-diagnosis-record.md)
- Decision Authority: `delegated continuation authority from user instruction`

## 根因与修复边界

根因是 `bug-fix` Completion 记录了 finishing 结果，却没有把“成功集成”绑定到对应 Bug 的 Backlog 汇总更新。修复只修改 `bug-fix` Completion 规则与契约测试，不改变 Business Acceptance 菜单、不增加 Backlog 状态、不修改 `feature-dev` 或 `refactor`。

## ✅ Selected 修复方法：成功本地合并后回写 `Done`

在 finishing flow 返回并保留运行记录的结果中，只有实际 `merge` 到 base branch 才触发 Bug Backlog 同步：

1. 依据当前运行的 Bug ID 和已确认卡片 Version 定位 `docs/backlog.md` 行。
2. 验证当前 Backlog 行仍指向同一 Bug 和 Version；发生可见事实冲突时停止并要求用户处理，不覆盖冲突。
3. 将该行从 `待处理` 或 `进行中` 原子移动到 `已完成`，将状态改为 `Done`。
4. 从“当前可并行实施表”删除已完成 Bug；保持无关行、待处理排序、Dependency Table 和卡片正文不变。
5. 将实际同步结果写入 manifest、Business Acceptance 和 Completion follow-up evidence。

PR 创建、保留分支、discard cancelled/blocked、whole-run discard 或其他未实际合并到 base branch 的结果不得写入 `Done`；它们保留未完成的 Backlog 状态，并记录不回写原因。该选择以“完成并集成”作为 B-008 的完成定义，避免把已验收但尚未集成的分支误报为已交付。

## 备选方案与取舍

### Business Acceptance 后立即标记 `Done`

不选择。Business Acceptance 只表示用户接受修复结果，尚未证明代码已集成到目标分支；这会误标 PR、保留分支和取消集成路径。

### 所有非 discard Completion 结果都标记 `Done`

不选择。`keep` 和 PR 结果仍可能未进入 base branch，不能满足“完成并集成”的验收标准。

### ✅ Selected 以实际 merge 结果作为触发器

选择此方案。它直接绑定 B-008 的“完成并集成”语义，且能对取消、阻塞、丢弃和冲突保持不回写。

## 受影响文件与边界

- 修改 `src/skills/bug-fix/SKILL.md` Completion 规则，定义 Backlog 同步矩阵和冲突处理。
- 新增 `tests/bug-fix-backlog-sync-contract.sh` 并接入 `tests/run-all.sh`，覆盖成功 merge 与非 merge 分支。
- 运行 `bash scripts/build.sh`；本项不再次递增版本，继承 B-005 在本批次统一递增的 `0.23.0`。
- 不在修复实施阶段直接把 B-008 卡片标为 Done；卡片/Backlog 终态写回属于本运行 Completion 的最终集成动作。

## 修复验收标准

- 成功本地 merge 后 Bug 行进入 `已完成` 且状态为 `Done`。
- PR、keep、取消、阻塞和 whole-run discard 不写入 `Done`。
- 卡片 Version 冲突时停止，不覆盖 Backlog。
- 无关 Backlog 行和排序不变，已完成 Bug 从并行表移除。
- 契约测试、构建和全量检查通过。

## 风险

- Backlog 是 Markdown 资产，回写必须保持生命周期区段和表头契约，不能只修改单个状态字符串。
- 当前 workflow 文本是执行规则，不是可执行程序；契约测试需要验证触发矩阵和冲突保护，而不是假装存在运行时 API。

## 2026-07-18 补强方案

### ✅ Selected 卡片与 Backlog 原子终态写回

成功 `merge` 且身份/可见事实检查通过后，Completion 必须在同一个原子写入单元中：

1. 将 Bug 卡片 `Status` 更新为 `Done`。
2. 写入修复结果与集成引用，并追加不增加需求版本的执行 Change Log。
3. 将 Backlog 行移到已完成、改为 `Done`，并从并行表移除该 Bug。

任一冲突必须零部分写入；重复执行不得重复卡片引用、Change Log 或 Backlog 行。非 `merge` 结果继续保持不写 `Done`。
