# Dev Cadence AGENTS.md Snippet

Copy the following section into the target repository's root `AGENTS.md`.

Do not rely on this file in place. It is only an installation snippet.

## Snippet

```markdown
## Dev Cadence

When the user asks for product discovery, product ideas, requirements work, development work, active-task follow-up, testing, verification, or commit/checkpoint operations, check Dev Cadence before any repository exploration, product-design changes, implementation, Git mutation, or clarifying question:

`.dev-cadence/skills/using-dev-cadence/SKILL.md`

If an installed Dev Cadence flow applies, use it. If no installed flow applies, handle the request normally.

Root-level `*.md` files and all files under `docs/` do not require new or updated automated tests. Do not add or modify tests solely because those documentation files changed. If the same task changes executable behavior, test that executable behavior.
```
