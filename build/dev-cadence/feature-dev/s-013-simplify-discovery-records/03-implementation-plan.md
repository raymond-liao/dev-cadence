# Implementation Plan

- Status: ✅ `confirmed`
- Workspace: `.worktrees/s-013-simplify-discovery-records`
- Branch: `codex/s-013-simplify-discovery-records`

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Define simplified contracts | Make legacy persistence requirements fail before implementation. | `tests/discovery-contract.sh`, `tests/asset-delivery-record-contract.sh` | Focused tests fail for missing simplified behavior. |
| Task 2: Simplify Discovery workflow | Keep conversational analysis and two authoritative assets while removing persistent process state. | `src/skills/discovery/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md` | Focused tests pass. |
| Task 3: Align user-facing documentation | Scope manifest evidence to Delivery Workflows and describe asset-only Discovery. | `docs/workflows/discovery.md`, `README.md`, `README.zh-CN.md` | Searches find no Discovery process-record claims. |
| Task 4: Close governance state | Complete S-013, unblock S-002, update release version, and build distribution. | `docs/stories/S-013-simplify-discovery-process-records.md`, `docs/backlog.md`, `version`, `dist/.dev-cadence/**` | Story/Backlog checks, build, source/dist parity. |
| Task 5: Review and verify | Produce review, test, acceptance, and completion evidence. | Current run records | Focused tests, whitespace, fresh `check-all`, key-rule searches. |

## Detailed Tasks

### Task 1: Define simplified contracts

- [x] Replace legacy artifact assertions with dual-authoritative-asset assertions.
- [x] Add negative assertions for manifests, stage records, confirmation records, and temporary S-013 exception text.
- [x] Run focused tests and capture expected RED failures.

### Task 2: Simplify Discovery workflow

- [x] Replace run-record and checkpoint sections with explicit Asset Workflow persistence and ordinary Git rules.
- [x] Rewrite stage rules so analysis remains in conversation and facts flow directly into the two documents.
- [x] Rewrite feedback, rejection, confirmation, and continuation behavior without a manifest.
- [x] Remove the using-dev-cadence temporary exception.
- [x] Run focused tests to GREEN.

### Task 3: Align user-facing documentation

- [x] Update the Discovery workflow guide and both READMEs.
- [x] Verify no user-facing text claims Discovery creates process records.

### Task 4: Close governance state

- [x] Mark S-013 Done and append its Change Log.
- [x] Move S-013 to Backlog completed, remove it from the parallel table, keep S-011 Ready, and mark S-002 Ready.
- [x] Bump the minor version because installed workflow behavior changes.
- [x] Run `bash scripts/build.sh` and verify source/dist parity.

### Task 5: Review and verify

- [x] Complete the executing-plans review ledger and final whole-change review.
- [x] Run focused contracts, whitespace, and fresh `bash scripts/check-all.sh`.
- [x] Complete System Testing and Business Acceptance records.
- [x] Commit only S-013 files and keep the branch for parent-session integration.
