---
name: cadence-review
description: Address Dev Cadence review feedback. Use after code review, checkpoint review, PR review, requested changes, or reviewer findings when Codex must verify findings, fix valid issues, push back on invalid issues with evidence, rerun verification, and request re-review.
---

# Cadence Review

Use this Skill after review findings exist and the task is to handle those findings. This Skill is separate from `cadence-request-review`: request-review produces findings; this Skill verifies and addresses them.

Core principle: review feedback is input to evaluate, not an order to obey.
Verify before implementing. Ask before assuming.

## Required References

- `../../references/review-discipline.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

Load `../../references/implementation-discipline.md` only to decide whether a
valid finding requires implementation-state evidence. Do not load or apply
`cadence-tdd` test-writing resources from this Skill.

## Required Behavior

First read all feedback before making changes. If any requested item is unclear,
pause and ask for clarification before partial implementation, because unclear
items may affect the right fix for clear items.

For each finding:

1. Understand the requested change in your own words, or ask for clarification.
2. Verify it against code, tests, specs, artifacts, and reviewer evidence.
3. Evaluate whether it is technically correct for this repository and compatible
   with accepted Human decisions.
4. Classify it as valid, partially valid, invalid, duplicate, or needs Human decision.
5. Fix valid blocker and major issues only when the fix is review-handling work
   that does not require a new implementation cycle.
6. Push back on invalid findings with concrete evidence and affected locations.
7. Keep fixes scoped to the finding; do not add unrelated refactors or new behavior.
8. Rerun targeted verification for each fix, then broader verification when integration risk exists.
9. Update `specs/records/{task_id}/07-review-report.md`, `05-implementation.md`, and run evidence when persistent artifacts are being used.

Do not blindly apply external reviewer suggestions. Check whether the suggestion:

- breaks existing behavior;
- conflicts with accepted requirements or Human decisions;
- adds unused or speculative functionality;
- assumes context the reviewer did not have;
- is technically wrong for this stack or repository.

When a finding is wrong, push back with code, test, spec, or artifact evidence.
When a finding is right, state the fix and evidence. Avoid performative
agreement; the useful output is the correction and verification.

If a finding reveals unclear requirements, changed scope, or design risk, return to `cadence-clarify` or `cadence-plan` through the Supervisor before implementing more changes.

If a valid finding requires production behavior changes, test changes, mocks, or
test utilities, return a handoff to `using-dev-cadence` so the Supervisor can
route the work to `cadence-tdd` or `cadence-executing-plans`. This Skill may
record the finding, validity, scope, and recommended next state, but it must not
own the test-writing discipline.

Do not treat "addressed" as "approved". After fixes, return to `cadence-request-review` for re-review and then `cadence-verify` before any completion claim.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
