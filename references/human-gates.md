# Human Gates

Human Gates record explicit human decisions. They are required when automation or agent judgment should not continue alone.

## Types

| Type | Meaning | Typical Use |
|---|---|---|
| `approval_required` | work cannot continue without explicit approval | merge, release, production, secret access, database write, CI change, destructive operation |
| `review_required` | human review is needed before direction is locked | architecture, security, high-risk refactor |
| `info_required` | missing information blocks correct execution | ambiguous requirement, unclear acceptance criterion, conflicting business rule |
| `notify_only` | human is informed but workflow is not blocked | low-risk retry, status update, non-critical environment issue |

## Required Gate Record

```yaml
gate_type:
state:
reason:
decision_needed:
options:
recommended_option:
evidence:
risk_if_skipped:
requested_by:
decision:
decided_by:
decided_at:
conditions:
follow_up:
```

## Trigger Conditions

Open a Human Gate for:

- high-risk task classification;
- S2 requirement approval before implementation;
- S2 architecture, data, API, permission, or CI approval before implementation;
- architecture or ADR approval;
- permission escalation;
- destructive operation;
- secret access;
- database write or migration;
- CI/CD or release change;
- production action;
- ambiguous scope or acceptance criteria;
- unclear product intent, reference behavior, user-visible expectation, or non-goal;
- broad or comparative requests where expected behavior is not explicit, such as "not as expected", "inconsistent", "same as", "match", "align", "parity", or "fix this issue";
- user rejection or correction of a previous result that changes scope, expected behavior, non-goals, or acceptance criteria;
- any proposed scope reduction or non-goal that was inferred rather than stated by the user;
- conflict between authoritative sources;
- incomplete verification that may still be accepted;
- final acceptance.

## Decision Capture

Write human decisions into the artifact that owns the decision:

- requirements decisions in `01-requirements.md`;
- architecture decisions in `02-design.md` or ADR;
- permission decisions in `runs/{run_id}/permission-decisions.md`;
- final acceptance in `08-acceptance.md`.

Do not treat an informal chat acknowledgement as durable approval unless it is copied into the relevant artifact.
Do not treat a request to commit code as final Human acceptance. A commit can
be requested while G6 is still pending, but the agent must say that final Human
acceptance is pending unless `08-acceptance.md` records the named Human
accepter and accepted residual risk.
When G6 is pending, the agent must also summarize the decision being requested:
goal, accepted scope or changed files, verification status, skipped checks,
review decision, blockers, residual risk, evidence reviewed or available, and
the exact `08-acceptance.md` fields that still need a Human decision. The agent
must refresh the browsable report with
`scripts/generate-spec-report.mjs --specs-dir specs/records --report-dir specs/report`
and provide `specs/report/{task_id}/index.html` as the approval review entry.
Use `scripts/summarize-acceptance.mjs --task-id <task_id> --require-report` to
produce the summary when artifacts exist.

Do not treat an agent assumption as a Human decision. If a missing answer affects product behavior or acceptance, record `info_required` and wait.
Do not treat source-code inspection as a substitute for Human clarification when user intent is unclear.
Do not treat repository evidence as a Human decision. Evidence can justify candidate interpretations, but only a named Human can select or defer the interpretation when clarification is required.

For `info_required`, do limited read-only analysis before asking the user. The question must include:

- what was inspected;
- candidate interpretations or likely inconsistency sources;
- the recommended interpretation;
- tradeoffs or impact;
- the exact decision needed.

Do not ask broad undirected questions when the repository can be inspected to form concrete options.

Do not record Supervisor, Harness, Developer, Tester, Reviewer, or an unspecified agent as the Human decision owner.
Do not modify product code while a Human Gate is waiting for clarification.

## Required S2 Gates

For `S2` work, record Human Gate decisions before:

- implementation starts, when requirements or architecture affect durable behavior;
- high-risk permission, data, CI/CD, public API, or destructive actions execute;
- final acceptance, especially when verification is incomplete or residual risk remains.

If the decision is unavailable, enter `blocked` with the requested decision and recommended options.

## Resolution

After a Human Gate decision:

- continue to the selected state;
- split the task if scope is too broad;
- defer blocked work with residual risk;
- stop if the risk or missing information is unacceptable.
