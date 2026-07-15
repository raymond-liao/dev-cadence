# Technical Solution

- Status: ✅ `confirmed`
- Confirmed requirement source: [Requirements Confirmation](01-requirements.md)

## Recommended Approach - ✅ Selected

Extend `src/skills/discovery/SKILL.md` with a normative content-classification section and stage-specific gates. Reuse the installed `open-question-registry` capability instead of creating a new transfer document. Add literal and regex contract checks to `tests/discovery-contract.sh`, update `docs/workflows/discovery.md`, and regenerate `dist/.dev-cadence` through the build script.

This is the smallest design that makes the boundary executable while preserving ownership: Discovery owns classification and product-document exclusion; S-005 owns Registry mechanics; S-002 will own migration of historical mixed content.

## Alternatives

### Minimal Boundary Text Only

Add only a longer prohibited-content list. This is insufficient because it would not define constraint exceptions, source-faithful classification, transfer ownership, or final confirmation evidence.

### Separate Content Classification Skill

Create a reusable classifier skill. This adds routing and ownership complexity before another workflow demonstrably needs an independent capability.

## Affected Modules And Boundaries

- `src/skills/discovery/SKILL.md`: authoritative runtime behavior.
- `tests/discovery-contract.sh`: executable contract for S-006.
- `docs/workflows/discovery.md`: maintainer-facing behavior description.
- `docs/stories/S-006-discovery-product-technical-content-boundary.md` and `docs/backlog.md`: completion and dependency state.
- `version`: installed package behavior version.
- `dist/.dev-cadence/**`: generated only by `scripts/build.sh`, never edited directly.

## Testing Strategy

- RED: add assertions for classification, allowed product constraints, prohibited mechanisms, authority/Registry transfer, local Open Questions, final summary, initial gate, and S-002 migration boundary.
- GREEN: minimally extend the Discovery rule until the focused contract passes.
- Verify build, all contracts, whitespace, and source/distribution synchronization.

## Risks And Constraints

- Avoid keyword-only classification; a named technology may be an externally mandated constraint, but the PRD records the required boundary/result, not an unconfirmed mechanism.
- Do not imply that Registry transfer is a technical decision or user acceptance.
- Do not silently clean historical mixed content; S-002 remains authoritative for that operation.

## Codebase Exploration Findings

Enhanced exploration was skipped because the behavior is localized and the Story already resolves scope and ownership. Essential files read: `src/skills/discovery/SKILL.md`, `src/skills/open-question-registry/SKILL.md`, `tests/discovery-contract.sh`, `docs/workflows/discovery.md`, `docs/backlog.md`, and the S-005/S-006 Story cards.
