---
name: dev-cadence-deliver
description: Run Dev Cadence delivery work in an initialized repository. Use for feature development, bugfixes, refactors, code review, research spikes, incidents, or behavior-changing work after repository rules route delivery to Dev Cadence.
---

# Dev Cadence Deliver

Use this Skill for ordinary software delivery only after a repository has been initialized with the Dev Cadence thin contract.

## Required References

Load the narrow shared resource required by the current state:

- `../../references/principles.md`
- `../../references/workflows.md`
- `../../references/supervisor-state-machine.md`
- `../../references/delivery-disciplines.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`
- `../../references/human-gates.md`
- `../../references/spec-templates.md`

Load additional discipline references through `../../references/delivery-disciplines.md`.

## Scope

Create task artifacts under `specs/{task_id}/` and Harness evidence under `specs/{task_id}/runs/{run_id}/`.

Use `../../scripts/init-task-artifacts.mjs` when a new task or run artifact set is needed.

Do not perform repository initialization or maintenance unless the user explicitly asks for it in the same turn.

## Required Behavior

Infer `selected_workflow` and `task_class`, but do not infer unclear product intent. If goal, scope, non-goals, reference behavior, or acceptance criteria are ambiguous, enter Human Gate `info_required` before implementation.

Run Worker states through Harness evidence even when one Codex instance performs multiple roles.

Do not claim completion until verification evidence exists and final acceptance is attributed to a named Human.
