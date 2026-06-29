---
name: cadence-clarify
description: Clarify delivery intent, requirements, and design before planning or implementation. Use for feature requests, behavior changes, ambiguous fixes, design-sensitive work, UI or visual alignment, unclear expected behavior, missing acceptance criteria, or any task that needs requirements readiness.
---

# Cadence Clarify

Use this Skill before planning or implementation for feature work, behavior changes, ambiguous fixes, or any task whose requirements, design, non-goals, acceptance, or verification are not already approved.

## Hard Gate

Do not plan implementation, edit product code, scaffold work, or invoke execution Skills until requirements readiness is satisfied and the named Human has approved the clarified intent. For design-sensitive work, do not proceed until the design or accepted option is approved.

Small tasks can have short clarification, but they still need explicit enough scope, non-goals, acceptance criteria, and verification to prevent invented requirements.

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

For standard or high-risk tasks, create or update task artifacts under `specs/records/{task_id}/`, especially `00-brief.md`, `01-requirements.md`, and `02-design.md`.

## Required Behavior

Follow this order:

1. Explore current project context with limited read-only analysis before asking detailed questions.
2. If visual alignment would materially help, offer the visual companion before asking visual design questions. Keep it optional.
3. Ask focused clarification questions one at a time. Prefer concrete options when possible.
4. When the request has multiple viable interpretations or approaches, present 2-3 options with tradeoffs and a recommendation.
5. Present the clarified requirements or design in sections scaled to the task complexity.
6. Get named Human approval for the clarified intent, requirements, and any required design before handing off to planning or execution.
7. Write or update required artifacts when persistent evidence is being used.
8. Self-review the artifacts before handoff.

Do not convert assumptions into requirements. If unresolved ambiguity could materially change implementation or acceptance, enter Human Gate `info_required` and block implementation.

Visual companion is optional. If unavailable, continue with text-only clarification and record the fallback when evidence is being written.

## Artifact Self-Review

After writing `00-brief.md`, `01-requirements.md`, or `02-design.md`, check for:

- placeholders, TODOs, or unfilled sections;
- contradictions between goal, scope, non-goals, acceptance, and design;
- requirements that can be interpreted in materially different ways;
- unapproved assumptions recorded as requirements;
- acceptance criteria without a verification approach;
- design-sensitive changes missing alternatives, tradeoffs, or Human approval.

Fix issues before handoff. If they cannot be fixed without a Human decision, keep G1 or G2 blocked and ask for that decision.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
