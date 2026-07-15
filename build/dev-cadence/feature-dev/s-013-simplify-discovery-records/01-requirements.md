# Requirements Confirmation

- Status: ✅ `confirmed`
- Source: `docs/stories/S-013-simplify-discovery-process-records.md`, Version 1
- Confirmation basis: The user explicitly authorized uninterrupted completion and deferred material decisions to the final summary.

## Confirmed Scope

- Preserve the five Discovery analysis stages and the final consolidated user-confirmation gate as conversation behavior.
- Make PRD and Business Architecture the only persistent Discovery outputs.
- Remove Discovery manifests, stage records, confirmation records, dedicated-branch requirements, workflow checkpoints, and checkpoint hash bookkeeping.
- Continue or resume Discovery from the conversation, user goal, and authoritative product-design documents rather than a manifest.
- Preserve the first-baseline-only boundary and all existing product/technical content responsibilities.
- Update source skills, workflow and README descriptions, generated package, contract tests, Story, Backlog, and version as required.

## Non-Goals

- No S-002 incremental baseline implementation.
- No migration or deletion of historical Discovery run records.
- No changes to Feature Dev, Bug Fix, or Refactor record models.
- No changes to PRD and Business Architecture content ownership.

## Acceptance Criteria

The twelve acceptance criteria in the S-013 card are authoritative. Contract coverage must prove absence of process records, presence of exactly two durable asset paths, confirmation behavior, content boundaries, continuation behavior, and the first-baseline guard.

## Assumptions And Open Questions

- Assumption: ordinary target-repository Git rules remain available for user-requested commits, but Discovery must not characterize them as workflow checkpoints.
- Open questions: None.
