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

Update `specs/{task_id}/06-test-report.md` and acceptance summary artifacts when persistent artifacts are being used.

Do not treat `partially_verified`, `not_verified`, or `blocked_by_environment` as complete unless a named Human accepts the gap.
