# B-005 终态确认门回归修复计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让三个 Delivery workflow 的终态决策始终展示固定选项，并阻止委托继续替代用户终态选择。

**Architecture:** 在 owning workflow skill 中增加对称的终态提示契约，以现有 shell 契约测试验证关键语义。保持 Business Acceptance 与 Completion 的现有选项和归一化逻辑不变。

**Tech Stack:** Markdown workflow skills、Bash、ripgrep。

## Global Constraints

- 不修改 `src/vendor/superpowers/**`。
- 不新增状态或终态选项。
- 修改 `src/skills/**` 后必须构建 `dist`。

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: 终态提示契约 | 固化菜单呈现与委托边界 | `tests/confirmation-gates-contract.sh`、三个 Delivery `SKILL.md` | `bash tests/confirmation-gates-contract.sh` |

## Detailed Tasks

### Task 1: 终态提示契约

**Files:**
- Modify: `tests/confirmation-gates-contract.sh`
- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`

- [ ] **Step 1: 写入失败契约**：断言同一消息展示完整 Business Acceptance 菜单，并断言 delegated continuation 不能形成 Business Acceptance 或 Completion 决策。
- [ ] **Step 2: 验证 RED**：运行 `bash tests/confirmation-gates-contract.sh`，预期因缺少终态提示契约失败。
- [ ] **Step 3: 最小实现**：在三个 Delivery skill 中加入对称的 Decision Prompt Contract 和 Completion 委托边界。
- [ ] **Step 4: 验证 GREEN**：运行 `bash tests/confirmation-gates-contract.sh`，预期通过。
- [ ] **Step 5: 自审并提交**：检查三文件对称性、无 vendor 修改，并按 executing-plans 提交审查门创建实现提交。

## Self-Review

- 需求覆盖：菜单呈现、三项选项、委托边界、Completion 交接均有任务覆盖。
- Placeholder scan：无未定义占位符。
- 一致性：三个 Delivery workflow 使用相同终态契约，保留各自阶段名。
