# B-009 Delivery Workflow Manifest

- Workflow: `bug-fix`
- Task slug: `b-009-pending-order-parallel-view-authority`
- Repository: `dev-cadence` (`git@github.com:raymond-liao/dev-cadence.git`)
- Branch: `codex/fix-b009-pending-order-authority`
- Started at: `2026-07-18T14:00:00+0800`
- Current stage: `Business Acceptance`
- Overall status: 🔄 `in_progress`
- Run directory: `build/dev-cadence/bug-fix/b-009-pending-order-parallel-view-authority/`
- Workspace: `.`

## Stage Table

| Stage | Status | Artifact | User confirmation | Checkpoint commit | Notes |
|---|---|---|---|---|---|
| Problem Diagnosis | ✅ `confirmed` | `01-problem-diagnosis-record.md` | 已在本次委派范围中确认 | `4cc0f3c` | 已完成根因调查与 RED 证据 |
| Repair Solution | ✅ `confirmed` | `02-repair-solution.md` | 已在本次委派范围中确认 | `4cc0f3c` | 已确认最小修复边界 |
| Repair Plan | ✅ `confirmed` | `03-repair-plan.md` | 已在本次委派范围中确认 | `4cc0f3c` | 实施前新鲜度检查通过 |
| Repair Implementation | ✅ `confirmed` | `04-repair-record.md` | 已在本次委派范围中确认 | `4cc0f3c` | 4 个实现提交，计划任务完成 |
| Code Review | ✅ `confirmed` | `04-code-review-report.md` | 已完成独立审查 | `4cc0f3c` | 无未解决 Critical/Important finding |
| Regression Verification | ✅ `confirmed` | `05-regression-test-report.md` | 已完成回归验证 | `4cc0f3c` | 全量检查通过，决策为 `ready` |
| Business Acceptance | ⏳ `pending` | `06-business-acceptance-record.md` | pending | `pending` | 由主线程处理最终业务验收 |

## Confirmed Scope

- `docs/backlog.md` 的 `待处理` 行顺序是唯一权威实施顺序。
- `当前可并行实施表` 是按待处理顺序和依赖关系生成的派生视图，不维护独立排序。
- 待处理首项不能推进时，必须先确认并调整排序，不能静默跳过后续工作项。
- 删除并行表的 `下一步 Workflow / 入口门禁` 列；状态只表达生命周期，Workflow 路由继续由 `using-dev-cadence` 和对应 workflow skill 负责。
- 不处理 B-005、B-007、B-008 的历史完成状态，不新增 skill，不实现 S-017 的完整领取功能。

## Verification Summary

- RED: `tests/work-item-planning-contract.sh` 失败，缺少待处理顺序权威契约。
- RED: `tests/parallel-work-table-contract.sh` 失败，缺少派生待处理顺序契约。
- GREEN and full regression: ✅ `passed`.

## Residual Risks

- Build、契约全量验证和当前 run 链接检查已完成并通过；尚待主线程完成 Business Acceptance。
- 工作区没有 `.dev-cadence.yaml`；本次记录和用户要求明确使用中文，不改变仓库配置。

## Current-Run Discard Context And Ownership Evidence

- Workflow: `bug-fix`
- Task slug: `b-009-pending-order-parallel-view-authority`
- Run directory: `build/dev-cadence/bug-fix/b-009-pending-order-parallel-view-authority/`
- Task branch: `codex/fix-b009-pending-order-authority`
- Base branch: `main`
- Expected HEAD SHA: `6e18954624df1df45f9afd9141191b002605b724`
- Expected base SHA: `6e18954624df1df45f9afd9141191b002605b724`
- Owned commit range: `61c2feae366bb914e527f0a46e8405f50f236c68..9e5983a8bc5ea6be36327d47b05a9b3854551a93`
- Owned tracked paths: `src/skills/work-item-planning/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md`, `docs/backlog.md`, `docs/workflows/work-item-planning.md`, `docs/stories/S-017-work-item-development-workflow-integration.md`, `tests/work-item-planning-contract.sh`, `tests/parallel-work-table-contract.sh`, `tests/routing-contract.sh`, `version`, and this run directory
- Owned untracked paths: `none at start`
- Workspace path: `.`
- Worktree created by this run: `no; this task is executing in the pre-existing isolated Codex worktree`
