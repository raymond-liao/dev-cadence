---
name: refactor
description: Use when a user asks to improve internal code structure, modularity, maintainability, testability, or dependencies without intentionally changing expected behavior in a target project.
---

# Refactor

Use this skill to run the Dev Cadence refactoring workflow.

This is a Delivery Workflow. Preserve its complete scope, implementation, and verification evidence chain under `build/dev-cadence/refactor/<refactor-slug>/` according to the shared record-model contract in `using-dev-cadence`.

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

## Generated Document References

Apply the shared document-reference rules from `document-conventions` to every Dev Cadence-managed Markdown document. Check local links in all tracked Markdown before each commit; check local links in all generated documents for the current run before Completion. Keep the complete selection, identity, lifecycle, and URI contract in the shared skill rather than duplicating it here.

## Documentation Test Boundary

Root-level `*.md` files and all files under `docs/` do not require new or updated automated tests.
Do not add or modify automated tests solely because these documentation files changed.
Run existing formatting, link, spelling, or repository checks when they apply.
If the same task changes executable behavior, test that executable behavior; do not create tests that lock human-facing documentation wording merely to manufacture a TDD RED phase.

This boundary is path-based. It does not exempt `SKILL.md`, agent instructions, machine-consumed Markdown, executable specifications, or other runtime assets stored outside the target repository root and `docs/`.

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
| Interface and data shape changes | introduce parameter object, introduce value object, encapsulate raw data, narrow internal interface, split stable and unstable internal interfaces, add compatibility adapter. |
| Dependency direction changes | remove circular dependencies, invert dependency direction, extract port/interface, introduce adapter, make implicit global state explicit. |
| Incremental migration | create new structure beside old structure, keep compatibility layer, migrate callers in small batches, run verification after each batch, delete old path only after migration evidence is complete. |

Public APIs and external data shapes must remain compatible during refactoring. Keep interface and data-shape changes internal or preserve the external contract through a compatibility adapter. If the requested outcome intentionally changes an external contract, switch that work to `feature-dev`; if it restores broken expected behavior, use `bug-fix`.

### ⚠️ Refactor Red Flags

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

Dev Cadence uses commits for engineering progress and workflow checkpoints.

Commits do not require user confirmation. User confirmation controls whether the workflow may advance to the next business stage; it does not control whether current in-scope work may be committed.

Before creating any Dev Cadence workflow commit:

1. Ensure the work is on a dedicated branch for this refactor.
2. If the current branch is not dedicated to this refactor, create or switch to a dedicated branch automatically and report the branch name.
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
| "The refactor is committed, so regression verification can happen later." | Commit timing does not relax implementation, review, Regression Verification, or Business Acceptance requirements. |

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
- final integration decision after Completion only when run records remain.
- Current-run Discard context and ownership evidence, captured during the run before Completion: Workflow, Task slug, Run directory, Task branch, Base branch, Expected HEAD SHA, Expected base SHA, Owned commit range, Owned tracked and untracked paths, Workspace path, and Worktree created by this run.

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

## Active Task Change Handling

Until Business Acceptance and Completion are finished, treat user requests about the same refactor as changes to the current workflow run.

When the user asks for a scope clarification, structural target adjustment, implementation change, baseline change, test change, review fix, or acceptance feedback that belongs to the current refactor:

- update the existing task directory under `build/dev-cadence/refactor/<refactor-slug>/`;
- update the existing stage records and manifest instead of creating a new refactor slug, workflow run, requirements document, solution document, or refactor plan document;
- if the change affects an already confirmed stage, return to the earliest affected stage, mark affected later stages as `pending` or `in_progress` in the manifest, and refresh their records before moving forward again;
- if refactor implementation has already started, update `03-refactor-plan.md` when the plan no longer matches the requested change before continuing implementation;
- preserve prior decisions and evidence in the relevant record when they still explain the task history, but make the latest confirmed scope, baseline, plan, and verification state explicit.

If the requested change introduces new behavior, changes intended behavior, or asks to fix an unrelated defect, ask whether the user wants to expand the current work into a feature or bug-fix flow, split the request into a separate task, or keep the refactor behavior-preserving.

### ⚠️ Active Task Red Flags

| Thought | Reality |
| --- | --- |
| "The user added details, so start a new refactor document." | Same-refactor changes update the current workflow run and existing records. |
| "The confirmed refactor plan is old, but keep implementing anyway." | Return to the earliest affected stage and refresh records before moving forward. |
| "This adds useful behavior, but it is small enough to stay in refactor." | Intentional behavior changes require feature scope or a separate feature task. |

## Consolidated Brainstorming Confirmation

For the brainstorming-backed Requirements Confirmation and Refactor Solution stages, this active workflow overrides the vendored brainstorming instruction to request approval after each design subsection.

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

#### Pre-Implementation Design Freshness Gate

Immediately before entering Refactor Implementation, revalidate that the confirmed requirements, Refactor Solution, and Refactor Plan still match the current refactor context.

Compare the current work item card version, confirmed requirements record, confirmed Refactor Solution record, Refactor Plan, and current code state. When present, also inspect authoritative product design, architecture, Decision, dependency state, and other sources referenced by the plan.

Record the input identities, conclusion, and evidence summary in the manifest and current plan or refactor record. The evidence must identify the card and document versions or paths used, the current branch and commit, relevant dependency state, and material repository changes since confirmation.

Classify the result:

- If the inputs remain valid, continue directly without asking the user to reconfirm unchanged content.
- If requirements, behavior baseline, refactor boundary, or acceptance criteria changed, return to the earliest affected Requirements Confirmation stage.
- If architecture, data, interface, security, or refactor-strategy assumptions changed, return to Refactor Solution.
- If only the task split, file list, order, or verification steps changed, return to Refactor Plan.
- Unrelated code changes, formatting changes, generated output, or files outside the affected boundary do not invalidate the design.

When returning to an earlier stage, mark affected later confirmation and verification evidence as superseded, set the earliest affected stage to `in_progress`, set later affected stages to `pending`, refresh and reconfirm the affected records, and block implementation until the gate passes again.

### Failure Classification And Stage Routing

Use this lifecycle for blocking failures observed during implementation, compilation or build, automated testing, Regression Verification, regression checks, or implementation-stage code review. Classify from inspectable evidence, not from the failure symptom alone.

Use exactly these canonical classifications: `implementation_bug`, `test_bug`, `environment_issue`, `unclear_requirement`, `design_conflict`, `architecture_conflict`, and `missing_dependency`.

Assign every failure a stable failure ID that remains unchanged across remediation, reruns, and reclassification. The complete failure record belongs in the stage record that observed the failure; the manifest contains only the current routing or blocking summary. Record the failure ID, evidence, classification rationale, remediation round, return target, and result. When a failure originates from code review, also record its source finding ID.

Route each classification as follows:

- `implementation_bug`: return to Refactor Implementation.
- `test_bug`: return to the test asset owner or the test-correction step within Refactor Implementation. Do not delete, skip, or weaken an effective test to hide an implementation failure. If the test asset owner is external, keep `test_bug`, record the owner and unblock conditions, and do not relabel it as `missing_dependency`.
- `unclear_requirement`: return to Requirements Confirmation, the earliest requirement stage for this workflow.
- `design_conflict`: return to Refactor Solution.
- `architecture_conflict`: return to Refactor Solution and reassess the relevant Architecture and Decision sources before reconfirming the solution.
- `environment_issue`: keep the current business stage as `blocked`, keep the overall status as `in_progress`, and record reproducible evidence plus unblock conditions. Do not report the implementation or verification as passed, failed, or ready solely because the environment is blocked.
- `missing_dependency`: return a requirement dependency to Requirements Confirmation, a solution dependency to Refactor Solution, and an execution dependency to Refactor Plan or Refactor Implementation, choosing the earliest stage that can resolve it. If the current task cannot resolve it, block the run and record the responsible owner and unblock conditions without reporting a false verification conclusion.

Do not retry the same failure without new evidence, a corrective action, or an environment change. After remediation, rerun the check associated with the stable failure ID and record exactly one failure lifecycle result: `closed`, `reclassified`, or `blocked`. These failure lifecycle results are internal record values and must not become Backlog or work-item statuses.

Only a validated blocking code review finding enters this failure lifecycle; preserve its source finding ID. Keep non-blocking or unvalidated findings in the existing code review evidence model.

When routing returns to an earlier stage, reuse the active-task rollback semantics: set the earliest affected stage to `in_progress`, set later affected stages to `pending`, mark invalidated confirmation and verification evidence as `superseded`, refresh the affected records, and obtain the confirmations required by this workflow before continuing.

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

Vendored implementation skills may create progress commits without asking. These commits do not confirm Refactor Implementation or advance the workflow.

Return control to Dev Cadence after implementation and review. Do not invoke `finishing-a-development-branch` during Refactor Implementation, even if a vendored implementation skill normally invokes it after its tasks. This active workflow overrides that terminal step; proceed to Regression Verification instead.

Follow the Superpowers code review requirements during Refactor Implementation. Fix Critical and Important findings before moving to Regression Verification, unless the user explicitly accepts the risk.

#### Executing-Plans Pre-Commit Review

This subsection applies only when `executing-plans` is selected. It governs every implementation commit created while executing the confirmed refactor plan, including plan-task commits, user-requested refactor progress commits, and final-review fix commits. The active main agent must perform this review without requiring a subagent. It does not apply to `subagent-driven-development` task commits or stage checkpoint commits.

Before the first implementation commit, capture and persist the implementation base in the refactor record:

```bash
IMPLEMENTATION_BASE_SHA=$(git rev-parse HEAD)
```

The refactor record must record the implementation base SHA before any implementation commit. Use one review unit for every commit:

- `plan-task-<n>` for a commit required by the confirmed refactor-plan task;
- `progress-<n>-<k>` for a user-requested commit before refactor-plan task `<n>` is complete;
- `final-review-fix-<k>` for commits that resolve findings from the final whole-refactor review;
- `recovery-fix-<review-id>-<k>` for a corrective commit required to close retrospective findings for `<review-id>`.

A progress unit runs checks appropriate to its staged work; the current plan task must remain `in_progress` and its checklist must not advance. A final-review fix unit cites its finding IDs and affected tasks and may cross completed-task file boundaries only to resolve those findings. A recovery-fix unit is limited to the changes required by its linked retrospective findings.

Maintain an `Executing-Plans Commit Review Ledger` in the refactor record. Each entry records the review ID and unit, commit type, state, Expected parent, Reviewed tree, staged files, checks, decision, commit hash, Committed parent, Committed tree, Identity, findings, residual risks, and separate Source finding IDs and Affected tasks fields when applicable. Allowed states are `reviewed-pending-commit` (reviewed snapshot persisted, commit not verified), `verified` (identity proven or retrospective review closed), and `recovery-required` (actual commit is not proven or its retrospective findings remain open). Identity is `pending`, `exact`, or `retrospective`.

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

3. Review the complete staged diff against the review unit, confirmed refactor requirements and solution, Behavior Baseline, refactor plan, acceptance criteria, applicable repository rules, behavior preservation and risk, required regression evidence, and scope. Fix findings, rerun relevant checks, restage, and repeat the complete gate.
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

Do not mark a refactor-plan task complete until its final plan-task entry is `verified`, its required checks pass, and its evidence is complete. A progress entry never completes a refactor-plan task.

When resuming, read `IMPLEMENTATION_BASE_SHA` and the complete ledger before continuing. Reconcile the ledger with:

```bash
git rev-list --reverse --first-parent "$IMPLEMENTATION_BASE_SHA..HEAD"
```

Before treating any history entry as unmatched, classify each first-parent commit after `IMPLEMENTATION_BASE_SHA`:

- a commit recorded in the ledger is an implementation commit;
- a commit whose hash is recorded as a stage checkpoint in the run manifest or current stage record is a recorded stage checkpoint; it does not enter the implementation ledger or require retrospective implementation review;
- any other commit is an unclassified commit; first try to reconcile it with a pending entry using the identity rules below, and require retrospective review or user clarification only when no exact pending match exists.

Verified ledger commits must appear in first-parent order, but recorded stage checkpoints may appear between them. For an exact entry, Expected parent must equal the Commit's actual immediate parent; for a retrospective entry, Committed parent must equal the actual immediate parent. Implementation commits do not need to be adjacent to one another. If a pending entry's Expected parent equals `HEAD`, no commit occurred. Continue if the index still equals its Reviewed tree. If the index differs, record why the pending snapshot was invalidated, repeat the complete gate, and replace its identity and review evidence before committing. If the direct first-parent child is a recorded stage checkpoint, the pending snapshot is stale; invalidate it and repeat the gate from the current `HEAD` after classifying later commits. Otherwise set `COMMIT_SHA` to the direct first-parent child and recompute only `COMMIT_PARENT_SHA` and `COMMITTED_TREE_SHA` for that selected commit using the last two committed-identity commands above; do not reset `COMMIT_SHA` from `HEAD`. If the parent and tree match, attach it as `verified` and `exact`. Any remaining unclassified commit requires retrospective review and `Identity: retrospective`; never fabricate pre-commit evidence. Recover a missing base only from the earliest ledger Expected parent after verifying the ordered history. Stop and ask the user for rewritten history, unexplained merges, broken ancestry, missing evidence, or ambiguous ownership; do not guess, amend, or rewrite history.

After all refactor-plan tasks have verified final entries and no entry remains pending or recovery-required, set `FINAL_IMPLEMENTATION_SHA` to the Commit hash of the latest verified implementation commit in the ledger and consolidate the ledger into `04-code-review-report.md`. The final review must cover the complete refactor range `IMPLEMENTATION_BASE_SHA..FINAL_IMPLEMENTATION_SHA`; use that range as the ancestry boundary, but exclude changes introduced only by recorded stage checkpoints from refactor findings and list those checkpoint hashes separately. Do not use `HEAD~1` for a multi-commit refactor. If reviewer subagents are available, use `requesting-code-review` for an additional final independent review. If reviewer subagents are unavailable, the active main agent must perform the final whole-refactor review and record its reviewed commit range, findings, fixes, and decision in the same report.

If the final review produces a validated finding that requires code changes, create a `final-review-fix-<k>` unit with the next unused `<k>` and tie it to the finding IDs; because one unit covers one commit, additional commits use successive values. Keep completed refactor-plan tasks closed for cross-task integration fixes. Reopen an affected task only when the finding proves that its behavior-preservation criteria or required verification were not satisfied. If the fix expands confirmed scope, do not treat it as a review fix; follow Active Task Change Handling and return to the earliest affected stage. Every final-review fix commit must pass the normal exact-identity gate. After any verified implementation commit created during final-review remediation, whether `final-review-fix` or `recovery-fix`, set `FINAL_IMPLEMENTATION_SHA` to the latest verified implementation commit and repeat the final whole-refactor review. Continue until no blocking finding remains or the user explicitly accepts the residual risk.

This gate applies only to implementation commits created while executing the confirmed refactor plan. Stage checkpoint commits remain governed by the Git Checkpoints rules. Do not mix implementation changes into a stage checkpoint commit.

#### Subagent-Driven Development

Before using `subagent-driven-development`, set:

```text
DEV_CADENCE_TASK_DIR=build/dev-cadence/refactor/<refactor-slug>
```

All SDD task briefs, implementer reports, review packages, and progress ledgers must stay under that task directory.

#### Common Implementation Rules

These common rules apply to both `executing-plans` and `subagent-driven-development`.

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

#### Verification Decision Gate

The final regression test report must record a normalized `Verification Decision`:

- `ready`: executed evidence shows the confirmed goal is satisfied and no blocking gap remains.
- `ready_with_risk`: executed evidence does not show a confirmed goal failure, but explicitly listed non-blocking skipped checks, uncovered optional areas, or residual risks remain for Business Acceptance.
- `not_ready`: an executed check failed, a confirmed goal is unmet, required evidence is inconsistent, or a blocking gap remains.

Observed behavior drift or an unmet required structural goal must be `not_ready`. It must not be downgraded to `ready_with_risk`.

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
- `Verification Decision`: exactly one of `ready`, `ready_with_risk`, or `not_ready`, determined by the Verification Decision Gate.
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

### ❓ Ambiguous Acceptance Feedback

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

When the run records remain after Completion, update `Final Follow-Up Actions` with the actual final result. Record whether the branch was merged, a PR was created, or the branch was kept; also record whether any worktree was removed and whether the task branch was deleted or preserved. Do not require or attempt this update after `whole_run_discarded`. Do not leave final follow-up actions as future-tense TODOs when the manifest is in a terminal status.

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
- Current-run Discard context: Workflow, Task slug, Run directory, Task branch, Expected HEAD SHA, Base branch, Expected base SHA, Owned commit range, Owned tracked and untracked paths, Workspace path, and Worktree created by this run.
- Successful whole-run Discard intentionally deletes the current run records and leaves no persistent terminal record.

Derive the current-run Discard context from the confirmed manifest and stage records, then revalidate every value against current Git and filesystem state immediately before invoking the finishing flow.

Handle the normalized finishing result:

- `whole_run_discarded`: the current run directory no longer exists; do not update the manifest, Business Acceptance record, checkpoint fields, or any other run record. Do not run the terminal-record readiness checklist. Report the verified deletion result in the current conversation and stop this workflow.
- `discard_cancelled` or `discard_blocked`: retain the current run and its records, report the reason, and remain in Completion without claiming a terminal result.
- merge, pull request, or keep: update the manifest and Business Acceptance record with the final integration result, then complete the existing terminal-record readiness checklist.

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
