---
name: cadence-subagent-development
description: Execute approved Dev Cadence plans with isolated Worker contexts. Use when an approved plan has bounded tasks that can be executed one at a time by fresh Workers, with each task requiring spec compliance review and code quality review before it is marked complete.
---

# Cadence Subagent Development

Use this Skill when `cadence-executing-plans` selects sequential subagent-style execution for an approved plan.

## Required References

- `../../references/execution-orchestration.md`
- `../../references/harness.md`
- `../../references/context-pack.md`
- `../../references/review-discipline.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

Load `../../references/adapters.md` only when an external Worker adapter is configured or requested.

## Required Behavior

Before dispatching any Worker:

1. Read the approved task plan once.
2. Extract every task with full text, required files, dependencies, verification, and expected evidence.
3. Build a focused Context Pack and Harness Run Context for the current task.
4. Record required pre-implementation status for `S1` and `S2` implementation or fix work.

For each task:

1. Dispatch one fresh implementer Worker with only the context needed for that task.
2. If the Worker asks questions, answer with evidence or update artifacts before implementation continues.
3. Require implementation evidence, verification output, changed files, and self-review notes.
4. Run spec compliance review before code quality review.
5. Fix spec gaps and re-review until clear.
6. Run code quality review.
7. Fix blocking quality issues and re-review until clear or blocked by a named Human Gate.
8. Mark the task complete only after required evidence is recorded.

Do not dispatch multiple implementation Workers in parallel from this Skill. Use `cadence-dispatch-parallel` only when the domains are independent and the Supervisor selects parallel execution.

Do not let Worker self-review replace independent spec compliance or code quality review.

## Worker Status Handling

Treat Worker results as claims that need evidence:

- `DONE`: proceed to spec compliance review.
- `DONE_WITH_CONCERNS`: inspect concerns before review; update artifacts or escalate if correctness or scope is affected.
- `NEEDS_CONTEXT`: provide context or update task artifacts before re-dispatch.
- `BLOCKED`: classify blocker as missing context, task size, model capability, plan flaw, or external dependency before retrying.

Never force the same Worker to retry unchanged after a real blocker.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
