# B-002 Repair Solution

## Stage Status

- Status: ✅ `confirmed`
- Work item: [B-002 Delivery Workflow Discard 整体运行删除安全性](../../../../docs/delivery/bugs/B-002-normal-checkout-discard-safety.md)
- Diagnosis source: `build/dev-cadence/bug-fix/b-002-normal-checkout-discard-safety/01-problem-diagnosis-record.md`
- Card version: `2`
- Branch: `codex/b-002-normal-checkout-discard-safety`
- Base commit: `9834d2ee4c3536196e7844bfc697ed724088a7ea`
- Workspace: `.worktrees/b-002-normal-checkout-discard-safety`
- Solution updated at: `2026-07-17T18:42:34+0800`
- User confirmation: confirmed at `2026-07-17T20:36:40+0800`.

## Root Cause Being Repaired

The current Discard path is branch-oriented rather than run-oriented. It does not identify the complete current Delivery Workflow run, cannot reliably distinguish workflow-owned changes from external changes, may try to delete a currently checked-out branch, and does not bind confirmation to exact Git and filesystem identities.

The three Delivery Workflow Completion contracts also assume that manifest and Business Acceptance records remain available after Discard. That assumption conflicts with the selected whole-run deletion semantics.

## ✅ Selected Discard Semantics

When the user selects Discard, the workflow offers to delete the entire current run. The deletion set includes:

- workflow-owned committed changes and the recorded task branch;
- workflow-owned tracked and untracked changes;
- the worktree when it is proven to have been created by the current run;
- the complete run directory under `build/dev-cadence/<workflow>/<task-slug>/`, including manifest and stage records.

The confirmation must state that successful Discard leaves no persistent manifest, stage record, tombstone, `abandoned` status, or cleanup-result record. The actual result is reported only in the current conversation.

This semantic applies symmetrically to `feature-dev`, `bug-fix`, and `refactor`.

## Run And Ownership Classification

Before presenting Discard, the active Delivery Workflow must provide the finishing flow with the current run identity:

- workflow and task slug;
- run directory;
- task branch and expected HEAD SHA;
- base branch and expected SHA;
- workflow-owned commit range;
- workflow-owned tracked and untracked paths;
- checkout or worktree path;
- whether the current run created the worktree.

The finishing flow must compare this context with current Git and filesystem state. It must classify every changed path as `current-run`, `external`, or `unknown`. `unknown` is treated as external and is never deleted implicitly.

A worktree is removable only when the current run recorded its creation and `git worktree list --porcelain` still matches its path, branch, and Git identity. Directory naming alone is insufficient evidence.

## User Decisions

### No external changes

Show one complete deletion summary containing the exact branch, commit range, workflow-owned paths, owned worktree when applicable, and run directory. Require exact typed `discard` confirmation.

### External or unknown changes present

List the external or unknown paths and present exactly these choices:

1. **Discard the current run only**: delete only current-run changes and the current run directory. Preserve all external and unknown changes. Retain the branch or worktree when deleting it would affect preserved changes.
2. **Discard the entire owned workspace or branch**: delete the current run and the listed external or unknown changes. This option requires a second exact confirmation that names the additional paths. An owned worktree may be removed; an external or unknown worktree may not.
3. **Cancel**: make no destructive change.

The confirmation for choices 1 and 2 must explicitly state that the current run records will also be deleted and no persistent Discard record will remain.

## Execution Order And Failure Handling

Before executing any destructive command, revalidate the complete confirmation snapshot. Any changed branch, SHA, path set, run directory, or worktree identity invalidates the confirmation and returns to the decision step.

For a normal checkout:

1. Remove only the selected workflow-owned or explicitly included workspace changes.
2. Switch away from the task branch without modifying preserved external changes.
3. Delete the exact task branch and verify its absence.
4. Delete the current run directory last.

For a current-run-owned worktree:

1. Remove only the selected changes and preserve any unselected external changes.
2. Move the worktree off the task branch when required for safe branch deletion.
3. Delete and verify the exact task branch.
4. Remove the owned worktree last; this also removes the current run directory stored inside it.

Broad destructive commands such as unscoped `git reset --hard`, unscoped `git clean -fd`, or removal of an unowned worktree are forbidden.

If any step fails before the run directory or owned worktree is deleted, stop and leave the remaining run records available. If the final record/worktree deletion succeeds, report the verified result only in the current conversation. Partial success must be reported as partial failure with the exact resources that remain; it must not be called successful Discard.

## Delivery Workflow Completion Contract

Each of `feature-dev`, `bug-fix`, and `refactor` must distinguish the finishing result:

- `merge`, `pull request`, and `keep`: retain the existing manifest, Business Acceptance update, terminal-readiness checklist, and final integration recording.
- `discard current run`: after the finishing flow verifies deletion, do not update manifest, Business Acceptance, checkpoint fields, or any other run record. Report the result in the current conversation and stop the workflow.
- failed or cancelled Discard: retain the existing run and return control to the active Completion step without claiming a terminal result.

Whole-run Discard is not the `abandoned` status. `abandoned` remains a record-preserving terminal status for Manual Recovery.

## Likely Files And Assets To Change

- `src/skills/feature-dev/SKILL.md`: pass run identity and define no-record Discard Completion behavior.
- `src/skills/bug-fix/SKILL.md`: same symmetric contract.
- `src/skills/refactor/SKILL.md`: same symmetric contract.
- `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`: exact Discard choices, confirmation, execution ordering, ownership checks, and verification result.
- `tests/workflow-symmetry.sh`: enforce the symmetric Delivery Completion contract.
- a focused finishing/Discard contract test under `tests/`: verify exact required and forbidden rules.
- `version`: update because installed Delivery Workflow behavior changes.
- `dist/.dev-cadence/`: regenerate through `bash scripts/build.sh`; do not edit directly.

## Related Behavior And Regression Scope

- Merge, PR, and Keep must retain their current persistent-record behavior.
- A clean normal checkout must support whole-run Discard without attempting to delete the checked-out branch directly.
- A current-run-created worktree may be deleted only after ownership and confirmation checks pass.
- External or unknown worktrees must never be removed automatically.
- External changes must remain unchanged under “Discard the current run only”.
- Detached HEAD remains outside this repair.
- A successful whole-run Discard must not attempt any post-deletion record update.
- A failed or cancelled Discard must retain the run records and must not be reported as successful.

## Repair Acceptance Criteria

1. The confirmation identifies the exact current run deletion set and states that no persistent run record will remain.
2. Current-run changes are deleted without deleting unselected external or unknown changes.
3. External changes trigger the fixed three-choice decision and any expanded deletion requires a second exact confirmation.
4. Only a worktree proven to have been created by the current run can be removed automatically.
5. Branch and worktree deletion are ordered so the target branch is not deleted while still checked out.
6. The three Delivery Workflow Completion contracts skip all post-deletion record updates after successful whole-run Discard.
7. Merge, PR, Keep, cancelled Discard, and failed Discard preserve their existing records and behavior.
8. Git and filesystem postconditions are verified before reporting successful Discard in the current conversation.

## Behavior That Must Remain Unchanged

- Discard still requires explicit typed confirmation.
- No push, merge, PR creation, amend, or history rewrite is introduced by the Discard path.
- No external change is deleted without an additional explicit user decision.
- `abandoned` remains a persistent Manual Recovery status and is not used for whole-run Discard.
- Detached HEAD and unowned worktree cleanup remain outside this repair.

## Alternatives And Tradeoffs

### Preserve all process records after Discard

❌ Rejected. It conflicts with the confirmed meaning of deleting the entire current run.

### Create a Discard tombstone or final deletion record

❌ Rejected. The repository has no such record model, and the user explicitly chose no persistent record after successful whole-run deletion.

### ✅ Selected: delete the entire confirmed run with no persistent terminal record

This gives Discard a literal and internally consistent meaning. The tradeoff is intentional loss of auditability after successful deletion, which must be stated before confirmation.

## User Decisions

- The user confirmed that Discard deletes the current run's implementation, owned branch/worktree, and complete process records.
- The user confirmed that the warning must state that no persistent record remains after successful deletion.
- The user confirmed that all three Delivery Workflow Completion contracts must use this semantic.
- The user confirmed that external changes require explicit scope choices and are not deleted by default.

## Confirmation Gate

This Repair Solution is confirmed. Executable workflow rules must not change until the Repair Plan is confirmed.
