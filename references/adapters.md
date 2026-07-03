# Adapters

Use this reference when selecting or constraining optional replacement points
for Worker execution techniques.

Dev Cadence owns Supervisor routing, Harness evidence, Quality Gates, Human Gates, permission policy, scope reconciliation, and final acceptance. An adapter may change how a bounded Worker state is executed, but it must not change what evidence is required or who can approve the result.

## Contents

- [Selection](#selection)
- [Allowed Scope](#allowed-scope)
- [Input Contract](#input-contract)
- [Output Contract](#output-contract)
- [Evidence Gaps](#evidence-gaps)
- [Conflict Rules](#conflict-rules)
- [Forbidden Overrides](#forbidden-overrides)

## Selection

The built-in Dev Cadence delivery discipline is the default.

Use an external adapter only when it is explicitly configured or explicitly requested by a named Human for the current Worker state. Do not infer adapter selection from a package name, installed tool, or model preference.

Record adapter selection in the relevant task artifact or Harness run:

```yaml
adapter_id:
selected_by_human:
selected_for_state:
selection_reason:
expected_discipline:
expected_evidence:
fallback:
```

If no adapter is configured, use the `default` discipline from `delivery-disciplines.md`.

## Allowed Scope

Adapters may operate only inside bounded Worker states, for example:

- implementation technique;
- verification technique;
- review technique;
- research technique;
- orchestration technique for independent Worker tasks.

Adapters do not own:

- workflow selection;
- task classification;
- Requirements Readiness Check;
- Quality Gate pass/fail rules;
- Human Gate approval rules;
- permission policy;
- final acceptance;
- repo-local initialization or maintenance policy.

## Input Contract

Every adapter run receives a Harness-controlled context:

```yaml
task_id:
run_id:
agent_role:
current_state:
task_class:
selected_workflow:
goal:
acceptance_criteria:
non_goals:
target_files:
forbidden_actions:
verification_plan:
harness_run_context:
artifact_paths:
allowed_read_paths:
allowed_write_paths:
denied_paths:
permission_policy:
required_evidence:
```

The Harness may provide less context when the Worker state does not need all fields, but it must not omit constraints, forbidden actions, required evidence, or permission policy.

## Output Contract

Every adapter run must produce or allow Harness capture of:

```yaml
status:
changed_files:
commands_run:
tests_run:
test_or_verification_results:
skipped_checks:
residual_risk:
open_questions:
handoff_notes:
```

Implementation adapters also need:

```yaml
diff_summary:
test_first_evidence:
green_test_evidence:
refactor_notes:
scope_reconciliation_notes:
```

Review adapters also need:

```yaml
findings:
severity:
affected_locations:
decision:
required_fixes:
residual_risk:
```

Research adapters also need:

```yaml
question:
options_considered:
evidence:
tradeoffs:
recommendation:
open_questions:
```

## Evidence Gaps

If an adapter cannot provide required Dev Cadence evidence, record:

```yaml
missing_evidence:
adapter_limitation:
effect_on_gate:
residual_risk:
recommended_follow_up:
human_acceptance_allowed:
```

Missing adapter evidence keeps the relevant Quality Gate blocked unless a named Human accepts the residual risk. An adapter's own success message is not a substitute for Harness evidence files.

## Conflict Rules

When Dev Cadence and an adapter both define a compatible rule, use the stricter rule inside the selected Worker state.

Examples:

- If Dev Cadence requires Red-Green-Refactor and the adapter requires additional mutation or property tests, use both when feasible.
- If an adapter permits implementation without failing-test evidence for a testable behavior change, Dev Cadence still requires a named Human exception.
- If an adapter reports review approval but omits severity, affected locations, or residual risk, Dev Cadence treats the review evidence as incomplete.

If the rules are incompatible, stop before execution and request a Human Gate decision.

## Forbidden Overrides

Adapters must not weaken or bypass:

- named Human final acceptance;
- Requirements Readiness Check;
- Quality Gate evidence requirements;
- Human Gate approval requirements;
- Harness evidence requirements;
- scope reconciliation;
- permission policy;
- final verification before completion claims;
- the three-iteration fix loop limit;
- initialization and maintenance write boundaries.

Do not let adapter configuration in `.dev-cadence.yaml`, legacy `.ai/**`, or task artifacts override these boundaries.
