# Repository Rule Sync

Use this reference only when the user explicitly invokes `$dev-cadence` or names `dev-cadence` for update, sync, repair, inspect, diagnose, or maintenance of an already initialized repository.

## Core Model

After initialization, normal delivery work is governed by the target repository's root `AGENTS.md` and `.ai/**` files. The Skill source is not the runtime authority for ordinary feature, bugfix, refactor, review, research, or incident work.

The Skill becomes active again only for repository-rule maintenance. In that mode, update generated rules and templates so future ordinary work uses the improved repo-local `.ai/` behavior.

## Allowed Modes

- `inspect`: read repo-local `AGENTS.md`, `.ai/**`, and `specs/` shape; report whether the repository appears initialized and where drift exists. Do not write.
- `sync` or `update`: reconcile repo-local generated rules and templates with current Skill references while preserving local overlays. Write only framework files.
- `repair`: restore missing or malformed generated framework files. Preserve local repository instructions and report any uncertain merge.
- `diagnose`: explain initialization or rule-routing problems and recommend exact fixes. Write only if the user explicitly asked to repair or update.

Maintenance modes are forbidden unless the user explicitly invokes `$dev-cadence` or names `dev-cadence`.

## Write Boundary

Allowed writes during rule maintenance:

- root `AGENTS.md` AI delivery entrypoint section;
- `.ai/control/**`;
- `.ai/agents/**`;
- `.ai/workflows/**`;
- `.ai/policies/**`;
- `.ai/templates/**`;
- `specs/.gitkeep` only when needed to represent an empty specs directory.

Forbidden writes unless the same user turn explicitly asks for delivery work:

- product source, tests, migrations, build scripts, deployment files, runtime configuration, or dependency manifests;
- task-specific `specs/{task_id}/` artifacts;
- commits, pushes, releases, database operations, or production actions.

## Sync Record

Generated `.ai/` rules should include a small sync record:

```text
.ai/dev-cadence.md
```

This file is audit metadata, not runtime configuration. Runtime authority remains the target repository's `AGENTS.md` and `.ai/**` rules.

Use this shape:

```yaml
schema: dev-cadence.rule-sync.v1
record_type: rule_sync_audit
runtime_authority:
  - AGENTS.md
  - .ai/**
skill_source:
  name: dev-cadence
  version:
    value:
    status: not_versioned
    reason:
  commit:
    value:
    status: not_recorded
    reason:
sync:
  mode:
  synced_at:
  actor:
local_overlays:
  - path:
    disposition: preserved
    reason:
manual_review_required:
  - path:
    reason:
```

Record a version or source commit only when it is actually known. If either value is not known, leave `value` empty and set `status` plus `reason`; do not write placeholder values such as `local`, `unavailable`, `unknown`, or `n/a`.

The sync record helps future agents tell whether repo-local rules are older than the Skill source, but absence of this file must not block inspection or repair.

## Drift Detection

Compare repo-local files against the current Skill references through the Initialization Source Map in `skill-layout.md`.

Classify each target as:

```text
missing
matches_current
local_overlay
outdated_generated
conflict_needs_review
unknown
```

Use `local_overlay` when the target repository intentionally adds project-specific constraints. Preserve these unless they conflict with hard safety rules. Use `conflict_needs_review` when local content contradicts hard stops, weakens gate ownership, allows product edits during initialization, or lets non-Humans accept final completion.

## Merge Rules

- Preserve repository-specific instructions in root `AGENTS.md`; add or update only the AI delivery entrypoint section.
- Preserve documented local overlays in `.ai/control/supervisor.md` and policy files when they add stricter or project-specific constraints.
- Do not delete unknown `.ai/` files by default. Report them as `unknown` unless they conflict with generated responsibilities.
- Prefer patching generated sections over replacing whole files when local overlays exist.
- If a merge would weaken local safety rules or erase project knowledge, stop and ask for a Human decision.
- If a generated rule has become stricter in the Skill source, update the repo-local rule unless the user explicitly rejects it.

## Required Sync Report

After inspect, sync, update, repair, or diagnose, report:

```yaml
mode:
repository:
initialized:
metadata:
files_added:
files_updated:
files_preserved:
local_overlays:
conflicts:
manual_review_required:
forbidden_changes_avoided:
verification:
next_steps:
```

Verification should include at least:

- root `AGENTS.md` still routes normal delivery to `.ai/control/supervisor.md`;
- `.ai/control/supervisor.md` exists;
- required `.ai/agents`, `.ai/workflows`, `.ai/policies`, and `.ai/templates` files exist;
- generated hard rules are present;
- sync/update did not create task-specific specs or touch product files.

## Runtime Reminder

After sync/update completes, future normal work should use the target repository's updated `AGENTS.md` and `.ai/**`. Do not continue into product delivery unless the user asks for a concrete delivery task in the same turn.
