# Delivery Disciplines

Use this reference as the routing entrypoint for Dev Cadence's built-in delivery discipline.

`default` discipline fields mean the rules in these Dev Cadence references. The default behavior does not depend on any external skill.

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

Workspace, branch, worktree, commit, merge, and PR lifecycle management are outside the default discipline for now. Preserve existing repository policy and user instructions. Continue to record Harness evidence and scope reconciliation even when no Git checkpoint is created.

## State Loading Contract

Load these references by state or condition:

| State or condition | Required references |
|---|---|
| `intake`, `requirements`, design-sensitive clarification | `intent-and-design-discipline.md` |
| visual clarification would materially improve alignment | `visual-companion.md` |
| `planning` | `planning-discipline.md` |
| `implementation` for testable behavior | `implementation-discipline.md`; load `testing-anti-patterns.md` when writing tests or mocks |
| Worker dispatch, inline execution, subagent execution, parallel candidates | `execution-orchestration.md` |
| `bugfix`, `incident-fix`, unexpected behavior, failing tests | `debugging-discipline.md` |
| Deep symptom, unclear origin, bad value propagation | `root-cause-tracing.md` |
| Flaky async tests or arbitrary sleeps | `condition-based-waiting.md` |
| Invalid data, unsafe state, boundary failures | `defense-in-depth.md` |
| `review`, checkpoint review, final implementation review | `review-discipline.md` |
| before claiming fixed, done, passing, approved, or complete | `verification-discipline.md` |
| Dev Cadence Skill/plugin/reference/template/policy authoring | `authoring-discipline.md`; load `skill-pressure-testing.md` for validation |

Prompt templates live under `templates/prompts/` and should be used when dispatching Worker or reviewer runs through Harness.

## Optional Capabilities

Visual companion tooling is optional. It may help when visual inspection or visual comparison materially improves clarification, such as UI layouts, architecture diagrams, data flow diagrams, or design alternatives.

Do not make visual companion usage a G1 requirement. Requirements pass based on clarified intent and named Human decisions, not on whether a browser session was opened.

Use `visual-companion.md` for server lifecycle, port and host handling, session directory cleanup, event capture, `.gitignore` impact, fallback behavior, and Harness evidence mapping.

## Adapter Boundary

External adapters are optional replacement points for Worker execution techniques. They must not weaken:

- named Human final acceptance;
- Requirements Readiness Check;
- Quality Gate evidence;
- Human Gate approvals;
- Harness evidence;
- scope reconciliation;
- permission policy.

When an adapter is selected, the stricter compatible rule wins inside that Worker state. If the adapter cannot provide required Dev Cadence evidence, record the gap and keep the relevant gate blocked unless a named Human accepts the residual risk.
