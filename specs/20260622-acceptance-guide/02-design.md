# Design

```yaml
status: skipped
problem: The user needs a durable acceptance guide for the current Dev Cadence stage.
chosen_approach: Add one focused Chinese Markdown guide under docs/ and record dogfooding evidence under specs/.
alternatives_considered:
  - Keep acceptance instructions in chat only; rejected because chat is not durable source of truth.
  - Change CLI to support positional `init`; rejected because the existing help already defines `--mode <mode>` and the issue was documentation misuse.
architecture_constraints:
  - Do not change CLI or skill package runtime behavior.
  - Keep docs/ content Chinese.
affected_components:
  - docs/acceptance-guide.md
  - specs/20260622-acceptance-guide/
data_or_control_flow:
  - User asks how to accept the stage.
  - Guide directs user through roadmap check, package checks, thin repo init, dry run, summary, and pass/fail decision.
risks:
  - Dry-run acceptance could be confused with product behavior verification.
required_adrs: []
human_decisions:
  - decided_by: Raymond
    decision: Do not add positional init compatibility; document the correct `--mode init` usage.
```

## Rationale

This documentation task does not need a durable architecture decision. The only design decision is to keep CLI behavior unchanged and document the correct acceptance workflow.

## Gate G2

```yaml
gate_id: G2
status: skipped
required_inputs:
  - design requirement check
evidence:
  - specs/20260622-acceptance-guide/02-design.md
pass_condition: Design is accepted when required.
fail_condition: Architecture-sensitive change lacks design.
decision: skipped_not_required
human_override: null
residual_risk: None for current documentation scope.
escalation: none
```
