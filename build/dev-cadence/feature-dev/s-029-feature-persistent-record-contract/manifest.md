# Dev Cadence Run Manifest

- Workflow: `feature-dev`
- Task Slug: `s-029-feature-persistent-record-contract`
- Repository: `dev-cadence` (`git@github.com:raymond-liao/dev-cadence.git`)
- Branch: `codex/s029-feature-persistent-record-contract`
- Workspace: `.worktrees/codex/s029-feature-persistent-record-contract`
- Started At: `2026-07-20T16:38:17+0800`
- Output Language: `zh-CN`
- Configuration Source: `target repository root/.dev-cadence.yaml`
- Worktree Configuration Propagated: `yes`
- Current Stage: Requirements Confirmation
- Overall Status: 🔄 `in_progress`

## Stage Table

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Requirements Confirmation | 🔄 `in_progress` | [S-029 需求确认](01-requirements.md); `build/dev-cadence/feature-dev/s-029-feature-persistent-record-contract/01-requirements.md` | `pending` | `31fbd6c` | 已形成可审阅的需求记录，阶段 checkpoint 已验证，等待用户确认。 |
| Technical Solution | ⏳ `pending` | pending | `pending` | `pending` | 仅在 Requirements Confirmation 确认后开始。 |
| Implementation Plan | ⏳ `pending` | pending | `pending` | `pending` | 仅在 Technical Solution 确认后开始。 |
| Development Implementation | ⏳ `pending` | pending | `pending` | `pending` | 仅在 Implementation Plan 确认后开始。 |
| System Testing | ⏳ `pending` | pending | `pending` | `pending` | 等待实现和代码审查完成。 |
| Business Acceptance | ⏳ `pending` | pending | `pending` | `pending` | 仅在系统测试达到 `ready` 或 `ready_with_risk` 后开始。 |

## Work Item Identity

- Card: [S-029 Feature 持久化记录契约](../../../docs/stories/S-029-feature-persistent-record-contract.md) (`docs/stories/S-029-feature-persistent-record-contract.md`)
- Work-item Type: `Story`
- Card Version At Claim: `4`
- Card Status At Claim: `In Progress`
- Selected Scope: 已确认 Requirements 和 Technical Solution 的最小可恢复字段、manifest 的记录路径与 SHA-256 身份、连续确认阶段恢复、失效回退和可执行契约测试。
- Backlog Projection: [Backlog](../../../docs/backlog.md) (`docs/backlog.md`), source `待处理`, destination `进行中`, Version `4`, Status `In Progress`
- Claim Checkpoint: `e31db56b88aabdf6854bbc8454101d24e01a852a`

## Baseline

- Base Branch: `main`
- Baseline Commit: `e31db56b88aabdf6854bbc8454101d24e01a852a`
- Baseline Verification: `bash scripts/check-all.sh` passed before Requirements Confirmation.

## Current-run Discard Context

- Workflow: `feature-dev`
- Task Slug: `s-029-feature-persistent-record-contract`
- Run Directory: `build/dev-cadence/feature-dev/s-029-feature-persistent-record-contract`
- Task Branch: `codex/s029-feature-persistent-record-contract`
- Base Branch: `main`
- Expected HEAD SHA: `31fbd6c`
- Expected Base SHA: `e31db56b88aabdf6854bbc8454101d24e01a852a`
- Owned Commit Range: `e31db56b88aabdf6854bbc8454101d24e01a852a..HEAD`
- Owned Tracked Paths: `build/dev-cadence/feature-dev/s-029-feature-persistent-record-contract/01-requirements.md`, `build/dev-cadence/feature-dev/s-029-feature-persistent-record-contract/manifest.md`
- Owned Untracked Paths: `None`
- Workspace Path: `.worktrees/codex/s029-feature-persistent-record-contract`
- Worktree Created By This Run: `yes`

## Verification Summary

- ⏳ `pending`: System Testing has not started.

## Residual Risks

- ⚠️ Requirements are derived from S-029 Version 4 and await user confirmation; no implementation has started.
