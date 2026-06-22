# Requirements

```yaml
status: accepted_for_dry_run
goal: Add a minimal --help interface to both Dev Cadence self-check scripts.
scope:
  - skills/dev-cadence/scripts/check-skill-package.mjs
  - skills/dev-cadence/scripts/check-discipline-routes.mjs
  - skills/dev-cadence/references/workflows.md
  - skills/dev-cadence/references/supervisor-state-machine.md
non_goals:
  - Do not add new command-line flags beyond --help and -h.
  - Do not change existing validation behavior when no help flag is supplied.
  - Do not add external dependencies.
  - Do not change visual companion behavior.
users_or_stakeholders:
  - Dev Cadence maintainers running local package checks.
acceptance_criteria:
  - Running each script with --help exits with status 0.
  - Running each script with -h exits with status 0.
  - Help output includes usage, default target behavior, and a concise description of what the script validates.
  - Existing validation commands continue to pass for skills/dev-cadence.
  - The shipped skill package remains English-only.
  - Package self-check automatically validates help output for both self-check scripts.
  - Scope reconciliation rules explicitly include untracked planned artifacts.
constraints:
  - Use only Node.js built-in modules.
  - Keep changes limited to the two self-check scripts and task artifacts unless verification exposes a necessary documentation correction.
assumptions:
  - No Human clarification is required because the requested dry run objective is explicit and low-risk.
open_questions: []
human_decisions:
  - decision: Proceed with a real small dry run task in this repository.
    decided_by: Raymond
    decided_at: 2026-06-22
```

## Source Notes

- User requested continuing to the next phase and then said "开始吧".
- Current repository has no existing `specs/` directory, so this run starts from a clean artifact area.
- Existing scripts already accept an optional target path argument.

## Ambiguity Check

```yaml
unresolved_ambiguity: false
material_to_implementation: false
clarification_required: false
analysis_performed:
  - Read repository instructions.
  - Read Dev Cadence SKILL.md, state machine, Harness, workflow, task class, implementation, review, verification, and spec template references.
evidence_paths:
  - AGENTS.md
  - skills/dev-cadence/SKILL.md
  - skills/dev-cadence/references/delivery-disciplines.md
  - skills/dev-cadence/scripts/check-skill-package.mjs
  - skills/dev-cadence/scripts/check-discipline-routes.mjs
candidate_interpretations:
  - Add a very small behavior to existing self-check scripts so the dry run has real code, verification, and review evidence.
recommended_option: Add --help and -h support to both self-check scripts.
clarified_by_human: Raymond
clarified_at: 2026-06-22
decision: Use this small script behavior change as the dry-run task.
```

## Requirements Readiness Check

```yaml
expected_behavior_explicit: true
expected_behavior_source: Acceptance criteria in this file.
reference_behavior_explicit: true
reference_behavior_source: Existing scripts already validate the package when invoked with an optional target path.
scope_confirmed: true
non_goals_confirmed: true
acceptance_criteria_confirmed: true
verification_approach_confirmed: true
accepted_by_human: Raymond
human_decision_reference: User message "开始吧" for the dry run, recorded into this artifact.
ready_for_implementation: true
blocking_questions: []
```

## Gate G1

```yaml
gate_id: G1
status: passed
required_inputs:
  - explicit goal
  - scope
  - non-goals
  - acceptance criteria
  - verification approach
evidence:
  - specs/20260622-self-check-help/00-brief.md
  - specs/20260622-self-check-help/01-requirements.md
pass_condition: Requirements are explicit and no ambiguity materially affects implementation.
fail_condition: A missing requirement or unresolved ambiguity would change implementation or acceptance.
decision: passed
human_override: null
residual_risk: Final acceptance still requires Raymond.
escalation: none
```
