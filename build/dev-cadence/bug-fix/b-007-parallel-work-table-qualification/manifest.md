# B-007 Bug Fix 运行清单

- Workflow: `bug-fix`
- Task Slug: `b-007-parallel-work-table-qualification`
- Work Item: [B-007 当前可并行实施表混用卡片状态与流程入口资格](../../../../docs/bugs/B-007-parallel-work-table-entry-qualification.md)
- Work Item Version: `1`
- Repository: `dev-cadence` (`git@github.com:raymond-liao/dev-cadence.git`)
- Workspace: `.worktrees/b-007-parallel-work-table-qualification`
- Branch: `codex/b-007-parallel-work-table-qualification`
- Started At: `2026-07-18T07:19:45+0800`
- Current Stage: Business Acceptance
- Overall Status: `in_progress`

## 阶段表

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Problem Diagnosis | ✅ `confirmed` | [问题诊断记录](01-problem-diagnosis-record.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/01-problem-diagnosis-record.md`) | `confirmed: user said "确认三项诊断，后面不要找我确认"` | `1fd1c87` | 三项诊断已确认。 |
| Repair Solution | ✅ `confirmed` | [修复方案](02-repair-solution.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/02-repair-solution.md`) | `delegated: user authorized continuation without intermediate confirmations` | `d3d3856` | 保留原表名，新增独立入口资格列。 |
| Repair Plan | ✅ `confirmed` | [修复计划](03-repair-plan.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/03-repair-plan.md`) | `delegated: user authorized continuation without intermediate confirmations` | `d3d3856` | 计划覆盖源规则、Backlog 表和契约测试。 |
| Repair Implementation | ✅ `confirmed` | [修复实施记录](04-repair-record.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/04-repair-record.md`) | `not required` | `pending` | 实现提交 `89eb653`；记录提交后绑定。 |
| Regression Verification | ✅ `confirmed` | [回归测试报告](05-regression-test-report.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/05-regression-test-report.md`) | `not required` | `pending` | `check-all.sh`、专项契约和静态检查均通过；记录提交后绑定。 |
| Business Acceptance | ⏳ `pending` | ⏳ `pending`: `build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/06-business-acceptance-record.md` | pending | `pending` | 必须由用户选择固定验收选项。 |

## 诊断摘要

- `docs/backlog.md` 的“当前可并行实施表”只有一个 `状态` 字段，没有单独表达卡片状态、依赖阻塞和下游 Workflow 入口门禁。
- 该表的 `Draft` 说明会让用户理解为完全不能启动，而 `work-item-planning` 又明确允许 Bug 在非 `Ready` 状态进入 `bug-fix` 诊断。
- 现有工作项规划契约测试验证了状态枚举和 Bug 入口规则，但未验证并行视图的字段语义闭环。

## 验证摘要

- Diagnosis Baseline: `ec0ee0c6b6dc07c30537c9fd1789c3af4165f6f3`
- Baseline checks: `bash scripts/build.sh`; `bash tests/run-all.sh` -> passed
- Previously confirmed in conversation: B-007 is a real documentation and planning-view contract defect

## 方案与计划状态

- Repair Solution: ✅ `confirmed` by delegated continuation authority.
- Repair Plan: ✅ `confirmed` by delegated continuation authority.
- Repair Implementation: ✅ `confirmed`; final repair SHA `89eb653`.
- Regression Verification: ✅ `ready`; no failed or skipped checks.
