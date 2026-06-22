---
name: dev-cadence-authoring
description: Maintain the Dev Cadence framework or plugin package. Use when changing Dev Cadence skills, shared references, templates, scripts, adapters, roadmap, validation, or policy behavior.
---

# Dev Cadence Authoring

Use this Skill for maintaining Dev Cadence itself.

## Required References

Read these shared plugin resources before editing package behavior:

- `../../references/authoring-discipline.md`
- `../../references/skill-pressure-testing.md`
- `../../references/skill-layout.md`
- `../../references/delivery-disciplines.md`

## Scope

Maintain Dev Cadence skills, references, templates, scripts, adapters, roadmap, validation, and policy behavior.

Keep project design documents in Chinese under `docs/`. Keep shipped Skill package content in English under `skills/dev-cadence/**`.

## Required Behavior

Treat process documentation like code. Prefer narrow, validated changes over broad doctrine.

Run package validation before completion:

```bash
node skills/dev-cadence/scripts/check-skill-package.mjs skills/dev-cadence
node skills/dev-cadence/scripts/check-discipline-routes.mjs skills/dev-cadence
node skills/dev-cadence/scripts/check-spec-artifacts.mjs specs
```

Update `docs/dev-cadence-roadmap.md` when roadmap item state changes.
