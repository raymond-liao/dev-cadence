# B-012 修复计划

- Workflow: `bug-fix`
- Work Item: [B-012 Draft Story 在 Ready 门禁前被提前领取](../../../../docs/delivery/bugs/B-012-draft-story-claimed-before-ready-gate.md)
- Diagnosis: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/01-problem-diagnosis-record.md`
- Repair Solution: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/02-repair-solution.md`
- Confirmed solution: 入口内建立有序领取资格矩阵（方案 B）
- Plan status: 🔄 `in_progress`
- Implementation worktree: `.worktrees/b012-draft-story-claimed`
- Implementation branch: `codex/b012-draft-story-claimed`
- Implementation base: `e96d344`

## Pre-Implementation Design Freshness Gate

- Card identity: `docs/bugs/B-012-draft-story-claimed-before-ready-gate.md`, Version `1`, Status `In Progress`
- Confirmed inputs: `01-problem-diagnosis-record.md`, `02-repair-solution.md`, this plan
- Current branch and commit: `codex/b012-draft-story-claimed` at `ead5d96`
- Dependency/config state: `.dev-cadence.yaml` propagated and verified; baseline `bash scripts/check-all.sh` passed
- Conclusion: ✅ `confirmed`; diagnosis, solution, scope, acceptance criteria and task split remain valid
- Evidence summary: no material repository changes since plan confirmation; worktree is clean before implementation

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: RED 顺序与场景契约 | 让 claim-before-maturity 顺序缺陷在基线下失败，并锁定四类工作项路由 | `tests/work-item-development-workflow-contract.sh` | focused contract fails for missing ordered matrix |
| Task 2: 有序领取资格矩阵 | 在入口先判定类型/状态/成熟度，再对合格项 claim | `src/skills/using-dev-cadence/SKILL.md` | focused contract passes; source rule order verified |
| Task 3: 分发与全量回归 | 同步安装包并验证 Story/Task/Bug 路由不回归 | `dist/.dev-cadence/**`, `version` | build, package/install, `scripts/check-all.sh` |

## Detailed Tasks

### Task 1: RED 顺序与场景契约

1. 在 `tests/work-item-development-workflow-contract.sh` 增加精确的入口段解析，而不是只对全文件做存在性匹配。
2. 先写断言：类型/状态/成熟度解析必须位于首次 claim 写入之前；Draft Story 必须出现“不 claim、不改 `In Progress`”；Ready Story、Task、Bug 必须各有正向资格路径。
3. 运行 `bash tests/work-item-development-workflow-contract.sh`，预期 RED：当前规则中 claim 段位于成熟度路由之前，且没有四场景有序矩阵。
4. 记录失败输出和命中的规则位置，作为 Repair Implementation 的 RED 证据。

### Task 2: 有序领取资格矩阵

1. 在唯一入口所有者 `src/skills/using-dev-cadence/SKILL.md` 的 `Work Item Intake And Claiming` 内重排并明确：选择 -> 解析类型/状态/成熟度 -> 按类型判定 -> 合格项原子 claim -> branch/worktree -> 下游 workflow。
2. 明确 Draft Story 在 Work Item Analysis 和用户确认 Ready 前不得 claim；确认 Ready 后新的或继续中的实施请求重新判定资格。
3. 保留 Ready Story、Task、Bug 的既有非统一门禁，以及 claim 的原子性、幂等性、Version/Change Log 和 branch/worktree 时序。
4. 运行 Task 1 focused test，预期 GREEN；只在 GREEN 后进行措辞整理，保持测试继续通过。

### Task 3: 分发与全量回归

1. 运行 `bash scripts/build.sh`，只由构建脚本同步 `dist/.dev-cadence`，不直接编辑分发文件。
2. 运行 `bash tests/work-item-analysis-contract.sh`、`bash tests/work-item-planning-contract.sh`、`bash tests/routing-contract.sh`、`bash tests/package-contract.sh`、`bash tests/install-contract.sh`。
3. 运行 `bash scripts/check-whitespace.sh` 和 `bash scripts/check-all.sh`。
4. 用 `rg --no-ignore` 对比 source/dist 的入口矩阵和顺序，确认未修改 Work Item Analysis、Task/Bug 门禁或 B-011 worktree 时点。

## Completion Conditions

- RED 证据已记录，随后 focused contract 和全量 `scripts/check-all.sh` 均通过。
- Draft Story 在任何 claim 写入前进入 Work Item Analysis；Ready Story、Task、Bug 路由保持原语义。
- source、dist、安装验证和根版本（如行为变更需要）同步完成。
- 变更范围仅限确认的 B-012 修复边界，完成 self-review 后提交实施记录和 review evidence。

## Self-Review

- 检查是否把成熟度判断重新分散到多个入口段。
- 检查是否误把 Task 或 Bug 套用 Story Ready 门禁。
- 检查是否改变 claim 的原子写回、幂等性或 branch/worktree 时序。
