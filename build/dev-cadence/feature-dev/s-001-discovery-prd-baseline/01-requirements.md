# Requirements Confirmation: S-001 Initial Discovery And PRD Baseline

## Work Item Source

- Work Item: `S-001`
- Card: `docs/stories/S-001-initial-discovery-prd-baseline.md`
- Card Version At Workflow Start: `3`
- Current Card Version: `4`
- Business Flow: `docs/workflows/discovery.md`

## User Outcome

A user planning a software product or new capability can clarify the problem, goals, scope, and constraints before development so the team shares one understanding of what should be built.

## Confirmed Scope Proposed For This Run

- Add a new `discovery` workflow skill as a source asset under `src/skills/`.
- Accept incomplete product ideas, feedback, business problems, or product directions as valid workflow input.
- Guide the user through background and problem exploration, user and value definition, success criteria, scope, non-scope, constraints, risks, and open questions.
- Define `docs/product-design/prd.md` and `docs/product-design/business-architecture.md` as the durable version-1 product-design baseline.
- Keep unresolved material in `Open Questions`, preserve explicitly rejected directions, and keep deferred product work in `Future Scope`.
- Keep an independent Change Log in each product-design document.
- Require one consolidated user confirmation for the complete two-document product-design baseline; keep approval evidence in the Discovery run records rather than the product documents.
- Route appropriate requests to `discovery` from `using-dev-cadence`.
- Include the new workflow in the source package, generated distribution package, skill description checks, installation contract, and public workflow availability where required.

## Explicit Non-Goals

- Do not implement incremental PRD updates or PRD version increments beyond version 1; that belongs to `S-002`.
- Do not create or update Feature, Story, Bug, or Technical Task cards.
- Do not implement `work-item-planning` or maintain a work-item roadmap.
- Do not design technical architecture or modify application code in target repositories.
- Do not add Release, Deployment, Post-deploy Verification, or Incident workflows.
- Do not modify vendored Superpowers behavior unless a later technical solution proves it necessary.

## Acceptance Criteria

1. A user can start `discovery` from an incomplete idea without supplying complete requirements or acceptance criteria first.
2. The workflow can produce `docs/product-design/prd.md` version 1 with product goal, users, value, success criteria, scope, non-scope, capabilities, requirements, constraints, Open Questions, Rejected Directions, Future Scope, and a Change Log.
3. The workflow can produce `docs/product-design/business-architecture.md` version 1 with business actors, domains, capabilities, value streams, processes, business objects, lifecycle states, rules, policies, exceptions, external boundaries, Open Questions, Rejected Directions, and a Change Log.
4. Unresolved material remains in `Open Questions` and is never silently promoted into confirmed product or business-architecture content.
5. Workflow confirmation and checkpoint evidence remain in `build/dev-cadence/discovery/<discovery-slug>/` and are not embedded as approval metadata in either product-design document.
6. The workflow does not report Discovery complete until the user confirms the complete two-document product-design baseline.
7. The workflow does not create work-item cards, design technical architecture, or modify target application code.
8. The source skill, entry selector, build output, and installed package expose one consistent Discovery workflow.

## Assumptions

- Enhanced exploration mode applies because the feature touches multiple workflow and packaging boundaries.
- The default output language follows `.dev-cadence.yaml`; when missing or unsupported, it follows the existing Dev Cadence fallback.
- The stage record structure and exact section wording remain Technical Solution decisions as long as they preserve the confirmed two-document product-design boundary.
- Existing root-level Markdown and `docs/**` test exemptions remain in force; tests will target executable skill, routing, build, and installation behavior rather than human-facing prose.

## Open Questions

- None that block Requirements Confirmation. The exact implementation structure belongs to Technical Solution.

## Stage Decision

- Status: `confirmed and refined by user in chat on 2026-07-13`
- Checkpoint: `4327d65`
