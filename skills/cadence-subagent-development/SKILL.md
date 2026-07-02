---
name: cadence-subagent-development
description: Execute approved Dev Cadence plans with isolated Worker contexts. Use when Supervisor-selected implementation has bounded sequential tasks that benefit from fresh implementer Workers and per-task review.
---

# Cadence Subagent Development

Use this Skill when `using-dev-cadence` selects isolated sequential Worker execution for an approved implementation plan.

## Core Rule

Fresh Worker per task + file-based task brief and report + task-scoped review after each task.

This Skill coordinates bounded Worker execution. It does not route workflow, select another cadence Skill, write persistent records, mark gates complete, accept risk, commit by default, or claim final completion.

## Required References

- `../../references/execution-orchestration.md`
- `../../references/harness.md`
- `../../references/context-pack.md`
- `../../references/review-discipline.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

Use Skill-local resources only for Worker dispatch:

- `skills/cadence-subagent-development/implementer-prompt.md` for implementer Workers.
- `skills/cadence-subagent-development/task-reviewer-prompt.md` for task reviewer Workers.
- `skills/cadence-subagent-development/scripts/handoff-workspace` for local handoff scratch under `<repo-root>/build/dev-cadence/subagent-development/`.
- `skills/cadence-subagent-development/scripts/task-brief` for extracting one Markdown `Task N` section into a Worker-readable file.
- `skills/cadence-subagent-development/scripts/review-package` for creating reviewer-readable diff packages from either a commit range or `--worktree BASE`.

Load `../../references/adapters.md` only when an external Worker adapter is configured or requested.

## When to Use

Use this path only when all are true:

- an approved implementation plan exists;
- `using-dev-cadence` selected isolated sequential Worker execution;
- each task has enough files, interfaces, acceptance mapping, test/code detail, dependencies, and verification commands for a fresh Worker;
- tasks can be executed one at a time without requiring shared live context;
- the controller can review Worker reports, changed files, and verification evidence before moving on.

Do not use this path when:

- the plan is missing task-level implementation detail;
- tasks are tightly coupled enough that inline execution is safer;
- independent domains should run concurrently instead of sequentially;
- the next step is research, clarification, plan repair, or review-only work;
- the Human did not authorize implementation.

## Continuous Execution Boundary

Once execution is authorized, continue through the selected task list without asking “should I continue?” between tasks.

Stop only when:

- a Worker returns `BLOCKED` and the controller cannot resolve it with existing approved context;
- a Worker returns `NEEDS_CONTEXT` and the missing context is not already in approved artifacts or repository state;
- a review finding conflicts with the approved plan or requires a Human decision;
- verification fails and the failure cannot be fixed inside the current approved task;
- all selected tasks are implemented and reviewed.

Progress notes are fine, but do not convert routine progress into Human Gate prompts.

## Pre-Flight Plan Review

Before dispatching the first Worker:

1. Read the approved plan and Supervisor-selected execution context.
2. Extract the selected task list with exact task text, files, interfaces, acceptance mapping, implementation detail, dependencies, verification commands, expected evidence, and risks.
3. Check whether any task contradicts the plan's global constraints, approved requirements, or review rubric.
4. Check that each task is small enough for one fresh Worker and has sufficient context to avoid invention.
5. If a critical gap, contradiction, missing approval, impossible verification, or unbounded task exists, stop and return a blocker to `using-dev-cadence` instead of dispatching a Worker.

If the scan is clean, proceed without asking for confirmation.

## Context Construction

For each task, build one focused dispatch package:

- full task text or a path to it;
- Context Pack fields relevant to this task;
- Harness Run Context or artifact-ready run context fields when persistent artifacts are used;
- allowed read/write paths and forbidden actions;
- exact files to inspect first;
- task-specific acceptance criteria and non-goals;
- exact interfaces, signatures, data fields, config keys, or pseudocode from the plan;
- Supervisor-selected implementation discipline and the evidence required by that discipline;
- focused verification and neighboring checks;
- prior completed-task outputs only when this task depends on them;
- expected Worker report format.

A fresh Worker must not need chat history. Do not paste accumulated prior-task summaries into later dispatches; pass only the prior interfaces or decisions that this task actually consumes.

Prefer paths to large artifacts over copied content. Never pass secrets.

When possible, use file handoffs to keep controller context small:

- task brief: use `scripts/task-brief PLAN_FILE TASK_NUMBER [OUTFILE]` to extract one Markdown `Task N` section containing the task text, acceptance mapping, constraints, allowed paths, verification commands, and required evidence;
- implementer report: one file under `build/dev-cadence/subagent-development/` containing implementation summary, changed files, verification output, discipline evidence, skipped checks, and concerns;
- review package: use `scripts/review-package BASE HEAD [OUTFILE]` for committed ranges or `scripts/review-package --worktree BASE [OUTFILE]` for no-commit working tree review; the package contains changed files, diff, untracked text files when applicable, implementer report path, and evidence paths for the reviewer;
- local progress ledger: `build/dev-cadence/subagent-development/progress.md` is a resume map for local statuses such as `in_progress`, `needs_context`, `blocked`, `local_review_clear`, and `handoff_returned`.

These files are local coordination inputs. They are not gate completion, Human acceptance, or persistent Harness records unless the Supervisor/Harness separately records them. Never use the local progress ledger to claim done, accepted, ready, or gate-passed.

## Per-Task Loop

For each task:

1. Ensure the local handoff workspace exists with `skills/cadence-subagent-development/scripts/handoff-workspace`.
2. Generate the task brief from the approved Markdown plan with `skills/cadence-subagent-development/scripts/task-brief`.
3. Record local task progress as `in_progress` in `build/dev-cadence/subagent-development/progress.md` for resume support only.
4. Dispatch one fresh implementer Worker using `skills/cadence-subagent-development/implementer-prompt.md`, passing the task brief path and an expected implementer report path.
5. Handle Worker status before review.
6. Inspect the Worker report, changed files, and verification evidence as claims, not proof.
7. Build a focused review package with `skills/cadence-subagent-development/scripts/review-package`; use `--worktree BASE` when the task did not create commits.
8. Dispatch one read-only task reviewer Worker using `skills/cadence-subagent-development/task-reviewer-prompt.md`, passing the task brief path, implementer report path, and review package path.
9. Fix spec gaps, evidence gaps, and blocking or major quality findings inside the approved task scope, then re-review until the task reviewer reports compliant/approved, a named Human accepts residual risk, or the task is blocked.
10. Update `build/dev-cadence/subagent-development/progress.md` only with local coordination status such as `local_review_clear`, `blocked`, `needs_context`, or `handoff_returned`.
11. Return task execution status, changed files, review verdicts, verification evidence, skipped checks, residual risk, and blockers to `using-dev-cadence`/Supervisor-Harness as handoff data.
12. Move to the next task only after required implementation evidence and the task review are clear for this task.

Do not dispatch multiple implementer Workers in parallel from this Skill.

## Worker Status Handling

Treat Worker results as claims that need evidence:

- `DONE`: inspect the report and changed files, then proceed to spec compliance review.
- `DONE_WITH_CONCERNS`: read concerns before review; if they affect correctness, scope, verification, or plan fit, resolve them before review or return a blocker.
- `NEEDS_CONTEXT`: provide approved context if available; otherwise return missing context to `using-dev-cadence` for plan/artifact update or Human decision.
- `BLOCKED`: classify blocker as missing context, task size, model/tool capability, plan flaw, external dependency, or permission issue before retrying.

Never force the same Worker to retry unchanged after a real blocker. Change the context, split the task, choose an approved different execution path, or return to Supervisor.

## Review Rules

Task review is mandatory after each implementer Worker and before the next task.

The task reviewer must return both verdicts:

- spec compliance: whether the actual change matches the accepted task, constraints, and acceptance mapping;
- task quality: whether the task is well built, maintainable, verified, and safe enough to proceed.

Spec compliance checks:

- accepted requirements and acceptance criteria are implemented;
- no unaccepted behavior was added;
- planned files and interfaces match actual changes or deviations are reconciled;
- implementation report matches the actual diff and verification evidence.

Task quality checks:

- correctness, edge cases, and error handling;
- maintainability and separation of concerns;
- architecture fit and public-contract preservation;
- security, operations, migration, or compatibility risk when relevant;
- test quality and verification coverage.

Reviewer Workers are read-only. Do not let implementer self-review replace independent review. Do not move to the next task with unresolved spec issues, evidence gaps, or blocking/major quality findings unless a named Human explicitly accepts the residual risk.

## Prompt Construction Rules

Implementer dispatch must include:

- one task only;
- approved task text or task path;
- scene-setting context for where this task fits;
- allowed files and forbidden actions;
- exact test/code detail needed to avoid invention;
- Supervisor-selected implementation discipline and evidence expectations;
- verification commands and expected results;
- report format and status vocabulary.

Reviewer dispatch must include:

- task text or task path;
- global constraints binding this task;
- implementer report;
- changed files and diff/range or review package;
- verification evidence;
- explicit read-only instruction;
- the Skill-local task reviewer prompt.

Do not pre-judge findings for the reviewer. If a finding appears plan-mandated, report the conflict to `using-dev-cadence`; do not dismiss it and do not dispatch a fix that contradicts the approved plan.

## Red Flags

Stop and return a blocker when any of these appear:

- no approved implementation plan or no Supervisor-selected execution context;
- task lacks files, acceptance mapping, test/code detail, or verification commands;
- Worker asks a question that exposes missing requirements or architecture decisions;
- Worker changes files outside allowed scope;
- task brief, implementer report, review package, or local progress ledger is treated as Harness evidence, gate status, Human acceptance, or persistent record;
- Worker report lacks changed files, verification output, or required implementation-discipline evidence;
- task review is skipped, failed, or replaced by self-review;
- reviewer findings are ignored or not re-reviewed after fixes;
- same Worker is retried unchanged after `BLOCKED`;
- multiple implementer Workers are dispatched in parallel from this Skill;
- local progress is treated as gate completion, final acceptance, or persistent evidence.

## Handoff

When the selected task set finishes or blocks, return a concise handoff to `using-dev-cadence` with:

- tasks attempted and status per task;
- changed files;
- Worker statuses and concerns;
- verification commands/checks and results;
- task review verdicts, including spec compliance and task quality;
- skipped checks, unresolved findings, blockers, and residual risk;
- required Human decisions;
- recommended next state for Supervisor consideration.

Do not approve, accept, commit, mark gates complete, write persistent records, or say done/fixed/passing/ready from this Skill.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence fields produced, unresolved blockers, gate-relevant observations, and recommended next state. Do not select the next cadence Skill from here.
