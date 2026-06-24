# Harness

Harness mediates Worker Agent execution through context injection, tool policy, permission policy, logging, and evidence capture.

Harness is not an Agent and must not make semantic approval decisions.

## Contents

- [Run Context Schema](#run-context-schema)
- [Pre-Implementation Status Schema](#pre-implementation-status-schema)
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
pre_implementation_status_path:
expected_artifacts:
log_paths:
```

## Pre-Implementation Status Schema

For `S1` and `S2` implementation or fix runs, capture
`pre-implementation-status.md` before the first product source, test, migration,
build, deployment, or application configuration edit.

```yaml
run_id:
task_id:
captured_at:
task_class:
selected_workflow:
implementation_state:
git_status_before:
untracked_files_before:
authorized_target_files:
authorized_artifact_files:
g1_status:
g2_status:
g3_status:
requirements_ready:
blocking_questions:
implementation_authorized:
authorization_source:
post_hoc_backfill:
post_hoc_human_override_by:
post_hoc_human_override_reason:
residual_risk:
```

`implementation_authorized` may be `true` only when the latest request is
reconciled, Requirements Readiness Check is complete, required gates are passed
or explicitly overridden by a named Human, and the authorized target files cover
the intended product edit. If this file is captured after product edits started,
set `post_hoc_backfill: true`; the baseline is not equivalent to pre-work
evidence.

## Required Evidence

Capture or reference:

- `run-context.md`;
- `pre-implementation-status.md` before S1/S2 implementation or fix product edits;
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
