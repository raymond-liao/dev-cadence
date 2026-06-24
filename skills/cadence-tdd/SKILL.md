---
name: cadence-tdd
description: Apply Dev Cadence test-driven implementation discipline. Use during implementation of testable behavior changes, bug fixes with reproducible behavior, and any change where a failing test can describe the intended behavior before production code changes.
---

# Cadence TDD

Use this Skill for testable behavior changes.

## Required References

- `../../references/implementation-discipline.md`
- `../../references/testing-anti-patterns.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`

## Required Behavior

Follow Red-Green-Refactor:

1. RED: write the smallest failing test for the intended behavior and observe it fail for the expected reason.
2. GREEN: write the minimum production code needed to pass.
3. REFACTOR: improve the code while keeping tests passing.

Record commands, failures, passes, and skipped checks in Harness evidence when artifacts are being written.

If TDD is not feasible, record why, choose the next-best feedback loop, and keep the Quality Gate blocked unless verification evidence or a named Human Gate accepts the gap.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
