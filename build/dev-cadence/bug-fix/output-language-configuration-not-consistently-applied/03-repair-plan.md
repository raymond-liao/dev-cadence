# B-004 Repair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task after Repair Plan confirmation. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve the target repository's resolved Dev Cadence configuration when workflows enter or recover from project-local Git worktrees, so configured `zh-CN` output does not silently fall back to English.

**Architecture:** Add one shared configuration-propagation contract to the Dev Cadence entry rules. At a worktree boundary, resolve the primary checkout from `git rev-parse --git-common-dir`, copy the local `.dev-cadence.yaml` into the active worktree when available, and record the resolved language identity for the active Delivery run. Keep the vendored Superpowers copy unchanged; individual workflows reference the shared contract and apply the same fallback/reporting rules.

**Tech Stack:** Markdown workflow skills, Bash contract tests, Git worktrees, generated `dist/.dev-cadence` package.

## Global Constraints

- User configuration remains outside the replaceable `.dev-cadence/` package.
- `.dev-cadence.yaml` remains a local ignored file and is not made Git-tracked.
- Existing workflow stages, confirmation gates, record models, paths, IDs, commands, and canonical status values remain unchanged.
- All generated workflow records and user-visible summaries use the resolved `output_language`; this run uses `zh-CN`.
- Do not edit `src/vendor/superpowers/skills/**` unless implementation proves the shared Dev Cadence contract cannot own propagation.
- Root `version` must be evaluated and incremented because installed workflow behavior changes.

## Task Overview

| Task | Goal | Files | Verification |
|---|---|---|---|
| Task 1: Configuration propagation contract | Define the stable config source, worktree copy step, run snapshot, and visible fallback behavior. | `src/skills/using-dev-cadence/SKILL.md`, Delivery workflow skills | New configuration contract test fails before the rule changes and passes afterward. |
| Task 2: Workflow language coverage | Make every applicable workflow use the resolved language, including `work-item-analysis`. | `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, `src/skills/refactor/SKILL.md`, `src/skills/discovery/SKILL.md`, `src/skills/architecture-design/SKILL.md`, `src/skills/work-item-planning/SKILL.md`, `src/skills/work-item-analysis/SKILL.md` | Symmetry and configuration contract tests pass for all workflow surfaces. |
| Task 3: Propagation and fallback regression checks | Test the Git worktree boundary and ensure source/package rule contracts remain synchronized. | `tests/configuration-contract.sh`, `tests/run-all.sh` | Test detects missing config propagation and fallback visibility. Full check suite passes. |
| Task 4: Package release verification | Rebuild the distribution package and record the behavior change version. | `version`, generated `dist/.dev-cadence/**` | `bash scripts/build.sh`, package contract, whitespace check, and full check suite pass. |

## Detailed Tasks

### Task 1: Add the shared configuration propagation contract

**Files:**
- Modify: `src/skills/using-dev-cadence/SKILL.md` near the shared workflow-selection and continuation rules.
- Modify: `src/skills/feature-dev/SKILL.md` configuration and Implementation Plan sections.
- Modify: `src/skills/bug-fix/SKILL.md` configuration and Repair Plan sections.
- Modify: `src/skills/refactor/SKILL.md` configuration and Refactor Plan sections.
- Test: `tests/configuration-contract.sh`.

**Interfaces:**
- Consumes: target repository `.dev-cadence.yaml`, current Git workspace, and active Delivery manifest when one exists.
- Produces: a resolved language value, a stable configuration source identity, and a worktree-local config file when the primary checkout config exists.

- [x] **Step 1: Write the failing contract test.** Create `tests/configuration-contract.sh` with strict Bash mode and assertions for these exact behavioral contracts:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  rg --no-ignore -n "$pattern" "$ROOT_DIR/$path" >/dev/null || fail "$label: missing '$pattern' in $path"
}

assert_match "stable git common directory resolution" 'git rev-parse --git-common-dir' "src/skills/using-dev-cadence/SKILL.md"
assert_match "worktree config propagation" 'copy.*\.dev-cadence\.yaml|\.dev-cadence\.yaml.*copy' "src/skills/using-dev-cadence/SKILL.md"
assert_match "configuration snapshot" 'configuration snapshot|resolved language identity|output_language.*manifest' "src/skills/using-dev-cadence/SKILL.md"
assert_match "visible fallback" 'fallback.*visible|explain.*fallback|missing.*unsupported.*English' "src/skills/using-dev-cadence/SKILL.md"

for workflow in feature-dev bug-fix refactor; do
  assert_match "$workflow shared config reference" 'using-dev-cadence|configuration propagation|configuration snapshot' "src/skills/$workflow/SKILL.md"
done

printf 'Configuration contract checks passed.\n'
```

- [x] **Step 2: Run the new test to verify it fails.**

Run: `bash tests/configuration-contract.sh`

Expected: FAIL because the current entry skill has no Git-common-directory propagation contract and the delivery workflows do not reference one.

- [x] **Step 3: Add the minimal shared rule.** In `src/skills/using-dev-cadence/SKILL.md`, add a configuration lifecycle section with these exact operational rules:

```text
Before any workflow produces user-facing guidance, documents, records, or summaries, resolve `.dev-cadence.yaml` from the target repository configuration source.

When the current workspace is a linked worktree, resolve the primary checkout's `.git` location with `git rev-parse --git-common-dir`, take its parent as the primary checkout root, and use `<primary checkout root>/.dev-cadence.yaml` as the source when the current worktree does not contain the file.

When a primary checkout config exists and the current workspace is a different worktree, copy that ignored local config into the current worktree before generating workflow output. Do not copy it into `.dev-cadence/` or commit it.

For an active Delivery Workflow, record the resolved `output_language`, configuration source identity as `target repository root/.dev-cadence.yaml`, and whether worktree propagation occurred in the manifest. A resumed run must use this snapshot before applying fallback rules.

If no valid config is available and no active snapshot exists, use English and state in the first user-visible summary that the config was missing or unsupported and the default `en` was selected.
```

- [x] **Step 4: Reference the shared rule from each Delivery workflow.** In the Configuration and worktree-plan sections of `feature-dev`, `bug-fix`, and `refactor`, require the worker to apply the entry skill's configuration lifecycle before writing the plan or any later record. Keep their existing stage-specific names and record paths unchanged.

- [x] **Step 5: Run the focused test.**

Run: `bash tests/configuration-contract.sh`

Expected: PASS.

- [x] **Step 6: Commit the focused contract change.**

Run: `git add src/skills/using-dev-cadence/SKILL.md src/skills/feature-dev/SKILL.md src/skills/bug-fix/SKILL.md src/skills/refactor/SKILL.md tests/configuration-contract.sh && git commit -m "fix(flow): preserve config across worktrees"`

Expected: a commit on `codex/b-004-output-language-configuration-not-consistently-applied` containing only Task 1 files.

### Task 2: Align language coverage across all workflow surfaces

**Files:**
- Modify: `src/skills/discovery/SKILL.md` Configuration section.
- Modify: `src/skills/architecture-design/SKILL.md` Configuration section.
- Modify: `src/skills/work-item-planning/SKILL.md` Configuration section.
- Modify: `src/skills/work-item-analysis/SKILL.md` Configuration section.
- Modify: `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, and `src/skills/refactor/SKILL.md` only where required to align wording.
- Test: `tests/configuration-contract.sh` and existing workflow contract tests.

**Interfaces:**
- Consumes: the resolved language and fallback result from Task 1.
- Produces: consistent language rules for workflow guidance, proposals, durable assets, Delivery records, and user-facing summaries.

- [x] **Step 1: Extend the failing test with output-surface assertions.** Add assertions that `work-item-analysis` contains `Use the selected language` and that each Asset Workflow names its complete user-facing surface. Run `bash tests/configuration-contract.sh` and confirm FAIL before changing the skills.

- [x] **Step 2: Add explicit selected-language rules.** Update `work-item-analysis` to require the selected language for workflow guidance, in-conversation analysis proposals, user-facing analysis summaries, and durable work-item updates. Align Discovery, Architecture Design, and Work Item Planning with the same stable source, snapshot, and visible fallback contract without changing their Asset Workflow record boundary.

- [x] **Step 3: Preserve machine-readable exact values.** Add or retain an explicit rule that paths, commands, IDs, configuration values, and canonical statuses remain exact regardless of the selected human language.

- [x] **Step 4: Run focused workflow contracts.**

Run: `bash tests/configuration-contract.sh`

Expected: PASS.

Run: `bash tests/workflow-symmetry.sh && bash tests/work-item-planning-contract.sh && bash tests/work-item-analysis-contract.sh`

Expected: PASS with all workflow language and symmetry assertions satisfied.

- [x] **Step 5: Commit the focused language-coverage change.**

Run: `git add src/skills/discovery/SKILL.md src/skills/architecture-design/SKILL.md src/skills/work-item-planning/SKILL.md src/skills/work-item-analysis/SKILL.md src/skills/feature-dev/SKILL.md src/skills/bug-fix/SKILL.md src/skills/refactor/SKILL.md tests/configuration-contract.sh && git commit -m "fix(flow): align localized workflow output rules"`

Expected: a commit containing only Task 2 files and the updated contract test.

### Task 3: Add worktree-boundary and fallback regression checks

**Files:**
- Modify: `tests/configuration-contract.sh`.
- Modify: `tests/run-all.sh`.

**Interfaces:**
- Consumes: the configuration lifecycle text from Tasks 1 and 2.
- Produces: executable evidence that the ignored config is absent from a fresh linked worktree and that the prescribed common-directory lookup can find it.

- [x] **Step 1: Add a temporary Git fixture test.** Extend `tests/configuration-contract.sh` with a `mktemp -d` fixture, an initialized repository, an ignored `.dev-cadence.yaml`, a committed marker file, and a linked worktree. Assert:

```bash
test -f "$PRIMARY_ROOT/.dev-cadence.yaml"
test ! -e "$WORKTREE/.dev-cadence.yaml"
COMMON_GIT_DIR="$(cd "$(git -C "$WORKTREE" rev-parse --git-common-dir)" && pwd -P)"
test "$(dirname "$COMMON_GIT_DIR")/.dev-cadence.yaml" = "$PRIMARY_ROOT/.dev-cadence.yaml"
```

The fixture must remove only its own temporary directory through a local trap and must not create a worktree inside the project repository.

- [x] **Step 2: Run the fixture before changing the propagation implementation.**

Run: `bash tests/configuration-contract.sh`

Expected: the fixture passes for Git mechanics, while the rule assertions fail until Tasks 1 and 2 are complete. After Tasks 1 and 2, the complete test must pass.

- [x] **Step 3: Register the test in the suite.** Add `bash "$ROOT_DIR/tests/configuration-contract.sh"` to `tests/run-all.sh` after `document-conventions-contract.sh` and before the workflow-specific contracts.

- [x] **Step 4: Run the complete existing suite.**

Run: `bash tests/run-all.sh`

Expected: PASS, including package source-to-distribution checks and installation checks.

- [x] **Step 5: Commit the regression test.**

Run: `git add tests/configuration-contract.sh tests/run-all.sh && git commit -m "test(flow): cover config propagation boundaries"`

Expected: a commit containing only the new regression coverage and suite registration.

### Task 4: Bump package version and verify distribution

**Files:**
- Modify: `version` from `0.21.0` to `0.22.0`.
- Generated: `dist/.dev-cadence/**` via `bash scripts/build.sh`; do not edit generated files directly.

**Interfaces:**
- Consumes: all source rule and test changes from Tasks 1-3.
- Produces: a package whose generated skills match `src/` and whose version identifies the behavior fix.

- [x] **Step 1: Update the version.** Change only the root `version` value to `0.22.0` and verify the change with `git diff -- version`.

- [x] **Step 2: Rebuild the package.**

Run: `bash scripts/build.sh`

Expected: `dist/.dev-cadence/` is regenerated from the current `src/` tree, including all updated skills and tests' required package files.

- [x] **Step 3: Run final source/package checks.**

Run: `bash scripts/check-whitespace.sh && bash tests/package-contract.sh && bash tests/configuration-contract.sh`

Expected: all checks pass and no package contains local absolute paths, secrets, or stale run records.

- [x] **Step 4: Self-review the full diff.**

Run: `git diff --check && git diff --stat && git status --short`

Expected: only B-004 source rules, tests, version, and generated ignored distribution output are present; unrelated worktree or repository changes are absent.

- [x] **Step 5: Commit the package release update.**

Run: `git add version src/skills tests && git commit -m "fix(flow): stabilize output language configuration"`

Expected: a final implementation commit on the dedicated B-004 branch. Do not push, merge, or delete the branch.

## Implementation Completion Conditions

- All four tasks are complete and their focused checks pass.
- The new regression check demonstrates the ignored-config worktree boundary and the common-directory source resolution.
- Every affected workflow explicitly uses the resolved language and reports fallback when necessary.
- `dist/.dev-cadence` matches source after `bash scripts/build.sh`.
- Code review and Regression Verification records are written before Business Acceptance.
