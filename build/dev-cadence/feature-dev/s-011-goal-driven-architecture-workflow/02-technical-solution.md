# Goal-Driven Architecture Workflow Technical Solution

- Status: ✅ `confirmed`
- Requirement source: `build/dev-cadence/feature-dev/s-011-goal-driven-architecture-workflow/01-requirements.md`
- Confirmation: delegated by the 2026-07-14 batch execution instruction

## Codebase Exploration Findings

### Entry Routing And Record Model

- Key files: `src/skills/using-dev-cadence/SKILL.md`, `tests/routing-contract.sh`, `tests/asset-delivery-record-contract.sh`.
- Pattern: the entry selector owns cross-workflow discovery, selection, representative examples, continuation, and Asset/Delivery classification.
- Constraint: S-012's temporary Discovery exception must remain Discovery-only and must not propagate to Architecture Design.

### Workflow And Document Semantics

- Key files: `src/skills/discovery/SKILL.md`, `src/skills/document-conventions/SKILL.md`, `docs/workflows/discovery.md`.
- Pattern: workflow skills are executable authorities; shared document conventions own marker and link semantics; `docs/workflows/` explains user-visible behavior.
- Constraint: architecture-design must be goal-driven and section-tailored, not a copied six-stage delivery workflow.

### Distribution And Contracts

- Key files: `scripts/build.sh`, `tests/package-contract.sh`, `tests/run-all.sh`, `README.md`, `README.zh-CN.md`.
- Pattern: the whole `src/skills` tree is copied into dist, while package contracts enumerate public required files and focused contracts protect semantic rules.
- Constraint: edit `src/`, build dist, and verify exact source/dist synchronization.

## Options

### Minimal Change

Add only the workflow skill and one route row. This minimizes edits but leaves packaging, negative routing boundaries, record-model enforcement, and user-facing discoverability weak.

### Clean Architecture

Refactor routing and Asset Workflow behavior into new shared abstractions before adding Architecture Design. This is broader than S-011 and risks changing existing workflows.

### ✅ Selected: Pragmatic Balance

Add one focused workflow skill, extend the existing selector in place, add a dedicated semantic contract, enumerate the package artifact, update concise user-facing workflow documentation, and preserve existing shared contracts unchanged except where Architecture Design must be covered.

## Affected Boundaries

- `src/skills/architecture-design/SKILL.md`: workflow authority.
- `src/skills/using-dev-cadence/SKILL.md`: explicit routing and continuation boundary.
- `tests/architecture-design-contract.sh` and existing contract runners: focused acceptance protection.
- Package and README/workflow documentation: installability and user-visible behavior.
- Story, Backlog, and `version`: product state and release identity.

## Testing Strategy

- RED: focused contract fails because the skill and routing do not exist.
- GREEN: focused architecture, routing, record-model, and package contracts pass.
- Final: build, whitespace, full contract suite, and source/dist synchronization searches.

## Risks

- Over-routing architecture terminology could steal Discovery or delivery requests; explicit user intent and representative negative examples prevent this.
- Process-record language could accidentally copy Discovery's temporary exception; focused negative assertions prevent this.
