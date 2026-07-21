# Dev Cadence Run Manifest

- Workflow: `feature-dev`
- Task Slug: `s-018-delivery-terminal-mapping`
- Repository: `dev-cadence` (`git@github.com:raymond-liao/dev-cadence.git`)
- Branch: `codex/s-018-delivery-terminal-mapping`
- Workspace: `.worktrees/s-018-delivery-terminal-mapping`
- Started At: `2026-07-21T14:24:56+0800`
- Output Language: `zh-CN`
- Configuration Source: `target repository root/.dev-cadence.yaml`
- Worktree Configuration Propagated: `yes`
- Current Stage: Requirements Confirmation
- Overall Status: 🔄 `in_progress`

## Stage Table

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Requirements Confirmation | 🔄 `in_progress` | [S-018 需求确认](01-requirements.md); `build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/01-requirements.md` | `superseded: direct-input table encoding was not validator-readable` | `1e7a335871847c573ca9c36c6e2a7a0aeadcddb1` | 已修复为原始仓库相对路径与 SHA-256；恢复 checkpoint 已验证，等待重新确认。 |
| Technical Solution | ⏳ `pending` | [S-018 技术方案](02-technical-solution.md); `build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/02-technical-solution.md` | `superseded: Requirements recovery` | `superseded: 4c136dcaad68909cef7f1d3bec211fd3afe38607` | 需在 Requirements 重新确认后刷新。 |
| Implementation Plan | ⏳ `pending` | [S-018 实施计划](03-implementation-plan.md); `build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/03-implementation-plan.md` | `superseded: Requirements recovery` | `superseded: 86fbd2411f05d403d2bc07c37b309149045c98f5` | 需在 Requirements 和 Technical Solution 重新确认后刷新。 |
| Development Implementation | ⏳ `pending` | ⏳ `pending`: `build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/04-implementation-record.md` | `not_required` | `pending` | 被 Requirements recovery 阻断。 |
| System Testing | ⏳ `pending` | ⏳ `pending`: `build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/05-system-test-report.md` | `pending` | `pending` | 等待 Development Implementation。 |
| Business Acceptance | ⏳ `pending` | ⏳ `pending`: `build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/06-business-acceptance-record.md` | `pending` | `pending` | 等待 System Testing 的 Verification Decision。 |

## Recovery Summary

- Recovery ID: `REC-S018-001`
- Detected By: `validate-persistent-record-recovery.sh` before Development Implementation.
- Root Cause: Direct Input Identities encoded repository-relative paths and SHA-256 values as Markdown code values; the validator requires raw table fields.
- Scope Impact: None. The work-item Version, Status, selected scope, and all direct-input SHA-256 values remain unchanged.
- Recovery Action: Requirements record paths normalized; Technical Solution and Implementation Plan confirmations superseded and must be refreshed after renewed Requirements Confirmation.

## Work Item Identity

- Card: [S-018 Delivery 终态映射与 Manual Recovery](../../../../docs/stories/S-018-business-acceptance-terminal-mapping.md) (`docs/stories/S-018-business-acceptance-terminal-mapping.md`)
- Work-item Type: `Story`
- Card Version At Claim: `4`
- Card Status At Claim: `In Progress`
- Selected Scope: 明确三个 Delivery workflow 中 `accepted`、`rejected` 与 `accepted_with_risk` 的后续路径，保留风险责任；仅为已接受且正常 Completion 已被证明不可恢复阻断的 run 定义 manual recovery 与 `abandoned` 终态记录，并以对称契约测试验证。
- Backlog Projection: [Backlog](../../../../docs/backlog.md) (`docs/backlog.md`), source `待处理`, destination `进行中`, Version `4`, Status `In Progress`
- Claim Checkpoint: `be7c945af634abab30a86f286ee3262e6352150e`

## Baseline

- Base Branch: `main`
- Baseline Commit: `be7c945af634abab30a86f286ee3262e6352150e`
- Baseline Verification: `bash scripts/check-all.sh` passed before Requirements Confirmation.

## Configuration Snapshot

- Output Language: `zh-CN`
- Worktree Enabled: `true`
- Worktree Directory: `.worktrees`
- Configuration SHA-256: `9ba610320f36b3d0b18536daa896113584f7b6be679b1a6f118b8232516dc83b`
- Configuration Propagation Verification: primary checkout source and task-worktree target matched with `cmp -s`.

## Current-run Discard Context

- Workflow: `feature-dev`
- Task Slug: `s-018-delivery-terminal-mapping`
- Run Directory: `build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping`
- Task Branch: `codex/s-018-delivery-terminal-mapping`
- Base Branch: `main`
- Expected HEAD SHA: `be7c945af634abab30a86f286ee3262e6352150e`
- Expected Base SHA: `be7c945af634abab30a86f286ee3262e6352150e`
- Owned Commit Range: `be7c945af634abab30a86f286ee3262e6352150e..HEAD`
- Owned Tracked Paths: `build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/**`; planned Delivery workflow sources, validator, contract tests, and `version` within the confirmed S-018 scope.
- Owned Untracked Paths: `None`
- Workspace Path: `.worktrees/s-018-delivery-terminal-mapping`
- Worktree Created By This Run: `yes`

## Worktree Creation Evidence

- Created By Current Run: `yes`
- Workspace Path: `.worktrees/s-018-delivery-terminal-mapping`
- Task Branch Ref: `refs/heads/codex/s-018-delivery-terminal-mapping`
- Creation HEAD SHA: `be7c945af634abab30a86f286ee3262e6352150e`
- Evidence Source: `git worktree list --porcelain`

## Verification Summary

- 🔄 `in_progress`: 基线 `bash scripts/check-all.sh` 已通过；尚未开始技术方案或实现。

## Residual Risks

- ⚠️ 三个 workflow、终态记录 validator 与契约测试必须保持对称；任何误将可恢复失败、验收拒绝或用户 discard 归为 manual recovery 都会破坏 Story 边界。
