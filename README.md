# Dev Cadence

[简体中文](README.zh-CN.md)

Dev Cadence is a software delivery governance framework for AI coding agents. It organizes AI work into configurable business workflows: Asset Workflows maintain durable authoritative documents, while Delivery Workflows produce auditable stage records, test evidence, acceptance decisions, and integration decisions.

It is built on top of a fixed, vendored copy of Superpowers and a small set of project-level instructions that make delivery stages visible, reviewable, and repeatable.

## Quickstart

From a Dev Cadence source checkout, install or update the package in your target repository, then wire the target repository's agent instructions to Dev Cadence:

```bash
bash scripts/install.sh /path/to/target-repo
```

The installer rebuilds the package and replaces the target repository's existing `.dev-cadence` directory, so updates do not retain stale files or create nested package directories. User configuration remains safe because `.dev-cadence.yaml` lives outside the installed package.

Then merge the snippet from:

```text
.dev-cadence/AGENTS-snippet.md
```

into the target repository's root `AGENTS.md`.

## How It Works

Dev Cadence starts when a user asks for product discovery, architecture design, requirements work, or development work. The agent first checks whether an installed Dev Cadence workflow applies instead of jumping directly into product documents or code.

If a workflow applies, the agent uses that workflow before implementation. Asset Workflows keep analysis and confirmation gates in the conversation and persist only authoritative assets. Delivery Workflows record stage artifacts and use the vendored Superpowers skills for the underlying engineering method: brainstorming, systematic debugging, planning, test-driven development, code review, verification, and branch finishing.

Dev Cadence does not replace Superpowers. It fixes the business workflow around Superpowers:

- which workflow applies;
- which stages require user confirmation;
- which durable assets or delivery records must exist;
- where task artifacts belong;
- which vendored Superpowers version the target repository uses.

For each Delivery Workflow run, Dev Cadence maintains a delivery evidence trail. A Dev Cadence Run Manifest ties the run together by recording the workflow type, branch, stage status, artifact paths, checkpoint commits, verification state, business acceptance state, and final integration decision. Asset Workflows do not create manifests or process-record copies of their authoritative documents.

Because the skills trigger through the target repository's `AGENTS.md`, users do not need special prompt wording. Once installed, normal product-discovery and development requests should enter the matching Dev Cadence workflow automatically.

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

**discovery** turns an incomplete product idea or business problem into the first version of two durable product-design documents:

```text
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

```text
Background And Problem Exploration -> Goal And Value Definition -> Scope And Business Architecture Analysis -> Product Design Baseline Creation -> Product Design Confirmation
```

Discovery covers product requirements and business architecture, not technical architecture, work-item decomposition, or application implementation. Its analysis stages and final confirmation gate stay in the conversation; its only primary new outputs are the PRD and Business Architecture. Technical input may be linked to an existing authoritative technical asset or maintained through the shared Open Question Registry under that asset's own rules; this supporting shared-asset maintenance is not a third Discovery output or a process record. The current S-001 capability creates only the first baseline; incremental updates to a baseline that existed before the current Discovery effort belong to S-002.

**architecture-design** handles explicit requests to design, propose, or review architecture for a stated goal. It creates one goal-named authoritative asset:

```text
docs/architecture/<goal-slug>.md
```

It investigates only the necessary current state, compares meaningful alternatives when they exist, and keeps diagrams inside the architecture document with Mermaid preferred. It is not triggered by repository state and does not replace a delivery workflow's task-scoped solution.

**feature-dev** handles new user-visible or system-visible features and intentional changes to expected behavior.

```text
Requirements Confirmation -> Technical Solution -> Implementation Plan -> Development Implementation -> System Testing -> Business Acceptance
```

**bug-fix** handles reported bugs, errors, regressions, failing tests, broken expected behavior, and unexpected behavior.

```text
Problem Diagnosis -> Repair Solution -> Repair Plan -> Repair Implementation -> Regression Verification -> Business Acceptance
```

**refactor** handles behavior-preserving internal improvements to structure, modularity, maintainability, testability, and dependencies.

```text
Requirements Confirmation -> Refactor Solution -> Refactor Plan -> Refactor Implementation -> Regression Verification -> Business Acceptance
```

The detailed execution rules live in each workflow skill. The README is only the product and installation guide.

## Workflow Records

Asset Workflows such as Architecture Design create or update authoritative documents under `docs/` and do not duplicate their process into run manifests, stage records, confirmation records, or checkpoint commits.

Delivery Workflows retain the evidence described below.

Delivery Workflow records belong in the target repository's normal workspace. They are not stored inside `.dev-cadence`. Discovery is an Asset Workflow and does not create this delivery record set.

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

Dev Cadence presents explicit user-visible statuses with a shared semantic marker plus the canonical status text, such as 🔄 `in_progress` or ⚠️ `ready_with_risk`. The text remains authoritative and machine-consumed status values are unchanged; markers are only a scanning aid for manifests, stage records, reports, acceptance summaries, and progress updates.

## What's Inside

```text
.dev-cadence/
  version
  LICENSE
  .dev-cadence.example.yaml
  README.md
  README.zh-CN.md
  AGENTS-snippet.md
  skills/
    using-dev-cadence/
      SKILL.md
    discovery/
      SKILL.md
    architecture-design/
      SKILL.md
    feature-dev/
      SKILL.md
    bug-fix/
      SKILL.md
    refactor/
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
- `skills/discovery/` - the initial product-discovery and product-design baseline workflow.
- `skills/architecture-design/` - the explicit, goal-driven architecture design workflow.
- `skills/feature-dev/` - the feature development workflow.
- `skills/bug-fix/` - the bug fix workflow.
- `skills/refactor/` - the behavior-preserving refactoring workflow.
- `.dev-cadence.example.yaml` - example runtime configuration for target repositories.
- `vendor/superpowers/` - the fixed Superpowers copy used by Dev Cadence.

## Configuration

To customize workflow output language, copy the example config to the target repository root:

```bash
cp .dev-cadence/.dev-cadence.example.yaml .dev-cadence.yaml
```

Then edit:

```text
.dev-cadence.yaml
```

Supported values:

- `en` - English workflow documents and records.
- `zh-CN` - Simplified Chinese workflow documents and records.

Worktree options:

- `worktree.enabled: false` - work in the current checkout unless explicitly requested.
- `worktree.enabled: true` - create or verify an isolated worktree without asking.
- `worktree.directory` - preferred project-local worktree directory.

Keep user configuration outside `.dev-cadence`. The `.dev-cadence` directory is replaced during Dev Cadence updates.

## Runtime Rules

- `.dev-cadence` contains workflow rules and vendored skills only.
- User configuration belongs in `.dev-cadence.yaml` at the target repository root, not inside `.dev-cadence`.
- Task artifacts, plans, reports, and acceptance records belong in the target repository's normal workspace, not inside `.dev-cadence`.
- Do not edit `vendor/superpowers/skills/` inside target repositories. Update Dev Cadence source and rebuild instead.
- Keep `vendor/superpowers/LICENSE` and `vendor/superpowers/RELEASE-NOTES.md` when using or distributing the package.

## Source Development

The source tree mirrors the installed package under `src/`:

```text
src/
  AGENTS-snippet.md
  .dev-cadence.example.yaml
  skills/
  vendor/
```

Build the installable package with:

```bash
bash scripts/build.sh
```

The build script only replaces `dist/.dev-cadence`.

Install or update that package in a target repository with:

```bash
bash scripts/install.sh /path/to/target-repo
```

Run all source, package, installation, and workflow contract checks with:

```bash
bash scripts/check-all.sh
```

## License

Dev Cadence is licensed under the MIT License. See `LICENSE`.

The vendored Superpowers copy is licensed under the MIT License. See `vendor/superpowers/LICENSE`.
