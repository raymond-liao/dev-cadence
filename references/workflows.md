# Workflows

Use workflows to route a task into the right state sequence and required artifacts. Task class can strengthen any workflow.

The user does not need to choose a workflow. Supervisor infers `selected_workflow` from the request, records `selection_reason`, and treats explicit user wording such as "review this" or "handle as incident" as `workflow_hint`.

## Contents

- [Common Rules](#common-rules)
- [`feature-dev`](#feature-dev)
- [`bugfix`](#bugfix)
- [`code-review`](#code-review)
- [`refactor`](#refactor)
- [`research-spike`](#research-spike)
- [`incident-fix`](#incident-fix)
- [`release`](#release)

## Common Rules

- Start with `00-brief.md`.
- Classify task before planning.
- Record `workflow_hint`, `selected_workflow`, and `selection_reason`.
- Use the smallest workflow that preserves safety, evidence, reviewability, and handoff quality.
- Apply `delivery-disciplines.md` unless a named Human Gate records an exception.
- Define the feedback signal before implementation.
- Use strict Red-Green-Refactor for testable behavior changes.
- Reconcile actual changed files against planned target files before test, review, and acceptance.
- Use `S2` rules whenever high-risk triggers appear.
- Use Harness for Worker Agent states.
- Capture `pre-implementation-status.md` before S1/S2 product edits.
- Run `scripts/check-gates.mjs --task-id <task_id>` before claiming completion, approval, acceptance, or readiness.
- Run `scripts/check-before-commit.mjs` before creating a Git commit. Add `--task-id <task_id>` when committing product paths that intentionally belong to an existing Dev Cadence workflow but the workflow specs are not in the same candidate.
- Enforce hard stops from `SKILL.md` before implementation, review, and acceptance.
- Record skipped states and residual risk.
- End with acceptance or blocked escalation.

## Scope Reconciliation

Before `test`, `review`, and `acceptance`, compare the actual diff with `02-design.md`, `03-tasks.md`, and `05-implementation.md`.

Use both tracked and untracked file evidence. A Git diff can omit newly created untracked artifacts, generated files, or new source files, so inspect worktree status or file lists when new files are expected.

For `S1` and `S2` implementation or fix runs, `pre-implementation-status.md`
must establish the worktree baseline, authorized target files, artifact files,
and G1/G3 status before the first product edit. If the baseline is missing or
marked `post_hoc_backfill: true`, do not treat normal scope reconciliation as
complete unless a named Human Gate accepts the evidence gap.

Record in `05-implementation.md` and `runs/{run_id}/diff-summary.md`:

- files planned and changed;
- planned artifact files and created artifact files;
- tracked and untracked files observed during reconciliation;
- untracked files that belong to the task;
- files changed outside the planned target list;
- deleted files;
- affected components added during implementation;
- whether new affected components require design, task-class, Human Gate, or verification updates;
- whether the verification plan covers every affected component.

If implementation touches files, components, platforms, APIs, schemas, migrations, security, permissions, CI/CD, release, or production behavior that were not planned, stop before review until requirements/design/tasks/test plan are updated or a named Human explicitly accepts the narrowed evidence.

If the task class is strengthened during execution, record the previous class, new class, reason, required extra gates, and Human decisions needed by the new class.

## `feature-dev`

Use for new user-visible or system behavior.

Sequence:

```text
intake -> classify -> requirements -> design? -> planning -> implementation -> test -> review -> acceptance
```

Required focus:

- clear users or stakeholders;
- acceptance criteria;
- affected files or components;
- verification plan;
- test-first path for new behavior;
- affected-component verification coverage;
- regression risk;
- review decision.

Require `design` for public contracts, architecture changes, data model changes, or cross-module behavior.

## `bugfix`

Use for correcting incorrect behavior.

Sequence:

```text
intake -> classify -> requirements -> planning -> implementation -> test -> review -> acceptance
```

Required focus:

- observed behavior;
- expected behavior;
- reproduction or characterization before the fix;
- root cause when knowable;
- regression test before production changes when feasible;
- regression verification.

If reproduction is impossible, record the evidence gap and use `partially_verified` or `not_verified`.

## `code-review`

Use for reviewing an existing diff, branch, PR, or patch.

Sequence:

```text
intake -> classify -> review -> acceptance
```

Add `test` when the user asks for verification or when review depends on evidence not already present.

Required focus:

- findings first;
- severity and file references;
- missed tests or residual risk;
- decision: `approved`, `approved_with_minor_notes`, `changes_requested`, or `blocked`.

Do not rewrite code unless the user explicitly asks to fix findings.

## `refactor`

Use for structure changes intended to preserve behavior.

Sequence:

```text
intake -> classify -> requirements -> design? -> planning -> implementation -> test -> review -> acceptance
```

Required focus:

- behavior-preservation statement;
- non-goals;
- affected modules;
- characterization tests or safety checks before structural changes;
- regression tests or not-verified reason.

Require `design` for broad, cross-module, public contract, or architecture-sensitive refactors.

## `research-spike`

Use for feasibility, technical comparison, design option research, or evidence-backed recommendation.

Sequence:

```text
intake -> classify -> research -> design? -> acceptance
```

Required focus:

- question being answered;
- constraints;
- options;
- evidence;
- tradeoffs;
- recommendation;
- open questions.

Do not implement as part of a research spike unless a new delivery task is approved.

## `incident-fix`

Use for urgent production or critical failure remediation.

Sequence:

```text
intake -> classify -> triage -> emergency approval -> implementation -> smoke test -> review? -> acceptance -> post-incident backfill
```

Required focus:

- incident summary;
- user or system impact;
- suspected cause;
- minimal patch;
- rollback plan;
- smoke evidence;
- emergency Human Gate approval;
- post-incident follow-up.

Prefer minimal reversible fixes. Backfill missing normal artifacts after immediate risk is reduced.

## `release`

Release is a placeholder workflow in this first Skill version.

Use it only to document release decisions, gates, evidence requirements, or handoff needs. Do not automate release execution unless a later Skill version adds explicit platform or CI integration rules.
