# Supervisor State Machine

Use explicit state, not conversational judgment. Any skipped state must record its reason and residual risk.

## States

| State | Owner | Required Input | Required Output | Gate | Next State |
|---|---|---|---|---|---|
| `intake` | Supervisor | user request | `00-brief.md` | goal, constraints, requested outcome, assumptions, and open questions recorded | `classify` or `blocked` |
| `classify` | Supervisor | `00-brief.md` | task class and workflow type | valid task class selected | `requirements` or lightweight path |
| `requirements` | Planner | brief, task class | `01-requirements.md` | scope, non-goals, constraints, acceptance criteria clear and unresolved ambiguity resolved | `design`, `planning`, or `blocked` |
| `design` | Architect | requirements, project constraints | `02-design.md` or ADR | required design is accepted | `planning` |
| `planning` | Planner | requirements, design if present | `03-tasks.md` | tasks are executable and bounded | `implementation` |
| `implementation` | Developer via Harness | tasks, context pack, run context | code diff, `05-implementation.md`, execution report | implementation notes and initial evidence exist | `test` |
| `test` | Tester via Harness | diff, implementation notes, test plan | `04-test-plan.md`, `06-test-report.md`, execution report | verification status recorded with evidence | `review` or `fix` |
| `review` | Reviewer via Harness | diff, test report, implementation notes | `07-review-report.md`, execution report | no unresolved blocker or major issue | `acceptance` or `fix` |
| `fix` | Developer via Harness | structured issue list | patch, updated implementation notes, execution report | scoped fix, loop count within limit | `test` |
| `acceptance` | Human with Supervisor recording | all artifacts and reports | `08-acceptance.md` | named human accepts result and residual risk | `done` |
| `blocked` | Supervisor and Human | blocker evidence | escalation decision | human decides continue, split, defer, or stop | selected state |

## Transition Rules

- Start every delivery task at `intake`.
- Run every Worker Agent state through Harness.
- Produce required Harness evidence for every run: `run-context.md`, `execution-report.md`, `tool-log.md`, `permission-decisions.md`, plus `diff-summary.md` when files change and `test-log.md` when commands or tests run.
- For `S1` and `S2` implementation or fix runs, produce `pre-implementation-status.md` before the first product source, test, migration, build, deployment, or application configuration edit.
- After implementation and before test, reconcile actual changed files, untracked files, created artifact files, deleted files, new components, and new platforms against `02-design.md`, `03-tasks.md`, and `05-implementation.md`.
- Do not rely only on tracked diffs for scope reconciliation. New `specs/{task_id}/` artifacts, generated files, and new source files can be untracked until staged, but still must be classified as planned, unplanned, or evidence-only files.
- If actual diff exceeds planned scope, pause before review and update requirements, design, tasks, and test plan, or record a named Human decision accepting the narrowed evidence.
- Test evidence must cover every changed component or explicitly record skipped checks, residual risk, and whether Human acceptance is allowed.
- Reviewer must check scope reconciliation and verification coverage before approving.
- If task class is strengthened during execution, record previous class, new class, reason, extra gates, and Human decisions before continuing.
- Do not let Supervisor replace missing Worker Agent artifacts with summaries.
- Enter `blocked` when required inputs, permissions, evidence, or decisions are missing.
- Enter a Human Gate for conflicts affecting scope, architecture, security, permissions, test validity, production, release, or final acceptance.
- Enter Human Gate `info_required` when product intent, scope, non-goals, reference behavior, or acceptance criteria have multiple reasonable interpretations.
- Do not convert an unconfirmed assumption into scope, non-goal, task, or acceptance criteria.
- Before planning or implementation, require a Requirements Readiness Check that records expected behavior, reference behavior, scope, non-goals, acceptance criteria, verification approach, and source for each decision.
- If the request uses any-language broad or comparative wording equivalent to "not as expected", "inconsistent", "same as", "match", "align", "parity", or "fix this issue", perform limited read-only analysis and present candidate interpretations before asking for confirmation.
- Clarification must include evidence paths, 2-4 plausible interpretations when available, a recommended option, and the impact of choosing it.
- Do not ask broad questions such as "what is inconsistent?" until after checking the relevant code, docs, specs, or existing behavior enough to propose concrete possibilities.
- Repository evidence can support candidate interpretations, but it cannot clarify user intent or pass G1. When clarification is required, G1 needs a named Human decision that selects or defers the interpretation.
- If the user rejects or corrects a previous result, reopen `requirements`; previous G1 status is invalid until the correction is recorded and clarified.
- Existing task specs, prior G1 records, or dirty worktree changes are not user clarification. Reconcile the latest user request before continuing.
- Enforce the product edit barrier: product source, tests, migrations, build scripts, deployment files, and application configuration must not change until latest-request requirements are reconciled, Requirements Readiness Check is complete, and G1 is passed.
- G1 cannot pass until ambiguity that could materially change implementation or acceptance is answered by the user or explicitly deferred by a named Human.
- Enter a Human Gate before implementing or accepting `S2` work when required approvals are missing.
- Enter `blocked` when verification is not `verified` and no named Human has accepted the gap.
- Never write `accepted_by: supervisor`, `accepted_by: developer`, `accepted_by: tester`, `accepted_by: reviewer`, `accepted_by: harness`, or equivalent final acceptance.
- Run `fix` at most three times per task. Escalate after the third failed loop.

## Lightweight Path

For `S0` tasks, Supervisor may skip `requirements`, `design`, `planning`, `test`, or `review` only when all of these are true:

- the task is tiny, local, reversible, and low risk;
- acceptance criteria are obvious from the brief;
- no architecture, security, data, CI, production, or permission behavior changes;
- skipped states are recorded in `00-brief.md` or `05-implementation.md`;
- final acceptance still requires named Human acceptance, or the task remains not accepted.

## Design Requirement

Require `design` when any condition is true:

- durable architecture changes;
- public API or contract changes;
- security, permissions, secrets, identity, or data access changes;
- database schema or migration changes;
- CI/CD, deployment, release, or production behavior changes;
- cross-module or high-blast-radius refactoring;
- unclear technical approach with material tradeoffs.

## Blocked State

Record:

- current state;
- blocker type;
- evidence;
- attempted resolution;
- required human decision or external condition;
- recommendation: continue, split, defer, stop, or reclassify.

Do not continue by inventing missing requirements or approvals.
Do not continue by inventing product intent when the user request is ambiguous.
Do not treat code exploration or a plausible implementation path as clarification of user intent.
Do not modify product code during clarification analysis.
Do not record repository evidence, code inspection, Supervisor, Harness, or any Worker Agent as the decision owner for required clarification.

## Product Edit Barrier

Before any product file write, verify:

- the latest user request is recorded and reconciled with existing specs;
- Requirements Readiness Check is complete;
- no blocking questions remain;
- G1 is `passed` for the latest request;
- any same-turn scope change or user correction has been captured as a Human decision.
- any required clarification names a Human decision owner, not repository evidence, code inspection, Supervisor, Harness, or a Worker Agent.

If any item is missing, only read-only analysis and updates to `specs/{task_id}/` or requirement documents are allowed.

For `S1` and `S2`, also verify that
`specs/{task_id}/runs/{run_id}/pre-implementation-status.md` exists before the
first product edit and records:

- current tracked and untracked worktree status;
- authorized target files and artifact files;
- G1, G2 when required, and G3 status;
- whether blocking questions remain;
- `implementation_authorized: true`;
- `post_hoc_backfill: false`.

If product files were changed before this baseline was captured, record
`post_hoc_backfill: true`, keep affected gates blocked, and require a named
Human Gate decision before review or acceptance can pass.
