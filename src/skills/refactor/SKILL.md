---
name: refactor
description: Use when a user asks to improve internal code structure, modularity, maintainability, testability, or dependencies without intentionally changing expected behavior in a target project.
---

# Refactor

Use this skill to run the Dev Cadence refactoring workflow.

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

## Refactoring Principles

Refactoring means improving internal structure, boundaries, maintainability, testability, or evolvability without intentionally changing externally observable behavior.

Use these principles throughout the workflow:

| Principle | Rule |
| --- | --- |
| Behavior preservation | External behavior, public APIs, data formats, CLI output, configuration semantics, user-visible copy, and integration contracts must remain unchanged unless the user explicitly converts that part into feature work or bug-fix work. |
| Baseline first | Identify the current behavior evidence before structural changes begin. If evidence is weak, add characterization tests, contract tests, snapshots, golden samples, or manual checks before changing structure, or record the uncovered risk. |
| Specific structural goal | Tie every refactor to a concrete goal such as clearer module boundaries, lower coupling, smaller files, reduced duplication, safer dependencies, better testability, or simpler control flow. |
| Small reversible steps | Prefer small changes that can be understood, verified, and reverted independently. Avoid big-bang rewrites unless the user accepts the risk explicitly. |
| No mixed demand | Do not mix new features, unrelated bug fixes, or stylistic preferences into refactoring work. |
| Contract first | Identify and protect external contracts before moving code, renaming exported symbols, changing data structures, or altering dependency direction. |
| Simplicity over abstraction | Add an abstraction only when it removes real complexity, protects a clear boundary, or consolidates proven duplication. |
| Reviewable evidence | Keep the diff, refactor record, review report, and verification report traceable enough for another engineer to understand why the structure changed and how behavior was protected. |
| Explicit risk | Record unverified behavior, compatibility risks, migration risks, and accepted residual risks instead of hiding them behind confidence language. |

## Common Refactoring Methods

Use the smallest method that achieves the confirmed structural goal:

| Method group | Examples |
| --- | --- |
| Behavior protection | characterization tests, contract tests, snapshot or golden-sample tests, baseline build and test runs, manual regression checklists. |
| Local cleanup | rename local symbols, extract function, inline trivial wrapper, split long function, extract constant, simplify conditional, remove dead code. |
| Responsibility and boundary changes | move function or type, split large file, split mixed-responsibility module, merge over-fragmented modules, separate read/write paths, isolate side effects. |
| Interface and data shape changes | introduce parameter object, introduce value object, encapsulate raw data, narrow public API, split stable and unstable interfaces, add compatibility adapter. |
| Dependency direction changes | remove circular dependencies, invert dependency direction, extract port/interface, introduce adapter, make implicit global state explicit. |
| Incremental migration | create new structure beside old structure, keep compatibility layer, migrate callers in small batches, run verification after each batch, delete old path only after migration evidence is complete. |

### Refactor Red Flags

| Thought | Reality |
| --- | --- |
| "Code first, tests later." | This is not protected refactoring. Establish enough Behavior Baseline evidence before changing structure; otherwise behavior drift cannot be distinguished from existing behavior. |
| "This tiny behavior improvement fits inside the refactor." | Intentional behavior changes belong in `feature-dev` unless the user explicitly expands scope and the workflow returns to the affected stage. |
| "This unrelated bug is easy to fix while I am here." | Unrelated defects belong in `bug-fix` or a separate task. Mixing them makes regression source unclear. |
| "This module is bad, so rewrite it." | A rewrite is not the default refactoring strategy. Prefer incremental migration unless the user accepts the larger risk. |
| "The abstraction might help later." | Future-only abstractions add complexity. Require current duplication, a real boundary, or a specific structural goal. |
| "Renaming cannot affect behavior." | Renames can affect exports, reflection, serialization, scripts, docs, configuration, and integrations. Protect the relevant contract. |
| "Cleaner code is the acceptance criterion." | Acceptance criteria must name the structural target and behavior-preservation evidence. |

## Git Checkpoints

Dev Cadence uses commits as workflow checkpoints after the user has confirmed a stage output.

Before creating any Dev Cadence workflow commit:

1. Confirm the current stage output has already been approved by the user.
2. Ensure the work is on a dedicated branch for this refactor.
3. If the current branch is not dedicated to this refactor, create or switch to a dedicated branch automatically and report the branch name.
4. Include only files related to the confirmed stage output.
5. Report the commit hash after committing.

After the user confirms a stage output, create a checkpoint commit unless the user explicitly asks not to or unrelated uncommitted changes make the commit unsafe.

Do not commit before the user confirms the current stage output.
Do not push unless the user explicitly asks.
If the current branch has unrelated uncommitted changes, stop and ask before switching branches or committing.
Final merge, PR creation, branch cleanup, or discarding the branch belongs to Completion and requires the user's decision through the vendored finishing flow.

### User-Requested Commits During Active Runs

Until Business Acceptance and Completion are finished, treat user requests to commit, submit, save, or checkpoint current changes as workflow control requests, not ordinary git commit requests.

Do not create an ordinary git commit for unfinished refactor work, even if the user says "commit changes" or a localized equivalent. Only create checkpoint commits for confirmed stage outputs under the Git Checkpoints rules above.

If the user asks to commit while the current stage output is not confirmed, explain that the workflow cannot create a checkpoint yet, then continue the current stage by updating the relevant record, running required verification, or asking for the required confirmation.

If refactor changes exist but Regression Verification or Business Acceptance is not complete, continue the workflow through refactor records, code review evidence, regression verification, and business acceptance instead of committing the work as a regular development commit.

### Commit Red Flags

| Thought | Reality |
| --- | --- |
| "User asked to commit, so ordinary git commit is allowed." | Active refactor runs allow checkpoint commits only for confirmed stage outputs. |
| "The refactor is mostly done, commit now and test later." | Continue through refactor records, code review, Regression Verification, and Business Acceptance first. |
| "This is just saving progress." | Save progress in stage records and the manifest, not an ordinary development commit. |

## Dev Cadence Stages

Present the work to the user using these business stages:

```text
Requirements Confirmation -> Refactor Solution -> Refactor Plan -> Refactor Implementation -> Regression Verification -> Business Acceptance
```

Do not start implementation before the user has confirmed:

- Requirements Confirmation
- Refactor Solution
- Refactor Plan

## Superpowers Mapping

Use the vendored Superpowers workflow as the execution method:

```text
brainstorming -> using-git-worktrees -> writing-plans -> behavior-baseline TDD when needed / green refactor loop -> subagent-driven-development / executing-plans -> requesting-code-review -> verification-before-completion
```

Map it to Dev Cadence like this:

| Dev Cadence stage | Superpowers work | Business output |
| --- | --- | --- |
| Requirements Confirmation | `brainstorming` refactor requirement clarification | Confirmed refactor requirements |
| Refactor Solution | `brainstorming` structural design/spec work | Refactor technical solution |
| Refactor Plan | `using-git-worktrees` and `writing-plans` | isolated workspace readiness, refactor implementation plan |
| Refactor Implementation | `test-driven-development` for new behavior-protection code, sensitivity-checked characterization tests for existing behavior, otherwise the green `REFACTOR` phase; then `subagent-driven-development`, `executing-plans`, and `requesting-code-review` | Working deliverable, supporting test assets, refactor record, code review report |
| Regression Verification | `verification-before-completion` | Regression test report |
| Business Acceptance | Dev Cadence user decision gate | Business acceptance record |

The mapping is semantic, not one-skill-per-stage. If a Superpowers skill naturally spans more than one Dev Cadence stage, keep the Superpowers flow intact and make the Dev Cadence stage boundary explicit in the user-facing update.

## Stage Records

The active AI agent is responsible for writing or updating the record for the stage it is executing. Do not rely on the conversation transcript as the only record.

Use one task directory for every workflow record and short-lived execution artifact:

```text
build/dev-cadence/refactor/<refactor-slug>/
```

Stage records:

```text
build/dev-cadence/refactor/<refactor-slug>/01-requirements.md
build/dev-cadence/refactor/<refactor-slug>/02-refactor-solution.md
build/dev-cadence/refactor/<refactor-slug>/03-refactor-plan.md
build/dev-cadence/refactor/<refactor-slug>/04-refactor-record.md
build/dev-cadence/refactor/<refactor-slug>/04-code-review-report.md
build/dev-cadence/refactor/<refactor-slug>/05-regression-test-report.md
build/dev-cadence/refactor/<refactor-slug>/06-business-acceptance-record.md
```

Subagent-driven development artifacts, when used, must be written under:

```text
build/dev-cadence/refactor/<refactor-slug>/sdd/
```

Create and maintain a run manifest for every workflow run:

```text
build/dev-cadence/refactor/<refactor-slug>/manifest.md
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

Until Business Acceptance and Completion are finished, treat user requests about the same refactor as changes to the current workflow run.

When the user asks for a scope clarification, structural target adjustment, implementation change, baseline change, test change, review fix, or acceptance feedback that belongs to the current refactor:

- update the existing task directory under `build/dev-cadence/refactor/<refactor-slug>/`;
- update the existing stage records and manifest instead of creating a new refactor slug, workflow run, requirements document, solution document, or refactor plan document;
- if the change affects an already confirmed stage, return to the earliest affected stage, mark affected later stages as `pending` or `in_progress` in the manifest, and refresh their records before moving forward again;
- if refactor implementation has already started, update `03-refactor-plan.md` when the plan no longer matches the requested change before continuing implementation;
- preserve prior decisions and evidence in the relevant record when they still explain the task history, but make the latest confirmed scope, baseline, plan, and verification state explicit.

If the requested change introduces new behavior, changes intended behavior, or asks to fix an unrelated defect, ask whether the user wants to expand the current work into a feature or bug-fix flow, split the request into a separate task, or keep the refactor behavior-preserving.

### Active Task Red Flags

| Thought | Reality |
| --- | --- |
| "The user added details, so start a new refactor document." | Same-refactor changes update the current workflow run and existing records. |
| "The confirmed refactor plan is old, but keep implementing anyway." | Return to the earliest affected stage and refresh records before moving forward. |
| "This adds useful behavior, but it is small enough to stay in refactor." | Intentional behavior changes require feature scope or a separate feature task. |

## Stage Rules

### Requirements Confirmation

Use:

```text
.dev-cadence/vendor/superpowers/skills/brainstorming/SKILL.md
```

Clarify the refactor requirement. Before moving on, explicitly present:

- structural goal;
- affected modules, paths, workflows, APIs, data formats, or dependencies;
- externally observable behavior that must remain unchanged;
- non-goals, including new features, unrelated bug fixes, and style-only preferences;
- success criteria for structure and behavior preservation;
- risks, assumptions, and open questions.

If the user asks for behavior changes as part of the request, ask whether to run `feature-dev`, split the behavior change from the refactor, or narrow this workflow to behavior-preserving structural work.

At the end of this stage, write or update:

```text
build/dev-cadence/refactor/<refactor-slug>/01-requirements.md
```

Ask the user to confirm this stage. Do not write the refactor plan or code yet.

### Refactor Solution

Continue with:

```text
.dev-cadence/vendor/superpowers/skills/brainstorming/SKILL.md
```

Define the technical solution for the confirmed refactor. Before moving on, explicitly present:

- current structural problem and evidence;
- target structure and boundary changes;
- refactoring methods selected from the Common Refactoring Methods section;
- external contracts that must be protected;
- Behavior Baseline: existing tests, characterization tests to add before structure changes, contract checks, snapshots, golden samples, build checks, manual checks, and known uncovered behavior;
- migration strategy, compatibility adapters, and deletion strategy when relevant;
- rollback or recovery points;
- risks and user decisions needed.

The Behavior Baseline definition must exist before Refactor Implementation begins. Executable baseline evidence must be established before the first structural edit. If coverage is insufficient and cannot be improved before structural edits, record the gap as an explicit risk and ask the user to confirm the risk before planning implementation.

At the end of this stage, write or update:

```text
build/dev-cadence/refactor/<refactor-slug>/02-refactor-solution.md
```

The Refactor Solution record must link to `01-requirements.md` as the confirmed refactor requirement source.
This active workflow path overrides any generic feature-spec default in the vendored brainstorming skill.

Ask the user to confirm this stage. Do not write the refactor implementation plan or code yet.

### Refactor Plan

Use:

```text
.dev-cadence/vendor/superpowers/skills/using-git-worktrees/SKILL.md
.dev-cadence/vendor/superpowers/skills/writing-plans/SKILL.md
```

Before writing the plan, apply the configured `worktree.enabled` and `worktree.directory`, then use `using-git-worktrees` to create or verify the isolated refactor workspace according to the vendored Superpowers rules. When `worktree.enabled` is `true`, treat it as a predeclared user preference to create an isolated worktree and do not ask for worktree consent. When `worktree.enabled` is `false`, skip worktree creation unless the user explicitly asks for it.

The plan is only for the next stage, Refactor Implementation. It must follow the Superpowers plan requirements: concrete files, concrete steps, behavior-protection cycles, commands, expected results, and self-review. Use test-first RED-GREEN cycles for new behavior-protection code, sensitivity-checked characterization tests for existing behavior, and green-REFACTOR-green cycles for behavior already covered by the baseline.

The plan must include:

- baseline tests or checks to add or run before structural changes;
- small behavior-preserving refactor steps;
- contract protection for affected public APIs, data formats, commands, configuration, and integrations;
- verification after each meaningful step or migration batch;
- removal steps for obsolete code only after replacement behavior is protected;
- completion conditions for Refactor Implementation.

Before detailed task steps, the plan must include a `Task Overview` section that lets the user quickly scan the planned refactor tasks without reading every step.

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
build/dev-cadence/refactor/<refactor-slug>/03-refactor-plan.md
```

This active workflow path overrides any generic default plan path in the vendored writing-plans skill.

Ask the user to confirm the plan before implementation starts.

### Refactor Implementation

Use these vendored skills as applicable:

```text
.dev-cadence/vendor/superpowers/skills/test-driven-development/SKILL.md
.dev-cadence/vendor/superpowers/skills/subagent-driven-development/SKILL.md
.dev-cadence/vendor/superpowers/skills/executing-plans/SKILL.md
.dev-cadence/vendor/superpowers/skills/requesting-code-review/SKILL.md
```

Follow the confirmed plan. Development-stage verification belongs here: establish or run baseline checks before structural edits, make small behavior-preserving changes, pass focused checks after each meaningful step, and refactor only while tests stay green.

Use `test-driven-development` RED-GREEN cycles when adding new compatibility adapters, test seams, or other behavior-protection code whose required behavior does not exist yet.

When adding a characterization or contract test for behavior that already exists, the test may pass immediately. Before relying on it as baseline evidence, perform a reversible test-sensitivity check: temporarily perturb the protected behavior or use mutation tooling, confirm the new test fails for the expected reason, restore the original behavior, and confirm the test passes again. Do not retain the mutation or change expected behavior merely to manufacture a RED phase.

When the Behavior Baseline already covers the protected behavior and the relevant checks are green, treat the structural edit as the `REFACTOR` phase of an established TDD cycle. Do not invent a failing test or add tests that lock internal structure solely to manufacture a RED phase. Make one small structural change, rerun the focused baseline checks, and continue only while they remain green.

This workflow-specific mapping resolves how the vendored TDD process applies to behavior-preserving refactors. It does not relax the RED requirement when new behavior coverage or compatibility behavior must be introduced.

Use `subagent-driven-development` when the plan has independent tasks and the platform supports subagents. Use `executing-plans` when subagent-driven development is not available or not appropriate.

Follow the Superpowers code review requirements during Refactor Implementation. Fix Critical and Important findings before moving to Regression Verification, unless the user explicitly accepts the risk.

Before using `subagent-driven-development`, set:

```text
DEV_CADENCE_TASK_DIR=build/dev-cadence/refactor/<refactor-slug>
```

All SDD task briefs, implementer reports, review packages, and progress ledgers must stay under that task directory.

If new debugging is needed, use:

```text
.dev-cadence/vendor/superpowers/skills/systematic-debugging/SKILL.md
```

If implementation reveals a necessary behavior change or unrelated bug fix, stop and ask whether to switch flows, split the work, or keep this refactor behavior-preserving.

At the end of this stage, write or update:

```text
build/dev-cadence/refactor/<refactor-slug>/04-refactor-record.md
```

The refactor record must include:

- implementation commit hash or changed files;
- completed plan tasks;
- Behavior Baseline evidence used before structural changes;
- structural changes actually made;
- tests and checks run during refactor implementation;
- code review report path, summary, and unresolved review findings, if any;
- skipped checks with reasons;
- refactor notes and known residual risks.

Completed plan task evidence must be kept in sync with the plan. Mark completed refactor-plan steps as `- [x]`. If the plan file cannot be updated, record the completed step numbers and the reason the checklist could not be updated in the refactor record.

Code review evidence must be traceable and high signal. Write the detailed review report to:

```text
build/dev-cadence/refactor/<refactor-slug>/04-code-review-report.md
```

The refactor record must link to `04-code-review-report.md` and summarize:

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
- `behavior preservation`: whether external behavior, public contracts, data formats, commands, configuration, user-visible text, and integrations remain protected by the Behavior Baseline;
- `refactor quality`: whether the change improves the confirmed structural goal without over-abstraction, hidden behavior change, or unnecessary churn;
- `test / acceptance alignment`: whether implementation and tests match the confirmed requirements, refactor solution, refactor plan, and acceptance criteria.

Only record high-signal findings. A finding must have file/line evidence or a clearly stated proof, must be introduced by the current change, and must affect functionality, rule compliance, security, maintainability, behavior preservation, or acceptance. Do not record pure style preferences, speculative concerns, pre-existing issues, or issues a linter/formatter will catch unless they block delivery.

For each Critical or Important finding, record one validation state: `validated`, `not validated`, `fixed`, or `accepted risk`. Unvalidated findings must not block Regression Verification, but must remain visible as review notes. Critical and Important validated findings must be fixed or explicitly accepted by the user before moving to Regression Verification.

Use this `Code Review Evidence` structure in the refactor record:

```text
## Code Review Evidence

- Report: build/dev-cadence/refactor/<refactor-slug>/04-code-review-report.md
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
- [ ] Confirmed refactor requirements and refactor solution sources are linked.
- [ ] Behavior Baseline source is linked.
- [ ] Refactor plan source is linked.
- [ ] Reviewed diff or commit range is identified by branch and commit hash when available.

## Review Perspectives

- [ ] Rules compliance reviewed.
- [ ] Behavior preservation reviewed.
- [ ] Refactor quality reviewed.
- [ ] Test / acceptance alignment reviewed.
- [ ] Security, accessibility, performance, or operational concerns considered when relevant.

## Findings

- [ ] Critical findings recorded, or `None`.
- [ ] Important findings recorded, or `None`.
- [ ] Each Critical or Important finding has file/line evidence or a clearly stated proof.
- [ ] Each Critical or Important finding has one validation state: `validated`, `not validated`, `fixed`, or `accepted risk`.

## Review Decision

- [ ] Safe to proceed to Regression Verification, or blocking reason recorded.
- [ ] Fixes applied are listed, or `None`.
- [ ] Unresolved findings are listed, or `None`.
- [ ] Residual review risks are listed, or `None`.
```

### Regression Verification

Use:

```text
.dev-cadence/vendor/superpowers/skills/verification-before-completion/SKILL.md
```

Verify the working deliverable against the confirmed requirements, refactor solution, Behavior Baseline, refactor plan, and actual changes. Confirm the structural goal was met and compare results against the Behavior Baseline to show behavior did not drift.

Do not claim the refactor is complete, safe, or regression-free without fresh verification evidence.

At the end of this stage, write or update:

```text
build/dev-cadence/refactor/<refactor-slug>/05-regression-test-report.md
```

The regression test report must use this structure:

- `Refactor Sources`: requirements source, refactor solution source, Behavior Baseline source, plan source, and refactor record source.
- `Test Environment`: repository, branch, date, runtime, servers, tools, and relevant configuration.
- `Test Cases`: a table with columns `ID`, `Scenario`, `Type`, `Execution`, `Result`, and `Evidence`. List every automated, manual, smoke, build, source-inspection, regression, and skipped test case that matters to the confirmed refactor.
- `Behavior Baseline Coverage`: map each protected behavior or contract to test case IDs and an explicit status: `covered`, `skipped`, `not covered`, or `accepted risk`.
- `Structural Goal Coverage`: map each confirmed structural goal to evidence and an explicit status: `met`, `partially met`, `not met`, or `accepted risk`.
- `Failed Or Skipped Checks`: failures and skipped checks with reasons. If none, write `None`.
- `Residual Risks`: remaining risks after testing. If none, write `None`.
- `Recommendation`: whether the refactor can enter Business Acceptance.

Coverage must be honest. If a protected behavior, contract, or structural goal is not verified by an executed test or check, list it as `skipped`, `not covered`, `partially met`, `not met`, or `accepted risk`; do not only mention it in `Residual Risks`.

### Business Acceptance

Superpowers does not provide a dedicated business acceptance skill. Use this Dev Cadence gate:

- summarize the confirmed refactor requirement;
- summarize the structural result;
- summarize Behavior Baseline and regression evidence;
- summarize residual risks;
- ask the user to choose a business acceptance decision from fixed numbered options:
  1. Accept
  2. Reject
  3. Accept with residual risk
- get the business acceptor identity from the target repository's `git config user.name` and `git config user.email`; ask the user only if git identity is unavailable;
- map the user's selected number or exact option text to the normalized decision, then record the decision, decision maker, exact decision time with timezone, and accepted residual risks.

Do not substitute regression verification success for user acceptance.
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
build/dev-cadence/refactor/<refactor-slug>/06-business-acceptance-record.md
```

The business acceptance record must use this structure:

- `Accepted Refactor Sources`: confirmed requirements, refactor solution, Behavior Baseline, and plan sources.
- `Regression Test Report Source`: regression test report source.
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
- [ ] Refactor record has the final implementation commit hash or final changed-files state.
- [ ] Refactor record links to `04-code-review-report.md`.
- [ ] Code review report exists and all checklist items are checked or have an explicit reason.
- [ ] Regression test report records Behavior Baseline coverage, skipped checks, and residual risks honestly.
- [ ] No stage record contains stale future-tense or pre-commit status that conflicts with the manifest.
- [ ] Artifact paths are repository-relative; no local absolute paths are persisted unless explicitly requested by the user.

If any checklist item is not satisfied, update the affected record before reporting Completion.

Then follow the vendored finishing skill.
