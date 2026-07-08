# Dev Cadence

Dev Cadence is a business workflow layer for coding agents, built on top of vendored Superpowers skills and a small set of project-level instructions that make the agent follow visible delivery stages.

## Quickstart

Copy `.dev-cadence` into your target repository, then merge `.dev-cadence/AGENTS-snippet.md` into the repository's root `AGENTS.md`.

## How It Works

Dev Cadence starts when a user asks for development work. The agent first reads `using-dev-cadence`, checks the installed flows, and only enters a flow when the request matches one.

Right now, the installed business flow is `feature-dev`. It covers new user-visible or system-visible features and changes to intended feature behavior.

Once `feature-dev` starts, the agent does not jump straight into code. It walks through the business stages with explicit user confirmation:

```text
Requirements Confirmation -> Technical Solution -> Implementation Plan -> Development Implementation -> System Testing -> Business Acceptance
```

The execution method still comes from Superpowers: brainstorming, writing plans, test-driven development, execution, verification, and branch finishing. Dev Cadence makes those steps visible as business stage outputs and records.

## Install In A Target Repository

Copy the built `.dev-cadence` directory into the target repository, then merge the snippet from `.dev-cadence/AGENTS-snippet.md` into the target repository's root `AGENTS.md`.

After installation, development work requests first read:

```text
.dev-cadence/skills/using-dev-cadence/SKILL.md
```

If the request is a new feature or a change to existing feature behavior, the entry skill routes to:

```text
.dev-cadence/skills/feature-dev/SKILL.md
```

## Installed Contents

```text
.dev-cadence/
  version
  config.md
  README.md
  AGENTS-snippet.md
  skills/
    using-dev-cadence/
      SKILL.md
    feature-dev/
      SKILL.md
  vendor/
    superpowers/
      LICENSE
      RELEASE-NOTES.md
      skills/
```

`vendor/superpowers/` is the fixed Superpowers copy used by Dev Cadence. Keep `vendor/superpowers/LICENSE` and `vendor/superpowers/RELEASE-NOTES.md` when using or distributing the package.

## Runtime Rules

- `.dev-cadence` contains workflow rules and vendored skills only.
- Task artifacts, plans, reports, and acceptance records belong in the target repository's normal workspace, not inside `.dev-cadence`.
- Do not edit `vendor/superpowers/skills/` inside target repositories. Update Dev Cadence source and rebuild instead.
- Configure workflow output language in `.dev-cadence/config.md`.

## Source Repository

The source tree mirrors the installed package under `src/`:

```text
src/
  AGENTS-snippet.md
  config.md
  skills/
  vendor/
```

Build the installable package with:

```bash
bash scripts/build.sh
```

The build script only replaces `dist/.dev-cadence`.
