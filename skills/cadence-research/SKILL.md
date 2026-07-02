---
name: cadence-research
description: Run Dev Cadence research spikes. Use for feasibility checks, technical comparisons, option analysis, evidence-backed recommendations, risk investigation, or design research when the user needs decision input and has not approved implementation.
---

# Cadence Research

Use this Skill for `research-spike` work: answer a bounded research question with evidence, options, tradeoffs, risks, recommendation, and open questions.

Research output is decision input, not delivery approval. Do not implement product changes from this Skill.

## Required References

- `../../references/principles.md`
- `../../references/workflows.md`
- `../../references/task-classes.md`
- `../../references/agent-blueprints.md`
- `../../references/human-gates.md`
- `../../references/spec-templates.md`

Load `../../references/context-pack.md` and `../../references/harness.md` only when dispatching a Researcher Worker or when the Supervisor/Harness requires persistent run evidence.

## When to Use

Use this Skill when the current workflow question is research, evaluation, comparison, feasibility, or recommendation without approved implementation:

- technical selection or unknown feasibility;
- design option research before choosing an approach;
- risk investigation, dependency/library comparison, migration feasibility, or architecture tradeoff analysis;
- evidence-backed recommendation needed for Human or Architect review.

Do not use this Skill for:

- implementing, refactoring, testing, migrating, configuring, or deploying product changes;
- code review findings on an existing diff;
- debugging an observed failure where the goal is to find and fix root cause;
- planning already-approved delivery work.

If the request mixes research with implementation, split the workflow: complete the research handoff first, then require explicit Human approval before `using-dev-cadence` routes follow-up delivery.

## Research Boundary

Before gathering sources, state the research boundary:

```yaml
research_question:
decision_boundary:
constraints:
non_goals:
allowed_sources:
comparison_criteria:
implementation_not_authorized: true
```

If the question, allowed sources, comparison criteria, or decision boundary is ambiguous enough to affect the recommendation, route through `cadence-clarify` before researching. Do limited read-only context inspection first so the clarification question can present concrete options instead of asking broadly.

## Evidence Rules

Every material recommendation must trace to source evidence. Return source paths, commands, links, versions, dates, or source freshness caveats.

Use repository and current-source evidence before older or informal sources. When sources conflict and the conflict affects scope, architecture, security, permissions, cost, schedule, production behavior, privacy, data handling, or acceptance, do not choose silently; surface the conflict as a Human decision.

For date-sensitive external facts, include the access date or version caveat. Do not present stale external information as current.

## Option Analysis

Compare options using the stated criteria. Include a `do nothing`, defer, or no-ready-option path when it is plausible.

For each option, include:

- evidence supporting it;
- tradeoffs and constraints;
- risks and reversibility;
- prerequisites or follow-up decisions;
- what evidence would invalidate the option.

Do not pad the comparison with weak options only to reach a number. If there is one credible option, say why alternatives were rejected.

## Recommendation Gate

Recommendations must be explicit about confidence and limits:

```yaml
recommendation:
confidence: high | medium | low
evidence_gaps:
risks:
open_questions:
human_decisions_needed:
follow_up_delivery_needed: true | false
```

Open a Human Gate when the recommendation depends on cost, schedule, risk tolerance, long-term technical direction, production behavior, security, privacy, data handling, or unresolved source conflicts.

Do not make final architecture, product, release, or business-priority decisions. If an option is adopted, the durable decision belongs in `02-design.md`, an ADR, `08-acceptance.md`, or another Supervisor/Harness-selected artifact path.

## Artifact Handoff

When persistent artifacts are being used, produce artifact-ready content for `specs/records/{task_id}/research-report.md` using the `templates/spec/research-report.md` fields:

- `research_question`, `constraints`, `non_goals`, and `decision_boundary`;
- `sources_reviewed` with paths, commands, links, versions, or dates;
- `comparison_criteria`, `options`, `recommendation`, and `confidence`;
- `evidence_gaps`, `risks`, `open_questions`, and `human_decisions`;
- `follow_up_delivery_needed`.

Write or update specified artifact targets only when Supervisor/Harness context provides the paths and authorizes this Skill as the artifact-writing action; otherwise return complete artifact-ready content to the Supervisor/Harness path. Do not choose artifact paths, create workflow records, own Harness-evidence recording, own gate status, or write acceptance records from this Skill.

## Stop Conditions

Stop and hand back to `using-dev-cadence` when:

- implementation, migration, deployment, dependency installation, or product configuration would be required to continue;
- source access, credentials, network access, or permissions are missing;
- sources conflict on a decision-relevant fact;
- the research question expands into a delivery task;
- the recommendation needs a Human decision before additional work is meaningful.

Do not use research momentum as permission to edit product source, tests, migrations, build scripts, deployment files, or application configuration. If research reveals a needed code change, return it as a recommendation or follow-up task.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence fields produced, unresolved blockers, gate-relevant observations, required Human decisions, and recommended next state. Do not select the next cadence Skill from here.
