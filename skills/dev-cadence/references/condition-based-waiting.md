# Condition-Based Waiting

Use this reference when tests are flaky, async timing is involved, or test code uses arbitrary sleeps.

## Core Rule

Wait for the condition you care about, not a guess about how long it might take.

## Use When

- tests use `sleep`, `setTimeout`, or fixed delays;
- tests pass locally but fail in CI;
- async events race with assertions;
- tests timeout under load;
- parallel execution changes timing.

Do not replace real timing assertions such as debounce or throttle behavior. When an arbitrary timeout is truly testing time, document why.

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
