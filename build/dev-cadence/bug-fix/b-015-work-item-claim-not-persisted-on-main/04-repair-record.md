# B-015 Repair Implementation Record

## Implementation Identity

- Implementation Base SHA：`0e5d69e73f6bf760ff954ba15119ad9c429571be`
- Final Implementation SHA：`04a958e07ccdb6a3a4ba20a1d3c053b1104d750e`
- Reviewed implementation range：`0e5d69e73f6bf760ff954ba15119ad9c429571be..04a958e07ccdb6a3a4ba20a1d3c053b1104d750e`
- Changed Files：`src/skills/using-dev-cadence/SKILL.md`、`tests/work-item-development-workflow-contract.sh`、`version`、`docs/bugs/B-015-work-item-claim-not-persisted-on-main.md`、`docs/backlog.md`、本运行目录下的 B-015 records。

## Scope And Entry Gates

- 工作项：[B-015 工作项领取未在 main 持久化](../../../../docs/bugs/B-015-work-item-claim-not-persisted-on-main.md)
- 修复范围：使 `worktree.enabled: true` 与 `worktree.enabled: false` 都从已解析并验证的权威 base ref（本仓库为 `main`）上的持久化领取提交创建任务 workspace。
- 主 checkout 领取提交：`0e5d69e73f6bf760ff954ba15119ad9c429571be`。该提交原子地将 B-015 卡片和 `docs/backlog.md` 行同步为 `In Progress`；任务 worktree 从该提交创建。
- 实施前门禁：领取写入、主 checkout 领取提交和 workspace 基线验证均先完成；Repair Plan 已确认并形成 checkpoint `e6c7361` 后才开始 Task 1--4 的实现。未在上述门禁完成前开始实现、需求、方案、计划或 checkpoint 工作。

## RED / GREEN 证据

### RED

Task 1 在 source 规则变更前运行 `bash tests/work-item-development-workflow-contract.sh` 返回 `1`。临时 Git fixture 已证明错误基线：未提交领取变更后创建 `task-from-uncommitted-claim` 并提交，`main` 的卡片仍为 `Draft`、Backlog 行仍为 pending，且两分支指针不同。随后 fixture 证明正确基线：先在 `main` 提交领取，再创建真实 `task-worktree` 和 `task-from-primary-claim`，两种 workspace 的指针、卡片和 Backlog 均与 `main` 的 `In Progress` 领取状态一致。预期失败输出为：

```text
B-015 primary-checkout claim baseline fixture passed.
FAIL: missing enabled worktree path primary checkout claim write target in src/skills/using-dev-cadence/SKILL.md
```

### GREEN

入口规则现在要求无论 `worktree.enabled` 配置为何，都必须先解析并验证权威 base ref，在 primary checkout 原子同步卡片与 `docs/backlog.md`，记录 claim commit 并确认其推进该精确 ref 后，才可创建任务 workspace。`true` 路径从该提交创建或验证 worktree；`false` 路径从该提交准备 dedicated branch 且不得创建 worktree。任何 primary 写入、claim persistence/commit、base-ref advancement、基线、Version、状态或 Backlog 验证的失败均阻止对应 workspace 创建和下游路由；成功的写入或提交不构成停止条件。B-015 运行记录核对卡片 Version `4`，通用入口规则只要求与 authoritative card Version 一致。

动态 fixture 在 GREEN 回归中再次覆盖两条基线：

- `task-from-uncommitted-claim`：保留错误基线，确认只在 task branch 提交不能更新 `main`。
- `task-worktree`：使用 `git worktree add` 从已持久化的 `main` 领取提交创建真实 linked worktree，确认其 `HEAD` 等于 `main`，并确认卡片与 Backlog 内容匹配；fixture 在移除临时目录前移除此 worktree。
- `task-from-primary-claim`：确认先在 `main` 持久化领取时，dedicated task branch 与 `main` 共享提交指针、`In Progress` 卡片和匹配 Backlog 行。

## 版本、构建与验证

- 包版本从 `0.26.3` 递增到 `0.26.4`；B-015 卡片 Version 保持 `4`。
- `dist/.dev-cadence` 仅由构建脚本生成，未直接编辑或强制加入 Git。
- `cmp -s src/skills/using-dev-cadence/SKILL.md dist/.dev-cadence/skills/using-dev-cadence/SKILL.md` 返回 `0`；source 与生成包字节一致。
- `rg --no-ignore -n` 在 source 与 dist 均定位到 primary checkout、main claim commit、`worktree.enabled: true` / `false` 的规则，未发生构建截断。

| 命令 | 结果 | 关键输出 |
| --- | --- | --- |
| `bash scripts/check-whitespace.sh` | ✅ 返回 `0` | 无输出，空白检查通过。 |
| `bash scripts/check-all.sh` | ✅ 返回 `0` | `Package contract checks passed.`、`B-015 primary-checkout claim baseline fixture passed.`、`S-017 work-item development workflow contract checks passed.`、`Install contract checks passed.`、`Confirmation gates contract checks passed.`。 |
| `bash tests/work-item-development-workflow-contract.sh` | ✅ 返回 `0` | `B-015 primary-checkout claim baseline fixture passed.`；`S-017 work-item development workflow contract checks passed.`。 |
| `bash tests/configuration-contract.sh` | ✅ 返回 `0` | `Configuration contract checks passed.` |
| `bash tests/package-contract.sh` | ✅ 返回 `0` | `Package contract checks passed.` |
| `bash tests/install-contract.sh` | ✅ 返回 `0` | 安装 Dev Cadence `0.26.4` 两次；`Install contract checks passed.` |
| `git diff --check` | ✅ 返回 `0` | 无空白错误。 |

## 范围、自检与风险

## Code Review Evidence

- Report: [Code review report](04-code-review-report.md) (`build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/04-code-review-report.md`)
- Review decision：✅ `ready to proceed to Regression Verification`；最终 whole-branch review 覆盖 `0e5d69e..04a958e`。
- Critical findings：`0`，无 Critical finding。
- Important findings：首轮 `4` 个，均已在 `04a958e` 修复并由复审验证 `fixed`；当前 `0` 个未解决。
- Unresolved findings：`None`。

`git diff --name-status main...HEAD` 显示的实现路径为：

- `src/skills/using-dev-cadence/SKILL.md`
- `tests/work-item-development-workflow-contract.sh`
- `version`
- `docs/bugs/B-015-work-item-claim-not-persisted-on-main.md` 与 `docs/backlog.md`（B-015 领取的权威卡片/Backlog 原子同步）
- `build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/` 下的 B-015 运行记录（包含本记录）

范围内没有手工修改 `dist/.dev-cadence/**`。已检查新增和引用的 Markdown 链接：B-015 卡片、既有诊断/方案记录以及 Backlog 目标存在。对 B-015 修改范围执行绝对本机路径与本地文件 URI 检索，未发现持久化的本机路径；无 `.env`、`.dev-cadence.yaml`、PID、日志或临时 fixture 进入已跟踪变更。

剩余风险：动态 fixture 证明了 `true` 和 `false` 路径共用的 Git 基线交接不变量，但不替代后续 Code Review、Regression Verification 和 Business Acceptance 门禁。本任务未 push、未 amend，且未修改 manifest；等待后续门禁更新其阶段状态。
