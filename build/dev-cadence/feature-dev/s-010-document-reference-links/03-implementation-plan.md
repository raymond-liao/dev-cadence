# S-010 文档引用快捷链接 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 Dev Cadence 管理的文档建立集中、选择性且可验证的 Markdown 引用规则，并让四个已实现 workflow 对称接入。

**Architecture:** `document-conventions` 是完整链接契约的唯一所有者；feature-dev、bug-fix、refactor、discovery 只声明应用面和验证时机。Shell 契约测试验证语义与对称性，构建脚本负责同步分发包。

**Tech Stack:** Markdown workflow skills、Bash contract tests、`rg`、Git、现有 build/check 脚本。

## Global Constraints

- 不改变 workflow 阶段、状态机或 S-009 状态映射。
- 不直接编辑 `dist/.dev-cadence/**` 或 `src/vendor/superpowers/**`。
- 不新增通用 Markdown parser，不批量重写无关历史文档。
- 规则完整契约只存在于 `src/skills/document-conventions/SKILL.md`。
- Story 和 Backlog 在 Business Acceptance 前保持未完成状态。
- 根 `version` 从 `0.11.0` 更新为 `0.12.0`。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: 锁定链接契约 | 用失败契约测试定义共享所有权、选择条件、身份、生命周期和 workflow 对称接入 | `tests/document-conventions-contract.sh` | focused test 先失败后通过 |
| Task 2: 实现共享规则与 workflow 接入 | 添加最小链接规则，并对称接入四个 workflow | `src/skills/document-conventions/SKILL.md`、四个 workflow skill | focused contract、workflow symmetry |
| Task 3: 版本、构建与交付验证 | 更新版本、同步 dist、执行完整检查和链接验证 | `version`、生成的 `dist/.dev-cadence/**` | whitespace、check-all、src/dist `rg`、run 链接检查 |

## Detailed Tasks

### Task 1: 锁定链接契约

**Files:**
- Modify: `tests/document-conventions-contract.sh`
- Test: `tests/document-conventions-contract.sh`

**Interfaces:**
- Consumes: Story 验收标准和现有 `assert_literal` / `assert_match` helper。
- Produces: 共享规则与四 workflow 必须满足的可执行契约。

- [ ] **Step 1: 添加共享规则失败断言**

  断言三项选择条件、有意义文本、来源相对路径、稳定锚点、链接与精确路径并存、pending 目标、`docs/`/`build/` 生命周期、移动重命名、tracked/run 检查、禁止 URI 和机器路径例外。

- [ ] **Step 2: 添加 workflow 对称接入失败断言**

  对 discovery、feature-dev、bug-fix、refactor 循环断言共享 document-reference 契约和 tracked/run 链接检查时机，并断言入口不复制完整契约。

- [ ] **Step 3: 运行 RED**

  Run: `bash tests/document-conventions-contract.sh`

  Expected: FAIL，首个缺失项指向 `src/skills/document-conventions/SKILL.md` 的文档引用规则。

### Task 2: 实现共享规则与 workflow 接入

**Files:**
- Modify: `src/skills/document-conventions/SKILL.md`
- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`
- Modify: `src/skills/discovery/SKILL.md`
- Test: `tests/document-conventions-contract.sh`
- Test: `tests/workflow-symmetry.sh`

**Interfaces:**
- Consumes: Task 1 契约。
- Produces: 单一共享链接规范，以及四 workflow 的对称应用门禁。

- [ ] **Step 1: 添加最小共享 `Document References` 章节**

  写入选择条件、格式、身份、生命周期、pending、验证和禁止范围；保留明确的 `must` / `do not` / `when` / `before` 表述。

- [ ] **Step 2: 对称接入四个 workflow**

  每个 workflow 添加相同职责的短规则，只引用共享规范，不复制完整契约。

- [ ] **Step 3: 运行 GREEN 和对称性回归**

  Run: `bash tests/document-conventions-contract.sh`

  Expected: `Document conventions contract checks passed.`

  Run: `bash tests/workflow-symmetry.sh`

  Expected: `Workflow symmetry checks passed.`

- [ ] **Step 4: 审查并提交实现任务**

  暂存 Task 1-2 文件，记录 staged tree 身份，审查完整 staged diff，执行 focused checks，按 executing-plans ledger 验证精确 commit 身份。

### Task 3: 版本、构建与交付验证

**Files:**
- Modify: `version`
- Generate: `dist/.dev-cadence/**` via `bash scripts/build.sh`
- Test: `tests/package-contract.sh`
- Test: `tests/install-contract.sh`
- Test: `tests/run-all.sh`

**Interfaces:**
- Consumes: Task 2 的规则源和测试。
- Produces: `0.12.0` 可安装包与完整验证证据。

- [ ] **Step 1: 更新版本并添加契约保护**

  将 `version` 更新为 `0.12.0`；现有 package/install contract 继续验证版本进入分发包和安装结果。

- [ ] **Step 2: 构建并核对源/分发同步**

  Run: `bash scripts/build.sh`

  Expected: exit 0，`dist/.dev-cadence/version` 为 `0.12.0`。

  Run: `rg --no-ignore -n 'Document References|tracked Markdown|current run' src/skills dist/.dev-cadence/skills`

  Expected: 共享规则与四 workflow 关键接入同时出现在 `src/` 和 `dist/`。

- [ ] **Step 3: 执行完整检查**

  Run: `bash scripts/check-whitespace.sh`

  Expected: exit 0。

  Run: `bash scripts/check-all.sh`

  Expected: 所有构建和契约检查通过。

- [ ] **Step 4: 检查当前 run 文档链接与禁止路径**

  对 `build/dev-cadence/feature-dev/s-010-document-reference-links/*.md` 中的仓库内相对链接解析目标存在性，并扫描 `/Users/`、`file://`、`vscode://`。

  Expected: 所有本地目标存在，禁止路径扫描无匹配。

- [ ] **Step 5: 审查并提交版本任务**

  暂存 `version`，记录 staged tree 身份，审查 diff，执行完整检查，并按 executing-plans ledger 验证精确 commit 身份。

## Self-Review

- Spec coverage：15 条验收标准分别由共享规则、四 workflow 接入、契约测试和构建/运行记录验证覆盖。
- Placeholder scan：无 `TBD`、`TODO`、`implement later` 或未定义实现步骤。
- Type consistency：本任务不引入代码类型或 API；所有路径与测试命令和仓库现状一致。

## Pre-Implementation Design Freshness Gate

- Work item identity：`docs/stories/S-010-document-reference-links.md`，Version `3`。
- Requirements：`build/dev-cadence/feature-dev/s-010-document-reference-links/01-requirements.md`。
- Technical Solution：`build/dev-cadence/feature-dev/s-010-document-reference-links/02-technical-solution.md`。
- Branch：`codex/s-010-document-reference-links`。
- Current commit before implementation：`ae23f0b8ec2c74c493e0b5f81634bcea07b7f0c7`。
- Dependency state：S-009 已在 Backlog 标记完成；共享 `document-conventions` 已包含其状态呈现规则。
- Material repository changes since confirmation：仅 S-010 requirements/manifest checkpoint；未发现改变工作项 Version 3、验收标准、架构边界或文件职责的改动。
- Decision：🟢 `ready`，需求、方案和计划仍匹配当前代码状态，可进入 Development Implementation。

## 实施计划结论

- Status：✅ `confirmed`
- Confirmation：用户于 2026-07-14 授权需求确认后连续完成后续阶段，无需中途再次确认；本计划按该委托确认执行。
