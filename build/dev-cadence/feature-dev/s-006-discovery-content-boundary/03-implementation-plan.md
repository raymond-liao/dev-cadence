# Implementation Plan

- Status: ✅ `confirmed`
- Requirements: [Requirements Confirmation](01-requirements.md)
- Technical solution: [Technical Solution](02-technical-solution.md)

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Contract RED | Encode the S-006 behavior before implementation. | `tests/discovery-contract.sh` | Focused contract fails for missing boundary rules. |
| Task 2: Discovery boundary GREEN | Add classification, document ownership, transfer, and stage gates. | `src/skills/discovery/SKILL.md` | Focused contract passes. |
| Task 3: Public documentation and state | Explain the behavior and close the Story/backlog dependency. | `docs/workflows/discovery.md`, `docs/stories/S-006-discovery-product-technical-content-boundary.md`, `docs/backlog.md`, `version` | Review diff and link/contract checks. |
| Task 4: Distribution and verification | Regenerate installed assets and run repository checks. | `dist/.dev-cadence/**` (generated) | Build, whitespace, all checks, and `rg --no-ignore` synchronization. |

## Detailed Tasks

### Task 1: Contract RED

- [x] Add focused assertions covering all S-006 acceptance categories to `tests/discovery-contract.sh`.
- [x] Run `bash tests/discovery-contract.sh`.
- [x] Confirm failure is caused by missing content-boundary rules.

### Task 2: Discovery Boundary GREEN

- [x] Add a shared classification and disposition procedure to the Discovery skill.
- [x] Define allowed PRD and Business Architecture content and concrete forbidden implementation mechanisms.
- [x] Add initial-baseline pre-write checks, future incremental-input behavior, and final-summary evidence.
- [x] Run `bash tests/discovery-contract.sh` and confirm it passes.

### Task 3: Public Documentation And State

- [x] Update the Discovery workflow guide with the same ownership and transfer model.
- [x] Mark S-006 Done, add its Change Log entry, move it to Backlog Done, remove it from the parallel table, and mark S-012 Ready.
- [x] Increment `version` from `0.13.0` to `0.14.0` because installed workflow behavior changes.

### Task 4: Distribution And Verification

- [x] Run `bash scripts/build.sh`.
- [x] Run `bash scripts/check-whitespace.sh`.
- [x] Run `bash scripts/check-all.sh`.
- [x] Use `rg --no-ignore` to confirm key rules exist in both `src/` and generated `dist/.dev-cadence/`.
- [x] Review the complete diff against all S-006 acceptance criteria.

## Pre-Implementation Design Freshness

The Story remains Version 1 and Ready, S-005 is Done, the branch is based at `37e86d5bb2bccd69510251a9f48f61e2601a08b9`, and no material repository change invalidates this plan. Result: proceed.
