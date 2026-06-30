# Testing Anti-Patterns

Use this reference when writing or changing tests, adding mocks, or tempted to add test-only methods to production code.

## Overview

Tests must verify real behavior, not mock behavior. Mocks are a way to isolate, not the thing being tested.

Core principle: test what the code does, not what the mocks do.

Following strict TDD prevents these anti-patterns.

## Iron Laws

```text
1. NEVER test mock behavior
2. NEVER add test-only methods to production classes
3. NEVER mock without understanding dependencies
```

## Anti-Pattern 1: Testing Mock Behavior

The violation:

```typescript
// ❌ BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

Why this is wrong:

- You are verifying the mock works, not that the component works.
- The test passes when the mock is present and fails when it is absent.
- It says nothing about real behavior.

Human correction signal: "Are we testing the behavior of a mock?"

The fix:

```typescript
// ✅ GOOD: Test the real component or do not mock it
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// If sidebar must be mocked for isolation, do not assert on the mock.
// Test Page behavior with a sidebar boundary present.
```

### Gate Function

```text
BEFORE asserting on any mock element:
  Ask: "Am I testing real component behavior or just mock existence?"

  IF testing mock existence:
    STOP - Delete the assertion or unmock the component

  Test real behavior instead
```

## Anti-Pattern 2: Test-Only Methods in Production

The violation:

```typescript
// ❌ BAD: destroy() is only used in tests
class Session {
  async destroy() {
    await this._workspaceManager?.destroyWorkspace(this.id);
  }
}

afterEach(() => session.destroy());
```

Why this is wrong:

- Production class is polluted with test-only code.
- The method looks like a supported production API.
- It violates YAGNI and separation of concerns.
- It can confuse object lifecycle with test cleanup lifecycle.

The fix:

```typescript
// ✅ GOOD: Test utilities handle test cleanup
// Session has no destroy() if it does not own that lifecycle in production.

export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

afterEach(() => cleanupSession(session));
```

### Gate Function

```text
BEFORE adding any method to production class:
  Ask: "Is this only used by tests?"

  IF yes:
    STOP - Do not add it
    Put it in test utilities instead

  Ask: "Does this class own this resource's lifecycle?"

  IF no:
    STOP - Wrong class for this method
```

## Anti-Pattern 3: Mocking Without Understanding

The violation:

```typescript
// ❌ BAD: Mock breaks the behavior the test depends on
test('detects duplicate server', async () => {
  // Mock prevents config write that duplicate detection needs.
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config); // Should throw, but duplicate state was never written.
});
```

Why this is wrong:

- The mocked method had a side effect the test needed.
- Over-mocking to "be safe" breaks actual behavior.
- The test passes for the wrong reason or fails mysteriously.

The fix:

```typescript
// ✅ GOOD: Mock at the correct lower boundary
test('detects duplicate server', async () => {
  // Mock only the slow external operation; preserve config writes.
  vi.mock('ServerProcessManager');

  await addServer(config);
  await addServer(config); // Duplicate is detected.
});
```

### Gate Function

```text
BEFORE mocking any method:
  STOP - Do not mock yet

  1. Ask: "What side effects does the real method have?"
  2. Ask: "Does this test depend on any of those side effects?"
  3. Ask: "Do I fully understand what this test needs?"

  IF the test depends on side effects:
    Mock at a lower boundary, such as the slow or external operation
    OR use a test double that preserves necessary behavior
    NOT the high-level method the test depends on

  IF unsure what the test depends on:
    Run the test or code path with the real implementation FIRST
    Observe what actually needs to happen
    THEN add minimal mocking at the right boundary

  Red flags:
    - "I will mock this to be safe"
    - "This might be slow, better mock it" before measuring
    - Mocking without understanding the dependency chain
```

## Anti-Pattern 4: Incomplete Mocks

The violation:

```typescript
// ❌ BAD: Partial mock with only fields the immediate test mentions
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // Missing metadata that downstream code consumes
};
```

Why this is wrong:

- Partial mocks hide structural assumptions.
- Downstream code may depend on omitted fields.
- Tests pass while integration fails.
- The mock creates false confidence.

Iron rule: mock the complete data structure as it exists in reality, not just fields your immediate test uses.

The fix:

```typescript
// ✅ GOOD: Mirror real API shape
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
};
```

### Gate Function

```text
BEFORE creating mock responses:
  Check: "What fields does the real API response contain?"

  Actions:
    1. Examine actual API responses from docs, fixtures, traces, or examples
    2. Include all fields downstream code may consume
    3. Verify the mock matches the real response schema closely enough

  Critical:
    If you create a mock, understand the structure
    Partial mocks fail silently when code depends on omitted fields

  If uncertain: include all documented fields or use a real fixture
```

## Anti-Pattern 5: Integration Tests as Afterthought

The violation:

```text
✅ Implementation complete
❌ No tests written
"Ready for testing"
```

Why this is wrong:

- Testing is part of implementation, not optional follow-up.
- TDD would have caught this before implementation.
- You cannot claim complete without verification evidence.

The fix:

```text
TDD cycle:
1. Write failing test
2. Implement to pass
3. Refactor
4. Then claim complete with evidence
```

## When Mocks Become Too Complex

Warning signs:

- mock setup is longer than test logic;
- everything is mocked just to make the test pass;
- mocks are missing methods real components have;
- test breaks when mock details change;
- test no longer communicates behavior.

Human correction signal: "Do we need to be using a mock here?"

Consider integration tests with real components. They are often simpler and more reliable than complex mocks.

## TDD Prevents These Anti-Patterns

Why TDD helps:

1. Write test first: forces clarity about what is being tested.
2. Watch it fail: confirms the test checks real behavior, not mock existence.
3. Minimal implementation: prevents test-only production methods from creeping in.
4. Real dependencies first: shows what the test actually needs before mocking.

If you are testing mock behavior, you violated TDD. You added mocks without proving the test fails against real behavior first.

## Quick Reference

| Anti-Pattern | Fix |
|---|---|
| Assert on mock elements | Test real component or unmock it |
| Test-only methods in production | Move cleanup/setup to test utilities |
| Mock without understanding | Understand dependencies first, mock minimally |
| Incomplete mocks | Mirror the real API or use real fixtures |
| Tests as afterthought | Use TDD: tests first |
| Over-complex mocks | Prefer integration tests or real components |

## Red Flags

- Assertion checks for `*-mock` test IDs.
- Methods only called in test files.
- Mock setup is more than half the test.
- Test fails when you remove the mock.
- Cannot explain why the mock is needed.
- Mocking "just to be safe".
- Reporting implementation complete without Red/Green evidence.

## Bottom Line

Mocks are tools to isolate, not things to test.

If TDD reveals you are testing mock behavior, you have gone wrong.

Fix it by testing real behavior or questioning why the mock exists.
