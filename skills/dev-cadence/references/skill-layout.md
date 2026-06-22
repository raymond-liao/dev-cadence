# Skill Layout

This file defines the Dev Cadence plugin package shape and the thin repo-local output shape created when applying Dev Cadence to a target repository.

## Contents

- [Target Plugin Package](#target-plugin-package)
- [Skill Boundaries](#skill-boundaries)
- [Invocation Boundary](#invocation-boundary)
- [Thin Target Repository Layout](#thin-target-repository-layout)
- [Initialization Rules](#initialization-rules)
- [Automatic Entrypoint](#automatic-entrypoint)
- [Runtime Authority](#runtime-authority)
- [Delivery Discipline and Adapters](#delivery-discipline-and-adapters)
- [Repository Rule Maintenance](#repository-rule-maintenance)
- [Hard Rules](#hard-rules)
- [Versioning](#versioning)

## Target Plugin Package

The target distributable shape is a plugin with a small set of user-facing skills and shared plugin-owned resources:

```text
dev-cadence-plugin/
  skills/
    dev-cadence-init/
      SKILL.md
      agents/openai.yaml
    dev-cadence-deliver/
      SKILL.md
      agents/openai.yaml
    dev-cadence-maintain/
      SKILL.md
      agents/openai.yaml
    dev-cadence-authoring/
      SKILL.md
      agents/openai.yaml
  references/
    principles.md
    supervisor-state-machine.md
    task-classes.md
    agent-blueprints.md
    workflows.md
    delivery-disciplines.md
    intent-and-design-discipline.md
    visual-companion.md
    planning-discipline.md
    implementation-discipline.md
    testing-anti-patterns.md
    execution-orchestration.md
    debugging-discipline.md
    root-cause-tracing.md
    condition-based-waiting.md
    defense-in-depth.md
    review-discipline.md
    verification-discipline.md
    authoring-discipline.md
    skill-pressure-testing.md
    context-pack.md
    harness.md
    quality-gates.md
    human-gates.md
    adapters.md
    skill-layout.md
  templates/
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
    runs/
      run-context.md
      execution-report.md
      tool-log.md
      test-log.md
      diff-summary.md
      permission-decisions.md
    prompts/
      spec-document-reviewer.md
      plan-document-reviewer.md
      implementer.md
      spec-compliance-reviewer.md
      code-quality-reviewer.md
      code-reviewer.md
  scripts/
    check-skill-package.mjs
    check-discipline-routes.mjs
    check-spec-artifacts.mjs
    visual-companion/
      start-server.sh
      stop-server.sh
      server.cjs
      helper.js
      frame-template.html
```

The current first version is still packaged as:

```text
skills/dev-cadence/
  SKILL.md
  agents/openai.yaml
  skills/
    dev-cadence-init/
      SKILL.md
      agents/openai.yaml
    dev-cadence-deliver/
      SKILL.md
      agents/openai.yaml
    dev-cadence-maintain/
      SKILL.md
      agents/openai.yaml
    dev-cadence-authoring/
      SKILL.md
      agents/openai.yaml
  references/
    ...
  templates/
    spec/
      ...
    runs/
      ...
    prompts/
      ...
  scripts/
    ...
```

Treat that shape as the current transitional package. The nested entrypoint skills define the target user-facing boundaries while shared references, templates, and scripts remain in the package root until the final plugin distribution shape is introduced.

Do not add generic `README.md`, installation guide, changelog, or narrative research documents to runtime Skill folders. Keep narrative design documents in the framework repository.

## Skill Boundaries

Use this rule for modularization:

```text
Skill boundaries follow user intent.
Reference boundaries follow workflow internals.
Template boundaries follow artifact types.
Adapter boundaries follow replaceable execution disciplines.
```

Do not create one Skill per internal Supervisor state such as `requirements-gate`, `planning`, `harness-run`, `test-verification`, `review`, or `human-gate`.

Recommended user-facing skills:

- `dev-cadence-init`: initialize a repository with the thin entrypoint, project config, and artifact directories.
- `dev-cadence-deliver`: run normal delivery work after initialization.
- `dev-cadence-maintain`: inspect, sync, repair, diagnose, or upgrade Dev Cadence repository configuration.
- `dev-cadence-authoring`: maintain this framework and plugin package.

## Invocation Boundary

`dev-cadence-init` may be selected implicitly only when the user asks to install, initialize, set up, or prepare repository-level AI-assisted delivery rules, workflows, gates, or templates. The user does not need to name `$dev-cadence` for initial setup.

`dev-cadence-maintain` handles update, sync, repair, inspect, diagnose, and other maintenance modes only when the user explicitly invokes `$dev-cadence`, `dev-cadence`, or the maintenance Skill.

`dev-cadence-deliver` handles ordinary delivery work only after the repository has been initialized and its root `AGENTS.md` routes delivery work to Dev Cadence.

Do not use the initialization Skill as an implicit trigger for product implementation work, general engineering advice, maintenance requests that do not name Dev Cadence, or repositories that have not been initialized with this framework.

## Thin Target Repository Layout

For new repositories, create or update only the thin repo-local contract:

```text
AGENTS.md
.gitignore

.ai/
  config.yaml
  local.yaml
  overrides/
    .gitkeep

specs/
  .gitkeep
```

`AGENTS.md` routes normal delivery work to the Dev Cadence plugin.

`.ai/config.yaml` stores project defaults:

```yaml
dev_cadence:
  artifact_language: en
  specs_dir: specs
  implementation_discipline: default
  verification_discipline: default
  review_profile: normal
```

`default` means the built-in Dev Cadence delivery discipline in `delivery-disciplines.md`.

Supported `artifact_language` values are `en` and `zh`. `en` is the framework default. `zh` means Chinese prose and defaults to Simplified Chinese unless repository rules say otherwise.

`.ai/local.yaml` stores user-local overrides. Generate it with commented examples only:

```yaml
# Local Dev Cadence preferences.
# Uncomment and change this value to override generated artifact prose language for your local work.
# Supported values:
# - en: English
# - zh: Chinese, Simplified Chinese by default
# dev_cadence:
#   artifact_language: en
```

When `.ai/local.yaml` contains an uncommented supported `dev_cadence.artifact_language`, it overrides `.ai/config.yaml`. Add `.ai/local.yaml` to `.gitignore` during initialization or maintenance so user-local preferences are not committed by default.

`.ai/overrides/**` stores project-specific or stricter policy only. Do not copy generic framework defaults into this directory.

If persistent visual companion sessions are used, add `.dev-cadence/visual-companion/` to `.gitignore`. The visual companion remains optional and must not be required for G1.

Task artifacts and Harness evidence are written under `specs/{task_id}/`:

```text
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

Artifact language applies to Markdown prose, notes, acceptance criteria text, reports, and human-readable explanations. Keep filenames, paths, YAML keys, schema fields, status values, workflow IDs, gate IDs, and command/code identifiers in English for interoperability.

## Initialization Rules

- Create or update root `AGENTS.md` so normal software delivery requests route to Dev Cadence.
- Create `.ai/config.yaml` with `dev_cadence.artifact_language: en` and default discipline settings unless an equivalent config already exists.
- Create `.ai/local.yaml` with commented user preference fields unless it already exists.
- Create `.ai/overrides/.gitkeep` when no overrides exist.
- Create `specs/.gitkeep` when needed to represent an empty specs directory.
- Create or update `.gitignore` to include `.ai/local.yaml`, preserving existing ignore rules.
- During initialization, synchronization, repair, or diagnosis, write only root `AGENTS.md`, root `.gitignore` entry for `.ai/local.yaml`, `.ai/config.yaml`, `.ai/local.yaml`, `.ai/overrides/**`, and `specs/.gitkeep` by default.
- Do not modify product source, tests, migrations, build scripts, deployment files, or application configuration during framework initialization unless the user explicitly requests delivery work in the same turn.
- Do not create task-specific specs during framework initialization unless the user explicitly requests a concrete delivery task in the same turn.
- Do not infer a hidden product task from repository contents when the user asks only to prepare, initialize, apply, install, update, sync, repair, inspect, or diagnose the framework.
- If `AGENTS.md` already exists, preserve existing repository instructions and add only a scoped AI delivery entrypoint section.
- Preserve existing `.ai/` conventions and merge carefully. Unknown `.ai/` files are local project files unless they conflict with hard safety rules.

## Automatic Entrypoint

Add this section to root `AGENTS.md`, adapting wording only when the repository already has equivalent instructions:

```markdown
## AI Delivery Workflow

For software delivery tasks in this repository, use the Dev Cadence plugin.

This applies to feature development, bugfixes, refactoring, code review, research spikes, incident fixes, and any request that changes or evaluates repository behavior.

Read `.ai/config.yaml` and `.ai/overrides/**` when present. Write task artifacts and Harness evidence under `specs/{task_id}/`.

The user does not need to invoke a Skill name or choose a workflow. Dev Cadence infers `workflow_hint`, routes `selected_workflow`, records `selection_reason`, and follows its plugin-owned policies, templates, and gates.

Use direct execution without task specs only for explicitly trivial questions or non-delivery requests.
```

## Runtime Authority

Resolve runtime rules in this order:

1. Current user request and explicit repository instructions.
2. Repo-local `AGENTS.md`, `.ai/config.yaml`, and `.ai/overrides/**`.
3. Current task artifacts under `specs/{task_id}/`.
4. Dev Cadence plugin references, templates, built-in delivery disciplines, and adapters.
5. Configured adapters when selected.

Repo-local overlays may add stricter or project-specific constraints. They must not weaken hard safety rules such as named Human acceptance, evidence requirements, permission gates, Requirements Readiness Check, or required Harness evidence.

## Delivery Discipline and Adapters

The thin config starts with Dev Cadence defaults:

```yaml
dev_cadence:
  implementation_discipline: default
  verification_discipline: default
  review_profile: normal
```

`default` means Dev Cadence's own rules:

- clarify intent before implementation;
- create executable plans with concrete files, behavior, and verification;
- use strict Red-Green-Refactor for testable behavior changes;
- reproduce or characterize bugs before fixing;
- review spec compliance before code quality;
- verify before any completion claim;
- use parallel Worker runs only for independent domains;
- use Dev Cadence authoring validation when changing this plugin's own skills and references.

`delivery-disciplines.md` is the routing entrypoint. It maps each workflow state to the required detailed discipline reference. Task artifact templates live under `templates/spec/`, Harness evidence templates live under `templates/runs/`, and Worker and reviewer prompt templates live under `templates/prompts/`. Use these templates through the Harness when creating task artifacts or dispatching Worker runs. Package self-checks live in `scripts/check-skill-package.mjs`, `scripts/check-discipline-routes.mjs`, and `scripts/check-spec-artifacts.mjs`. Optional visual alignment uses `visual-companion.md` and `scripts/visual-companion/`; unavailability falls back to text-only clarification and does not block G1.

External adapters are optional replacement points for Worker execution techniques. Dev Cadence still controls Supervisor routing, Harness evidence, Quality Gate, Human Gate, scope reconciliation, and final acceptance.

When an adapter is selected, the stricter compatible rule wins inside that Worker state. Adapter selection must not weaken named Human acceptance, Requirements Readiness Check, permission gates, required Harness evidence, or scope reconciliation.

## Repository Rule Maintenance

Maintenance may update:

- root `AGENTS.md` AI delivery entrypoint section;
- root `.gitignore` entry for `.ai/local.yaml`;
- `.ai/config.yaml`;
- `.ai/local.yaml`;
- `.ai/overrides/.gitkeep`;
- `specs/.gitkeep`.

Maintenance must not touch product code or task-specific `specs/{task_id}/` artifacts unless the same user turn explicitly requests delivery work.

## Hard Rules

- Keep initialization and rule maintenance separate from delivery work.
- Do not infer unclear product intent. If goal, scope, non-goals, reference behavior, or acceptance has multiple reasonable interpretations, enter Human Gate `info_required` before implementation.
- Do not convert unconfirmed assumptions into scope, non-goals, tasks, or acceptance criteria.
- Require a Requirements Readiness Check before planning or implementation. It must confirm expected behavior, reference behavior, scope, non-goals, acceptance criteria, and verification approach.
- Treat broad or comparative wording such as "not as expected", "inconsistent", "same as", "match", "align", "parity", or "fix this issue" as unclear unless the expected behavior and comparison dimension are explicit.
- Before asking for clarification, perform limited read-only analysis and present candidate interpretations, evidence paths, a recommended option, and tradeoffs.
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

## Versioning

Version the Plugin, Skills, references, templates, adapters, and repo-local config like code. Changes to rules, templates, adapters, or gates should be reviewed with the same care as workflow code because they affect delivery behavior.
