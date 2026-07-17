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
```

This determines which menu to show and how cleanup works:

| State | Menu | Cleanup |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (normal repo) | Standard 4 options | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Standard 4 options | Provenance-based (see Step 6) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Reduced 3 options (no merge) | No cleanup (externally managed) |

### Step 3: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

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

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on merged result
<test command>

# Only after merge succeeds: cleanup worktree (Step 6), then delete branch
```

Then: Cleanup worktree (Step 6), then delete branch:

```bash
git branch -d <feature-branch>
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

For choice 2, list every additional external or unknown path and require a second exact confirmation that names the expanded deletion scope. Choice 3 returns `discard_cancelled` without changing Git or filesystem state.

Immediately after final user confirmation and before any destructive command, repeat the complete identity snapshot and compare it with the confirmed snapshot. Any mismatch returns `discard_blocked` without changing Git or filesystem state.

Immediately after final user confirmation and before any destructive command, re-enumerate and reclassify every changed path as current-run, external, or unknown and compare the complete classified path set with the confirmed snapshot. Any change, addition, deletion, or classification mismatch returns `discard_blocked` without changing Git or filesystem state.

#### Ownership and execution

- The workflow-only choice must preserve external and unknown paths byte-for-byte and path-for-path.
- If deleting the task branch or owned worktree would affect external or unknown changes, retain that branch or worktree and delete only independently deletable current-run objects. Return `discard_blocked` when preservation cannot be proven.
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

**Only runs for Options 1 and 4.** Options 2 and 3 always preserve the worktree.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

**If `GIT_DIR == GIT_COMMON`:** Normal repo, no worktree to clean up. Done.

**If worktree path is under `.worktrees/` or `worktrees/`:** Superpowers created this worktree — we own cleanup.

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
