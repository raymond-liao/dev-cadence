# Tasks

```yaml
status: ready
task_class: S1
selected_workflow: feature-dev
previous_task_class: null
task_class_change_reason: null
required_extra_gates: []
tasks:
  - id: T1
    name: Add help output to self-check scripts
    goal: Support --help and -h in both self-check scripts without changing normal validation behavior.
    target_files:
      - skills/dev-cadence/scripts/check-skill-package.mjs
      - skills/dev-cadence/scripts/check-discipline-routes.mjs
      - skills/dev-cadence/references/workflows.md
      - skills/dev-cadence/references/supervisor-state-machine.md
    acceptance_criteria:
      - AC1
      - AC2
      - AC3
      - AC4
      - AC5
      - AC6
      - AC7
    red_step:
      command: node skills/dev-cadence/scripts/check-skill-package.mjs --help
      expected_result: Fails before implementation because --help is treated as a target path.
    green_steps:
      - Add argument handling before path resolution.
      - Print usage text and exit 0 for --help and -h.
      - Keep existing target path behavior unchanged.
    verification_commands:
      - node skills/dev-cadence/scripts/check-skill-package.mjs --help
      - node skills/dev-cadence/scripts/check-skill-package.mjs -h
      - node skills/dev-cadence/scripts/check-discipline-routes.mjs --help
      - node skills/dev-cadence/scripts/check-discipline-routes.mjs -h
      - node skills/dev-cadence/scripts/check-skill-package.mjs skills/dev-cadence
      - node skills/dev-cadence/scripts/check-discipline-routes.mjs skills/dev-cadence
      - rg -n "[一-龥]" skills/dev-cadence
      - rg -n "superpowers|Superpowers|claude|Claude|\\.superpowers|brainstorming" skills/dev-cadence
      - git diff --check
    expected_passing_output:
      - Help commands exit 0 and include Usage.
      - Validation commands exit 0.
      - rg commands exit 1 with no matches.
      - git diff --check exits 0.
dependencies: []
planned_components:
  - Dev Cadence self-check scripts
target_files:
  - skills/dev-cadence/scripts/check-skill-package.mjs
  - skills/dev-cadence/scripts/check-discipline-routes.mjs
  - skills/dev-cadence/references/workflows.md
  - skills/dev-cadence/references/supervisor-state-machine.md
planned_artifact_files:
  - specs/20260622-self-check-help/**
forbidden_actions:
  - Do not change shipped skill references except task artifacts.
  - Do not add dependencies.
  - Do not rewrite validation logic beyond what help routing needs.
acceptance_mapping:
  AC1: T1 help commands with --help.
  AC2: T1 help commands with -h.
  AC3: Help output inspected for usage, default target, and validation summary.
  AC4: Existing validation commands.
  AC5: Language and old external naming searches.
  AC6: Package self-check validates help output automatically.
  AC7: Workflow and state-machine references include untracked planned artifact reconciliation.
verification_plan:
  - Use RED command before implementation.
  - Apply minimal code changes.
  - Run all planned verification commands.
verification_coverage_matrix:
  help_behavior: direct commands for both scripts and both flags.
  automated_help_assertion: package self-check validates required help text for both scripts and both flags.
  normal_validation_behavior: package and route self-check commands.
  package_language_boundary: rg Chinese search.
  old_external_naming_boundary: rg old naming search.
  scope_reconciliation_rule: reference text explicitly includes untracked planned artifacts.
```

## Execution Notes

The first RED command is intentionally expected to fail before code changes. If it passes immediately, this plan is invalid and must be revised before implementation.

## Gate G3

```yaml
gate_id: G3
status: passed
required_inputs:
  - target files
  - acceptance mapping
  - verification commands
  - forbidden actions
evidence:
  - specs/20260622-self-check-help/03-tasks.md
pass_condition: Task is executable with concrete files, Red step, Green steps, verification commands, and expected results.
fail_condition: Task lacks bounded files, expected outputs, or acceptance mapping.
decision: passed
human_override: null
residual_risk: This dry run may reveal artifact process gaps that require later framework updates.
escalation: none
```
