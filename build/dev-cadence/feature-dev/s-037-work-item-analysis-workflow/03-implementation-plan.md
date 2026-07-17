# S-037 工作项分析 Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 新增可安装、可路由、可验证的 Work Item Analysis Asset Workflow。

**Architecture:** 以一个 `src/skills/work-item-analysis/SKILL.md` 承载 Story/Task/Bug 分析规则，入口仍由 `using-dev-cadence` 集中路由；业务说明、双语 README、契约测试和构建产物保持同步。共享版本由主代理在最终集成时升级。

**Tech Stack:** Markdown skill 文档、Bash 契约测试、现有构建/安装脚本和 vendored Superpowers 规则。

## Global Constraints

- 不直接编辑 `dist/.dev-cadence/**`；通过 `bash scripts/build.sh` 生成。
- Asset Workflow 不创建自己的 `build/dev-cadence` manifest；本 Feature Dev 记录只保存实现证据。
- 不修改产品设计资产、Story Map、Milestone、Size、Iteration Plan 或 Backlog 排序。
- 保持 `work-item-analysis` 与 `feature-dev`、`bug-fix`、`refactor` 的职责边界。
- 每个实现步骤先增加失败契约检查，再写最小规则。

## Task Overview

| Task | Goal | Files | Verification |
|---|---|---|---|
| Task 1: Contract RED | 锁定新 workflow 的安装、路由和语义边界 | `tests/work-item-analysis-contract.sh`, `tests/run-all.sh` | focused contract fails first |
| Task 2: Workflow skill | 新增可执行的 Work Item Analysis 规则 | `src/skills/work-item-analysis/SKILL.md` | focused contract passes |
| Task 3: Routing and docs | 接入集中路由和双语用户说明 | `src/skills/using-dev-cadence/SKILL.md`, `README.md`, `README.zh-CN.md` | routing/package checks pass |
| Task 4: Package integration | 构建并验证 source/dist/install parity | generated dist, tests | `bash scripts/check-all.sh` |
| Task 5: Planning bookkeeping | 记录 S-037 Ready 状态和实现结果 | `docs/stories/S-037-work-item-analysis-workflow.md`, feature records | link/status review |

## Detailed Tasks

### Task 1: Contract RED

**Files:**
- Create: `tests/work-item-analysis-contract.sh`
- Modify: `tests/run-all.sh`

- [ ] Add assertions for skill existence, Asset Workflow boundary, single/batch modes, Story/Task/Bug fields, Story Ready gate, Task/Bug exceptions, card reuse/version conflict, product/planning/diagnosis boundaries, and no delivery records.
- [ ] Add the test to `tests/run-all.sh` following existing contract ordering.
- [ ] Run `bash tests/work-item-analysis-contract.sh` and verify the expected failure because the skill is absent.

### Task 2: Workflow skill

**Files:**
- Create: `src/skills/work-item-analysis/SKILL.md`

- [ ] Translate the confirmed business workflow into imperative execution rules.
- [ ] Preserve the three-stage analysis sequence and batch-scope boundary.
- [ ] Define Story, Task, Bug analysis fields and their distinct readiness/diagnosis rules.
- [ ] Define card reuse, versioning, Change Log, conflict stop, user confirmation and downstream handoff.
- [ ] Run `bash tests/work-item-analysis-contract.sh` and verify it passes.

### Task 3: Routing and docs

**Files:**
- Modify: `src/skills/using-dev-cadence/SKILL.md`
- Modify: `README.md`
- Modify: `README.zh-CN.md`

- [ ] Add Work Item Analysis to the available-flow table and flow-priority boundaries.
- [ ] Ensure direct implementation remains routed to Feature Dev/Bug Fix/Refactor after analysis, not to Work Item Analysis.
- [ ] Add concise English and Simplified Chinese installation/workflow descriptions without duplicating the full skill.
- [ ] Run routing and focused package checks.

### Task 4: Package integration

**Files:**
- Generated: `dist/.dev-cadence/**`

- [ ] Run `bash scripts/build.sh`.
- [ ] Run `bash scripts/check-whitespace.sh`.
- [ ] Run `bash scripts/check-all.sh`.
- [ ] Verify source/dist parity for the new skill and route; leave root `version` for main integration.

### Task 5: Planning bookkeeping

**Files:**
- Modify: `docs/stories/S-037-work-item-analysis-workflow.md`
- Modify: `build/dev-cadence/feature-dev/s-037-work-item-analysis-workflow/*`

- [ ] Change S-037 status from `Blocked` to `Ready` without incrementing Version because only execution status changes.
- [ ] Record the implementation, review, test and integration evidence in the Feature Dev records.
- [ ] Verify local Markdown links and confirm no Backlog ordering changes.

