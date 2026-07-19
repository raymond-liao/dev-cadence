# B-015 Regression Test Report

## Problem And Repair Sources

- Problem diagnosis: [01-problem-diagnosis-record.md](01-problem-diagnosis-record.md)
- Repair solution: [02-repair-solution.md](02-repair-solution.md)
- Repair plan: [03-repair-plan.md](03-repair-plan.md)
- Repair implementation: [04-repair-record.md](04-repair-record.md)
- Code review: [04-code-review-report.md](04-code-review-report.md)

## Test Environment

- Repository：`dev-cadence`
- Branch：`codex/b015-work-item-claim-persisted`
- Implementation base：`0e5d69e`
- Verification HEAD：`3733992`（包含 manifest 阶段转换；实现最终提交为 `04a958e`）
- Configuration：`output_language: zh-CN`；`worktree.enabled: true`；`worktree.directory: .worktrees`
- Runtime：macOS shell，Git 临时仓库 fixture，仓库既有 Bash 构建与契约脚本
- Servers/network：无；本次验证不依赖外部服务或网络
- Verification time：`2026-07-19T21:01:58+0800`

## Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| RV-001 | 完整仓库契约、构建、安装和空白检查 | automated regression | `bash scripts/check-all.sh` | ✅ PASS，退出码 0 | 包、记录、配置、路由、工作项、安装和 B-015 fixture 均通过 |
| RV-002 | `worktree.enabled: true/false` 入口契约 | automated regression | `bash tests/work-item-development-workflow-contract.sh` | ✅ PASS，退出码 0 | fixture 创建 `git worktree add` 的 `task-worktree`，并验证 dedicated branch `task-from-primary-claim` |
| RV-003 | 配置传播与 worktree 选择 | automated contract | `bash tests/configuration-contract.sh` | ✅ PASS | `Configuration contract checks passed.` |
| RV-004 | source 到 dist 的生成包契约 | build/package | `bash scripts/build.sh`；`bash tests/package-contract.sh`；`cmp -s src/skills/using-dev-cadence/SKILL.md dist/.dev-cadence/skills/using-dev-cadence/SKILL.md` | ✅ PASS | source/dist 字节一致，包版本为 `0.26.4` |
| RV-005 | 安装包重复安装与用户可见规则 | install | `bash tests/install-contract.sh` | ✅ PASS | Dev Cadence `0.26.4` 两次安装均通过 |
| RV-006 | source/dist 关键规则完整性 | source inspection | `rg --no-ignore` 检查 authoritative base ref、claim commit advancement、true/false workspace 顺序 | ✅ PASS | source 与 dist 均包含关键规则，未发生构建截断 |
| RV-007 | 代码与记录空白、链接和范围 | repository hygiene | `bash scripts/check-whitespace.sh`；`git diff --check`；链接/绝对路径/产物检查 | ✅ PASS | 无空白错误、断链、本机绝对路径或禁入产物 |
| RV-008 | 已报告错误基线：未提交 claim 后创建 branch | dynamic Git fixture | fixture 在临时仓库创建 `task-from-uncommitted-claim` 并提交 | ✅ PASS（错误基线被复现） | `main` 保持 `Draft`/pending，两个 branch 指针不同 |
| RV-009 | `worktree.enabled: true`：从 main claim commit 创建真实 worktree | dynamic Git fixture | fixture 执行 `git worktree add -b task-worktree ... main_commit` | ✅ PASS | linked worktree `HEAD`、卡片和 Backlog 与 `main` claim commit 一致，并在清理前移除 |
| RV-010 | `worktree.enabled: false`：从 main claim commit 创建 dedicated branch | dynamic Git fixture | fixture 从 persisted main claim 创建 `task-from-primary-claim` | ✅ PASS | dedicated branch 指针、卡片和 Backlog 与 `main` 一致 |
| RV-011 | 下游实时用户入口端到端执行 | manual/live optional | 未启动真实下游 Delivery Workflow；规则入口由静态契约和临时 Git fixture 覆盖 | ⏭ SKIPPED（非阻塞） | 不改变本次已执行的入口基线与安装包验证结论 |

## Bug Fix Coverage

| Acceptance point | Test IDs | Status |
| --- | --- | --- |
| true path claim 在创建 worktree 前于 authoritative base ref 持久化 | RV-002, RV-006, RV-009 | covered |
| false path claim 在创建 dedicated branch 前于 authoritative base ref 持久化 | RV-002, RV-006, RV-010 | covered |
| 卡片与 `docs/backlog.md` 原子同步为 `In Progress`，主 checkout 不继续 Draft/pending | RV-008, RV-009, RV-010 | covered |
| workspace 从相同 persisted claim commit 创建且 Version/status/Backlog 一致 | RV-002, RV-009, RV-010 | covered |
| primary checkout、authoritative base ref 和 claim commit advancement 门禁明确 | RV-002, RV-006 | covered |
| 失败不得创建 workspace 或下游路由 | RV-002, RV-006 | covered（规则契约） |
| 领取资格、原子性、幂等性、Change Log 和 Backlog 顺序未改变 | RV-001, RV-002, RV-006 | covered |

## Impact Scope Coverage

| Affected area | Test IDs | Status |
| --- | --- | --- |
| `src/skills/using-dev-cadence/SKILL.md` 入口规则 | RV-002, RV-006 | covered |
| 两种 workspace handoff 与 Git baseline | RV-008, RV-009, RV-010 | covered |
| source/dist/build/install package | RV-001, RV-004, RV-005, RV-006 | covered |
| 配置传播与 `worktree.enabled` 选择 | RV-003 | covered |
| 下游 Delivery Workflow 实时业务执行 | RV-011 | skipped（optional live check） |

## Failed Or Skipped Checks

- Failed checks：None。
- RV-011 未启动真实下游 Delivery Workflow；原因是本次 Bug 的修复对象是入口规则和 Git 状态基线，既有契约与动态 fixture 已覆盖两条配置路径。该项作为非阻塞风险保留给 Business Acceptance 判断。

## Residual Risks

- 真实用户入口在一个业务仓库中的完整下游路由未执行；静态入口契约、动态 Git fixture、构建、安装和全量仓库契约均已执行。
- 这不构成已确认目标失败，但 Business Acceptance 应知道该 live check 未覆盖。

## Verification Decision

`ready_with_risk`

Verification Result: `ready_with_risk`

执行证据覆盖原始状态分叉、authoritative base ref、true worktree、false dedicated branch、source/dist/install 和全量仓库契约；唯一跳过的是非阻塞的真实下游 live workflow 执行。

## Recommendation

可以进入 Business Acceptance；建议在接受决定中明确是否接受未执行真实下游 live workflow 的残余风险。
