# Spec Templates

This file defines the artifact contract and points to the reusable template
files. Template Markdown bodies live under `templates/` and are the source of
truth for generated artifacts. Do not duplicate full template bodies here.

## Template Files

Task artifact templates:

- `templates/spec/00-brief.md`
- `templates/spec/01-requirements.md`
- `templates/spec/02-design.md`
- `templates/spec/research-report.md`
- `templates/spec/03-tasks.md`
- `templates/spec/04-test-plan.md`
- `templates/spec/05-implementation.md`
- `templates/spec/06-test-report.md`
- `templates/spec/07-review-report.md`
- `templates/spec/08-acceptance.md`

Harness run templates:

- `templates/runs/run-context.md`
- `templates/runs/pre-implementation-status.md`
- `templates/runs/execution-report.md`
- `templates/runs/tool-log.md`
- `templates/runs/test-log.md`
- `templates/runs/diff-summary.md`
- `templates/runs/permission-decisions.md`

Copy only the artifacts required by the task class, workflow, or maintenance
mode. Prefer Markdown-first artifacts with stable labels, tables, checklists,
and headings that Human reviewers can read directly. Use fenced YAML only for
legacy compatibility blocks, local config examples, or small machine-oriented
schemas. Keep evidence reproducible and path-based.

## Checks

Executable artifact and gate checks:

- `scripts/check-spec-artifacts.mjs specs/records`
- `scripts/check-gates.mjs --task-id <task_id>`
- `scripts/check-before-commit.mjs`
- `scripts/generate-spec-report.mjs --specs-dir specs/records --report-dir specs/report`

Use `scripts/check-before-commit.mjs --task-id <task_id>` only when committing
product paths that intentionally belong to an existing Dev Cadence workflow but
the workflow specs are not in the same commit candidate.

`scripts/check-gates.mjs` validates G1-G6 and Human acceptance state for one
task. `scripts/check-before-commit.mjs` validates the Git commit candidate
without creating specs. The candidate is the full dirty worktree, regardless of
staging state. Candidates outside Dev Cadence workflow scope skip G1-G6 and
Human Gate checks. Dev Cadence contract/runtime-only candidates validate the
embedded runtime. Workflow candidates validate artifact structure, artifact
language warnings as failures, G1-G6/Human acceptance, and candidate path
coverage for the corresponding task artifacts. Pending G6 blocks workflow
commit readiness.

When gate validation fails because G6 is pending, the commit-readiness output
must include a Human-facing acceptance summary and the browsable report entry,
not only the gate failure.

## HTML Report

`scripts/generate-spec-report.mjs` writes a static derived browsing view to:

- `specs/report/index.html`
- `specs/report/assets/style.css`
- `specs/report/{task_id}/index.html`
- `specs/report/{task_id}/runs/{run_id}/index.html`

The report is for summary and drill-down navigation only. Markdown artifacts
under `specs/records/` remain the source of truth for gates, review, and Human
acceptance; parsers support legacy fenced YAML fields as compatibility input.

Before asking a Human to approve final acceptance, regenerate this report and
provide `specs/report/{task_id}/index.html` as the review entry. The Human may
inspect linked raw Markdown from the report, but acceptance is still recorded in
`specs/records/{task_id}/08-acceptance.md`.

## Artifact Language

Before writing artifact prose or generated report UI, resolve
`artifact_language` from an uncommented supported
`dev_cadence.artifact_language` value in root `.dev-cadence.yaml`, then default
to `en`. Supported values are:

- `en`: English prose. This is the default.
- `zh`: Chinese prose. Use Simplified Chinese unless repository rules say
  otherwise.

`artifact_language` controls human-readable Markdown prose, notes, acceptance
criteria text, reports, explanations, and generated HTML report UI labels. Keep
template filenames, headings, YAML keys, schema fields, status values, workflow
IDs, gate IDs, command/code identifiers, and raw Markdown source views in
English or source form.

Runtime scripts must use the shared artifact language resolver rather than
duplicating `.dev-cadence.yaml` parsing. When a script generates
human-readable task artifact prose or report UI, it must honor
`artifact_language`; validators remain a backstop, not the first point where
localization drift is discovered.

## Local Config Template

`.dev-cadence.yaml` is a user-local preferences file and must be ignored by Git
during initialization or update. It is generated with commented examples:

```yaml
# Local Dev Cadence preferences.
# Uncomment and change this value to override generated artifact prose language for your local work.
# Supported values:
# - en: English
# - zh: Chinese, Simplified Chinese by default
# dev_cadence:
#   artifact_language: en
#   specs_dir: specs/records
#   report_dir: specs/report
#   implementation_discipline: default
#   verification_discipline: default
#   review_profile: normal
```

For discipline fields, `default` means Dev Cadence's built-in delivery
discipline.

## Artifact Index

Task artifacts under `specs/records/{task_id}/`:

| File | Purpose | Main gate |
|---|---|---|
| `00-brief.md` | request, goal, workflow hint, selected workflow, task class | intake/classify |
| `01-requirements.md` | scope, non-goals, acceptance criteria, ambiguity and readiness | G1 |
| `02-design.md` | chosen approach, alternatives, constraints, affected components, risks | G2 |
| `research-report.md` | research question, evidence, options, recommendation, gaps | research-spike |
| `03-tasks.md` | executable tasks, target files, forbidden actions, verification plan | G3 |
| `04-test-plan.md` | verification strategy, commands, data, environment, coverage targets | planning/test |
| `05-implementation.md` | planned/changed files, scope reconciliation, implementation notes | implementation |
| `06-test-report.md` | verification status, commands, coverage, skipped checks, residual risk | G4 |
| `07-review-report.md` | findings, severity, review decision, residual risk | G5 |
| `08-acceptance.md` | named Human acceptance, accepted scope, residual risk accepted | G6 |

Harness evidence under `specs/records/{task_id}/runs/{run_id}/`:

| File | Purpose |
|---|---|
| `run-context.md` | bounded Worker context, paths, tool policy, required evidence |
| `pre-implementation-status.md` | S1/S2 baseline and authorization before product edits |
| `execution-report.md` | Worker outputs, changed files, commands, verification status |
| `tool-log.md` | commands or tools used, outputs, errors, omissions |
| `test-log.md` | test commands, environment, results, failures, skipped checks |
| `diff-summary.md` | planned vs actual files, untracked files, behavior changes, risk notes |
| `permission-decisions.md` | permission requests, decisions, denials, residual risk |

## Required Fields

Templates may evolve, but these fields are core runtime contract fields:

- identity and routing: `task_id`, `run_id`, `selected_workflow`,
  `task_class`, `agent_role`;
- scope and planning: `goal`, `scope`, `non_goals`, `acceptance_criteria`,
  `target_files`, `forbidden_actions`, `verification_plan`;
- gate evidence: `gate_id`, `status`, `decision`, `required_inputs`,
  `evidence`, `residual_risk`;
- implementation scope reconciliation: `planned_files`, `changed_files`,
  `unplanned_changed_files`, `deleted_files`, `created_artifact_files`,
  `scope_reconciliation_status`;
- verification: `commands_run`, `tests_run`, `verification_status`,
  `skipped_checks`, `changed_component_coverage`;
- Human decisions: `accepted_by_human`, `human_accepter`,
  `human_gate_decisions`, `residual_risk_accepted`;
- Harness authorization: `implementation_authorized`, `post_hoc_backfill`,
  `post_hoc_human_override_by`.

`accepted_by_human`, `human_accepter`, `clarified_by_human`, and equivalent
decision-owner fields must name a Human. Do not record Supervisor, Harness,
Developer, Tester, Reviewer, or an unspecified agent as the final accepter.

## Pre-Implementation Baseline

For `S1` and `S2` implementation or fix runs, capture
`runs/{run_id}/pre-implementation-status.md` before the first product source,
test, migration, build, deployment, or application configuration edit.

`implementation_authorized` may be `true` only when the latest request is
reconciled, required gates are passed or explicitly overridden by a named Human,
and the planned target files cover the intended edit. If product files were
already changed before this capture, `post_hoc_backfill` must be `true` and the
affected gates remain blocked unless a named Human accepts the evidence gap in
`post_hoc_human_override_by`.

## Research Spike Exception

`research-spike` requires `research-report.md` and final Human acceptance when
the recommendation is being accepted. It does not require `04-test-plan.md`,
`05-implementation.md`, `06-test-report.md`, or `07-review-report.md` unless
the Human explicitly asks for implementation, verification, or separate review.
