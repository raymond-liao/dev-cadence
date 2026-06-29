---
name: cadence-request-review
description: Request or perform Dev Cadence review of completed implementation work. Use for checkpoint review, final implementation review, code review requests, or when implementation needs spec compliance and code quality assessment before verification or completion.
---

# Cadence Request Review

Use this Skill to request or perform review of implementation work. It produces findings and a review decision. It does not implement fixes for review feedback.

## Required References

- `../../references/review-discipline.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

## Required Behavior

Review in two stages:

1. spec compliance: compare implementation to clarified requirements, plan, and acceptance criteria;
2. code quality: look for correctness, maintainability, security, reliability, and scope issues.

Do not run code quality review before spec compliance passes or unresolved spec gaps are recorded.

Findings lead. Blocker or major issues block progress unless a named Human Gate accepts the residual risk.

Write or update `specs/records/{task_id}/07-review-report.md` when persistent artifacts are being used.

If review finds valid blocking issues, hand off to `cadence-review`. Do not fix findings inside this Skill.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
