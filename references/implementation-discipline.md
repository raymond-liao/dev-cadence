# Implementation Discipline

Use this shared reference in `implementation` and `fix` states to route
behavior-change work and define implementation evidence. This reference defines
the shared implementation evidence and exception contract. For strict
Red-Green-Refactor execution, use `skills/cadence-tdd/SKILL.md`.

## Core Rule

```text
No production code without a failing test first.
```

For testable behavior changes, tests after implementation are not equivalent
evidence. If normal test-first order cannot be followed, get named Human
approval before implementation or record the work as missing normal TDD evidence.

## When It Applies

Use this reference for:

- new features;
- bug fixes;
- refactors intended to preserve behavior;
- behavior changes.

When a change is testable, enter `cadence-tdd` and follow its full Red-Green-Refactor workflow before changing production code.

## Shared Evidence Contract

For `S1` and `S2` behavior work, capture
`runs/{run_id}/pre-implementation-status.md` before writing production code,
tests, migrations, build scripts, deployment files, or application
configuration. If code was changed before the baseline, mark
`post_hoc_backfill: true` and treat the run as missing normal pre-work evidence
until a named Human accepts the gap.

`05-implementation.md` should record:

```yaml
red_evidence:
green_evidence:
refactor_evidence:
tdd_exception:
substitute_feedback:
```

A valid implementation record shows:

- pre-implementation baseline;
- Red evidence for testable behavior;
- Green verification output;
- Refactor verification when refactoring occurred;
- changed files;
- diff summary;
- Harness command logs;
- unresolved risks or blockers.

## Exception Contract

Exceptions require named Human approval before implementation unless a stricter
repository rule applies:

- throwaway prototype;
- generated code;
- pure configuration change;
- environment limitation that prevents useful test-first feedback.

Record the exception, approver, substitute feedback, residual risk, and plan to
restore test coverage in `05-implementation.md`.

## Invalid TDD Evidence

These do not satisfy normal TDD evidence unless a named Human accepts the
exception:

- production code written before the failing test;
- tests added after implementation;
- test passes immediately;
- failing test errors because of typos or setup;
- manual testing used as Red evidence;
- keeping prewritten implementation as "reference";
- adapting prewritten implementation while writing tests.

If code was written before Red, remove or disregard it and restart from the test,
or record the named Human exception and residual risk.

## Test Quality Boundary

When writing or changing tests, adding mocks, or tempted to add production
methods only for tests, use `cadence-tdd` and load
`skills/cadence-tdd/testing-anti-patterns.md`.

Hard checks:

- test real behavior, not mock existence;
- do not add test-only methods to production classes;
- do not mock without understanding side effects;
- mock complete data structures when mocking is necessary;
- prefer integration with real components when mocks become more complex than the behavior under test.
