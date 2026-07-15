# Goal-Driven Architecture Workflow Requirements

- Status: ✅ `confirmed`
- Source: `docs/stories/S-011-goal-driven-architecture-workflow.md`, Version 2
- Confirmation: delegated by the 2026-07-14 batch execution instruction

## Confirmed Scope

- Add an explicitly triggered `architecture-design` Asset Workflow.
- Confirm goal, design object, scope, non-scope, constraints, detail level, and output name before design.
- Investigate only the current state needed for the goal and record assumptions when it is unavailable.
- Compare two or three materially different options when meaningful alternatives exist.
- Produce one authoritative asset at `docs/architecture/<goal-slug>.md`, with Mermaid diagrams preferred.
- Apply shared solution markers without treating recommendation as selection.
- Route explicit architecture design, proposal, and review requests to the workflow.
- Package and contract-test the workflow.

## Non-Goals

- No automatic trigger from repository state, Discovery, or delivery activity.
- No fixed Product, Capability, or Work Item architecture classification.
- No implementation plan, code change, system test, deployment, or work-item decomposition by this workflow.
- No run manifest, stage record, confirmation record, or checkpoint commit for an architecture-design run.
- No replacement for delivery workflow Technical, Repair, or Refactor Solution records.

## Acceptance Criteria

All 12 acceptance criteria in S-011 Version 2 are authoritative and must be covered by focused contracts and final verification.

## Assumptions And Open Questions

- The user's batch authorization confirms the Ready card and delegates in-scope design decisions without intermediate confirmation.
- No open questions remain on the card.
