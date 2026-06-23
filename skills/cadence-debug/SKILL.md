---
name: cadence-debug
description: Diagnose bugs, incidents, failing tests, regressions, and unclear root causes. Use before fixing unexpected behavior, production incidents, flaky async behavior, invalid data, boundary failures, or symptoms whose origin is not proven.
---

# Cadence Debug

Use this Skill before changing code for a bug or incident unless the root cause and failing behavior are already proven.

## Required References

- `../../references/debugging-discipline.md`
- `../../references/root-cause-tracing.md` when the origin is unclear;
- `../../references/condition-based-waiting.md` for flaky async behavior or arbitrary sleeps;
- `../../references/defense-in-depth.md` for invalid data, unsafe state, or boundary failures;
- `../../references/harness.md`
- `../../references/quality-gates.md`

## Required Behavior

Reproduce or characterize the problem before fixing. Trace the first bad value, state transition, or missing invariant. Do not patch symptoms when the causal path is unknown.

Record reproduction steps, evidence, root cause, fix strategy, and verification in Harness evidence when artifacts are being written.
