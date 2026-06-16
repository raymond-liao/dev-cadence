# Context Pack

Context Pack defines what a Worker Agent should know. It does not define what the Agent is allowed to do.

## Schema

```yaml
task_id:
workflow_hint:
selected_workflow:
selection_reason:
task_class:
agent_role:
goal:
current_state:
acceptance_criteria:
non_goals:
constraints:
relevant_specs:
relevant_decisions:
relevant_files:
previous_outputs:
known_risks:
forbidden_assumptions:
expected_output:
handoff_target:
```

## Field Notes

- `task_id`: stable task folder ID.
- `workflow_hint`: user-provided workflow preference, if any.
- `selected_workflow`: Supervisor-routed workflow.
- `selection_reason`: reason Supervisor selected this workflow.
- `task_class`: `S0`, `S1`, `S2`, `research-spike`, or `incident`.
- `agent_role`: Worker Agent receiving the context.
- `goal`: current state goal, not the entire project ambition.
- `current_state`: Supervisor state being executed.
- `acceptance_criteria`: criteria relevant to this state.
- `non_goals`: explicit boundaries.
- `constraints`: technical, business, policy, time, or permission constraints.
- `relevant_specs`: artifact paths.
- `relevant_decisions`: ADRs, human decisions, or approved tradeoffs.
- `relevant_files`: code or docs the Agent should inspect.
- `previous_outputs`: upstream artifacts or reports.
- `known_risks`: risks the Agent must consider.
- `forbidden_assumptions`: tempting but unapproved assumptions.
- `expected_output`: required artifact or report.
- `handoff_target`: next state or role.

## Construction Rules

- Include the smallest sufficient context for the current Agent.
- Prefer paths to large artifacts over copied content.
- Include explicit source paths for important claims.
- Do not include secrets.
- Do not rely on chat history unless the content is copied into an approved artifact.
- If context is incomplete, record the gap and ask Supervisor to enter `blocked` or a Human Gate.

## Source Priority

Use this order:

1. current code and reproducible test results;
2. approved specs and ADRs;
3. current task artifacts;
4. stable project docs;
5. chat, issue discussion, or informal notes.

## Conflict Handling

If sources conflict, set or report `context_conflict` with:

- conflicting sources;
- affected decision;
- risk;
- recommended Human Gate or next state.

Do not silently choose a source when the conflict affects scope, architecture, security, permissions, test validity, or acceptance.
