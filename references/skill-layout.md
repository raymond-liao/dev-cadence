# Skill Layout

Use this reference when maintaining Dev Cadence runtime package boundaries and
resource ownership. It is an index, not the full repository sync contract.
Repository initialization and repair rules live in `repository-rule-sync.md`;
artifact schemas live in `spec-templates.md`; workflow behavior lives in the
workflow and discipline references.

## Package Shape

The source plugin package contains:

```text
dev-cadence/
  .codex-plugin/
  skills/
  references/
  templates/
  scripts/
```

The repo-embedded target runtime contains:

```text
.dev-cadence/
  VERSION
  manifest.json
  skills/
  references/
  templates/
  scripts/
```

Target repositories also keep a thin root contract:

```text
AGENTS.md
.gitignore
.dev-cadence.yaml
specs/records/.gitkeep
```

`AGENTS.md` routes normal delivery work to
`.dev-cadence/skills/using-dev-cadence/SKILL.md`. `.dev-cadence.yaml` stores
user-local overrides and is ignored by Git by default. Task artifacts and
Harness evidence are written under `specs/records/{task_id}/`; generated HTML
reports live under `specs/report/`.

## Skill Boundaries

Use this rule for modularization:

```text
Bootstrap owns Supervisor routing and discipline sequencing.
Skill boundaries follow agent work actions and delivery disciplines.
Reference boundaries follow workflow internals and governance protocols.
Template boundaries follow artifact types.
Adapter boundaries follow replaceable execution techniques.
```

Do not create one Skill per internal Supervisor state such as
`requirements-gate`, `planning-gate`, `harness-run`, `quality-gate`, or
`human-gate`. Supervisor, Harness, Quality Gate, Human Gate, Context Pack,
artifact schema, and task class policy are shared references, not user-facing
Skills.

Published Skills:

- `using-dev-cadence`: Supervisor entrypoint and discipline router.
- `cadence-clarify`: clarify goal, scope, expected behavior, non-goals, design,
  acceptance, and verification before implementation.
- `cadence-plan`: turn clarified requirements and design into executable tasks
  and verification steps.
- `cadence-research`: run research spikes without implementing product changes.
- `cadence-executing-plans`: execute an approved plan through Harness evidence.
- `cadence-subagent-development`: execute approved bounded tasks with fresh
  Worker contexts and per-task review checkpoints.
- `cadence-dispatch-parallel`: dispatch parallel Workers for independent
  problem domains and integrate results.
- `cadence-tdd`: apply Red-Green-Refactor for testable behavior changes.
- `cadence-debug`: diagnose bugs, incidents, failing tests, regressions, and
  unclear root cause.
- `cadence-request-code-review`: review implementation for spec compliance and code
  quality.
- `cadence-code-review`: verify and address existing code review feedback, then request
  code re-review; non-code feedback returns to Supervisor routing.
- `cadence-verify`: verify evidence, scope, skipped checks, residual risk, and
  Human acceptance before completion.
- `cadence-sync`: initialize, inspect, sync, repair, or diagnose the
  repo-embedded repository contract.

Every concrete cadence Skill must run under `using-dev-cadence` Supervisor
control. If selected directly, it must first enter `using-dev-cadence` so
workflow state, task class, gates, and evidence requirements are established.
When a concrete Skill finishes, it returns evidence produced, unresolved
blockers, gate status, and recommended next state to `using-dev-cadence`.

## Runtime References

Runtime references are shared workflow rules used by target repositories:

- `principles.md`
- `supervisor-state-machine.md`
- `task-classes.md`
- `workflows.md`
- `delivery-disciplines.md`
- `intent-and-design-discipline.md`
- `planning-discipline.md`
- `implementation-discipline.md`
- `execution-orchestration.md`
- `review-discipline.md`
- `verification-discipline.md`
- `context-pack.md`
- `harness.md`
- `agent-blueprints.md`
- `quality-gates.md`
- `human-gates.md`
- `repository-rule-sync.md`
- `spec-templates.md`
- `adapters.md`
- `skill-layout.md`

Source-maintenance references under `references/source-maintenance/` are for
changing Dev Cadence itself. They are part of the source plugin package but are
excluded from the repo-embedded target runtime.

The full test-first implementation workflow lives in
`skills/cadence-tdd/SKILL.md`. `implementation-discipline.md` remains the shared
implementation evidence and exception contract used by runtime workflow states.
Test anti-pattern guidance lives beside that Skill in
`skills/cadence-tdd/testing-anti-patterns.md`.
The full debugging workflow and debugging-specific techniques live in
`skills/cadence-debug/SKILL.md` and its Skill-local resources.
The full completion verification workflow lives in
`skills/cadence-verify/SKILL.md`. `verification-discipline.md` remains the
shared claim and gate contract used by runtime workflow states.

## Runtime Authority

Resolve runtime rules in this order:

1. Current user request and explicit repository instructions.
2. Repo-local `AGENTS.md` and `.dev-cadence.yaml`.
3. Current task artifacts under `specs/records/{task_id}/`.
4. Repo-embedded `.dev-cadence/` references, templates, built-in delivery
   disciplines, and adapters.
5. Configured adapters when selected.

Repo-local overlays may add stricter or project-specific constraints. They must
not weaken hard safety rules such as named Human acceptance, evidence
requirements, permission gates, Requirements Readiness Check, or required
Harness evidence.

## Resource Boundaries

Task artifact templates live under `templates/spec/`. Harness evidence
templates live under `templates/runs/`. Skill-specific resources, such as
`skills/cadence-clarify/visual-companion.md`,
`skills/cadence-clarify/spec-document-reviewer-prompt.md`,
`skills/cadence-request-code-review/code-reviewer.md`, and
`skills/cadence-clarify/scripts/`, live with the owning Skill. Debugging
techniques such as `skills/cadence-debug/root-cause-tracing.md`,
`skills/cadence-debug/condition-based-waiting.md`, and
`skills/cadence-debug/defense-in-depth.md` are Skill-local resources, not
global runtime references.

`delivery-disciplines.md` is the routing entrypoint for detailed discipline
references. `scripts/check-skill-package.mjs`,
`scripts/check-discipline-routes.mjs`, `scripts/check-spec-artifacts.mjs`,
`scripts/check-gates.mjs`, and `scripts/check-before-commit.mjs` provide source
and runtime validation. `scripts/generate-spec-report.mjs` generates a static
HTML browsing view under `specs/report/` from Markdown/YAML artifacts under
`specs/records/`; Markdown/YAML artifacts remain authoritative.

## Versioning

Version the Plugin, Skills, references, templates, adapters, and repo-local
config like code. Changes to rules, templates, adapters, or gates should be
reviewed with the same care as workflow code because they affect delivery
behavior.

Use the version in `.codex-plugin/plugin.json` as the Plugin package version.
Until the maintainer explicitly declares a formal public release, keep the major
version at `0`.

Version update rules:

- patch (`0.x.y -> 0.x.y+1`): fixes, documentation corrections, packaging
  fixes, tests, or behavior-preserving cleanup;
- minor (`0.x.y -> 0.x+1.0`): compatible new Skills, references, templates,
  scripts, workflow capabilities, or user-visible behavior;
- pre-1.0 breaking change (`0.x.y -> 0.x+1.0`): incompatible workflow,
  artifact, config, Skill, or package behavior before formal release. Document
  the incompatibility in the release notes or commit body;
- major (`1.0.0+`): only after the maintainer explicitly says Dev Cadence is
  ready for a formal public release.

Do not bump the Plugin version merely because local development commits exist.
Bump it when preparing a release package, an installable handoff, or when the
maintainer explicitly requests a version update.
