---
name: dev-cadence-authoring
description: Maintain Dev Cadence itself. Use when changing Dev Cadence skills, shared references, templates, scripts, adapters, roadmap, validation, or policy behavior.
---

# Dev Cadence Authoring

Use this Skill for maintaining Dev Cadence itself.

## Required References

Read these shared plugin resources before editing plugin behavior:

- `../../references/authoring-discipline.md`
- `../../references/skill-pressure-testing.md`
- `../../references/skill-layout.md`
- `../../references/delivery-disciplines.md`

## Scope

Maintain Dev Cadence skills, references, templates, scripts, adapters, roadmap, validation, and policy behavior.

Keep project design documents in Chinese under `docs/`. Keep shipped plugin content in English under `skills/**`, `references/**`, `templates/**`, `scripts/**`, and `hooks/**`.

## Required Behavior

Treat process documentation like code. Prefer narrow, validated changes over broad doctrine.

Run `dev-cadence` source validation before completion:

```bash
bash tests/run-all.sh
```

Update `docs/dev-cadence-roadmap.md` when roadmap item state changes.
