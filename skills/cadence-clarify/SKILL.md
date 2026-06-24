---
name: cadence-clarify
description: Clarify delivery intent before implementation. Use for feature requests, ambiguous fixes, design-sensitive changes, unclear expected behavior, missing acceptance criteria, UI or visual alignment needs, or any task that needs requirements readiness.
---

# Cadence Clarify

Use this Skill before planning or implementation when intent is unclear or unconfirmed.

## Required References

Read the narrow resources needed for the current clarification:

- `../../references/principles.md`
- `../../references/workflows.md`
- `../../references/task-classes.md`
- `../../references/intent-and-design-discipline.md`
- `../../references/human-gates.md`
- `../../references/spec-templates.md`

Read `../../references/visual-companion.md` only when UI, diagram, mockup, or visual comparison would materially improve alignment.

## Scope

Clarify and record:

- goal;
- scope and non-goals;
- expected behavior and reference behavior;
- constraints and risks;
- acceptance criteria;
- verification approach.

For standard or high-risk tasks, create or update task artifacts under `specs/{task_id}/`, especially `00-brief.md`, `01-requirements.md`, and `02-design.md`.

## Required Behavior

Do limited read-only analysis before asking questions. Present candidate interpretations with evidence and tradeoffs when possible.

Do not convert assumptions into requirements. If unresolved ambiguity could materially change implementation or acceptance, enter Human Gate `info_required` and block implementation.

Visual companion is optional. If unavailable, continue with text-only clarification and record the fallback when evidence is being written.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
