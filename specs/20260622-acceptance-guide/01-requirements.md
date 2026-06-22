# Requirements

```yaml
status: ready_for_implementation
goal: Add a Chinese acceptance guide that lets Raymond validate the current Dev Cadence stage without relying on chat history.
scope:
  - Create docs/acceptance-guide.md.
  - Include the current stage scope R1-R7.
  - Include core validation commands.
  - Include the minimal dry-run flow using `sync-repo-contract.mjs --mode init`.
  - Explain expected acceptance summary fields.
  - Explain that dry-run evidence does not verify product behavior.
  - Record this dogfooding task under specs/20260622-acceptance-guide.
non_goals:
  - Change CLI argument style.
  - Add subcommand aliases.
  - Change Dev Cadence skill package behavior.
  - Implement a real login feature.
  - Mark this dogfooding task finally accepted without named Human confirmation.
users_or_stakeholders:
  - Raymond
  - Future users evaluating Dev Cadence stage readiness
acceptance_criteria:
  - The guide is Chinese and lives under docs/.
  - The guide uses `--mode init`, not positional `init`.
  - The guide has copyable commands for package checks, thin-contract initialization, delivery dry run, acceptance summary, and optional artifact validation.
  - The guide states expected pass indicators.
  - The guide states fail or feedback conditions.
  - The guide explains dry-run residual risk.
constraints:
  - Keep skill package content English by not editing skills/dev-cadence/** unless verification reveals a required fix.
  - Keep the change documentation-scoped.
assumptions:
  - The guide can reference R1-R7 from docs/dev-cadence-roadmap.md.
  - The user-facing docs language requirement applies to the new guide.
open_questions: []
human_decisions:
  - decided_by: Raymond
    decision: Proceed with a real Dev Cadence dogfooding task for the acceptance guide.
    source: User message "跑一下试试"
```

## Source Notes

- User asked how to accept the stage and then manually confirmed the proposed commands passed after correcting `--mode init`.
- `sync-repo-contract.mjs --help` states `Usage: sync-repo-contract.mjs --mode <mode> [options]`.
- `docs/dev-cadence-roadmap.md` records R1-R7 as `done`.

## Ambiguity Check

```yaml
unresolved_ambiguity: false
material_to_implementation: false
clarification_required: false
analysis_performed:
  - Read roadmap and CLI help.
  - Ran the dry-run command sequence in a temporary directory.
evidence_paths:
  - docs/dev-cadence-roadmap.md
  - skills/dev-cadence/scripts/sync-repo-contract.mjs
  - skills/dev-cadence/scripts/run-delivery-dry-run.mjs
  - skills/dev-cadence/scripts/summarize-acceptance.mjs
candidate_interpretations:
  - Write only a chat answer.
  - Add a stable Chinese guide under docs/.
recommended_option: Add a stable Chinese guide under docs/ because chat is not durable source of truth.
clarified_by_human: Raymond
clarified_at: 2026-06-22
decision: Proceed with the stable guide.
```

## Requirements Readiness Check

```yaml
expected_behavior_explicit: true
expected_behavior_source: User request and corrected CLI help behavior.
reference_behavior_explicit: true
reference_behavior_source: Existing scripts and roadmap.
scope_confirmed: true
non_goals_confirmed: true
acceptance_criteria_confirmed: true
verification_approach_confirmed: true
accepted_by_human: Raymond
human_decision_reference: User message "跑一下试试"
ready_for_implementation: true
blocking_questions: []
```

## Gate G1

```yaml
gate_id: G1
status: passed
required_inputs:
  - goal
  - scope
  - non_goals
  - acceptance_criteria
evidence:
  - specs/20260622-acceptance-guide/00-brief.md
  - specs/20260622-acceptance-guide/01-requirements.md
pass_condition: Requirements are clear and no material ambiguity remains.
fail_condition: CLI command style or dry-run scope remains ambiguous.
decision: passed
human_override: null
residual_risk: Final acceptance still requires named Human confirmation after verification.
escalation: none
```
