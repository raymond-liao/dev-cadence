# B-007 并行视图契约对齐修复计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 B-007 卡片与 B-009 已验收的并行视图职责边界一致。

**Architecture:** 保持四列表格和中心路由所有权不变，只修正长期规划资产中的过期要求。现有并行表契约作为可执行回归证据。

**Tech Stack:** Markdown planning assets、Bash、ripgrep。

## Global Constraints

- 不修改 `src/vendor/superpowers/**`。
- 不恢复逐行 Workflow 入口列。
- 纯 `docs/**` 更新不新增自然语言锁定测试。

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: 卡片对齐 | 更新 B-007 定义与版本引用 | B-007 卡片、`docs/backlog.md` | `bash tests/parallel-work-table-contract.sh` |

## Detailed Tasks

### Task 1: 卡片对齐

**Files:**
- Modify: `docs/bugs/B-007-parallel-work-table-entry-qualification.md`
- Modify: `docs/backlog.md`

- [ ] **Step 1: 记录基线**：运行 `bash tests/parallel-work-table-contract.sh`，预期通过并证明当前四列行为。
- [ ] **Step 2: 更新卡片**：将方案与验收标准对齐 B-009，Version 提升到 `2`，关闭 Q-005。
- [ ] **Step 3: 同步 Backlog**：只更新 B-007 的 Version，不改变状态和排序。
- [ ] **Step 4: 验证**：再次运行 `bash tests/parallel-work-table-contract.sh` 和 `git diff --check`，预期通过。
- [ ] **Step 5: 自审并提交**：确认无运行时规则变化、无路由列恢复，并按 executing-plans 提交审查门创建实现提交。

## Self-Review

- 需求覆盖：卡片口径、版本引用、Q-005 关闭和四列保护均有步骤。
- Placeholder scan：无未定义占位符。
- 一致性：B-009 继续作为当前架构决定来源。
