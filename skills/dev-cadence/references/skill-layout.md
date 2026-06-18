# Skill Layout

This file defines the distributable Skill package shape and the repo-local output shape created when applying the Skill to a target repository.

## Contents

- [Skill Package](#skill-package)
- [Invocation Boundary](#invocation-boundary)
- [Target Repository Layout](#target-repository-layout)
- [Initialization Rules](#initialization-rules)
- [Automatic Entrypoint](#automatic-entrypoint)
- [Initialization Source Map](#initialization-source-map)
- [Repository Rule Sync](#repository-rule-sync)
- [Generated Hard Rules](#generated-hard-rules)
- [Minimal `.ai/` File Responsibilities](#minimal-ai-file-responsibilities)
- [Versioning](#versioning)

## Skill Package

```text
dev-cadence/
  SKILL.md
  agents/
    openai.yaml
  references/
    principles.md
    supervisor-state-machine.md
    task-classes.md
    agent-blueprints.md
    workflows.md
    context-pack.md
    harness.md
    quality-gates.md
    human-gates.md
    spec-templates.md
    skill-layout.md
    repository-rule-sync.md
```

Do not add generic `README.md`, installation guide, changelog, or narrative research documents to the Skill package.

## Invocation Boundary

The system-level Skill may be selected implicitly only when the user asks to install, initialize, set up, or prepare repository-level AI-assisted delivery rules, workflows, gates, or templates. The user does not need to name `$dev-cadence` for initial setup.

Update, sync, repair, inspect, diagnose, and other maintenance modes require explicit Skill-name invocation: `$dev-cadence` or `dev-cadence`.

Do not use the system-level Skill as an implicit trigger for product implementation work, general engineering advice, maintenance requests that do not name this Skill, or repositories that have not been initialized with this framework.

After initialization, normal delivery work is handled by the target repository's root `AGENTS.md` and `.ai/control/supervisor.md`. The user should not need to invoke the Skill name again for day-to-day tasks in that repository.

## Target Repository Layout

When initializing the framework in a repository, create or update:

```text
AGENTS.md
.gitignore

.ai/
  config.yaml
  local.yaml
  dev-cadence.md
  control/
    supervisor.md
  agents/
    planner.md
    architect.md
    developer.md
    tester.md
    reviewer.md
    researcher.md
  workflows/
    feature-dev.md
    bugfix.md
    code-review.md
    refactor.md
    research-spike.md
    release.md
    incident-fix.md
  policies/
    task-classes.md
    human-gates.md
    quality-gates.md
    permission-policy.md
    context-policy.md
    escalation-policy.md
    harness-policy.md
  templates/
    context-pack.md
    run-context.md
    execution-report.md
    spec/
      00-brief.md
      01-requirements.md
      02-design.md
      03-tasks.md
      04-test-plan.md
      05-implementation.md
      06-test-report.md
      07-review-report.md
      08-acceptance.md
      run-context.md
      execution-report.md
      tool-log.md
      test-log.md
      diff-summary.md
      permission-decisions.md

specs/
  {task_id}/
    00-brief.md
    01-requirements.md
    02-design.md
    03-tasks.md
    04-test-plan.md
    05-implementation.md
    06-test-report.md
    07-review-report.md
    08-acceptance.md
    decisions/
      ADR-001.md
    runs/
      {run_id}/
        run-context.md
        execution-report.md
        tool-log.md
        test-log.md
        diff-summary.md
        permission-decisions.md
```

`AGENTS.md` activates the repo-local rules for normal Codex work. `.ai/` stores durable collaboration rules and team defaults. `specs/` stores task-specific artifacts and Harness evidence.

`.ai/config.yaml` stores team defaults:

```yaml
artifact_language: en
```

Supported `artifact_language` values are `en` and `zh`. `en` is the framework default. `zh` means Chinese prose and defaults to Simplified Chinese unless repository rules say otherwise.

`.ai/local.yaml` stores user-local overrides. Generate it with commented examples only:

```yaml
# Local Dev Cadence preferences.
# Uncomment and change this value to override generated artifact prose language for your local work.
# Supported values:
# - en: English
# - zh: Chinese, Simplified Chinese by default
# artifact_language: en
```

When `.ai/local.yaml` contains an uncommented supported `artifact_language`, it overrides `.ai/config.yaml`. Add `.ai/local.yaml` to `.gitignore` during initialization or update so user-local preferences are not committed by default.

Artifact language applies to Markdown prose, notes, acceptance criteria text, reports, and human-readable explanations. Keep filenames, paths, YAML keys, schema fields, status values, workflow IDs, gate IDs, and command/code identifiers in English for interoperability.

## Initialization Rules

- Create or update root `AGENTS.md` so normal software delivery requests automatically use `.ai/control/supervisor.md`.
- Create `.ai/config.yaml` with `artifact_language: en` unless an equivalent config already exists.
- Create `.ai/local.yaml` with commented user preference fields unless it already exists.
- Create or update `.gitignore` to include `.ai/local.yaml`, preserving existing ignore rules.
- Create `researcher.md` by default for full initialization; use it only for `research-spike` or evidence-heavy tasks.
- Create `release.md` as a placeholder workflow only.
- During initialization, synchronization, repair, or diagnosis, write only root `AGENTS.md`, root `.gitignore` entry for `.ai/local.yaml`, `.ai/**`, and `specs/.gitkeep` when needed.
- Do not modify product source, tests, migrations, build scripts, deployment files, or application configuration during framework initialization unless the user explicitly requests delivery work in the same turn.
- Do not create task-specific specs during framework initialization unless the user explicitly requests a concrete delivery task in the same turn.
- Do not infer a hidden product task from repository contents when the user asks only to prepare, initialize, apply, install, update, sync, repair, inspect, or diagnose the framework.
- If `AGENTS.md` already exists, preserve existing repository instructions and add only a scoped AI delivery entrypoint section.
- Preserve any existing `.ai/` conventions and merge carefully.
- Record local deviations from this Skill in `.ai/control/supervisor.md`.

When generating `.ai/`, read the relevant Skill references instead of inventing abbreviated policy text.

## Automatic Entrypoint

Add this section to root `AGENTS.md`, adapting wording only when the repository already has equivalent instructions:

```markdown
## AI Delivery Workflow

For software delivery tasks in this repository, follow `.ai/control/supervisor.md`.

This applies to feature development, bugfixes, refactoring, code review, research spikes, incident fixes, and any request that changes or evaluates repository behavior.

The user does not need to invoke a Skill name or choose a workflow. Infer `workflow_hint`, route `selected_workflow`, record `selection_reason`, and create task artifacts under `specs/{task_id}/` according to `.ai/` policies and templates.

Use direct execution without task specs only for explicitly trivial questions or non-delivery requests.
```

## Initialization Source Map

Use these Skill references as the source of generated repo-local files:

| Target | Source |
| --- | --- |
| `.gitignore` | `skill-layout.md` |
| `.ai/config.yaml` | `skill-layout.md` |
| `.ai/local.yaml` | `skill-layout.md` |
| `.ai/control/supervisor.md` | `supervisor-state-machine.md`, `principles.md`, `task-classes.md`, `workflows.md` |
| `.ai/agents/*.md` | `agent-blueprints.md` |
| `.ai/workflows/*.md` | `workflows.md`, strengthened by `task-classes.md` |
| `.ai/policies/task-classes.md` | `task-classes.md` |
| `.ai/policies/human-gates.md` | `human-gates.md` |
| `.ai/policies/quality-gates.md` | `quality-gates.md` |
| `.ai/policies/permission-policy.md` | `harness.md`, `human-gates.md` |
| `.ai/policies/context-policy.md` | `context-pack.md`, `principles.md` |
| `.ai/policies/escalation-policy.md` | `supervisor-state-machine.md`, `quality-gates.md`, `human-gates.md` |
| `.ai/policies/harness-policy.md` | `harness.md` |
| `.ai/templates/**` | `spec-templates.md`, `context-pack.md`, `harness.md` |
| `.ai/dev-cadence.md` | `repository-rule-sync.md`, `skill-layout.md` |

## Repository Rule Sync

After initialization, target repositories use their own root `AGENTS.md` and `.ai/**` rules for ordinary delivery work. The Skill source is used again only when the user explicitly invokes `$dev-cadence` or names `dev-cadence` for maintenance.

For update, sync, repair, inspect, or diagnose, read `repository-rule-sync.md` first. Maintenance must preserve local overlays, write only framework files, and produce the required sync report.

Generate `.ai/dev-cadence.md` as a rule sync audit record during initialization and update it during sync/update when possible. It is not runtime configuration; repo-local `AGENTS.md` and `.ai/**` remain runtime authority. If an existing repository lacks this record, treat it as inspectable and repairable; absence of the record is drift, not failure.

## Generated Hard Rules

Generated repo-local `.ai/` rules must include these hard stops:

- Keep initialization and rule maintenance separate from delivery work.
- After initialization, ordinary delivery work must follow repo-local `AGENTS.md` and `.ai/control/supervisor.md`; do not use Skill source as runtime authority.
- Update, sync, repair, inspect, and diagnose require explicit `$dev-cadence` or `dev-cadence` invocation and must follow `repository-rule-sync.md`.
- Rule maintenance must produce a sync report that lists files added, updated, preserved, conflicts, local overlays, manual review needs, and forbidden product changes avoided.
- Generated initialization logic must limit setup writes to root `AGENTS.md`, `.gitignore`, `.ai/**`, and `specs/.gitkeep` unless a same-turn user request explicitly authorizes delivery work.
- Generated initialization logic must not modify product code, tests, migrations, build scripts, deployment files, or application configuration.
- Resolve artifact prose language from uncommented `.ai/local.yaml` value, then `.ai/config.yaml`, then default `en`; support only `en` and `zh` unless local rules extend this.
- Ensure `.ai/local.yaml` is ignored by Git during initialization and maintenance.
- Keep artifact structure identifiers in English even when artifact prose language is `zh`.
- Do not infer unclear product intent. If goal, scope, non-goals, reference behavior, or acceptance has multiple reasonable interpretations, enter Human Gate `info_required` before implementation.
- Do not convert unconfirmed assumptions into scope, non-goals, tasks, or acceptance criteria.
- Require a Requirements Readiness Check before planning or implementation. It must confirm expected behavior, reference behavior, scope, non-goals, acceptance criteria, and verification approach.
- Treat broad or comparative wording such as "not as expected", "inconsistent", "same as", "match", "align", "parity", or "fix this issue" as unclear unless the expected behavior and comparison dimension are explicit.
- Before asking for clarification, perform limited read-only analysis and present candidate interpretations, evidence paths, a recommended option, and tradeoffs.
- Do not ask broad undirected clarification questions when repository inspection can produce concrete options.
- Repository evidence can support candidate interpretations, but it cannot clarify user intent or pass G1.
- Do not record repository evidence, code inspection, Supervisor, Harness, Developer, Tester, Reviewer, or an unspecified agent as `clarified_by_human`, `accepted_by_human`, or an equivalent G1 decision owner.
- If the user rejects or corrects a prior result, reopen requirements and block implementation until the correction is clarified.
- Do not pass G1 while unresolved ambiguity could materially change implementation or acceptance.
- Do not start `S2` implementation until required Human Gate approvals are recorded.
- Do not approve review when G4 is not passed or explicitly overridden by a named Human Gate.
- Do not pass G6 unless final acceptance names a Human accepter.
- Do not record Supervisor, Harness, Developer, Tester, Reviewer, or an unspecified agent as final accepter.
- Treat `partially_verified`, `not_verified`, and `blocked_by_environment` as blocked until a named Human accepts the gap.
- Require `run-context.md`, `execution-report.md`, `tool-log.md`, and `permission-decisions.md` for every Harness run.
- Require `diff-summary.md` when files change.
- Require `test-log.md` when commands or tests run.
- Do not let an `execution-report.md` summary replace missing evidence files.

## Minimal `.ai/` File Responsibilities

- `control/supervisor.md`: state machine, task classification, skipped-state policy, blocked handling.
- `config.yaml`: team default configuration, including `artifact_language`.
- `local.yaml`: ignored user-local overrides, generated with commented examples.
- `agents/*.md`: role-specific blueprint contracts.
- `workflows/*.md`: workflow sequence and required artifacts.
- `policies/task-classes.md`: classification rules and escalation.
- `policies/human-gates.md`: human decision requirements.
- `policies/quality-gates.md`: evidence and approval gates.
- `policies/permission-policy.md`: allowed, denied, and approval-required actions.
- `policies/context-policy.md`: Context Pack source priority and conflict rules.
- `policies/escalation-policy.md`: blocked-state and fix-loop escalation.
- `policies/harness-policy.md`: run context, logging, and evidence capture.
- `templates/`: reusable artifact templates.

## Versioning

Version the Skill and repo-local `.ai/` rules like code. Changes to rules, templates, or gates should be reviewed with the same care as workflow code because they affect delivery behavior.
