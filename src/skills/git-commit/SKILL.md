---
name: git-commit
description: Use when using-dev-cadence delegates a Dev Cadence-managed commit.
allowed-tools: Bash, Read, Grep
---

# Dev Cadence Git Commit

Use this shared capability only when `using-dev-cadence` delegates a commit owned by a Dev Cadence workflow or shared capability. Refuse direct use without that delegated context.

The caller owns commit timing, scope, checks, exact staging, and workflow evidence. This skill must not run `git add`, select or advance a workflow, run tests, create branches, or update manifests and stage records.

## Allowed Git Operations

- `git status`
- `git diff --cached`
- `git commit -m <message>`

Do not run `git add`. Inspect only the staged commit unit. If no staged changes exist, return without creating a commit.

## Commit Gate

1. Read the delegated Dev Cadence context and the caller's declared commit unit.
2. Inspect `git status --short`, staged paths with `git diff --cached --name-only`, `git diff --cached --stat`, and staged content with the complete `git diff --cached`. Inspect only the staged commit unit.
3. Stop and return control to the caller when staged content spans more than one declared Dev Cadence workflow or shared-capability scope, even if it is otherwise related or atomic.
4. Stop and return control to the caller when the staged set is empty, contains unrelated changes, or cannot form one atomic commit.
5. Apply the sensitive-content gate below. Any matching staged path or staged content blocks the commit; do not downgrade the result to a warning. Return control to the caller to correct the staged unit or obtain the required decision.
6. Generate one Conventional Commit message, show the message and staged files, then execute one `git commit -m` without requesting a second confirmation.
7. Return the commit result to the caller. The caller captures the full hash, verifies applicable identity, updates evidence, and continues the owning context.

## Sensitive-Content Gate

Block the commit when staged path inspection or staged content inspection finds any of the following:

- A non-example `.env` file or a runtime `.dev-cadence.yaml` file.
- Credential, secret, or token filename indicators.
- Private key files or material, including `.pem`, `.key`, `id_rsa`, `id_ed25519`, or `PRIVATE KEY` blocks.
- PID, log, or local runtime artifacts when repository policy prohibits them.
- Apparent live password, secret, token, API key, or credential values.
- Machine-specific absolute paths.

Do not treat documented rule names, obvious placeholders, examples, or test fixtures as live values solely because they contain words such as `password`, `secret`, `token`, `key`, or `credential`. Use surrounding staged content and the declared commit unit to distinguish those benign cases from a value that appears usable. If uncertain whether a path or value is sensitive, block the commit and return control to the caller.

## Message Rules

- Use `<type>[optional scope]: <description>`; scope is optional.
- Use `feat`, `fix`, `perf`, `refactor`, `style`, `docs`, `test`, `build`, `ci`, or `chore` according to the staged intent.
- `style` means formatting-only changes that do not change behavior; user-interface behavior or appearance changes use the type matching their actual intent.
- Describe the change's intent and impact accurately. Use technical terms when they are necessary for accuracy.
- Use an optional body for motivation and an optional footer for issue references or breaking changes.
- Do not add tool attribution.

## Return Boundary

Return control immediately after the commit result. Do not suggest `push`, `amend`, `reset`, merge, branch cleanup, or any other follow-up Git operation.
