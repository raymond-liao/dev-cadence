# S-040 Open Question Registry 契约实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 Open Question Registry 更新为全量、稳定编号、终态保留的统一索引，并为所有 workflow 建立原子同步和有意义链接文本契约。

**Architecture:** Registry 结构与生命周期只由 `open-question-registry` 所有，通用链接文本只由 `document-conventions` 所有，`using-dev-cadence` 只负责 workflow 原子协作。仅对 Discovery 中已存在的旧终态删除规则做定点清理，不向其他 workflow 复制完整 Registry 契约。

**Tech Stack:** Markdown workflow skills，Bash 契约测试，`rg`，Git，`scripts/build.sh`。

## Global Constraints

- 不修改或迁移 `docs/open-questions.md` 及其当前 `OQ-001` 数据。
- 不为存量局部问题批量分配 `Q-nnn`，不批量清理历史链接。
- 不把简单 assumption、risk 或 review finding 自动升级为 Open Question。
- 长期 `docs/` 资产不得把 `build/` 记录作为权威链接目标。
- 不直接编辑 `dist/.dev-cadence/**` 或 `src/vendor/superpowers/**`。
- 根 `AGENTS.md` 协作偏好不进入 `src/AGENTS-snippet.md`。
- 先取得聚焦契约测试 RED，再实施最小 GREEN；不为根 `AGENTS.md` 的自然语言措辞单独添加测试。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Registry 与入口原子契约 | 实施全量索引、`Q-nnn`、五状态、终态保留和 workflow 原子同步 | `src/skills/open-question-registry/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md`, `tests/open-question-registry-contract.sh`, `tests/asset-delivery-record-contract.sh` | 两个聚焦契约测试 |
| Task 2: 文档链接文本契约 | 实施 ID-only 字段例外、`ID + 标题` 和无 ID 资产标题规则 | `src/skills/document-conventions/SKILL.md`, `tests/document-conventions-contract.sh` | Document Conventions 契约测试 |
| Task 3: Discovery 冲突清理 | 将局部问题改为全量索引，终态改为 Registry 保留 | `src/skills/discovery/SKILL.md`, `tests/discovery-contract.sh` | Discovery 契约测试 |
| Task 4: 仓库协作、版本与整体验证 | 记录子代理边界，升级至 `0.20.0`，构建并验证分发包 | `AGENTS.md`, `version`, generated `dist/.dev-cadence/**` | build、whitespace、check-all、source/dist `rg` |

## Detailed Tasks

### Task 1: Registry 与入口原子契约

**Files:**
- Modify: `tests/open-question-registry-contract.sh`
- Modify: `tests/asset-delivery-record-contract.sh`
- Modify: `tests/skill-description-contract.sh` during `S040-F-001` test-bug remediation
- Modify: `src/skills/open-question-registry/SKILL.md`
- Modify: `src/skills/using-dev-cadence/SKILL.md`

**Interfaces:**
- Consumes: [S-040 需求确认](01-requirements.md) 中的 Registry 结构、生命周期和原子同步契约。
- Produces: 所有 workflow 共享的 Registry 唯一权威规则，以及资产和交付记录的同步边界。

- [x] **Step 1: 用新契约替换 Registry 测试中的旧正向断言**

  在 `tests/open-question-registry-contract.sh` 增加 `assert_not_match`，并用以下断言覆盖四字段表、稳定编号、排序、锚点、详情、终态保留和无 Registry Change Log：

  ```bash
  assert_literal "questions table" '| ID | Status | Question | Authoritative Source |' "$REGISTRY_SKILL"
  assert_literal "global question id" 'Q-nnn' "$REGISTRY_SKILL"
  assert_literal "id link example" '[Q-001](#q-001)' "$REGISTRY_SKILL"
  assert_literal "detail anchor example" '### Q-001' "$REGISTRY_SKILL"
  for status in Open Resolved Rejected Invalid Superseded; do
    assert_literal "question status $status" "$status" "$REGISTRY_SKILL"
  done
  assert_match "open first ordering" 'Open.*first.*ID|Open.*before.*non-Open' "$REGISTRY_SKILL"
  assert_match "terminal retention" 'terminal.*remain|retain.*terminal|do not.*remove.*terminal' "$REGISTRY_SKILL"
  assert_match "registry has no change log" 'Registry.*must not.*Change Log|Do not.*Change Log.*Registry' "$REGISTRY_SKILL"
  assert_not_match "terminal removal rule" 'remove.*current.*index|current.*index.*remove' "$REGISTRY_SKILL"
  ```

  在 `tests/asset-delivery-record-contract.sh` 增加入口原子同步和 `build/` 生命周期断言：

  ```bash
  assert_match "atomic registry synchronization" 'create.*modify.*migrate.*status.*same operation.*Registry|Registry.*same operation.*create.*modify.*migrate.*status' "$ENTRY_SKILL"
  assert_match "unsynchronized workflow gate" 'must not.*advance.*confirmation gate|confirmation gate.*must not.*advance' "$ENTRY_SKILL"
  assert_match "delivery temporary ownership" 'build/.*Registry.*temporarily.*full body|Registry.*temporarily.*full body.*build/' "$ENTRY_SKILL"
  assert_match "delivery records are not registry authority" 'Registry.*must not.*build/.*authoritative|build/.*must not.*authoritative.*Registry' "$ENTRY_SKILL"
  ```

- [x] **Step 2: 运行聚焦测试并确认 RED**

  Run:

  ```bash
  bash tests/open-question-registry-contract.sh
  bash tests/asset-delivery-record-contract.sh
  ```

  Expected: FAIL，首个失败指向新四字段表或原子同步规则缺失；不得因 Shell 语法错误失败。

- [x] **Step 3: 重写 Registry 核心契约**

  在 `src/skills/open-question-registry/SKILL.md` 保留 Applicability、Registry Discovery 和按需创建边界，把旧八字段模板、终态删除和 Change Log 替换为以下核心结构：

  ```markdown
  ## Questions

  | ID | Status | Question | Authoritative Source |
  | --- | --- | --- | --- |
  | [Q-001](#q-001) | Open | Which durable asset should own this question? | Registry temporary body |

  ## Question Details

  ### Q-001
  ```

  明确写入：`Q-nnn` 全局扫描、从 `Q-001` 递增、不复用；Open-first 与两组 ID 升序；详情全量 ID 升序；有权威资产时只保留标题与链接，无权威资产时 Registry 临时持有完整正文；终态先写结论后改状态并保留条目；Registry 不包含 Change Log。

- [x] **Step 4: 在入口建立 workflow 原子同步**

  在 `src/skills/using-dev-cadence/SKILL.md` 更新 Registry 责任描述，并在 `Shared Asset Capabilities` 写入以下语义：

  ```markdown
  - When any active workflow creates, modifies, migrates, or changes the status of an Open Question in a confirmed asset update, it must update the authoritative asset and Registry in the same operation. It must not advance the current confirmation gate with only one side updated.
  - A Delivery Workflow record under `build/` must not become the Registry's long-lived authoritative source. When no durable authority exists, the Registry temporarily owns the full body and the delivery record keeps the same `Q-nnn` plus a Registry link.
  - Do not promote an assumption, risk, or review finding to an Open Question unless the workflow explicitly identifies it as a question that must be tracked.
  ```

- [x] **Step 5: 运行聚焦测试并确认 GREEN**

  Run:

  ```bash
  bash tests/open-question-registry-contract.sh
  bash tests/asset-delivery-record-contract.sh
  ```

  Expected: 两个脚本均输出 `contract checks passed.` 并以 `0` 退出。

- [x] **Step 6: 审查并提交 Task 1**

  审查旧契约是否被完整替换，且 `docs/open-questions.md` 未被修改。提交：

  ```bash
  git add tests/open-question-registry-contract.sh tests/asset-delivery-record-contract.sh src/skills/open-question-registry/SKILL.md src/skills/using-dev-cadence/SKILL.md
  git commit -m "feat(flow): 建立全量问题索引契约"
  ```

  Execution note: implementation commit `fdc9d89`; review remediation commit `02d87c8`. Failure `S040-F-001` was classified as `test_bug` because `tests/skill-description-contract.sh` retained the obsolete exact description, then closed in remediation round 1 after the strict expected value was updated and all checks passed.

### Task 2: 文档链接文本契约

**Files:**
- Modify: `tests/document-conventions-contract.sh`
- Modify: `src/skills/document-conventions/SKILL.md`

**Interfaces:**
- Consumes: Task 1 中 Registry 的 ID 字段、Authoritative Source 和 Question Details 链接。
- Produces: 所有 Dev Cadence 文档共享的链接文本选择规则。

- [x] **Step 1: 增加链接文本 RED 契约**

  在 `tests/document-conventions-contract.sh` 的 Document References 断言后增加：

  ```bash
  assert_match "id-only explicit field exception" 'explicit ID field.*ID-only|ID-only.*explicit ID field' "$CONVENTIONS_SKILL"
  assert_match "stable id and title link text" 'stable ID.*title.*link text|link text.*ID.*title' "$CONVENTIONS_SKILL"
  assert_match "asset without id uses title" 'without.*stable ID.*title|no.*stable ID.*meaningful title' "$CONVENTIONS_SKILL"
  assert_match "id-only forbidden outside id field" 'outside.*ID field.*must not.*ID-only|ID-only.*must not.*outside.*ID field' "$CONVENTIONS_SKILL"
  ```

- [x] **Step 2: 运行测试并确认 RED**

  Run: `bash tests/document-conventions-contract.sh`

  Expected: FAIL with `missing id-only explicit field exception` or another new link-text assertion.

- [x] **Step 3: 实施三分链接文本规则**

  在 `src/skills/document-conventions/SKILL.md` 的 `For a navigational reference` 列表中加入：

  ```markdown
  - an explicit ID field may use ID-only link text when the field itself supplies the navigation context;
  - outside an explicit ID field, when the target has both a stable ID and title, the link text must include `ID + title`; ID-only link text is not allowed there;
  - when the target has no stable ID, use a meaningful title that describes the target's content or responsibility.
  ```

- [x] **Step 4: 运行测试并确认 GREEN**

  Run: `bash tests/document-conventions-contract.sh`

  Expected: `Document conventions contract checks passed.`

- [x] **Step 5: 审查并提交 Task 2**

  ```bash
  git add tests/document-conventions-contract.sh src/skills/document-conventions/SKILL.md
  git commit -m "feat(docs): 规范资产链接文本"
  ```

  Execution note: implementation commit `d0e22d9`; task review approved with no Critical, Important, or Minor findings.

### Task 3: Discovery 冲突清理

**Files:**
- Modify: `tests/discovery-contract.sh`
- Modify: `src/skills/discovery/SKILL.md`

**Interfaces:**
- Consumes: Task 1 的终态保留和 workflow 原子同步契约。
- Produces: 与 Registry 新契约一致的 Discovery 支持资产维护行为。

- [x] **Step 1: 将 Discovery 协作断言改为 RED**

  在 `tests/discovery-contract.sh` 保留 `resolved local questions removed`，把旧 `registry coordination` 断言替换为：

  ```bash
  assert_match "all local questions indexed" 'all.*Open Questions.*Registry|Registry.*every.*Open Question' "$DISCOVERY_SKILL"
  assert_match "terminal registry entry retained" 'Registry.*terminal.*retain|retain.*Registry.*resolved' "$DISCOVERY_SKILL"
  assert_match "registry status updated atomically" 'Registry.*status.*atomic|atomic.*Registry.*status' "$DISCOVERY_SKILL"
  assert_not_match "legacy registry removal and change log" 'removal and Registry `Change Log`|remove.*Registry.*Change Log' "$DISCOVERY_SKILL"
  ```

- [x] **Step 2: 运行测试并确认 RED**

  Run: `bash tests/discovery-contract.sh`

  Expected: FAIL because Discovery still says the Registry may index questions only when useful or removes terminal entries.

- [x] **Step 3: 定点替换 Discovery 旧语义**

  在 `src/skills/discovery/SKILL.md` 做两处最小修改：

  ```markdown
  User Journey, PRD, and Business Architecture retain their own in-scope `Open Questions`. Every such question must also be indexed in the repository-level Registry with the same stable `Q-nnn`; the Registry does not replace or empty the local sections.
  ```

  以及：

  ```markdown
  When a repository-level Registry entry represents the same resolved question, include the authoritative conclusion and the atomic Registry status update in the supporting asset maintenance proposal. Remove the question from the local `Open Questions` section after its conclusion is placed in the owning body, but retain its Registry entry in the applicable terminal status. Do not add a Registry Change Log.
  ```

- [x] **Step 4: 运行测试并确认 GREEN**

  Run: `bash tests/discovery-contract.sh`

  Expected: `Discovery contract checks passed.`

- [x] **Step 5: 审查并提交 Task 3**

  ```bash
  git add tests/discovery-contract.sh src/skills/discovery/SKILL.md
  git commit -m "fix(discovery): 保留终态问题索引"
  ```

  Execution note: implementation commit `166fefe`; review remediation commit `7fdf512`; task review approved with no Critical, Important, or Minor findings.

### Task 4: 仓库协作、版本与整体验证

**Files:**
- Modify: `AGENTS.md`
- Modify: `version`
- Generate: `dist/.dev-cadence/**` through `bash scripts/build.sh`

**Interfaces:**
- Consumes: Tasks 1-3 的已验证 source skill 和用户本轮确认的子代理协作偏好。
- Produces: 本仓库子代理协作规则、可安装 `0.20.0` 分发包和完整开发阶段验证证据。

- [x] **Step 1: 增加根 AGENTS 子代理协作边界**

  在“讨论与规则设计边界”和“构建与验证”之间加入：

  ```markdown
  ## 子代理协作边界

  - 实施 `docs/backlog.md` 中的工作项时，在平台支持且任务边界可独立委派的情况下，优先由子代理执行已确认范围内的实现。
  - 主代理保留 Dev Cadence 路由和门禁、用户确认、集成审查、最终验证、Git 集成和最终汇报责任；子代理可按已确认实施方法创建任务级进度提交，但不独立执行合并、push、业务验收或分支清理。
  - 不因使用子代理自动创建用户可见的新任务；只有用户明确要求时才创建。
  ```

- [x] **Step 2: 更新安装包版本**

  将 `version` 的唯一内容从 `0.19.0` 改为：

  ```text
  0.20.0
  ```

- [x] **Step 3: 构建分发包并运行开发阶段验证**

  Run:

  ```bash
  bash scripts/build.sh
  bash scripts/check-whitespace.sh
  bash scripts/check-all.sh
  ```

  Expected: 所有契约检查通过，安装检查报告 `Installed Dev Cadence 0.20.0`。

- [x] **Step 4: 验证 source/dist 关键规则同步和非范围**

  Run:

  ```bash
  rg --no-ignore -n 'Q-nnn|Question Details|terminal.*retain|retain.*terminal' src/skills/open-question-registry/SKILL.md dist/.dev-cadence/skills/open-question-registry/SKILL.md
  rg --no-ignore -n 'explicit ID field|ID \+ title' src/skills/document-conventions/SKILL.md dist/.dev-cadence/skills/document-conventions/SKILL.md
  git diff -- docs/open-questions.md src/AGENTS-snippet.md src/vendor/superpowers
  ```

  Expected: 前两个命令在 source 和 dist 均命中关键规则；最后一个命令无输出。

- [x] **Step 5: 审查并提交 Task 4**

  确认 `dist/` 仍由 `.gitignore` 忽略，不强制添加。提交：

  ```bash
  git add AGENTS.md version
  git commit -m "chore(release): 升级开放问题契约版本"
  ```

  Execution note: implementation commit `f659df5`; task review approved with no Critical, Important, or Minor findings. The implementer encountered an external 502 only after the commit and complete report were written; commit scope and verification evidence were independently confirmed.

## Development Implementation Completion Conditions

- 四个 Task 的所有 checklist 均完成，每个可执行规则任务均有 RED 和 GREEN 证据。
- 每个 Task 的实施提交都通过 subagent-driven development 的 spec compliance 和 code quality 审查。
- `docs/open-questions.md`、`src/AGENTS-snippet.md` 和 `src/vendor/superpowers/**` 保持未修改。
- `bash scripts/check-all.sh` 在实施后通过，source/dist 关键规则同步。
- `04-implementation-record.md` 和 `04-code-review-report.md` 完整记录实施提交、测试、审查结论与剩余风险。
