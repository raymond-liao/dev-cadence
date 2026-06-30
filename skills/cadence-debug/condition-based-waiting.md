# Condition-Based Waiting

Use this technique when tests are flaky, async timing is involved, or test code
uses arbitrary sleeps.

## Core Rule

Wait for the actual condition you care about, not a guess about how long the
system might take.

## When to Use

Use this when:

- tests use `sleep`, `setTimeout`, fixed delays, or similar waits;
- tests pass locally but fail under load or in CI;
- async events race with assertions;
- parallel execution changes timing;
- a timeout is increased as a flaky-test fix.

Do not replace real timing assertions such as debounce, throttle, or retry
interval behavior. When an arbitrary timeout is truly testing time, document
why and first wait for the triggering condition.

## Pattern

Bad:

```typescript
await new Promise((resolve) => setTimeout(resolve, 50));
expect(getResult()).toBeDefined();
```

Better:

```typescript
await waitFor(() => getResult() !== undefined, "result to exist");
expect(getResult()).toBeDefined();
```

## Generic Helper

```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000
): Promise<T> {
  const start = Date.now();

  while (true) {
    const result = condition();
    if (result) return result;

    if (Date.now() - start > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }

    await new Promise((resolve) => setTimeout(resolve, 10));
  }
}
```

## Requirements

- always include a timeout;
- include a useful timeout error;
- call the getter inside the loop so data is fresh;
- wait for a triggering condition before waiting for documented timing behavior;
- do not increase arbitrary delays as a flaky-test fix.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Polling too fast | Use a reasonable interval such as 10ms unless the domain requires otherwise. |
| No timeout | Always fail with a clear timeout message. |
| Stale data | Read the condition inside the loop. |
| Waiting before trigger | First wait for the event or state that starts the timed behavior. |
| Increasing sleeps | Replace the guess with a condition. |
