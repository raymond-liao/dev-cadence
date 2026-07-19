# B-011 Repair Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `subagent-driven-development` (recommended) or `executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure every claimed Delivery work item completes configuration-selected workspace preparation before the entry routes to the downstream workflow.

**Architecture:** `using-dev-cadence` becomes the single owner of claim-to-workspace bootstrap. The three Delivery Workflow skills consume that prepared workspace and their Plan stages only verify or reuse it. Bash contract tests encode the ordering and symmetry rules, while the build script mirrors source into the installed package.

**Tech Stack:** Markdown workflow skills, Bash contract tests, Git worktrees, existing build and install scripts.

## Global Constraints

- Preserve atomic card and Backlog claim semantics, Version handling, status model, Delivery stages, confirmation gates, and vendored Superpowers content.
- For `worktree.enabled: true`, the entry must create or verify the configured task worktree before routing downstream.
- For `worktree.enabled: false`, the entry must prepare a dedicated task branch and must not create a worktree.
- The task worktree `.worktrees/b-011-worktree-preparation` is already prepared and its `.dev-cadence.yaml` matches the primary configuration.
- Do not directly edit `dist/.dev-cadence/`; regenerate it with `bash scripts/build.sh`.
- Bump `version` from `0.26.2` to `0.26.3` because the installed workflow behavior changes.

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Lock the entry handoff | Make the strict three-step entry ordering fail before its rule exists, then add the entry rule. | `tests/work-item-development-workflow-contract.sh`, `src/skills/using-dev-cadence/SKILL.md` | Focused contract test RED then GREEN. |
| Task 2: Make Delivery Workflow consumption symmetric | Make Plan stages verify/reuse entry workspace rather than create it for the first time. | `tests/workflow-symmetry.sh`, three Delivery `SKILL.md` files | Symmetry test RED then GREEN. |
| Task 3: Align packaged guidance and version | Update the false-path user guidance, version, and generated package. | `src/AGENTS-snippet.md`, both READMEs, `version`, generated `dist/` | Build, package, and install contracts. |
| Task 4: Run delivery regression checks | Verify source/dist synchronization and all repository contracts. | No new source files | Whitespace, full check, focused source/dist searches. |

## Detailed Tasks

### Task 1: Lock the entry handoff

**Files:**

- Modify: `tests/work-item-development-workflow-contract.sh:60-72`
- Modify: `src/skills/using-dev-cadence/SKILL.md:194-196`

**Interfaces:**

- Consumes: the existing `assert_match` and `assert_order` helpers in the work-item development contract.
- Produces: an entry contract requiring `claim -> workspace preparation -> route downstream` and both configuration branches.

- [ ] **Step 1: Add the failing entry assertions.**

  Add these checks after the existing claim-before-worktree assertion:

  ```bash
  assert_match "workspace preparation gate" \
    'workspace preparation.*complete.*before.*route.*downstream' "$ENTRY_SKILL"
  assert_match "enabled worktree handoff" \
    'worktree\.enabled: true.*immediately.*create or verify.*worktree' "$ENTRY_SKILL"
  assert_match "disabled branch handoff" \
    'worktree\.enabled: false.*immediately.*prepare.*dedicated.*branch.*must not.*create.*worktree' "$ENTRY_SKILL"
  assert_order "claim -> workspace preparation -> downstream routing" \
    'claim it by atomically' \
    'workspace preparation.*complete.*before.*route.*downstream' \
    "$ENTRY_SKILL"
  ```

- [ ] **Step 2: Run the focused contract to verify RED.**

  Run: `bash tests/work-item-development-workflow-contract.sh`

  Expected: `FAIL` because the current entry lacks the workspace-preparation-before-routing invariant and both explicit configuration branches.

- [ ] **Step 3: Add the minimal entry-owned handoff rule.**

  Immediately after the atomic claim rule in `src/skills/using-dev-cadence/SKILL.md`, add a dedicated paragraph whose normative content is:

  ```markdown
  Workspace preparation must complete before the entry routes downstream. When `worktree.enabled: true`, immediately create or verify the configured task worktree; when `worktree.enabled: false`, immediately prepare a dedicated task branch and must not create a worktree. Verify the claimed card Version, `In Progress` status, and matching Backlog row in the selected workspace before routing any downstream Delivery Workflow.
  ```

  Keep the existing claim-before-branch/worktree wording and add an explicit prohibition on Requirements, Solution, Plan, checkpoint, or implementation work before this handoff completes.

- [ ] **Step 4: Run the focused contract to verify GREEN.**

  Run: `bash tests/work-item-development-workflow-contract.sh`

  Expected: `S-017 work-item development workflow contract checks passed.`

- [ ] **Step 5: Commit the atomic entry unit.**

  Stage only `tests/work-item-development-workflow-contract.sh` and `src/skills/using-dev-cadence/SKILL.md`, review the staged diff, then create one Conventional Commit: `fix(flow): prepare workspace before delivery routing`.

### Task 2: Make Delivery Workflow consumption symmetric

**Files:**

- Modify: `tests/workflow-symmetry.sh:535-565`
- Modify: `src/skills/feature-dev/SKILL.md:41-50, 136-139, 367-378`
- Modify: `src/skills/bug-fix/SKILL.md:41-50, 136-139, 326-337`
- Modify: `src/skills/refactor/SKILL.md:41-50, 181-184, 391-402`

**Interfaces:**

- Consumes: the entry-prepared workspace invariant from Task 1 and the `assert_workflows` helper.
- Produces: three matching Plan-stage contracts that verify/reuse an existing workspace without first creating it.

- [ ] **Step 1: Add the failing symmetry assertion.**

  Add this invocation near the existing configuration assertions:

  ```bash
  assert_workflows "entry-prepared workspace boundary" \
    "entry-prepared workspace.*must not.*first create" \
    "entry-prepared workspace.*must not.*first create" \
    "entry-prepared workspace.*must not.*first create"
  ```

- [ ] **Step 2: Run the symmetry contract to verify RED.**

  Run: `bash tests/workflow-symmetry.sh`

  Expected: `FAIL` because all three skills currently permit the Plan stage to create or verify the workspace for the first time.

- [ ] **Step 3: Replace the three duplicated first-creation contracts.**

  In each Delivery Workflow:

  ```markdown
  The entry-prepared workspace must be verified and reused at Plan stage; this stage must not first create a task branch or worktree.
  ```

  Update each configuration branch so `true` describes an entry-created or verified worktree and `false` describes an entry-prepared dedicated branch with no worktree. Change the Superpowers mapping output from `isolated workspace readiness` to `entry-prepared workspace verification`. Retain each workflow's existing plan-writing and implementation rules.

- [ ] **Step 4: Run the symmetry contract to verify GREEN.**

  Run: `bash tests/workflow-symmetry.sh`

  Expected: `Workflow symmetry checks passed.`

- [ ] **Step 5: Commit the symmetric workflow unit.**

  Stage only the symmetry test and three Delivery `SKILL.md` files, review the staged diff, then create one Conventional Commit: `fix(flow): reuse entry-prepared workspaces`.

### Task 3: Align packaged guidance and version

**Files:**

- Modify: `src/AGENTS-snippet.md:45-47`
- Modify: `README.md:163-167`
- Modify: `README.zh-CN.md:161-165`
- Modify: `version`
- Generate: `dist/.dev-cadence/`

**Interfaces:**

- Consumes: the confirmed false-path behavior from Tasks 1 and 2.
- Produces: installation guidance and a generated package whose text exactly matches source assets.

- [ ] **Step 1: Update user-facing configuration wording.**

  Replace each `worktree.enabled: false` description with wording equivalent to:

  ```text
  use an entry-prepared dedicated task branch and do not create a worktree
  ```

  Keep the `true` and directory descriptions unchanged except where they must say the entry performs the preparation.

- [ ] **Step 2: Update the package version.**

  Replace the complete content of `version` with:

  ```text
  0.26.3
  ```

- [ ] **Step 3: Build the installed package.**

  Run: `bash scripts/build.sh`

  Expected: `dist/.dev-cadence/` is regenerated from source; do not stage ignored `dist/` files.

- [ ] **Step 4: Verify package and install behavior.**

  Run: `bash tests/package-contract.sh && bash tests/install-contract.sh`

  Expected: both package source/dist comparisons and temporary-target installation replacement checks pass.

- [ ] **Step 5: Commit the guidance and release unit.**

  Stage only `src/AGENTS-snippet.md`, `README.md`, `README.zh-CN.md`, and `version`, review the staged diff, then create one Conventional Commit: `fix(flow): document prepared delivery workspaces`.

### Task 4: Run delivery regression checks

**Files:**

- No new source files.

**Interfaces:**

- Consumes: the completed source, test, documentation, version, and generated-package changes from Tasks 1-3.
- Produces: fresh evidence that the complete installed workflow remains internally consistent.

- [ ] **Step 1: Run whitespace validation.**

  Run: `bash scripts/check-whitespace.sh`

  Expected: exit code `0` with no whitespace failure.

- [ ] **Step 2: Run the full repository check.**

  Run: `bash scripts/check-all.sh`

  Expected: build, all contract tests, package synchronization, and install contract checks pass.

- [ ] **Step 3: Verify source and generated package contain the key invariant.**

  Run:

  ```bash
  rg --no-ignore -n 'workspace preparation.*complete.*before.*route.*downstream' \
    src/skills/using-dev-cadence/SKILL.md \
    dist/.dev-cadence/skills/using-dev-cadence/SKILL.md
  rg --no-ignore -n 'entry-prepared workspace.*must not.*first create' \
    src/skills/feature-dev/SKILL.md \
    src/skills/bug-fix/SKILL.md \
    src/skills/refactor/SKILL.md \
    dist/.dev-cadence/skills/feature-dev/SKILL.md \
    dist/.dev-cadence/skills/bug-fix/SKILL.md \
    dist/.dev-cadence/skills/refactor/SKILL.md
  ```

  Expected: every named source and generated skill reports the expected rule.

- [ ] **Step 4: Commit any in-scope verification-record update only.**

  Stage no source files unless a Task 1-3 correction is required. Record the commands and results in `04-repair-record.md` during Repair Implementation rather than creating an empty commit.

## Plan Self-Review

- Every B-011 acceptance criterion maps to Task 1, Task 2, Task 3, or Task 4.
- Task 1 and Task 2 each require a focused RED result before their minimal GREEN change.
- The Plan neither adds a workflow/skill nor changes the excluded lifecycle and Completion behavior.
- `dist/` is generated, source remains authoritative, and the version change is explicit.
- No task relies on undefined paths, tests, or commands.
