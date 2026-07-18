# S-017 工作项卡片与开发 Workflow 接入 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make work-item selection, card identity/version capture, and lifecycle/Backlog writeback explicit and symmetric across the entry selector and the three Delivery Workflows.

**Architecture:** Keep claiming and intent-based routing in `using-dev-cadence`, where cross-workflow orchestration already belongs. Add compact workflow-specific integration contracts to Feature Dev, Bug Fix, and Refactor, and protect them with focused shell contract tests plus existing routing/symmetry tests. Do not add a new skill or copy card bodies into Delivery records.

**Tech Stack:** Markdown workflow rules, Bash contract tests, `rg`, `bash scripts/build.sh`, and the existing Dev Cadence package/install checks.

## Global Constraints

- Preserve S017 card Version `5`; execution-status-only changes must not increment Version or Change Log.
- Keep `docs/` cards as durable work-item authority and `build/dev-cadence/` as Delivery evidence.
- Do not modify `src/vendor/superpowers/**`.
- Do not add a workflow or shared capability skill.
- Do not push, merge, create a PR, or delete the worktree without an explicit Completion decision.
- Update root `version` to `0.25.0` because installed workflow behavior changes.

## Task Overview

| Task | Goal | Files | Verification |
|---|---|---|---|
| Task 1: Entry claim and routing contract | Define explicit implementation routing, Backlog order authority, claim timing, duplicate-claim protection, and missing-card responsibility. | `src/skills/using-dev-cadence/SKILL.md`, `tests/routing-contract.sh`, `tests/work-item-development-workflow-contract.sh` | Focused new contract initially fails, then passes with routing contract. |
| Task 2: Delivery card integration symmetry | Add Ready Story/Task/Bug gates, exact card identity/version capture, freshness rollback, and lifecycle writeback to all three Delivery skills. | `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, `src/skills/refactor/SKILL.md`, `tests/workflow-symmetry.sh`, `tests/work-item-development-workflow-contract.sh` | Focused symmetry and S017 contracts pass. |
| Task 3: Package, version, and repository verification | Synchronize package behavior and verify all acceptance criteria against source, distribution, installation, whitespace, and full contracts. | `version`, `dist/.dev-cadence/**` generated only, `tests/*.sh` as needed | `bash scripts/build.sh`, `bash tests/run-all.sh`, `bash scripts/check-whitespace.sh`, source/dist checks. |

## Detailed Tasks

### Task 1: Entry claim and routing contract

**Files:**
- Modify: `tests/routing-contract.sh`
- Create: `tests/work-item-development-workflow-contract.sh`
- Modify: `src/skills/using-dev-cadence/SKILL.md`

**Interfaces:**
- Consumes: existing `work-item-planning`, `work-item-analysis`, and Delivery route boundaries.
- Produces: normative entry rules for `claim_work_item`, including explicit implementation intent, card reuse, Backlog pending-order selection, synchronized `In Progress` writes, and no duplicate claim.

- [x] **Step 1: Write failing contract assertions**

  Add shell assertions for: implementation-only claim trigger; `待处理` as sole order authority; parallel view as derived context; pre-branch/worktree claim ordering; card/Backlog atomic synchronization; `Draft Story -> work-item-analysis -> Ready Story -> feature-dev`; Task and Bug exceptions; missing-card intent routing; no claim for discussion/analysis/status-only; no duplicate `In Progress` claim; and no new skill.

- [x] **Step 2: Run the focused contract to verify RED**

  Run: `bash tests/work-item-development-workflow-contract.sh`

  Expected: FAIL on the first missing S017 contract phrase because the new entry orchestration rules do not yet exist.

- [x] **Step 3: Add the entry orchestration rules**

  Add one `Work Item Intake And Claiming` section to `src/skills/using-dev-cadence/SKILL.md` near routing/flow priority. Keep it as the single owner of claim timing, reuse `work-item-planning`/`work-item-analysis` instead of creating a new skill, and preserve existing flow selection examples.

- [x] **Step 4: Run focused routing contracts**

  Run: `bash tests/work-item-development-workflow-contract.sh && bash tests/routing-contract.sh`

  Expected: both exit 0 and report their contract checks passed.

- [x] **Step 5: Review scope and commit the task**

  Inspect `git diff -- src/skills/using-dev-cadence/SKILL.md tests/routing-contract.sh tests/work-item-development-workflow-contract.sh`, then commit only Task 1 files with a Conventional Commit message.

### Task 2: Delivery card integration symmetry

**Files:**
- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`
- Modify: `tests/workflow-symmetry.sh`
- Modify: `tests/work-item-development-workflow-contract.sh`

**Interfaces:**
- Consumes: Task 1's card claim identity and the existing workflow-specific stage/Completion rules.
- Produces: identical card identity/version/freshness/writeback invariants, with Feature/Bug Fix/Refactor-specific route and terminal language preserved.

- [x] **Step 1: Extend failing tests for the shared Delivery contract**

  Assert all three skills include: exact card path/type/Version/scope in the first stage; Ready Story-only Feature Dev gate; Task and Bug non-unified gates; conflict stop and Active Task Change Handling; start/rework/acceptance/Completion writeback; idempotent Backlog synchronization; and no false `Done` on non-integrated outcomes.

- [x] **Step 2: Run focused tests to verify RED**

  Run: `bash tests/workflow-symmetry.sh`

  Expected: FAIL on the first missing shared Delivery card-integration assertion.

- [x] **Step 3: Add symmetric workflow sections**

  Add a compact `Work Item Card Integration` section to each Delivery skill after Stage Records/active-task rules. Use the workflow's existing nouns (`feature`, `bug`, `refactor`) and terminal semantics, but keep the invariant sequence identical: read identity -> verify Version/visible facts -> record selected scope -> write lifecycle results atomically -> preserve Backlog order and derived parallel view -> stop on conflict.

- [x] **Step 4: Run focused tests to verify GREEN**

  Run: `bash tests/workflow-symmetry.sh && bash tests/work-item-development-workflow-contract.sh && bash tests/bug-fix-backlog-sync-contract.sh`

  Expected: all exit 0 with no contract failures.

- [x] **Step 5: Review scope and commit the task**

  Inspect the complete staged diff for the three workflow skills and tests, then commit only Task 2 files with a Conventional Commit message.

### Task 3: Package, version, and repository verification

**Files:**
- Modify: `version`
- Generated: `dist/.dev-cadence/**` via `bash scripts/build.sh` (ignored; do not force-add)

**Interfaces:**
- Consumes: completed source skill and contract changes from Tasks 1-2.
- Produces: installable Dev Cadence package at version `0.25.0` with source/dist parity and full verification evidence.

- [x] **Step 1: Update the root version**

  Change `version` from `0.24.0` to `0.25.0`, because the installed workflow rules and routing behavior change.

- [x] **Step 2: Build the distribution package**

  Run: `bash scripts/build.sh`

  Expected: `dist/.dev-cadence/` is regenerated from `src/` and reports the new package version.

- [x] **Step 3: Verify source/dist parity and focused contracts**

  Run: `cmp -s src/skills/using-dev-cadence/SKILL.md dist/.dev-cadence/skills/using-dev-cadence/SKILL.md`, the equivalent `cmp` checks for `feature-dev`, `bug-fix`, and `refactor`, then `bash tests/work-item-development-workflow-contract.sh`, `bash tests/workflow-symmetry.sh`, and `bash scripts/check-whitespace.sh`.

  Expected: all comparisons and checks exit 0.

- [x] **Step 4: Run the complete repository verification**

  Run: `bash tests/run-all.sh`

  Expected: every package, install, routing, workflow symmetry, record, configuration, and whitespace contract passes.

- [x] **Step 5: Record implementation evidence**

  Update `04-implementation-record.md`, the manifest, and checklist items with final changed files, commits, focused checks, full verification, residual risks, and source/dist identity before entering System Testing.

## Plan Self-Review

- Coverage: Tasks 1-3 cover all nine S017 acceptance criteria, the no-new-skill boundary, package synchronization, and version assessment.
- Placeholder scan: no `TODO`, `TBD`, or unspecified implementation step remains.
- Scope: no Story Map redesign, Work Item Analysis implementation, vendored Superpowers change, or unrelated workflow-count audit is included.

## Stage Decision

- Status: ✅ `confirmed`
- Confirmation: delegated by the user on `2026-07-18`; no intermediate confirmation required.
- Development Implementation may start after the pre-implementation freshness gate.
