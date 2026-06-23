# Principles

Use these principles whenever process rules conflict or a workflow choice is unclear.

## Non-Negotiable Rules

1. Treat artifacts as the source of truth. Chat is only a clue until it is written into an approved artifact.
2. Keep Supervisor, Harness, Worker Agent, Quality Gate, and Human Gate responsibilities separate.
3. Let Supervisor control workflow state, not implementation details.
4. Execute Worker Agent work through the Harness contract.
5. Exchange structured artifacts instead of conversational summaries.
6. Do not let Developer approve final completion.
7. Keep Tester and Reviewer independent.
8. Limit fix loops to three iterations per task before escalation.
9. Require Human Gate approval for high-risk actions.
10. Treat missing evidence as a blocked or incomplete workflow state.
11. Treat incomplete verification as blocked until a named Human accepts the residual risk.
12. Do not let Supervisor, Harness, Developer, Tester, or Reviewer be recorded as final accepter.
13. Prefer repo-local Markdown rules and templates before platform automation.
14. Repository evidence can support candidate interpretations, but it cannot clarify user intent, accept requirements, or pass G1 when clarification is required.

## Delivery Discipline

Use strict engineering discipline inside the delivery framework, not as a replacement for Supervisor, Harness, Quality Gate, or Human Gate responsibilities. The detailed default rules live in `delivery-disciplines.md`.

These values apply to Worker Agent execution:

- **Communication**: make goal, scope, acceptance, and handoff context explicit.
- **Simplicity**: choose the smallest design and workflow that satisfy safety, evidence, and handoff needs.
- **Feedback**: define the verification signal before changing implementation.
- **Test First**: for testable behavior changes, write and verify a failing test before production changes.
- **Courage**: stop or escalate when intent, acceptance, verification, or risk is unclear.
- **Respect**: protect user intent, existing behavior, repository conventions, and the next maintainer.

For testable behavior changes, Developer must default to strict Red-Green-Refactor:

```text
Red -> Green -> Refactor
```

If strict TDD does not fit, record a named Human Gate exception before changing implementation and define substitute feedback such as build, type check, manual inspection, screenshot, log, review, or generated-output validation.

Workspace, branch, worktree, commit, merge, and PR lifecycle management are not part of the default Dev Cadence discipline yet. Preserve existing repository policy and user instructions while still recording Harness evidence.

## Source Priority

Resolve conflicts in this order:

1. Current repository code and reproducible test results.
2. Approved task specs and ADRs.
3. Current task artifacts.
4. Stable project documentation.
5. Issue discussion, chat history, or informal notes.

When sources conflict and the conflict affects scope, architecture, security, permissions, test validity, or acceptance, enter a Human Gate instead of guessing.

Source priority resolves evidence conflicts. It does not let an agent replace a required Human decision with repository evidence, code inspection, or a plausible implementation path.

## Responsibility Boundaries

- **Supervisor**: classify, route, enforce state, record skipped states, escalate blockers.
- **Harness**: inject context, apply tool and permission policy, capture evidence, record execution.
- **Worker Agent**: perform role-specific work and produce required artifacts.
- **Quality Gate**: check whether required evidence satisfies the gate.
- **Human Gate**: approve, review, provide missing information, or accept residual risk.

## Evidence Standard

Every material claim about implementation, verification, review, or acceptance needs evidence:

- command and result;
- file or diff reference;
- test environment;
- skipped check and reason;
- residual risk;
- follow-up recommendation when evidence is incomplete.

Missing required Harness files are missing evidence, even when an execution report summarizes them.

## Completion Standard

Do not mark work complete until required artifacts exist, quality gates have evidence, human gates are resolved or explicitly deferred, and final acceptance is written by or explicitly attributed to a named Human.
