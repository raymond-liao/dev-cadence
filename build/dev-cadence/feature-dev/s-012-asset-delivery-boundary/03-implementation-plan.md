# Asset And Delivery Workflow Record Boundary Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish one enforceable Asset/Delivery workflow record boundary without prematurely implementing S-013.

**Architecture:** The entry selector owns classification, persistence, continuation, and future-workflow rules. Existing Delivery skills declare the shared model they use; focused shell contracts protect the boundary and the generated package mirrors source.

**Tech Stack:** Markdown workflow skills, Bash contract tests, repository build scripts.

## Global Constraints

- Modify `src/` authority, never `dist/` directly.
- Keep S-013, S-011, S-002, and Work Item Planning implementation out of scope.
- Preserve all existing Delivery run evidence.

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Contract RED | Encode the record-model boundary before implementation. | `tests/asset-delivery-record-contract.sh`, `tests/run-all.sh` | Focused test fails for missing shared rules. |
| Task 2: Shared And Delivery GREEN | Add classification, persistence, continuation, and local Delivery declarations. | `src/skills/using-dev-cadence/SKILL.md`, three Delivery skills | Focused and symmetry tests pass. |
| Task 3: Product State | Close S-012 and recalculate direct successors. | Story files, `docs/backlog.md`, `version` | Status and dependency review. |
| Task 4: Distribution And Verification | Regenerate installed assets and verify all contracts. | `dist/.dev-cadence/**` generated | Build, whitespace, full checks, synchronization search. |

## Detailed Tasks

### Task 1: Contract RED

- [x] Add semantic assertions for both workflow classes and their members.
- [x] Assert Asset persistence prohibitions and authoritative-asset ownership.
- [x] Assert Delivery evidence retention, continuation signals, and future workflow model selection.
- [x] Run `bash tests/asset-delivery-record-contract.sh`; expect failure because the shared contract is absent.

### Task 2: Shared And Delivery GREEN

- [x] Add the shared record-model contract to `using-dev-cadence`.
- [x] Replace manifest-only continuation with category-specific continuation.
- [x] Add concise Delivery classification declarations to Feature Dev, Bug Fix, and Refactor.
- [x] Run focused, routing, Discovery, and workflow symmetry contracts; expect pass.

### Task 3: Product State

- [x] Mark S-012 Done with a Change Log entry.
- [x] Move S-012 to Backlog Done and remove it from the parallel table.
- [x] Mark S-013 and S-011 Ready; keep S-002 Blocked on S-013.
- [x] Increment `version` because installed workflow behavior changes.

### Task 4: Distribution And Verification

- [x] Run `bash scripts/build.sh`.
- [x] Run `bash scripts/check-whitespace.sh`.
- [x] Run fresh `bash scripts/check-all.sh`.
- [x] Search `src/` and `dist/.dev-cadence/` for synchronized key rules.
- [x] Perform whole-change review against S-012 acceptance criteria and close findings.

## Pre-Implementation Design Freshness

- Work item: `docs/stories/S-012-asset-delivery-workflow-record-boundary.md`, Version 1, Ready.
- Branch/base: `codex/s-012-asset-delivery-boundary` at `3cb8acacf0d7cee7c53b3ea7dd452fa99b764809`.
- Dependency: S-006 is Done and its final implementation is present.
- Material changes since confirmation: None in this isolated worktree.
- Conclusion: inputs remain valid; proceed without reconfirmation under the batch authorization.
