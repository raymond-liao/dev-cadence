# Repository Rule Sync

Use this reference only when the user explicitly invokes `$dev-cadence` or names `dev-cadence` for update, sync, repair, inspect, diagnose, or maintenance of an already initialized repository.

## Core Model

After initialization, normal delivery work is routed by the target repository's root `AGENTS.md` to the repo-embedded Dev Cadence entrypoint at `.dev-cadence/skills/using-dev-cadence/SKILL.md`. Runtime authority is layered across repo-local entrypoint, optional local override file, task artifacts, `.dev-cadence/` references/templates/built-in delivery disciplines/adapters, and configured adapters.

The maintenance Skill becomes active again only for repository-rule maintenance. In that mode, update the repo-embedded contract so future ordinary work uses the intended runtime path.

## Allowed Modes

- `inspect`: read repo-local `AGENTS.md`, `.gitignore`, `.dev-cadence.yaml`, legacy `.ai/` when present, and `specs/` shape; report whether the repository appears initialized and where drift exists. Do not write.
- `sync` or `update`: reconcile the repo-embedded contract with the current Dev Cadence target-repo bundle while preserving local overlays. Write only framework runtime, entrypoint, local override, and artifact-space files.
- `repair`: restore missing or malformed repo-embedded contract files. Preserve local repository instructions and report any uncertain merge.
- `diagnose`: explain initialization or rule-routing problems and recommend exact fixes. Write only if the user explicitly asked to repair or update.

Maintenance modes are forbidden unless the user explicitly invokes `$dev-cadence` or names `dev-cadence`.

## Write Boundary

Allowed writes during rule maintenance:

- root `AGENTS.md` AI delivery entrypoint section;
- root `.gitignore` entry for `.dev-cadence.yaml`;
- root `.dev-cadence.yaml`;
- `.dev-cadence/` runtime bundle;
- `specs/records/.gitkeep` only when needed to represent an empty specs records directory.

Forbidden writes unless the same user turn explicitly asks for delivery work:

- product source, tests, migrations, build scripts, deployment files, runtime configuration, or dependency manifests;
- task-specific `specs/records/{task_id}/` artifacts;
- commits, pushes, releases, database operations, or production actions.

## Sync Record

Repo-embedded repositories do not need a generated sync record by default. Runtime authority is the layered model described in `skill-layout.md`.

If a future implementation adds a sync record, it must be audit metadata only and must not become runtime configuration.

## Drift Detection

Compare repo-local files against the current repo-embedded contract in `skill-layout.md`.

Classify each target as:

```text
missing
matches_current
local_overlay
outdated_generated
conflict_needs_review
unknown
```

Use `local_overlay` when the target repository intentionally adds project-specific constraints in existing instructions or legacy `.ai/` content. Preserve these unless they conflict with hard safety rules. Use `conflict_needs_review` when local content contradicts hard stops, weakens gate ownership, allows product edits during initialization, or lets non-Humans accept final completion.

## Merge Rules

- Preserve repository-specific instructions in root `AGENTS.md`; add or update only the AI delivery entrypoint section.
- Create `.dev-cadence.yaml` with commented preference fields when missing. Preserve existing uncommented user values when the file already exists.
- Ensure `.gitignore` contains `.dev-cadence.yaml`, preserving existing ignore rules.
- Supported `dev_cadence.artifact_language` values are `en` and `zh`; report unsupported values in `.dev-cadence.yaml` for manual review instead of guessing.
- Do not delete legacy `.ai/` files by default. Report them as `local_overlay` unless they conflict with generated responsibilities.
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

- root `AGENTS.md` routes normal delivery to `.dev-cadence/skills/using-dev-cadence/SKILL.md`;
- `.dev-cadence/` runtime bundle exists and contains `manifest.json`, `VERSION`, `skills/`, `references/`, `templates/`, and `scripts/`;
- `.dev-cadence.yaml` exists and `.gitignore` ignores it;
- legacy `.ai/` content is preserved and reported when present;
- hard rules are available through plugin-owned references;
- sync/update did not create task-specific specs or touch product files.

## Runtime Reminder

After sync/update completes, future normal work should use the target repository's updated `AGENTS.md` route plus `.dev-cadence/`, `.dev-cadence.yaml` when present, and `specs/**`. Do not continue into product delivery unless the user asks for a concrete delivery task in the same turn.
