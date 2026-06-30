---
name: cadence-tdd
description: Apply Dev Cadence test-driven implementation discipline. Use before implementing any testable feature, bug fix, refactor, or behavior change where a failing test or characterization can describe the intended behavior before production code changes.
---

# Cadence TDD

Use this Skill for testable behavior changes. It runs inside the Dev Cadence
implementation path and must produce Red-Green-Refactor evidence or a named
Human-approved exception before implementation can be treated as complete.

## Core Rule

Write the test first. Watch it fail. Write the minimum code to pass.

```text
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

If you did not watch the test fail for the expected reason, you do not know
whether it tests the right behavior.

Writing production code before the failing test invalidates normal TDD evidence. Delete or disregard that code and restart from the test unless a named Human explicitly accepts the gap and substitute feedback.

## Required References

- `../../references/implementation-discipline.md`
- `testing-anti-patterns.md` when writing or changing tests, adding mocks, or
  tempted to add production methods only for tests.
- `../../references/harness.md` when recording persistent run evidence.
- `../../references/quality-gates.md` when deciding whether evidence is enough
  to continue.
- `../../references/spec-templates.md` when updating task artifacts.

## When to Use

Use for:

- new features;
- bug fixes with reproducible or characterizable behavior;
- refactors that must preserve behavior;
- behavior changes;
- any implementation where a failing test can describe the intended result.

Exceptions require named Human approval before implementation unless a stricter
repository rule applies. Common exception candidates:

- throwaway prototype;
- generated code;
- pure configuration change;
- environment limitation that prevents useful test-first feedback.

Record the exception, substitute feedback, and residual risk in Harness
evidence and task artifacts. Thinking "skip TDD just this once" is a red flag,
not an exception.

## Pre-Implementation Baseline

For `S1` and `S2` implementation or fix work, capture
`runs/{run_id}/pre-implementation-status.md` before writing the Red test or any
product source, migration, build, deployment, or application configuration
change.

If test or production files were already changed, mark
`post_hoc_backfill: true` and keep the relevant gates blocked unless a named
Human accepts the evidence gap.

## Red-Green-Refactor

### RED: Write a Failing Test

Write one minimal test or characterization showing what should happen.

Requirements:

- one behavior per test;
- clear behavior-focused name;
- real code path unless mocking is unavoidable;
- expected assertion written before implementation;
- bug fixes reproduce the bug or characterize the failing behavior.

Run the test and verify:

- it fails, not merely errors;
- it fails for the expected reason;
- the failure is caused by missing or incorrect behavior, not typo, setup
  error, stale fixture, or unrelated failure.

If the test passes immediately, it is not Red evidence. Fix the test or choose
behavior that is actually missing.

### GREEN: Minimal Code

Write the smallest implementation that passes the Red test.

Do not:

- add unrequested behavior;
- add speculative options, hooks, abstractions, or configuration;
- refactor unrelated code;
- broaden scope;
- change acceptance criteria without updating requirements.

Run the focused test and relevant neighboring tests. If the test fails, fix the
code, not the test, unless the Red test was wrong and that correction is
recorded.

### REFACTOR: Clean Up While Green

Refactor only after Green:

- remove duplication;
- improve names;
- extract helpers;
- clarify structure.

Do not add behavior during refactor. Re-run verification and record that tests
stayed green.

Repeat the cycle for each next behavior.

## Good Tests

Good tests:

- verify behavior, not implementation details;
- make the intended API or user/system behavior clear;
- avoid vague names such as `works` or `test1`;
- use mocks only at necessary boundaries;
- cover edge cases and error paths that matter to the accepted behavior.

If a test name contains "and", consider splitting it. If test setup dominates
the behavior being tested, simplify the design or extract test helpers.

## Why Order Matters

Tests after implementation are biased by the implementation. They often prove
what the code does, not what it should do.

Test-first proves the test can fail for the missing behavior. It exposes edge
cases before the implementation shape biases the test. Manual testing does not
provide the same repeatable evidence.

Exploration is allowed, but exploration code is not production evidence. Throw
it away or disregard it, then restart with a failing test.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Too simple to test." | Simple code breaks. A small test is cheap. |
| "I will test after." | A test that only ever passes proves less. |
| "Manual testing is faster." | Manual testing is not repeatable evidence. |
| "Keep the code as reference." | You will adapt it. Delete or disregard it. |
| "Deleting work is wasteful." | Keeping untrusted code is the waste. |
| "Need to explore first." | Explore, then throw it away and start with Red. |
| "Test is hard to write." | That may mean the design is hard to use. |
| "This is different." | Different requires a named exception, not a silent skip. |

## Red Flags

Stop and restart from Red, or open a named Human Gate, when you catch:

- code before test;
- tests added later;
- test passes immediately;
- cannot explain why the test failed;
- failure is caused by typo or setup, not missing behavior;
- manual testing used as Red evidence;
- keeping or adapting prewritten implementation;
- rationalizing "just this once";
- calling a shortcut pragmatic without recording the evidence gap.

## When Stuck

| Problem | Response |
|---|---|
| Do not know how to test | Write the wished-for API and assertion first; ask the Human when behavior is unclear. |
| Test is too complicated | Simplify the interface or split the behavior. |
| Must mock everything | The code may be too coupled; look for a smaller boundary or dependency injection. |
| Test setup is huge | Extract helpers; if still huge, reconsider the design. |
| Existing code has no tests | Add characterization or regression tests around the behavior you are changing. |

## Debugging Integration

When a bug is found, `cadence-debug` must identify or characterize the root
cause first. Then use this Skill to write the failing regression test, verify
Red, implement the root-cause fix, verify Green, and refactor only while tests
stay green.

Never fix a testable bug without a failing test or named Human exception.

## Testing Anti-Patterns

When adding mocks or test utilities, load
`testing-anti-patterns.md` and avoid:

- testing mock behavior instead of real behavior;
- adding test-only methods to production classes;
- mocking without understanding side effects;
- using incomplete mock data that production code would not receive;
- replacing useful integration coverage with brittle mocks.

## Evidence

Record these when artifacts are being written:

- pre-implementation baseline path and status;
- Red test path, command, failure output, and expected failure reason;
- Green implementation files, command, and passing output;
- Refactor changes and verification that tests stayed green;
- skipped checks, TDD exception, substitute feedback, and residual risk.

`05-implementation.md` should include Red, Green, and Refactor evidence or a
named Human-approved exception.

## Final Rule

```text
Production code -> test exists and failed first.
Otherwise -> not TDD.
```

No exception is valid unless a named Human accepted it and the substitute
feedback is recorded.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with
evidence produced, unresolved blockers, gate status, and recommended next
state. Do not select the next cadence Skill from here.
