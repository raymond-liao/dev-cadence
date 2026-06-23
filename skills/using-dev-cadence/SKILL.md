---
name: using-dev-cadence
description: Bootstrap Dev Cadence for software delivery work. Use at session start, before any feature, bugfix, refactor, review, research spike, incident, verification, acceptance, or repository contract request, and whenever deciding which Dev Cadence discipline Skill applies.
---

# Using Dev Cadence

Use this Skill as the Dev Cadence bootstrap and router. It is the only Skill that represents Dev Cadence as a whole.

## Required References

Load only the shared resources needed for the current routing decision:

- `../../references/principles.md`
- `../../references/workflows.md`
- `../../references/task-classes.md`
- `../../references/supervisor-state-machine.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`
- `../../references/human-gates.md`
- `../../references/spec-templates.md`

Load `../../references/delivery-disciplines.md` when selecting a detailed discipline.

## Routing Rule

Before acting on software delivery work, identify the current workflow state, task class, evidence requirement, and applicable discipline Skill:

- repository contract setup, inspection, sync, repair, or diagnosis -> `cadence-sync`;
- unclear goal, scope, expected behavior, non-goals, design, or acceptance -> `cadence-clarify`;
- approved design that needs executable tasks -> `cadence-plan`;
- approved plan ready for implementation -> `cadence-execute`;
- testable behavior change during implementation -> `cadence-tdd`;
- bug, incident, failing test, or unknown cause -> `cadence-debug`;
- implementation checkpoint or final review -> `cadence-review`;
- before claiming fixed, done, passing, approved, or complete -> `cadence-verify`.

If multiple Skills apply, invoke the process Skill first, then the implementation-specific Skill.

## Repo Contract

A target repository does not need to be initialized before Dev Cadence can help. Create or use `specs/{task_id}/` when persistent artifacts are needed. Use `cadence-sync` only when the user requests repository setup or when low-risk contract files must be created for durable artifacts.

## Task Weight

Classify conservatively:

- `S0`: low-risk, small, easy to verify, no core behavior, no security/auth/payment/data migration/deletion, no design discussion needed;
- `S1`: ordinary feature, bugfix, refactor, review, research spike, or incident;
- `S2`: security, authentication, authorization, payment, data migration, destructive, compliance, privacy, or high blast-radius work.

When unsure, upgrade to `S1` or `S2`.

## Hard Rules

Do not bypass Supervisor state, Harness evidence, Quality Gates, Human Gates, scope reconciliation, or named Human final acceptance.

Do not make visual companion usage a gate. It is an optional clarification capability for UI, diagram, mockup, or visual comparison tasks and must fall back to text-only clarification when unavailable.
