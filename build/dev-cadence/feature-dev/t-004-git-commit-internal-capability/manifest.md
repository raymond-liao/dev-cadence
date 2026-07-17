# Dev Cadence Run Manifest

- Workflow: `feature-dev`
- Task Slug: `t-004-git-commit-internal-capability`
- Repository: `dev-cadence` (`git@github.com:raymond-liao/dev-cadence.git`)
- Branch: `codex/t-004-git-commit-internal-capability`
- Workspace: `.worktrees/t-004-git-commit-internal-capability`
- Started At: `2026-07-17T17:34:30+08:00`
- Current Stage: `Implementation Plan`
- Overall Status: 🔄 `in_progress`

## Stage Table

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
|---|---|---|---|---|---|
| Requirements Confirmation | ✅ `confirmed` | [T-004 需求确认](01-requirements.md) | 用户明确要求直接修改，并将边界澄清为不得在 Dev Cadence 之外调用；随后确认 Version 4。 | ⏳ `pending` | 覆盖所有已安装 Workflow 和入口直接路由的 shared capability。 |
| Technical Solution | ✅ `confirmed` | [T-004 技术方案](02-technical-solution.md) | 用户选择由 `using-dev-cadence` 集中路由，方式与 Document Conventions 相同；随后确认 Version 4。 | ⏳ `pending` | 入口拥有调用边界，shared skill 拥有完整提交规则，各调用方保留自己的提交语义。 |
| Implementation Plan | 🔄 `in_progress` | `build/dev-cadence/feature-dev/t-004-git-commit-internal-capability/03-implementation-plan.md` | pending | ⏳ `pending` | 隔离 worktree 已建立，基线检查通过。 |
| Development Implementation | ⏳ `pending` | `build/dev-cadence/feature-dev/t-004-git-commit-internal-capability/04-implementation-record.md` | pending | ⏳ `pending` | |
| System Testing | ⏳ `pending` | `build/dev-cadence/feature-dev/t-004-git-commit-internal-capability/05-system-test-report.md` | pending | ⏳ `pending` | |
| Business Acceptance | ⏳ `pending` | `build/dev-cadence/feature-dev/t-004-git-commit-internal-capability/06-business-acceptance-record.md` | pending | ⏳ `pending` | |

## Freshness Gate

- Input identity: T-004 Version `4`, Status `In Progress`.
- Base commit: `e638468744462bc0eff8c9763876bbfd4e1a4eb3`.
- Scope is limited to the installed Dev Cadence entry route, shared `git-commit` capability, package contracts, versioning, and directly affected delivery dispatch rules when required.
- The main checkout may be occupied by another task; T-004 remains isolated in the configured project-local worktree.

## Verification Summary

- Baseline `bash scripts/check-all.sh` passed before task changes.

## Residual Risks

- The personal global `git-commit` skill outside the target repository is outside T-004 delivery scope.
- The implementation plan must prove that SDD implementers receive the shared capability contract even though dispatched subagents do not route through `using-dev-cadence`.
