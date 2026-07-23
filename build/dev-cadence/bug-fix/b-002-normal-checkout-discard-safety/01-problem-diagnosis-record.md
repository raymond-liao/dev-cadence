# B-002 Problem Diagnosis Record

## Stage Status

- Status: ✅ `confirmed`
- Work item: [B-002 Delivery Workflow Discard 整体运行删除安全性](../../../../docs/delivery/bugs/B-002-normal-checkout-discard-safety.md)
- Card version: `2`
- Card status: `Draft`
- Diagnosis refreshed at: `2026-07-17T18:42:34+0800`
- Repository: `dev-cadence`
- Branch: `codex/b-002-normal-checkout-discard-safety`
- Commit: `9834d2ee4c3536196e7844bfc697ed724088a7ea`
- Workspace: `.worktrees/b-002-normal-checkout-discard-safety`
- Prior confirmation: `superseded` because Version 2 changed the problem and affected scope.
- Version 2 confirmation: confirmed at `2026-07-17T20:26:34+0800`.

## Reported Symptom

Delivery Workflow Completion 的 Discard 目前以 branch/worktree 为中心，没有把当前 workflow run 作为完整删除对象。它不能可靠区分当前 run 和外部改动，可能直接删除当前 checkout 中的 branch，也没有为“删除实现、owned branch/worktree 和完整运行记录且不留持久化终态”提供一致契约。

同时，`feature-dev`、`bug-fix` 和 `refactor` 当前都要求 finishing flow 完成后继续更新 manifest 和 Business Acceptance 记录。如果 Discard 已删除整个 run，这些后续写入对象已经不存在，Completion 契约内部冲突。

## Expected Behavior

用户选择 Discard 时，三个 Delivery Workflow 必须使用同一个整体 run 删除语义：

- 精确识别当前 run 的实现改动、task branch、owned worktree 和运行记录目录；
- 明确提示这些对象都会被删除，成功后不保留 manifest、stage record、tombstone 或其他持久化终态记录；
- 当前 run 之外的改动必须单独列出并由用户选择是否一并删除；
- 只有当前 run 创建的 worktree 可以被自动删除；
- 成功删除整个 run 后，Delivery Workflow 不再尝试更新已删除记录，只在当前会话报告验证结果。

## Actual Behavior

### Finishing Discard 缺口

1. 现有确认只列出 branch、commit 和 worktree，没有绑定 Delivery Workflow、task slug、run directory、精确 SHA 或 workflow-owned tracked/untracked 路径。
2. 普通 checkout 的 Discard 在确认后执行 `git branch -D <feature-branch>`，没有先离开待删除分支。
3. 当前规则以 worktree 目录命名判断清理归属，不能证明 worktree 由当前 run 创建。
4. 没有外部改动的固定选择语义，也没有确认快照失效后的重新确认规则。
5. 执行后没有完整验证 branch、worktree、改动范围和 run directory 的实际状态。

### Delivery Completion 契约冲突

1. 三个 Delivery Workflow 都要求 finishing flow 完成后更新 manifest 和 Business Acceptance 的最终结果。
2. 三个 Workflow 的终态 readiness checklist 都要求这些记录继续存在并完整。
3. 当用户确认删除整个 run 及其完整运行记录时，上述后置写入和检查没有可用目标，无法执行。

## Impact Scope

### ✅ Included

- `feature-dev`、`bug-fix` 和 `refactor` 的 Completion Discard 契约。
- 普通 checkout 中的新建 task branch。
- 当前 run 创建并可由运行身份验证的 named worktree。
- workflow-owned commits、tracked/untracked 改动和完整 run directory。
- 外部或 unknown 改动的显式范围选择。
- 成功删除后的无持久化记录终态语义。

### ❌ Excluded

- detached HEAD 的完整 Finishing。
- Merge、PR 和 Keep 的既有 Completion 行为。
- Discard tombstone、删除记录、`abandoned` manifest 或其他新持久化记录类型。
- 外部管理或创建来源不明 worktree 的自动删除。

## Bug Classification

- Classification: confirmed bug
- Reason: the existing Git deletion sequence is unsafe for a checked-out branch, and the current Delivery Completion postconditions are impossible after deleting the complete run they require to update.

## Reproduction Evidence

### Current branch deletion

In a temporary normal Git checkout, the current branch `task/discard-candidate` contained a task commit. Running `git branch -D task/discard-candidate` returned exit code `1`:

```text
error: cannot delete branch 'task/discard-candidate' used by worktree at '<temporary-repository-path>'
```

The temporary machine path is intentionally omitted from this durable record.

### Completion record contradiction

Source inspection confirms that all three Delivery Workflow Completion sections require post-finishing manifest and Business Acceptance updates. A successful whole-run Discard deletes the run directory containing those files, so the required postcondition cannot be satisfied.

## Root Cause Evidence

### Root cause 1: Discard identity is branch-oriented

The finishing skill does not receive or validate the complete Delivery Workflow run identity. It therefore cannot prove which commits, workspace changes, worktree, or run records belong to the requested Discard.

### Root cause 2: worktree ownership is inferred rather than proven

Directory placement is used as cleanup evidence, but a path under `.worktrees/` does not prove that the current run created or owns the worktree.

### Root cause 3: current branch is not released before deletion

The normal-checkout command sequence attempts branch deletion without first switching the checkout away from the target branch.

### Root cause 4: Completion assumes records survive every finishing choice

The three Delivery Workflows use one persistent-record postcondition for Merge, PR, Keep, and Discard. That model cannot represent a user-confirmed whole-run deletion that intentionally removes all process records.

## Confidence

- Current-branch deletion failure: high confidence, directly reproduced.
- Missing run identity and ownership proof: high confidence, established by source inspection.
- Cross-workflow Completion contradiction: high confidence, present symmetrically in all three rule sources.

## Open Questions

- None. The user confirmed whole-run deletion, no persistent Discard record, symmetric Delivery Workflow behavior, and explicit handling of external changes.

## Diagnosis Boundary

This refreshed diagnosis establishes the confirmed Version 2 problem. It does not authorize the Repair Plan or executable workflow changes before the revised Repair Solution is confirmed.
