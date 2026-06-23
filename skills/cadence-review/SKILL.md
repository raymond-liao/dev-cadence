---
name: cadence-review
description: Review Dev Cadence delivery work. Use for checkpoint review, final implementation review, code review requests, or when implementation needs spec compliance and code quality assessment before completion.
---

# Cadence Review

Use this Skill between implementation and completion, or whenever the user requests review.

## Required References

- `../../references/review-discipline.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

## Required Behavior

Review in two stages:

1. spec compliance: compare implementation to clarified requirements, plan, and acceptance criteria;
2. code quality: look for correctness, maintainability, security, reliability, and scope issues.

Findings lead. Critical or high severity issues block progress unless a named Human Gate accepts the residual risk.

Write or update `specs/{task_id}/07-review-report.md` when persistent artifacts are being used.
