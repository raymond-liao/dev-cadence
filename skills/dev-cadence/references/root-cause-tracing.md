# Root Cause Tracing

Use this reference when a bug appears deep in execution and the original trigger is unclear.

## Core Rule

Trace backward through the call chain until you find where the bad value or wrong state originated. Fix at the source, not only where the symptom appears.

## Process

1. Observe the symptom.
2. Find the immediate cause.
3. Ask what called this code.
4. Trace the relevant value or state one level up.
5. Repeat until you find the original trigger.
6. Fix the source.
7. Add validation at downstream layers when the failure mode is dangerous.

## Instrumentation

When manual tracing stalls, add temporary diagnostics before the dangerous operation:

```text
value being used
current working directory or environment
operation about to run
call stack
timestamp or request id when relevant
```

In tests, use output that is visible in the test runner. Remove or downgrade temporary diagnostics after root cause is confirmed unless they are useful production observability.

## Data Flow Questions

- Where did this value come from?
- What layer first allowed it to become invalid?
- What assumptions did each layer make?
- Which code path bypassed validation?
- Which test or input triggers the path?

## Fix Standard

Do not stop at "this line failed." Record:

- original trigger;
- propagation path;
- source fix;
- validation or guard layers added;
- regression evidence.
