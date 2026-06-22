# Brief

```yaml
task_id: 20260622-acceptance-guide
requested_by: Raymond
date: 2026-06-22
goal: Add a Chinese acceptance guide for validating the current Dev Cadence stage and dogfood Dev Cadence on the repository itself.
background: The user manually ran the proposed acceptance commands and found they passed. One command was previously documented incorrectly as a positional `init`; the stable guide must use `--mode init` and explain how to interpret dry-run evidence.
constraints:
  - Project documentation under docs/ must be Chinese.
  - Published skill package content under skills/dev-cadence/** must remain English.
  - Do not change CLI behavior in this task.
  - Do not modify product runtime behavior; this is documentation and artifact work.
initial_risks:
  - The guide could imply that dry-run acceptance verifies real product behavior.
  - The guide could repeat the incorrect positional `init` command.
  - Dogfooding artifacts could be treated as final acceptance without named Human confirmation.
assumptions:
  - The user's "run it and try" approves this small documentation dogfooding task.
  - The previous acceptance command output is sufficient evidence for the guide's expected-output examples.
open_questions: []
workflow_hint: dogfood delivery workflow
selected_workflow: feature-dev
selection_reason: The task creates a new user-facing documentation artifact and validates it through the Dev Cadence delivery path.
task_class: S1
```

## Notes

This task intentionally exercises Dev Cadence on a small real repository change. Strict TDD is not applicable because the change is a documentation guide, so substitute feedback is command verification, CLI help consistency, artifact validation, and review.

## Skipped States

```yaml
design:
  status: skipped
  reason: The requested change is a local documentation guide with no architecture, API, security, data, CI, deployment, or product behavior impact.
  residual_risk: If the acceptance workflow becomes a public CLI contract, a formal design note may be needed.
```
