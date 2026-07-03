# Delivery Disciplines

Use this reference as the routing entrypoint for Dev Cadence's built-in delivery discipline.

`default` discipline fields mean the rules in these Dev Cadence references and cadence Skills. The default behavior does not depend on any external skill package.

## Contents

- [Default Rule](#default-rule)
- [State Loading Contract](#state-loading-contract)
- [Optional Capabilities](#optional-capabilities)
- [Adapter Boundary](#adapter-boundary)

## Default Rule

Dev Cadence workflows are mandatory delivery rules, not suggestions. Do not execute a workflow state until its required discipline reference has been read or the skip is recorded with reason and residual risk.

When a rule cannot be followed, record a named Human Gate decision with:

```yaml
rule:
approved_by_human:
reason:
residual_risk:
follow_up:
```

Worker Agents must not treat shortcuts as equivalent evidence. Missing evidence is a blocked workflow state until a named Human accepts the gap.

Workspace, branch, worktree, merge, and PR lifecycle management are outside the
default discipline for now. Git commit readiness is inside the evidence
discipline: before creating a commit, run `scripts/check-before-commit.mjs`
against the commit candidate. The checker is read-only and must not create
specs. The commit candidate is the full dirty worktree, regardless of staging
state.

Dev Cadence gate checks apply only to candidates that contain Dev Cadence
workflow content, or when the user intentionally supplies `--task-id <task_id>`
for product paths that belong to an existing workflow. Candidates outside Dev
Cadence workflow scope skip G1-G6 and Human Gate checks. Dev Cadence
contract/runtime-only candidates validate the embedded runtime and must not be
blocked by unrelated product task Human Gates. Workflow candidates validate the
corresponding `specs/records/{task_id}/` artifacts, G1-G6/Human acceptance, and
coverage for product paths included in the candidate. This check does not
bypass pending G6 for workflow changes; commit is blocked until final Human
acceptance is recorded in `08-acceptance.md`.

Preserve existing repository policy and user instructions. Continue to record
Harness evidence and scope reconciliation even when no Git checkpoint is
created. A request to commit code is not final Human acceptance unless the
Human explicitly says they accept the result and residual risk, and that
decision is recorded in `08-acceptance.md`.

## State Loading Contract

Load these references by state or condition:

| State or condition | Required references |
|---|---|
| `intake`, `requirements`, design-sensitive clarification | `intent-and-design-discipline.md` |
| visual clarification would materially improve alignment | `skills/cadence-clarify/visual-companion.md` |
| `planning` | `planning-discipline.md` |
| `implementation` for testable behavior | `implementation-discipline.md`; use `skills/cadence-tdd/SKILL.md` for full Red-Green-Refactor workflow; load `skills/cadence-tdd/testing-anti-patterns.md` when writing tests or mocks |
| Worker dispatch, inline execution, subagent execution, parallel candidates | `execution-orchestration.md`; load `adapters.md` when an external adapter is configured or requested |
| `bugfix`, `incident-fix`, unexpected behavior, failing tests | `skills/cadence-debug/SKILL.md` |
| Deep symptom, unclear origin, bad value propagation | `skills/cadence-debug/root-cause-tracing.md` |
| Flaky async tests or arbitrary sleeps | `skills/cadence-debug/condition-based-waiting.md` |
| Invalid data, unsafe state, boundary failures | `skills/cadence-debug/defense-in-depth.md` |
| `review`, checkpoint review, final implementation review | `review-discipline.md` |
| before claiming fixed, done, passing, approved, or complete | `verification-discipline.md`; use `skills/cadence-verify/SKILL.md` for the full verification workflow |
| Dev Cadence source maintenance in this repository | source-only `references/source-maintenance/authoring-discipline.md`; load `references/source-maintenance/skill-pressure-testing.md` for validation |

Skill-specific prompts live with the owning Skill, such as `skills/cadence-subagent-development/implementer-prompt.md` for implementer runs and `skills/cadence-request-code-review/code-reviewer.md` for reviewer runs.

## Optional Capabilities

Visual companion tooling is optional. It may help when visual inspection or visual comparison materially improves clarification, such as UI layouts, architecture diagrams, data flow diagrams, or design alternatives.

Do not make visual companion usage a G1 requirement. Requirements pass based on clarified intent and named Human decisions, not on whether a browser session was opened.

Use `skills/cadence-clarify/visual-companion.md` for server lifecycle, port and host handling, session directory cleanup, event capture, `.gitignore` impact, fallback behavior, and Harness evidence mapping.

## Adapter Boundary

External adapters are optional replacement points for Worker execution techniques. Load `adapters.md` before selecting or invoking one. They must not weaken:

- named Human final acceptance;
- Requirements Readiness Check;
- Quality Gate evidence;
- Human Gate approvals;
- Harness evidence;
- scope reconciliation;
- permission policy.

When an adapter is selected, the stricter compatible rule wins inside that Worker state. If the adapter cannot provide required Dev Cadence evidence, record the gap and keep the relevant gate blocked unless a named Human accepts the residual risk.
