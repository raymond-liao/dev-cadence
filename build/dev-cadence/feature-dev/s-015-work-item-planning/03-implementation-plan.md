# S-015 工作项规划 Workflow 与工作项契约：实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use `.dev-cadence/vendor/superpowers/skills/subagent-driven-development/SKILL.md` to execute this plan task-by-task. Each task must have its own review evidence under `sdd/`.

**Goal:** 提供可安装、可路由、边界明确的 `work-item-planning` Asset Workflow，并同步契约验证和发布版本。

**Architecture:** 用一个完整的 workflow skill 承载规划模式、资产所有权、Story Map、卡片和确认写回规则；入口只负责集中路由，既有构建脚本负责复制到 dist。契约测试验证 source 行为和安装结果，不创建真实产品基线。

**Tech Stack:** Markdown skill rules, Bash contract tests, repository build scripts, Git worktree.

## Global Constraints

- 只修改 `src/` 源文件、`tests/`、`version` 和本次必要的 Story/Backlog 状态；不得直接编辑 `dist/.dev-cadence/**`。
- `work-item-planning` 是目标仓库中的 Asset Workflow，不创建 `build/dev-cadence/` manifest、阶段记录、checkpoint 或交付运行记录。
- Discovery 拥有 User Journey 和 Feature；Work Item Planning 只能引用已确认 Feature，不能创建、改名、改 Type、改业务身份或改顺序。
- 不实现 S-016、S-037、S-038、S-039 的独立能力。
- 所有规则文档和测试使用仓库配置的 `zh-CN`，路径使用仓库相对路径。

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Workflow skill | 把业务说明转成可执行的 Asset Workflow 规则 | `src/skills/work-item-planning/SKILL.md` | 新 skill 契约测试的规则断言 |
| Task 2: Central routing | 让入口可选择并正确交接 Work Item Planning | `src/skills/using-dev-cadence/SKILL.md` | `bash tests/routing-contract.sh` |
| Task 3: Contract coverage | 覆盖新 skill、Asset/Delivery 边界、description 和测试入口 | `tests/work-item-planning-contract.sh`, `tests/routing-contract.sh`, `tests/asset-delivery-record-contract.sh`, `tests/package-contract.sh`, `tests/skill-description-contract.sh`, `tests/run-all.sh` | `bash tests/run-all.sh` |
| Task 4: Package and release | 构建安装包并更新发布版本 | `version`, generated `dist/.dev-cadence/**` | `bash scripts/build.sh`, source/dist comparison |
| Task 5: Delivery bookkeeping | 同步 S-015 卡片、Backlog、记录和最终证据 | `docs/stories/S-015-work-item-planning-workflow-contract.md`, `docs/backlog.md`, `build/dev-cadence/feature-dev/s-015-work-item-planning/*` | `bash scripts/check-all.sh`, link and status review |

## Detailed Tasks

### Task 1: Workflow skill

- [x] 新增 `src/skills/work-item-planning/SKILL.md`，包含精确 front matter description、Asset Workflow 声明、适用/不适用场景、组合规划和单项登记模式。
- [x] 明确上游输入读取顺序、Discovery 的 Feature 所有权、Story Map 唯一路径和 Path/Backbone/Milestone/MVP 约束。
- [x] 明确 `S-nnn`/`T-nnn`/`B-nnn` 轻量卡片字段、七种状态、Version/Change Log、复用与并发版本检查。
- [x] 明确确认前仅会话提案、确认后原子写回、交付 workflow 移交和不得创建过程记录的边界。
- [x] 运行新增契约测试的聚焦断言；新 skill 的静态规则均可被测试定位。

### Task 2: Central routing

- [x] 在 `src/skills/using-dev-cadence/SKILL.md` 的 Available Flows 增加 Work Item Planning 路由。
- [x] 增加代表性工作项规划例子、与 Discovery/Feature Dev 的边界和流程优先级规则。
- [x] 保持入口是跨 workflow 路由唯一权威，不把完整矩阵复制进新 skill。
- [x] 运行 `bash tests/routing-contract.sh`；输出 `Routing contract checks passed.`。

### Task 3: Contract coverage

- [x] 新增 `tests/work-item-planning-contract.sh`，验证 Asset Workflow、两种模式、输入/输出资产、Feature 所有权、状态、确认门、Story Map 边界、后续 workflow 移交及禁止 Delivery 记录。
- [x] 更新 `tests/run-all.sh`、`tests/asset-delivery-record-contract.sh`、`tests/package-contract.sh` 和 `tests/skill-description-contract.sh`，使新 skill 纳入既有契约集合。
- [x] 在 `tests/routing-contract.sh` 增加新 workflow 的路由和负向边界检查。
- [x] 先运行新增/修改测试观察预期失败，再在 skill/routing 完成后运行至通过；未通过放宽断言隐藏缺口。

### Task 4: Package and release

- [x] 将 `version` 从 `0.18.0` 更新为 `0.19.0`，理由是新增可安装 workflow 改变用户可见安装行为。
- [x] 运行 `bash scripts/build.sh` 生成 dist；未手工编辑 `dist/.dev-cadence/**`。
- [x] 验证 source 与 dist 的新 skill、入口文件完全一致，且安装包不含本机路径或运行产物。

### Task 5: Delivery bookkeeping

- [x] 将 S-015 卡片状态从旧的 `Blocked` 更新为 `In Progress`；状态变化不递增 Version，Change Log 记录原因。
- [x] 保持 Backlog 处于 In Progress，直到 Business Acceptance；不提前移动并行实施表。
- [x] 更新 `manifest.md`、`04-implementation-record.md`、`04-code-review-report.md` 和 `05-system-test-report.md`，保留测试、review、构建和 source/dist 证据。
- [x] 检查当前 run 的 Markdown 本地链接、关键规则同步和工作树状态；Business Acceptance 作为唯一未完成门记录。

## Completion Conditions

- 所有计划任务有子线程实施和审查记录。
- `bash scripts/check-all.sh` 与 `bash scripts/check-whitespace.sh` 通过。
- 新 skill 在 source、dist 和安装契约中一致可见。
- S-015 卡片为 `Done`，Backlog 第 2 序号可并行项为 `Ready`，没有把后续项的实现混入本次提交。
