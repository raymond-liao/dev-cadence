# S-014 Discovery User Journey 与 Feature 基线实施计划

- Status: ✅ `confirmed`
- Workspace: `.worktrees/s-014-user-journey-baseline`
- Branch: `codex/s-014-user-journey-baseline`
- Confirmation: delegated by the user's parallel implementation instruction on `2026-07-16`。

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 Discovery 从 PRD/Business Architecture 双资产单门模型升级为 User Journey、PRD、Business Architecture 三资产两门模型，并保持入口、说明、测试、安装包与版本一致。

**Architecture:** User Journey 和 Feature Definitions 继续由现有 `discovery` 权威 skill 内聚管理，不新增 workflow 或共享 skill。契约测试先锁定三资产、五阶段、两门、增量协调和路由边界，再修改 source skill、入口、README 与分发契约；构建脚本负责生成忽略的 `dist/.dev-cadence/`。

**Tech Stack:** Markdown workflow skills、Bash contract tests、`rg`、Git、现有 `scripts/build.sh` 与 `scripts/check-all.sh`。

## Global Constraints

- 只实现 [S-014 Version 2](../../../../docs/stories/S-014-user-journey-analysis.md) 的确认范围。
- `src/skills/discovery/SKILL.md` 是 Discovery 执行行为权威来源；`docs/workflows/discovery.md` 是已确认业务设计输入但不替代 skill。
- 不修改 `src/vendor/superpowers/**`、Open Question Registry 或相邻 Delivery workflow。
- 不新增多 Journey 目录、根索引、拆分阈值、Story Map 或工作项规划行为。
- `dist/.dev-cadence/**` 只能由 `bash scripts/build.sh` 生成，不直接编辑、不强制加入 Git。
- 根版本从 `0.17.1` 升到 `0.18.0`。
- 每个实施提交前遵守 Feature Dev 的 staged-tree review gate；任务记录不混入实施提交。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: 三资产 Discovery 核心契约 | 用 TDD 建立 Journey/Feature、五阶段、两门和增量协调的权威行为。 | `tests/discovery-contract.sh`, `src/skills/discovery/SKILL.md` | `bash tests/discovery-contract.sh` RED 后 GREEN；旧模型负向扫描通过。 |
| Task 2: 产品 Feature 与交付 Feature 路由边界 | 让产品级 Journey/Feature 请求进入 Discovery，同时保持行为实现请求进入 Feature Dev。 | `tests/routing-contract.sh`, `src/skills/using-dev-cadence/SKILL.md` | `bash tests/routing-contract.sh` RED 后 GREEN；Discovery focused contract 保持 GREEN。 |
| Task 3: 公开说明、分发契约与版本 | 同步双语 README、package parity 和 `0.18.0` 版本。 | `README.md`, `README.zh-CN.md`, `tests/package-contract.sh`, `version` | package contract 先 RED；构建后 package、Discovery、routing focused checks 全部 GREEN。 |
| Task 4: 治理状态与开发阶段回归 | 更新 S-014/Backlog，重算 S-015，并完成全量开发验证与自审。 | `docs/stories/S-014-user-journey-analysis.md`, `docs/stories/S-015-work-item-planning-workflow-contract.md`, `docs/backlog.md` | 关键状态搜索、source/dist 搜索、whitespace、`bash scripts/check-all.sh` 全部通过。 |

## Detailed Tasks

### Task 1: 三资产 Discovery 核心契约

**Files:**
- Modify: `tests/discovery-contract.sh`
- Modify: `src/skills/discovery/SKILL.md`

**Interfaces:**
- Consumes: S-014 Version 2 和 `docs/workflows/discovery.md` 的五阶段、Journey/Feature、版本及增量规则。
- Produces: 后续入口与 README 可以摘要引用的 Discovery 三资产权威契约。

- [ ] **Step 1: 在 Discovery contract 中写入三资产和门禁的失败断言**

  增加或替换为以下行为断言，保留现有内容边界、Asset Workflow 和无运行记录断言：

  ```bash
  assert_literal "User Journey output" 'docs/product-design/user-journey.md' "$DISCOVERY_SKILL"
  assert_literal "Journey analysis stage" 'User Journey Analysis' "$DISCOVERY_SKILL"
  assert_literal "Journey confirmation stage" 'User Journey Confirmation' "$DISCOVERY_SKILL"
  assert_literal "derivation stage" 'PRD And Business Architecture Derivation' "$DISCOVERY_SKILL"
  assert_match "two confirmation gates" 'two confirmation gates|two.*confirmation.*gates' "$DISCOVERY_SKILL"
  assert_match "Journey gate blocks derivation" 'User Journey.*confirmed.*before.*PRD.*Business Architecture|do not.*derive.*PRD.*Business Architecture.*until.*User Journey.*confirmed' "$DISCOVERY_SKILL"
  assert_match "Journey identity" 'J-nnn|J-[0-9]{3}' "$DISCOVERY_SKILL"
  assert_match "Feature identity" 'F-nnn|F-[0-9]{3}' "$DISCOVERY_SKILL"
  assert_literal "Feature definition fields" 'ID | Type | Title | Description' "$DISCOVERY_SKILL"
  assert_match "Feature types" 'Offline.*System|System.*Offline' "$DISCOVERY_SKILL"
  assert_match "stable Feature identity" 'rename.*Type.*retain.*ID|retain.*ID.*rename.*Type' "$DISCOVERY_SKILL"
  assert_match "shared Feature identity" 'multiple roles.*same Feature|same Feature.*multiple roles' "$DISCOVERY_SKILL"
  assert_match "PRD traceability" 'Product Requirement.*Journey.*Feature' "$DISCOVERY_SKILL"
  assert_match "Business Architecture traceability" 'Business Architecture.*Journey.*Feature' "$DISCOVERY_SKILL"
  assert_match "Journey unaffected incremental path" 'does not affect.*User Journey.*do not.*reconfirm.*rewrite.*increment|do not.*reconfirm.*rewrite.*increment.*User Journey' "$DISCOVERY_SKILL"
  assert_match "legacy baseline migration" 'PRD.*Business Architecture.*without.*User Journey|without.*User Journey.*PRD.*Business Architecture' "$DISCOVERY_SKILL"
  ```

  增加旧模型负向断言：

  ```bash
  assert_not_match "legacy stage sequence" 'Goal And Value Definition -> Scope And Business Architecture Analysis' "$DISCOVERY_SKILL"
  assert_not_match "dual-only primary outputs" 'only primary.*outputs.*PRD.*Business Architecture' "$DISCOVERY_SKILL"
  assert_not_match "single gate for all assets" 'one consolidated user confirmation covering both product-design documents' "$DISCOVERY_SKILL"
  ```

- [ ] **Step 2: 运行 focused test 并记录 RED**

  Run: `bash tests/discovery-contract.sh`

  Expected: FAIL，首个失败应指向缺少 `docs/product-design/user-journey.md` 或新阶段/门禁；不得因 Bash 语法错误失败。

- [ ] **Step 3: 重写 Discovery 的资产、阶段、Journey/Feature 和持久化契约**

  在 `src/skills/discovery/SKILL.md` 中使用以下唯一阶段序列：

  ```text
  Background And Problem Exploration -> User Journey Analysis -> User Journey Confirmation -> PRD And Business Architecture Derivation -> Product Design Confirmation
  ```

  把标准主产物改为：

  ```text
  docs/product-design/user-journey.md
  docs/product-design/prd.md
  docs/product-design/business-architecture.md
  ```

  增加 `User Journey Contract`，明确：

  ```text
  Document Information
  Journey ID
  Business Line And Boundary
  Journey Map
  Feature Definitions
  Open Questions
  Rejected Directions
  Change Log
  ```

  并写入以下规范：Journey Map 为普通 Markdown Table；行是角色；列是从左到右业务顺序；连续空表头继承最近的左侧非空阶段；Feature Definitions 字段固定为 `ID | Type | Title | Description`；Type 只允许 `Offline` 和 `System`；Journey/Feature 使用仓库全局唯一 `J-nnn`/`F-nnn`；业务身份不变时改名或 Type 调整保留 ID；多角色使用同一能力时复用同一 Feature。

- [ ] **Step 4: 重写两道确认门和增量协调**

  明确两道门的写入边界：

  ```text
  Before User Journey Confirmation, keep the complete Journey proposal in the conversation and do not write the authoritative Journey path.
  After User Journey Confirmation, atomically write only the confirmed Journey revision.
  Do not formally derive PRD and Business Architecture until the User Journey is confirmed.
  Before Product Design Confirmation, keep the complete PRD and Business Architecture proposal in the conversation and leave their authoritative paths and supporting assets unchanged.
  After Product Design Confirmation, atomically write only affected PRD and Business Architecture assets and confirmed supporting maintenance.
  ```

  增量规则必须覆盖：输入不影响 Journey 时不重新确认、不改写、不升版；影响 Journey 时先确认 Journey 修订；已有 PRD/Business Architecture 但无 Journey 时将旧资产作为可信输入，先形成首份 Journey，再只协调实际受影响资产。

- [ ] **Step 5: 运行 GREEN 与旧语句反向扫描**

  Run: `bash tests/discovery-contract.sh`

  Expected: `Discovery contract checks passed.`

  Run:

  ```bash
  rg -n 'Goal And Value Definition -> Scope And Business Architecture Analysis|only primary.*PRD.*Business Architecture|one consolidated user confirmation covering both' src/skills/discovery/SKILL.md
  ```

  Expected: no matches。

- [ ] **Step 6: 自审并提交 Task 1**

  Stage only `tests/discovery-contract.sh` and `src/skills/discovery/SKILL.md`，执行 staged-tree review gate 和 `git diff --cached --check`，修复所有 Critical/Important 问题后提交：

  ```bash
  git commit -m "feat(discovery): add journey-led baseline"
  ```

### Task 2: 产品 Feature 与交付 Feature 路由边界

**Files:**
- Modify: `tests/routing-contract.sh`
- Modify: `src/skills/using-dev-cadence/SKILL.md`

**Interfaces:**
- Consumes: Task 1 的 Discovery 所有权和现有 Feature Dev 行为路由。
- Produces: 入口层明确区分产品 Feature 定义与系统行为实施的意图路由。

- [ ] **Step 1: 写路由 RED 契约**

  在 `tests/routing-contract.sh` 增加：

  ```bash
  assert_match "Journey baseline route" 'User Journey.*Feature.*Select `discovery`|Select `discovery`.*User Journey.*Feature'
  assert_match "product Feature ownership" 'product.*Feature.*Discovery|Discovery.*product.*Feature'
  assert_match "implementation Feature boundary" 'implement.*Feature.*feature-dev|feature-dev.*implement.*Feature'
  assert_match "routing uses intent" 'Feature.*intent|intent.*Feature'
  ```

- [ ] **Step 2: 运行 routing test 并记录 RED**

  Run: `bash tests/routing-contract.sh`

  Expected: FAIL，缺少 Journey/产品 Feature 路由；现有路由断言继续执行且无 Bash 错误。

- [ ] **Step 3: 最小修改入口选择器**

  在 Available Flows、Representative Routing Examples 和 Flow Priority 中明确：

  ```text
  Creating or maintaining a product-level User Journey and its Feature Definitions selects discovery.
  Implementing a Feature or intentionally changing system-visible behavior selects feature-dev.
  Route by the requested outcome, not by the isolated word "Feature".
  ```

  保留现有两阶段路由、Asset/Delivery 记录模型和混合意图澄清规则。

- [ ] **Step 4: 运行 focused GREEN**

  Run: `bash tests/routing-contract.sh`

  Expected: `Routing contract checks passed.`

  Run: `bash tests/discovery-contract.sh`

  Expected: `Discovery contract checks passed.`

- [ ] **Step 5: 自审并提交 Task 2**

  Stage only `tests/routing-contract.sh` and `src/skills/using-dev-cadence/SKILL.md`，执行 staged-tree review gate 后提交：

  ```bash
  git commit -m "feat(flow): route product journey definitions"
  ```

### Task 3: 公开说明、分发契约与版本

**Files:**
- Modify: `README.md`
- Modify: `README.zh-CN.md`
- Modify: `tests/package-contract.sh`
- Modify: `version`
- Generate: `dist/.dev-cadence/**`

**Interfaces:**
- Consumes: Tasks 1-2 的三资产行为和入口边界。
- Produces: 用户可见双语说明、安装包 source/dist parity 和 `0.18.0` 包身份。

- [ ] **Step 1: 为双语 README 分发一致性写 RED 契约**

  在 `tests/package-contract.sh` 的 `required_files` 增加：

  ```bash
  "dist/.dev-cadence/README.md"
  "dist/.dev-cadence/README.zh-CN.md"
  ```

  并增加：

  ```bash
  assert_same_file "README.md" "dist/.dev-cadence/README.md"
  assert_same_file "README.zh-CN.md" "dist/.dev-cadence/README.zh-CN.md"
  ```

- [ ] **Step 2: 运行 package test 并记录 RED**

  Run: `bash tests/package-contract.sh`

  Expected: FAIL，现有 dist README 与待修改 source 尚未一致；如果当前仍一致，则先完成 Step 3 的 source README 修改后重跑以获得 parity RED，再执行构建。

- [ ] **Step 3: 同步双语 README 与版本**

  README 必须列出三路径和新阶段：

  ```text
  docs/product-design/user-journey.md
  docs/product-design/prd.md
  docs/product-design/business-architecture.md

  Background And Problem Exploration -> User Journey Analysis -> User Journey Confirmation -> PRD And Business Architecture Derivation -> Product Design Confirmation
  ```

  英文和中文说明都必须明确：两道确认门；Discovery 创建/维护 Journey 中的 Feature Definitions；Work Item Planning 只引用已确认 Feature；完整基线要求三资产一致。

  将 `version` 精确修改为：

  ```text
  0.18.0
  ```

- [ ] **Step 4: 构建并运行 focused GREEN**

  Run: `bash scripts/build.sh`

  Expected: exit 0，生成 `dist/.dev-cadence/version`、双语 README 和全部 source skills。

  Run: `bash tests/package-contract.sh`

  Expected: `Package contract checks passed.`

  Run: `bash tests/discovery-contract.sh && bash tests/routing-contract.sh`

  Expected: 两项 focused contract 均通过。

- [ ] **Step 5: 自审并提交 Task 3**

  确认 `git status --short` 不包含被忽略的 `dist/`，stage only 双语 README、package contract 和 version，执行 staged-tree review gate 后提交：

  ```bash
  git commit -m "docs(discovery): publish journey-led workflow"
  ```

### Task 4: 治理状态与开发阶段回归

**Files:**
- Modify: `docs/stories/S-014-user-journey-analysis.md`
- Modify: `docs/stories/S-015-work-item-planning-workflow-contract.md`
- Modify: `docs/backlog.md`
- Update ignored records: `build/dev-cadence/feature-dev/s-014-user-journey-baseline/04-implementation-record.md`
- Update ignored records: `build/dev-cadence/feature-dev/s-014-user-journey-baseline/04-code-review-report.md`

**Interfaces:**
- Consumes: Tasks 1-3 的已审查实现和完整 dependency table。
- Produces: S-014 `Done`、S-015 `Ready`、重新计算的并行实施表和可进入 System Testing 的实现证据。

- [ ] **Step 1: 更新 Story 与 Backlog 状态**

  在 S-014 中把 Status 改为 `Done`、Version 从 `2` 升到 `3`，追加 `2026-07-16` Change Log 行，说明三资产两门契约已实现并验证。

  在 S-015 中把 Status 从 `Blocked` 改为 `Ready`、Version 从 `5` 升到 `6`，追加 Change Log 行，说明 S-014 已完成且全部依赖满足。

  在 `docs/backlog.md` 中：

  - 从“待处理”移除 S-014，加入“已完成”；
  - 从并行实施表移除序号 1 的 S-014；
  - 重新编号后使 S-015 成为新的序号 1，状态为 `✅ Ready`；
  - 保留所有其他依赖和 `Draft` 状态，只根据 Dependency Table 重新计算直接后继项。

- [ ] **Step 2: 检查治理状态一致性**

  Run:

  ```bash
  rg -n 'Status：`Done`|Version：`3`' docs/stories/S-014-user-journey-analysis.md
  rg -n 'Status：`Ready`|Version：`6`' docs/stories/S-015-work-item-planning-workflow-contract.md
  rg -n 'S-014|S-015|当前可并行实施表' docs/backlog.md
  ```

  Expected: S-014 只在完成区和 Dependency Table 出现，不在并行表；S-015 在待处理区和并行表首行显示 Ready。

- [ ] **Step 3: 运行 source/dist 与陈旧规则扫描**

  Run:

  ```bash
  rg --no-ignore -n 'docs/product-design/user-journey.md|User Journey Confirmation|Feature Definitions|J-nnn|F-nnn' src/ dist/.dev-cadence/
  rg -n 'two durable product-design documents|两份.*产品设计|Goal And Value Definition -> Scope And Business Architecture Analysis|one consolidated user confirmation covering both' README.md README.zh-CN.md src/skills/discovery/SKILL.md
  ```

  Expected: 第一项在 source/dist 同步出现；第二项 no matches。

- [ ] **Step 4: 运行开发阶段全量验证**

  Run: `bash scripts/check-whitespace.sh`

  Expected: exit 0。

  Run: `bash scripts/check-all.sh`

  Expected: package、asset/delivery、architecture、discovery、document conventions、registry、routing、symmetry、description、install、whitespace 全部通过。

- [ ] **Step 5: 完成 whole-implementation review**

  对实施基线到最新 implementation commit 的完整 diff 评审 rules compliance、correctness、test/acceptance alignment，以及规则冲突、可移植路径和版本同步。Critical/Important finding 必须修复或由用户明确接受风险；重复运行受影响 focused tests 和全量检查。

- [ ] **Step 6: 自审并提交 Task 4**

  Stage only S-014、S-015 和 Backlog 三个 tracked 文档，执行 staged-tree review gate 后提交：

  ```bash
  git commit -m "docs(backlog): complete journey baseline"
  ```

  然后更新 `04-implementation-record.md` 和 `04-code-review-report.md`，记录最终 implementation SHA、已完成任务、测试证据、findings 与剩余风险；这些忽略记录不混入实施提交。

## Development Implementation 完成条件

- Tasks 1-4 的复选框全部完成，且每个实施提交通过 staged-tree review gate 并记录 exact identity。
- S-014 的 12 项验收标准均有实现与开发阶段验证映射。
- Discovery、routing、package focused contracts 和 fresh `bash scripts/check-all.sh` 全部通过。
- `src/` 与 `dist/.dev-cadence/` 同步包含三资产、五阶段、两道门、Journey/Feature 身份和增量协调规则。
- Code Review 没有未解决的 validated Critical/Important finding。
- S-014 为 `Done`，S-015 为 `Ready`，并行实施表已重算。
- 仅当上述条件成立时进入 System Testing；Business Acceptance 仍由用户固定选项决定。

## Pre-Implementation Design Freshness

- Decision: 🟢 `ready`
- Inputs: S-014 Version `2`、[需求确认](01-requirements.md)、[技术方案](02-technical-solution.md)、`docs/workflows/discovery.md`、当前 source/tests/README/package/version。
- Code Identity: branch `codex/s-014-user-journey-baseline`, commit `a6f6951f3d8a484661bf3aa769670517b4940a44`。
- Dependency State: S-001、S-002、S-005、S-006、S-013 已完成；S-014 是当前并行表唯一 Ready 首项。
- Material Changes Since Confirmation: None。当前分支包含最新卡片与流程设计，且基线 `bash scripts/check-all.sh` 全部通过。
- Conclusion: 需求、技术方案、任务拆分、文件边界和验证步骤与当前交付上下文一致，可以进入 Development Implementation，无需重新确认未变化内容。
