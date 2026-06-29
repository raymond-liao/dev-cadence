---
name: cadence-verify
description: Verify Dev Cadence work before any completion claim. Use before saying fixed, done, passing, approved, complete, ready, or accepted, and whenever verification evidence, skipped checks, residual risk, or Human acceptance must be summarized.
---

# Cadence Verify

Use this Skill before any completion claim.

## Required References

- `../../references/verification-discipline.md`
- `../../references/quality-gates.md`
- `../../references/human-gates.md`
- `../../references/spec-templates.md`

## Required Behavior

Verify:

- required tests or commands ran and results are known;
- skipped checks are named with reasons;
- changed files match planned scope;
- unplanned diffs are explained or reverted with permission;
- residual risks are explicit;
- final acceptance, when required, names a Human accepter.

When persistent artifacts exist, run `scripts/check-gates.mjs --task-id
<task_id>` and include the Gate Summary in the handoff. Before creating a Git
commit for a dirty worktree, run `scripts/check-before-commit.mjs --task-id
<task_id>`. If G6 final Human acceptance is pending, block the commit and ask
the Human to accept the result and residual risk before committing.

When G6 is pending, the user-facing handoff must state what is being accepted.
Run `scripts/summarize-acceptance.mjs --task-id <task_id>` or provide the same
fields directly: goal, changed scope, verification status, skipped checks,
review decision, blockers, residual risk, evidence available, and the fields to
record in `08-acceptance.md`. Do not merely say "G6 is pending".

Update `specs/records/{task_id}/06-test-report.md` and acceptance summary artifacts when persistent artifacts are being used.

Do not treat `partially_verified`, `not_verified`, or `blocked_by_environment` as complete unless a named Human accepts the gap.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
