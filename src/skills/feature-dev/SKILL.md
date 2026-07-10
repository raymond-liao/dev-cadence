---
name: feature-dev
description: Use when a user asks to add a capability or intentionally change expected user-visible or system-visible behavior in a target project.
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
.dev-cadence.yaml
```

Use `output_language` from that file for all workflow documents and records, including Superpowers spec documents, Superpowers plan documents, Dev Cadence records, and user-facing stage summaries.

Supported values:

- `en`: write documents and records in English.
- `zh-CN`: write documents and records in Simplified Chinese.

Use `worktree.enabled` to set the worktree preference before invoking the vendored `using-git-worktrees` skill:

- `true`: create or verify an isolated worktree without asking.
- `false`: work in the current checkout unless the user explicitly asks for a worktree.

Use `worktree.directory` as the preferred project-local worktree directory when `worktree.enabled` is `true`.

If the config file is missing or the value is unsupported, use `en`.
If `worktree.enabled` is missing or unsupported, use `false`.
If `worktree.directory` is missing, use `.worktrees`.
Do not read user configuration from `.dev-cadence/`; that directory is a replaceable installed package.

## Git Checkpoints

Dev Cadence uses commits as workflow checkpoints after the user has confirmed a stage output.

Before creating any Dev Cadence workflow commit:

1. Confirm the current stage output has already been approved by the user.
2. Ensure the work is on a dedicated branch for this feature or task.
3. If the current branch is not dedicated to this task, create or switch to a dedicated branch automatically and report the branch name.
4. Include only files related to the confirmed stage output.
5. Report the commit hash after committing.

After the user confirms a stage output, create a checkpoint commit unless the user explicitly asks not to or unrelated uncommitted changes make the commit unsafe.

Do not commit before the user confirms the current stage output.
Do not push unless the user explicitly asks.
If the current branch has unrelated uncommitted changes, stop and ask before switching branches or committing.
Final merge, PR creation, branch cleanup, or discarding the branch belongs to Completion and requires the user's decision through the vendored finishing flow.

### User-Requested Commits During Active Runs

Until Business Acceptance and Completion are finished, treat user requests to commit, submit, save, or checkpoint current changes as workflow control requests, not ordinary git commit requests.

Do not create an ordinary git commit for unfinished feature work, even if the user says "commit changes" or a localized equivalent. Only create checkpoint commits for confirmed stage outputs under the Git Checkpoints rules above.

If the user asks to commit while the current stage output is not confirmed, explain that the workflow cannot create a checkpoint yet, then continue the current stage by updating the relevant record, running required verification, or asking for the required confirmation.

If implementation changes exist but System Testing or Business Acceptance is not complete, continue the workflow through implementation records, code review evidence, system testing, and business acceptance instead of committing the work as a regular development commit.

### Commit Red Flags

| Thought | Reality |
| --- | --- |
| "User asked to commit, so ordinary git commit is allowed." | Active feature runs allow checkpoint commits only for confirmed stage outputs. |
| "Implementation is mostly done, commit now and test later." | Continue through implementation records, code review, System Testing, and Business Acceptance first. |
| "This is just saving progress." | Save progress in stage records and the manifest, not an ordinary development commit. |

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
brainstorming -> using-git-worktrees -> writing-plans -> test-driven-development / subagent-driven-development / executing-plans -> requesting-code-review -> verification-before-completion
```

Map it to Dev Cadence like this:

| Dev Cadence stage | Superpowers work | Business output |
| --- | --- | --- |
| Requirements Confirmation | `brainstorming` requirement clarification | Confirmed requirements |
| Technical Solution | `brainstorming` design/spec work | Technical solution |
| Implementation Plan | `using-git-worktrees` and `writing-plans` | isolated workspace readiness, TDD implementation plan |
| Development Implementation | `test-driven-development`, `subagent-driven-development`, `executing-plans`, and `requesting-code-review` | Working deliverable, test assets, implementation notes, code review evidence |
| System Testing | `verification-before-completion` | System test report |
| Business Acceptance | Dev Cadence user decision gate | Business acceptance record |

The mapping is semantic, not one-skill-per-stage. If a Superpowers skill naturally spans more than one Dev Cadence stage, keep the Superpowers flow intact and make the Dev Cadence stage boundary explicit in the user-facing update.

## Stage Records

The active AI agent is responsible for writing or updating the record for the stage it is executing. Do not rely on the conversation transcript as the only record.

Use one task directory for every workflow record and short-lived execution artifact:

```text
build/dev-cadence/feature-dev/<feature-slug>/
```

Stage records:

```text
build/dev-cadence/feature-dev/<feature-slug>/01-requirements.md
build/dev-cadence/feature-dev/<feature-slug>/02-technical-solution.md
build/dev-cadence/feature-dev/<feature-slug>/03-implementation-plan.md
build/dev-cadence/feature-dev/<feature-slug>/04-implementation-record.md
build/dev-cadence/feature-dev/<feature-slug>/04-code-review-report.md
build/dev-cadence/feature-dev/<feature-slug>/05-system-test-report.md
build/dev-cadence/feature-dev/<feature-slug>/06-business-acceptance-record.md
```

Subagent-driven development artifacts, when used, must be written under:

```text
build/dev-cadence/feature-dev/<feature-slug>/sdd/
```

Visual companion artifacts, when used during Requirements Confirmation or Technical Solution, must stay under the same task directory by starting or restarting the vendored visual companion with the task directory as `--project-dir`:

```bash
.dev-cadence/vendor/superpowers/skills/brainstorming/scripts/start-server.sh \
  --project-dir build/dev-cadence/feature-dev/<feature-slug> \
  --open
```

This preserves the vendored Superpowers visual companion layout while keeping its files inside the Dev Cadence task directory:

```text
build/dev-cadence/feature-dev/<feature-slug>/.superpowers/brainstorm/
```

Do not edit or fork the vendored visual companion scripts to change this path.

Create and maintain a run manifest for every workflow run:

```text
build/dev-cadence/feature-dev/<feature-slug>/manifest.md
```

The manifest is the run index. It does not replace the stage records.

The manifest must include:

- workflow, task slug, repository, branch, started at, current stage, and overall status;
- a stage table with stage name, status, artifact path, user confirmation, checkpoint commit, and notes;
- verification summary and residual risks once available;
- business acceptance decision once available;
- final integration decision after Completion.

Repository and path fields must be portable:

- identify the repository by repository name and, when available, `git remote get-url origin`;
- record branches and commit hashes as the durable source of code identity;
- write artifact paths, workspace paths, and run directory paths relative to the target repository root;
- if working in the main checkout, record the workspace as `.` or `target repository root`;
- if working in a project-local worktree, record it as `.worktrees/<branch-or-task-slug>` or `worktrees/<branch-or-task-slug>` instead of the machine's absolute path;
- do not persist local absolute paths such as `/Users/...`, `/home/...`, or drive-letter paths in manifests or stage records unless the user explicitly asks for machine-local debugging evidence.

Use stage status values: `pending`, `in_progress`, `confirmed`, `blocked`, or `skipped`.
Use overall status values: `in_progress`, `accepted`, `rejected`, `accepted_with_risk`, `integrated`, or `abandoned`.

When the overall status is `accepted`, `rejected`, `accepted_with_risk`, `integrated`, or `abandoned`, the manifest must not contain `pending` checkpoint commit values. For each stage, record the actual checkpoint commit hash, `skipped`, or `skipped: <reason>`.

Update the manifest:

- when the workflow starts;
- whenever a stage record is created or updated;
- after each checkpoint commit, adding the commit hash;
- before entering Business Acceptance;
- after the finishing flow records merge, PR, keep-branch, or discard decisions.

If run records under `build/dev-cadence/` are ignored by the target repository, keep the manifest updated on disk and do not force-add ignored files unless the user or project policy requires it.

Before moving to the next stage, ensure the current stage record exists and reflects the user's latest confirmed decision or the latest verification evidence.
Also ensure the manifest points to the latest stage record and checkpoint commit before moving to the next stage.

## Active Task Change Handling

Until Business Acceptance and Completion are finished, treat user requests about the same feature as changes to the current workflow run.

When the user asks for a requirement adjustment, scope clarification, implementation change, test change, review fix, or acceptance feedback that belongs to the current feature:

- update the existing task directory under `build/dev-cadence/feature-dev/<feature-slug>/`;
- update the existing stage records and manifest instead of creating a new feature slug, workflow run, requirements document, or technical solution document;
- if the change affects an already confirmed stage, return to the earliest affected stage, mark affected later stages as `pending` or `in_progress` in the manifest, and refresh their records before moving forward again;
- if implementation has already started, update `03-implementation-plan.md` when the plan no longer matches the requested change before continuing implementation;
- preserve prior decisions and evidence in the relevant record when they still explain the task history, but make the latest confirmed scope, plan, and verification state explicit.

If the requested change clearly exceeds the current confirmed scope, ask whether the user wants to expand the current feature or start a separate task before creating any new workflow run or document.

### Active Task Red Flags

| Thought | Reality |
| --- | --- |
| "The user added details, so start a new requirements document." | Same-feature changes update the current workflow run and existing records. |
| "The confirmed plan is old, but keep implementing anyway." | Return to the earliest affected stage and refresh records before moving forward. |
| "This sounds bigger, so silently start a new task." | Ask whether to expand the current feature or start a separate task. |

## Stage Rules

### Enhanced Exploration Mode

Use enhanced exploration mode for features that touch multiple files or modules, require architectural decisions, integrate with existing workflows, have unclear requirements, or introduce meaningful user-visible behavior. Do not force enhanced exploration mode for trivial, well-scoped changes.

When enhanced exploration mode applies:

- explore 2-3 independent perspectives before finalizing the Technical Solution, such as similar existing features, relevant architecture and data flow, UI or API patterns, testing strategy, integration boundaries, accessibility, security, or operational constraints;
- each exploration perspective must identify key files with line references, established patterns, constraints, risks, and 5-10 essential files the main agent must read;
- the main agent must read the essential files before writing the Technical Solution;
- record the exploration summary in `02-technical-solution.md` under `Codebase Exploration Findings`;
- present multiple architecture alternatives in `02-technical-solution.md`, including minimal-change, clean-architecture, and pragmatic-balance options when those options are meaningfully different;
- recommend one option with concrete rationale and ask the user to confirm the Technical Solution before writing the implementation plan.

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

If enhanced exploration mode might apply but the trigger is unclear, state the assumption and either enter enhanced exploration mode or explain why the request is trivial enough to skip it.

At the end of this stage, write or update:

```text
build/dev-cadence/feature-dev/<feature-slug>/01-requirements.md
```

Ask the user to confirm this stage. Do not start implementation planning or code.

### Technical Solution

Continue with:

```text
.dev-cadence/vendor/superpowers/skills/brainstorming/SKILL.md
```

Use its design/spec guidance. Before moving on, explicitly present:

- recommended approach;
- alternatives or tradeoffs when relevant, and for enhanced exploration mode include minimal-change, clean-architecture, and pragmatic-balance alternatives unless two or more are effectively identical;
- affected modules and boundaries;
- high-level testing strategy;
- risks or constraints.

At the end of this stage, write or update:

```text
build/dev-cadence/feature-dev/<feature-slug>/02-technical-solution.md
```

The Technical Solution record must link to `01-requirements.md` as the confirmed requirement source. This active workflow path overrides any generic feature-spec default in the vendored brainstorming skill.

Ask the user to confirm this stage. Do not write the TDD implementation plan or code yet.

### Implementation Plan

Use:

```text
.dev-cadence/vendor/superpowers/skills/using-git-worktrees/SKILL.md
.dev-cadence/vendor/superpowers/skills/writing-plans/SKILL.md
```

Before writing the plan, apply the configured `worktree.enabled` and `worktree.directory`, then use `using-git-worktrees` to create or verify the isolated feature workspace according to the vendored Superpowers rules. When `worktree.enabled` is `true`, treat it as a predeclared user preference to create an isolated worktree and do not ask for worktree consent. When `worktree.enabled` is `false`, skip worktree creation unless the user explicitly asks for it.

The plan is only for the next stage, Development Implementation. It must follow the Superpowers plan requirements: concrete files, concrete steps, test-first cycles, commands, expected results, and self-review.

The plan must include:

- tasks that implement only the confirmed requirement and technical solution;
- tests or checks for each acceptance criterion;
- development-stage verification needed to prove the working deliverable;
- completion conditions for Development Implementation.

Before detailed task steps, the plan must include a `Task Overview` section that lets the user quickly scan the planned tasks without reading every step.

Use this structure before the first detailed task:

```text
## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: <task name> | <one-sentence outcome> | `<primary files>` | `<main checks>` |

## Detailed Tasks
```

Each detailed task must have a matching row in `Task Overview`. Keep overview rows concise; detailed step-by-step execution stays under `Detailed Tasks`.

At the end of this stage, write or update:

```text
build/dev-cadence/feature-dev/<feature-slug>/03-implementation-plan.md
```

Ask the user to confirm the plan before implementation starts.

### Development Implementation

Use:

```text
.dev-cadence/vendor/superpowers/skills/test-driven-development/SKILL.md
.dev-cadence/vendor/superpowers/skills/subagent-driven-development/SKILL.md
.dev-cadence/vendor/superpowers/skills/executing-plans/SKILL.md
.dev-cadence/vendor/superpowers/skills/requesting-code-review/SKILL.md
```

Follow the confirmed plan. Development-stage verification belongs here: failing tests first, minimal implementation, passing focused tests, refactor after green, and implementation notes.

Use `subagent-driven-development` when the plan has independent tasks and the platform supports subagents. Use `executing-plans` when subagent-driven development is not available or not appropriate.

Follow the Superpowers code review requirements during Development Implementation: review after each subagent-driven task, review after major feature completion, and review before merge. Fix Critical and Important findings before moving to System Testing, unless the user explicitly accepts the risk.

Before using `subagent-driven-development`, set:

```text
DEV_CADENCE_TASK_DIR=build/dev-cadence/feature-dev/<feature-slug>
```

All SDD task briefs, implementer reports, review packages, and progress ledgers must stay under that task directory.

If debugging is needed, use:

```text
.dev-cadence/vendor/superpowers/skills/systematic-debugging/SKILL.md
```

At the end of this stage, write or update:

```text
build/dev-cadence/feature-dev/<feature-slug>/04-implementation-record.md
```

The implementation record must include:

- implementation commit hash or changed files;
- completed plan tasks;
- tests and checks run during development;
- code review report path, summary, and unresolved review findings, if any;
- skipped checks with reasons;
- implementation notes and known residual risks.

Completed plan task evidence must be kept in sync with the plan. Mark completed implementation-plan steps as `- [x]`. If the plan file cannot be updated, record the completed step numbers and the reason the checklist could not be updated in the implementation record.

Code review evidence must be traceable and high signal. Write the detailed review report to:

```text
build/dev-cadence/feature-dev/<feature-slug>/04-code-review-report.md
```

The implementation record must link to `04-code-review-report.md` and summarize:

- review decision;
- Critical findings count and status;
- Important findings count and status;
- unresolved findings or `None`.

Before review, collect local rule sources from the target repository when they exist:

- root `AGENTS.md`;
- `AGENTS.md` or `CLAUDE.md` files in directories containing changed files or their parents.

Apply only rule sources whose path scope covers the changed files. If no local rule sources exist, record `None found` and continue.

Review must cover these perspectives:

- `rules compliance`: violations of explicit AGENTS/CLAUDE rules that apply to the changed files;
- `correctness / bugs`: functional bugs, missing imports, invalid state handling, error handling gaps, security issues, or other defects introduced by the change;
- `test / acceptance alignment`: whether implementation and tests match the confirmed requirements, technical solution, implementation plan, and acceptance criteria.

Only record high-signal findings. A finding must have file/line evidence or a clearly stated proof, must be introduced by the current change, and must affect functionality, rule compliance, security, maintainability, or acceptance. Do not record pure style preferences, speculative concerns, pre-existing issues, or issues a linter/formatter will catch unless they block delivery.

For each Critical or Important finding, record one validation state: `validated`, `not validated`, `fixed`, or `accepted risk`. Unvalidated findings must not block System Testing, but must remain visible as review notes. Critical and Important validated findings must be fixed or explicitly accepted by the user before moving to System Testing.

Use this `Code Review Evidence` structure in the implementation record:

```text
## Code Review Evidence

- Report: build/dev-cadence/feature-dev/<feature-slug>/04-code-review-report.md
- Review decision:
- Critical findings:
- Important findings:
- Unresolved findings:
```

The code review report must use this checklist structure:

```text
# Code Review Report

## Review Inputs

- [ ] Changed files are listed.
- [ ] Applicable `AGENTS.md` or `CLAUDE.md` rule sources are listed, or `None found` is recorded.
- [ ] Confirmed requirements and technical solution source is linked.
- [ ] Implementation plan source is linked.
- [ ] Reviewed diff or commit range is identified by branch and commit hash when available.

## Review Perspectives

- [ ] Rules compliance reviewed.
- [ ] Correctness / bugs reviewed.
- [ ] Test / acceptance alignment reviewed.
- [ ] Security, accessibility, performance, or operational concerns considered when relevant.

## Findings

- [ ] Critical findings recorded, or `None`.
- [ ] Important findings recorded, or `None`.
- [ ] Each Critical or Important finding has file/line evidence or a clearly stated proof.
- [ ] Each Critical or Important finding has one validation state: `validated`, `not validated`, `fixed`, or `accepted risk`.

## Review Decision

- [ ] Safe to proceed to System Testing, or blocking reason recorded.
- [ ] Fixes applied are listed, or `None`.
- [ ] Unresolved findings are listed, or `None`.
- [ ] Residual review risks are listed, or `None`.
```

For enhanced exploration mode, code review evidence must cover multiple perspectives before moving to System Testing: correctness and bugs; simplicity, duplication, and maintainability; and project conventions, tests, accessibility, security, or performance as relevant to the feature. Record each perspective's conclusion and any Critical or Important findings.

### System Testing

Use:

```text
.dev-cadence/vendor/superpowers/skills/verification-before-completion/SKILL.md
```

Verify the working deliverable against the confirmed requirement, technical solution, implementation plan, and actual changes. Record passed checks, failures, skipped checks, residual risk, and whether the work can enter business acceptance.

Do not claim the system is ready without fresh verification evidence.

At the end of this stage, write or update:

```text
build/dev-cadence/feature-dev/<feature-slug>/05-system-test-report.md
```

The system test report must use this structure:

- `Requirement, Technical Solution, And Implementation Sources`: requirements source, technical solution source, plan source, and implementation source.
- `Test Environment`: repository, branch, date, runtime, servers, tools, and relevant configuration.
- `Test Cases`: a table with columns `ID`, `Scenario`, `Type`, `Execution`, `Result`, and `Evidence`. List every automated, manual, smoke, build, source-inspection, and skipped test case that matters to the confirmed requirement.
- `Requirement Coverage`: map each acceptance criterion or important requirement to test case IDs and an explicit status: `covered`, `skipped`, `not covered`, or `accepted risk`.
- `Failed Or Skipped Checks`: failures and skipped checks with reasons. If none, write `None`.
- `Residual Risks`: remaining risks after testing. If none, write `None`.
- `Recommendation`: whether the work can enter Business Acceptance.

Coverage must be honest. If a confirmed acceptance criterion is not verified by an executed test or check, list it as `skipped`, `not covered`, or `accepted risk` in `Requirement Coverage`; do not only mention it in `Residual Risks`.

### Business Acceptance

Superpowers does not provide a dedicated business acceptance skill. Use this Dev Cadence gate:

- summarize the confirmed requirement;
- summarize the technical solution and implementation result;
- summarize system test evidence and residual risks;
- ask the user to choose a business acceptance decision from fixed numbered options:
  1. Accept
  2. Reject
  3. Accept with residual risk
- get the business acceptor identity from the target repository's `git config user.name` and `git config user.email`; ask the user only if git identity is unavailable;
- map the user's selected number or exact option text to the normalized decision, then record the decision, decision maker, exact decision time with timezone, and accepted residual risks.

Do not substitute system test success for user acceptance.
Do not infer acceptance from ambiguous positive feedback such as "looks good", "seems fine", "looks okay", localized equivalents, or similar wording.
Only treat the response as a business acceptance decision when the user selects one of the numbered options or repeats the exact option text.
If the user's response does not clearly select one fixed option, ask the user to choose again and do not write the business acceptance record yet.

### Ambiguous Acceptance Feedback

| User says | Reality |
| --- | --- |
| "looks good" | Not an acceptance decision. Ask for one fixed option. |
| "seems fine" or "looks okay" | Not an acceptance decision. Ask for one fixed option. |
| Localized positive feedback | Not an acceptance decision. Ask for one fixed option. |
| "ship it" | Ambiguous unless it selects or repeats one fixed option. |

After the user gives the acceptance decision, write or update:

```text
build/dev-cadence/feature-dev/<feature-slug>/06-business-acceptance-record.md
```

The business acceptance record must use this structure:

- `Accepted Requirement And Solution Sources`: confirmed requirements, technical solution, and plan sources.
- `System Test Report Source`: system test report source.
- `User Decision`: normalized decision selected from the fixed options: accepted, rejected, or accepted with residual risk.
- `Decision By`: target repository git identity that made the business acceptance decision, formatted as `user.name <user.email>` when both values are available.
- `Decision At`: exact decision timestamp with timezone, preferably ISO 8601 with offset.
- `Accepted Result`: brief business summary of what was accepted.
- `Accepted Residual Risks`: residual risks accepted by the user, if any.
- `Final Follow-Up Actions`: final follow-up actions, if any.

After Completion, update `Final Follow-Up Actions` with the actual final result. Record whether the branch was merged, a PR was created, the branch was kept, or the work was discarded; also record whether any worktree was removed and whether the task branch was deleted or preserved. Do not leave final follow-up actions as future-tense TODOs when the manifest is in a terminal status.

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

After the finishing flow completes, update the manifest and business acceptance record with the final integration result. The manifest must include the merge, PR, keep-branch, or discard decision; worktree cleanup result; branch deletion or preservation result; final overall status; and non-`pending` checkpoint values for terminal stages.

Before marking the run terminal, complete this readiness checklist:

- [ ] Manifest has a terminal overall status and no `pending` checkpoint commit values.
- [ ] Business acceptance record has `Final Follow-Up Actions` updated with actual past-tense results.
- [ ] Implementation record has the final implementation commit hash or final changed-files state.
- [ ] Implementation record links to `04-code-review-report.md`.
- [ ] Code review report exists and all checklist items are checked or have an explicit reason.
- [ ] System test report records skipped checks and residual risks honestly.
- [ ] No stage record contains stale future-tense or pre-commit status that conflicts with the manifest.
- [ ] Artifact paths are repository-relative; no local absolute paths are persisted unless explicitly requested by the user.

If any checklist item is not satisfied, update the affected record before reporting Completion.

Then follow the vendored finishing skill.
