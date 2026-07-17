# S-016 统一 Backlog 看板 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将 Backlog 的统一生命周期表格和规划维护边界固化为可安装、可验证的 Work Item Planning 契约。

**Architecture:** 继续由 `src/skills/work-item-planning/SKILL.md` 作为唯一执行规则源，`docs/backlog.md` 作为权威实例，业务说明和契约测试作为同步验证层。共享根版本由主代理在最终集成时更新。

**Tech Stack:** Markdown 规则文档、Bash 契约测试、现有 `scripts/build.sh` 和 `scripts/check-all.sh`。

## Global Constraints

- 不直接编辑 `dist/.dev-cadence/**`；通过 `bash scripts/build.sh` 生成。
- 不修改“当前可并行实施表”的排序。
- 不新增工作项状态，不复制卡片正文或 workflow 内部阶段。
- 保持 `docs/backlog.md` 现有工作项顺序和相对链接。
- 每个实现步骤先增加失败检查，再实现最小规则并运行对应检查。

## Task Overview

| Task | Goal | Files | Verification |
|---|---|---|---|
| Task 1: Backlog contract RED | 锁定统一区块、列和所有权规则 | `tests/work-item-planning-contract.sh` | focused contract fails for missing rules |
| Task 2: Source rule | 将 Backlog 维护契约写入 Work Item Planning | `src/skills/work-item-planning/SKILL.md`, `docs/workflows/work-item-planning.md` | focused contract passes |
| Task 3: Authoritative instance | 将 Backlog 生命周期区块迁移为五列表格并保持顺序 | `docs/backlog.md` | structural inspection and link check |
| Task 4: Package verification | 构建并验证 source/dist/package parity | generated dist, test outputs | `bash scripts/check-all.sh` |

## Detailed Tasks

### Task 1: Backlog contract RED

**Files:**
- Modify: `tests/work-item-planning-contract.sh`
- Test: `tests/work-item-planning-contract.sh`

- [ ] Add assertions for authoritative Backlog ownership, four lifecycle sections, five columns, pending-row order, no duplicate card detail, and no parallel-table reorder.
- [ ] Run `bash tests/work-item-planning-contract.sh` and verify it fails because the source skill lacks the new literals.

### Task 2: Source rule

**Files:**
- Modify: `src/skills/work-item-planning/SKILL.md`
- Modify: `docs/workflows/work-item-planning.md`

- [ ] Add the normative Backlog contract to the source skill, including ownership, four sections, five columns, ordering, relationship boundaries, and closed-history handling.
- [ ] Mirror the business explanation in `docs/workflows/work-item-planning.md` without adding a second authority.
- [ ] Run `bash tests/work-item-planning-contract.sh` and verify it passes.

### Task 3: Authoritative instance

**Files:**
- Modify: `docs/backlog.md`

- [ ] Convert only the four lifecycle sections to Markdown tables with `ID`, `Title`, `Version`, `Status`, `Priority`.
- [ ] Populate Version and Status from each linked card without changing item order, dependency rows, or the parallel implementation table.
- [ ] Verify every new relative card link exists and no unrelated document is changed.

### Task 4: Package verification

**Files:**
- Generated: `dist/.dev-cadence/**`

- [ ] Run `bash scripts/build.sh`.
- [ ] Run `bash scripts/check-whitespace.sh`.
- [ ] Run `bash scripts/check-all.sh`.
- [ ] Confirm source/dist parity for the Backlog rules; leave root `version` unchanged for the main integration step.

