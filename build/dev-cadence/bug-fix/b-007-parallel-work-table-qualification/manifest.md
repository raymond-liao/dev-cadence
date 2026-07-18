# B-007 Bug Fix 运行清单

- Workflow: `bug-fix`
- Task Slug: `b-007-parallel-work-table-qualification`
- Work Item: [B-007 当前可并行实施表混用卡片状态与流程入口资格](../../../../docs/bugs/B-007-parallel-work-table-entry-qualification.md)
- Work Item Version: `1`
- Repository: `dev-cadence` (`git@github.com:raymond-liao/dev-cadence.git`)
- Workspace: `.worktrees/b-005-b-007-b-008-contract-closure`
- Branch: `codex/b-005-b-007-b-008-contract-closure`
- Started At: `2026-07-18T07:19:45+0800`
- Current Stage: Repair Implementation
- Overall Status: 🔄 `in_progress`

## 阶段表

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Problem Diagnosis | ✅ `confirmed` | [问题诊断记录](01-problem-diagnosis-record.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/01-problem-diagnosis-record.md`) | `confirmed: user approved the analyzed repair and said "继续"` | ⏳ `pending` | B-009 已取代原先的逐行入口列方案。 |
| Repair Solution | ✅ `confirmed` | [修复方案](02-repair-solution.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/02-repair-solution.md`) | `confirmed: implement the approved approach` | ⏳ `pending` | 使用表级职责边界和中心路由所有权。 |
| Repair Plan | ✅ `confirmed` | [修复计划](03-repair-plan.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/03-repair-plan.md`) | `confirmed: implement then build dist` | ⏳ `pending` | 只对齐卡片事实和 Backlog 版本。 |
| Repair Implementation | 🔄 `in_progress` | [修复实施记录](04-repair-record.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/04-repair-record.md`) | `not required` | ⏳ `pending` | 原实现 `89eb653` 已被 B-009 的后续设计取代；当前对齐实施中。 |
| Regression Verification | ⏳ `pending` | [回归测试报告](05-regression-test-report.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/05-regression-test-report.md`) | `not required` | ⏳ `pending` | 使用当前四列契约重新验证。 |
| Business Acceptance | ⏳ `pending` | [业务验收记录](06-business-acceptance-record.md) (`build/dev-cadence/bug-fix/b-007-parallel-work-table-qualification/06-business-acceptance-record.md`) | ⏳ `pending` | ⏳ `pending` | 原验收保留为历史证据；当前对齐待验收。 |

## 诊断摘要

- `docs/backlog.md` 的“当前可并行实施表”只有一个 `状态` 字段，没有单独表达卡片状态、依赖阻塞和下游 Workflow 入口门禁。
- 该表的 `Draft` 说明会让用户理解为完全不能启动，而 `work-item-planning` 又明确允许 Bug 在非 `Ready` 状态进入 `bug-fix` 诊断。
- 现有工作项规划契约测试验证了状态枚举和 Bug 入口规则，但未验证并行视图的字段语义闭环。

## 验证摘要

- Diagnosis Baseline: `ec0ee0c6b6dc07c30537c9fd1789c3af4165f6f3`
- Baseline checks: `bash scripts/build.sh`; `bash tests/run-all.sh` -> passed
- Previously confirmed in conversation: B-007 is a real documentation and planning-view contract defect

## 历史方案与计划状态

- Repair Solution: ✅ `confirmed` by delegated continuation authority.
- Repair Plan: ✅ `confirmed` by delegated continuation authority.
- Repair Implementation: ✅ `confirmed`; final repair SHA `89eb653`.
- Regression Verification: ✅ `ready`; no failed or skipped checks.
- Business Acceptance: ✅ `accepted`; user selected `1. Accept` at `2026-07-18T07:58:51+0800`.

## 历史最终集成

- Decision: `merge locally to main`
- Merge Commit: `74c6287`
- Base Branch: `main`
- Push: `skipped: not requested`
- Worktree Cleanup: `completed`; `.worktrees/b-007-parallel-work-table-qualification` 已移除
- Task Branch Cleanup: `completed`; `codex/b-007-parallel-work-table-qualification` 已删除
- Post-Merge Verification: ✅ `passed`; 主分支 `bash scripts/check-all.sh`

## 历史修复状态（当前已重新打开）

- Repair Solution: confirmed
- Repair Plan: confirmed
- Repair Implementation: confirmed
- Regression Verification: confirmed
- Business Acceptance: accepted
- Completion: integrated

## 当前复核

- 触发证据：B-009 已验收并移除逐行 `下一步 Workflow / 入口门禁` 列，但 B-007 卡片仍要求该列。
- 当前根因：后续权威决定未同步到 B-007 长期卡片。
- 当前计划：保持 B-009 的四列架构，只更新 B-007 卡片 Version、验收口径和 Backlog 版本引用。
