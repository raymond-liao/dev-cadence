---
name: cadence-sync
description: Inspect, repair, diagnose, or reconcile a Dev Cadence repo-embedded repository contract. Use when Dev Cadence is already available from an embedded runtime, source checkout, global plugin, or supplied bundle, and the user asks to inspect local wiring, repair drift, diagnose activation, or reconcile against an explicit bundle/source.
---

# Cadence Sync

Use this Skill only for Dev Cadence repository contract maintenance after Dev Cadence is already available from an embedded runtime, source checkout, global plugin, or Human-supplied bundle/source. Its job is to inspect, repair, diagnose, or reconcile the target repository's Dev Cadence runtime entrypoint.

Initial bootstrap happens outside a missing target-repo Skill: use Dev Cadence source tooling, installation docs, a global plugin, or an explicit bundle path. Repository contract setup is not a prerequisite for ordinary Dev Cadence help. Treat a missing thin contract or `.dev-cadence/` runtime as local status unless the user asked to inspect, repair, diagnose, or reconcile Dev Cadence itself.

## Required References

Read these shared plugin resources before reporting or changing files:

- `../../references/repository-rule-sync.md`
- `../../references/skill-layout.md`
- `../../references/principles.md`

## Scope

Only inspect, repair, diagnose, or reconcile the repo-embedded Dev Cadence contract:

- `.dev-cadence/` runtime bundle;
- root `AGENTS.md`;
- root `.gitignore` entry for `.dev-cadence.yaml`;
- root `.dev-cadence.yaml`;
- `specs/records/.gitkeep`.

Do not touch product source, tests, migrations, runtime configuration, dependency manifests, task-specific specs, commits, pushes, releases, databases, or production systems.

## When to Use

Use this Skill when the user asks to:

- inspect whether Dev Cadence is wired correctly;
- diagnose Dev Cadence routing, activation, or repository contract problems;
- reconcile the repo-embedded `.dev-cadence/` runtime against an explicit bundle, source checkout, or expected version supplied by the Human/controller.
- repair drift in `AGENTS.md`, `.gitignore`, `.dev-cadence.yaml`, `.dev-cadence/`, or `specs/records/.gitkeep`;

## Mode Selection

Classify the requested maintenance mode before writing:

| Mode | Behavior |
|---|---|
| `inspect` | Read contract files and report state. Do not write. |
| `reconcile` | Compare and align the repo-embedded runtime against an explicit `expected_bundle_path`, `expected_source_path`, or `expected_version` supplied by the Human/controller. |
| `repair` | Restore missing or malformed contract files without erasing project knowledge. |
| `diagnose` | Explain routing or initialization failures and recommend exact fixes. |

## Comparison Target Requirement

This Skill does not discover upstream Dev Cadence updates. It cannot know that Dev Cadence is newer somewhere else unless the Human/controller supplies a comparison target.

Use these input fields when reconciling:

```yaml
mode: inspect | repair | diagnose | reconcile
target_repository:
expected_bundle_path: optional
expected_source_path: optional
expected_version: optional
```

Without `expected_bundle_path`, `expected_source_path`, or `expected_version`, report local runtime status only. Do not claim the runtime is current, stale, or updated. Use `unknown` for freshness relative to upstream.

## Runtime Reconcile Path

When `expected_source_path` is supplied, use its `scripts/package-target-repo-bundle.mjs` to generate a target-repo bundle from that source checkout. When `expected_bundle_path` is supplied, use it directly. Then use `sync-target-repo-bundle.mjs --target <repo> --bundle-dir <bundle>` from the same supplied source/bundle context for deterministic repo-embedded runtime reconciliation.

Use `../../scripts/sync-repo-contract.mjs` only for thin contract inspection, initialization, or repair when the repo-embedded runtime bundle is not being reconciled. Never use `sync-repo-contract.mjs` as proof that `.dev-cadence/` runtime is current; it does not install or update the full embedded runtime.

## Write Boundary

Allowed writes are limited to the contract files named in Scope. Preserve repository-specific instructions in `AGENTS.md`; add or update only the Dev Cadence marked section. Preserve existing uncommented `.dev-cadence.yaml` user values. Ensure `.gitignore` contains `.dev-cadence.yaml` without rewriting unrelated ignore rules.

Create low-risk directories or contract files directly when permissions allow and no conflicting user content exists. Stop for a Human decision when a write would overwrite project knowledge, weaken safety rules, or cross the contract boundary.

Never delete legacy `.ai/` content by default. Report it as a local overlay unless it conflicts with hard safety rules.

## Drift Classification

Classify local contract state as `missing`, `local_runtime_present`, `local_overlay`, `conflict_needs_review`, or `unknown`. Classify generated-runtime comparison as `matches_expected` or `outdated_generated` only when an explicit comparison target was supplied.

Use `local_overlay` for repository-owned additions that should be preserved. Use `conflict_needs_review` when local content contradicts hard stops, weakens gate ownership, allows product edits during contract maintenance, or lets non-Humans accept final completion.

## Sync Report

Return a report with these fields after inspect, repair, diagnose, or reconcile:

```yaml
mode:
repository:
initialized:
comparison_target:
upstream_freshness:
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

Verification should show whether `AGENTS.md` routes to `.dev-cadence/skills/using-dev-cadence/SKILL.md`, `.dev-cadence/` contains `manifest.json`, `VERSION`, `skills/`, `references/`, `templates/`, and `scripts/`, `.dev-cadence.yaml` exists and is ignored, `specs/records/` exists, local overlays were preserved, and product files or task-specific specs were not touched.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with the sync report, repository contract status, unresolved blockers, local overlays, required Human decisions, and recommended next state. Do not select the next cadence Skill from here.
