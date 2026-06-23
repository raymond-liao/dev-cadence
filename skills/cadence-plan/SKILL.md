---
name: cadence-plan
description: Write Dev Cadence delivery plans. Use after intent and design are clarified and before implementation, especially when work must be split into executable tasks with files, behavior, verification, risks, and review checkpoints.
---

# Cadence Plan

Use this Skill only after requirements readiness is satisfied or the remaining gaps are explicitly accepted by a named Human Gate.

## Required References

- `../../references/principles.md`
- `../../references/planning-discipline.md`
- `../../references/spec-templates.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`

## Scope

Create or update:

- `specs/{task_id}/03-tasks.md`;
- `specs/{task_id}/04-test-plan.md`.

Each task must include concrete files or modules, intended behavior, verification command or method, dependencies, risk, and expected evidence.

## Required Behavior

Prefer small, reviewable tasks. Do not plan implementation for unresolved requirements. Mark assumptions as blockers unless accepted by a named Human Gate.

If the task is `S0`, a lightweight plan in the conversation or a compact evidence note is acceptable. When unsure, use standard `S1` artifacts.
