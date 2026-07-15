# Goal-Driven Architecture Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the S-011 goal-driven Architecture Design Asset Workflow as an installable, routed, contract-tested capability.

**Architecture:** A dedicated workflow skill owns architecture-design behavior; the existing entry selector owns cross-workflow routing and Asset continuation; focused shell contracts protect semantics and the source tree is rebuilt into dist.

**Tech Stack:** Markdown workflow skills, Bash contract tests, repository build scripts.

## Global Constraints

- Modify `src/` authority, never `dist/` directly.
- Keep S-013 and S-002 implementation out of scope.
- Do not copy Discovery's temporary record exception into Architecture Design.

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Contract RED | Encode S-011 behavior before implementation. | `tests/architecture-design-contract.sh`, `tests/run-all.sh` | Focused test fails for missing workflow. |
| Task 2: Workflow GREEN | Implement the Asset Workflow and explicit routing. | `src/skills/architecture-design/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md` | Focused, routing, and record-model tests pass. |
| Task 3: Package And Guidance | Expose the workflow in distribution and user guidance. | package contract, README files, workflow guide | Package and focused contracts pass. |
| Task 4: Product State | Close S-011 and update release identity. | Story, Backlog, `version` | Status/dependency inspection. |
| Task 5: Review And Verification | Review the whole change and run fresh repository checks. | delivery run records | Full checks and synchronization search pass. |

## Detailed Tasks

### Task 1: Contract RED

- [x] Add semantic assertions for explicit trigger, confirmations, investigation, options, markers, output, diagrams, and non-goals.
- [x] Add package and runner integration.
- [x] Run the focused test and record the expected failure.

### Task 2: Workflow GREEN

- [x] Add the dedicated Architecture Design Asset Workflow skill.
- [x] Add explicit route, negative boundary, and Asset continuation rules to the entry selector.
- [x] Run focused routing and record-model contracts.

### Task 3: Package And Guidance

- [x] Enumerate the installed skill in the package contract.
- [x] Add concise English and Chinese workflow guidance and package-tree entries.
- [x] Add the maintainer-facing workflow explanation.

### Task 4: Product State

- [x] Mark S-011 Done and append its Change Log.
- [x] Move S-011 to Backlog Done and remove it from the parallel table.
- [x] Keep S-013 Ready and S-002 Blocked because this branch does not include S-013 completion.
- [x] Increment `version` because installable workflow behavior changes.

### Task 5: Review And Verification

- [x] Build dist from source.
- [x] Run focused checks, whitespace, and fresh full checks.
- [x] Verify synchronized key rules in source and dist.
- [x] Perform whole-change review and close findings.

### Task 6: Independent Review Fix

- [x] Add a failing negative contract for preset architecture scale/Scope classification naming.
- [x] Require `<goal-slug>` to express only the confirmed specific goal and prohibit Product, Capability, Work Item, or similar classification prefixes.
- [x] Rebuild, review the fix identity, and run fresh full verification.

## Pre-Implementation Design Freshness

- Work item: `docs/stories/S-011-goal-driven-architecture-workflow.md`, Version 2, Ready.
- Branch/base: `codex/s-011-architecture-design` at `c46f1d7c02333fc9648dcd9df4d4cbf3ea424d5a`.
- Dependencies: S-008 and S-012 are Done; S-012 final baseline is present.
- Material changes since confirmation: None in this isolated worktree.
- Conclusion: inputs remain valid; proceed without reconfirmation under the batch authorization.
