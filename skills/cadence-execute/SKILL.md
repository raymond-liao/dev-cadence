---
name: cadence-execute
description: Execute approved Dev Cadence delivery plans. Use when a plan is ready for implementation, Worker execution, inline execution, or adapter-driven execution through Harness evidence.
---

# Cadence Execute

Use this Skill for implementation execution after clarification and planning gates are satisfied.

## Required References

- `../../references/principles.md`
- `../../references/execution-orchestration.md`
- `../../references/harness.md`
- `../../references/context-pack.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

Read `../../references/adapters.md` only when an external adapter is configured or requested.

## Scope

Execute planned work and record Harness evidence under `specs/{task_id}/runs/{run_id}/` when persistent evidence is required.

Use `../../scripts/init-task-artifacts.mjs` when a new task or run artifact set is needed.

## Required Behavior

For `S1` and `S2` implementation or fix work, write or update
`runs/{run_id}/pre-implementation-status.md` before the first product source,
test, migration, build, deployment, or application configuration edit.

Do not expand scope silently. Record scope reconciliation when changed files or behavior differ from the plan.

For testable behavior changes, use `cadence-tdd` during implementation. For bugs, incidents, failing tests, or unclear cause, use `cadence-debug` before changing production code.

Do not claim completion. Return control to the Supervisor before any review, verification, or completion claim.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
