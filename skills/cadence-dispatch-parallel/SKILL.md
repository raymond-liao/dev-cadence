---
name: cadence-dispatch-parallel
description: Dispatch parallel Dev Cadence Workers for independent domains. Use when there are two or more independent failures, subsystems, investigation tracks, research options, or review slices that can run concurrently without shared mutable state, file conflicts, or sequencing dependencies.
---

# Cadence Dispatch Parallel

Use this Skill when `cadence-executing-plans` or `cadence-debug` identifies independent domains that can be worked in parallel.

## Required References

- `../../references/execution-orchestration.md`
- `../../references/harness.md`
- `../../references/context-pack.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

Load `../../references/debugging-discipline.md` when parallelizing bug, incident, failing-test, or root-cause investigations.

## Required Behavior

Before dispatch:

1. Group work by independent problem domain.
2. Confirm each domain can be understood without findings from another domain.
3. Confirm Workers will not edit the same files, mutate shared state, or require a whole-system mental model.
4. Write focused Worker prompts with scope, constraints, expected evidence, and forbidden actions.

Dispatch one Worker per independent domain. Each Worker gets isolated context and must return:

- summary of findings;
- changed files, if any;
- commands and verification results;
- residual risk;
- blockers or follow-up questions.

## Integration

After Workers return:

1. Review every summary and changed file list.
2. Check for overlapping edits, semantic conflicts, and inconsistent assumptions.
3. Run integrated verification.
4. Return integration evidence and unresolved risks for Supervisor/Harness recording.
5. Continue to review only after conflicts and verification gaps are resolved.

Do not use parallel dispatch when failures are related, when one fix may change another domain, when shared state is involved, or when a single whole-system investigation is required.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
