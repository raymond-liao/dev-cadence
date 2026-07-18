# B-009 Repair Implementation Record

- Workflow: `bug-fix`
- Work Item: [B-009 待处理排序与并行视图职责不一致](../../../../docs/bugs/B-009-pending-order-parallel-view-authority.md)
- Status: ✅ `confirmed`
- Implementation base SHA: `6e18954624df1df45f9afd9141191b002605b724`
- Final implementation SHA: `9e5983a8bc5ea6be36327d47b05a9b3854551a93`
- Implementation branch: `codex/fix-b009-pending-order-authority`

## Implementation Commits

- `61c2feae366bb914e527f0a46e8405f50f236c68`: restore pending order as parallel view authority.
- `7fe5e6b99a10825573424eb453d88ae94e1de762`: remove the residual parallel-view entry-gate field rule after review.
- `031f88e0f313edcf75d31e03b4d950eab088a710`: align Backlog parallel view with pending order and workflow ownership.
- `9e5983a8bc5ea6be36327d47b05a9b3854551a93`: enforce the updated planning and parallel-view contracts in tests and bump version to `0.24.0`.

## Completed Plan Tasks

- [x] Task 1: source rules define the pending-order authority, derived parallel view, no silent skip, lifecycle-only status, and routing ownership.
- [x] Task 2: Backlog and workflow documentation remove the parallel table's per-row workflow field and align row order; S-017 was verified already aligned and was not rewritten.
- [x] Task 3: tests and version updated; build and full contract checks passed.

## Original Reproduction And Repair Evidence

The baseline had a pending-order view beginning with `S-041` while the parallel table used an independent sequence and placed unrelated items before the pending order. The parallel table also repeated workflow entry rules. The repaired Backlog uses `并行组` as derived grouping, keeps pending work-item relative order, removes per-row route text, and states the lifecycle/routing boundary at table level.

## Checks Run

- `bash tests/work-item-planning-contract.sh` -> passed.
- `bash tests/parallel-work-table-contract.sh` -> passed.
- `bash tests/routing-contract.sh` -> passed.
- `bash scripts/build.sh` -> passed; source rules and version synchronized to `dist/.dev-cadence`.
- `bash scripts/check-whitespace.sh` -> passed.
- `bash scripts/check-all.sh` -> passed, including package, install, symmetry, confirmation-gate, parallel-view, and backlog-sync contracts.
- Source/dist `cmp` checks and changed-document local-link check -> passed.
- `git diff --check 6e18954..HEAD` -> passed.

## Code Review Evidence

- Report: `build/dev-cadence/bug-fix/b-009-pending-order-parallel-view-authority/04-code-review-report.md`
- Review decision: no Critical or Important findings remain.
- Critical findings: `0`
- Important findings: `0`
- Unresolved findings: `None`

## Skipped Checks And Concerns

- No UI, API, or runtime integration test applies; the changed deliverable is rule/documentation text and shell contract tests.
- Business Acceptance has not been recorded in this subtask; the main thread must make the final acceptance decision.
- No push, merge, branch deletion, worktree deletion, or B-009 re-claim was performed.
