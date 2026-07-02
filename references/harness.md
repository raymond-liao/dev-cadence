# Harness

Harness mediates Worker Agent execution through context injection, tool policy, permission policy, logging, and evidence capture.

Harness is not an Agent and must not make semantic approval decisions.

## Contents

- [Run Context Evidence](#run-context-evidence)
- [Pre-Implementation Status Evidence](#pre-implementation-status-evidence)
- [Required Evidence](#required-evidence)
- [Execution Report Evidence](#execution-report-evidence)
- [Permission Policy](#permission-policy)
- [Single-Executor Use](#single-executor-use)
- [Missing Evidence](#missing-evidence)

## Run Context Evidence

`run-context.md` records the execution boundary for one Harness run as readable
Markdown/schema-lite. It must answer what this run was allowed to do before a
Reviewer or Verifier trusts later claims.

Required stable labels and sections:

- `Run ID`, `Task ID`, `Agent role`, `Status`;
- `What this run is allowed to do`: blueprint path, context pack path,
  workspace path, allowed read paths, allowed write paths, forbidden paths;
- `Tools and environment`: allowed tools, denied tools, network policy, secret
  policy, permission policy;
- `Required evidence`: evidence files expected from this run;
- `Limits`: budget, timeout, max iterations.

## Pre-Implementation Status Evidence

For `S1` and `S2` implementation or fix runs, capture
`pre-implementation-status.md` before the first product source, test, migration,
build, deployment, or application configuration edit.

Use stable Markdown labels for `Run ID`, `Task ID`, `Captured at`, `Task class`,
`Selected workflow`, `Implementation state`, `Implementation authorized`,
`Authorization source`, and `Post hoc backfill`. Include sections for worktree
baseline, authorized scope, gate-relevant baseline, post-hoc Human override, and
residual risk.

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

## Execution Report Evidence

`execution-report.md` summarizes one run without replacing the required evidence
files. It must use readable sections for `What happened`, `Files changed`,
authorization baseline, artifacts created or updated, verification run,
permission activity, skipped checks, errors/blockers, residual risk, and handoff.
Keep stable labels such as `Run ID`, `Task ID`, `Agent role`, `Status`,
`Scope reconciliation status`, `Commands run`, `Tests run`, and
`Verification status` so checkers can parse the evidence.

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
