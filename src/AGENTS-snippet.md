# Dev Cadence AGENTS.md Snippet

Copy the following section into the target repository's root `AGENTS.md`.

Do not rely on this file in place. It is only an installation snippet.

## Snippet

```markdown
## Dev Cadence

Before responding to or acting on requests involving product discovery, product ideas, architecture design, requirements or work-item management, development, active-task follow-up, testing, verification, Dev Cadence-managed assets, or commit/checkpoint operations, read and follow:

`.dev-cadence/skills/using-dev-cadence/SKILL.md`

Do this before any repository exploration, clarification question, user-facing guidance, document or code change, test execution, verification claim, or Git mutation.

Let `using-dev-cadence` determine whether an installed workflow, shared capability, or ordinary handling applies.

Worktree options:

- `worktree.enabled: false` - use an entry-prepared dedicated task branch and do not create a worktree.
- `worktree.enabled: true` - the entry creates or verifies an isolated worktree without asking.
- `worktree.directory` - preferred project-local worktree directory.
```
