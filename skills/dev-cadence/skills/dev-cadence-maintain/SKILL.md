---
name: dev-cadence-maintain
description: Maintain Dev Cadence repository configuration. Use when the user explicitly asks to inspect, sync, update, repair, diagnose, or upgrade an existing Dev Cadence thin repo-local contract.
---

# Dev Cadence Maintain

Use this Skill only for explicit Dev Cadence maintenance requests.

## Required References

Read these shared plugin resources before reporting or changing files:

- `../../references/repository-rule-sync.md`
- `../../references/skill-layout.md`
- `../../references/principles.md`

## Scope

Inspect, synchronize, repair, or diagnose the thin repo-local contract:

- root `AGENTS.md`;
- root `.gitignore` entry for `.ai/local.yaml`;
- `.ai/config.yaml`;
- `.ai/local.yaml`;
- `.ai/overrides/**`;
- `specs/.gitkeep`.

Do not touch product source, tests, migrations, runtime configuration, dependency manifests, task-specific specs, commits, pushes, releases, databases, or production systems.

## Required Behavior

Preserve existing repository instructions and local overlays.

Classify drift as `missing`, `matches_current`, `local_overlay`, `outdated_generated`, `conflict_needs_review`, or `unknown`.

Stop for a Human decision if maintenance would weaken safety rules or erase project knowledge.
