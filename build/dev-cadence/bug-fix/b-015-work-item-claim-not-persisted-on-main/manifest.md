# B-015 Bug Fix 运行清单

- Workflow：`bug-fix`
- Task slug：`b-015-work-item-claim-not-persisted-on-main`
- Repository：`dev-cadence`（`git@github.com:raymond-liao/dev-cadence.git`）
- Branch：`codex/b015-work-item-claim-persisted`
- Started at：`2026-07-19T19:12:59+0800`
- Current stage：🔄 `in_progress` — Repair Implementation
- Overall Status：🔄 `in_progress`
- Run directory：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/`
- Workspace：`.worktrees/b015-work-item-claim-persisted`
- Output language：`zh-CN`
- Configuration source：`target repository root/.dev-cadence.yaml`
- Worktree propagation：已完成；主 checkout 配置已复制并通过一致性校验。

## Stage Table

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Problem Diagnosis | ✅ `confirmed` | [B-015 问题诊断记录](01-problem-diagnosis-record.md)；path：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/01-problem-diagnosis-record.md` | `2026-07-19T19:32:28+0800`，选项 1：扩大到两种配置 | `e13b99b` | 用户确认追加调查结论，诊断范围已扩大并重新确认。 |
| Repair Solution | ✅ `confirmed` | [B-015 修复方案](02-repair-solution.md)；path：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/02-repair-solution.md` | `2026-07-19T19:41:25+0800`，选项 1：确认方案并进入 Repair Plan | `9bcb49e` | 用户确认两种配置共用 primary checkout 持久化方案。 |
| Repair Plan | ✅ `confirmed` | [B-015 修复计划](03-repair-plan.md)；path：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/03-repair-plan.md` | `2026-07-19T20:14:56+0800`，选项 1：确认计划并进入 Repair Implementation | `e6c7361` | 用户确认计划，开始按 Task 1-4 执行。 |
| Repair Implementation | 🔄 `in_progress` | ⏳ pending；planned path：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/04-repair-record.md` | 未开始 | `pending` | Task 1 RED/GREEN 与规则实现已完成；版本、构建和全量回归进行中。 |
| Code Review | ⏳ `pending` | ⏳ pending；planned path：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/04-code-review-report.md` | 未开始 | `pending` | 实施完成后开始。 |
| Regression Verification | ⏳ `pending` | ⏳ pending；planned path：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/05-regression-test-report.md` | 未开始 | `pending` | Review 通过后开始。 |
| Business Acceptance | ⏳ `pending` | ⏳ pending；planned path：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/06-business-acceptance-record.md` | 未开始 | `pending` | 仅允许 `ready` 或 `ready_with_risk` 进入。 |

## Work Item Identity And Claim

- Card：[B-015 工作项领取未在 main 持久化](../../../../docs/bugs/B-015-work-item-claim-not-persisted-on-main.md)
- Work-item type：`Bug`
- Card Version：`4`
- Visible Status：`In Progress`
- Selected scope：同时修复 `worktree.enabled: true` 的已复现状态分叉和 `false` 的可构造同类契约缺口；不扩展到生命周期终态回写或其他工作项行为。
- Claim persistence：主 checkout 已在提交 `0e5d69e` 原子同步 B-015 卡片与 Backlog 为 `In Progress`；任务 worktree 从该提交创建。

## Verification Summary

- 基线 `bash tests/work-item-development-workflow-contract.sh`：通过，但未覆盖“领取写入必须发生在 main”这一不变量。
- 基线 `bash tests/install-contract.sh`：通过。
- 最小 RED 检查：入口规则没有 `main` checkout / 主分支领取不变量，证明契约缺口仍存在。
- `worktree.enabled: false` 追加调查：现有规则和测试没有 primary checkout 持久化约束，可构造“未提交领取变更随专用 branch 走、main 分支指针保持旧状态”的失败路径。
- `bash tests/package-contract.sh`：一次并行基线执行报告缺少 dist package；当前 worktree 已确认生成目录存在，待后续构建阶段重新执行完整检查。

## Residual Risks

- `false` 路径尚无独立历史运行记录；Repair Plan 必须补充可执行的 branch-baseline 验证证据。
- 现有契约只验证领取先于 branch/worktree 和下游路由，未验证领取更新的执行 checkout 身份。
- Repair Solution 已于 `2026-07-19T19:41:25+0800` 由用户选项 1 确认；Repair Plan 已于 `2026-07-19T20:14:56+0800` 由用户选项 1 确认，已进入 Repair Implementation。

## Current-Run Discard Context And Ownership Evidence

- Workflow：`bug-fix`
- Task slug：`b-015-work-item-claim-not-persisted-on-main`
- Run directory：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/`
- Task branch：`codex/b015-work-item-claim-persisted`
- Base branch：`main`
- Expected HEAD SHA：`e9713fc`
- Expected base SHA：`0e5d69e73f6bf760ff954ba15119ad9c429571be`
- Owned commit range：`0e5d69e73f6bf760ff954ba15119ad9c429571be..e9713fc`
- Owned tracked paths：`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/01-problem-diagnosis-record.md`, `build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/02-repair-solution.md`, `build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/03-repair-plan.md`, `build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/manifest.md`
- Owned untracked paths：`none at start`
- Workspace path：`.worktrees/b015-work-item-claim-persisted`
- Worktree created by this run：`yes`
