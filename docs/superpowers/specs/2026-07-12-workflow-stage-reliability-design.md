# Minimal Workflow Stage Gate Design

## Context

Dev Cadence defines the optimistic stage sequence for `feature-dev`, `bug-fix`, and `refactor`, but the final verification stage does not provide one small, normalized gate that determines whether the workflow may enter Business Acceptance.

The previous design for the fifth reliability backlog item combined this gate with tested-revision identity, evidence carry-forward, workflow-specific record expansion, bug RED/GREEN proof, and refactor baseline governance. Implementing all of those concerns together creates a broad change across three large workflow skills and their contract tests. That breadth makes the change harder to review and increases the chance of repeated corrective edits.

This design narrows the fifth backlog item to the smallest shared stage-gate improvement. It adds one symmetric verification decision contract to the three workflows and defers the remaining reliability improvements to separate work.

## Goals

- Give System Testing and Regression Verification one normalized decision field.
- Prevent a workflow with a blocking verification result from entering Business Acceptance.
- Define the minimum rework action for a blocking result.
- Keep the rule structure and wording symmetric across `feature-dev`, `bug-fix`, and `refactor`.
- Add focused contract checks for only this gate.
- Keep the implementation small enough to review and verify in one pass.

## Non-Goals

- Do not add tested commit, branch, tree, or working-tree identity requirements.
- Do not add `Carry-Forward Items` or expand evidence propagation contracts.
- Do not expand feature requirements or technical-solution record structures.
- Do not change bug diagnosis, root-cause validation, or RED/GREEN evidence rules.
- Do not change refactor baseline, migration, or sensitivity-check rules.
- Do not define Completion terminal states such as accepted, accepted with risk, rejected, not-a-bug, or manual recovery.
- Do not change merge, pull request, discard, branch deletion, normal-checkout finishing, or worktree lifecycle behavior.
- Do not modify vendored Superpowers skills.
- Do not change the public six-stage workflow sequence or installation interface documented in the README files.

## Considered Approaches

### Minimal Shared Gate

Add the same normalized verification decision and blocking transition to the final verification stage of all three workflows. Add section-aware contract checks that cover only this rule.

This is the selected approach because it addresses the immediate stage-gate gap with the smallest behavioral and testing surface.

### Gate Plus Evidence Identity

Add the shared gate together with tested-revision identity and evidence carry-forward. This provides a stronger audit chain, but it requires more record fields, more transition rules, and substantially broader tests. It is deferred.

### Full Workflow Reliability Package

Add the gate, workflow-specific record contracts, bug proof requirements, refactor baseline governance, Completion behavior, and Git lifecycle handling together. This repeats the broad implementation shape that this narrowed design is intended to avoid.

## Verification Decision Gate

Each System Testing or Regression Verification report must contain a normalized `Verification Decision`:

- `ready`: executed evidence shows the confirmed goal is satisfied and no blocking gap remains.
- `ready_with_risk`: executed evidence does not show a confirmed goal failure, but explicitly listed non-blocking skipped checks, uncovered optional areas, or residual risks remain for Business Acceptance.
- `not_ready`: an executed check failed, a confirmed goal is unmet, required evidence is inconsistent, or a blocking gap remains.

A required acceptance criterion without executed evidence, an original bug that still reproduces, an unverified required bug-fix outcome, an observed refactor behavior drift, or an unmet required structural goal must be `not_ready`. These conditions must not be downgraded to `ready_with_risk`.

Only `ready` and `ready_with_risk` may enter Business Acceptance.

For `not_ready`, the workflow must:

1. record the blocking evidence and identify the earliest affected stage in the verification report;
2. set the earliest affected stage to `in_progress` and later affected stages to `pending` in the manifest;
3. mark confirmation and verification information invalidated by the finding as superseded rather than treating it as current evidence;
4. update and reconfirm the affected stage records;
5. repeat implementation review and verification as required before presenting Business Acceptance again.

Historical confirmation and checkpoint information may remain for auditability, but the manifest must distinguish it from the current confirmation state.

## Workflow Placement

The same gate must be added without restructuring unrelated workflow content:

- `feature-dev`: under System Testing, before Business Acceptance.
- `bug-fix`: under Regression Verification, before Business Acceptance.
- `refactor`: under Regression Verification, before Business Acceptance.

Workflow-specific language may identify the relevant goal, but decision values and transition semantics must remain equivalent.

## Contract Tests

`tests/workflow-symmetry.sh` will receive focused, section-aware checks that verify:

- all three workflows define `ready`, `ready_with_risk`, and `not_ready` in the final verification stage;
- only `ready` and `ready_with_risk` may enter Business Acceptance;
- required unverified outcomes and observed confirmed-goal failures are `not_ready`;
- `not_ready` records the blocking evidence and earliest affected stage;
- affected manifest stages are returned to `in_progress` or `pending`;
- invalidated confirmation or verification information is treated as superseded;
- affected stages must be updated and reconfirmed before verification is repeated.

The tests must not introduce assertions for deferred tested-revision identity, evidence carry-forward, workflow-specific record expansion, Completion, finishing, or worktree behavior.

## Files And Change Limits

Expected source changes for a later implementation:

- `src/skills/feature-dev/SKILL.md`
- `src/skills/bug-fix/SKILL.md`
- `src/skills/refactor/SKILL.md`
- `tests/workflow-symmetry.sh`
- `docs/backlog.md`
- `version`

Implementation must add one small, symmetric rule block to each workflow. It must not refactor surrounding sections or incorporate unrelated reliability findings discovered during verification.

After source edits, run `bash scripts/build.sh` to synchronize the ignored distribution package. Evaluate and update `version` because the installed workflow behavior changes. README files remain unchanged because the public workflow sequence and installation interface do not change.

## Verification Strategy

The intended verification sequence is:

```bash
bash tests/workflow-symmetry.sh
bash scripts/build.sh
bash scripts/check-all.sh
```

Run the focused workflow test before the full repository checks. If verification fails, fix only failures caused by the new gate or its assertions. Record unrelated failures separately instead of expanding this implementation.

## Deferred Reliability Work

The following concerns remain valid but require separate design and implementation work:

- tested revision and clean working-tree identity;
- carry-forward IDs and evidence completeness checks;
- durable feature requirements and technical-solution contracts;
- bug diagnosis entry gates and auditable RED/GREEN proof;
- refactor baseline identity, migration evidence, and test sensitivity;
- Completion state-machine terminal paths;
- normal-checkout finishing reliability;
- worktree lifecycle reliability;
- broader end-to-end or fixture-based workflow execution tests.

Deferring these concerns is an explicit scope decision, not a claim that they are already solved.

## Success Criteria

- Every final verification report has one normalized decision.
- A `not_ready` workflow cannot enter Business Acceptance.
- Missing evidence for a required outcome cannot be classified as `ready_with_risk`.
- A blocking finding returns the workflow to the earliest affected stage and invalidated current confirmation is not presented as valid.
- The three workflows use equivalent gate semantics.
- Focused workflow contract tests and the full repository check suite pass.
- The implementation does not change deferred workflow reliability areas.
