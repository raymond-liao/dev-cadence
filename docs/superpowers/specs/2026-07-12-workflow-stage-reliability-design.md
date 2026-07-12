# Workflow Stage Reliability Design

## Context

Dev Cadence currently defines the optimistic sequence for `feature-dev`, `bug-fix`, and `refactor`, but several stage outputs do not act as executable gates. A verification report can recommend that work must not enter business acceptance without forcing a return to an earlier stage. Evidence can also lose its identity or disappear while moving from implementation, through verification, to business acceptance.

This design implements the narrowed fifth reliability backlog item. It covers workflow-specific stage gates, evidence continuity, and rework loops. It deliberately excludes the deferred Completion state machine, normal-checkout finishing behavior, and worktree lifecycle.

## Goals

- Make verification outcomes control whether a workflow may enter Business Acceptance.
- Bind verification evidence to the exact tested repository revision.
- Carry skipped checks, unresolved review items, and residual risks across stage boundaries without omission.
- Add durable record contracts for feature requirements and technical solutions.
- Prevent bug repair from advancing on an ambiguous diagnosis or unvalidated root cause.
- Persist auditable bug reproduction, RED, and GREEN evidence.
- Anchor refactor behavior baselines to the pre-refactor repository state.
- Remove contradictions between behavior preservation and public-contract-changing refactor methods.
- Add workflow-specific contract tests that fail when these rules are weakened or moved to the wrong stage.

## Non-Goals

- Do not define final statuses for accepted, accepted with risk, rejected, not-a-bug, or manual recovery.
- Do not change merge, pull request, discard, branch deletion, or normal-checkout finishing commands.
- Do not change worktree ownership, cleanup, or detached-HEAD behavior.
- Do not modify vendored Superpowers skills.
- Do not change the high-level six-stage business flow documented in the README files.

## Considered Approaches

### Minimal Text Patch

Add a few `must not proceed` sentences around verification. This has low churn, but it leaves revision identity, evidence carry-forward, bug TDD evidence, and refactor baseline integrity unresolved.

### Evidence-Closed Stage Gates

Define normalized verification decisions, explicit rework transitions, tested-revision identity, carry-forward evidence, and workflow-specific record contracts. This adds enough structure for reliable execution and contract tests without entering deferred Completion or Git lifecycle work.

This is the selected approach.

### Full Governance State Machine

Model every business decision, finishing action, worktree state, and recovery state in one change. This would overlap the deferred second, third, and fourth backlog items and would make the change too broad to review safely.

## Common Verification Gate

Each System Testing or Regression Verification report must contain a normalized `Verification Decision`:

- `ready`: executed evidence shows the confirmed goal is satisfied and no blocking gap remains.
- `ready_with_risk`: no executed evidence disproves the confirmed goal, but explicitly listed skipped checks, uncovered areas, or non-blocking open items remain for the user to consider during Business Acceptance.
- `not_ready`: an executed check failed, evidence shows a confirmed goal is unmet, required evidence is internally inconsistent, or a blocking gap remains.

An acceptance criterion failure, an original bug that still reproduces, an observed refactor behavior drift, or an unmet required structural goal must be `not_ready`; these are not residual-risk shortcuts.

Only `ready` and `ready_with_risk` may enter Business Acceptance. For `not_ready`, the agent must:

1. identify the earliest affected workflow stage;
2. record the blocking evidence and the earliest affected stage in the verification report;
3. set that stage to `in_progress` and later affected stages to `pending` in the manifest;
4. update and reconfirm affected stage records;
5. rerun implementation review and verification as required before presenting Business Acceptance.

The existing Active Task Change Handling rule must also apply when the agent, implementation, review, or verification discovers information that invalidates a confirmed stage, not only when the user supplies a change.

## Tested Revision Identity

Before final System Testing or Regression Verification begins, all in-scope deliverables must be represented by the current commit, and the tracked working tree must be clean. Ignored Dev Cadence records and ignored runtime artifacts do not violate this rule.

The verification report must record:

- tested commit SHA;
- tested branch;
- tracked working-tree state before testing;
- tracked working-tree state after testing;
- confirmation that the tested commit did not change during the verification run.

If the tested commit changes or in-scope tracked files become dirty, the verification decision is stale. The agent must finish or classify those changes and rerun the relevant verification before Business Acceptance.

## Evidence Carry-Forward

Each verification report must include `Carry-Forward Items`. Every skipped implementation check, unresolved review finding, accepted review risk, and known implementation risk must appear with:

- stable source ID;
- source record;
- current disposition;
- verification evidence or reason it remains unverified;
- residual risk presented to Business Acceptance.

Items may be marked resolved, covered, still open as residual risk, or invalidated with an explicit reason. They may not disappear between records. The Business Acceptance summary must include every remaining carry-forward item.

## Feature Development Rules

### Requirements Record

`01-requirements.md` must persist the content currently required in the user-facing presentation:

- confirmed scope;
- non-goals;
- acceptance criteria with stable IDs;
- assumptions and open questions;
- user confirmation reflected in the manifest.

### Technical Solution Record

`02-technical-solution.md` must persist:

- requirements source;
- recommended approach;
- alternatives and tradeoffs when relevant;
- affected modules and boundaries;
- testing strategy;
- risks and constraints;
- `Codebase Exploration Findings` when enhanced exploration applies.

The system test report must map acceptance criteria and material technical-solution constraints to evidence. It must also carry forward unresolved implementation and review evidence before deciding whether the feature is ready for Business Acceptance.

## Bug Fix Rules

### Diagnosis Entry Gate

The diagnosis record must use normalized fields:

- `Diagnosis Conclusion`: `confirmed_bug`, `ambiguous`, or `not_a_bug_candidate`;
- `Root Cause State`: `validated` or `hypothesis`;
- `Root Cause Evidence`: evidence that connects the proposed cause to the reported symptom;
- `Reproduction State`: `reproduced` or `not_reproduced`, with equivalent causal evidence when direct reproduction is unavailable.

Repair Solution may begin only when `Diagnosis Conclusion` is `confirmed_bug` and `Root Cause State` is `validated`. An ambiguous report, an untested root-cause hypothesis, or an unreproduced issue without equivalent causal evidence remains in Problem Diagnosis as `in_progress` or `blocked`.

The not-a-bug terminal path remains deferred to the Completion state-machine backlog item.

### Root-Cause Revisions

If implementation, review, or verification disproves the confirmed root cause or repair boundary, the workflow must return to Problem Diagnosis. It must refresh and reconfirm Problem Diagnosis, Repair Solution, and Repair Plan before continuing implementation.

### RED/GREEN Evidence

The Repair Plan and Repair Record must use stable proof IDs. For each repaired behavior, the Repair Record must preserve:

- reproduction or RED command/check;
- expected failure;
- actual failure evidence and why it proves the bug;
- implementation change associated with the proof;
- GREEN command/check;
- actual passing evidence after the fix.

The regression report must map the original symptom, root cause, repair acceptance points, impact scope, and behaviors required to remain unchanged to executed evidence.

## Refactor Rules

### Baseline Identity

The Refactor Solution defines the semantic Behavior Baseline. Immediately before the first structural edit, after required baseline tests are established, the Refactor Record must capture:

- baseline commit SHA;
- baseline tree SHA;
- clean tracked working-tree evidence;
- stable baseline item IDs;
- each protected behavior or contract;
- expected observable result;
- evidence command, test, snapshot, golden sample, or manual check;
- sensitivity evidence or an explicit reason the protection is self-evident.

After structural edits begin, current-code behavior cannot redefine the pre-refactor expectation. New baseline coverage must be verified against the captured baseline revision or recorded as an unverified risk.

### Contract-Preserving Methods

The refactor method catalog must not present narrowing a public API or changing an external data shape as ordinary behavior-preserving work. Interface and data-shape refactors must remain internal, preserve the external contract through compatibility adapters, or move to feature or bug-fix work after user confirmation.

When incremental migration applies, the solution, plan, refactor record, and regression report must preserve a migration evidence chain covering:

- known caller or consumer inventory;
- compatibility strategy;
- migrated and remaining callers;
- remaining legacy references;
- adapter retention or deletion decision;
- evidence that old-path deletion is safe.

### Existing Test Adequacy

An existing test may protect a baseline item only when its relevant assertion clearly detects the protected behavior. Otherwise the agent must perform a reversible sensitivity check or add stronger characterization evidence before structural edits.

## Contract Tests

`tests/workflow-symmetry.sh` will receive workflow-specific contract checks:

- common verification decisions, rework transition, tested revision, and carry-forward evidence in all three workflows;
- feature requirements and technical-solution record structures;
- bug diagnosis entry gate, root-cause rollback, RED/GREEN evidence, and preserved-behavior coverage;
- refactor baseline identity, no public-contract narrowing, migration evidence, and existing-test adequacy.

Tests must first fail against the current skills, then pass after the rules are added. Section-aware checks must ensure rules remain under the correct workflow stage rather than merely existing somewhere in the file.

## Files And Release Handling

Expected source changes:

- `src/skills/feature-dev/SKILL.md`
- `src/skills/bug-fix/SKILL.md`
- `src/skills/refactor/SKILL.md`
- `tests/workflow-symmetry.sh`
- `docs/workflow-reliability-backlog.md`
- `version`

After source edits, run `bash scripts/build.sh` to synchronize the ignored distribution package. The workflow behavior change increments the version from `0.8.1` to `0.8.2`. README files remain unchanged because the public six-stage sequence and installation interface do not change.

The fifth backlog item will be rewritten to cover workflow-specific stage gates, evidence continuity, and rework loops, with terminal-state work explicitly left to the deferred Completion item.

## Success Criteria

- A verification report with `not_ready` cannot legally enter Business Acceptance.
- A stale tested revision cannot be presented for Business Acceptance.
- Implementation risks and unresolved review evidence remain visible through verification and acceptance.
- Feature requirements and solution records can reconstruct the confirmed design after session loss.
- Bug repair cannot start from an ambiguous diagnosis or an unvalidated root cause.
- Bug repair records prove the RED/GREEN sequence for each repaired behavior.
- Refactor regression evidence is anchored to the pre-refactor revision and cannot be silently redefined.
- Public contract changes are not treated as ordinary behavior-preserving refactors.
- Targeted workflow contract tests and the full repository check suite pass.
