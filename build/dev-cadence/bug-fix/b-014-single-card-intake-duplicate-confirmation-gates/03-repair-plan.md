# B-014 修复计划

- Workflow: `bug-fix`
- Work Item: [B-014 单项建卡被错误套用双确认门](../../../../docs/bugs/B-014-single-card-intake-duplicate-confirmation-gates.md)
- Diagnosis: `build/dev-cadence/bug-fix/b-014-single-card-intake-duplicate-confirmation-gates/01-problem-diagnosis-record.md`
- Repair Solution: `build/dev-cadence/bug-fix/b-014-single-card-intake-duplicate-confirmation-gates/02-repair-solution.md`
- Confirmed solution: 显式双分支与 Direct Intake 专属门名（方案一）
- Plan status: 🔄 `in_progress`
- Implementation worktree: `.worktrees/b014-single-card-intake`
- Implementation branch: `codex/b014-single-card-intake`
- Implementation base: `e96d344`

## Pre-Implementation Design Freshness Gate

- Card identity: `docs/bugs/B-014-single-card-intake-duplicate-confirmation-gates.md`, Version `1`, Status `In Progress`
- Confirmed inputs: `01-problem-diagnosis-record.md`, `02-repair-solution.md`, this plan
- Current branch and commit: `codex/b014-single-card-intake` at `f5c3e86`
- Dependency/config state: `.dev-cadence.yaml` propagated and verified; baseline `bash scripts/check-all.sh` passed
- Conclusion: ✅ `confirmed`; diagnosis, solution, scope, acceptance criteria and task split remain valid
- Evidence summary: no material repository changes since plan confirmation; worktree is clean before implementation

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: RED 模式门禁契约 | 让 Direct Intake 继承双门的基线行为失败，并锁定 Portfolio 双门 | `tests/work-item-planning-contract.sh`, `tests/confirmation-gates-contract.sh` | focused tests fail |
| Task 2: 显式双分支修复 | Direct Intake 使用一次专属结果确认，Portfolio Planning 保持双门 | `src/skills/work-item-planning/SKILL.md`, `docs/workflows/work-item-planning.md` | focused tests pass |
| Task 3: 原子写入与分发回归 | 验证命名子集、Backlog 原子一致性和 source/dist/install 同步 | `tests/work-item-planning-contract.sh`, `tests/package-contract.sh`, `tests/install-contract.sh`, `version` | `scripts/check-all.sh` |

## Detailed Tasks

### Task 1: RED 模式门禁契约

1. 增加按模式提取规则块的契约断言：Direct Intake 不得包含 `Planning Inputs And Scope Confirmation`，且只能有一个正式结果确认；必要澄清必须明确不是正式门。
2. 同时断言 Portfolio Planning 仍包含输入范围门和规划结果门。
3. 增加命名子集原子单元断言：卡片与必要 Backlog 引用不得拆分确认。
4. 运行 `bash tests/work-item-planning-contract.sh` 和 `bash tests/confirmation-gates-contract.sh`，预期 RED：当前共享三阶段使 Direct Intake 命中两道正式门。

### Task 2: 显式双分支修复

1. 在 `src/skills/work-item-planning/SKILL.md` 将 Stage Sequence 改为模式专属分支：Portfolio 保持三阶段；Direct Intake 使用必要澄清 -> `Direct Intake Proposal` -> `Direct Intake Result Confirmation`。
2. 明确必要澄清不形成正式门，结果门一次展示完整卡片、ID、路径、Priority、关系、依赖和全部必要 Backlog 变化。
3. 保留确认前零写入、要求修改零写入、版本冲突停止、Portfolio 部分确认和 MVP/Milestone 决定权。
4. 同步 `docs/workflows/work-item-planning.md` 的业务说明，并运行 Task 1 focused tests，预期 GREEN。

### Task 3: 原子写入与分发回归

1. 用契约测试覆盖 `confirm only the named subset` 不能产生孤立卡片或 Backlog 行，Ordering Version/Change Log 的同步语义保持不变。
2. 运行 `bash scripts/build.sh`，再运行 `bash tests/package-contract.sh`、`bash tests/install-contract.sh`、`bash scripts/check-whitespace.sh` 和 `bash scripts/check-all.sh`。
3. 用 `rg --no-ignore` 和 source/dist 对比确认两种模式的阶段分支和门禁数量一致。
4. 检查 diff 不包含 Work Item Analysis、Delivery Workflow、Business Acceptance 或历史卡片修改。

## Completion Conditions

- RED 证据已记录，Direct Intake focused/full tests 和 Portfolio 双门回归均通过。
- Direct Intake 只有一次正式确认，必要澄清不成为额外门；卡片与必要 Backlog 引用原子一致。
- source、dist、安装验证和根版本（如行为变更需要）同步完成。
- 变更范围仅限确认的 B-014 修复边界，完成 self-review 后提交实施记录和 review evidence。

## Self-Review

- 检查 Direct Intake 专属门名没有被误写回共享 Stage Sequence。
- 检查 Portfolio Planning 的双门和部分确认语义未削弱。
- 检查命名子集不会拆散卡片、Backlog、Ordering Version 和 Change Log 的必要原子单元。
