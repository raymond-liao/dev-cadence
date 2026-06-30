---
name: cadence-request-review
description: Request or perform Dev Cadence review of completed implementation work. Use for checkpoint review, final implementation review, code review requests, or when implementation needs spec compliance and code quality assessment before verification or completion.
---

# Cadence Request Review

Use this Skill to request or perform review of implementation work. It produces findings and a review decision. It does not implement fixes for review feedback.

Core principle: review the work product, not the implementer's conversation
history. Provide precise context and keep reviewer execution read-only.

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

## Reviewer Context

When dispatching reviewer Workers, provide only the context needed to review the
work:

- task description and task class;
- requirements, plan, acceptance criteria, and design decisions;
- changed file list and relevant diff or git range;
- implementation notes and verification evidence;
- known skipped checks, residual risks, and Human decisions.

Do not pass the current chat history as reviewer context. Do not ask the reviewer
to infer the intended behavior from implementer commentary.

Reviewer Workers are read-only:

- inspect code, specs, diffs, logs, and tests;
- do not mutate the working tree, index, branch state, specs, or run evidence;
- use a separate temporary checkout if another revision must be inspected.

## Review Output

Every review must provide:

- strengths or correct decisions worth preserving;
- findings grouped by `blocker`, `major`, `minor`, and `note`;
- file and line references for each concrete issue when available;
- why each issue matters;
- suggested fix when the fix is clear;
- explicit verdict: `approved`, `approved_with_minor_notes`,
  `changes_requested`, or `blocked`;
- reasoning for the verdict.

Write or update `specs/records/{task_id}/07-review-report.md` when persistent artifacts are being used.

If review finds valid blocking issues, hand off to `cadence-review`. Do not fix findings inside this Skill.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
