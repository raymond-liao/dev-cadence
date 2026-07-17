# B-008 修复计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task with verification checkpoints.

**Goal:** 将 Bug Fix 的成功实际集成结果可靠回写到 Backlog `Done`，并保护所有未集成路径不被误标完成。

**Architecture:** Completion 规则拥有 Bug Fix 交付结果与回写触发时机；Backlog 继续由 Work Item Planning 定义结构。规则用明确的 finishing-result 矩阵连接两者，契约测试验证正向 merge、负向非 merge 和冲突保护。

**Tech Stack:** Markdown workflow rules, Bash contract tests, generated Dev Cadence package.

## Global Constraints

- 只修改 `src/skills/bug-fix/SKILL.md`、`tests/**` 和生成的 `dist/`；不修改 `feature-dev` 或 `refactor`。
- 不改变 Business Acceptance 固定菜单和 Backlog 状态枚举。
- `Done` 只能表示已实际集成到 base branch 的 Bug Fix。
- 先加入失败契约断言，再修改规则；每个正向/负向分支都必须有可重复证据。

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Completion trigger matrix | 定义 merge 才回写和其他结果不回写的规则 | `src/skills/bug-fix/SKILL.md` | 专项源规则断言 |
| Task 2: Backlog sync contract | 验证成功、非成功和冲突分支 | `tests/bug-fix-backlog-sync-contract.sh`, `tests/run-all.sh` | 专项脚本与全量测试 |
| Task 3: Package synchronization | 生成安装包并验证契约一致 | generated `dist/.dev-cadence/**` | `bash scripts/build.sh`, `bash tests/check-all.sh` |

## Detailed Tasks

### Task 1: Completion trigger matrix

**Files:**
- Modify: `src/skills/bug-fix/SKILL.md` in Completion after normalized finishing results.

- [x] Add the post-Completion Backlog synchronization responsibility and exact success trigger `merge`.
- [x] Define Bug ID/Version lookup, conflict stop, atomic lifecycle move, parallel-row removal, and preservation of unrelated order.
- [x] Define non-write behavior for PR, keep, discard cancelled/blocked and whole-run discard.
- [x] Require manifest, Business Acceptance, and follow-up evidence to record the actual sync result.
- [ ] Run the new contract test before the rule edit and record the expected failure.

### Task 2: Backlog sync contract

**Files:**
- Create: `tests/bug-fix-backlog-sync-contract.sh`.
- Modify: `tests/run-all.sh`.

- [x] Assert the source defines `merge` as the only successful write trigger.
- [x] Assert the source explicitly excludes PR, keep, cancellation, blocking and whole-run discard from `Done` writeback.
- [x] Assert conflict, atomic move, unrelated-order preservation and parallel-row removal requirements.
- [x] Run the standalone script and `bash tests/run-all.sh`.

### Task 3: Package synchronization

**Files:**
- Generate: `dist/.dev-cadence/**` with `bash scripts/build.sh`.

- [x] Run `bash scripts/build.sh`.
- [x] Run `bash tests/check-all.sh`.
- [x] Run `bash scripts/check-whitespace.sh` and `git diff --check`.
- [x] Record final implementation and review evidence in `04-repair-record.md`.

## Completion Conditions

- All B-008 acceptance criteria have executed evidence.
- No non-merge Completion result can be interpreted as a completed Backlog delivery.
- The source package and generated installation package are synchronized.
- Whole-branch review has no unresolved Critical or Important findings.

## Plan Self-Review

- Scope coverage: trigger rule, negative branches, tests and package validation are represented.
- Placeholder scan: all steps name concrete files and commands.
- Boundary check: Backlog structure remains planning-owned; Bug Fix only performs the delivery-result writeback.
