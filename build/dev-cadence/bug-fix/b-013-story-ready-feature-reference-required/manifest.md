# B-013 Bug Fix 运行清单

- Workflow：`bug-fix`
- Task slug：`b-013-story-ready-feature-reference-required`
- Repository：`dev-cadence`（`git@github.com:raymond-liao/dev-cadence.git`）
- Branch：`codex/b013-story-ready-feature`
- Started at：`2026-07-19T21:30:32+0800`
- Current stage：🔄 `in_progress` — Repair Solution
- Overall Status：🔄 `in_progress`
- Run directory：`build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/`
- Workspace：`.worktrees/b013-story-ready-feature`
- Output language：`zh-CN`
- Configuration source：`target repository root/.dev-cadence.yaml`
- Worktree propagation：已完成；主 checkout 配置已复制并通过一致性校验。

## Stage Table

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Problem Diagnosis | ✅ `confirmed` | [B-013 问题诊断记录](01-problem-diagnosis-record.md)；path：`build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/01-problem-diagnosis-record.md` | `2026-07-19T21:34:40+0800`，选项 1：确认诊断并进入 Repair Solution | `e256de2b79b32a91cf0dee45ef42d19e559b4b67` | 用户确认诊断范围；确认后的检查点已验证。 |
| Repair Solution | 🔄 `in_progress` | [B-013 修复方案](02-repair-solution.md)；path：`build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/02-repair-solution.md` | ⏳ `pending` | `c6483216ff44b824df6d1d3ac8bdf54b0591a42f` | 最小修复方案已形成，等待用户确认。 |
| Repair Plan | ⏳ `pending` | `build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/03-repair-plan.md` | ⏳ `pending` | ⏳ `pending` | 尚未开始。 |
| Repair Implementation | ⏳ `pending` | `build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/04-repair-record.md` | ⏳ `pending` | ⏳ `pending` | 尚未开始。 |
| Code Review | ⏳ `pending` | `build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/04-code-review-report.md` | ⏳ `pending` | ⏳ `pending` | 尚未开始。 |
| Regression Verification | ⏳ `pending` | `build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/05-regression-test-report.md` | ⏳ `pending` | ⏳ `pending` | 尚未开始。 |
| Business Acceptance | ⏳ `pending` | `build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/06-business-acceptance-record.md` | ⏳ `pending` | ⏳ `pending` | 尚未开始。 |

## Work Item Identity And Claim

- Card：[B-013 Story Ready 错误依赖 Feature 关联](../../../../docs/bugs/B-013-story-ready-feature-reference-required.md)
- Work-item type：`Bug`
- Card Version：`2`
- Visible Status：`In Progress`
- Selected scope：移除 Story `Ready` 的强制主 System Feature 条件，同时保留已有 Feature 的追踪关系与真正产品级结论变化时的 Discovery 路由；不改变 Task、Bug 或 Delivery Workflow 的入口边界。
- Claim persistence：主 checkout 已在提交 `5cb09c6e1423add910c63b25470f8aa6beff5c70` 原子同步 B-013 卡片与 Backlog 为 `In Progress`；任务 worktree 从该提交创建。

## Current-Run Discard Context And Ownership Evidence

- Workflow：`bug-fix`
- Task slug：`b-013-story-ready-feature-reference-required`
- Run directory：`build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/`
- Task branch：`codex/b013-story-ready-feature`
- Base branch：`main`
- Expected HEAD SHA：`5cb09c6e1423add910c63b25470f8aa6beff5c70`
- Expected base SHA：`5cb09c6e1423add910c63b25470f8aa6beff5c70`
- Owned commit range：`5cb09c6e1423add910c63b25470f8aa6beff5c70..HEAD`
- Owned tracked paths：`build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/manifest.md`、`build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/01-problem-diagnosis-record.md`
- Owned untracked paths：`none at start`
- Workspace path：`.worktrees/b013-story-ready-feature`
- Worktree created by this run：`yes`
