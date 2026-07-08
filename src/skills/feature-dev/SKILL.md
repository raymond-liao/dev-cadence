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

## Configuration

Before producing user-facing workflow documents or records, read:

```text
.dev-cadence/config.md
```

Use `output_language` from that file for all workflow documents and records, including Superpowers spec documents, Superpowers plan documents, Dev Cadence records, and user-facing stage summaries.

Supported values:

- `en`: write documents and records in English.
- `zh-CN`: write documents and records in Simplified Chinese.

If the config file is missing or the value is unsupported, use `en`.

## Git Checkpoints

Dev Cadence allows commits as workflow checkpoints after the user has confirmed a stage output.

Before creating any Dev Cadence workflow commit:

1. Confirm the current stage output has already been approved by the user.
2. Confirm the work is on a dedicated branch for this feature or task.
3. If the current branch is not dedicated to this task, create or switch to a dedicated branch automatically and report the branch name.
4. Include only files related to the confirmed stage output.
5. Report the commit hash after committing.

Do not commit before the user confirms the current stage output.
Do not push unless the user explicitly asks.
If the current branch has unrelated uncommitted changes, stop and ask before switching branches or committing.

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

## Stage Records

The active AI agent is responsible for writing or updating the record for the stage it is executing. Do not rely on the conversation transcript as the only record.

Use the Superpowers spec and plan documents as the records for the first three stages:

- Requirements Confirmation and Technical Solution: `docs/superpowers/specs/<date>-<feature>-design.md`
- Implementation Plan: `docs/superpowers/plans/<date>-<feature>.md`

Create Dev Cadence records for the remaining stages:

```text
build/dev-cadence/feature-dev/<feature-slug>/implementation-record.md
build/dev-cadence/feature-dev/<feature-slug>/system-test-report.md
build/dev-cadence/feature-dev/<feature-slug>/business-acceptance-record.md
```

Before moving to the next stage, ensure the current stage record exists and reflects the user's latest confirmed decision or the latest verification evidence.

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

At the end of this stage, write or update:

```text
build/dev-cadence/feature-dev/<feature-slug>/implementation-record.md
```

The implementation record must include:

- implementation commit hash or changed files;
- completed plan tasks;
- tests and checks run during development;
- skipped checks with reasons;
- implementation notes and known residual risks.

### System Testing

Use:

```text
.dev-cadence/vendor/superpowers/skills/verification-before-completion/SKILL.md
```

Verify the working deliverable against the confirmed requirement, technical solution, implementation plan, and actual changes. Record passed checks, failures, skipped checks, residual risk, and whether the work can enter business acceptance.

Do not claim the system is ready without fresh verification evidence.

At the end of this stage, write or update:

```text
build/dev-cadence/feature-dev/<feature-slug>/system-test-report.md
```

The system test report must include:

- requirement/spec source;
- implementation source;
- test environment;
- commands and checks executed;
- manual checks executed;
- pass/fail/skipped results;
- residual risks;
- recommendation on whether the work can enter Business Acceptance.

### Business Acceptance

Superpowers does not provide a dedicated business acceptance skill. Use this Dev Cadence gate:

- summarize the confirmed requirement;
- summarize the technical solution and implementation result;
- summarize system test evidence and residual risks;
- ask the user for a named decision: accept, reject, or accept with residual risk;
- record the decision and accepted residual risks.

Do not substitute system test success for user acceptance.

After the user gives the acceptance decision, write or update:

```text
build/dev-cadence/feature-dev/<feature-slug>/business-acceptance-record.md
```

The business acceptance record must use this structure:

- `Accepted Requirement Source`: confirmed spec and plan sources.
- `System Test Report Source`: system test report source.
- `User Decision`: accepted, rejected, or accepted with residual risk; include the user's acceptance statement and acceptance date.
- `Accepted Result`: brief business summary of what was accepted.
- `Accepted Residual Risks`: residual risks accepted by the user, if any.
- `Final Follow-Up Actions`: final follow-up actions, if any.

## Completion

After Business Acceptance is accepted, invoke:

```text
.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md
```

Pass this Dev Cadence context into the finishing flow:

- Business Acceptance has already been accepted.
- The business acceptance record has been written or updated.
- Ignored Dev Cadence run records under `build/dev-cadence/` may remain on disk after merge.
- Do not push unless the user explicitly asks.

Then follow the vendored finishing skill.
