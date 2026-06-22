---
name: dev-cadence
description: Install or initialize Dev Cadence repository rules. Use when the user asks to install, initialize, set up, or add repository-level AGENTS.md, .ai configuration, overrides, specs, workflow rules, policies, gates, or templates for AI-assisted software delivery.
---

# Dev Cadence

## Core Rule

Use artifact-first delivery. Chat can clarify intent, but stable decisions, evidence, and acceptance must be written to artifacts under `specs/{task_id}/` or stable rules under `.ai/`.

This Skill defines the thin repo-local contract for Dev Cadence. Repository initialization must create an `AGENTS.md` entrypoint so normal software delivery requests automatically use Dev Cadence without requiring the user to invoke this Skill by name.

Use this Skill as the global installer for the current framework implementation, not as the automatic runtime for unrelated repositories. Maintenance operations are available only when the user explicitly invokes this Skill by name. Ordinary delivery work should enter this framework only after the repository has been initialized and its root `AGENTS.md` routes the request to the Dev Cadence delivery entrypoint.

It is not a platform, CI system, issue tracker, or release automation layer. Preserve the target repository's existing conventions unless they conflict with this Skill's safety rules.

## Invocation Contract

This Skill may be selected implicitly only when the user asks to install, initialize, set up, or prepare repository-level AI-assisted delivery rules, workflows, gates, or templates. The user does not need to name `$dev-cadence` for initial setup.

Use update, sync, repair, inspect, diagnose, or maintenance modes only when the user explicitly invokes `$dev-cadence` or names the skill `dev-cadence`.

Do not select this Skill for product implementation requests, framework maintenance requests that do not name this Skill, or general engineering advice. Those prompts should not install or maintain repository rules.

After initialization, ordinary delivery requests should not invoke the installer Skill. They should be routed by the target repository's root `AGENTS.md` to the configured Dev Cadence delivery entrypoint.

## Quick Start

1. Inspect repository instructions, existing docs, `AGENTS.md`, `.ai/`, and `specs/`.
2. Determine whether the user is asking to install or initialize the named framework, or whether the user explicitly invoked this Skill for maintenance.
3. For installation or initialization, apply the Initialization Boundary below, read `references/skill-layout.md`, and generate or update the repo-local Dev Cadence entrypoint and configuration.
4. For explicit Skill-name maintenance, read `references/repository-rule-sync.md`, preserve local overlays, and report or patch drift.
5. For explicit delivery-task requests in an already initialized repository, follow the repo-local `AGENTS.md` Dev Cadence entrypoint; do not require the user to choose a workflow.
6. If the repository is not initialized and the user asks only for ordinary feature, bugfix, review, refactor, research, or incident work, do not initialize this framework unless the user explicitly requests it.

## Initialization Boundary

Installation and initialization are repository-level framework operations by default. Synchronization, repair, inspection, diagnosis, and other maintenance operations are allowed only after explicit Skill-name invocation.

Allowed writes:

- root `AGENTS.md`;
- `.ai/config.yaml`, `.ai/local.yaml`, and `.ai/overrides/**`;
- `.gitignore` only to ignore `.ai/local.yaml`;
- `specs/.gitkeep` only when an empty `specs/` directory must be represented.

Forbidden writes unless the user explicitly requests delivery work in the same turn:

- product source, tests, migrations, build scripts, deployment files, or application configuration;
- task-specific directories under `specs/{task_id}/`;
- requirements, design, implementation, test, review, or acceptance artifacts for a concrete delivery task.

If a user asks only to install, initialize, or add this framework, treat that as framework setup only. For explicit Skill-name maintenance requests, treat the request as framework maintenance only. Do not infer a hidden product task from repository contents.

## Mode Routing

- **Install or initialize a repository**: apply the Initialization Boundary; read `references/skill-layout.md`; create or update `AGENTS.md`, `.ai/config.yaml`, `.ai/local.yaml`, `.ai/overrides/**`, and `specs/.gitkeep`. Do not create task specs or modify product files unless the user asks for a concrete delivery task in the same turn.
- **Explicit Skill-name maintenance**: when the user invokes `$dev-cadence` or names `dev-cadence`, read `references/repository-rule-sync.md`; inspect, synchronize, repair, or diagnose thin-contract config without touching product code.
- **Route an explicit delivery task in an initialized repository**: defer to the repo-local `AGENTS.md` Dev Cadence entrypoint; use the Skill references only to fill missing framework guidance.
- **Define or revise agent behavior**: read `references/agent-blueprints.md`.
- **Define or revise delivery discipline**: read `references/delivery-disciplines.md`.
- **Verify, review, or accept work**: read `references/quality-gates.md` and `references/human-gates.md`.
- **Resolve unclear process decisions**: read `references/principles.md`, then the narrow reference file for the current state.

Do not use this Skill as an implicit trigger for ordinary delivery work in repositories that do not contain this framework. The system-level Skill handles installation and maintenance; initialized repositories handle day-to-day execution through their own `AGENTS.md`, `.ai/config.yaml`, `.ai/overrides/**`, `specs/**`, and the configured Dev Cadence delivery entrypoint.

The user does not need to choose a workflow. Supervisor infers `selected_workflow` from the request, records `selection_reason`, and preserves any user-provided workflow preference as `workflow_hint`.

After repository initialization, the user should not need to invoke this Skill by name for normal feature, bugfix, refactor, review, research, or incident requests. The repo-local `AGENTS.md` entrypoint must direct Codex to the Dev Cadence delivery entrypoint.

## Required Practices

- Keep repository initialization separate from delivery work. Initialization creates or updates the thin repo-local contract; it must not create task specs or change product code unless the user also asks for a concrete delivery task.
- Keep context to the smallest sufficient set for the current state.
- Resolve `artifact_language` before writing task artifacts. Use `.ai/local.yaml` when it contains an uncommented supported `dev_cadence.artifact_language` value, then `.ai/config.yaml`, then default to `en`.
- Infer workflow, but do not infer unclear product intent. If goal, scope, acceptance, reference behavior, or non-goals have multiple reasonable interpretations, enter Human Gate `info_required` before implementation.
- Record assumptions and open questions separately. Do not convert an unconfirmed assumption into `scope`, `non_goals`, or `acceptance_criteria`.
- Run a Requirements Readiness Check before planning or implementation. Implementation may start only when expected behavior, reference behavior, scope, non-goals, acceptance criteria, and verification approach are explicit and source-attributed.
- Apply the built-in Dev Cadence delivery discipline for ordinary delivery work: executable planning, strict Red-Green-Refactor for testable behavior changes, reproduce-before-fix debugging, spec-compliance review before code-quality review, verification before completion claims, and conditional parallel Worker execution only for independent domains.
- When intent is unclear, perform limited read-only analysis first, then ask for confirmation with candidate interpretations, evidence paths, and a recommended option. Do not ask the user to discover the ambiguity from scratch.
- Repository evidence can support candidate interpretations, but it cannot clarify user intent or pass G1. When clarification is required, G1 needs a named Human decision that selects or defers the interpretation.
- Treat any-language wording equivalent to "not as expected", "inconsistent", "same as", "match", "align", "parity", or "fix this issue" as requiring analysis-backed clarification unless the expected behavior and comparison dimension are already explicit.
- If the user rejects or corrects a prior result, reopen requirements. Prior G1 status is invalid until the correction is recorded and ambiguity is resolved.
- Enforce a product edit barrier. Before changing product source, tests, migrations, build scripts, deployment files, or application configuration, the latest user request must be reconciled in requirements, Requirements Readiness Check must be complete, and G1 must be passed.
- Existing task specs, prior G1 records, or dirty worktree changes do not count as clarification for a new or repeated ambiguous request.
- G1 cannot pass while unresolved ambiguity affects product behavior, user-visible output, risk, or acceptance.
- Separate Supervisor, Harness, Worker Agent, Quality Gate, and Human Gate responsibilities.
- Run Worker Agent states through the Harness contract, even when the current executor is one agent. Represent this with `run-context.md`, logs, diff summaries, and execution reports.
- Record skipped states with reason and residual risk.
- Reconcile actual diffs against planned scope before review or acceptance; update artifacts when scope, components, platforms, or risk class changes.
- Limit `fix` loops to three iterations before escalation.
- Treat missing evidence as a workflow state, not approval.
- Treat incomplete verification as a blocking condition unless a named Human explicitly accepts the residual risk.
- Never let Developer declare final completion.
- Never let Supervisor, Harness, Developer, Tester, or Reviewer be recorded as final accepter.
- Ask for or record Human Gate decisions for high-risk actions, ambiguous acceptance, permission changes, destructive operations, secrets, database writes, CI changes, production actions, or release actions.

## Hard Stops

Enter `blocked` or a Human Gate before continuing when any hard stop applies:

- `S2`, `incident`, production, release, destructive, security, permission, database, CI/CD, public API, or cross-module work lacks required Human Gate approval.
- unclear product intent, scope, non-goals, reference behavior, or acceptance criteria could materially change implementation and no named Human has clarified it.
- G1 or Requirements Readiness Check attributes clarification or acceptance to repository evidence, code inspection, Supervisor, Harness, or any Worker Agent instead of a named Human when clarification was required.
- Requirements Readiness Check is missing, incomplete, or based on assumptions instead of user-confirmed intent.
- clarification asks the user an open-ended question without first presenting analyzed candidate interpretations and evidence.
- user rejects or corrects a prior implementation and requirements have not been reopened and clarified.
- product files would be changed before latest-request requirements are reconciled and G1 is passed.
- actual diff includes unplanned files, deleted files, new components, new platforms, or stronger risk triggers and scope reconciliation has not updated requirements, design, tasks, and verification plan.
- `verification_status` is `partially_verified`, `not_verified`, or `blocked_by_environment` and no named Human Gate accepts the gap.
- any changed component, platform, API, schema, migration, security, permission, CI/CD, release, or production behavior lacks matching verification or explicit skipped-check risk.
- required Harness evidence is missing: `run-context.md`, `execution-report.md`, `tool-log.md`, `diff-summary.md` for file changes, `test-log.md` for verification commands, or `permission-decisions.md`.
- Reviewer reports unresolved blocker or major findings.
- final acceptance would name Supervisor or any Worker Agent as accepter.

## Reference Map

- `references/principles.md`: non-negotiable principles and source-of-truth rules.
- `references/supervisor-state-machine.md`: states, owners, gates, transitions, fix loops, and blocked handling.
- `references/task-classes.md`: `S0`, `S1`, `S2`, `research-spike`, and `incident` classification.
- `references/agent-blueprints.md`: Planner, Architect, Developer, Tester, Reviewer, and Researcher contracts.
- `references/workflows.md`: feature development, bugfix, code review, refactor, research spike, incident fix, and release placeholder.
- `references/delivery-disciplines.md`: routing entrypoint for built-in planning, implementation, execution, debugging, review, verification, and authoring disciplines.
- `references/intent-and-design-discipline.md`: intent clarification, collaborative exploration, alternatives, design validation, and requirements readiness.
- `references/visual-companion.md`: optional browser-based visual alignment for mockups, diagrams, and visual comparisons, with text-only fallback.
- `references/planning-discipline.md`: executable task planning and plan review.
- `references/implementation-discipline.md`: strict Red-Green-Refactor for testable behavior changes.
- `references/testing-anti-patterns.md`: test and mock pitfalls to avoid during implementation.
- `references/execution-orchestration.md`: inline, sequential Worker, and parallel Worker execution rules.
- `references/debugging-discipline.md`: reproduce-before-fix debugging workflow.
- `references/root-cause-tracing.md`: trace bad values or symptoms to their origin.
- `references/condition-based-waiting.md`: replace arbitrary sleeps with condition-based waits.
- `references/defense-in-depth.md`: validate unsafe state at every relevant boundary.
- `references/review-discipline.md`: spec-compliance review before code-quality review.
- `references/verification-discipline.md`: evidence requirements before claiming fixed, passing, approved, done, or complete.
- `references/authoring-discipline.md`: Dev Cadence skill, reference, template, adapter, and policy authoring discipline.
- `references/skill-pressure-testing.md`: pressure-testing method for discipline-enforcing Skill changes.
- `references/context-pack.md`: Context Pack schema, source priority, and conflict rules.
- `references/harness.md`: Harness Run Context, evidence capture, execution report, and permission decisions.
- `references/quality-gates.md`: G1-G6 quality gates and verification status semantics.
- `references/human-gates.md`: approval, review, information, and notification gate contracts.
- `references/adapters.md`: optional Worker execution adapter selection, contracts, conflict rules, and forbidden overrides.
- `references/spec-templates.md`: task artifact templates.
- `references/skill-layout.md`: target Plugin package structure, thin repo-local contract, and `specs/` layout.
- `references/repository-rule-sync.md`: explicit maintenance, drift detection, local overlay preservation, and sync/update reporting.
- `templates/spec/`: reusable task artifact templates for brief, requirements, design, tasks, test plan, implementation, test report, review report, and acceptance.
- `templates/runs/`: reusable Harness evidence templates for run context, execution report, tool log, test log, diff summary, and permission decisions.
- `templates/prompts/`: reusable prompt templates for spec document review, plan document review, implementation, spec-compliance review, code-quality review, and general code review.
- `scripts/check-skill-package.mjs`: package validation for frontmatter, language boundary, script syntax, executable bits, and runtime Skill clutter.
- `scripts/check-discipline-routes.mjs`: route validation for discipline references, prompt templates, visual companion resources, and Reference Map entries.
- `scripts/check-spec-artifacts.mjs`: task artifact validation for duplicate YAML-like keys in fenced YAML blocks.
- `scripts/init-task-artifacts.mjs`: deterministic initialization of task and Harness run artifacts from bundled templates.
- `scripts/visual-companion/`: optional local browser companion server for visual clarification during intent and design work.

## Task ID and Run ID

Use stable lowercase IDs when the user does not provide them:

- `task_id`: `YYYYMMDD-short-slug`
- `run_id`: `YYYYMMDD-HHMM-agent-role-N`

Use the current system date and local timezone. Keep slugs short, descriptive, and safe for filenames.

## Artifact Policy

Preferred task location:

```text
specs/{task_id}/
```

If the target repository already has an approved task/spec convention, adapt to it and record the mapping in `00-brief.md` or `.ai/overrides/**`.

Artifact language controls prose in task artifacts, reports, and free-form notes. Supported values are:

- `en`: English. This is the default.
- `zh`: Chinese. Use Simplified Chinese unless repository rules say otherwise.

Keep filenames, paths, YAML keys, schema fields, status values, workflow IDs, gate IDs, and command/code identifiers in English for interoperability. Initialize `.ai/local.yaml` with commented user preferences and add `.ai/local.yaml` to `.gitignore` so users can edit it without committing personal defaults.

Minimum artifact strength by class:

- `S0`: brief, implementation notes, verification evidence or not-verified reason, acceptance.
- `S1`: requirements, tasks, implementation, test report, review report, acceptance.
- `S2`: `S1` plus design or ADR and explicit human gates.
- `research-spike`: research report, options comparison, recommendation, and open questions; no implementation unless separately approved.
- `incident`: triage, minimal patch, smoke evidence, emergency approval, and post-incident backfill.

## Completion Rule

A task is complete only when:

- required artifacts exist for the task class;
- quality gates have evidence;
- human gates are resolved or explicitly deferred;
- residual risks are recorded;
- final acceptance is written by or explicitly attributed to a named Human.
