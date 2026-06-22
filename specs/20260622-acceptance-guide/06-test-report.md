# Test Report

```yaml
status: complete
verification_status: verified
commands_run:
  - node skills/dev-cadence/scripts/check-skill-package.mjs skills/dev-cadence
  - node skills/dev-cadence/scripts/check-discipline-routes.mjs skills/dev-cadence
  - node skills/dev-cadence/scripts/check-spec-artifacts.mjs specs
  - node skills/dev-cadence/scripts/check-spec-artifacts.mjs skills/dev-cadence/templates
  - git diff --check
  - node -e JSON assertion for summarize-acceptance.mjs --task-id 20260622-acceptance-guide
  - node skills/dev-cadence/scripts/sync-repo-contract.mjs --mode init --repo-dir "$tmp"
  - node skills/dev-cadence/scripts/run-delivery-dry-run.mjs --repo-dir "$tmp" --task-id acceptance-login --goal "Develop a login feature" --accepted-by Raymond
  - node skills/dev-cadence/scripts/summarize-acceptance.mjs --specs-dir "$tmp/specs" --task-id acceptance-login
  - node skills/dev-cadence/scripts/check-spec-artifacts.mjs "$tmp/specs"
environment:
  - local shell
  - Node.js runtime
  - temporary directory under /tmp
results:
  - Package self-check passed.
  - Discipline route check passed.
  - Repository specs artifact check passed.
  - Template artifact check passed.
  - Whitespace diff check passed.
  - Acceptance summary parser regression check passed after a RED failure showed `scope_reconciliation=[]`.
  - Documented dry-run command sequence passed.
  - Temporary dry-run specs artifact check passed.
coverage_scope:
  - docs/acceptance-guide.md command correctness
  - docs/acceptance-guide.md expected-output correctness
  - Dev Cadence package structure
  - Dev Cadence discipline routes
  - Task artifact schema sanity
changed_component_coverage:
  - component: docs/acceptance-guide.md
    status: covered_by_dry_run_and_manual_read
  - component: specs/20260622-acceptance-guide
    status: covered_by_check_spec_artifacts
  - component: skills/dev-cadence/scripts/summarize-acceptance.mjs
    status: covered_by_json_assertion
skipped_component_checks:
  - component: product behavior
    reason: This task changes documentation and artifacts only.
defects: []
skipped_checks:
  - Product tests were not run because no product files or behavior changed.
residual_risk:
  - Documentation validation does not prove all future local environments can run Node scripts.
  - The dry-run workflow does not verify real login behavior or any other product behavior.
recommendation: Proceed to review; final acceptance still requires Raymond.
```

## Evidence

- `runs/20260622-1820-developer-1/test-log.md`
- `runs/20260622-1820-tester-1/test-log.md`

## Gate G4

```yaml
gate_id: G4
status: passed
required_inputs:
  - test plan
  - implementation notes
  - command evidence
  - changed component coverage
evidence:
  - specs/20260622-acceptance-guide/04-test-plan.md
  - specs/20260622-acceptance-guide/05-implementation.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-tester-1/test-log.md
  - summarize-acceptance.mjs JSON assertion output
verification_status: verified
component_coverage_complete: true
human_override: null
residual_risk:
  - Product behavior is intentionally out of scope.
escalation: none
```
