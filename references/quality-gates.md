# Quality Gates

Each gate must define inputs, outputs, pass condition, fail condition, evidence, override rules, and escalation.

## Gates

| Gate | Name | Pass Condition |
|---|---|---|
| `G1` | requirements accepted | scope, non-goals, constraints, and acceptance criteria are clear, and ambiguity that could materially change implementation or acceptance is resolved |
| `G2` | design accepted when required | high-risk or architecture-sensitive tasks have design or ADR approval |
| `G3` | task executable | tasks include inputs, outputs, target files, acceptance mapping, verification plan, forbidden actions, and task-class escalation rules |
| `G4` | test evidence complete and reproducible | every affected component and changed platform has matching verification, and verification status is `verified`, or a named Human Gate accepts incomplete verification |
| `G5` | review has no unresolved blocker or major issue | G4 is passed or overridden by Human Gate, scope reconciliation is complete, and Reviewer decision is `approved` or `approved_with_minor_notes` |
| `G6` | human accepts result | named Human has accepted final output and residual risk |

## Gate Record

Use this shape inside the relevant artifact or gate report:

```yaml
gate_id:
status:
required_inputs:
evidence:
pass_condition:
fail_condition:
decision:
human_override:
residual_risk:
escalation:
```

Allowed `status` values:

```text
passed
failed
blocked
skipped
```

## Verification Status

Verification status must be one of:

```text
verified
partially_verified
not_verified
blocked_by_environment
```

For any status other than `verified`, record:

- evidence gap;
- residual risk;
- recommended follow-up;
- whether Human acceptance is allowed.

Statuses other than `verified` do not pass G4 by themselves. They must enter Human Gate before review can approve or acceptance can pass.

## Override Rules

Human override can accept residual risk but cannot erase missing evidence. The override must name a Human decision owner, not Supervisor or a Worker Agent. When an override is used, record:

- who accepted;
- what evidence was missing or failed;
- why continuing is acceptable;
- required follow-up;
- time limit or revisit condition when applicable.

## Review and Acceptance Blocking Rules

- If unresolved ambiguity affects product intent, user-visible behavior, scope, non-goals, or acceptance criteria, G1 is blocked and implementation must not start.
- If a non-goal or scope reduction is based on an assumption rather than a named Human decision, G1 is blocked.
- If Requirements Readiness Check is missing or incomplete, G1 is blocked.
- If expected behavior, reference behavior, or comparison dimension is inferred from code rather than confirmed by user or authoritative docs, G1 is blocked.
- If clarification was required but no analysis-backed candidate interpretation was presented to the user, G1 is blocked.
- If clarification was required and no named Human selected or deferred the interpretation, G1 is blocked.
- If clarification or requirements acceptance is attributed to repository evidence, code inspection, Supervisor, Harness, or any Worker Agent, G1 is blocked.
- If the user rejects or corrects a prior result, G1 returns to blocked until requirements are updated and clarified.
- If actual changed files include unplanned files, deleted files, new components, new platforms, or stronger risk triggers, G3 is blocked until requirements, design, tasks, and verification plan are reconciled or a named Human accepts the narrowed evidence.
- If task class changes during execution and the escalation reason, new gates, and required Human decisions are not recorded, G3 is blocked.
- If any changed component, platform, API, schema, migration, security, permission, CI/CD, release, or production behavior lacks matching verification or explicit skipped-check risk, G4 is blocked.
- If G4 is not passed or explicitly overridden, Reviewer decision must be `changes_requested` or `blocked`.
- If required Harness evidence files are missing, G4 and G5 are blocked.
- If `08-acceptance.md` does not name a Human accepter, G6 is blocked.
- If S2 lacks requirement, architecture, permission, or final Human Gate decisions required by its risk profile, G6 is blocked.

## Escalation

Escalate to Human Gate when:

- gate input is missing;
- product intent or acceptance has multiple reasonable interpretations;
- repository evidence or code inspection is being treated as user clarification;
- user feedback invalidates prior assumptions or acceptance criteria;
- evidence is contradictory;
- test environment blocks verification;
- Reviewer finds a blocker or major issue;
- acceptance depends on risk tolerance or business priority.
