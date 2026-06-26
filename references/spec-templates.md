# Spec Templates

Use these templates for task artifacts under `specs/{task_id}/`. Copy only the artifacts required by the task class, workflow, or maintenance mode.

The reusable template files live under:

- `templates/spec/00-brief.md`
- `templates/spec/01-requirements.md`
- `templates/spec/02-design.md`
- `templates/spec/03-tasks.md`
- `templates/spec/04-test-plan.md`
- `templates/spec/05-implementation.md`
- `templates/spec/06-test-report.md`
- `templates/spec/07-review-report.md`
- `templates/spec/08-acceptance.md`
- `templates/runs/run-context.md`
- `templates/runs/pre-implementation-status.md`
- `templates/runs/execution-report.md`
- `templates/runs/tool-log.md`
- `templates/runs/test-log.md`
- `templates/runs/diff-summary.md`
- `templates/runs/permission-decisions.md`

Executable artifact and gate checks:

- `scripts/check-spec-artifacts.mjs specs`
- `scripts/check-gates.mjs --task-id <task_id>`
- `scripts/check-before-commit.mjs --task-id <task_id>`
- `scripts/generate-spec-report.mjs --specs-dir specs`

Prefer YAML-like field blocks plus concise Markdown notes. Keep evidence reproducible and path-based.

`scripts/generate-spec-report.mjs` writes a static derived browsing view to
`specs/index.html`, `specs/.dev-cadence-report/style.css`,
`specs/{task_id}/index.html`, and
`specs/{task_id}/runs/{run_id}/index.html`. The report is for summary and
drill-down navigation only. Markdown/YAML artifacts remain the source of truth
for gates, review, and Human acceptance.

Before writing artifact prose, resolve `artifact_language` from an uncommented supported `dev_cadence.artifact_language` value in root `.dev-cadence.yaml`, then default to `en`. Supported values are `en` and `zh`.

`artifact_language` controls human-readable Markdown prose, notes, acceptance criteria text, reports, and explanations. Keep template filenames, headings, YAML keys, schema fields, status values, workflow IDs, gate IDs, and command/code identifiers in English.

## Contents

- [`.dev-cadence.yaml`](#dev-cadenceyaml)
- [`00-brief.md`](#00-briefmd)
- [`01-requirements.md`](#01-requirementsmd)
- [`02-design.md`](#02-designmd)
- [`03-tasks.md`](#03-tasksmd)
- [`04-test-plan.md`](#04-test-planmd)
- [`05-implementation.md`](#05-implementationmd)
- [`06-test-report.md`](#06-test-reportmd)
- [`07-review-report.md`](#07-review-reportmd)
- [`08-acceptance.md`](#08-acceptancemd)
- [`decisions/ADR-001.md`](#decisionsadr-001md)
- [`runs/{run_id}/run-context.md`](#runsrun_idrun-contextmd)
- [`runs/{run_id}/pre-implementation-status.md`](#runsrun_idpre-implementation-statusmd)
- [`runs/{run_id}/execution-report.md`](#runsrun_idexecution-reportmd)
- [`runs/{run_id}/tool-log.md`](#runsrun_idtool-logmd)
- [`runs/{run_id}/test-log.md`](#runsrun_idtest-logmd)
- [`runs/{run_id}/diff-summary.md`](#runsrun_iddiff-summarymd)
- [`runs/{run_id}/permission-decisions.md`](#runsrun_idpermission-decisionsmd)

## `.dev-cadence.yaml`

```yaml
# Local Dev Cadence preferences.
# Uncomment and change this value to override generated artifact prose language for your local work.
# Supported values:
# - en: English
# - zh: Chinese, Simplified Chinese by default
# dev_cadence:
#   artifact_language: en
#   specs_dir: specs
#   implementation_discipline: default
#   verification_discipline: default
#   review_profile: normal
```

Allowed `artifact_language` values:

- `en`: English prose. This is the default.
- `zh`: Chinese prose. Use Simplified Chinese unless repository rules say otherwise.

For discipline fields, `default` means Dev Cadence's built-in delivery discipline.

`.dev-cadence.yaml` must be ignored by Git during initialization or update. If the file contains an uncommented supported `dev_cadence.artifact_language`, it overrides the plugin default.

`scripts/check-spec-artifacts.mjs` reports warning-level findings when
`artifact_language: zh` is configured and Markdown prose appears to be
English-only. These warnings highlight localization drift; they do not fail the
structural artifact check.

`scripts/check-gates.mjs` validates G1-G6 and Human acceptance state for one
task. `scripts/check-before-commit.mjs` validates artifact structure, gate
state, artifact language warnings as failures for the selected task, and dirty
worktree path coverage before a Git commit. It requires G6 final Human
acceptance to pass; pending acceptance blocks commit readiness.

## `00-brief.md`

````markdown
# Brief

```yaml
task_id:
requested_by:
date:
goal:
background:
constraints:
initial_risks:
assumptions:
open_questions:
workflow_hint:
selected_workflow:
selection_reason:
```

## Notes

## Skipped States
````

## `01-requirements.md`

````markdown
# Requirements

```yaml
status:
goal:
scope:
non_goals:
users_or_stakeholders:
acceptance_criteria:
constraints:
assumptions:
open_questions:
human_decisions:
```

## Source Notes

## Ambiguity Check

```yaml
unresolved_ambiguity:
material_to_implementation:
clarification_required:
analysis_performed:
evidence_paths:
candidate_interpretations:
recommended_option:
clarified_by_human:
clarified_at:
decision:
```

## Requirements Readiness Check

```yaml
expected_behavior_explicit:
expected_behavior_source:
reference_behavior_explicit:
reference_behavior_source:
scope_confirmed:
non_goals_confirmed:
acceptance_criteria_confirmed:
verification_approach_confirmed:
accepted_by_human:
human_decision_reference:
ready_for_implementation:
blocking_questions:
```

## Gate G1
````

## `02-design.md`

````markdown
# Design

```yaml
status:
problem:
chosen_approach:
alternatives_considered:
architecture_constraints:
affected_components:
data_or_control_flow:
risks:
required_adrs:
human_decisions:
```

## Rationale

## Gate G2
````

## `03-tasks.md`

````markdown
# Tasks

```yaml
status:
task_class:
selected_workflow:
previous_task_class:
task_class_change_reason:
required_extra_gates:
tasks:
dependencies:
planned_components:
target_files:
forbidden_actions:
acceptance_mapping:
verification_plan:
verification_coverage_matrix:
```

## Execution Notes

## Gate G3
````

## `04-test-plan.md`

````markdown
# Test Plan

```yaml
status:
scope:
test_strategy:
test_commands:
test_data:
environment:
coverage_targets:
changed_component_coverage:
skipped_component_checks:
risks:
```

## Planned Evidence
````

## `05-implementation.md`

````markdown
# Implementation

```yaml
status:
planned_files:
changed_files:
unplanned_changed_files:
deleted_files:
added_components:
scope_reconciliation:
rationale:
implementation_notes:
tdd_or_feedback_evidence:
red_evidence:
green_evidence:
refactor_evidence:
tdd_exception:
substitute_feedback:
test_commands:
test_results:
known_limitations:
follow_up_needed:
```

## Diff Summary

## Harness Runs
````

## `06-test-report.md`

````markdown
# Test Report

```yaml
status:
verification_status:
commands_run:
environment:
results:
coverage_scope:
changed_component_coverage:
skipped_component_checks:
defects:
skipped_checks:
residual_risk:
recommendation:
```

## Evidence

## Gate G4

```yaml
gate_id: G4
status:
required_inputs:
evidence:
verification_status:
component_coverage_complete:
human_override:
residual_risk:
escalation:
```
````

## `07-review-report.md`

````markdown
# Review Report

```yaml
status:
review_scope:
evidence_reviewed:
scope_reconciliation_reviewed:
verification_coverage_reviewed:
findings:
blockers:
major_issues:
minor_notes:
security_notes:
architecture_notes:
decision:
residual_risk:
```

## Findings

Use severity values:

- `blocker`
- `major`
- `minor`
- `note`

Allowed decisions:

- `approved`
- `approved_with_minor_notes`
- `changes_requested`
- `blocked`

## Gate G5

```yaml
gate_id: G5
status:
required_inputs:
evidence:
g4_status:
scope_reconciliation_status:
verification_coverage_status:
decision:
residual_risk:
escalation:
```
````

## `08-acceptance.md`

````markdown
# Acceptance

```yaml
status:
accepted_by_human:
accepted_at:
accepted_scope:
evidence_reviewed:
human_gate_decisions:
residual_risk_accepted:
merge_or_release_decision:
follow_up:
```

## Gate G6

```yaml
gate_id: G6
status:
required_inputs:
evidence:
human_accepter:
decision:
residual_risk:
escalation:
```
````

## `decisions/ADR-001.md`

````markdown
# ADR-001: Title

```yaml
status:
date:
decision_owner:
context:
decision:
consequences:
alternatives_considered:
follow_up:
```
````

## `runs/{run_id}/run-context.md`

````markdown
# Run Context

```yaml
run_id:
task_id:
agent_role:
blueprint_path:
context_pack_path:
workspace_path:
allowed_read_paths:
allowed_write_paths:
denied_paths:
allowed_tools:
denied_tools:
network_policy:
secret_policy:
permission_policy:
budget:
timeout:
max_iterations:
required_evidence:
pre_implementation_status_path:
expected_artifacts:
log_paths:
```
````

## `runs/{run_id}/pre-implementation-status.md`

````markdown
# Pre-Implementation Status

```yaml
run_id:
task_id:
captured_at:
task_class:
selected_workflow:
implementation_state:
git_status_before:
untracked_files_before:
authorized_target_files:
authorized_artifact_files:
g1_status:
g2_status:
g3_status:
requirements_ready:
blocking_questions:
implementation_authorized:
authorization_source:
post_hoc_backfill:
post_hoc_human_override_by:
post_hoc_human_override_reason:
residual_risk:
```
````

For `S1` and `S2` implementation or fix runs, capture this file before the
first product source, test, migration, build, deployment, or application
configuration edit. `implementation_authorized` may be `true` only when the
latest request is reconciled, required gates are passed or explicitly
overridden by a named Human, and the planned target files cover the intended
edit. If product files were already changed before this capture,
`post_hoc_backfill` must be `true` and the affected gates remain blocked unless
a named Human accepts the evidence gap in `post_hoc_human_override_by`.

## `runs/{run_id}/execution-report.md`

````markdown
# Execution Report

```yaml
run_id:
task_id:
agent_role:
state:
started_at:
ended_at:
inputs:
outputs:
planned_files:
planned_artifact_files:
files_changed:
untracked_files:
created_artifact_files:
unplanned_changed_files:
deleted_files:
added_components:
pre_implementation_status_path:
implementation_authorized:
post_hoc_backfill:
scope_reconciliation_status:
commands_run:
tests_run:
verification_status:
permissions_requested:
permissions_granted:
permissions_denied:
skipped_checks:
errors:
residual_risk:
handoff_target:
```
````

## `runs/{run_id}/tool-log.md`

````markdown
# Tool Log

```yaml
run_id:
commands_or_tools:
outputs:
errors:
omissions:
```
````

## `runs/{run_id}/test-log.md`

````markdown
# Test Log

```yaml
run_id:
commands:
environment:
results:
failures:
skipped:
```
````

## `runs/{run_id}/diff-summary.md`

````markdown
# Diff Summary

```yaml
run_id:
planned_files:
planned_artifact_files:
files_changed:
untracked_files:
created_artifact_files:
unplanned_changed_files:
deleted_files:
added_components:
scope_reconciliation_status:
behavior_changes:
non_behavior_changes:
risk_notes:
```
````

## `runs/{run_id}/permission-decisions.md`

````markdown
# Permission Decisions

```yaml
run_id:
requests:
decisions:
denials:
conditions:
residual_risk:
```
````
