# B-008 终态生命周期写回修复计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 Bug Fix 成功 merge 后原子同步 Bug 卡片和 Backlog 的完成事实。

**Architecture:** Completion 专用规则明确卡片写回字段和 Backlog 移动顺序，并以专项 shell 契约验证。保持共享 lifecycle contract 和 merge-only 触发条件不变。

**Tech Stack:** Markdown workflow skill、Bash、ripgrep。

## Global Constraints

- 只修改 `bug-fix` owning workflow，不扩散到其他 Delivery workflow。
- 不修改 `src/vendor/superpowers/**`。
- 修改 `src/skills/**` 后构建 `dist` 并更新根版本。

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: 原子终态写回 | 补齐卡片与 Backlog Completion 契约 | B-008 契约测试、Bug Fix skill、B-008 卡片、Backlog | `bash tests/bug-fix-backlog-sync-contract.sh` |

## Detailed Tasks

### Task 1: 原子终态写回

**Files:**
- Modify: `tests/bug-fix-backlog-sync-contract.sh`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `docs/bugs/B-008-bug-fix-completion-does-not-update-backlog.md`
- Modify: `docs/backlog.md`

- [ ] **Step 1: 写入失败契约**：断言卡片 `Done`、修复结果/集成引用、Change Log 与 Backlog 原子写入。
- [ ] **Step 2: 验证 RED**：运行 `bash tests/bug-fix-backlog-sync-contract.sh`，预期因 Completion 未明确卡片写回而失败。
- [ ] **Step 3: 最小实现**：补充 merge 路径的卡片写回、零部分写入和幂等要求。
- [ ] **Step 4: 更新规划资产**：B-008 Version 提升到 `2`，修正 merge-only 范围并同步 Backlog 版本。
- [ ] **Step 5: 验证 GREEN**：运行专项测试、`git diff --check`，预期通过。
- [ ] **Step 6: 自审并提交**：确认只修改 owning workflow，并按 executing-plans 提交审查门创建实现提交。

## Self-Review

- 需求覆盖：卡片状态、交付引用、Change Log、Backlog 移动、冲突和幂等均有步骤。
- Placeholder scan：无未定义占位符。
- 范围一致性：非 merge 路径保持不写 `Done`。
