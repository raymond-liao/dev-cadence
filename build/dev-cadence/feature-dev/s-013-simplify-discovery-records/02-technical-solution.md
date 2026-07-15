# Technical Solution

- Status: ✅ `confirmed`
- Confirmed requirements: [Requirements Confirmation](01-requirements.md)

## Codebase Exploration Findings

### Perspective 1: Workflow authority and routing

- `src/skills/discovery/SKILL.md` owns the legacy manifest, stage-record, checkpoint, confirmation-record, and continuation behavior.
- `src/skills/using-dev-cadence/SKILL.md` already defines Asset versus Delivery record models but contains the temporary S-013 exception.
- Constraint: Discovery must retain the content-classification and initial-baseline contracts added by S-006.
- Essential files read: both skills, S-013, S-012, S-006, and the Discovery workflow description.

### Perspective 2: User-visible documentation and packaging

- `docs/workflows/discovery.md`, `README.md`, and `README.zh-CN.md` describe Discovery records or imply that every workflow has a manifest.
- `scripts/build.sh` copies source skills and README files into `dist/.dev-cadence`; source files remain authoritative.
- Constraint: general evidence-trail language must be scoped to Delivery Workflows without weakening delivery governance.
- Essential files read: workflow document, both READMEs, build script, package contract, and version.

### Perspective 3: Contract and backlog state

- `tests/discovery-contract.sh` explicitly requires legacy record paths and checkpoint behavior.
- `tests/asset-delivery-record-contract.sh` explicitly requires the temporary S-013 exception.
- `docs/backlog.md` must move S-013 to completed and recalculate S-002 as Ready while leaving S-011 Ready.
- Essential files read: both contract tests, test runner, Story card, Backlog, and dependency table.

## Alternatives

### Minimal-change option

Delete only the legacy sections from Discovery and update the two direct tests. This minimizes edits but leaves inaccurate README and workflow descriptions.

### Clean-architecture option

Extract shared Asset Workflow behavior into a new reusable skill and make Discovery delegate most lifecycle rules to it. This offers stronger reuse but introduces an unrequested abstraction before S-011 and S-015 establish the other Asset Workflows.

### ✅ Selected: Pragmatic-balance option

Rewrite only Discovery's persistence and stage-execution sections while preserving its product-design and content-boundary contracts; remove the entry selector's temporary exception; qualify affected README and workflow language; update focused contracts and backlog state. This satisfies S-013 without anticipating S-002 or inventing a new shared layer.

## Testing Strategy

- RED: focused Discovery and Asset/Delivery contract tests must fail against the legacy implementation.
- GREEN: focused contracts pass after source changes.
- Build: generate `dist/.dev-cadence` from source.
- Final: whitespace, full contract suite, source/dist key-rule search, and tracked Markdown-link validation through repository checks.

## Risks And Constraints

- Negative assertions must reject legacy process paths without accidentally banning the Delivery Workflow manifest model.
- README language must still accurately describe Feature Dev, Bug Fix, and Refactor evidence trails.
- S-002 must become Ready in Backlog state only; no incremental Discovery rule may be implemented.
