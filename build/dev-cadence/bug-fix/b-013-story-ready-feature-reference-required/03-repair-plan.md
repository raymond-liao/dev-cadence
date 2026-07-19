# B-013 Repair Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

- 状态：✅ `confirmed`
- 最近确认：`2026-07-19T21:44:19+0800`，选项 1：确认计划并进入 Repair Implementation。

**Goal:** 修复 Story `Ready` 对主 System Feature 的错误强制依赖，使定义完整且不依赖产品级结论的独立 Story 可在用户确认后进入 `Ready`，同时保留已有 Feature 追踪和真实产品级结论缺口的 Discovery 路由。

**Architecture:** `src/skills/work-item-analysis/SKILL.md` 继续拥有 Story 定义与 `Ready` 门禁，但把 Feature 从通用必备字段改为已有关系的条件性追踪字段；入口选择器只重申路由边界，不承担 Story 定义。Bash 契约测试先锁定四种场景，再用现有构建和安装脚本传播规则，不直接编辑 `dist/`。

**Tech Stack:** Markdown workflow skill、Bash 契约测试、Git、`scripts/build.sh`、`scripts/install.sh`。

## Global Constraints

- 只修改 `src/skills/work-item-analysis/SKILL.md`、`src/skills/using-dev-cadence/SKILL.md`、`tests/work-item-analysis-contract.sh`、`tests/routing-contract.sh` 和 `version`；`dist/.dev-cadence/**` 必须仅由 `bash scripts/build.sh` 生成。
- 独立 Story 缺少 Feature 引用或产品设计基线不得单独路由到 Discovery；确实需要新建或改变产品级结论时仍必须返回 Discovery。
- 来自 Story Map 或已有 Feature 定义的 Story 必须保留其已确认的主 Feature 追踪关系。
- 角色、目标、价值、范围、可观察行为、验收条件、依赖、阻塞性 Open Questions 和用户确认继续构成 Story `Ready` 门禁。
- 不创建、修改或重新解释 Feature、User Journey、PRD、Business Architecture、Story Map 或 S-042；不改变 Task、Bug 或 Delivery Workflow 入口。
- 根目录版本从 `0.26.4` 递增为 `0.26.5`；B-013 卡片 Version `2` 保持不变。
- 每个实现任务完成后只提交其相关文件；不 push、不 amend、不修改历史。实现提交须遵守 Repair Implementation 的预提交审查台账。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| 1. 建立 RED 契约 | 将无 Feature 独立 Story、保留追踪、Discovery 边界和 S-042 写成会在旧规则下失败的测试 | `tests/work-item-analysis-contract.sh`、`tests/routing-contract.sh` | 两个 focused contracts 在旧规则下失败，输出定位到新门禁 |
| 2. 修正规则源 | 将 Feature 改为条件性追踪，并收窄 Discovery 路由 | `src/skills/work-item-analysis/SKILL.md`、`src/skills/using-dev-cadence/SKILL.md` | 两个 focused contracts 从 RED 变为 PASS |
| 3. 同步版本与安装包 | 递增包版本并从源重新生成和安装规则包 | `version`、生成的 `dist/.dev-cadence/**`、当前 `.dev-cadence/**` | build、package/install、source/dist/install 比较通过 |
| 4. 全量回归与范围审查 | 验证完整分发、契约和变更范围 | 实现改动与后续 Repair Implementation 记录 | whitespace、check-all、diff 和关键词同步检查通过 |

## Detailed Tasks

### Task 1: 建立 Story `Ready` Feature 边界的 RED 契约

**Files:**
- Modify: `tests/work-item-analysis-contract.sh`
- Modify: `tests/routing-contract.sh`

**Interfaces:**
- Consumes: 当前 `src/skills/work-item-analysis/SKILL.md` 与 `src/skills/using-dev-cadence/SKILL.md`。
- Produces: 四条精确文本契约，供 Task 2 的规则源满足。

- [ ] **Step 1: 在工作项分析契约中替换旧的 Feature 必备断言，并添加四个场景断言。**

  将当前 `story fields` 和 `story ready conditions` 的泛匹配替换或补充为下列精确断言：

  ```bash
  assert_literal "conditional Feature traceability" \
    'When a Story has a confirmed primary System Feature or Story Map placement, analysis must retain that traceability; an independent Story without a Feature reference may still become `Ready`.' \
    "$SKILL"
  assert_literal "story ready without Feature" \
    'Story may become `Ready` only when the role, goal, value, scope, observable behavior, acceptance conditions, direct dependencies, and development-blocking open questions are explicit and the user has confirmed the work-item definition.' \
    "$SKILL"
  assert_literal "missing Feature alone does not route Discovery" \
    'A missing Feature reference or product-design baseline alone must not return Story analysis to `discovery`.' \
    "$SKILL"
  assert_literal "Discovery requires product conclusion" \
    'Return to `discovery` only when the Story requires a new or changed product-level conclusion, including a User Journey, Feature, PRD, or Business Architecture conclusion.' \
    "$SKILL"
  ```

- [ ] **Step 2: 在入口路由契约中锁定 S-042 的历史回归和同一 Discovery 边界。**

  在 `tests/routing-contract.sh` 的 Work Item Analysis 断言附近加入：

  ```bash
  assert_literal "independent Story Feature boundary" \
    'A missing Feature reference or product-design baseline alone does not select `discovery`; return to `discovery` only when the Story needs a new or changed product-level conclusion.' \
    "$ENTRY_SKILL"
  assert_literal "S-042 historical regression boundary" \
    'S-042 remains a historical regression example of an independent Story and does not require a Feature reference to become `Ready`.' \
    "$ENTRY_SKILL"
  ```

- [ ] **Step 3: 运行 RED 检查并记录失败证据。**

  Run:

  ```bash
  bash tests/work-item-analysis-contract.sh
  bash tests/routing-contract.sh
  ```

  Expected: 两个命令均以非零状态失败，失败信息分别指向缺失的 `conditional Feature traceability` / `story ready without Feature` 与 `independent Story Feature boundary` / `S-042 historical regression boundary`；不得修改规则源来让失败消失后才记录 RED。

- [ ] **Step 4: 检查测试脚本格式并提交 RED 单元。**

  Run:

  ```bash
  git diff --check -- tests/work-item-analysis-contract.sh tests/routing-contract.sh
  ```

  Expected: 返回 0；只包含新的 B-013 契约断言。

  Commit:

  ```bash
  git add tests/work-item-analysis-contract.sh tests/routing-contract.sh
  git commit -m "test(flow): cover B-013 Story Ready boundaries"
  ```

### Task 2: 修正 Story 分析和入口的 GREEN 规则

**Files:**
- Modify: `src/skills/work-item-analysis/SKILL.md:98-116`
- Modify: `src/skills/using-dev-cadence/SKILL.md:176`

**Interfaces:**
- Consumes: Task 1 的精确文本契约与已确认 Repair Solution。
- Produces: 无 Feature 的独立 Story 可进入 `Ready`，并保留已有 Feature 追踪和产品级结论 Discovery 路由。

- [ ] **Step 1: 将 Story 字段和最小定义改为条件性 Feature 追踪。**

  在 `src/skills/work-item-analysis/SKILL.md` 以如下可验证文本替换包含 `primary System Feature` 的通用必备描述：

  ```markdown
  Story analysis must cover role, goal, value, included scope, excluded scope, observable behavior, business rules, dependencies, open questions, and acceptance conditions. When a Story has a confirmed primary System Feature or Story Map placement, analysis must retain that traceability; an independent Story without a Feature reference may still become `Ready`.
  ```

  并在最小定义列表中以条件性追踪项替换强制项：

  ```markdown
  - when present, the confirmed primary System Feature or Story Map traceability;
  ```

- [ ] **Step 2: 替换 `Ready` 门禁与 Discovery 返回规则。**

  写入以下两条精确规则，同时保留现有的 `Story must reach Ready before entering feature-dev`、禁止重解释 Feature 与其余 Story 字段：

  ```markdown
  Story may become `Ready` only when the role, goal, value, scope, observable behavior, acceptance conditions, direct dependencies, and development-blocking open questions are explicit and the user has confirmed the work-item definition.

  A missing Feature reference or product-design baseline alone must not return Story analysis to `discovery`. Return to `discovery` only when the Story requires a new or changed product-level conclusion, including a User Journey, Feature, PRD, or Business Architecture conclusion. Work Item Analysis must not define or reinterpret Feature identity.
  ```

- [ ] **Step 3: 在入口选择器添加相同的路由边界与 S-042 回归说明。**

  在 `src/skills/using-dev-cadence/SKILL.md` 的 Work Item Analysis 优先级说明后加入：

  ```markdown
  A missing Feature reference or product-design baseline alone does not select `discovery`; return to `discovery` only when the Story needs a new or changed product-level conclusion. S-042 remains a historical regression example of an independent Story and does not require a Feature reference to become `Ready`.
  ```

- [ ] **Step 4: 运行 GREEN 契约并检查旧门禁已消失。**

  Run:

  ```bash
  bash tests/work-item-analysis-contract.sh
  bash tests/routing-contract.sh
  rg --no-ignore -n 'Story may become `Ready` only when the goal, scope, primary Feature' src/skills && exit 1 || true
  git diff --check -- src/skills/work-item-analysis/SKILL.md src/skills/using-dev-cadence/SKILL.md
  ```

  Expected: 两个测试返回 0；旧 `primary Feature` Ready 门禁不存在；空白检查返回 0。

- [ ] **Step 5: 提交 GREEN 单元。**

  ```bash
  git add src/skills/work-item-analysis/SKILL.md src/skills/using-dev-cadence/SKILL.md
  git commit -m "fix(flow): allow independent Stories to become Ready"
  ```

### Task 3: 递增版本、构建并安装规则包

**Files:**
- Modify: `version`
- Generate: `dist/.dev-cadence/**` (ignored build output)
- Replace locally: `.dev-cadence/**` (current installed package, untracked)

**Interfaces:**
- Consumes: Task 2 的 source 规则和 Task 1 的 GREEN 测试。
- Produces: version `0.26.5` 的 source、dist 与当前安装包。

- [ ] **Step 1: 递增包版本而不改变 Bug 卡 Version。**

  将 `version` 的唯一内容从 `0.26.4` 改为：

  ```text
  0.26.5
  ```

  确认 `docs/bugs/B-013-story-ready-feature-reference-required.md` 继续为 Version `2`。

- [ ] **Step 2: 构建并安装到当前 task worktree。**

  Run:

  ```bash
  bash scripts/build.sh
  bash scripts/install.sh .
  ```

  Expected: `dist/.dev-cadence/` 从 source 重建；当前 `.dev-cadence/` 报告安装的版本为 `0.26.5`；不直接编辑或暂存 `dist/`。

- [ ] **Step 3: 验证 source、dist 与安装包身份和契约。**

  Run:

  ```bash
  cmp -s src/skills/work-item-analysis/SKILL.md dist/.dev-cadence/skills/work-item-analysis/SKILL.md
  cmp -s src/skills/work-item-analysis/SKILL.md .dev-cadence/skills/work-item-analysis/SKILL.md
  cmp -s src/skills/using-dev-cadence/SKILL.md dist/.dev-cadence/skills/using-dev-cadence/SKILL.md
  cmp -s src/skills/using-dev-cadence/SKILL.md .dev-cadence/skills/using-dev-cadence/SKILL.md
  cmp -s version dist/.dev-cadence/version
  cmp -s version .dev-cadence/version
  bash tests/package-contract.sh
  bash tests/install-contract.sh
  ```

  Expected: 每条比较和两个契约测试都返回 0。

- [ ] **Step 4: 提交版本单元。**

  ```bash
  git add version
  git commit -m "chore(release): bump Dev Cadence to 0.26.5"
  ```

### Task 4: 运行全量回归并准备实施证据

**Files:**
- Verify: `src/skills/work-item-analysis/SKILL.md`
- Verify: `src/skills/using-dev-cadence/SKILL.md`
- Verify: `tests/work-item-analysis-contract.sh`
- Verify: `tests/routing-contract.sh`
- Verify: `version`
- Later record: `build/dev-cadence/bug-fix/b-013-story-ready-feature-reference-required/04-repair-record.md`

**Interfaces:**
- Consumes: Tasks 1-3 的测试、规则和生成包。
- Produces: 供 Repair Implementation review 与 Regression Verification 使用的完整命令证据。

- [ ] **Step 1: 执行聚焦、格式与全量回归。**

  Run:

  ```bash
  bash tests/work-item-analysis-contract.sh
  bash tests/routing-contract.sh
  bash scripts/check-whitespace.sh
  bash scripts/check-all.sh
  ```

  Expected: 所有命令返回 0；`check-all` 重新生成分发包并运行全部契约测试。

- [ ] **Step 2: 审查同步、范围与可移植性。**

  Run:

  ```bash
  rg --no-ignore -n 'independent Story without a Feature reference|missing Feature reference or product-design baseline alone|S-042 remains a historical regression' src/skills dist/.dev-cadence/skills .dev-cadence/skills
  git diff --check main...HEAD
  git diff --name-status main...HEAD
  git status --short
  ```

  Expected: 三个规则关键词在 source、dist 和当前安装包均可定位；没有空白错误；受跟踪实现变更限于 Global Constraints 所列文件和本次运行记录；不出现 `.env`、`.dev-cadence.yaml`、临时日志、PID 或绝对本机路径。

- [ ] **Step 3: 在 Repair Implementation 阶段写入实际结果并提交验证单元。**

  创建 `04-repair-record.md`，只记录实际 RED/GREEN 输出、实施提交、构建/安装身份、通过与跳过的检查及残余风险；不得在本计划阶段预填结果。随后按实施提交审查台账审核并提交该记录与测试验证相关变更。

**Expected result:** B-013 的四个场景有 RED/GREEN 证据，source、dist 与当前安装包版本和内容同步，完整回归通过且变更范围闭合。

## Plan Self-Review

- [x] 覆盖 B-013 验收标准 1-9：Task 1-2 覆盖规则与四场景，Task 3 覆盖版本和三处同步，Task 4 覆盖全量回归和范围。
- [x] 每个任务都包含精确文件、命令、预期结果和独立提交单元；没有占位符。
- [x] 测试先于规则变更，且 Feature 追踪、独立 Story、产品级结论缺口和 S-042 的用词在测试与规则中保持一致。

## Execution Method

按 `executing-plans` 在当前隔离 worktree 内串行执行。任务彼此依赖（RED 测试 -> GREEN 规则 -> 版本/安装 -> 全量验证），不拆分为独立子代理任务。
