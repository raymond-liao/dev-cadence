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

Do not expand scope silently. Record scope reconciliation when changed files or behavior differ from the plan.

For testable behavior changes, use `cadence-tdd` during implementation. For bugs, incidents, failing tests, or unclear cause, use `cadence-debug` before changing production code.

Do not claim completion. Route to `cadence-review` and `cadence-verify` before any completion claim.
