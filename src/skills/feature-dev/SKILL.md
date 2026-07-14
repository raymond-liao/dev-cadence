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

## Generated Status Presentation

When writing or updating user-visible status summaries, apply the shared status presentation mapping from `document-conventions`. Use it consistently for the manifest and stage table, stage records and reports, review and test conclusions, coverage, verification, business acceptance, Completion, and user-facing progress summaries while preserving every canonical status value.

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

1. Ensure the work is on a dedicated branch for this feature or task.
2. If the current branch is not dedicated to this task, create or switch to a dedicated branch automatically and report the branch name.
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
| "The code is committed, so testing can happen later." | Commit timing does not relax implementation, review, System Testing, or Business Acceptance requirements. |

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
Use `skipped: no tracked changes` when a stage produced only ignored records and no related tracked project change.

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

### ⚠️ Active Task Red Flags

| Thought | Reality |
| --- | --- |
| "The user added details, so start a new requirements document." | Same-feature changes update the current workflow run and existing records. |
| "The confirmed plan is old, but keep implementing anyway." | Return to the earliest affected stage and refresh records before moving forward. |
| "This sounds bigger, so silently start a new task." | Ask whether to expand the current feature or start a separate task. |

## Consolidated Brainstorming Confirmation

For the brainstorming-backed Requirements Confirmation and Technical Solution stages, this active workflow overrides the vendored brainstorming instruction to request approval after each design subsection.

A clarifying question is a decision input, not a stage confirmation. An approach selection is also a decision input, not a stage confirmation.

Do not request approval after each subsection by default. Ask an additional question only when the answer materially changes the remaining requirements or design and is needed before the next part can be completed.

After required clarification and exploration, use this order:

1. Write or update the required stage record.
2. Update the manifest for that record and create or record the stage checkpoint under the Git Checkpoints rules, using `skipped: no tracked changes` when applicable.
3. Present the complete stage output in a single consolidated review that points to the written record.
4. Request one final confirmation interaction for each completed version of the stage. Make the written stage record review and the stage confirmation the same interaction; do not request another confirmation after the user approves that record.
5. After the user's decision, record the user confirmation separately in the manifest. A checkpoint commit does not count as confirmation.

If the user's response changes the proposed stage output, update the same record and repeat this order before moving to the next stage.

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

This active workflow path overrides any generic default plan path in the vendored writing-plans skill.

Ask the user to confirm the plan before implementation starts.

#### Pre-Implementation Design Freshness Gate

Immediately before entering Development Implementation, revalidate that the confirmed design and implementation plan still match the current delivery context.

Compare the current work item card version, confirmed requirements record, confirmed Technical Solution record, Implementation Plan, and current code state. When present, also inspect authoritative product design, architecture, Decision, dependency state, and other sources referenced by the plan.

Record the input identities, conclusion, and evidence summary in the manifest and current plan or implementation record. The evidence must identify the card and document versions or paths used, the current branch and commit, relevant dependency state, and material repository changes since confirmation.

Classify the result:

- If the inputs remain valid, continue directly without asking the user to reconfirm unchanged content.
- If requirements, scope, or acceptance criteria changed, return to the earliest affected Requirements Confirmation stage.
- If architecture, data, interface, security, or delivery-strategy assumptions changed, return to Technical Solution.
- If only the task split, file list, order, or verification steps changed, return to Implementation Plan.
- Unrelated code changes, formatting changes, generated output, or files outside the affected boundary do not invalidate the design.

When returning to an earlier stage, mark affected later confirmation and verification evidence as superseded, set the earliest affected stage to `in_progress`, set later affected stages to `pending`, refresh and reconfirm the affected records, and block implementation until the gate passes again.

### Failure Classification And Stage Routing

Use this lifecycle for blocking failures observed during implementation, compilation or build, automated testing, System Testing, regression checks, or implementation-stage code review. Classify from inspectable evidence, not from the failure symptom alone.

Use exactly these canonical classifications: `implementation_bug`, `test_bug`, `environment_issue`, `unclear_requirement`, `design_conflict`, `architecture_conflict`, and `missing_dependency`.

Assign every failure a stable failure ID that remains unchanged across remediation, reruns, and reclassification. The complete failure record belongs in the stage record that observed the failure; the manifest contains only the current routing or blocking summary. Record the failure ID, evidence, classification rationale, remediation round, return target, and result. When a failure originates from code review, also record its source finding ID.

Route each classification as follows:

- `implementation_bug`: return to Development Implementation.
- `test_bug`: return to the test asset owner or the test-correction step within Development Implementation. Do not delete, skip, or weaken an effective test to hide an implementation failure. If the test asset owner is external, keep `test_bug`, record the owner and unblock conditions, and do not relabel it as `missing_dependency`.
- `unclear_requirement`: return to Requirements Confirmation, the earliest requirement stage for this workflow.
- `design_conflict`: return to Technical Solution.
- `architecture_conflict`: return to Technical Solution and reassess the relevant Architecture and Decision sources before reconfirming the solution.
- `environment_issue`: keep the current business stage as `blocked`, keep the overall status as `in_progress`, and record reproducible evidence plus unblock conditions. Do not report the implementation or verification as passed, failed, or ready solely because the environment is blocked.
- `missing_dependency`: return a requirement dependency to Requirements Confirmation, a solution dependency to Technical Solution, and an execution dependency to Implementation Plan or Development Implementation, choosing the earliest stage that can resolve it. If the current task cannot resolve it, block the run and record the responsible owner and unblock conditions without reporting a false verification conclusion.

Do not retry the same failure without new evidence, a corrective action, or an environment change. After remediation, rerun the check associated with the stable failure ID and record exactly one failure lifecycle result: `closed`, `reclassified`, or `blocked`. These failure lifecycle results are internal record values and must not become Backlog or work-item statuses.

Only a validated blocking code review finding enters this failure lifecycle; preserve its source finding ID. Keep non-blocking or unvalidated findings in the existing code review evidence model.

When routing returns to an earlier stage, reuse the active-task rollback semantics: set the earliest affected stage to `in_progress`, set later affected stages to `pending`, mark invalidated confirmation and verification evidence as `superseded`, refresh the affected records, and obtain the confirmations required by this workflow before continuing.

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

Vendored implementation skills may create progress commits without asking. These commits do not confirm Development Implementation or advance the workflow.

Return control to Dev Cadence after implementation and review. Do not invoke `finishing-a-development-branch` during Development Implementation, even if a vendored implementation skill normally invokes it after its tasks. This active workflow overrides that terminal step; proceed to System Testing instead.

Follow the Superpowers code review requirements during Development Implementation: review after each subagent-driven task, review after major feature completion, and review before merge. Fix Critical and Important findings before moving to System Testing, unless the user explicitly accepts the risk.

#### Executing-Plans Pre-Commit Review

This subsection applies only when `executing-plans` is selected. It governs every implementation commit created while executing the confirmed plan, including plan-task commits, user-requested implementation progress commits, and final-review fix commits. The active main agent must perform this review without requiring a subagent. It does not apply to `subagent-driven-development` task commits or stage checkpoint commits.

Before the first implementation commit, capture and persist the implementation base in the implementation record:

```bash
IMPLEMENTATION_BASE_SHA=$(git rev-parse HEAD)
```

The implementation record must record the implementation base SHA before any implementation commit. Use one review unit for every commit:

- `plan-task-<n>` for a commit required by the confirmed plan task;
- `progress-<n>-<k>` for a user-requested commit before plan task `<n>` is complete;
- `final-review-fix-<k>` for commits that resolve findings from the final whole-implementation review;
- `recovery-fix-<review-id>-<k>` for a corrective commit required to close retrospective findings for `<review-id>`.

A progress unit runs checks appropriate to its staged work; the current plan task must remain `in_progress` and its checklist must not advance. A final-review fix unit cites its finding IDs and affected tasks and may cross completed-task file boundaries only to resolve those findings. A recovery-fix unit is limited to the changes required by its linked retrospective findings.

Maintain an `Executing-Plans Commit Review Ledger` in the implementation record. Each entry records the review ID and unit, commit type, state, Expected parent, Reviewed tree, staged files, checks, decision, commit hash, Committed parent, Committed tree, Identity, findings, residual risks, and separate Source finding IDs and Affected tasks fields when applicable. Allowed states are `reviewed-pending-commit` (reviewed snapshot persisted, commit not verified), `verified` (identity proven or retrospective review closed), and `recovery-required` (actual commit is not proven or its retrospective findings remain open). Identity is `pending`, `exact`, or `retrospective`.

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

3. Review the complete staged diff against the review unit, confirmed requirements and solution, implementation plan, acceptance criteria, applicable repository rules, correctness and risk, required test evidence, and scope. Fix findings, rerun relevant checks, restage, and repeat the complete gate.
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

Do not mark a plan task complete until its final plan-task entry is `verified`, its required checks pass, and its evidence is complete. A progress entry never completes a plan task.

When resuming, read `IMPLEMENTATION_BASE_SHA` and the complete ledger before continuing. Reconcile the ledger with:

```bash
git rev-list --reverse --first-parent "$IMPLEMENTATION_BASE_SHA..HEAD"
```

Before treating any history entry as unmatched, classify each first-parent commit after `IMPLEMENTATION_BASE_SHA`:

- a commit recorded in the ledger is an implementation commit;
- a commit whose hash is recorded as a stage checkpoint in the run manifest or current stage record is a recorded stage checkpoint; it does not enter the implementation ledger or require retrospective implementation review;
- any other commit is an unclassified commit; first try to reconcile it with a pending entry using the identity rules below, and require retrospective review or user clarification only when no exact pending match exists.

Verified ledger commits must appear in first-parent order, but recorded stage checkpoints may appear between them. For an exact entry, Expected parent must equal the Commit's actual immediate parent; for a retrospective entry, Committed parent must equal the actual immediate parent. Implementation commits do not need to be adjacent to one another. If a pending entry's Expected parent equals `HEAD`, no commit occurred. Continue if the index still equals its Reviewed tree. If the index differs, record why the pending snapshot was invalidated, repeat the complete gate, and replace its identity and review evidence before committing. If the direct first-parent child is a recorded stage checkpoint, the pending snapshot is stale; invalidate it and repeat the gate from the current `HEAD` after classifying later commits. Otherwise set `COMMIT_SHA` to the direct first-parent child and recompute only `COMMIT_PARENT_SHA` and `COMMITTED_TREE_SHA` for that selected commit using the last two committed-identity commands above; do not reset `COMMIT_SHA` from `HEAD`. If the parent and tree match, attach it as `verified` and `exact`. Any remaining unclassified commit requires retrospective review and `Identity: retrospective`; never fabricate pre-commit evidence. Recover a missing base only from the earliest ledger Expected parent after verifying the ordered history. Stop and ask the user for rewritten history, unexplained merges, broken ancestry, missing evidence, or ambiguous ownership; do not guess, amend, or rewrite history.

After all plan tasks have verified final entries and no entry remains pending or recovery-required, set `FINAL_IMPLEMENTATION_SHA` to the Commit hash of the latest verified implementation commit in the ledger and consolidate the ledger into `04-code-review-report.md`. The final review must cover the complete implementation range `IMPLEMENTATION_BASE_SHA..FINAL_IMPLEMENTATION_SHA`; use that range as the ancestry boundary, but exclude changes introduced only by recorded stage checkpoints from implementation findings and list those checkpoint hashes separately. Do not use `HEAD~1` for a multi-commit implementation. If reviewer subagents are available, use `requesting-code-review` for an additional final independent review. If reviewer subagents are unavailable, the active main agent must perform the final whole-implementation review and record its reviewed commit range, findings, fixes, and decision in the same report.

If the final review produces a validated finding that requires code changes, create a `final-review-fix-<k>` unit with the next unused `<k>` and tie it to the finding IDs; because one unit covers one commit, additional commits use successive values. Keep completed plan tasks closed for cross-task integration fixes. Reopen an affected task only when the finding proves that its acceptance criteria or required verification were not satisfied. If the fix expands confirmed scope, do not treat it as a review fix; follow Active Task Change Handling and return to the earliest affected stage. Every final-review fix commit must pass the normal exact-identity gate. After any verified implementation commit created during final-review remediation, whether `final-review-fix` or `recovery-fix`, set `FINAL_IMPLEMENTATION_SHA` to the latest verified implementation commit and repeat the final whole-implementation review. Continue until no blocking finding remains or the user explicitly accepts the residual risk.

This gate applies only to implementation commits created while executing the confirmed plan. Stage checkpoint commits remain governed by the Git Checkpoints rules. Do not mix implementation changes into a stage checkpoint commit.

#### Subagent-Driven Development

Before using `subagent-driven-development`, set:

```text
DEV_CADENCE_TASK_DIR=build/dev-cadence/feature-dev/<feature-slug>
```

All SDD task briefs, implementer reports, review packages, and progress ledgers must stay under that task directory.

#### Common Implementation Rules

These common rules apply to both `executing-plans` and `subagent-driven-development`.

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

#### Verification Decision Gate

The final system test report must record a normalized `Verification Decision`:

- `ready`: executed evidence shows the confirmed goal is satisfied and no blocking gap remains.
- `ready_with_risk`: executed evidence does not show a confirmed goal failure, but explicitly listed non-blocking skipped checks, uncovered optional areas, or residual risks remain for Business Acceptance.
- `not_ready`: an executed check failed, a confirmed goal is unmet, required evidence is inconsistent, or a blocking gap remains.

A required acceptance criterion without executed evidence must be `not_ready`. It must not be downgraded to `ready_with_risk`.

Only `ready` and `ready_with_risk` may enter Business Acceptance.

When the decision is `not_ready`:

1. record the blocking evidence and the earliest affected stage in the system test report;
2. set the earliest affected stage to `in_progress` and later affected stages to `pending` in the manifest;
3. mark confirmation and verification information invalidated by the finding as `superseded` instead of treating it as current evidence;
4. update and reconfirm the affected stage records;
5. repeat implementation review and verification as required before presenting Business Acceptance again.

Historical confirmation and checkpoint information may remain for auditability, but the manifest must distinguish it from the current confirmation state.

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
- `Verification Decision`: exactly one of `ready`, `ready_with_risk`, or `not_ready`, determined by the Verification Decision Gate.
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

### ❓ Ambiguous Acceptance Feedback

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
