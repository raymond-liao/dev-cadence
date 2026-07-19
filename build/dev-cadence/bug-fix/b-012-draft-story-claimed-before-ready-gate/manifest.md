# B-012 Delivery Workflow Manifest

- Workflow: `bug-fix`
- Task slug: `b-012-draft-story-claimed-before-ready-gate`
- Repository: `dev-cadence` (`git@github.com:raymond-liao/dev-cadence.git`)
- Branch: `codex/b012-draft-story-claimed`
- Started at: `2026-07-19T15:03:31+08:00`
- Current stage: 🔄 `in_progress` - Business Acceptance
- Overall status: 🔄 `in_progress`
- Run directory: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/`
- Workspace: `.`
- Output language: `zh-CN`
- Configuration source: `target repository root/.dev-cadence.yaml`
- Worktree propagation: `not required; primary checkout`

## Stage Table

| Stage | Status | Artifact | User confirmation | Checkpoint commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Problem Diagnosis | ✅ `confirmed` | [B-012 问题诊断记录](01-problem-diagnosis-record.md); path: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/01-problem-diagnosis-record.md` | `2026-07-19T15:18:41+08:00`, option 1 | `92d454c` | 用户确认当前诊断并进入修复方案 |
| Repair Solution | ✅ `confirmed` | [B-012 修复方案](02-repair-solution.md); path: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/02-repair-solution.md` | `2026-07-19T15:35:59+08:00`, option 1 | `786f155` | 用户确认方案 B |
| Repair Plan | ✅ `confirmed` | [B-012 修复计划](03-repair-plan.md); path: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/03-repair-plan.md` | `2026-07-19T15:50:00+08:00`, option 1 | `da41433` | 用户确认计划并通过新鲜度门禁 |
| Repair Implementation | ✅ `confirmed` | [B-012 修复记录](04-repair-record.md); path: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/04-repair-record.md` | `implementation complete` | `b3addaa` | TDD RED/GREEN 与实施检查完成 |
| Code Review | ✅ `confirmed` | [B-012 Code Review Report](04-code-review-report.md); path: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/04-code-review-report.md` | `passed` | `b3addaa` | 无 Critical/Important finding |
| Regression Verification | ✅ `confirmed` | [B-012 回归测试报告](05-regression-test-report.md); path: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/05-regression-test-report.md` | `passed` | `0c3a390` | 全量构建、契约、安装和 source/dist 检查通过 |
| Business Acceptance | 🔄 `in_progress` | ⏳ `pending`: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/06-business-acceptance-record.md` | ⏳ `pending` | ⏳ `pending` | 等待用户业务验收 |

## Work Item Lifecycle Writeback

- Card: [B-012 Draft Story 在 Ready 门禁前被提前领取](../../../../docs/bugs/B-012-draft-story-claimed-before-ready-gate.md)
- Card type and version: `Bug`, Version `1`
- Card status: `Draft` -> `In Progress`
- Backlog source: `docs/backlog.md` section `待处理`
- Backlog destination: `docs/backlog.md` section `进行中`
- Derived parallel-view projection: 当前 Backlog 不持久化独立并行视图；投影由待处理顺序和依赖关系派生。
- Repair result/reference: ⏳ `pending`

## Current-Run Discard Context And Ownership Evidence

- Workflow: `bug-fix`
- Task slug: `b-012-draft-story-claimed-before-ready-gate`
- Run directory: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/`
- Task branch: `codex/b012-draft-story-claimed`
- Base branch: `main`
- Expected HEAD SHA: `da41433`
- Expected base SHA: `74a19032d9409f8116ae9a7bc6ed12e9692977af`
- Owned commit range: `74a19032d9409f8116ae9a7bc6ed12e9692977af..da41433`
- Owned tracked paths: `docs/bugs/B-012-draft-story-claimed-before-ready-gate.md`, shared lifecycle update in `docs/backlog.md`, and later confirmed repair paths
- Owned untracked paths: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/` at start
- Workspace path: `.worktrees/b012-draft-story-claimed`
- Worktree created by this run: `yes; .worktrees/b012-draft-story-claimed`
