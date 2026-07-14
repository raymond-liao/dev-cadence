# S-001 Discovery Product-Design Baseline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use vendored `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an installable `discovery` workflow that turns incomplete product input into version-1 PRD and Business Architecture documents under `docs/product-design/` without creating work items, technical architecture, or application code.

**Architecture:** A focused standalone `src/skills/discovery/SKILL.md` owns Discovery stages, records, product-design document contracts, and final confirmation. `using-dev-cadence` remains the single router, while shell contracts verify the executable Markdown rules, packaging, installation, and source-to-dist synchronization.

**Tech Stack:** Markdown workflow skills, Bash contract tests, `rg`, existing build/install scripts.

## Global Constraints

- S-001 creates only version `1`; existing product-design documents must not be overwritten or incrementally reconciled.
- Durable outputs are `docs/product-design/prd.md` and `docs/product-design/business-architecture.md`.
- Unresolved material uses `Open Questions`; do not create `Draft Ideas` or `Pending Decisions` sections.
- Product documents contain Change Logs but no workflow approval metadata.
- Discovery must not create Feature, Story, Bug, Technical Task, Roadmap, technical architecture, migrations, or application code.
- Do not modify `src/vendor/superpowers/**`.
- During implementation and verification, leave changes uncommitted for user review. If the user later explicitly requests a commit, commit the verified change set without treating that commit as Business Acceptance.

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Discovery contract | Define executable acceptance checks and observe the required RED failure. | `tests/discovery-contract.sh`, `tests/run-all.sh` | `bash tests/discovery-contract.sh` fails because the skill is missing. |
| Task 2: Workflow implementation | Add Discovery rules, routing, target-repository entry instructions, and product-design boundaries. | `src/skills/discovery/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md`, `src/AGENTS-snippet.md` | `bash tests/discovery-contract.sh` passes. |
| Task 3: Package and public contract | Publish the new workflow consistently and update dependent documentation for acceptance. | `tests/package-contract.sh`, `tests/skill-description-contract.sh`, `docs/workflows/discovery.md`, `README.md`, `README.zh-CN.md`, `docs/stories/S-001-initial-discovery-prd-baseline.md`, `docs/stories/S-002-discovery-prd-incremental-versioning.md`, `docs/backlog.md`, `version` | Focused contracts and source/dist checks pass after build. |
| Task 4: Review and verification | Review the complete diff, record evidence, and leave a cleanly verifiable uncommitted result. | `build/dev-cadence/feature-dev/s-001-discovery-prd-baseline/04-implementation-record.md`, `04-code-review-report.md`, `05-system-test-report.md`, `manifest.md` | `bash scripts/check-whitespace.sh` and `bash scripts/check-all.sh` pass; `rg --no-ignore` confirms source/dist synchronization. |

## Detailed Tasks

### Task 1: Discovery Contract

**Files:**
- Create: `tests/discovery-contract.sh`
- Modify: `tests/run-all.sh`

**Interfaces:**
- Consumes: repository-relative skill and document paths from the confirmed Technical Solution.
- Produces: a standalone executable contract invoked by `tests/run-all.sh`.

- [x] **Step 1: Create the failing contract**

Create Bash assertions for:

```text
src/skills/discovery/SKILL.md
build/dev-cadence/discovery/<discovery-slug>/manifest.md
docs/product-design/prd.md
docs/product-design/business-architecture.md
Background And Problem Exploration -> Goal And Value Definition -> Scope And Business Architecture Analysis -> Product Design Baseline Creation -> Product Design Confirmation
```

Also assert the skill contains input precedence, Open Questions, Rejected Directions, Future Scope, Change Log, existing-document refusal, one final confirmation, and explicit exclusions for work items, technical architecture, migrations, and application code. Assert the entry selector preserves direct `feature-dev`, `bug-fix`, and `refactor` routes.

- [x] **Step 2: Register the contract**

Add this line after the package contract in `tests/run-all.sh`:

```bash
bash "$ROOT_DIR/tests/discovery-contract.sh"
```

- [x] **Step 3: Verify RED**

Run:

```bash
bash tests/discovery-contract.sh
```

Expected: non-zero exit with `missing Discovery skill` because `src/skills/discovery/SKILL.md` does not exist.

### Task 2: Workflow Implementation

**Files:**
- Create: `src/skills/discovery/SKILL.md`
- Modify: `src/skills/using-dev-cadence/SKILL.md`
- Modify: `src/AGENTS-snippet.md`

**Interfaces:**
- Consumes: the contract created in Task 1 and vendored `brainstorming`.
- Produces: the installable Discovery workflow and entry routing used by later package contracts.

- [x] **Step 1: Implement the standalone skill**

Define:

```text
Background And Problem Exploration
-> Goal And Value Definition
-> Scope And Business Architecture Analysis
-> Product Design Baseline Creation
-> Product Design Confirmation
```

The skill must read repository sources and explicit user confirmations before weaker notes, preserve conflicts as Open Questions, maintain portable run records, create both product-design documents, forbid overwrite when either exists, and end after one consolidated user confirmation.

- [x] **Step 2: Add routing without forcing Discovery**

Update the entry table and priority rules so broad product ideas and first-time PRD or Business Architecture creation route to `.dev-cadence/skills/discovery/SKILL.md`. Explicit Feature, Bug, and Refactor requests continue directly to their delivery workflows. Existing-product-design update requests must not claim S-001 support.

- [x] **Step 3: Expand the installed AGENTS trigger**

Make target repositories check Dev Cadence for product discovery and requirements work as well as development, testing, verification, and checkpoint requests.

- [x] **Step 4: Verify GREEN**

Run:

```bash
bash tests/discovery-contract.sh
```

Expected: `Discovery contract checks passed.`

### Task 3: Package And Public Contract

**Files:**
- Modify: `tests/package-contract.sh`
- Modify: `tests/skill-description-contract.sh`
- Modify: `docs/workflows/discovery.md`
- Modify: `README.md`
- Modify: `README.zh-CN.md`
- Modify: `docs/stories/S-001-initial-discovery-prd-baseline.md`
- Modify: `docs/stories/S-002-discovery-prd-incremental-versioning.md`
- Modify: `docs/backlog.md`
- Modify: `version`

**Interfaces:**
- Consumes: the implemented skill and existing recursive build behavior.
- Produces: version `0.9.0`, synchronized installable package metadata, and user-facing workflow documentation.

- [x] **Step 1: Extend package and description contracts**

Require `dist/.dev-cadence/skills/discovery/SKILL.md`, define the exact Discovery description, and apply the trigger-only description check.

- [x] **Step 2: Update the business workflow document**

Describe the S-001 initial-only workflow, two product-design outputs, five revised stages, Open Questions rule, Change Logs, and the boundary before work-item planning and technical architecture.

- [x] **Step 3: Update public installation documentation**

Add Discovery to both workflow overviews, package trees, component lists, and the explanation of when Dev Cadence starts.

- [x] **Step 4: Update the Story for acceptance**

Update S-001 to version `5` while keeping status `In Progress`, align its scope and acceptance criteria with the two-document baseline, and add a Change Log entry stating that implementation is ready for Business Acceptance. Keep the backlog entry in `进行中`. Update the future S-002 Story to version `4` so its requirements consistently describe incremental governance of both product-design documents, but keep it `Blocked` until the user accepts S-001.

- [x] **Step 5: Bump package version**

Change root `version` from `0.8.5` to `0.9.0` because Discovery adds a new installable workflow. This follows the repository precedent of using a minor release for a new workflow, such as the `0.6.6` to `0.7.0` refactor-workflow release.

- [x] **Step 6: Build and run focused contracts**

Run:

```bash
bash scripts/build.sh
bash tests/discovery-contract.sh
bash tests/package-contract.sh
bash tests/skill-description-contract.sh
bash tests/install-contract.sh
```

Expected: every command exits `0` and reports its passing message.

### Task 4: Review And Verification

**Files:**
- Create: `build/dev-cadence/feature-dev/s-001-discovery-prd-baseline/04-implementation-record.md`
- Create: `build/dev-cadence/feature-dev/s-001-discovery-prd-baseline/04-code-review-report.md`
- Create: `build/dev-cadence/feature-dev/s-001-discovery-prd-baseline/05-system-test-report.md`
- Modify: `build/dev-cadence/feature-dev/s-001-discovery-prd-baseline/manifest.md`

**Interfaces:**
- Consumes: the complete working-tree diff and verification output.
- Produces: reviewable implementation and system-test evidence without a commit.

- [x] **Step 1: Review the complete diff**

Inspect `git diff --check`, `git diff --stat`, the complete diff, new untracked files, portable paths, source/dist synchronization, routing ambiguity, S-001/S-002 state transitions, and accidental changes under `src/vendor/superpowers/`.

- [x] **Step 2: Fix all Critical and Important findings**

Record each finding and resolution in `04-code-review-report.md`. If no findings remain, state that explicitly and list residual test or interpretation risks.

- [x] **Step 3: Run full verification**

Run:

```bash
bash scripts/check-whitespace.sh
bash scripts/check-all.sh
rg --no-ignore -n "docs/product-design/prd.md|docs/product-design/business-architecture.md" src/skills/discovery/SKILL.md dist/.dev-cadence/skills/discovery/SKILL.md
git status --short
```

Expected: both check scripts exit `0`; source and dist contain both paths; status lists only task-related uncommitted changes.

- [x] **Step 4: Record the handoff state**

Mark Development Implementation and System Testing complete in the manifest, leave Business Acceptance `pending`, record that the user requested no implementation commit, and retain all changes for user review.

## Plan Self-Review

- Acceptance criteria coverage: Tasks 1-3 cover both product-design outputs, routing, boundaries, packaging, versioning, and installation; Task 4 covers review and full verification.
- Placeholder scan: no deferred implementation placeholders remain.
- Path consistency: all runtime and test paths match the Technical Solution.
- Scope control: S-002 implementation remains excluded and blocked until S-001 receives Business Acceptance; only its future Story contract is aligned with the confirmed two-document model.

## Plan Decision

- Execution mode: inline execution with vendored `executing-plans`.
- User authorization: continue through implementation and verification without intermediate confirmation.
- Git result: implementation remained uncommitted through verification; the user later requested all changes be committed. Commit `52139c0` records the verified implementation without changing Business Acceptance state.
