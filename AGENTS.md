# Repository Guidelines

## Project Structure & Module Organization

This repository documents an AI-native software delivery framework and packages the `dev-cadence` Codex skill.

- `README.md`: primary framework proposal and architecture overview.
- `docs/`: supporting design notes.
- `skills/dev-cadence/`: skill package, including `SKILL.md`, `agents/`, and `references/`.
- `research/`: studies, agent prompts, materials, analysis, verification, and reports.

Keep new framework references near the relevant existing reference file. Put exploratory or study-specific material under `research/`, not `skills/`, unless it is part of the shipped skill.

## Build, Test, and Development Commands

There is no application build pipeline in this repository. Useful local checks are:

- `rg --files`: list tracked project files quickly.
- `rg "term" README.md skills docs research`: search framework terminology and avoid conflicting definitions.
- `git diff -- README.md skills docs research`: review documentation and skill changes before committing.

If you add generated artifacts or scripts, document their commands in the same change.

## Coding Style & Naming Conventions

Most content is Markdown. Use ATX headings (`#`, `##`), short sections, and fenced code blocks with language hints where helpful. Keep framework terms consistent with existing usage, for example `Supervisor`, `Harness`, `Context Pack`, `Human Gate`, and `Quality Gate`.

Use lowercase, hyphenated filenames for Markdown references, such as `quality-gates.md` or `skill-layout.md`. Preserve existing numbered prefixes in research agent files, such as `00.orchestrator.md`.

## Testing Guidelines

No automated tests are currently configured. Validate changes by reading rendered Markdown, checking links and paths, and searching for duplicate or contradictory rules. For skill behavior changes, inspect `skills/dev-cadence/SKILL.md` with the directly referenced file under `skills/dev-cadence/references/`.

For future code-bearing examples or tools, prefer TDD. If TDD does not fit documentation-only work, name the substitute feedback used.

## Commit & Pull Request Guidelines

Recent history uses Conventional Commits, for example `docs(skill): prepare authoring pre-spec` and `docs(framework): ...`. Prefer `docs(scope): concise summary` for documentation changes.

Pull requests should include purpose, affected directories, notable terminology or policy changes, and manual validation performed. Link related issues or research notes when applicable.

## Agent-Specific Instructions

Do not treat chat as the durable source of truth for framework behavior. Update stable artifacts when rules change.

Use the smallest process that preserves safety, evidence, reviewability, and handoff quality. XP/TDD complements this framework at the Worker Agent execution layer; it does not replace Supervisor, Harness, Quality Gate, or Human Gate responsibilities.
