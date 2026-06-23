# Implementation Discipline

Use this reference in `implementation` and `fix` states for code behavior changes.

## Core Rule

```text
No production code without a failing test first.
```

For testable behavior changes, use strict Red-Green-Refactor. Tests after implementation are not equivalent evidence.

## When It Applies

Use Red-Green-Refactor for:

- new features;
- bug fixes;
- refactors intended to preserve behavior;
- behavior changes.

Exceptions require named Human approval before implementation unless a stricter repository rule applies:

- throwaway prototype;
- generated code;
- pure configuration change;
- environment limitation that prevents useful test-first feedback.

Record the exception, substitute feedback, and residual risk in `05-implementation.md`.

## Red

Write one minimal test or characterization that expresses the expected behavior.

Verify Red by running the test and recording:

- test name and path;
- command;
- failure output;
- why the failure is expected;
- why the failure is caused by missing or incorrect behavior, not typo, setup error, or unrelated failure.

If the test passes immediately, it is not Red evidence. Fix the test or choose a missing behavior.

## Green

Write the smallest implementation that passes the Red test.

Do not:

- add unrequested behavior;
- broaden scope;
- refactor unrelated code;
- add speculative options, hooks, abstractions, or configuration;
- change acceptance criteria without updating requirements.

Verify Green by recording:

- changed files;
- command;
- passing output;
- whether relevant neighboring tests still pass.

## Refactor

After Green only:

- remove duplication;
- improve names;
- extract helpers;
- clarify structure.

Do not add behavior during refactor. Re-run verification and record that the tests stayed green.

## Invalid TDD Evidence

These are not acceptable unless a named Human accepts the exception:

- production code written before the failing test;
- tests added after implementation;
- test passes immediately;
- failing test errors because of typos or setup;
- manual testing used as Red evidence;
- keeping prewritten implementation as "reference";
- adapting prewritten implementation while writing tests.

If code was written before Red, remove or disregard it and restart from the test.

## Testing Anti-Patterns

Load `testing-anti-patterns.md` when writing or changing tests, adding mocks, or tempted to add production methods only for tests.

Hard checks:

- test real behavior, not mock existence;
- do not add test-only methods to production classes;
- do not mock without understanding side effects;
- mock complete data structures when mocking is necessary;
- prefer integration with real components when mocks become more complex than the behavior under test.

## Required Evidence

`05-implementation.md` should record:

```yaml
red_evidence:
green_evidence:
refactor_evidence:
tdd_exception:
substitute_feedback:
```

Harness run evidence must include command logs, changed files, diff summary, and verification output.
