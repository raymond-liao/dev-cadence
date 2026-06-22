# Brief

```yaml
task_id: 20260622-self-check-help
requested_by: Raymond
date: 2026-06-22
goal: Run a real Dev Cadence end-to-end dry run by adding --help support to the two self-check scripts.
background: The previous step added package self-check scripts. This dry run should validate specs, Harness evidence, TDD evidence, verification evidence, and review evidence on a small real change.
constraints:
  - Keep repository documentation prose in Chinese outside the shipped skill package.
  - Keep shipped skill package content in English.
  - Do not broaden package behavior beyond help output.
initial_risks:
  - Dry run may reveal missing artifact templates or unclear gate ownership.
  - Shell-script execution evidence may differ between direct executable and node invocation.
assumptions:
  - The user request "start" approves running the dry run on this repository.
  - The final acceptance still requires Raymond as named Human.
open_questions: []
workflow_hint: end-to-end validation
selected_workflow: feature-dev
selection_reason: The task adds a small user-facing behavior to existing self-check scripts and needs test-first evidence.
task_class: S1
```

## Notes

This task intentionally uses an S1 workflow even though the code change is small. The purpose is to pressure-test Dev Cadence artifacts and gates, not to minimize process.

## Skipped States

```yaml
design:
  status: skipped
  reason: The change is a local CLI behavior addition to existing scripts with no architecture, security, data, CI, production, public API, or cross-module impact.
  residual_risk: If help output later becomes a public compatibility contract, a design note may be needed.
```
