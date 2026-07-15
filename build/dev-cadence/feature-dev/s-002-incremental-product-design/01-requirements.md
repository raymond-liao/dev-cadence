# Requirements Confirmation

## Confirmed Scope

Implement S-002 Version 8: route explicit existing-baseline update intent into incremental Discovery only when a credible candidate exists; discover product-design assets by content while excluding generated, installed, dependency, and third-party trees; confirm ambiguous authority, optional migration, optional combined-document split, and historical mixed-content cleanup before mutation; independently version PRD and Business Architecture; coordinate local Open Questions and the Registry; and hand work-item impacts to `work-item-planning`.

Discovery remains an Asset Workflow. It must not create a Discovery manifest, stage record, confirmation record, or checkpoint record.

## Non-Goals

- Do not implement S-015 or modify work-item cards.
- Do not modify application code.
- Do not redesign S-006 classification or S-005 Registry ownership.

## Acceptance Criteria

The fifteen acceptance criteria in `docs/stories/S-002-discovery-prd-incremental-versioning.md` are authoritative.

## Assumptions And Open Questions

- The user's batch instruction delegates Requirements, Technical Solution, and Implementation Plan confirmation and forbids intermediate confirmation requests.
- Business Acceptance remains a distinct final decision and is not delegated.
- No open requirement question blocks implementation.
