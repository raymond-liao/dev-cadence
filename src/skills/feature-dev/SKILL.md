---
name: feature-dev
description: Use when a user asks to add or change user-visible or system-visible feature behavior in a target project.
---

# Feature Dev

Use this skill to run the Dev Cadence feature development workflow.

Dev Cadence is a business-facing workflow wrapper around vendored Superpowers skills. It does not replace the Superpowers process. It makes each business stage visible to the user, fixes confirmation gates, and keeps the target repository on the vendored skill version.

Use only vendored Superpowers skills from:

```text
.dev-cadence/vendor/superpowers/skills/
```

Do not substitute globally installed Superpowers skills unless the user explicitly asks to do so.

Keep task artifacts in the target repository's normal project space. Do not write task artifacts, plans, reports, or acceptance records inside `.dev-cadence/`; that directory is the installed rules package.

## Git Checkpoints

Dev Cadence allows commits as workflow checkpoints after the user has confirmed a stage output.

Before creating any Dev Cadence workflow commit:

1. Confirm the current stage output has already been approved by the user.
2. Confirm the work is on a dedicated branch for this feature or task.
3. If the current branch is not dedicated to this task, propose a branch name and ask the user before creating or switching branches.
4. Include only files related to the confirmed stage output.
5. Report the commit hash after committing.

Do not commit before the user confirms the current stage output.
Do not push unless the user explicitly asks.

## Dev Cadence Stages

Present the work to the user using these business stages:

```text
Requirements Confirmation -> Technical Solution -> Implementation Plan -> Development Implementation -> System Testing -> Business Acceptance
```

Do not start implementation before the user has confirmed:

- Requirements Confirmation
- Technical Solution
- Implementation Plan

## Superpowers Mapping

Use the vendored Superpowers workflow as the execution method:

```text
brainstorming -> writing-plans -> test-driven-development / executing-plans -> verification-before-completion
```

Map it to Dev Cadence like this:

| Dev Cadence stage | Superpowers work | Business output |
| --- | --- | --- |
| Requirements Confirmation | `brainstorming` requirement clarification | Confirmed requirements |
| Technical Solution | `brainstorming` design/spec work | Technical solution |
| Implementation Plan | `writing-plans` implementation plan | TDD implementation plan |
| Development Implementation | `test-driven-development` and `executing-plans` | Working deliverable, test assets, implementation notes |
| System Testing | `verification-before-completion` | System test report |
| Business Acceptance | Dev Cadence user decision gate | Business acceptance record |

The mapping is semantic, not one-skill-per-stage. If a Superpowers skill naturally spans more than one Dev Cadence stage, keep the Superpowers flow intact and make the Dev Cadence stage boundary explicit in the user-facing update.

## Stage Rules

### Requirements Confirmation

Use:

```text
.dev-cadence/vendor/superpowers/skills/brainstorming/SKILL.md
```

Clarify the user-visible or system-visible requirement. Before moving on, explicitly present:

- confirmed scope;
- non-goals;
- acceptance criteria;
- open questions or assumptions.

Ask the user to confirm this stage. Do not start implementation planning or code.

### Technical Solution

Continue with:

```text
.dev-cadence/vendor/superpowers/skills/brainstorming/SKILL.md
```

Use its design/spec guidance. Before moving on, explicitly present:

- recommended approach;
- alternatives or tradeoffs when relevant;
- affected modules and boundaries;
- high-level testing strategy;
- risks or constraints.

The Superpowers design/spec document is the persisted artifact for Requirements Confirmation and Technical Solution.

Ask the user to confirm this stage. Do not write the TDD implementation plan or code yet.

### Implementation Plan

Use:

```text
.dev-cadence/vendor/superpowers/skills/writing-plans/SKILL.md
```

The plan is only for the next stage, Development Implementation. It must follow the Superpowers plan requirements: concrete files, concrete steps, test-first cycles, commands, expected results, and self-review.

Ask the user to confirm the plan before implementation starts.

### Development Implementation

Use:

```text
.dev-cadence/vendor/superpowers/skills/test-driven-development/SKILL.md
.dev-cadence/vendor/superpowers/skills/executing-plans/SKILL.md
```

Follow the confirmed plan. Development-stage verification belongs here: failing tests first, minimal implementation, passing focused tests, refactor after green, and implementation notes.

If debugging is needed, use:

```text
.dev-cadence/vendor/superpowers/skills/systematic-debugging/SKILL.md
```

### System Testing

Use:

```text
.dev-cadence/vendor/superpowers/skills/verification-before-completion/SKILL.md
```

Verify the working deliverable against the confirmed requirement, technical solution, implementation plan, and actual changes. Record passed checks, failures, skipped checks, residual risk, and whether the work can enter business acceptance.

Do not claim the system is ready without fresh verification evidence.

### Business Acceptance

Superpowers does not provide a dedicated business acceptance skill. Use this Dev Cadence gate:

- summarize the confirmed requirement;
- summarize the technical solution and implementation result;
- summarize system test evidence and residual risks;
- ask the user for a named decision: accept, reject, or accept with residual risk;
- record the decision and accepted residual risks.

Do not substitute system test success for user acceptance.
