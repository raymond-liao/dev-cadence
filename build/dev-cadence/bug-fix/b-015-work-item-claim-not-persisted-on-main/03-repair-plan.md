# B-015 Repair Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修复工作项领取未先在 `main` 持久化的问题，使 `worktree.enabled: true` 与 `false` 两条入口路径都从主 checkout 的已持久化领取状态创建任务 workspace。

**Architecture:** 保留 `using-dev-cadence` 作为唯一入口和现有卡片/Backlog 原子同步语义；把 primary checkout 的身份、领取提交和 workspace 基线验证补充为两种配置共用的连续交接不变量。领取提交属于 workflow 生命周期交接，不替代任务实现提交或阶段 checkpoint。契约测试同时用静态规则断言和临时 Git 仓库动态证明验证主分支基线，避免只证明隔离 workspace 自洽。

**Tech Stack:** Markdown workflow skill、Bash 契约测试、Git 临时 fixture、现有 `scripts/build.sh` 分发构建与 shell 检查。

## Global Constraints

- 规则源只修改 `src/skills/using-dev-cadence/SKILL.md`；不得直接编辑 `dist/.dev-cadence/**`，分发包必须由 `bash scripts/build.sh` 生成。
- 契约测试必须覆盖 `worktree.enabled: true` 的 worktree 基线和 `worktree.enabled: false` 的 dedicated branch 基线；不得用只检查文字出现的断言替代 branch pointer/提交状态验证。
- 领取资格、卡片与 Backlog 原子性、幂等性、Change Log 版本语义、Backlog 顺序、生命周期终态回写和下游 Delivery 阶段保持不变。
- 主 checkout 的领取写入失败、领取提交失败或基线验证失败时，规则必须禁止创建任务 worktree/branch 和下游路由。
- 任何脚本 fixture 使用临时目录并在退出时清理；不得写入 `.dev-cadence.yaml`、`.env`、用户目录或仓库外的持久化路径。
- 运行中使用仓库相对路径记录证据；不把本机绝对路径写入 workflow 记录或规则文本。
- 版本按仓库指南从 `0.26.3` 递增到 `0.26.4`；工作项卡片 Version `4` 不变。
- 每个实现任务完成后只提交该任务相关文件；不 push、不 amend、不修改历史。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| 1. 建立 RED 契约 | 先让测试明确拒绝缺少 primary checkout 持久化的现状，并动态证明 false 路径的主分支基线分叉 | `tests/work-item-development-workflow-contract.sh` | focused contract 在未改规则前失败，失败原因指向 main/持久化不变量 |
| 2. 补齐入口规则 | 定义两种配置共用的 main claim commit、workspace 基线和失败门禁 | `src/skills/using-dev-cadence/SKILL.md` | focused contract、配置契约通过；source 规则顺序可读检查通过 |
| 3. 同步版本与分发包 | 递增根版本并从 source 生成安装包，验证 source/dist 一致 | `version`、`dist/.dev-cadence/**`（生成物） | `bash scripts/build.sh`、package/install contract 通过 |
| 4. 全量回归与交付自检 | 执行全量检查并确认只改动 B-015 允许的资产 | `build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/04-repair-record.md`（后续记录）及实现改动 | whitespace、check-all、focused/config/package/install、`git diff --check`、source/dist 同步检查通过 |

## Detailed Tasks

### Task 1: 建立 RED 契约并验证两条主分支基线

**Files:** `tests/work-item-development-workflow-contract.sh`

- [ ] 在现有入口规则读取和时序断言旁增加静态 RED 断言，要求规则同时出现以下可执行约束：primary/main checkout 是领取写入目标；领取状态必须先创建并持久化提交；worktree 与 dedicated branch 都从该提交创建；领取或持久化失败时不得创建 workspace/路由。断言应定位到具体缺失条件，失败输出不得只写 `contract failed`。
- [ ] 将静态断言分别绑定到 `worktree.enabled: true` 和 `worktree.enabled: false` 的分支文本，确保修复只补 true 路径时测试仍失败。
- [ ] 在同一脚本中加入隔离的临时 Git fixture：创建带有 `Draft` 卡片和 pending Backlog 行的 `main`，用未提交领取变更切出专用 branch 并提交，断言 `main` 仍为 `Draft`，作为错误实现的 RED 证据；随后在 primary checkout 提交领取变更，再从该提交创建 task branch，断言 `main` 与 task branch 都为 `In Progress` 且内容相同。
- [ ] fixture 使用 `mktemp -d`、显式 `git -C` 和 `trap` 清理；断言 branch 指针和文件内容，不能只检查工作树未提交差异。
- [ ] 运行 `bash tests/work-item-development-workflow-contract.sh`，在尚未修改 `src/skills/using-dev-cadence/SKILL.md` 时必须以非零状态失败，并在输出中同时显示静态缺口或动态 baseline 缺口；记录实际失败输出供后续 Repair Implementation 使用。
- [ ] 运行 `git diff --check -- tests/work-item-development-workflow-contract.sh`，确认测试脚本无空白错误。

**Expected result:** 测试在当前规则下稳定 RED；动态 fixture 明确显示“只在 task branch 提交领取”不会改变 `main`，而“先在 main 提交领取”才能成为两条 workspace 的共同基线。

**Commit:** `test(flow): lock B-015 primary checkout claim contract`

### Task 2: 补齐 `using-dev-cadence` 的 GREEN 入口规则

**Files:** `src/skills/using-dev-cadence/SKILL.md`

- [ ] 在现有“卡片与 Backlog 原子同步、先于 branch/worktree”规则之后加入明确身份不变量：无论配置值，领取事务必须在 primary checkout（本仓库基线为 `main`）执行。
- [ ] 明确该事务必须先把权威卡片和 `docs/backlog.md` 原子同步为 `In Progress`，再创建并记录一个可验证的 main claim commit；只有提交成功并取得提交身份后，才允许创建任务 worktree 或 dedicated task branch。
- [ ] 明确 `worktree.enabled: true` 的 workspace 从该 main claim commit 创建/验证 worktree；`worktree.enabled: false` 的 workspace 从该 main claim commit 创建/验证 dedicated task branch，且不得创建 worktree。
- [ ] 明确任何 main checkout 写入、claim commit、workspace baseline 或卡片 Version/状态/Backlog 验证失败都必须停止，不得路由下游 workflow；保留“workspace preparation 先于下游路由”。
- [ ] 明确 claim commit 是生命周期交接记录，不是 Repair Implementation 提交或阶段 checkpoint；不得因此改变现有 checkpoint 提交门。
- [ ] 明确创建后在选定 workspace 检查卡片 Version `4`、`In Progress`、匹配 Backlog 行，并保持领取资格、原子性、幂等性和 Change Log 规则不变。
- [ ] 运行 `bash tests/work-item-development-workflow-contract.sh`，预期从 RED 变为 PASS；运行 `bash tests/configuration-contract.sh`，预期 PASS。
- [ ] 运行 `git diff --check -- src/skills/using-dev-cadence/SKILL.md`，确认规则文本无空白错误，并用 `rg -n` 检查新增关键词在 source 中可定位。

**Expected result:** focused contract 能同时证明 true/false 路径的 main 持久化与基线顺序，入口规则不会允许只在隔离 workspace 写入领取状态。

**Commit:** `fix(flow): require primary checkout claim handoff`

### Task 3: 递增版本并生成、验证安装分发包

**Files:** `version`、由构建生成的 `dist/.dev-cadence/**`

- [ ] 将根目录 `version` 从 `0.26.3` 更新为 `0.26.4`；不得修改 B-015 卡片 Version `4`。
- [ ] 执行 `bash scripts/build.sh`，使 `dist/.dev-cadence/skills/using-dev-cadence/SKILL.md` 从 source 自动同步；不得直接编辑或强制添加被忽略的 dist 文件。
- [ ] 执行 `bash tests/package-contract.sh` 和 `bash tests/install-contract.sh`，确认生成包包含 main claim 规则、版本元数据和安装流程；若脚本需要构建，使用脚本自身生成结果，不手工复制。
- [ ] 用 `cmp -s src/skills/using-dev-cadence/SKILL.md dist/.dev-cadence/skills/using-dev-cadence/SKILL.md` 验证 source/dist 内容一致，并用 `rg --no-ignore -n` 在两处检查 primary checkout、claim commit、true/false workspace 顺序关键词。
- [ ] 检查 `git status --short`，确保没有 `.dev-cadence.yaml`、`.env`、临时日志、PID 或本机绝对路径产物进入变更集。

**Expected result:** 根版本为 `0.26.4`，构建成功，package/install contract 和 source/dist 同步检查全部通过。

**Commit:** `chore(release): bump package version for B-015`

### Task 4: 全量回归、范围审查与交付记录准备

**Files:** 实现改动及后续 `build/dev-cadence/bug-fix/b-015-work-item-claim-not-persisted-on-main/04-repair-record.md`

- [ ] 执行 `bash scripts/check-whitespace.sh`，预期 PASS。
- [ ] 执行 `bash scripts/check-all.sh`，预期完成构建、空白检查和全部仓库契约测试且返回 0。
- [ ] 重新执行 `bash tests/work-item-development-workflow-contract.sh`、`bash tests/configuration-contract.sh`、`bash tests/package-contract.sh`、`bash tests/install-contract.sh`，保留每个命令的返回状态和关键输出。
- [ ] 执行 `git diff --check`，并用 `git diff --name-status main...HEAD` 审查变更只包含 `src/skills/using-dev-cadence/SKILL.md`、`tests/work-item-development-workflow-contract.sh`、`version` 和本次 B-015 运行记录；`dist` 只作为构建验证产物，不直接编辑。
- [ ] 用 `rg --no-ignore -n` 对照 source 与 dist，确认规则没有被构建截断；检查新增 Markdown 链接目标存在，且没有绝对本机路径。
- [ ] 在实现阶段创建 `04-repair-record.md`，记录 RED/GREEN、main claim commit、true/false baseline 验证、构建与回归命令；本计划阶段不提前伪造实现结果。
- [ ] 完成集成前自检：`git status --short` 只剩计划允许的已跟踪文件，确认不 push、不 amend，等待 Code Review 和 Regression Verification 门禁。

**Expected result:** 全量检查通过，变更范围闭合，主 checkout 与两种 task workspace 的持久化基线证据可在后续 review/验收记录中追溯。

**Commit:** `test(flow): verify B-015 regression and scope`
