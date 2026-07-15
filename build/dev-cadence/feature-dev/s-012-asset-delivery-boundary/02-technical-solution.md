# Technical Solution

- Status: ✅ `confirmed`
- Requirements: [Requirements Confirmation](01-requirements.md)

## Codebase Exploration Findings

### Entry And Continuation

- `src/skills/using-dev-cadence/SKILL.md` owns cross-workflow routing and Active Workflow Continuation.
- It currently treats a run manifest as the general continuation signal, so it is the correct authority for the new classification and model-selection rule.

### Delivery Evidence

- `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, and `src/skills/refactor/SKILL.md` already maintain complete run manifests and stage records.
- Their evidence contracts must remain unchanged; a short classification declaration can make ownership explicit without duplicating the shared contract.

### Asset Transition

- `src/skills/discovery/SKILL.md` still implements the legacy run-record model.
- S-013 explicitly owns removing that implementation. Rewriting it here would merge two Stories and make S-013's acceptance boundary meaningless.

### Tests And Distribution

- Shell contract tests are the established executable specification.
- `scripts/build.sh` regenerates `dist/.dev-cadence`; source files remain authoritative.

## Options Considered

### Minimal Change

Add classification prose only to the entry selector. This is low impact but does not make Delivery conformance locally visible or provide strong regression protection.

### Clean Architecture

Create a new shared skill dedicated to record models and rewrite every workflow to consume it immediately. This adds routing and packaging surface that is not required by S-012 and would force the S-013 migration into this Story.

### ✅ Selected: Pragmatic Balance

Define the complete classification and persistence contract once in `using-dev-cadence`, add concise Delivery declarations to Feature Dev, Bug Fix, and Refactor, and add a focused contract test. Explicitly record the Discovery transition to S-013 rather than modifying its process implementation here.

## Affected Boundaries

- Shared workflow classification and continuation: `src/skills/using-dev-cadence/SKILL.md`.
- Delivery workflow declarations: `src/skills/{feature-dev,bug-fix,refactor}/SKILL.md`.
- Executable contract: `tests/asset-delivery-record-contract.sh`, `tests/run-all.sh`.
- Product state: S-012 Story, Backlog, dependent Story readiness, and root `version`.

## Testing Strategy

- RED/GREEN focused contract test for classification, Asset prohibitions, Delivery retention, continuation, and future workflow selection.
- Existing workflow symmetry and Discovery contracts to prove no Delivery evidence loss or premature Discovery migration.
- Build, whitespace, full repository checks, and source/distribution synchronization search.

## Risks And Constraints

- The repository temporarily contains a classified Asset workflow whose implementation still has legacy process records. The shared contract must name S-013 as the migration owner and must not present the old model as acceptable for new Asset workflows.
- Text contracts can drift if wording changes; assertions therefore target semantic anchors rather than entire paragraphs.
