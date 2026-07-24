---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Detect environment → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Detect Environment

**Determine workspace state before presenting options:**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# Capture now, while still inside the workspace. Step 5 changes directory
# before cleanup needs this value.
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

This determines which menu to show and how cleanup works:

| State | Menu | Cleanup |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (normal repo) | Standard 4 options | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Standard 4 options | Provenance-based (see Step 6) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Reduced 3 options (no merge) | No cleanup (externally managed) |

### Step 3: Determine and Freeze Merge Identity

For a normal checkout or named-branch worktree, determine the base branch before presenting Completion options. Prefer the local `main` branch; if it does not exist, use local `master`. If neither exists, stop and ask the user for the base branch. The merge-base result is ancestry evidence only; it must not replace the base branch name.

```bash
if git show-ref --verify --quiet refs/heads/main; then
  BASE_BRANCH=main
elif git show-ref --verify --quiet refs/heads/master; then
  BASE_BRANCH=master
else
  printf 'Base branch not found; stop and ask the user.\n' >&2
  exit 1
fi

git merge-base HEAD "$BASE_BRANCH" >/dev/null
FEATURE_BRANCH=$(git branch --show-current)
test -n "$FEATURE_BRANCH"
EXPECTED_FEATURE_SHA=$(git rev-parse "$FEATURE_BRANCH")
EXPECTED_BASE_SHA=$(git rev-parse "$BASE_BRANCH")
```

Record the snapshot in the current Completion context:

```text
Base branch: <BASE_BRANCH>
Base SHA: <EXPECTED_BASE_SHA>
Feature branch: <FEATURE_BRANCH>
Feature SHA: <EXPECTED_FEATURE_SHA>
```

If base selection, ancestry verification, branch identity, or SHA capture fails, stop before presenting or executing a local Merge. Any failure stops the flow before cleanup and completion reporting. The branch is preserved on identity mismatch.

### Step 4: Present Options

**Normal repo and named-branch worktree — present exactly these 4 options:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Detached HEAD — present exactly these 3 options:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)
3. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 5: Execute Choice

#### Option 1: Merge Locally

```bash
# Get main repo root for CWD safety
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# Revalidate the immutable Merge snapshot before changing checkout state.
test "$(git rev-parse "$FEATURE_BRANCH")" = "$EXPECTED_FEATURE_SHA"
test "$(git rev-parse "$BASE_BRANCH")" = "$EXPECTED_BASE_SHA"
test -z "$(git status --short --untracked-files=all)"

git checkout "$BASE_BRANCH"
test -z "$(git status --short --untracked-files=all)"

# This is a local-only Merge. Do not call git pull or git fetch here.
if git merge-base --is-ancestor "$EXPECTED_FEATURE_SHA" "$BASE_BRANCH"; then
  MERGE_RESULT=already-integrated
else
  git merge "$EXPECTED_FEATURE_SHA"
  MERGE_RESULT=merged
fi

# Verify the exact approved commit is in the target before cleanup.
git merge-base --is-ancestor "$EXPECTED_FEATURE_SHA" "$BASE_BRANCH"
FINAL_BASE_SHA=$(git rev-parse "$BASE_BRANCH")
test -z "$(git status --short --untracked-files=all)"

# Verify tests on merged result
<test command>

# A failed command, conflict, or verification check stops here and preserves
# the branch/worktree. Recheck identity before any branch deletion.
test "$(git rev-parse "$FEATURE_BRANCH")" = "$EXPECTED_FEATURE_SHA"

# Only after merge succeeds: cleanup worktree (Step 6), then delete branch
```

Then: Cleanup worktree (Step 6), then delete branch:

```bash
git branch -d "$FEATURE_BRANCH"
```

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>
```

**Do NOT clean up worktree** — user needs it alive to iterate on PR feedback.

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

### Dev Cadence Whole-Run Discard

Use this mode only when the caller supplies all current-run fields:

- Workflow
- Task slug
- Run directory
- Task branch
- Expected HEAD SHA
- Base branch
- Expected base SHA
- Owned commit range
- Owned tracked and untracked paths
- Workspace path
- Worktree created by this run

If any field is missing or conflicts with current Git or filesystem state, do not execute Discard. Return `discard_blocked` with the mismatched fields.

Before any destructive confirmation, take a complete identity snapshot for the supplied run: the exact run directory, task branch and expected HEAD SHA, base branch and expected base SHA, owned commit range, owned tracked and untracked paths, workspace path, worktree creation evidence, and complete classified path set.

Current-run creation evidence and `git worktree list --porcelain` must agree on path, branch, and Git identity. Directory naming is not ownership evidence.

Before presenting the three choices, exhaustively enumerate every changed path and classify it as current-run, external, or unknown. Treat unknown as external.

When the classification contains external or unknown changes, present exactly these choices:

```
1. Discard the current run only
2. Discard the entire owned workspace or branch
3. Cancel
```

The first destructive confirmation must state the exact run directory, task branch and SHA, owned commit range, owned paths, and owned worktree. It must include this warning:

```
Successful Discard deletes the run directory and every independently deletable current-run object; an owned branch or worktree retained to preserve external or unknown changes remains outside the deletion, and no persistent run record will remain.
```

For the first destructive confirmation, require the user to type the exact literal `discard`. A missing or invalid response returns `discard_cancelled` or `discard_blocked` without changing Git or filesystem state.

For choice 2, list every additional external or unknown path and require a second exact confirmation that names the expanded deletion scope. Choice 3 returns `discard_cancelled` without changing Git or filesystem state.

Immediately after final user confirmation and before any destructive command, repeat the complete identity snapshot and compare it with the confirmed snapshot. Any mismatch returns `discard_blocked` without changing Git or filesystem state.

Immediately after final user confirmation and before any destructive command, re-enumerate and reclassify every changed path as current-run, external, or unknown and compare the complete classified path set with the confirmed snapshot. Any change, addition, deletion, or classification mismatch returns `discard_blocked` without changing Git or filesystem state.

Immediately after final user confirmation and before any destructive command, freeze the exact task branch ref and `Expected Current HEAD SHA` again and invoke `scripts/verify-worktree-ownership.sh` with the immutable manifest ownership tuple. After changing to the target repository root, resolve that verifier as `$MAIN_ROOT/.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/scripts/verify-worktree-ownership.sh`; do not invoke a source-repository-relative `scripts/...` path. Both Dev Cadence cleanup gates must invoke this same installed verifier. A `not_owned` result or any verifier failure returns `discard_blocked` before destructive commands and preserves the worktree, task branch, and active run records. With `Created By Current Run: no`, the manifest `not_applicable` tuple is rejected by the verifier; return `discard_blocked` and preserve the worktree, task branch, and active run records.

#### Ownership and execution

- The workflow-only choice must preserve external and unknown paths byte-for-byte and path-for-path.
- If deleting the task branch or owned worktree would affect external or unknown changes, retain that branch or worktree and delete only independently deletable current-run objects. Return `discard_blocked` when preservation cannot be proven.
- When an owned worktree is retained to preserve external or unknown paths, verify all branch and path postconditions, preserve those paths byte-for-byte, and delete the run directory last from outside the retained workspace. Return `whole_run_discarded` only after verifying that the run directory is absent.
- Move a normal checkout or owned worktree off the task branch before deleting that exact branch.
- B-002 whole-run Discard must not proceed from or move into detached HEAD; detached HEAD remains outside B-002 whole-run Discard.
- Before returning success, successful postconditions require an attached, verified non-task branch.
- Delete the run directory last in a normal checkout.
- Remove a current-run-owned worktree last after branch and path postconditions pass.
- The finishing flow must not remove an external or unknown worktree.
- Verify the exact branch, worktree, path, and run-directory postconditions before returning success.

Return exactly one normalized result:

- `whole_run_discarded`: the run directory was deleted, every independently deletable current-run object was deleted, and all unselected external or unknown changes were preserved.
- `discard_cancelled`: the user cancelled before destructive execution.
- `discard_blocked`: identity changed, preservation could not be proven, or any destructive/postcondition step failed.

Keep existing ordinary Option 4 behavior for callers that do not supply Dev Cadence current-run context, except retain the already-required typed `discard` confirmation.
The B-002 detached-HEAD restriction does not change ordinary non-Dev-Cadence behavior.

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

Then: Cleanup worktree (Step 6), then force-delete branch:
```bash
git branch -D <feature-branch>
```

### Step 6: Cleanup Workspace

**Only runs for Options 1 and 4.** Options 2 and 3 always preserve the worktree. The caller has already changed directory to the primary repository root, so cleanup must use the `GIT_DIR`, `GIT_COMMON`, and `WORKTREE_PATH` values captured in Step 2.

**If `GIT_DIR == GIT_COMMON`:** Normal repo, no worktree to clean up. Done.

### Dev Cadence ownership gate

Dev Cadence cleanup caller must read the immutable ownership tuple only from the run manifest: `Created By Current Run`, `Workspace Path`, `Task Branch Ref`, and `Creation HEAD SHA`. It must pass the actual current workspace classification separately from the manifest ownership tuple. The Dev Cadence caller must not infer or fall back to `.worktrees/`, `worktrees/`, or configured worktree directories to prove ownership.

For a Dev Cadence named-branch worktree, invoke the installed `scripts/verify-worktree-ownership.sh` with the primary root and the immutable manifest tuple. Immediately before `git worktree remove`, freeze the exact task branch ref and `Expected Current HEAD SHA`, then run that verifier. Only an `owned` result permits the existing removal command. On `not_owned` or any verifier failure, skip `git worktree remove` and preserve the task branch and worktree. With `Created By Current Run: no`, pass the manifest `not_applicable` tuple unchanged; the verifier must reject it.

```bash
# Dev Cadence callers only, immediately before the existing removal command
TASK_BRANCH_REF=<manifest-task-branch-ref>
EXPECTED_CURRENT_HEAD_SHA=$(git rev-parse "$TASK_BRANCH_REF")
OWNERSHIP_VERIFIER="$MAIN_ROOT/.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/scripts/verify-worktree-ownership.sh"
"$OWNERSHIP_VERIFIER" \
  "$MAIN_ROOT" \
  <manifest-created-by-current-run> \
  <manifest-workspace-path> \
  "$TASK_BRANCH_REF" \
  <manifest-creation-head-sha> \
  "$EXPECTED_CURRENT_HEAD_SHA"
```

The Dev Cadence Whole-Run Discard gate above uses this same verifier after final confirmation. A verifier denial blocks the whole run before any destructive command; do not create a persistent cleanup or audit record for either gate.

**For legacy ordinary Superpowers callers, if worktree path is under `.worktrees/` or `worktrees/`:** Superpowers created this worktree — retain the existing path-convention cleanup behavior.

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

**Otherwise:** The host environment (harness) owns this workspace. Do NOT remove it. If your platform provides a workspace-exit tool, use it. Otherwise, leave the workspace in place.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | yes | - | - | yes |
| 2. Create PR | - | yes | yes | - |
| 3. Keep as-is | - | - | yes | - |
| 4. Discard | - | - | - | yes (force) |

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" is ambiguous
- **Fix:** Present exactly 4 structured options (or 3 for detached HEAD)

**Cleaning up worktree for Option 2**
- **Problem:** Remove worktree user needs for PR iteration
- **Fix:** Only cleanup for Options 1 and 4

**Deleting branch before removing worktree**
- **Problem:** `git branch -d` fails because worktree still references the branch
- **Fix:** Merge first, remove worktree, then delete branch

**Running git worktree remove from inside the worktree**
- **Problem:** Command fails silently when CWD is inside the worktree being removed
- **Fix:** Always `cd` to main repo root before `git worktree remove`

**Cleaning up harness-owned worktrees**
- **Problem:** Removing a worktree the harness created causes phantom state
- **Fix:** Only clean up worktrees under `.worktrees/` or `worktrees/`

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request
- Remove a worktree before confirming merge success
- Clean up worktrees you didn't create (provenance check)
- Run `git worktree remove` from inside the worktree

**Always:**
- Verify tests before offering options
- Detect environment before presenting menu
- Present exactly 4 options (or 3 for detached HEAD)
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only
- `cd` to main repo root before worktree removal
- Run `git worktree prune` after removal
