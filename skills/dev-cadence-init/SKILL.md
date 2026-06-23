---
name: dev-cadence-init
description: Initialize Dev Cadence in a repository. Use when the user asks to install, initialize, set up, or prepare repository-level AI-assisted delivery rules, workflows, gates, templates, or thin Dev Cadence configuration.
---

# Dev Cadence Init

Use this Skill only for repository-level Dev Cadence initialization.

## Required References

Read these shared plugin resources before changing files:

- `../../references/skill-layout.md`
- `../../references/principles.md`

## Scope

Initialize or update only the thin repo-local contract:

- root `AGENTS.md`;
- root `.gitignore` entry for `.dev-cadence.yaml`;
- root `.dev-cadence.yaml`;
- `specs/.gitkeep`.

Do not create task-specific specs, Harness runs, or product changes unless the same user turn explicitly requests a concrete delivery task.

## Required Behavior

Preserve existing repository instructions. Add or update only the scoped Dev Cadence delivery entrypoint.

Generate `.dev-cadence.yaml` with commented local preference examples only. Ensure `.dev-cadence.yaml` is ignored by Git.

After initialization, ordinary delivery work should be routed by the repository's `AGENTS.md` to Dev Cadence delivery behavior. The user should not need to invoke this initialization Skill for normal feature, bugfix, refactor, review, research, or incident requests.
