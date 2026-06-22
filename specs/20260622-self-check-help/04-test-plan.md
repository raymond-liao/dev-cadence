# Test Plan

```yaml
status: planned
scope:
  - help flag behavior for both self-check scripts
  - unchanged normal validation behavior
test_strategy:
  - Use command-line behavior checks as the feedback signal.
  - Use existing package validation scripts as regression checks.
test_commands:
  - node skills/dev-cadence/scripts/check-skill-package.mjs --help
  - node skills/dev-cadence/scripts/check-skill-package.mjs -h
  - node skills/dev-cadence/scripts/check-discipline-routes.mjs --help
  - node skills/dev-cadence/scripts/check-discipline-routes.mjs -h
  - node skills/dev-cadence/scripts/check-skill-package.mjs skills/dev-cadence
  - node skills/dev-cadence/scripts/check-discipline-routes.mjs skills/dev-cadence
  - rg -n "[一-龥]" skills/dev-cadence
  - rg -n "superpowers|Superpowers|claude|Claude|\\.superpowers|brainstorming" skills/dev-cadence
  - git diff --check
test_data:
  - skills/dev-cadence
environment:
  - local repository
  - Node.js runtime available through node
coverage_targets:
  - both self-check scripts
  - both help flags
  - existing validation path
changed_component_coverage:
  - component: skills/dev-cadence/scripts/check-skill-package.mjs
    covered_by:
      - --help
      - -h
      - normal package validation
  - component: skills/dev-cadence/scripts/check-discipline-routes.mjs
    covered_by:
      - --help
      - -h
      - normal route validation
skipped_component_checks: []
risks:
  - Help output assertions are inspected manually instead of through a separate automated test file.
```

## Planned Evidence

Command outputs will be recorded in `runs/20260622-1553-developer-1/test-log.md` for RED and in `runs/20260622-1553-tester-1/test-log.md` for GREEN/regression verification.
