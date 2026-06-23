# Testing Anti-Patterns

Use this reference when writing or changing tests, adding mocks, or tempted to add test-only methods to production code.

## Core Rule

Tests must verify real behavior, not mock behavior. Mocks isolate a unit; they are not the thing being tested.

## Iron Laws

```text
1. Never test mock behavior.
2. Never add test-only methods to production classes.
3. Never mock without understanding dependencies.
```

## Testing Mock Behavior

Before asserting on any mock element or mock call:

```text
Am I testing real component behavior, or just proving that my mock exists?
```

If the assertion only proves the mock exists, delete the assertion or unmock the component. Test real user-visible or system behavior instead.

## Test-Only Production Methods

Before adding a method to production code:

```text
Is this only used by tests?
```

If yes, do not add it to production. Put cleanup, setup, or inspection behavior in test utilities unless the production object truly owns that lifecycle.

## Mocking Without Understanding

Before mocking any method:

1. Identify the real method's side effects.
2. Check whether the test depends on any side effect.
3. Mock at the lowest useful boundary.
4. Preserve behavior that the test depends on.

Red flags:

- "mock this to be safe";
- "this might be slow, better mock it" before measuring;
- test fails when mock is removed but you cannot explain why;
- mock setup is larger than the behavior under test.

## Incomplete Mocks

Mock real data structures completely enough for downstream consumers.

If the real API response has metadata, status, nested fields, or IDs that production code may consume, include them or use a fixture from real examples. Partial mocks create false confidence.

## Integration Tests as Afterthought

Testing is part of implementation. Do not report implementation complete with "ready for testing" when no verification evidence exists.

## When Mocks Are Too Complex

Prefer real components or integration tests when:

- mock setup dominates the test;
- mocks duplicate production logic;
- mocks break when unrelated implementation details change;
- the test no longer communicates behavior.
