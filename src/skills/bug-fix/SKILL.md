---
name: bug-fix
description: Use when a user reports a bug, error, regression, failing test, broken expected behavior, or unexpected behavior in a target project.
---

# Bug Fix

Use this skill to run the Dev Cadence bug fix workflow.

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

Use `output_language` from that file for all workflow documents and records, including Superpowers plan documents, Dev Cadence records, and user-facing stage summaries.

Supported values:

- `en`: write documents and records in English.
- `zh-CN`: write documents and records in Simplified Chinese.

If the config file is missing or the value is unsupported, use `en`.

## Git Checkpoints

Dev Cadence uses commits as workflow checkpoints after the user has confirmed a stage output.

Before creating any Dev Cadence workflow commit:

1. Confirm the current stage output has already been approved by the user.
2. Ensure the work is on a dedicated branch for this bug fix.
3. If the current branch is not dedicated to this bug fix, create or switch to a dedicated branch automatically and report the branch name.
4. Include only files related to the confirmed stage output.
5. Report the commit hash after committing.

After the user confirms a stage output, create a checkpoint commit unless the user explicitly asks not to or unrelated uncommitted changes make the commit unsafe.

Do not commit before the user confirms the current stage output.
Do not push unless the user explicitly asks.
If the current branch has unrelated uncommitted changes, stop and ask before switching branches or committing.
Final merge, PR creation, branch cleanup, or discarding the branch belongs to Completion and requires the user's decision through the vendored finishing flow.

## Dev Cadence Stages

Present the work to the user using these business stages:

```text
Problem Diagnosis -> Repair Solution -> Repair Plan -> Repair Implementation -> Regression Verification -> Business Acceptance
```

Do not start implementation before the user has confirmed:

- Problem Diagnosis
- Repair Solution
- Repair Plan

## Superpowers Mapping

Use the vendored Superpowers workflow as the execution method:

```text
systematic-debugging -> using-git-worktrees -> writing-plans -> test-driven-development / subagent-driven-development / executing-plans -> requesting-code-review -> verification-before-completion
```

Map it to Dev Cadence like this:

| Dev Cadence stage | Superpowers work | Business output |
| --- | --- | --- |
| Problem Diagnosis | `systematic-debugging` root cause investigation | Problem diagnosis record |
| Repair Solution | `systematic-debugging` hypothesis and fix boundary | Repair solution and impact scope |
| Repair Plan | `using-git-worktrees` and `writing-plans` | isolated workspace readiness, TDD repair plan |
| Repair Implementation | `test-driven-development`, `subagent-driven-development`, `executing-plans`, and `requesting-code-review` | Working deliverable, supporting test assets, repair notes, code review evidence |
| Regression Verification | `verification-before-completion` | Regression test report |
| Business Acceptance | Dev Cadence user decision gate | Business acceptance record |

The mapping is semantic, not one-skill-per-stage. If a Superpowers skill naturally spans more than one Dev Cadence stage, keep the Superpowers flow intact and make the Dev Cadence stage boundary explicit in the user-facing update.

## Stage Records

The active AI agent is responsible for writing or updating the record for the stage it is executing. Do not rely on the conversation transcript as the only record.

Use one task directory for every workflow record and short-lived execution artifact:

```text
build/dev-cadence/bug-fix/<bug-slug>/
```

Use these records:

```text
build/dev-cadence/bug-fix/<bug-slug>/problem-diagnosis-record.md
build/dev-cadence/bug-fix/<bug-slug>/repair-solution.md
build/dev-cadence/bug-fix/<bug-slug>/repair-plan.md
build/dev-cadence/bug-fix/<bug-slug>/repair-record.md
build/dev-cadence/bug-fix/<bug-slug>/regression-test-report.md
build/dev-cadence/bug-fix/<bug-slug>/business-acceptance-record.md
```

Subagent-driven development artifacts, when used, must be written under:

```text
build/dev-cadence/bug-fix/<bug-slug>/sdd/
```

Create and maintain a run manifest for every workflow run:

```text
build/dev-cadence/bug-fix/<bug-slug>/manifest.md
```

The manifest is the run index. It does not replace the stage records.

The manifest must include:

- workflow, task slug, repository, branch, started at, current stage, and overall status;
- a stage table with stage name, status, artifact path, user confirmation, checkpoint commit, and notes;
- verification summary and residual risks once available;
- business acceptance decision once available;
- final integration decision after Completion.

Use stage status values: `pending`, `in_progress`, `confirmed`, `blocked`, or `skipped`.
Use overall status values: `in_progress`, `accepted`, `rejected`, `accepted_with_risk`, `integrated`, or `abandoned`.

Update the manifest:

- when the workflow starts;
- whenever a stage record is created or updated;
- after each checkpoint commit, adding the commit hash;
- before entering Business Acceptance;
- after the finishing flow records merge, PR, keep-branch, or discard decisions.

If run records under `build/dev-cadence/` are ignored by the target repository, keep the manifest updated on disk and do not force-add ignored files unless the user or project policy requires it.

Before moving to the next stage, ensure the current stage record exists and reflects the user's latest confirmed decision or the latest verification evidence.
Also ensure the manifest points to the latest stage record and checkpoint commit before moving to the next stage.

## Stage Rules

### Problem Diagnosis

Use:

```text
.dev-cadence/vendor/superpowers/skills/systematic-debugging/SKILL.md
```

Clarify and investigate the reported problem. Before moving on, explicitly present:

- reported symptom;
- expected behavior;
- actual behavior;
- impact scope;
- whether this is confirmed as a bug or still ambiguous;
- reproduction steps or why reproduction is not currently possible;
- root cause hypothesis, evidence, and confidence;
- open questions or assumptions.

Do not propose or implement a fix until the root cause investigation has enough evidence.

At the end of this stage, write or update:

```text
build/dev-cadence/bug-fix/<bug-slug>/problem-diagnosis-record.md
```

Ask the user to confirm this stage. Do not write the repair plan or code yet.

### Repair Solution

Continue with:

```text
.dev-cadence/vendor/superpowers/skills/systematic-debugging/SKILL.md
```

Based on the diagnosis, define the repair approach. Before moving on, explicitly present:

- root cause being fixed;
- repair point and repair boundary;
- files, modules, data, configuration, or workflows likely to change;
- related behavior that may be affected;
- regression scope that must be checked later;
- repair acceptance criteria;
- behavior that must remain unchanged;
- alternatives or tradeoffs when relevant;
- risks and user decisions needed.

At the end of this stage, write or update:

```text
build/dev-cadence/bug-fix/<bug-slug>/repair-solution.md
```

Ask the user to confirm this stage. Do not write the TDD repair plan or code yet.

### Repair Plan

Use:

```text
.dev-cadence/vendor/superpowers/skills/using-git-worktrees/SKILL.md
.dev-cadence/vendor/superpowers/skills/writing-plans/SKILL.md
```

Before writing the plan, use `using-git-worktrees` to create or verify the isolated repair workspace according to the vendored Superpowers rules.

The plan is only for the next stage, Repair Implementation. It must follow the Superpowers plan requirements: concrete files, concrete steps, test-first cycles, commands, expected results, and self-review.

The plan must include:

- a failing test or reproducible check that proves the bug;
- the expected failure evidence before the fix;
- the minimal repair steps;
- supporting unit, integration, frontend, API, script, or manual checks needed for the repaired behavior;
- regression checks derived from the Repair Solution impact scope;
- completion conditions for Repair Implementation.

At the end of this stage, write or update:

```text
build/dev-cadence/bug-fix/<bug-slug>/repair-plan.md
```

Ask the user to confirm the plan before implementation starts.

### Repair Implementation

Use:

```text
.dev-cadence/vendor/superpowers/skills/test-driven-development/SKILL.md
.dev-cadence/vendor/superpowers/skills/subagent-driven-development/SKILL.md
.dev-cadence/vendor/superpowers/skills/executing-plans/SKILL.md
.dev-cadence/vendor/superpowers/skills/requesting-code-review/SKILL.md
```

Follow the confirmed plan. Development-stage verification belongs here: reproduce the bug first, write or run the failing test/check, implement the minimal fix, pass focused tests, refactor only after green, and record repair notes.

Use `subagent-driven-development` when the plan has independent tasks and the platform supports subagents. Use `executing-plans` when subagent-driven development is not available or not appropriate.

Follow the Superpowers code review requirements during Repair Implementation. Fix Critical and Important findings before moving to Regression Verification, unless the user explicitly accepts the risk.

Before using `subagent-driven-development`, set:

```text
DEV_CADENCE_TASK_DIR=build/dev-cadence/bug-fix/<bug-slug>
```

All SDD task briefs, implementer reports, review packages, and progress ledgers must stay under that task directory.

If new debugging is needed, return to:

```text
.dev-cadence/vendor/superpowers/skills/systematic-debugging/SKILL.md
```

At the end of this stage, write or update:

```text
build/dev-cadence/bug-fix/<bug-slug>/repair-record.md
```

The repair record must include:

- implementation commit hash or changed files;
- completed plan tasks;
- original bug reproduction evidence;
- tests and checks run during repair implementation;
- code review evidence and unresolved review findings, if any;
- skipped checks with reasons;
- repair notes and known residual risks.

### Regression Verification

Use:

```text
.dev-cadence/vendor/superpowers/skills/verification-before-completion/SKILL.md
```

Verify the working deliverable against the problem diagnosis, repair solution, repair plan, and actual changes. Confirm the original problem is fixed and that behavior inside the stated impact scope has not regressed.

Do not claim the bug is fixed or regression-free without fresh verification evidence.

At the end of this stage, write or update:

```text
build/dev-cadence/bug-fix/<bug-slug>/regression-test-report.md
```

The regression test report must use this structure:

- `Problem And Repair Sources`: diagnosis source, solution source, plan source, and repair source.
- `Test Environment`: repository, branch, date, runtime, servers, tools, and relevant configuration.
- `Test Cases`: a table with columns `ID`, `Scenario`, `Type`, `Execution`, `Result`, and `Evidence`. List every automated, manual, smoke, build, source-inspection, regression, and skipped test case that matters to the confirmed bug and impact scope.
- `Bug Fix Coverage`: map the original symptom, root cause, and repair acceptance points to the test case IDs that cover them.
- `Impact Scope Coverage`: map each affected area from the Repair Solution to the test case IDs that cover it.
- `Failed Or Skipped Checks`: failures and skipped checks with reasons. If none, write `None`.
- `Residual Risks`: remaining risks after testing. If none, write `None`.
- `Recommendation`: whether the fix can enter Business Acceptance.

### Business Acceptance

Superpowers does not provide a dedicated business acceptance skill. Use this Dev Cadence gate:

- summarize the confirmed problem;
- summarize the root cause and repair result;
- summarize regression evidence and residual risks;
- ask the user for a named decision: accept, reject, or accept with residual risk;
- record the decision and accepted residual risks.

Do not substitute regression verification success for user acceptance.

After the user gives the acceptance decision, write or update:

```text
build/dev-cadence/bug-fix/<bug-slug>/business-acceptance-record.md
```

The business acceptance record must use this structure:

- `Accepted Problem Source`: confirmed diagnosis and solution sources.
- `Regression Test Report Source`: regression test report source.
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
