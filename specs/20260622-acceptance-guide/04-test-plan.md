# Test Plan

```yaml
status: ready
scope:
  - docs/acceptance-guide.md
  - specs/20260622-acceptance-guide/
test_strategy:
  - Validate Dev Cadence package structure and route references.
  - Validate task artifacts for duplicate YAML-like keys.
  - Validate the documented dry-run command sequence in a temporary directory.
  - Check git diff whitespace.
test_commands:
  - node skills/dev-cadence/scripts/check-skill-package.mjs skills/dev-cadence
  - node skills/dev-cadence/scripts/check-discipline-routes.mjs skills/dev-cadence
  - node skills/dev-cadence/scripts/check-spec-artifacts.mjs specs
  - node skills/dev-cadence/scripts/check-spec-artifacts.mjs skills/dev-cadence/templates
  - git diff --check
  - node -e JSON assertion for summarize-acceptance.mjs --task-id 20260622-acceptance-guide
  - node skills/dev-cadence/scripts/sync-repo-contract.mjs --mode init --repo-dir "$tmp"
  - node skills/dev-cadence/scripts/run-delivery-dry-run.mjs --repo-dir "$tmp" --task-id acceptance-login --goal "Develop a login feature" --accepted-by Raymond
  - node skills/dev-cadence/scripts/summarize-acceptance.mjs --specs-dir "$tmp/specs" --task-id acceptance-login
test_data:
  - temporary directory from mktemp under /tmp
environment:
  - local repository checkout
  - Node.js available for .mjs scripts
coverage_targets:
  - guide command correctness
  - guide expected-output correctness
  - package route integrity
  - artifact schema sanity
changed_component_coverage:
  - component: docs/acceptance-guide.md
    planned_check: documented dry-run command sequence and manual read.
  - component: specs/20260622-acceptance-guide
    planned_check: check-spec-artifacts.mjs specs.
  - component: skills/dev-cadence/scripts/summarize-acceptance.mjs
    planned_check: JSON assertion for `scope_reconciliation: in_scope`.
skipped_component_checks:
  - component: product behavior
    reason: No product behavior is changed by this task.
risks:
  - Documentation validation cannot prove every future environment can run the scripts.
  - Dry-run validation remains a framework workflow check, not product behavior verification.
```

## Planned Evidence

Record command outputs in `specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/test-log.md` and implementation scope reconciliation in `diff-summary.md`.
