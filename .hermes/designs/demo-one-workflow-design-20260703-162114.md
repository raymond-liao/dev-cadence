# Dev Cadence 单 Workflow Demo 验证方案

生成时间：2026-07-03 16:21:14

## 1. 目标

设计一个最小但完整的 demo，用于验证 Dev Cadence 是否能把一个小型软件交付任务从 Human 意图一路推进到可验收结果，并留下可审计证据。

本 demo **只跑一个被测业务 workflow：`feature-dev`**。它不用于实现或修改 Dev Cadence runtime；但为了准备 demo 环境，可以在当前 `dev-cadence` 源码仓库中执行只读检查、打包或同步命令。

## 2. Demo 范围

### In scope

- 在一个隔离的临时 demo target repo 中执行一次 `feature-dev` workflow。
- 使用一个很小、可测试、可回滚的代码行为变更作为任务载体。
- 覆盖 Dev Cadence 的核心闭环：
  - intake / brief
  - classify
  - requirements
  - planning
  - implementation
  - test
  - review
  - acceptance
- 观察并收集 workflow artifacts、run evidence、gate 状态、Human acceptance 请求内容。

### Out of scope

- 不验证多个 workflow 的路由选择。
- 不验证 incident、bugfix、refactor、research-spike、code-review 等 workflow。
- 不做 Dev Cadence runtime、plugin、skills、templates、scripts 的实现变更。
- 不把当前 `dev-cadence` 仓库作为业务 target，不在其中生成 demo 的 `specs/records` 或 `.dev-cadence`。
- 不默认在当前 `dev-cadence` 仓库中生成 `dist/`；如需使用默认打包输出 `dist/target-repo` 或 `dist/codex`，必须作为 demo infrastructure preparation，经 Human 授权并采用干净工作区 / 可清理输出策略。
- 不做 merge、push、release、branch cleanup 等 finalization 动作。

## 3. 选择的单一 workflow

选择：`feature-dev`

参考 workflow sequence：

```text
intake -> classify -> requirements -> design? -> planning -> implementation -> test -> review -> acceptance
```

本 demo 建议跳过 `design`，因为任务是局部、小型、低风险行为变更，不涉及公共 API、架构、数据模型或跨模块行为。跳过原因需要在 `00-brief.md` 或相应 artifact 中记录。

### 为什么选择 `feature-dev`

相比 `research-spike` 或纯 `code-review`，`feature-dev` 能在最小范围内覆盖 Dev Cadence 的主要价值：

- Human 意图被转化为明确 acceptance criteria。
- 任务在实现前完成分类、边界和计划。
- 实现阶段能要求 TDD 或等价反馈信号。
- 交付前需要 scope reconciliation、test evidence、review evidence。
- 最终不能由 agent 自行接受，必须进入 Human acceptance。

因此它更适合做第一条端到端 demo。

## 4. Demo 项目 / 任务建议

### Demo target repo

建议使用隔离目录，例如：

```text
/tmp/dev-cadence-demo-target
```

或者用户指定的其他临时目录。不要把当前 `dev-cadence` runtime 仓库当作业务 target，以免把 demo 产品代码和 workflow artifacts 写入 runtime 工作区；但 demo 准备阶段可以从当前源码仓库打包 / 同步 Dev Cadence runtime 到该临时 target。

### 初始 demo app

建议使用一个最小 Node.js / Express Web demo app。它应足够真实，可以让 Human 在浏览器里体验登录、受保护页面、刷新、退出等路径；同时保持隔离、无数据库、低依赖，避免把 demo 扩大成用户系统。

```text
package.json
src/app.mjs
src/server.mjs
test/health.test.mjs
```

初始行为建议保持非常小：

```text
GET /health
=> 200 { ok: true }
```

demo app 可预置一个内存 demo 用户，例如 `demo@example.com` / `password123`。该用户仅用于本地 demo，不接数据库、不引入迁移、不做生产级认证体系。

### 单次 feature 任务

任务名称：为最小 Web demo app 增加**完整登录功能**。

Human intent 示例：

> 请为这个最小 Web demo app 增加完整登录功能：未登录访问首页或受保护页面时应看到登录页或被重定向到登录页；登录页包含 email/password 输入；使用预置 demo 用户登录成功后进入首页 / 仪表盘；错误密码或未知用户显示可理解错误；刷新后保持登录状态；可以 logout / 退出，退出后不能访问受保护页面。请用自动测试覆盖关键用户路径，并保留足够的手工体验说明。

建议 acceptance criteria（控制在 Human 可体验的 6 条左右）：

- AC-1：未登录访问首页、仪表盘或其他受保护页面时，会被要求登录，不能直接看到受保护内容。
- AC-2：使用正确 `email/password` 登录成功后，Human 进入首页 / 仪表盘，并能看到已登录用户的安全展示信息。
- AC-3：错误密码或未知用户会显示可理解错误，且不泄漏密码、账号枚举细节或敏感实现信息。
- AC-4：刷新后保持登录状态（例如 session cookie 或等价的最小本地机制），不会立即丢失会话。
- AC-5：点击 logout / 退出后回到未登录状态，再访问受保护页面会重新要求登录。
- AC-6：自动测试和手工验证说明覆盖上述关键用户路径。

明确 out of scope：

- 注册。
- 用户管理 CRUD。
- 角色权限 / authorization policy。
- 找回密码、邮件验证、多因素认证。
- 第三方登录。
- 复杂 UI / 视觉设计系统。
- 数据库接入、schema 设计、迁移或生产数据库。
- 生产级完整 auth 安全策略（限流、审计日志、密码哈希参数调优、账户锁定、设备管理等）。
- 权限系统或复杂 authorization policy。

建议 task class：`S1`。

理由：这是普通可测试 feature，虽然涉及登录语义、会话状态和安全响应边界，但 demo 明确限定为预置 demo 用户、最小会话机制、无数据库、无权限体系、无生产安全策略；会修改产品代码和测试，需要正常交付证据。若 Human 要求接入真实身份系统、生产数据库、复杂 session/token 管理或权限策略，应升级范围并重新评估 task class。

### 为什么选择这个 demo 业务场景

完整登录功能比玩具 CLI 参数或单一 endpoint 更能展示 Dev Cadence 的需求澄清、scope control、TDD、review、安全 / 风险边界与 Human acceptance：它有用户可见页面、成功路径、失败路径、会话保持、logout / 退出、测试与手工体验；但它仍明显小于“用户管理系统”，不涉及注册、CRUD、角色权限、找回密码、第三方登录、生产数据库或生产级认证体系，适合作为第一条单 workflow demo。

## 5. Human-facing Demo Walkthrough：Human 如何体验并验收登录功能

> 注意：以下是后续执行 demo 时的步骤；本方案修正阶段不执行这些写入动作，也不实际运行 demo。

本节以 Human 视角描述一次完整演示：Human 先看到一个隔离 demo 仓库被准备好，然后只观察一个被测业务 workflow：`feature-dev` 如何把“完整登录功能”从需求推进到可体验、可验收的结果。

本节把动作分为两类：

- **Step 0 / Demo setup**：准备被测环境。可以在当前 `dev-cadence` 源码仓库执行只读检查、打包和同步命令，也可以在临时 demo target 中初始化最小 Web app。这些动作是 demo 仓库准备，**不是被测业务 workflow**。
- **Step 1 起 / 被测 workflow execution**：只在 demo target 中执行一个业务 workflow：`feature-dev`，并产生该 task 的 artifacts / evidence。

### Step 0：Demo 仓库准备（setup，不算 workflow）

Step 0 的目标是让 Human 确认“舞台已经搭好”：有一个隔离 demo target repo、有一个 baseline 可运行的最小 Web app、有 Dev Cadence repo-embedded runtime 可用，并且当前 `dev-cadence` runtime 仓库没有被当作业务 target。

#### Step 0.1 创建隔离 demo target repo

1. 创建或重置临时 demo target repo，例如 `/tmp/dev-cadence-demo-target`。
2. 在 demo target 中初始化 git，并记录初始 `git status --short`。
3. 明确 demo 产品代码、测试和后续 `specs/records` 只写入 demo target；禁止在当前 `dev-cadence` 源码仓库中创建 demo app、demo task artifacts 或 target `.dev-cadence` runtime。

#### Step 0.2 初始化最小 Web app baseline

1. 初始化一个最小可运行 Express Web app 和测试基线，例如 Node.js 内置 test runner + HTTP request helper 形态：`package.json`、`src/app.mjs`、`src/server.mjs`、`test/health.test.mjs`。
2. baseline app 可以只包含健康检查和一个非常简单的页面占位；完整登录功能尚未实现。
3. 运行基线测试，例如 `node --test test/health.test.mjs` 或 demo app 的全量 test script，记录输出。
4. 启动 baseline app，确认 Human 能访问本地服务，且 baseline 行为可解释。

#### Step 0.3 准备 Dev Cadence runtime / bundle / sync

结论：demo 前通常**不需要编译型 build** Dev Cadence；但如果 demo target 还没有安装 / 同步 Dev Cadence runtime，则需要先做**打包 / 同步准备**。这里“构建 dev-cadence”的准确含义按验证路径区分：

1. **主路径：repo-embedded runtime（推荐）**
   - 在当前 `dev-cadence` 源码仓库生成 target-repo bundle：
     ```bash
     cd /Users/raymond/Desktop/AI/AIA/dev-cadence
     node scripts/package-target-repo-bundle.mjs --clean
     ```
   - 默认输出为 `dist/target-repo/`，包含 `.dev-cadence/` runtime、`AGENTS.dev-cadence-section.md` 和示例 `.dev-cadence.yaml`。
   - 将 bundle 同步到 demo target：
     ```bash
     node scripts/sync-target-repo-bundle.mjs --target /tmp/dev-cadence-demo-target
     ```
   - 如果不希望污染当前源码仓库，可改用外部输出目录，并在 sync 时显式指定：
     ```bash
     node scripts/package-target-repo-bundle.mjs --clean --output-dir /tmp/dev-cadence-target-repo-bundle
     node scripts/sync-target-repo-bundle.mjs --target /tmp/dev-cadence-demo-target --bundle-dir /tmp/dev-cadence-target-repo-bundle
     ```

2. **可选路径：Codex Plugin / marketplace 包**
   - 仅当 demo 明确要验证 plugin marketplace 启动路径时才需要：
     ```bash
     cd /Users/raymond/Desktop/AI/AIA/dev-cadence
     node scripts/package-codex-plugin.mjs --clean
     ```
   - 默认输出为 `dist/codex/`。这不是 repo-embedded runtime 主路径的前提。
   - 不要把源码仓库根目录直接作为 plugin 安装源；如走 plugin 安装，应使用打包产物或维护者本机安装脚本。

3. **源码仓库检查 / 维护者验证（可选）**
   - 如需要先确认当前源码 checkout 健康，可在源码仓库运行维护者回归检查：
     ```bash
     cd /Users/raymond/Desktop/AI/AIA/dev-cadence
     bash tests/run-all.sh
     ```
   - 这属于 demo 环境准备，不是业务 workflow 的一部分，也不替代 demo target 中的 task evidence。

4. **Human 授权与工作区策略**
   - 在当前 `dev-cadence` 仓库执行只读检查通常可作为准备动作。
   - 任何会写入 `dist/` 的打包命令，必须先确认 Human 授权和干净工作区策略：记录 `git status --short`，优先使用外部 `--output-dir`；若使用默认 `dist/`，应明确该产物不属于 demo 的业务变更，不进入 commit，demo 后按需清理。
   - 严禁在当前 `dev-cadence` 仓库中创建 demo app、demo task 的 `specs/records` 或 `.dev-cadence` target runtime。

#### Step 0.4 确认 runtime 同步和 baseline 可运行

1. 同步后确认 demo target 至少存在：
   - `AGENTS.md`
   - `.dev-cadence/manifest.json`
   - `.dev-cadence/skills/using-dev-cadence/SKILL.md`
   - `specs/records/.gitkeep`
2. 如需先审查同步影响，可先运行 dry run：
   ```bash
   node scripts/sync-target-repo-bundle.mjs --target /tmp/dev-cadence-demo-target --dry-run
   ```
3. 重新运行 baseline 测试并记录结果。
4. 到这里为止，demo target 环境已准备好；下面才开始被测的单一业务 workflow。

### Step 1：Human 提出完整登录功能需求

Human 在 demo target 中提出需求，而不是要求修改 Dev Cadence runtime：

> 请为这个最小 Web demo app 增加完整登录功能：未登录访问首页或受保护页面时应看到登录页或被重定向到登录页；登录页包含 email/password 输入；使用预置 demo 用户登录成功后进入首页 / 仪表盘；错误密码或未知用户显示可理解错误；刷新后保持登录状态；可以 logout / 退出，退出后不能访问受保护页面。请用自动测试覆盖关键用户路径，并保留足够的手工体验说明。

Dev Cadence 应创建 `00-brief.md`，记录：

- task id，例如 `demo-feature-login-001`；
- requested by；
- artifact language：中文；
- workflow hint：用户请求新增 feature；
- selected workflow：`feature-dev`；
- selection reason：新增 Human 可体验的登录功能；
- goal：交付完整登录功能，而不是只交付某个接口；
- delivery boundary；
- allowed write areas：仅 demo target 的登录功能相关源码（例如 `src/app.mjs`，必要时可新增小型 auth/session helper、页面模板或静态资源）、相关测试、对应 workflow artifact；
- forbidden actions：不修改 Dev Cadence runtime repo、不 merge、不 push、不 release、不删除分支或工作区。

Human 观察点：Supervisor 是否在实现前完成 workflow 选择和任务分类，并把主目标表述为完整登录功能。

### Step 2：Human 确认范围和验收标准

Dev Cadence 应创建 `01-requirements.md`，将 Human intent 转为 acceptance criteria：

- 未登录访问受保护页面被要求登录；
- 正确账号密码登录成功进入首页 / 仪表盘；
- 错误账号或密码显示可理解错误，且不泄漏敏感信息；
- 刷新后保持登录；
- logout / 退出后回到未登录状态；
- 自动测试和手工验证说明覆盖这些路径。

同时明确非目标：不做注册、用户管理 CRUD、角色权限、找回密码、第三方登录、复杂 UI、数据库迁移 / 生产数据库、生产级完整 auth 安全策略或权限系统。

Human 观察点：需求是否足够具体、Human 可体验，是否有非目标和边界；如范围不对，Human 应在本步骤打回，而不是等实现后再纠偏。

### Step 3：Human 授权开始实现

在 Human 确认需求和验收标准后，Dev Cadence 应创建 `03-tasks.md` 和 `04-test-plan.md`：

- 明确计划修改文件；
- 明确优先写覆盖用户路径的 failing tests（例如未登录重定向 / 登录页、成功登录、错误登录、刷新保持、logout 后保护页不可访问）；
- 明确测试命令，例如 `node --test` 或 demo app 的全量 test script；
- 明确手工体验步骤，例如启动本地服务后访问首页 / 仪表盘、提交登录表单、刷新页面、点击退出；
- 明确 review 和 acceptance 前需要做 scope reconciliation。

因为本 demo 不涉及复杂架构或生产认证设计，可记录 `02-design.md` 为 skipped 或仅保留最小设计说明，并在 brief 中说明原因。

幕后观察项：在 implementation 前记录 run evidence，例如 `runs/<run_id>/run-context.md`、`runs/<run_id>/pre-implementation-status.md`，包含 worktree path、git status before、authorized target files、authorized artifact files、implementation_authorized: true、post_hoc_backfill: false、G1/G2/G3 当前状态。

Human 观察点：计划是否能让 Worker 在受控文件范围内执行，而不是自由发挥；是否在首次产品文件写入前捕获 baseline。

### Step 4：Human 观察交付过程摘要

执行最小 Red-Green-Refactor，但 Human-facing 汇报应聚焦“登录功能如何被交付”，不要把 gate checklist 当作主线：

1. 先写覆盖关键用户路径的测试，运行后确认新增登录行为尚未实现，记录 Red evidence。
2. 实现最小登录页面、受保护首页 / 仪表盘、预置 demo 用户校验、最小会话保持机制、logout / 退出行为和可理解错误展示。
3. 运行自动测试，确认通过，记录 Green evidence。
4. 如有重构，重新运行测试；如无重构，记录 `no refactor needed` 理由。
5. 更新交付摘要，说明 Human 可以如何启动 app、使用 demo 账号登录、刷新页面、退出并验证保护页。

幕后观察项：Dev Cadence 应防止“先实现后补证据”，并要求将命令、输出、文件变更写入 run evidence。

Human 观察点：过程摘要是否能回答“我现在能体验什么登录行为”，而不只是列出内部 artifact 名称。

### Step 5：Human 查看 review / verify 结论

在声称完成前，Dev Cadence 应完成 scope reconciliation、测试报告和 review：

- 比较 `02-design.md` 或跳过记录、`03-tasks.md`、`05-implementation.md` 与实际 git status / diff / untracked files；
- 记录 planned files vs changed files、是否有 unplanned changed files、是否有 deleted files、verification plan 是否覆盖所有 affected components；
- 生成 `06-test-report.md`，记录实际执行命令和结果；
- 生成或请求 code review，记录 `07-review-report.md`，包含 findings first、severity、file references、missed tests or residual risk、decision：`approved` / `approved_with_minor_notes` / `changes_requested` / `blocked`；
- 如 review 要求修改，仍留在同一个 `feature-dev` workflow 中处理 review feedback，不切换到第二个 workflow。

可选幕后准备 / 观察项：在 demo target 中运行 repo-embedded runtime 的 gate 检查，例如 `.dev-cadence/scripts/check-gates.mjs --task-id demo-feature-login-001`，并把结果作为内部可审计证据；但 Human 的主验证不应变成阅读 gate checklist。

Human 观察点：review 是否独立于实现总结；verify 结论是否明确说明哪些用户路径已被自动 / 手工覆盖、是否存在残余风险。

### Step 6：Human 体验功能并最终接受 / 打回

Dev Cadence 的 acceptance 请求应让 Human 直接体验完整登录功能，并清楚知道如何判定通过：

1. 启动 demo app。
2. 未登录访问首页 / 仪表盘 / 受保护页面，确认被要求登录。
3. 在登录页输入预置 demo 用户的正确 email/password，确认进入首页 / 仪表盘。
4. 刷新页面，确认刷新后保持登录。
5. 点击 logout / 退出，确认回到未登录状态。
6. 再访问受保护页面，确认不能访问并重新要求登录。
7. 使用错误密码或未知用户尝试登录，确认显示可理解错误且不泄漏敏感信息。

`08-acceptance.md` 必须由 named Human 接受，不能由 agent 自行填写最终接受。Human 可以选择：

- `accepted`：功能符合验收标准；
- `changes_requested`：描述需要调整的用户路径或体验问题；
- `blocked`：说明阻塞原因，例如 app 无法启动、关键路径无法验证或安全边界不满足。

Human acceptance 请求应包含：delivered scope、changed files、tests run and result、review decision、skipped states、residual risk、体验步骤、demo 账号说明，以及是否 merge / push / release（本 demo 建议全部为 `none` 或 `not requested`）。

Human 观察点：Dev Cadence 是否把“实现完成”和“Human 接受”分开；最终接受依据是否来自可体验功能和验证证据，而不是 agent 自我声明。

## 6. 需要产生 / 观察的 artifacts 与 evidence

这些内容是幕后准备 / 观察项，用来证明 `feature-dev` workflow 有纪律地运行；它们不应取代 Human 对完整登录功能的实际体验。

### Spec artifacts

建议在 demo target 中产生：

```text
specs/records/demo-feature-login-001/00-brief.md
specs/records/demo-feature-login-001/01-requirements.md
specs/records/demo-feature-login-001/03-tasks.md
specs/records/demo-feature-login-001/04-test-plan.md
specs/records/demo-feature-login-001/05-implementation.md
specs/records/demo-feature-login-001/06-test-report.md
specs/records/demo-feature-login-001/07-review-report.md
specs/records/demo-feature-login-001/08-acceptance.md
```

`02-design.md` 可跳过或仅记录最小设计说明，但必须记录跳过 / 简化原因。

### Run evidence

建议在 demo target 中产生：

```text
specs/records/demo-feature-login-001/runs/<run_id>/run-context.md
specs/records/demo-feature-login-001/runs/<run_id>/pre-implementation-status.md
specs/records/demo-feature-login-001/runs/<run_id>/execution-report.md
specs/records/demo-feature-login-001/runs/<run_id>/test-log.md
specs/records/demo-feature-login-001/runs/<run_id>/tool-log.md
specs/records/demo-feature-login-001/runs/<run_id>/diff-summary.md
specs/records/demo-feature-login-001/runs/<run_id>/permission-decisions.md
```

### Product evidence

- 完整登录功能相关源码 diff，例如 `src/app.mjs`、auth / session helper、最小页面模板或静态资源；
- 登录功能测试 diff，例如 `test/login-flow.test.mjs`；
- 自动测试命令输出；
- 手工体验步骤和结果；
- final git status；
- review decision；
- Human acceptance decision。

## 7. 成功标准

Demo 视为成功，当且仅当：

1. Step 0 demo 仓库准备与被测 workflow execution 被明确区分；被测业务执行全程只使用一个 workflow：`feature-dev`。
2. Workflow selection、task class、selection reason 被记录，且主目标始终是 Human 可体验的完整登录功能。
3. Requirements 中 acceptance criteria 清晰、可验证，并覆盖未登录保护、正确登录、错误登录、刷新后保持登录、logout / 退出和自动 / 手工验证。
4. Implementation 前存在非 post-hoc 的 pre-implementation baseline；TDD 或等价测试证据完整：Red、Green、Refactor / no-refactor reason。
5. Scope reconciliation、test report 与 review report 有明确结论，且说明关键用户路径覆盖情况和残余风险。
6. Acceptance artifact 区分 agent handoff 与 named Human acceptance；Human 最终依据实际体验接受或打回。
7. 无 merge、push、release、删除分支、删除 worktree 等 finalization 行为。
8. 当前 `dev-cadence` runtime 仓库未被当作业务 target；除经 Human 授权的准备性检查 / 打包输出外，没有 demo 产品代码、task artifacts、`.dev-cadence` target runtime 或提交污染当前源码仓库。

## 8. 风险与边界

### 风险

- Demo 太小，可能无法覆盖复杂设计、并发 worker、incident、人为 gate override 等高级能力。
- 如果 demo target 未隔离，可能误把产品代码或 task artifacts 写入当前 runtime 仓库。
- 如果把“构建 dev-cadence”理解为实现 runtime 功能，可能扩大 demo 范围；本方案中的准备性构建仅指检查、target-repo bundle、sync 或可选 plugin package。
- 如果使用默认 `dist/` 输出而未事先确认工作区策略，可能在当前源码仓库留下可清理但容易混淆的生成产物。
- 如果直接让 agent 自行接受，会绕过 Dev Cadence 的 Human Gate 核心约束。
- 如果没有故意制造 failing test，TDD Red evidence 可能不足。

### 边界控制

- 强制使用临时 demo target repo 作为业务 target。
- Allowed write paths 只允许 demo target 的源码、测试、Dev Cadence repo-embedded runtime 同步文件和该 task 的 artifact 目录。
- 当前 `dev-cadence` 源码仓库只允许 demo 准备动作：只读检查、可选 target-repo bundle / plugin package 生成；默认优先使用外部输出目录，默认 `dist/` 输出必须经 Human 授权并可清理。
- Forbidden actions 明确禁止修改当前 runtime 源码、在当前源码仓库生成 demo task artifacts、git commit、merge、push、release。
- Acceptance 只请求 Human 决策，不自动 finalization。

## 9. 为什么这个 demo 能验证 Dev Cadence

这个 demo 虽然只做一个很小的完整登录功能 feature，但它验证的是 Dev Cadence 的交付纪律，而不是业务复杂度：

- 从模糊 Human intent 到明确 acceptance criteria，验证需求澄清与边界管理。
- 从计划到执行前 baseline，验证“先授权、再改动”的控制机制。
- 从测试失败到测试通过，验证可观察反馈信号。
- 从 diff reconciliation 到 review，验证计划与实际变更一致性。
- 从 verification 到 Human acceptance，验证 agent 不能自我验收。
- 通过隔离 demo target，验证 workflow 能在真实仓库形态中运行，同时不污染 Dev Cadence runtime 本身。

因此，`feature-dev` 的单 workflow demo 是一个覆盖面足够、风险最小、可重复执行的第一阶段验证方案。

## 10. 本方案创建时的约束执行记录

- 本文件仅为方案文档。
- 未执行 demo。
- 未执行 Dev Cadence 打包、同步或构建命令。
- 未修改当前项目 runtime/docs/scripts/skills 等已有源码文件。
- 未生成 `specs/records`、`.dev-cadence`、`dist` 或 demo target。
- 未执行 `git add`、`git commit`、merge、push、release。
- 上下文收集使用只读读取与搜索；写入动作仅修改本 Markdown 方案文件。
