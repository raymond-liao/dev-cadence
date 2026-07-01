---
name: using-dev-cadence
description: Use when starting or continuing software delivery work, including features, bugfixes, refactors, reviews, research spikes, incidents, verification, acceptance, or Dev Cadence repository setup.
---

# Using Dev Cadence

Use this Skill as the Dev Cadence Supervisor entrypoint. It is the only Skill that represents Dev Cadence as a whole.

## Control Rule

Before any response or action for software delivery work, classify the request, check all applicable cadence Skills, and enter the smallest workflow that preserves evidence, gates, and Human acceptance.

User instructions define what to do. Dev Cadence defines how delivery work is controlled, evidenced, reviewed, verified, and accepted.

If there is any reasonable chance a cadence Skill applies, use this Supervisor entrypoint before answering, asking clarification questions, reading files, running commands, or editing code.

If a concrete cadence Skill applies, use it through this Supervisor entrypoint. Do not treat this bootstrap Skill as a replacement for the concrete discipline Skill.

## Instruction Priority

Follow this priority order:

1. explicit user instructions, repository instructions, and direct constraints;
2. Dev Cadence Supervisor, Harness, Quality Gate, Human Gate, and cadence Skill rules;
3. default agent behavior.

If user or repository instructions conflict with Dev Cadence discipline, follow the higher-priority instruction, record the conflict when evidence is being written, and keep affected gates blocked unless a named Human accepts the residual risk.

## Skill Activation

Use Codex native skill activation. Do not read `SKILL.md` files with ordinary file tools as a substitute for activating an applicable Skill.

When Dev Cadence is embedded in a target repository under `.dev-cadence/`, repository instructions may require reading `.dev-cadence/skills/using-dev-cadence/SKILL.md` as the activation path. In that mode, treat the repo-embedded file as the active Dev Cadence runtime, resolve `skills/...`, `references/...`, `templates/...`, and `scripts/...` paths relative to `.dev-cadence/`, and continue through the same Supervisor routing rules.

If a concrete cadence Skill was activated first, immediately return to this Supervisor entrypoint before doing that Skill's work.

## Required References

Load only the shared resources needed for the current routing decision:

- `../../references/principles.md`
- `../../references/workflows.md`
- `../../references/task-classes.md`
- `../../references/supervisor-state-machine.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`
- `../../references/human-gates.md`
- `../../references/spec-templates.md`

Load `../../references/delivery-disciplines.md` when selecting a detailed discipline.

## Supervisor Routing

Before acting on software delivery work, identify the current workflow state, task class, evidence requirement, gate status, and all applicable discipline Skills:

- repository contract setup, inspection, sync, repair, or diagnosis -> `cadence-sync`;
- unclear goal, scope, expected behavior, non-goals, design, or acceptance -> `cadence-clarify`;
- approved design that needs executable tasks -> `cadence-plan`;
- feasibility check, technical comparison, design research, option analysis, or recommendation without approved implementation -> `cadence-research`;
- approved plan ready for implementation -> `cadence-executing-plans`;
- approved plan with bounded tasks and isolated Worker execution -> `cadence-subagent-development`;
- independent domains that can run concurrently -> `cadence-dispatch-parallel`;
- testable behavior change during implementation -> `cadence-tdd`;
- bug, incident, failing test, or unknown cause -> `cadence-debug`;
- implementation checkpoint, final review, or code review request -> `cadence-request-code-review`;
- review feedback, requested changes, or reviewer findings to fix -> `cadence-review`;
- before claiming fixed, done, passing, approved, or complete -> `cadence-verify`.

If multiple Skills apply, use them in workflow order. These Skills are cumulative, not alternatives.

Common sequences:

- research spike: `cadence-clarify` when the research question or decision boundary is unclear -> `cadence-research` -> Human decision or `cadence-clarify`/`cadence-plan` for approved delivery follow-up;
- feature or behavior change: `cadence-clarify` -> `cadence-plan` -> `cadence-tdd` or `cadence-executing-plans` -> `cadence-request-code-review` -> `cadence-review` when findings require fixes -> `cadence-request-code-review` -> `cadence-verify` -> Human acceptance;
- bug, incident, failing test, or regression: `cadence-debug` -> `cadence-tdd` or `cadence-executing-plans` -> `cadence-request-code-review` -> `cadence-review` when findings require fixes -> `cadence-request-code-review` -> `cadence-verify` -> Human acceptance;
- review request: `cadence-request-code-review` -> `cadence-review` when findings require fixes -> `cadence-request-code-review` -> `cadence-verify` -> Human acceptance when the user asks to accept or finish;
- verification or completion claim: `cadence-verify` -> Human acceptance when final completion is requested;
- repository setup or drift repair: `cadence-sync`, then return to the delivery sequence only if the same user turn requests product work.

## Repo Contract

A target repository does not need to be initialized before Dev Cadence can help. Create or use `specs/records/{task_id}/` when persistent artifacts are needed. Use `cadence-sync` only when the user requests repository setup or when low-risk contract files must be created for durable artifacts.

## Task Weight

Classify conservatively:

- `S0`: low-risk, small, easy to verify, no core behavior, no security/auth/payment/data migration/deletion, no design discussion needed;
- `S1`: ordinary feature, bugfix, refactor, review, research spike, or incident;
- `S2`: security, authentication, authorization, payment, data migration, destructive, compliance, privacy, or high blast-radius work.

When unsure, upgrade to `S1` or `S2`.

## Red Flags

Stop and route through the applicable cadence Skill when any of these are true:

- responding to a feature, bugfix, refactor, review, research, incident, verification, acceptance, or repo contract request before checking Dev Cadence routing;
- asking clarification questions before checking whether `cadence-clarify` applies;
- reading files, checking git, or exploring the repository before checking the applicable cadence Skill;
- starting with file edits, shell commands, or implementation before classifying workflow state and task class;
- starting S1/S2 product edits before `runs/{run_id}/pre-implementation-status.md` captures the worktree baseline and authorization state;
- thinking the request is too small, too obvious, or too urgent for a cadence Skill;
- relying on memory of a Skill instead of activating the current Skill;
- treating a terse continuation such as "continue", "start", or "finish it" as permission to skip the active cadence sequence;
- fixing a bug before root cause or reproducible behavior is recorded;
- implementing testable behavior before deciding whether `cadence-tdd` applies;
- claiming fixed, done, passing, ready, approved, or complete before `cadence-verify`;
- creating a Git commit before `scripts/check-before-commit.mjs` has evaluated the commit candidate;
- treating missing verification, missing Harness evidence, or skipped checks as acceptable without a named Human Gate;
- recording Supervisor, Harness, Developer, Tester, Reviewer, or an unspecified agent as the final accepter.

## Hard Rules

Do not bypass Supervisor state, Harness evidence, Quality Gates, Human Gates, scope reconciliation, or named Human final acceptance.

For `S1` and `S2`, do not edit product source, tests, migrations, build scripts,
deployment files, or application configuration until
`pre-implementation-status.md` records the tracked and untracked worktree
baseline, authorized target files, required gate status, and
`implementation_authorized: true`. If this baseline is captured after product
edits started, mark `post_hoc_backfill: true`; do not treat it as normal
pre-work evidence without a named Human Gate override.

Do not collapse the workflow to a single Skill when later Skills are required. A bugfix can require debug, TDD or execution, review, verify, and acceptance in the same delivery.

Do not turn research into implementation. A research spike can inspect evidence and recommend a path, but product edits require explicit follow-up delivery approval and the normal clarify, plan, execute, review, and verify sequence.

Do not self-accept final results. Final acceptance must name a Human accepter.

Do not treat a request to commit code as final acceptance. Before committing,
run `scripts/check-before-commit.mjs` against the commit candidate. The checker
is read-only and must not create specs. It evaluates the full dirty worktree,
regardless of staging state.

If the candidate is outside Dev Cadence workflow scope, Dev Cadence G1-G6 and
Human Gate checks are skipped. If the candidate is Dev Cadence
contract/runtime-only, run the checker without borrowing an unrelated product
task id; it validates the embedded runtime. If the candidate includes
`specs/records/{task_id}/` workflow specs, or product paths intentionally belong
to an existing Dev Cadence workflow but the specs are not in the same candidate,
ensure the workflow is checked with `--task-id <task_id>` when needed. Workflow
checks must fail on selected-task artifact language warnings, blocked gates,
pending Human acceptance, or uncovered candidate paths.

If G6 is pending for a workflow candidate, block the commit and ask the Human to
accept the result and residual risk before committing. The blocking message
must explain what the Human is being asked to accept: task goal, changed scope,
verification status, skipped checks, review decision, blockers, residual risk,
evidence available, and the `08-acceptance.md` fields that must be recorded.
Use `scripts/summarize-acceptance.mjs --task-id <task_id> --require-report` or
equivalent content. Before requesting final Human acceptance, refresh the
browsable report with
`scripts/generate-spec-report.mjs --specs-dir specs/records --report-dir specs/report`
and include `specs/report/{task_id}/index.html` in the approval request.

Do not make visual companion usage a gate. It is an optional clarification capability for UI, diagram, mockup, or visual comparison tasks and must fall back to text-only clarification when unavailable.
