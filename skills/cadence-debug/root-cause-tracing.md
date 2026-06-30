# Root Cause Tracing

Use this technique when a bug appears deep in execution and the original
trigger is unclear.

## Core Rule

Trace backward through the call chain until you find where the bad value,
wrong state, or missing invariant originated. Fix at the source, not only where
the symptom appears.

## When to Use

Use this when:

- the error appears far from user input or the triggering test;
- a stack trace crosses several layers;
- an invalid value appears but its origin is unclear;
- a dangerous operation receives bad state;
- a test or caller pollutes later execution.

## Process

1. Observe the symptom and capture the exact error.
2. Find the immediate cause: the operation, line, or state that directly fails.
3. Ask what called this code with the bad value or state.
4. Trace the relevant value one level upward.
5. Repeat until you find the original trigger.
6. Fix the source.
7. Add downstream validation when the failure mode is dangerous.

## Instrumentation

When manual tracing stalls, add temporary diagnostics immediately before the
dangerous operation:

```text
value being used
current working directory or environment
operation about to run
call stack
timestamp or request id when relevant
```

In tests, use output visible in the test runner. Remove temporary diagnostics
after confirming the root cause unless they are useful production
observability.

## Finding Test Pollution

If a file, directory, environment state, or cache appears during a test run and
you do not know which test created it, use `find-polluter.sh`:

```bash
skills/cadence-debug/find-polluter.sh '.git' 'src/**/*.test.ts' npm test --
```

The script runs matching tests one at a time, stops at the first test that
creates the unwanted path, and prints the focused command to reproduce it. Pass
the test command after the pattern; when omitted, it defaults to `npm test --`.

## Questions

- Where did this value come from?
- What layer first allowed it to become invalid?
- What assumptions did each layer make?
- Which code path bypassed validation?
- Which test, input, or event triggered the path?

## Fix Standard

Do not stop at "this line failed." Record:

- original trigger;
- propagation path;
- source fix;
- validation or guard layers added;
- regression evidence.

NEVER fix just where the error appears when the source can still be traced.
