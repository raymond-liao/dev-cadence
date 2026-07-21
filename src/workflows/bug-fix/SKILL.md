---
name: bug-fix
description: Use when a user reports or asks to fix a bug, error, crash, regression, failing test, broken expected behavior, or unexpected behavior in a target project.
---

# Bug Fix

Use this skill to run the Dev Cadence bug fix workflow.

This is a Delivery Workflow. Preserve its complete diagnosis, implementation, and verification evidence chain under `build/dev-cadence/bug-fix/<bug-slug>/` according to the shared record-model contract in `using-dev-cadence`.

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

Apply the shared `Configuration Identity And Worktree Continuation` rules from `using-dev-cadence` before writing any diagnosis, solution, plan, record, or summary. In a linked worktree, verify that the propagated configuration is present and matches the active run snapshot before continuing.

Use `output_language` from that file for all workflow documents and records, including Superpowers plan documents, Dev Cadence records, and user-facing stage summaries.

Supported values:

- `en`: write documents and records in English.
- `zh-CN`: write documents and records in Simplified Chinese.

Use `worktree.enabled` to select the entry-prepared workspace:

- `true`: the entry immediately creates or verifies the configured isolated task worktree before routing downstream; Plan verifies and reuses it.
- `false`: the entry immediately prepares a dedicated task branch without a worktree before routing downstream; Plan verifies and reuses it.

Use `worktree.directory` as the preferred project-local worktree directory when `worktree.enabled` is `true`.

If the config file is missing or the value is unsupported, use `en`.
If `worktree.enabled` is missing or unsupported, use `false`.
If `worktree.directory` is missing, use `.worktrees`.
Do not read user configuration from `.dev-cadence/`; that directory is a replaceable installed package.

## Generated Status Presentation

When writing or updating user-visible status summaries, apply the shared status presentation mapping from `document-conventions`. Use it consistently for the manifest and stage table, stage records and reports, review and test conclusions, coverage, verification, business acceptance, Completion, and user-facing progress summaries while preserving every canonical status value.

## Generated Document References

Apply the shared document-reference rules from `document-conventions` to every Dev Cadence-managed Markdown document. Check local links in all tracked Markdown before each commit; check local links in all generated documents for the current run before Completion. Keep the complete selection, identity, lifecycle, and URI contract in the shared skill rather than duplicating it here.

## Documentation Test Boundary

Root-level `*.md` files and all files under `docs/` do not require new or updated automated tests.
Do not add or modify automated tests solely because these documentation files changed.
Run existing formatting, link, spelling, or repository checks when they apply.
If the same task changes executable behavior, test that executable behavior; do not create tests that lock human-facing documentation wording merely to manufacture a TDD RED phase.

This boundary is path-based. It does not exempt `SKILL.md`, agent instructions, machine-consumed Markdown, executable specifications, or other runtime assets stored outside the target repository root and `docs/`.

## Git Checkpoints

Dev Cadence uses commits for engineering progress and workflow checkpoints.

Commits do not require user confirmation. User confirmation controls whether the workflow may advance to the next business stage; it does not control whether current in-scope work may be committed.

Before creating any Dev Cadence workflow commit:

1. Ensure the work is on a dedicated branch for this bug fix.
2. If the current branch is not dedicated to this bug fix, create or switch to a dedicated branch automatically and report the branch name.
3. Include only files related to the active workflow scope and current progress.
4. Run the checks appropriate for the files being committed.
5. Report the commit hash after committing.

Create progress commits when the confirmed plan or a vendored Superpowers implementation skill requires them. After a stage record reaches a reviewable state, create a stage checkpoint commit without asking unless unrelated uncommitted changes make the commit unsafe.

A commit does not confirm the current stage, satisfy a user confirmation gate, or allow the workflow to advance. Record user confirmation separately in the manifest.
If a stage has no related tracked changes because its records are ignored and it does not change tracked project files, do not create an empty commit unless project policy requires one. Record the checkpoint as `skipped: no tracked changes` and continue to the stage confirmation gate.
Do not push unless the user explicitly asks.
If the current branch has unrelated uncommitted changes, stop and ask before switching branches or committing.
Before any action that would merge, create or update a PR, push, discard work, or delete a branch, get the user's explicit decision through Completion and the vendored finishing flow.

### User-Requested Commits During Active Runs

Until Business Acceptance and Completion are finished, a commit request changes Git state but does not change workflow state.

If the user asks to commit, save, or checkpoint current changes, commit current in-scope changes without asking after running appropriate checks. Record the commit hash in the current stage record or manifest when it is relevant to the evidence trail.

The commit does not confirm a stage or bypass testing, verification, business acceptance, or Completion. After committing, continue the active workflow from its current stage.

If there are no in-scope tracked changes, report that no commit was created and use `skipped: no tracked changes` for any stage checkpoint that needs a terminal manifest value.

### ⚠️ Commit Red Flags

| Thought | Reality |
| --- | --- |
| "User asked to commit, so the workflow is complete." | A commit only records current progress. Continue through the remaining stage gates. |
| "I need user approval before every commit." | Commits do not require approval. Merge, PR, push, discard, and branch deletion decisions do. |
| "The repair is committed, so regression verification can happen later." | Commit timing does not relax implementation, review, Regression Verification, or Business Acceptance requirements. |

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
| Repair Plan | `using-git-worktrees` and `writing-plans` | entry-prepared workspace verification, TDD repair plan |
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
build/dev-cadence/bug-fix/<bug-slug>/01-problem-diagnosis-record.md
build/dev-cadence/bug-fix/<bug-slug>/02-repair-solution.md
build/dev-cadence/bug-fix/<bug-slug>/03-repair-plan.md
build/dev-cadence/bug-fix/<bug-slug>/04-repair-record.md
build/dev-cadence/bug-fix/<bug-slug>/04-code-review-report.md
build/dev-cadence/bug-fix/<bug-slug>/05-regression-test-report.md
build/dev-cadence/bug-fix/<bug-slug>/06-business-acceptance-record.md
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

## Worktree Creation Evidence

The manifest is the sole authority for this immutable creation-evidence tuple. Write this section once when the initial manifest is created from the entry handoff, and never update it during checkpoints or later stages.

- Created By Current Run: `yes|no`
- Workspace Path: `<repository-relative path or not_applicable>`
- Task Branch Ref: `<refs/heads/... or not_applicable>`
- Creation HEAD SHA: `<full 40-hex SHA or not_applicable>`

`Workspace Path` is created-worktree provenance only. When `Created By Current Run: no`, every tuple value is `not_applicable`; this does not describe or replace the actual current workspace classification used in Current-run Discard context.

Do not reconstruct or replace this tuple from stage records, workspace path, configuration, branch name, or an existing worktree registration.

The manifest must include:

- workflow, task slug, repository, branch, started at, current stage, and overall status;
- a stage table with stage name, status, artifact path, user confirmation, checkpoint commit, and notes;
- verification summary and residual risks once available;
- business acceptance decision once available;
- final integration decision after Completion only when run records remain.
- Current-run Discard context and ownership evidence, captured during the run before Completion: Workflow, Task slug, Run directory, Task branch, Base branch, Expected HEAD SHA, Expected base SHA, Owned commit range, Owned tracked and untracked paths, Workspace path (the actual current workspace classification, independent of the creation-evidence tuple and not ownership evidence), and Worktree created by this run.

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
Use `skipped: no tracked changes` when a stage produced only ignored records and no related tracked project change.

Update the manifest:

- when the workflow starts;
- whenever a stage record is created or updated;
- after each checkpoint commit, adding the commit hash;
- before entering Business Acceptance;
- Only when run records remain after the finishing flow returns merge, PR, or keep: record the final integration decision.

If run records under `build/dev-cadence/` are ignored by the target repository, keep the manifest updated on disk and do not force-add ignored files unless the user or project policy requires it.

Before moving to the next stage, ensure the current stage record exists and reflects the user's latest confirmed decision or the latest verification evidence.
Also ensure the manifest points to the latest stage record and checkpoint commit before moving to the next stage.

## Work Item Card Integration

Every `bug-fix` run must reuse one authoritative Bug card when one exists; direct Bug investigation may create or complete the Bug card under this workflow when no card exists. The first diagnosis record must capture the exact card path, `Bug` type, current card Version, visible Status, and the selected scope; it must reference the card rather than copy its body.

A Bug may enter `bug-fix` without `Ready`, complete reproduction, or a known root cause. Diagnosis owns reproduction, root-cause evidence, and the repair boundary. A Feature request or intentional behavior change must route to `feature-dev`, not be hidden inside a Bug Fix.

Before using card facts at any stage, check the current card Version and visible facts against the run record. A Version or visible-fact conflict must stop the run for a user decision. A substantive card revision uses Active Task Change Handling to return to the earliest affected stage; an execution-status-only change preserves the Version.

At start, rework, Business Acceptance, and Completion, lifecycle writeback must record the card status, repair result/reference, and exact Backlog source and destination sections. A lifecycle writeback uses the current card Version and does not increment it; its Change Log records an important event when a status transition or repair result qualifies under `.dev-cadence/references/contracts/change-log.md`. The same lifecycle event must not duplicate the Change Log entry. Card and Backlog lifecycle writes must be atomic and idempotent, preserve unrelated pending-row order, and keep Workflow stage names separate from work-item statuses. The workflow must not mark the card `Done` for an unaccepted, unintegrated, kept-branch, cancelled-discard, or blocked-discard result.

## Active Task Change Handling

Until Business Acceptance and Completion are finished, treat user requests about the same bug fix as changes to the current workflow run.

When the user provides additional symptoms, reproduction feedback, repair requirements, implementation change requests, test changes, review fixes, or acceptance feedback that belongs to the current bug fix:

- update the existing task directory under `build/dev-cadence/bug-fix/<bug-slug>/`;
- update the existing stage records and manifest instead of creating a new bug slug, workflow run, diagnosis document, repair solution document, or repair plan document;
- if the change affects an already confirmed stage, return to the earliest affected stage, mark affected later stages as `pending` or `in_progress` in the manifest, and refresh their records before moving forward again;
- if repair implementation has already started, update `03-repair-plan.md` when the plan no longer matches the requested change before continuing implementation;
- preserve prior diagnosis, decisions, and evidence in the relevant record when they still explain the task history, but make the latest confirmed problem, repair boundary, plan, and verification state explicit.

If the requested change clearly exceeds the current confirmed repair boundary, ask whether the user wants to expand the current bug fix or start a separate task before creating any new workflow run or document.

### ⚠️ Active Task Red Flags

| Thought | Reality |
| --- | --- |
| "The user added details, so start a new diagnosis document." | Same-bug changes update the current workflow run and existing records. |
| "The confirmed repair plan is old, but keep implementing anyway." | Return to the earliest affected stage and refresh records before moving forward. |
| "This sounds bigger, so silently start a new task." | Ask whether to expand the current bug fix or start a separate task. |

## Confirmation Gate Presentation

Before each real pre-Business Acceptance confirmation gate in `Problem Diagnosis`, `Repair Solution`, and `Repair Plan`, present the decision in this order before any evidence link:

1. `current conclusion`: the confirmed diagnosis, repair approach, or repair plan for the current stage.
2. `included scope`: the symptom, root cause, repair boundary, files, regression checks, and records covered by this version.
3. `excluded scope`: unrelated defects, intentional behavior changes, deferred work, and later workflow stages not covered by this decision.
4. `risks or open questions`: diagnosis confidence, repair risks, unresolved assumptions, and regression gaps that affect the decision.
5. `evidence link`: a repository-relative link to the stage record, repair plan, or other complete evidence. The link supports the summary and does not replace it.

Then present the actual choices and their effects. The minimum delivery choices are:

- `confirm current version and advance to the next stage`: record the user's confirmation for the current stage, preserve the confirmed repair scope and version, create the required checkpoint when applicable, and allow the next Dev Cadence stage to begin.
- `request changes and remain at the current stage`: do not advance or start later-stage work, update the same diagnosis, solution, or plan record with the requested changes, and present the complete gate again for confirmation.

Every choice must state its effect on the next stage, asset writes, workflow records, stage status, and whether re-confirmation is required. A diagnosis that remains ambiguous must stay in diagnosis; `not-a-bug`, scope expansion, and any intentional behavior change keep their existing routing rules. This contract does not replace the fixed Business Acceptance or Completion menus.

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
build/dev-cadence/bug-fix/<bug-slug>/01-problem-diagnosis-record.md
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
build/dev-cadence/bug-fix/<bug-slug>/02-repair-solution.md
```

Ask the user to confirm this stage. Do not write the TDD repair plan or code yet.

### Repair Plan

Use:

```text
.dev-cadence/vendor/superpowers/skills/using-git-worktrees/SKILL.md
.dev-cadence/vendor/superpowers/skills/writing-plans/SKILL.md
```

The entry-prepared workspace must be verified and reused at Plan stage; this stage must not first create a task branch or worktree. When `worktree.enabled` is `true`, verify the entry created or verified the configured isolated repair worktree. When `worktree.enabled` is `false`, verify the entry prepared the dedicated repair branch with no worktree.

The plan is only for the next stage, Repair Implementation. It must follow the Superpowers plan requirements: concrete files, concrete steps, test-first cycles, commands, expected results, and self-review.

The plan must include:

- a failing test or reproducible check that proves the bug;
- the expected failure evidence before the fix;
- the minimal repair steps;
- supporting unit, integration, frontend, API, script, or manual checks needed for the repaired behavior;
- regression checks derived from the Repair Solution impact scope;
- completion conditions for Repair Implementation.

Before detailed task steps, the plan must include a `Task Overview` section that lets the user quickly scan the planned repair tasks without reading every step.

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
build/dev-cadence/bug-fix/<bug-slug>/03-repair-plan.md
```

Ask the user to confirm the plan before implementation starts.

#### Pre-Implementation Design Freshness Gate

Immediately before entering Repair Implementation, revalidate that the confirmed diagnosis, Repair Solution, and Repair Plan still match the current repair context.

Compare the current work item card version, confirmed diagnosis record, confirmed Repair Solution record, Repair Plan, and current code state. When present, also inspect authoritative product design, architecture, Decision, dependency state, and other sources referenced by the plan.

Record the input identities, conclusion, and evidence summary in the manifest and current plan or repair record. The evidence must identify the card and document versions or paths used, the current branch and commit, relevant dependency state, and material repository changes since confirmation.

Classify the result:

- If the inputs remain valid, continue directly without asking the user to reconfirm unchanged content.
- If the diagnosis, expected behavior, repair boundary, or acceptance criteria changed, return to the earliest affected Problem Diagnosis stage.
- If architecture, data, interface, security, or repair-strategy assumptions changed, return to Repair Solution.
- If only the task split, file list, order, or verification steps changed, return to Repair Plan.
- Unrelated code changes, formatting changes, generated output, or files outside the affected boundary do not invalidate the design.

When returning to an earlier stage, mark affected later confirmation and verification evidence as superseded, set the earliest affected stage to `in_progress`, set later affected stages to `pending`, refresh and reconfirm the affected records, and block implementation until the gate passes again.

### Failure Classification And Stage Routing

Use this lifecycle for blocking failures observed during implementation, compilation or build, automated testing, Regression Verification, regression checks, or implementation-stage code review. Classify from inspectable evidence, not from the failure symptom alone.

Use exactly these canonical classifications: `implementation_bug`, `test_bug`, `environment_issue`, `unclear_requirement`, `design_conflict`, `architecture_conflict`, and `missing_dependency`.

Assign every failure a stable failure ID that remains unchanged across remediation, reruns, and reclassification. The complete failure record belongs in the stage record that observed the failure; the manifest contains only the current routing or blocking summary. Record the failure ID, evidence, classification rationale, remediation round, return target, and result. When a failure originates from code review, also record its source finding ID.

Route each classification as follows:

- `implementation_bug`: return to Repair Implementation.
- `test_bug`: return to the test asset owner or the test-correction step within Repair Implementation. Do not delete, skip, or weaken an effective test to hide an implementation failure. If the test asset owner is external, keep `test_bug`, record the owner and unblock conditions, and do not relabel it as `missing_dependency`.
- `unclear_requirement`: return to Problem Diagnosis, the earliest requirement or diagnosis stage for this workflow.
- `design_conflict`: return to Repair Solution.
- `architecture_conflict`: return to Repair Solution and reassess the relevant Architecture and Decision sources before reconfirming the solution.
- `environment_issue`: keep the current business stage as `blocked`, keep the overall status as `in_progress`, and record reproducible evidence plus unblock conditions. Do not report the implementation or verification as passed, failed, or ready solely because the environment is blocked.
- `missing_dependency`: return a requirement dependency to Problem Diagnosis, a solution dependency to Repair Solution, and an execution dependency to Repair Plan or Repair Implementation, choosing the earliest stage that can resolve it. If the current task cannot resolve it, block the run and record the responsible owner and unblock conditions without reporting a false verification conclusion.

Do not retry the same failure without new evidence, a corrective action, or an environment change. After remediation, rerun the check associated with the stable failure ID and record exactly one failure lifecycle result: `closed`, `reclassified`, or `blocked`. These failure lifecycle results are internal record values and must not become Backlog or work-item statuses.

Only a validated blocking code review finding enters this failure lifecycle; preserve its source finding ID. Keep non-blocking or unvalidated findings in the existing code review evidence model.

When routing returns to an earlier stage, reuse the active-task rollback semantics: set the earliest affected stage to `in_progress`, set later affected stages to `pending`, mark invalidated confirmation and verification evidence as `superseded`, refresh the affected records, and obtain the confirmations required by this workflow before continuing.

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

Vendored implementation skills may create progress commits without asking. These commits do not confirm Repair Implementation or advance the workflow.

Return control to Dev Cadence after implementation and review. Do not invoke `finishing-a-development-branch` during Repair Implementation, even if a vendored implementation skill normally invokes it after its tasks. This active workflow overrides that terminal step; proceed to Regression Verification instead.

Follow the Superpowers code review requirements during Repair Implementation. Fix Critical and Important findings before moving to Regression Verification, unless the user explicitly accepts the risk.

#### Executing-Plans Pre-Commit Review

This subsection applies only when `executing-plans` is selected. It governs every implementation commit created while executing the confirmed repair plan, including plan-task commits, user-requested repair progress commits, and final-review fix commits. The active main agent must perform this review without requiring a subagent. It does not apply to `subagent-driven-development` task commits or stage checkpoint commits.

Before the first implementation commit, capture and persist the implementation base in the repair record:

```bash
IMPLEMENTATION_BASE_SHA=$(git rev-parse HEAD)
```

The repair record must record the implementation base SHA before any implementation commit. Use one review unit for every commit:

- `plan-task-<n>` for a commit required by the confirmed repair-plan task;
- `progress-<n>-<k>` for a user-requested commit before repair-plan task `<n>` is complete;
- `final-review-fix-<k>` for commits that resolve findings from the final whole-repair review;
- `recovery-fix-<review-id>-<k>` for a corrective commit required to close retrospective findings for `<review-id>`.

A progress unit runs checks appropriate to its staged work; the current plan task must remain `in_progress` and its checklist must not advance. A final-review fix unit cites its finding IDs and affected tasks and may cross completed-task file boundaries only to resolve those findings. A recovery-fix unit is limited to the changes required by its linked retrospective findings.

Maintain an `Executing-Plans Commit Review Ledger` in the repair record. Each entry records the review ID and unit, commit type, state, Expected parent, Reviewed tree, staged files, checks, decision, commit hash, Committed parent, Committed tree, Identity, findings, residual risks, and separate Source finding IDs and Affected tasks fields when applicable. Allowed states are `reviewed-pending-commit` (reviewed snapshot persisted, commit not verified), `verified` (identity proven or retrospective review closed), and `recovery-required` (actual commit is not proven or its retrospective findings remain open). Identity is `pending`, `exact`, or `retrospective`.

Before any implementation commit, run this gate:

1. Stage only review-unit files. A final-review fix is scoped by its cited findings, not by a nonexistent current task. Do not stage unrelated changes.
2. Capture the reviewed identity, then inspect the complete review-unit snapshot:

   ```bash
   EXPECTED_PARENT_SHA=$(git rev-parse HEAD)
   REVIEWED_TREE_SHA=$(git write-tree)
   git status --short
   git diff --cached --stat
   git diff --cached
   ```

3. Review the complete staged diff against the review unit, confirmed diagnosis and solution, repair plan, acceptance criteria, applicable repository rules, correctness and risk, required regression evidence, and scope. Fix findings, rerun relevant checks, restage, and repeat the complete gate.
4. Confirm the reviewed identity is still current:

   ```bash
   test "$(git rev-parse HEAD)" = "$EXPECTED_PARENT_SHA"
   test "$(git write-tree)" = "$REVIEWED_TREE_SHA"
   ```

5. Persist the complete ledger entry as `reviewed-pending-commit` with `Identity: pending` and read it back.
6. Immediately before committing, repeat both identity checks. If either fails, repeat the complete gate and replace the stale pending evidence.
7. Create the implementation commit only after the pending entry and identity checks pass, then capture the committed identity:

    ```bash
    COMMIT_SHA=$(git rev-parse HEAD)
    COMMIT_PARENT_SHA=$(git rev-parse "${COMMIT_SHA}^")
    COMMITTED_TREE_SHA=$(git rev-parse "${COMMIT_SHA}^{tree}")
    ```

8. Only after both comparisons pass may the entry become `verified` with `Identity: exact`: `COMMIT_PARENT_SHA` equals `EXPECTED_PARENT_SHA`, and `COMMITTED_TREE_SHA` equals `REVIEWED_TREE_SHA`. For `Identity: exact`, Expected parent is the Commit's actual immediate parent. Otherwise set `recovery-required` with `Identity: retrospective`, record Committed parent, and review `EXPECTED_PARENT_SHA..COMMIT_SHA`; for `Identity: retrospective`, use Committed parent rather than Expected parent when reconciling actual history. Stop further implementation commits except linked `recovery-fix-<review-id>-<k>` commits, each of which uses the normal exact-identity gate. Mark the recovery entry `verified` when the retrospective review is recorded and no blocking finding remains: validated Critical or Important findings are fixed or recorded as accepted risk after explicit user acceptance, while not validated and other non-blocking findings remain visible. Never call retrospective evidence pre-commit evidence.

Do not mark a repair-plan task complete until its final plan-task entry is `verified`, its required checks pass, and its evidence is complete. A progress entry never completes a repair-plan task.

When resuming, read `IMPLEMENTATION_BASE_SHA` and the complete ledger before continuing. Reconcile the ledger with:

```bash
git rev-list --reverse --first-parent "$IMPLEMENTATION_BASE_SHA..HEAD"
```

Before treating any history entry as unmatched, classify each first-parent commit after `IMPLEMENTATION_BASE_SHA`:

- a commit recorded in the ledger is an implementation commit;
- a commit whose hash is recorded as a stage checkpoint in the run manifest or current stage record is a recorded stage checkpoint; it does not enter the implementation ledger or require retrospective implementation review;
- any other commit is an unclassified commit; first try to reconcile it with a pending entry using the identity rules below, and require retrospective review or user clarification only when no exact pending match exists.

Verified ledger commits must appear in first-parent order, but recorded stage checkpoints may appear between them. For an exact entry, Expected parent must equal the Commit's actual immediate parent; for a retrospective entry, Committed parent must equal the actual immediate parent. Implementation commits do not need to be adjacent to one another. If a pending entry's Expected parent equals `HEAD`, no commit occurred. Continue if the index still equals its Reviewed tree. If the index differs, record why the pending snapshot was invalidated, repeat the complete gate, and replace its identity and review evidence before committing. If the direct first-parent child is a recorded stage checkpoint, the pending snapshot is stale; invalidate it and repeat the gate from the current `HEAD` after classifying later commits. Otherwise set `COMMIT_SHA` to the direct first-parent child and recompute only `COMMIT_PARENT_SHA` and `COMMITTED_TREE_SHA` for that selected commit using the last two committed-identity commands above; do not reset `COMMIT_SHA` from `HEAD`. If the parent and tree match, attach it as `verified` and `exact`. Any remaining unclassified commit requires retrospective review and `Identity: retrospective`; never fabricate pre-commit evidence. Recover a missing base only from the earliest ledger Expected parent after verifying the ordered history. Stop and ask the user for rewritten history, unexplained merges, broken ancestry, missing evidence, or ambiguous ownership; do not guess, amend, or rewrite history.

After all repair-plan tasks have verified final entries and no entry remains pending or recovery-required, set `FINAL_IMPLEMENTATION_SHA` to the Commit hash of the latest verified implementation commit in the ledger and consolidate the ledger into `04-code-review-report.md`. The final review must cover the complete repair range `IMPLEMENTATION_BASE_SHA..FINAL_IMPLEMENTATION_SHA`; use that range as the ancestry boundary, but exclude changes introduced only by recorded stage checkpoints from repair findings and list those checkpoint hashes separately. Do not use `HEAD~1` for a multi-commit repair. If reviewer subagents are available, use `requesting-code-review` for an additional final independent review. If reviewer subagents are unavailable, the active main agent must perform the final whole-repair review and record its reviewed commit range, findings, fixes, and decision in the same report.

If the final review produces a validated finding that requires code changes, create a `final-review-fix-<k>` unit with the next unused `<k>` and tie it to the finding IDs; because one unit covers one commit, additional commits use successive values. Keep completed repair-plan tasks closed for cross-task integration fixes. Reopen an affected task only when the finding proves that its acceptance criteria or required verification were not satisfied. If the fix expands confirmed scope, do not treat it as a review fix; follow Active Task Change Handling and return to the earliest affected stage. Every final-review fix commit must pass the normal exact-identity gate. After any verified implementation commit created during final-review remediation, whether `final-review-fix` or `recovery-fix`, set `FINAL_IMPLEMENTATION_SHA` to the latest verified implementation commit and repeat the final whole-repair review. Continue until no blocking finding remains or the user explicitly accepts the residual risk.

This gate applies only to implementation commits created while executing the confirmed repair plan. Stage checkpoint commits remain governed by the Git Checkpoints rules. Do not mix implementation changes into a stage checkpoint commit.

#### Subagent-Driven Development

Before using `subagent-driven-development`, set:

```text
DEV_CADENCE_TASK_DIR=build/dev-cadence/bug-fix/<bug-slug>
```

All SDD task briefs, implementer reports, review packages, and progress ledgers must stay under that task directory.

Ignored SDD scratch such as `sdd/progress.md` is useful during implementation, but `sdd/progress.md` and other ignored SDD scratch files are not required terminal evidence.

#### Common Implementation Rules

These common rules apply to both `executing-plans` and `subagent-driven-development`.

If new debugging is needed, return to:

```text
.dev-cadence/vendor/superpowers/skills/systematic-debugging/SKILL.md
```

At the end of this stage, write or update:

```text
build/dev-cadence/bug-fix/<bug-slug>/04-repair-record.md
```

For committed tracked changes, terminal evidence must include the Implementation Base SHA, final implementation commit hash, and final changed-files state derived from that implementation range. If a terminal or stage checkpoint has no tracked changes, record `skipped: no tracked changes` instead of substituting alternative evidence.

After writing or updating the stage record, follow this sequence exactly: Write or update the stage record -> create the stage checkpoint -> verify the checkpoint tree contains the stage record -> bind the verified SHA in manifest -> run the installed delivery-record validator.

Verify the checkpoint tree contains the stage record with `git cat-file -e "<checkpoint-commit>:build/dev-cadence/bug-fix/<bug-slug>/04-repair-record.md"`, then record the verified checkpoint SHA in the manifest and run `bash .dev-cadence/workflows/using-dev-cadence/scripts/validate-delivery-record.sh build/dev-cadence/bug-fix/<bug-slug>`.

The repair record must include:

- final implementation commit hash and Changed Files for committed tracked changes, or `skipped: no tracked changes` when applicable;
- completed plan tasks;
- original bug reproduction evidence;
- tests and checks run during repair implementation;
- code review report path, summary, and unresolved review findings, if any;
- skipped checks with reasons;
- repair notes and known residual risks.

Completed plan task evidence must be kept in sync with the plan. Mark completed repair-plan steps as `- [x]`. If the plan file cannot be updated, record the completed step numbers and the reason the checklist could not be updated in the repair record.

Code review evidence must be traceable and high signal. Write the detailed review report to:

```text
build/dev-cadence/bug-fix/<bug-slug>/04-code-review-report.md
```

The repair record must link to `04-code-review-report.md` and summarize:

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
- `test / acceptance alignment`: whether implementation and tests match the confirmed problem diagnosis, repair solution, repair plan, and repair acceptance criteria.

Only record high-signal findings. A finding must have file/line evidence or a clearly stated proof, must be introduced by the current change, and must affect functionality, rule compliance, security, maintainability, or acceptance. Do not record pure style preferences, speculative concerns, pre-existing issues, or issues a linter/formatter will catch unless they block delivery.

For each Critical or Important finding, record one validation state: `validated`, `not validated`, `fixed`, or `accepted risk`. Unvalidated findings must not block Regression Verification, but must remain visible as review notes. Critical and Important validated findings must be fixed or explicitly accepted by the user before moving to Regression Verification.

Use this `Code Review Evidence` structure in the repair record:

```text
## Code Review Evidence

- Report: [Code review report](04-code-review-report.md) (`build/dev-cadence/bug-fix/<bug-slug>/04-code-review-report.md`)
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
- [ ] Confirmed problem diagnosis and repair solution sources are linked.
- [ ] Repair plan source is linked.
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

Verify the working deliverable against the problem diagnosis, repair solution, repair plan, and actual changes. Confirm the original problem is fixed and that behavior inside the stated impact scope has not regressed.

Do not claim the bug is fixed or regression-free without fresh verification evidence.

#### Verification Decision Gate

The final regression test report must record a normalized `Verification Decision`:

- `ready`: executed evidence shows the confirmed goal is satisfied and no blocking gap remains.
- `ready_with_risk`: executed evidence does not show a confirmed goal failure, but explicitly listed non-blocking skipped checks, uncovered optional areas, or residual risks remain for Business Acceptance.
- `not_ready`: an executed check failed, a confirmed goal is unmet, required evidence is inconsistent, or a blocking gap remains.

If the original bug still reproduces or a required bug-fix outcome lacks executed evidence, the decision must be `not_ready`. It must not be downgraded to `ready_with_risk`.

Only `ready` and `ready_with_risk` may enter Business Acceptance.

When the decision is `not_ready`:

1. record the blocking evidence and the earliest affected stage in the regression test report;
2. set the earliest affected stage to `in_progress` and later affected stages to `pending` in the manifest;
3. mark confirmation and verification information invalidated by the finding as `superseded` instead of treating it as current evidence;
4. update and reconfirm the affected stage records;
5. repeat implementation review and verification as required before presenting Business Acceptance again.

Historical confirmation and checkpoint information may remain for auditability, but the manifest must distinguish it from the current confirmation state.

At the end of this stage, write or update:

```text
build/dev-cadence/bug-fix/<bug-slug>/05-regression-test-report.md
```

The regression test report must use this structure:

- `Problem And Repair Sources`: diagnosis source, solution source, plan source, and repair source.
- `Test Environment`: repository, branch, date, runtime, servers, tools, and relevant configuration.
- `Test Cases`: a table with columns `ID`, `Scenario`, `Type`, `Execution`, `Result`, and `Evidence`. List every automated, manual, smoke, build, source-inspection, regression, and skipped test case that matters to the confirmed bug and impact scope.
- `Bug Fix Coverage`: map the original symptom, root cause, and repair acceptance points to test case IDs and an explicit status: `covered`, `skipped`, `not covered`, or `accepted risk`.
- `Impact Scope Coverage`: map each affected area from the Repair Solution to test case IDs and an explicit status: `covered`, `skipped`, `not covered`, or `accepted risk`.
- `Failed Or Skipped Checks`: failures and skipped checks with reasons. If none, write `None`.
- `Residual Risks`: remaining risks after testing. If none, write `None`.
- `Verification Decision`: exactly one of `ready`, `ready_with_risk`, or `not_ready`, determined by the Verification Decision Gate.
- `Recommendation`: whether the fix can enter Business Acceptance.

Coverage must be honest. If the original symptom, root cause, repair acceptance point, or affected area is not verified by an executed test or check, list it as `skipped`, `not covered`, or `accepted risk` in `Bug Fix Coverage` or `Impact Scope Coverage`; do not only mention it in `Residual Risks`.

### Business Acceptance

Superpowers does not provide a dedicated business acceptance skill. Use this Dev Cadence gate:

The same user-visible message must present the Business Acceptance summary, selection request, and all fixed numbered options. Do not split the menu across messages, replace it with a generic confirmation request, or rely on a record link to expose the choices.

Delegated continuation must not create, imply, or select a Business Acceptance or Completion decision. It applies only to explicitly delegated intermediate confirmation gates. If the fixed menu was not presented, no terminal decision exists and no acceptance record may be written.

- summarize the confirmed problem;
- summarize the root cause and repair result;
- summarize regression evidence and residual risks;
- ask the user to choose a business acceptance decision from fixed numbered options:
  1. Accept
  2. Reject
  3. Accept with residual risk
- get the business acceptor identity from the target repository's `git config user.name` and `git config user.email`; ask the user only if git identity is unavailable;
- map the user's selected number or exact option text to the normalized decision, then record the decision, decision maker, exact decision time with timezone, and accepted residual risks.

- Map `Accept` to `accepted`, record it, set the manifest overall status to `accepted`, and enter normal Completion.
- Map `Accept with residual risk` to `accepted_with_risk`; require a table of stable Risk ID, description, and owner before entering normal Completion, and preserve that table after integration.
- For `Reject`, require a rejection reason. When it identifies the earliest affected stage, record `rejected`, set that stage to `in_progress`, set later affected stages to `pending`, mark invalidated evidence `superseded`, and return there. When it does not identify a stage, remain in Business Acceptance and request clarification.
- `rejected` returns to the earliest affected stage, which becomes `in_progress`, and must not enter Completion, report success, or set `integrated`.

Do not substitute regression verification success for user acceptance.
Do not infer acceptance from ambiguous positive feedback such as "looks good", "seems fine", "looks okay", localized equivalents, or similar wording.
Only treat the response as a business acceptance decision when the user selects one of the numbered options or repeats the exact option text.
If the user's response does not clearly select one fixed option, ask the user to choose again and do not write the business acceptance record yet.

### ❓ Ambiguous Acceptance Feedback

| User says | Reality |
| --- | --- |
| "looks good" | Not an acceptance decision. Ask for one fixed option. |
| "seems fine" or "looks okay" | Not an acceptance decision. Ask for one fixed option. |
| Localized positive feedback | Not an acceptance decision. Ask for one fixed option. |
| "ship it" | Ambiguous unless it selects or repeats one fixed option. |

After the user gives the acceptance decision, write or update:

```text
build/dev-cadence/bug-fix/<bug-slug>/06-business-acceptance-record.md
```

The business acceptance record must use this structure:

- `Accepted Problem Source`: confirmed diagnosis and solution sources.
- `Regression Test Report Source`: regression test report source.
- `User Decision`: normalized decision selected from the fixed options: `accepted`, `rejected`, or `accepted_with_risk`.
- `Decision By`: target repository git identity that made the business acceptance decision, formatted as `user.name <user.email>` when both values are available.
- `Decision At`: exact decision timestamp with timezone, preferably ISO 8601 with offset.
- `Accepted Result`: brief business summary of what was accepted.
- `Accepted Residual Risks`: residual risks accepted by the user, if any.
- `Accepted Risk Register`: a table with `Risk ID`, `Description`, and `Owner`; use `None` when the decision is not `accepted_with_risk`.
- `Rejection Reason and Return Target`: the rejection reason and earliest affected stage, or `None` when the decision is not `rejected`.
- `Final Follow-Up Actions`: final follow-up actions, if any.

When the run records remain after Completion, update `Final Follow-Up Actions` with the actual final result. Record whether the branch was merged, a PR was created, or the branch was kept; also record whether any worktree was removed and whether the task branch was deleted or preserved. Do not require or attempt this update after `whole_run_discarded`. Do not leave final follow-up actions as future-tense TODOs when the manifest is in a terminal status.

## Completion

After Business Acceptance is `accepted` or `accepted_with_risk`, invoke normal Completion. For `accepted_with_risk`, preserve the original decision and `Accepted Risk Register` through integration:

The Completion menu must be presented to the user with every option actually supported by the finishing flow and its result. Delegated continuation must not select a Completion action.

```text
.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md
```

Pass this Dev Cadence context into the finishing flow:

- Business Acceptance has already been recorded as `accepted` or `accepted_with_risk`; preserve the original decision and `Accepted Risk Register` through integration.
- The business acceptance record has been written or updated.
- Ignored Dev Cadence run records under `build/dev-cadence/` may remain on disk after merge.
- Do not push unless the user explicitly asks.
- Current-run Discard context: Workflow, Task slug, Run directory, Task branch, Expected HEAD SHA, Base branch, Expected base SHA, Owned commit range, Owned tracked and untracked paths, Workspace path, and Worktree created by this run.
- Successful whole-run Discard intentionally deletes the current run records and leaves no persistent terminal record.

Completion must read `Created By Current Run`, `Workspace Path`, `Task Branch Ref`, and `Creation HEAD SHA` only from the manifest and pass the same tuple unchanged to the finishing flow. Completion must also pass the independently recorded Current-run Discard context `Workspace path` separately as the actual current workspace classification. Map manifest `Created By Current Run` directly to finishing `Worktree created by this run`; do not infer that value from the classification context. The manifest is the sole authority for the tuple; Completion must not use stage records, workspace path, or configuration as fallback evidence for it. Derive the remaining current-run Discard context from the confirmed manifest and stage records, then revalidate every value against current Git and filesystem state immediately before invoking the finishing flow. With `Created By Current Run: no`, the `not_applicable` ownership tuple must make Whole-run Discard take the conservative cleanup-verifier denial path: the verifier's `not_owned` rejection follows deny semantics, returns `discard_blocked`, and retains the worktree, task branch, and active run records. It does not authorize deletion.

Handle the normalized finishing result:

- `whole_run_discarded`: the current run directory no longer exists; do not update the manifest, Business Acceptance record, checkpoint fields, or any other run record. Do not run the terminal-record readiness checklist. Report the verified deletion result in the current conversation and stop this workflow.
- `discard_cancelled` or `discard_blocked`: retain the current run and its records, report the reason, and remain in Completion without claiming a terminal result.
- merge, pull request, or keep: update the manifest and Business Acceptance record with the final integration result, then complete the existing terminal-record readiness checklist.

Only an actual `merge` result may set manifest `Overall Status` to `integrated`. A `pull request` or `keep` result must preserve the original Business Acceptance decision as manifest `Overall Status` (`accepted` or `accepted_with_risk`) and preserve the `Accepted Risk Register`.

### Manual Recovery

Manual recovery is available only after `accepted` or `accepted_with_risk` has entered normal Completion and a verified, unrecoverable Git, branch, worktree, permission, or external-service blocker prevents Completion from continuing. A manual recovery for `accepted` or `accepted_with_risk` requires an unrecoverable blocker, a documented `Recovery Attempt`, a failed `Recovery Result`, an explanation of why normal recovery cannot continue, and explicit `User Confirmation`.

Allowed `Blocking Category` values are `git`, `branch`, `worktree`, `permission`, and `external_environment`.

Manual recovery is forbidden for `retryable_tool_failure`, `verification_failure`, `code_review_failure`, `ordinary_rework`, `incomplete_acceptance`, `user_requested_discard`, and `recoverable_completion`.

Do not use manual recovery for retryable tool failures, verification or code-review failures, ordinary rework, incomplete acceptance, discard, or recoverable Completion cases. Retain all code, branch, worktree, and run-record evidence. Mark the manifest `abandoned` only after every stage and checkpoint is terminal.

Write `build/dev-cadence/bug-fix/<bug-slug>/07-manual-recovery-record.md` before setting `abandoned`. It must contain:

- `Blocking Category`
- `Blocking Evidence`
- `Blocked Completion Action`
- `Recovery Attempt`
- `Recovery Result`
- `Why Further Recovery Is Not Viable`
- `User Confirmation`
- `Code Preservation`
- `Branch Preservation`
- `Worktree Preservation`
- `Run Record Preservation`
- `Follow-up Owner`
- `Next Step`

## Backlog Synchronization After Completion

Only a successful Completion whose normalized finishing result is exactly `merge` may synchronize the Bug Fix to the Backlog. Completion must have succeeded, including accepted Business Acceptance, before this synchronization starts. A `pull request`, `keep`, `discard_cancelled`, `discard_blocked`, or `whole_run_discarded` result must not mark the Bug `Done` and must not move it into the completed lifecycle section.

For the `merge` path, locate the existing Bug card and its Backlog row by the card's Bug ID and Version. Re-read the current card and Backlog visible facts immediately before writing. If the Bug ID, Version, title, priority, status, link, or lifecycle location conflicts with the confirmed facts, stop on the conflict and require a user decision; do not partially write either the card or Backlog.

After identity and visible-fact checks pass, perform one atomic card and Backlog write:

1. Update the Bug card `Status` to `Done`.
2. Record the repair result and integration reference on the Bug card. When this execution is an important event, append its Change Log event using the current Version; an execution-only status or delivery-reference write does not increment the confirmed requirement Version, and the same execution event must not duplicate the Change Log entry.
3. Atomically update the Backlog: remove the matching row from the active or pending lifecycle section and add that same row to the completed lifecycle section with status `Done`.

If any card or Backlog write cannot be completed against the re-read facts, perform zero partial writes and stop for a user decision. Preserve the title, Version, priority, link, and all unrelated row order in every affected table; do not recalculate or reorder unrelated work items as part of this write.

The manifest, Business Acceptance record, and follow-up evidence must record the actual sync result, including the matched Bug ID and Version, card status and repair/integration references, the source and destination lifecycle sections, or the conflict and no-write outcome. The `merge` write must be idempotent: a repeat after the same visible facts are already synchronized records the existing `Done` state without duplicating the card reference, execution Change Log entry, or Backlog row.

Before marking the run terminal, complete this readiness checklist:

- [ ] Manifest has a terminal overall status and no `pending` checkpoint commit values.
- [ ] Business acceptance record has `Final Follow-Up Actions` updated with actual past-tense results.
- [ ] Repair record has the final implementation commit hash and final changed-files state for committed changes, or `skipped: no tracked changes` when the terminal stage has no tracked changes.
- [ ] Repair record links to `04-code-review-report.md`.
- [ ] Code review report exists and all checklist items are checked or have an explicit reason.
- [ ] Regression test report records skipped checks and residual risks honestly.
- [ ] No stage record contains stale future-tense or pre-commit status that conflicts with the manifest.
- [ ] Artifact paths are repository-relative; no local absolute paths are persisted unless explicitly requested by the user.

If any checklist item is not satisfied, update the affected record before reporting Completion.

Before marking the run terminal, run:

```bash
bash .dev-cadence/workflows/using-dev-cadence/scripts/validate-delivery-record.sh build/dev-cadence/bug-fix/<bug-slug> --terminal
```

Then follow the vendored finishing skill.
