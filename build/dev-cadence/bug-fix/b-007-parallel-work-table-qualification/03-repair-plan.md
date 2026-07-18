# B-007 修复计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task with verification checkpoints.

**Goal:** 让当前可并行实施表同时清晰表达卡片生命周期状态和下一步 Workflow 入口门禁。

**Architecture:** Backlog 继续是唯一规划汇总资产；并行表增加一个派生的入口资格列，不创建新状态、不复制运行记录。`work-item-planning` 源规则定义列语义和按工作项类型解释入口，契约测试验证源规则与 Backlog 示例一致。

**Tech Stack:** Markdown planning assets, Bash contract tests, generated Dev Cadence package.

## Global Constraints

- 修改 `src/skills/work-item-planning/SKILL.md`、`docs/backlog.md` 和相关测试；不编辑 `dist/.dev-cadence/**`。
- 不修改七个规范状态、Dependency Table 排序、并行序号或用户授权规则。
- 不把 Workflow 内部阶段写成 Backlog 状态。
- 先扩展契约测试并观察基线失败，再更新源规则和 Backlog。

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: View contract | 定义并行视图和入口资格列的源规则 | `src/skills/work-item-planning/SKILL.md` | 专项源规则断言 |
| Task 2: Backlog projection | 更新表头、每个并行行的入口资格和说明 | `docs/backlog.md` | Backlog 结构/语义断言 |
| Task 3: Contract coverage | 保护 Story、Task、Bug、Blocked 的差异 | `tests/parallel-work-table-contract.sh`, `tests/run-all.sh` | 专项脚本与全量测试 |
| Task 4: Package synchronization | 构建安装包并验证 source/dist 一致 | generated `dist/.dev-cadence/**` | `bash scripts/build.sh`, `bash tests/check-all.sh` |

## Detailed Tasks

### Task 1: View contract

**Files:**
- Modify: `src/skills/work-item-planning/SKILL.md` near Backlog And Planning Relationships.

- [x] Add a `Parallel Work View Contract` stating that the table is a candidate view, not a second status model or direct code-implementation board.
- [x] Define `状态` as card lifecycle only and `下一步 Workflow / 入口门禁` as an independent field.
- [x] Define Story, Task, Bug, and Blocked semantics without adding statuses or changing downstream gates.
- [x] Add a negative boundary that the view must not imply automatic start or direct code modification.
- [ ] Run the new contract test before the source edit and record the expected failure.

### Task 2: Backlog projection

**Files:**
- Modify: `docs/backlog.md:144-168`.

- [x] Keep the heading and row order unchanged.
- [x] Add the fifth column `下一步 Workflow / 入口门禁`.
- [x] Add explicit qualifications for every existing row: Story rows require `Ready` for `feature-dev`; Task rows route by confirmed goal; Bug rows allow `bug-fix` diagnosis but not code changes; Blocked rows remain dependency-blocked.
- [x] Keep card status values and `⚠️ Blocked` / `✅ Ready` presentation intact.
- [x] Preserve the existing rule that the table is used only after user authorization for parallel work.

### Task 3: Contract coverage

**Files:**
- Create: `tests/parallel-work-table-contract.sh`.
- Modify: `tests/run-all.sh`.

- [x] Assert the source contract and exact five-column Backlog header.
- [x] Assert the Backlog contains positive semantics for Draft Bug diagnosis and the prohibition on direct code changes.
- [x] Assert Story, Task, and Blocked qualification text exists.
- [x] Assert canonical statuses remain present and no new `可启动`/`可实施` status is introduced.
- [x] Run the standalone script and `bash tests/run-all.sh`.

### Task 4: Package synchronization

**Files:**
- Generate: `dist/.dev-cadence/**` with `bash scripts/build.sh`.

- [x] Run `bash scripts/build.sh`.
- [x] Run `bash tests/check-all.sh` from the worktree root.
- [x] Run `bash scripts/check-whitespace.sh` and `git diff --check`.
- [x] Record source and Backlog changes in `04-repair-record.md`; do not force-add generated `dist/`.

## Completion Conditions

- All six B-007 acceptance criteria have executed evidence.
- The parallel table has distinct state and entry qualification dimensions.
- No unrelated Backlog row or order changes are introduced.
- Whole-branch review has no unresolved Critical or Important findings.

## Plan Self-Review

- Scope coverage: source rule, Backlog projection, tests and package build are represented.
- Placeholder scan: all checks name concrete files and commands.
- Compatibility: no new status or automatic workflow start is introduced.

## 2026-07-18 设计对齐任务

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 5: B-009 决定对齐 | 清除 B-007 卡片中的过期第五列要求 | B-007 卡片、`docs/backlog.md` | `bash tests/parallel-work-table-contract.sh` |

- [x] 运行现有并行表契约，确认四列基线通过。
- [x] 将 B-007 Version 提升到 `2`，用表级职责边界替代逐行入口列要求，并关闭 Q-005。
- [x] 只同步 Backlog 中 B-007 的 Version，不改变状态和排序。
- [x] 同步 Open Question Registry 中 Q-005 的 `Resolved` 状态并保留权威来源链接。
- [x] 重新运行并行表契约和 `git diff --check`。
