---
name: cadence-research
description: Run Dev Cadence research spikes. Use for feasibility checks, technical comparisons, option analysis, evidence-backed recommendations, risk investigation, or design research when the user needs a decision input and has not approved implementation.
---

# Cadence Research

Use this Skill for `research-spike` work: answer a bounded research question with evidence, options, tradeoffs, risks, recommendation, and open questions.

Do not implement product changes from this Skill. Research output is decision input, not delivery approval.

## Required References

- `../../references/principles.md`
- `../../references/workflows.md`
- `../../references/task-classes.md`
- `../../references/agent-blueprints.md`
- `../../references/human-gates.md`
- `../../references/spec-templates.md`

Load `../../references/context-pack.md` and `../../references/harness.md` when dispatching a Researcher Worker or persistent run evidence is required.

## Scope

Produce artifact-ready content for `specs/records/{task_id}/research-report.md` when persistent artifacts are being used.

Research may inspect code, docs, tests, dependency metadata, logs, or approved external sources. Return source dates or version caveats when evidence may become stale.

## Required Behavior

1. Confirm the research question, constraints, non-goals, and decision boundary.
2. If the question is ambiguous, route through `cadence-clarify` before researching.
3. Gather evidence from approved sources and return source paths, commands, links, versions, or dates.
4. Compare options using explicit criteria.
5. State confidence, evidence gaps, risks, and open questions.
6. Recommend a path, including when no option is ready.
7. Hand off to Human decision, `cadence-clarify`, or `cadence-plan` only if follow-up delivery is explicitly approved.

Do not make final architecture, product, release, or business-priority decisions. Open a Human Gate when the recommendation depends on cost, schedule, risk tolerance, long-term technical direction, production behavior, security, privacy, or data handling.

Do not write product source, tests, migrations, build scripts, deployment files, or application configuration from this Skill. If research reveals a needed code change, return it as a recommendation or follow-up task.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
