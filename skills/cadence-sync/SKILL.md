---
name: cadence-sync
description: Initialize, inspect, sync, repair, or diagnose the Dev Cadence repo-embedded repository contract. Use when the user asks to set up Dev Cadence, initialize repository rules, inspect configuration, repair drift, sync contract files, diagnose setup, or prepare artifact space.
---

# Cadence Sync

Use this Skill only for Dev Cadence repository contract work.

## Required References

Read these shared plugin resources before reporting or changing files:

- `../../references/repository-rule-sync.md`
- `../../references/skill-layout.md`
- `../../references/principles.md`

## Scope

Only create, inspect, synchronize, repair, or diagnose the repo-embedded Dev Cadence contract:

- `.dev-cadence/` runtime bundle;
- root `AGENTS.md`;
- root `.gitignore` entry for `.dev-cadence.yaml`;
- root `.dev-cadence.yaml`;
- `specs/records/.gitkeep`.

Do not touch product source, tests, migrations, runtime configuration, dependency manifests, task-specific specs, commits, pushes, releases, databases, or production systems.

## Behavior

Use `../../scripts/sync-target-repo-bundle.mjs` when deterministic target repository synchronization is needed. Use `../../scripts/package-target-repo-bundle.mjs` first when a fresh bundle must be generated from source.

Create low-risk directories or contract files directly when permissions allow and no conflicting user content exists. Stop for a Human decision when a write would overwrite project knowledge, weaken safety rules, or cross the contract boundary.

Classify drift as `missing`, `matches_current`, `local_overlay`, `outdated_generated`, `conflict_needs_review`, or `unknown`.

Repository contract setup is not a prerequisite for ordinary Dev Cadence help. Do not block delivery work just because the thin contract is absent.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
