---
name: cadence-review
description: Address Dev Cadence review feedback. Use after code review, checkpoint review, PR review, requested changes, or reviewer findings when Codex must verify findings, fix valid issues, push back on invalid issues with evidence, rerun verification, and request re-review.
---

# Cadence Review

Use this Skill after review findings exist and the task is to handle those findings. This Skill is separate from `cadence-request-review`: request-review produces findings; this Skill verifies and addresses them.

## Required References

- `../../references/review-discipline.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

Load `../../references/implementation-discipline.md` and `../../references/testing-anti-patterns.md` when a valid finding requires implementation or test changes.

## Required Behavior

For each finding:

1. Verify it against code, tests, specs, artifacts, and reviewer evidence.
2. Classify it as valid, partially valid, invalid, duplicate, or needs Human decision.
3. Fix valid blocker and major issues before continuing unless a named Human accepts the residual risk.
4. Push back on invalid findings with concrete evidence and affected locations.
5. Keep fixes scoped to the finding; do not add unrelated refactors or new behavior.
6. Rerun targeted verification, then broader verification when integration risk exists.
7. Update `specs/records/{task_id}/07-review-report.md`, `05-implementation.md`, and run evidence when persistent artifacts are being used.

If a finding reveals unclear requirements, changed scope, or design risk, return to `cadence-clarify` or `cadence-plan` through the Supervisor before implementing more changes.

Do not treat "addressed" as "approved". After fixes, return to `cadence-request-review` for re-review and then `cadence-verify` before any completion claim.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
