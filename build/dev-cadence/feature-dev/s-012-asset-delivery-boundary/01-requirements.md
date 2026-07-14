# Requirements Confirmation

- Status: ✅ `confirmed`
- Source: [S-012 Asset 与 Delivery Workflow 记录边界](../../../../docs/stories/S-012-asset-delivery-workflow-record-boundary.md)
- Confirmation basis: 2026-07-14 batch execution authorization; Story Version 1 is Ready with no Open Questions.

## Confirmed Scope

- Define `Asset Workflow` as Discovery, Work Item Planning, and Architecture Design.
- Define `Delivery Workflow` as Feature Dev, Bug Fix, and Refactor.
- Establish one shared record-model contract in the workflow entry selector.
- Asset workflows persist business facts only in authoritative `docs/` assets and do not create run manifests, stage records, confirmation records, checkpoint commits, or duplicate process evidence.
- Delivery workflows retain their complete implementation-run evidence chain, including requirements or diagnosis/scope, solution, plan, implementation, review, test, acceptance, and Completion evidence.
- Continuation uses manifest evidence for Delivery workflows and conversation, user goal, and authoritative assets for Asset workflows.
- Require every future workflow to choose exactly one record model.
- Add executable contract coverage and synchronize the installed package.

## Non-Goals

- Do not remove Discovery process records in this Story; S-013 owns that migration.
- Do not implement Work Item Planning, Architecture Design, incremental Discovery, or any adjacent workflow.
- Do not alter historical run records or move Delivery process state into business assets.

## Acceptance Criteria

All ten acceptance criteria in S-012 Version 1 are in scope. The transition rule is explicit: this Story establishes the shared Asset contract and classifies Discovery, while S-013 performs the existing Discovery implementation migration without weakening the new boundary.

## Open Questions And Assumptions

- Open Questions: None.
- Assumption: Shared classification belongs in `using-dev-cadence`; Delivery skills declare conformance locally, while S-013 updates Discovery's legacy record-producing implementation.
