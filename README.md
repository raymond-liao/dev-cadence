# Dev Cadence

[简体中文](README.zh-CN.md)

Dev Cadence is a software delivery governance framework for AI coding agents. It organizes AI development behavior into configurable business workflows and produces auditable stage records, test evidence, acceptance decisions, and integration decisions for each delivery.

It is built on top of a fixed, vendored copy of Superpowers and a small set of project-level instructions that make delivery stages visible, reviewable, and repeatable.

## Quickstart

Build the package, copy it into your target repository, then wire the target repository's agent instructions to Dev Cadence:

```bash
bash scripts/build.sh
cp -R dist/.dev-cadence /path/to/target-repo/.dev-cadence
```

Then merge the snippet from:

```text
.dev-cadence/AGENTS-snippet.md
```

into the target repository's root `AGENTS.md`.

## How It Works

Dev Cadence starts when a user asks for development work. The agent does not jump straight into code. It first checks whether an installed Dev Cadence workflow applies.

If a workflow applies, the agent uses that workflow before implementation. It confirms the business-facing stage outputs, records the stage artifacts, and then uses the vendored Superpowers skills for the underlying engineering method: brainstorming, systematic debugging, planning, test-driven development, code review, verification, and branch finishing.

Dev Cadence does not replace Superpowers. It fixes the business workflow around Superpowers:

- which workflow applies;
- which stages require user confirmation;
- which records must exist;
- where task artifacts belong;
- which vendored Superpowers version the target repository uses.

For each workflow run, Dev Cadence is intended to maintain a delivery evidence trail. A Dev Cadence Run Manifest ties the run together by recording the workflow type, branch, stage status, artifact paths, checkpoint commits, verification state, business acceptance state, and final integration decision.

Because the skills trigger through the target repository's `AGENTS.md`, users do not need special prompt wording. Once installed, normal development requests should enter the matching Dev Cadence workflow automatically.

## Enterprise Value

As AI coding agents enter engineering teams, the core enterprise problem is no longer only whether AI can write code. The harder problem is whether AI-generated delivery work can be managed, verified, reviewed, accepted, and audited.

Dev Cadence helps teams:

- reduce quality risk before AI-generated code reaches the main branch;
- reduce management risk from untracked AI decisions and undocumented verification;
- make AI-assisted delivery consistent across teams and repositories;
- preserve evidence for requirements, design decisions, tests, reviews, acceptance, and integration;
- turn good AI development practices into a reusable company standard.

Dev Cadence is not only a productivity tool for individual developers. It is a governance layer for using AI safely and consistently in real software delivery.

## Basic Workflows

**feature-dev** handles new user-visible or system-visible features and intentional changes to expected behavior.

```text
Requirements Confirmation -> Technical Solution -> Implementation Plan -> Development Implementation -> System Testing -> Business Acceptance
```

**bug-fix** handles reported bugs, errors, regressions, failing tests, broken expected behavior, and unexpected behavior.

```text
Problem Diagnosis -> Repair Solution -> Repair Plan -> Repair Implementation -> Regression Verification -> Business Acceptance
```

The detailed execution rules live in each workflow skill. The README is only the product and installation guide.

## Delivery Evidence

Workflow records belong in the target repository's normal workspace. They are not stored inside `.dev-cadence`.

The task-level run directory keeps every workflow artifact for the task together:

```text
build/dev-cadence/<workflow>/<task-slug>/
```

The task-level run index is the Dev Cadence Run Manifest:

```text
build/dev-cadence/<workflow>/<task-slug>/manifest.md
```

The same task directory also contains stage records and, when subagent-driven development is used, SDD task briefs, implementer reports, review packages, and progress ledgers under `sdd/`.

The manifest should connect:

- workflow type, task slug, and target branch;
- stage status and stage artifact paths;
- checkpoint commits;
- tests, checks, and verification results;
- business acceptance decision;
- final merge, PR, keep-branch, or discard decision.

## What's Inside

```text
.dev-cadence/
  version
  LICENSE
  config.md
  README.md
  README.zh-CN.md
  AGENTS-snippet.md
  skills/
    using-dev-cadence/
      SKILL.md
    feature-dev/
      SKILL.md
    bug-fix/
      SKILL.md
  vendor/
    superpowers/
      LICENSE
      RELEASE-NOTES.md
      skills/
```

The main pieces are:

- `AGENTS-snippet.md` - the snippet to merge into the target repository's root `AGENTS.md`.
- `skills/using-dev-cadence/` - the entry workflow selector.
- `skills/feature-dev/` - the feature development workflow.
- `skills/bug-fix/` - the bug fix workflow.
- `config.md` - runtime configuration, including workflow output language.
- `vendor/superpowers/` - the fixed Superpowers copy used by Dev Cadence.

## Configuration

Configure workflow output language in:

```text
.dev-cadence/config.md
```

Supported values:

- `en` - English workflow documents and records.
- `zh-CN` - Simplified Chinese workflow documents and records.

## Runtime Rules

- `.dev-cadence` contains workflow rules and vendored skills only.
- Task artifacts, plans, reports, and acceptance records belong in the target repository's normal workspace, not inside `.dev-cadence`.
- Do not edit `vendor/superpowers/skills/` inside target repositories. Update Dev Cadence source and rebuild instead.
- Keep `vendor/superpowers/LICENSE` and `vendor/superpowers/RELEASE-NOTES.md` when using or distributing the package.

## Source Development

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

## License

Dev Cadence is licensed under the Apache License 2.0. See `LICENSE`.

The vendored Superpowers copy is licensed under the MIT License. See `vendor/superpowers/LICENSE`.
