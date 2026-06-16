# Task Classes

Task class controls workflow strength. Choose the smallest class that covers risk, evidence needs, and blast radius.

## Classification Algorithm

1. If the request is urgent production recovery or a critical active failure, classify as `incident`.
2. If the request asks for research, evaluation, comparison, feasibility, or recommendation without implementation, classify as `research-spike`.
3. If any high-risk trigger applies, classify as `S2`.
4. If the task is tiny, local, reversible, and low risk, classify as `S0`.
5. Otherwise classify as `S1`.

## High-Risk Triggers

Classify as `S2` when work touches:

- architecture or durable technical direction;
- security, identity, permissions, secrets, privacy, or data access;
- database schema, migration, or data correction;
- CI/CD, deployment, release, infrastructure, or production settings;
- public API, compatibility contract, or integration boundary;
- broad refactor, cross-module change, or uncertain blast radius;
- destructive operation or irreversible state change;
- ambiguous acceptance criteria with material business impact.

## Class Matrix

| Class | Use When | Required Agents | Required Artifacts | Human Gate |
|---|---|---|---|---|
| `S0` | text edits, comments, low-risk config, tiny reversible changes | Developer; Reviewer optional | brief, implementation notes, verification evidence or not-verified reason, acceptance | final acceptance |
| `S1` | normal feature, bugfix, local refactor, ordinary code review | Planner, Developer, Tester, Reviewer | requirements, tasks, implementation, test report, review report, acceptance | requirements and final acceptance |
| `S2` | architecture, security, permissions, CI, migration, cross-module changes | Planner, Architect, Developer, Tester, Reviewer | requirements, design or ADR, tasks, implementation, test report, review report, acceptance | requirement approval, architecture or risk approval before implementation, permission approval when needed, final acceptance |
| `research-spike` | technical selection, unknown feasibility, comparative research | Researcher; Architect optional | research report, options comparison, recommendation, open questions | decision review |
| `incident` | urgent production or critical failure fix | Supervisor, Developer, Tester and Reviewer as needed | triage, minimal patch, smoke test, emergency approval, post-incident backfill | emergency approval, post-incident acceptance |

## Escalation

Escalate task class upward when new evidence expands risk or scope. Record the reason in the current artifact and add any newly required artifacts before continuing.

Do not downgrade a task after high-risk evidence appears unless a Human Gate explicitly accepts the reduced workflow and residual risk.

Do not start implementation for `S2` until required requirement and architecture or risk Human Gates are recorded. If the user has not approved the gate, enter `blocked` with the decision needed.
