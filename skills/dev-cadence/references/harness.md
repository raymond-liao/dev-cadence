# Harness

Harness mediates Worker Agent execution through context injection, tool policy, permission policy, logging, and evidence capture.

Harness is not an Agent and must not make semantic approval decisions.

## Contents

- [Run Context Schema](#run-context-schema)
- [Required Evidence](#required-evidence)
- [Execution Report Schema](#execution-report-schema)
- [Permission Policy](#permission-policy)
- [Single-Executor Use](#single-executor-use)
- [Missing Evidence](#missing-evidence)

## Run Context Schema

```yaml
run_id:
task_id:
agent_role:
blueprint_path:
context_pack_path:
workspace_path:
allowed_read_paths:
allowed_write_paths:
denied_paths:
allowed_tools:
denied_tools:
network_policy:
secret_policy:
permission_policy:
budget:
timeout:
max_iterations:
required_evidence:
expected_artifacts:
log_paths:
```

## Required Evidence

Capture or reference:

- `run-context.md`;
- `execution-report.md`;
- `tool-log.md`;
- `permission-decisions.md`, even when no permission was requested;
- `diff-summary.md` when files change;
- `test-log.md` when commands or tests run;
- skipped evidence and reason.

Missing required files block Quality Gates. A summary inside `execution-report.md` does not replace the required evidence files.

## Execution Report Schema

```yaml
run_id:
task_id:
agent_role:
state:
started_at:
ended_at:
inputs:
outputs:
files_changed:
commands_run:
tests_run:
verification_status:
permissions_requested:
permissions_granted:
permissions_denied:
skipped_checks:
errors:
residual_risk:
handoff_target:
```

## Permission Policy

Require explicit Human Gate approval before:

- destructive file or git operations;
- production or release actions;
- database writes or migrations;
- secret access;
- CI/CD workflow changes;
- network access when policy is restricted;
- broad file writes outside allowed paths.

Record approved, denied, or deferred permission decisions in `permission-decisions.md`.

## Single-Executor Use

When one Codex instance performs multiple roles, still represent Harness boundaries:

- write or update a Run Context before role work;
- keep role-specific outputs separate;
- record commands and results;
- preserve Tester and Reviewer independence in artifacts;
- do not let Developer notes become final approval.

## Missing Evidence

If evidence cannot be captured, record:

- missing item;
- reason;
- effect on quality gates;
- residual risk;
- recommended follow-up;
- whether Human acceptance is still allowed.
