# Debugging Discipline

Use this reference for `bugfix`, `incident-fix`, unexpected behavior, test failures, build failures, and integration problems.

## Core Rule

```text
No fixes without root cause investigation first.
```

Random fixes waste time and create new bugs. Symptom fixes are blocked unless a named Human explicitly accepts emergency residual risk.

## Four Phases

Complete each phase before moving to the next.

### Phase 1: Root Cause Investigation

Before attempting any fix:

1. Read error messages, stack traces, logs, and warnings completely.
2. Reproduce consistently or record why reproduction is blocked.
3. Check recent changes, configuration, dependencies, environment, and test data.
4. Gather evidence at component boundaries in multi-component systems.
5. Trace data flow backward when the error appears deep in the stack.

Use `root-cause-tracing.md` when the symptom appears far from the original trigger.

### Phase 2: Pattern Analysis

Find working examples before changing code:

- similar code in the repository;
- reference implementation;
- expected API usage;
- configuration or environment differences;
- dependencies and assumptions.

List meaningful differences between working and broken paths.

### Phase 3: Hypothesis and Testing

State one hypothesis:

```text
I think X is the root cause because Y.
```

Test with the smallest useful change or diagnostic. Do not bundle fixes. If the hypothesis fails, record the evidence and form a new hypothesis.

### Phase 4: Implementation

Fix the root cause, not only the symptom:

1. Create a failing regression test or characterization when possible.
2. Implement one fix.
3. Verify the fix.
4. Run relevant regression checks.
5. Record residual risk.

If three fix attempts fail, stop and question the architecture or assumptions before attempting a fourth.

## Red Flags

Stop and return to investigation when you catch:

- "quick fix for now";
- "just try changing X";
- proposing solutions before tracing data;
- multiple changes before testing;
- skipping reproduction;
- skipping the regression test;
- not understanding why a fix worked;
- trying one more fix after repeated failures.

## Related References

- `root-cause-tracing.md`: trace bad values backward to original source.
- `condition-based-waiting.md`: replace arbitrary sleeps in flaky async tests.
- `defense-in-depth.md`: add validation at multiple layers after invalid-data bugs.
