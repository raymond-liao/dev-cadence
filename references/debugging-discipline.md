# Debugging Discipline

Use this shared reference only as the routing marker for `bugfix`,
`incident-fix`, unexpected behavior, test failures, build failures, and
integration problems.

The full debugging workflow belongs to `skills/cadence-debug/SKILL.md`.
Debugging-specific techniques belong with that Skill:

- `skills/cadence-debug/root-cause-tracing.md`
- `skills/cadence-debug/condition-based-waiting.md`
- `skills/cadence-debug/defense-in-depth.md`

## Core Rule

```text
No fixes without root cause investigation first.
```

Random fixes waste time and create new bugs. Symptom fixes are blocked unless a
named Human explicitly accepts emergency residual risk.

When a Worker, parallel dispatch, or workflow reference needs debugging
discipline, route to `cadence-debug` instead of duplicating its method here.
