---
name: cadence-executing-plans
description: Execute approved Dev Cadence delivery plans. Use when the Supervisor has selected inline or adapter-driven implementation execution for an approved plan.
---

# Cadence Executing Plans

Use this Skill only after `using-dev-cadence` has selected inline or adapter-driven execution for an approved plan.

## Core Rule

Read the approved plan, review it critically, execute task steps in order, run specified verification, and stop when blocked.

Do not route workflow, select other cadence Skills, mark gates complete, write persistent records, accept risk, or claim completion.

## Required References

- `../../references/principles.md`
- `../../references/execution-orchestration.md`
- `../../references/harness.md`
- `../../references/context-pack.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

Read `../../references/adapters.md` only when an external adapter is configured or requested.

## Step 1: Load and Review Plan

Read the approved plan and Supervisor-selected execution context:

- `03-tasks.md`;
- `04-test-plan.md`;
- requirements and design artifacts;
- task class, allowed files, required evidence, gates, and implementation discipline.

Check task order, target files, dependencies, acceptance mapping, verification commands, expected results, and forbidden actions.

For `S1` and `S2` implementation or fix work, ensure `runs/{run_id}/pre-implementation-status.md` exists before the first product source, test, migration, build, deployment, or application configuration edit.

If the plan has critical gaps, unapproved scope, missing target files, unclear instructions, impossible verification, missing approvals, or a required discipline/gate not present in the Supervisor context, stop and return the mismatch to `using-dev-cadence`. Do not implement or switch Skills directly.

Create local todos only after review finds no blocker.

## Step 2: Execute Tasks

For each task:

1. Track one task as in progress locally.
2. Follow approved steps exactly unless unsafe, impossible, or inconsistent with repository reality.
3. Apply only the implementation discipline selected by `using-dev-cadence` for this run.
4. Stay within approved files and allowed write paths.
5. Run the task's focused verification and relevant neighboring checks.
6. Return task-status fields, changed files, commands, outputs, skipped checks, residual risk, and scope reconciliation as fields for Supervisor/Harness recording when persistent artifacts are being used.

Task status is one of: `implemented`, `verification_failed`, `blocked`, `needs_plan_update`.

Do not treat local task progress as gate or workflow completion.

## Stop Conditions

Stop and return to `using-dev-cadence` when:

- a dependency is missing;
- a plan instruction is unclear;
- the repository differs from the plan;
- verification fails unexpectedly or repeatedly;
- implementation would exceed approved scope or allowed files;
- permission, architecture, security, migration, CI/CD, release, production, Human Gate, or unselected cadence discipline is required.

Ask for clarification or a named Human decision through the Supervisor rather than guessing. If the plan changes, return to Step 1 before continuing.

## Handoff

Return:

- task statuses;
- changed files and scope reconciliation;
- verification commands, exit codes, and relevant output summaries;
- skipped checks and reasons;
- implementation discipline evidence or named exceptions from the Supervisor-selected context;
- blockers, unresolved risks, and required Human decisions;
- recommended next state for Supervisor consideration.

Do not approve, accept, commit, mark gates complete, or say done/fixed/passing/ready from this Skill.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence fields produced, unresolved blockers, gate-relevant observations, and recommended next state. Do not select the next cadence Skill from here.
