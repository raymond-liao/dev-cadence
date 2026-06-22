# Tasks

```yaml
status: executable
task_class: S1
selected_workflow: feature-dev
previous_task_class: null
task_class_change_reason: null
required_extra_gates: []
tasks:
  - id: T1
    description: Fill task artifacts for brief, requirements, design skip, tasks, and test plan.
    target_files:
      - specs/20260622-acceptance-guide/00-brief.md
      - specs/20260622-acceptance-guide/01-requirements.md
      - specs/20260622-acceptance-guide/02-design.md
      - specs/20260622-acceptance-guide/03-tasks.md
      - specs/20260622-acceptance-guide/04-test-plan.md
  - id: T2
    description: Create the Chinese acceptance guide with copyable commands and expected pass indicators.
    target_files:
      - docs/acceptance-guide.md
  - id: T3
    description: Record implementation, verification, review, and pending acceptance evidence.
    target_files:
      - specs/20260622-acceptance-guide/05-implementation.md
      - specs/20260622-acceptance-guide/06-test-report.md
      - specs/20260622-acceptance-guide/07-review-report.md
      - specs/20260622-acceptance-guide/08-acceptance.md
      - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/
  - id: T4
    description: Fix acceptance summary parsing if dogfooding reveals an acceptance-summary defect.
    target_files:
      - skills/dev-cadence/scripts/summarize-acceptance.mjs
dependencies:
  - Existing scripts must remain callable with their documented help output.
planned_components:
  - user-facing project documentation
  - Dev Cadence task artifacts
target_files:
  - docs/acceptance-guide.md
  - skills/dev-cadence/scripts/summarize-acceptance.mjs
  - specs/20260622-acceptance-guide/00-brief.md
  - specs/20260622-acceptance-guide/01-requirements.md
  - specs/20260622-acceptance-guide/02-design.md
  - specs/20260622-acceptance-guide/03-tasks.md
  - specs/20260622-acceptance-guide/04-test-plan.md
  - specs/20260622-acceptance-guide/05-implementation.md
  - specs/20260622-acceptance-guide/06-test-report.md
  - specs/20260622-acceptance-guide/07-review-report.md
  - specs/20260622-acceptance-guide/08-acceptance.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/
planned_artifact_files:
  - specs/20260622-acceptance-guide/00-brief.md
  - specs/20260622-acceptance-guide/01-requirements.md
  - specs/20260622-acceptance-guide/02-design.md
  - specs/20260622-acceptance-guide/03-tasks.md
  - specs/20260622-acceptance-guide/04-test-plan.md
  - specs/20260622-acceptance-guide/05-implementation.md
  - specs/20260622-acceptance-guide/06-test-report.md
  - specs/20260622-acceptance-guide/07-review-report.md
  - specs/20260622-acceptance-guide/08-acceptance.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/run-context.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/execution-report.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/tool-log.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/test-log.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/diff-summary.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/permission-decisions.md
forbidden_actions:
  - Change CLI argument parsing.
  - Edit skills/dev-cadence/** behavior unless verification reveals a required fix.
  - Mark final acceptance as passed without named Human confirmation.
  - Claim dry run verifies product behavior.
acceptance_mapping:
  - requirement: Chinese docs guide exists.
    evidence: docs/acceptance-guide.md
  - requirement: Correct `--mode init` command is documented.
    evidence: docs/acceptance-guide.md
  - requirement: Expected outputs and residual risks are documented.
    evidence: docs/acceptance-guide.md
  - requirement: Artifacts record dogfooding evidence.
    evidence: specs/20260622-acceptance-guide/
  - requirement: Acceptance summary must show scope reconciliation status when implementation records an object-shaped scope_reconciliation block.
    evidence: summarize-acceptance.mjs JSON assertion.
verification_plan:
  - Run package checks.
  - Run discipline route checks.
  - Run spec artifact checks on specs and templates.
  - Run git diff whitespace check.
  - Run the documented dry-run command sequence in a temporary directory.
  - Assert summarize-acceptance.mjs reports `scope_reconciliation: in_scope` for this task.
verification_coverage_matrix:
  - component: docs/acceptance-guide.md
    verification: manual read plus dry-run command sequence comparison.
  - component: specs/20260622-acceptance-guide
    verification: check-spec-artifacts.mjs specs
  - component: skills/dev-cadence/scripts/summarize-acceptance.mjs
    verification: JSON assertion for object-shaped scope_reconciliation.
  - component: skill package structure
    verification: check-skill-package.mjs and check-discipline-routes.mjs
```

## Execution Notes

No product source, application tests, migrations, CI, release files, or skill runtime behavior are planned for this task.

## Gate G3

```yaml
gate_id: G3
status: passed
required_inputs:
  - tasks
  - target_files
  - forbidden_actions
  - acceptance_mapping
  - verification_plan
evidence:
  - specs/20260622-acceptance-guide/03-tasks.md
pass_condition: Task is executable and bounded.
fail_condition: Target files or verification plan are unclear.
decision: passed
human_override: null
residual_risk: Reviewer must verify no CLI behavior change was introduced.
escalation: none
```
