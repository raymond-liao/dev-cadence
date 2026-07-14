# Work Item Scope Semantic Markers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enforce and migrate semantic scope headings across Dev Cadence work-item cards.

**Architecture:** Keep the normative presentation contract in the shared document-conventions skill. Use one focused shell contract to verify both the shared rule and all current work-item cards, then rebuild and dogfood the package.

**Tech Stack:** Markdown, Bash, ripgrep, Dev Cadence build/install scripts.

## Global Constraints

- Preserve all work-item business content.
- Do not edit vendored Superpowers sources.
- Build from `src/`; do not hand-edit `dist/`.

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Add contract and shared rule | Define and enforce semantic work-item scope headings. | `tests/document-conventions-contract.sh`, `src/skills/document-conventions/SKILL.md` | Focused contract fails before and passes after implementation. |
| Task 2: Migrate existing cards | Update all current Story and Task scope headings without body changes. | `docs/stories/*.md`, `docs/tasks/*.md` | Focused contract and diff review. |
| Task 3: Release and verify | Synchronize package copies and validate the repository. | `version`, generated `dist/.dev-cadence`, dogfood `.dev-cadence` | Build, source/dist/dogfood comparisons, whitespace and full checks. |

## Detailed Tasks

### Task 1: Add Contract And Shared Rule

- [x] Add failing assertions for the headings, work-item types, semantic boundaries, and existing-card scan.
- [x] Run `bash tests/document-conventions-contract.sh`; expect failure for the missing shared heading rule.
- [x] Add the minimal normative work-item section to the source document-conventions skill.
- [x] Run the focused contract; confirm the rule is present and card migration remains the next requirement.

### Task 2: Migrate Existing Cards

- [x] Replace legacy `## 范围` and `## 非范围` headings in every current Story card.
- [x] Preserve the already-compliant Task card and all ordinary list items.
- [x] Run `bash tests/document-conventions-contract.sh`; confirmed pass.
- [x] Review the diff to confirm no work-item body semantics changed.

### Task 3: Release And Verify

- [x] Bump `version` from `0.10.0` to `0.11.0` because the installable authoring contract changes.
- [x] Run `bash scripts/build.sh`.
- [x] Run dogfood installation against the current worktree.
- [x] Verify source, dist, and installed document-conventions rules match.
- [x] Run `bash scripts/check-whitespace.sh` and `bash scripts/check-all.sh`.
- [x] Complete implementation and review records, then create the implementation commit through the executing-plans review gate.
