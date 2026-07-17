# B-008 Bug Fix 运行清单

- Workflow: `bug-fix`
- Task Slug: `b-008-bug-fix-backlog-sync`
- Work Item: [B-008 Bug Fix 完成后未更新 Backlog](../../../../docs/bugs/B-008-bug-fix-completion-does-not-update-backlog.md)
- Work Item Version: `1`
- Repository: `dev-cadence` (`git@github.com:raymond-liao/dev-cadence.git`)
- Workspace: `.worktrees/b-008-bug-fix-backlog-sync`
- Branch: `codex/b-008-bug-fix-backlog-sync`
- Started At: `2026-07-18T07:19:45+0800`
- Current Stage: Problem Diagnosis
- Overall Status: `in_progress`

## 阶段表

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Problem Diagnosis | 🔄 `in_progress` | [问题诊断记录](01-problem-diagnosis-record.md) (`build/dev-cadence/bug-fix/b-008-bug-fix-backlog-sync/01-problem-diagnosis-record.md`) | pending | `pending` | 已完成 Completion 规则与 Backlog 责任对照，待用户确认诊断。 |
| Repair Solution | ⏳ `pending` | ⏳ `pending`: `build/dev-cadence/bug-fix/b-008-bug-fix-backlog-sync/02-repair-solution.md` | pending | `pending` | 等待 Problem Diagnosis 确认。 |
| Repair Plan | ⏳ `pending` | ⏳ `pending`: `build/dev-cadence/bug-fix/b-008-bug-fix-backlog-sync/03-repair-plan.md` | pending | `pending` | 等待 Repair Solution 确认。 |
| Repair Implementation | ⏳ `pending` | ⏳ `pending`: `build/dev-cadence/bug-fix/b-008-bug-fix-backlog-sync/04-repair-record.md` | pending | `pending` | 等待 Repair Plan 确认。 |
| Regression Verification | ⏳ `pending` | ⏳ `pending`: `build/dev-cadence/bug-fix/b-008-bug-fix-backlog-sync/05-regression-test-report.md` | pending | `pending` | 尚未开始。 |
| Business Acceptance | ⏳ `pending` | ⏳ `pending`: `build/dev-cadence/bug-fix/b-008-bug-fix-backlog-sync/06-business-acceptance-record.md` | pending | `pending` | 必须由用户选择固定验收选项。 |

## 诊断摘要

- `bug-fix` 的 Completion 规则要求记录集成结果，但没有规定在成功集成后同步更新 `docs/backlog.md`。
- Work Item Planning 规定 Backlog 是工作项状态汇总视图，但没有把 Bug Fix Completion 的成功结果绑定为 Backlog `Done` 写回动作。
- 现有历史运行中，B-002 的 Backlog 变化通过后续文档/集成提交完成，不能证明 bug-fix 规则会自动或稳定执行同步。

## 验证摘要

- Diagnosis Baseline: `ec0ee0c6b6dc07c30537c9fd1789c3af4165f6f3`
- Baseline checks: `bash scripts/build.sh`; `bash tests/run-all.sh` -> passed
- Scope: `src/skills/bug-fix/SKILL.md`, `src/skills/work-item-planning/SKILL.md`, `docs/backlog.md`, B-002 completion evidence and workflow contract tests

