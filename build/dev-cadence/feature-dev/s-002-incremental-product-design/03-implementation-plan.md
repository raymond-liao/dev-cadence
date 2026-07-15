# Implementation Plan

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Contract RED | Define executable incremental Discovery expectations. | `tests/discovery-contract.sh`, `tests/routing-contract.sh`, `tests/skill-description-contract.sh` | Focused test fails for missing behavior. |
| Task 2: Discovery modes | Implement routing, discovery, authority, mutation, version, question, and handoff rules. | `src/skills/discovery/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md` | Focused contracts pass. |
| Task 3: Public contract | Align workflow documentation, README, Story, Backlog, and release version. | `docs/workflows/discovery.md`, `README.md`, `README.zh-CN.md`, `docs/stories/S-002-discovery-prd-incremental-versioning.md`, `docs/backlog.md`, `version` | Text/state checks and build pass. |
| Task 4: Review and system test | Review the complete implementation and run repository verification. | Run records | Fresh focused, build, whitespace, full checks, parity checks. |

## Detailed Tasks

### Task 1: Contract RED

- [x] Add contract assertions for all S-002 acceptance boundaries.
- [x] Run `bash tests/discovery-contract.sh` and verify it fails because the old description lacks incremental behavior.

### Task 2: Discovery Modes

- [x] Replace first-only applicability with explicit initial and incremental selection.
- [x] Add repository candidate scanning, authority, migration, split, mixed-content, versioning, question, and work-item-impact rules.
- [x] Preserve the Asset Workflow no-record model.
- [x] Run focused contracts to GREEN.

### Task 3: Public Contract

- [x] Align public documentation and governance state.
- [x] Evaluate and update `version` because installed workflow behavior changes.
- [x] Build distribution and check source/dist parity.

### Task 4: Review And System Test

- [x] Review the complete diff against the card and repository rules.
- [x] Resolve the stale entry-selector example that still rejected incremental Discovery and add a regression contract.
- [x] Add an in-conversation proposal gate so incremental authority and supporting assets remain unchanged until consolidated confirmation.
- [x] Define independent PRD and Business Architecture responsibility versions for retained combined documents.
- [x] Align the Backlog delivery summary with pending Business Acceptance.
- [x] Run fresh focused and full verification.
- [x] Record System Testing and leave Business Acceptance pending.
