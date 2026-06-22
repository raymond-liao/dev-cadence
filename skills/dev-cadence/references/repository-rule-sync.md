# Repository Rule Sync

Use this reference only when the user explicitly invokes `$dev-cadence` or names `dev-cadence` for update, sync, repair, inspect, diagnose, or maintenance of an already initialized repository.

## Core Model

After initialization, normal delivery work is routed by the target repository's root `AGENTS.md` to the Dev Cadence plugin. Runtime authority is layered across repo-local entrypoint/config/overrides, task artifacts, plugin-owned references/templates/built-in delivery disciplines/adapters, and configured adapters.

The maintenance Skill becomes active again only for repository-rule maintenance. In that mode, update the thin repo-local contract so future ordinary work uses the intended runtime path.

## Allowed Modes

- `inspect`: read repo-local `AGENTS.md`, `.ai/config.yaml`, `.ai/local.yaml`, `.ai/overrides/**`, and `specs/` shape; report whether the repository appears initialized and where drift exists. Do not write.
- `sync` or `update`: reconcile the thin repo-local contract with current Dev Cadence references while preserving local overlays. Write only framework entrypoint/config files.
- `repair`: restore missing or malformed thin-contract files. Preserve local repository instructions and report any uncertain merge.
- `diagnose`: explain initialization or rule-routing problems and recommend exact fixes. Write only if the user explicitly asked to repair or update.

Maintenance modes are forbidden unless the user explicitly invokes `$dev-cadence` or names `dev-cadence`.

## Write Boundary

Allowed writes during rule maintenance:

- root `AGENTS.md` AI delivery entrypoint section;
- root `.gitignore` entry for `.ai/local.yaml`;
- `.ai/config.yaml`;
- `.ai/local.yaml`;
- `.ai/overrides/**`;
- `specs/.gitkeep` only when needed to represent an empty specs directory.

Forbidden writes unless the same user turn explicitly asks for delivery work:

- product source, tests, migrations, build scripts, deployment files, runtime configuration, or dependency manifests;
- task-specific `specs/{task_id}/` artifacts;
- commits, pushes, releases, database operations, or production actions.

## Sync Record

Thin-contract repositories do not need a generated `.ai/dev-cadence.md` sync record by default. Runtime authority is the layered model described in `skill-layout.md`.

If a future implementation adds a sync record, it must be audit metadata only and must not become runtime configuration.

## Drift Detection

Compare repo-local files against the current thin contract in `skill-layout.md`.

Classify each target as:

```text
missing
matches_current
local_overlay
outdated_generated
conflict_needs_review
unknown
```

Use `local_overlay` when the target repository intentionally adds project-specific constraints under `.ai/overrides/**`. Preserve these unless they conflict with hard safety rules. Use `conflict_needs_review` when local content contradicts hard stops, weakens gate ownership, allows product edits during initialization, or lets non-Humans accept final completion.

## Merge Rules

- Preserve repository-specific instructions in root `AGENTS.md`; add or update only the AI delivery entrypoint section.
- Preserve existing `.ai/config.yaml` values unless they are unsupported. Supported `dev_cadence.artifact_language` values are `en` and `zh`; report unsupported values for manual review instead of guessing.
- Create `.ai/local.yaml` with commented preference fields when missing. Preserve existing uncommented user values when the file already exists.
- Ensure `.gitignore` contains `.ai/local.yaml`, preserving existing ignore rules.
- Preserve documented local overlays in `.ai/overrides/**`.
- Do not delete unknown `.ai/` files by default. Report them as `unknown` unless they conflict with generated responsibilities.
- Prefer patching generated sections over replacing whole files when local overlays exist.
- If a merge would weaken local safety rules or erase project knowledge, stop and ask for a Human decision.

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

- root `AGENTS.md` routes normal delivery to Dev Cadence;
- `.ai/config.yaml` exists or an equivalent repo-local config is documented;
- `.ai/local.yaml` exists and `.gitignore` ignores it;
- `.ai/overrides/` exists or absence is documented;
- hard rules are available through plugin-owned references;
- sync/update did not create task-specific specs or touch product files.

## Runtime Reminder

After sync/update completes, future normal work should use the target repository's updated `AGENTS.md` route plus `.ai/config.yaml`, `.ai/overrides/**`, `specs/**`, and Dev Cadence plugin-owned references/templates/built-in delivery disciplines/adapters. Do not continue into product delivery unless the user asks for a concrete delivery task in the same turn.
