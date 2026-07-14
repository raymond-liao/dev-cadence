# S-008 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Subagents are not used because the active repository instructions do not authorize delegation. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增共享 `document-conventions` skill，接入 Dev Cadence 入口，并在现有 workflow 的高价值区块应用统一语义标识。

**Architecture:** `document-conventions` 是公共 Markdown 呈现规则的唯一权威来源；`using-dev-cadence` 只要求在写文档前读取它。业务 workflow 仅应用代表性标题，不复制完整映射。构建继续复制整个 `src/skills`，契约测试负责验证 source、dist、dogfood 安装包和入口接入一致。

**Tech Stack:** Bash contract tests、Markdown workflow skills、现有 build/install scripts、Git checkpoint 与 implementation review ledger。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: 共享规范与入口接入 | 以 TDD 新增共享 skill、入口读取规则、描述与打包契约，并更新版本 | `tests/document-conventions-contract.sh`, `tests/run-all.sh`, `tests/package-contract.sh`, `tests/install-contract.sh`, `tests/skill-description-contract.sh`, `src/skills/document-conventions/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md`, `version` | 聚焦契约测试、build、package/install contracts |
| Task 2: Workflow 代表性视觉应用 | 在不改变业务语义的前提下更新 Boundary、Red Flags 和歧义反馈标题 | `tests/document-conventions-contract.sh`, `tests/workflow-symmetry.sh`, `src/skills/discovery/SKILL.md`, `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, `src/skills/refactor/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md` | 新契约、workflow symmetry、关键文本差异检查 |
| Task 3: 分发、dogfood 与完整验证 | 构建分发包、更新本仓库安装包并验证全部契约 | `dist/.dev-cadence/**`, `.dev-cadence/**`, `build/dev-cadence/feature-dev/s-008-document-conventions/04-implementation-record.md`, `04-code-review-report.md` | `bash scripts/check-all.sh`, source/dist/install 同步检查 |

## Detailed Tasks

### Task 1: 共享规范与入口接入

**Files:**
- Create: `tests/document-conventions-contract.sh`
- Create: `src/skills/document-conventions/SKILL.md`
- Modify: `tests/run-all.sh`
- Modify: `tests/package-contract.sh`
- Modify: `tests/install-contract.sh`
- Modify: `tests/skill-description-contract.sh`
- Modify: `src/skills/using-dev-cadence/SKILL.md`
- Modify: `version`

- [ ] **Step 1: 写共享规范失败契约**

在 `tests/document-conventions-contract.sh` 中断言：

```bash
test -f "$ROOT_DIR/src/skills/document-conventions/SKILL.md" || fail "missing document-conventions skill"
assert_literal "auxiliary boundary" "not a business workflow" "$CONVENTIONS_SKILL"
assert_literal "no run boundary" "does not create a workflow run" "$CONVENTIONS_SKILL"
for marker in '✅' '❌' '❓' '⚠️' 'ℹ️'; do
  assert_literal "semantic marker $marker" "$marker" "$CONVENTIONS_SKILL"
done
assert_match "text accompanies emoji" 'explicit text|text.*reason|not.*only source of meaning' "$CONVENTIONS_SKILL"
assert_literal "entry convention path" '.dev-cadence/skills/document-conventions/SKILL.md' "$ENTRY_SKILL"
assert_match "entry reads convention before writing" 'before.*creat|before.*updat' "$ENTRY_SKILL"
```

将脚本加入 `tests/run-all.sh`。在 package、install 和 description 测试中增加新 skill 的存在、同步和 description 断言。

- [ ] **Step 2: 运行测试并确认 RED**

Run:

```bash
bash tests/document-conventions-contract.sh
```

Expected: FAIL，原因是 `src/skills/document-conventions/SKILL.md` 尚不存在。

- [ ] **Step 3: 实现最小共享 skill 与入口规则**

创建 `src/skills/document-conventions/SKILL.md`，至少包含：

```markdown
---
name: document-conventions
description: Use when creating or updating Dev Cadence-managed Markdown documents, records, reports, examples, or summaries.
---

# Document Conventions

This is an auxiliary document-authoring skill. It is not a business workflow and does not create a workflow run.

## Semantic Visual Markers

| Marker | Meaning |
| --- | --- |
| ✅ | Required, applicable, correct, or passed |
| ❌ | Forbidden, not applicable, incorrect, or failed |
| ❓ | Ambiguous, unresolved, or requiring clarification |
| ⚠️ | Risk, exception, warning, or conditional execution |
| ℹ️ | Necessary supplementary information |

Every marker must retain explicit text, a decision, or a reason. Emoji must never be the only source of meaning.
```

补充适用位置、禁止位置和选择性使用示例。更新 `using-dev-cadence`，要求写 Dev Cadence 管理的 Markdown 前读取该 skill，但不复制映射。

将 `version` 从 `0.9.0` 更新为 `0.10.0`。

- [ ] **Step 4: 构建并确认 GREEN**

Run:

```bash
bash scripts/build.sh
bash tests/document-conventions-contract.sh
bash tests/skill-description-contract.sh
bash tests/package-contract.sh
bash tests/install-contract.sh
```

Expected: 全部 PASS。

- [ ] **Step 5: 执行 plan-task-1 pre-commit review 并提交**

按照 Feature Dev 的 Executing-Plans Pre-Commit Review 规则：

```bash
git add tests/document-conventions-contract.sh tests/run-all.sh tests/package-contract.sh tests/install-contract.sh tests/skill-description-contract.sh src/skills/document-conventions/SKILL.md src/skills/using-dev-cadence/SKILL.md version
EXPECTED_PARENT_SHA=$(git rev-parse HEAD)
REVIEWED_TREE_SHA=$(git write-tree)
git diff --cached --check
git diff --cached --stat
git diff --cached
```

将 ledger 条目持久化为 `reviewed-pending-commit`，再次验证 parent/tree 后提交：

```bash
git commit -m "feat(docs): add shared document conventions"
```

验证 commit parent/tree 后把 ledger 条目标为 `verified`。

### Task 2: Workflow 代表性视觉应用

**Files:**
- Modify: `tests/document-conventions-contract.sh`
- Modify: `tests/workflow-symmetry.sh`
- Modify: `src/skills/using-dev-cadence/SKILL.md`
- Modify: `src/skills/discovery/SKILL.md`
- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`

- [ ] **Step 1: 扩展失败契约**

增加结构断言：

```bash
assert_literal "entry warning heading" "## ⚠️ Red Flags" "$ENTRY_SKILL"
assert_literal "discovery required boundary" "### ✅ Discovery Must" "$DISCOVERY_SKILL"
assert_literal "discovery forbidden boundary" "### ❌ Discovery Must Not" "$DISCOVERY_SKILL"
for skill in "$FEATURE_SKILL" "$BUG_FIX_SKILL" "$REFACTOR_SKILL"; do
  assert_match "workflow warning heading" '^### ⚠️ .*Red Flags$' "$skill"
  assert_literal "ambiguous feedback heading" "### ❓ Ambiguous Acceptance Feedback" "$skill"
done
```

同步更新 `tests/workflow-symmetry.sh` 中对三个 workflow 精确标题的对称断言。

- [ ] **Step 2: 运行测试并确认 RED**

Run:

```bash
bash tests/document-conventions-contract.sh
bash tests/workflow-symmetry.sh
```

Expected: 至少新视觉标题断言 FAIL。

- [ ] **Step 3: 最小修改高价值区块**

执行以下有限修改：

```text
using-dev-cadence: ## Red Flags -> ## ⚠️ Red Flags
discovery: Workflow Boundary 内增加 ### ✅ Discovery Must / ### ❌ Discovery Must Not
feature-dev/bug-fix/refactor: 所有 *Red Flags 标题增加 ⚠️
feature-dev/bug-fix/refactor: Ambiguous Acceptance Feedback 增加 ❓
```

不得更改列表正文、业务规则、阶段或状态值。

- [ ] **Step 4: 确认 GREEN 与业务文本不变**

Run:

```bash
bash tests/document-conventions-contract.sh
bash tests/workflow-symmetry.sh
git diff --word-diff=porcelain -- src/skills/using-dev-cadence/SKILL.md src/skills/discovery/SKILL.md src/skills/feature-dev/SKILL.md src/skills/bug-fix/SKILL.md src/skills/refactor/SKILL.md
```

Expected: tests PASS；word diff 只显示预期标题、Discovery 子标题和入口读取规则变化。

- [ ] **Step 5: 执行 plan-task-2 pre-commit review 并提交**

按同一 review ledger 规则暂存、检查并提交：

```bash
git commit -m "docs(skills): add semantic visual markers"
```

### Task 3: 分发、dogfood 与完整验证

**Files:**
- Modify: `.dev-cadence/**`（仅通过安装脚本生成）
- Create: `build/dev-cadence/feature-dev/s-008-document-conventions/04-implementation-record.md`
- Create: `build/dev-cadence/feature-dev/s-008-document-conventions/04-code-review-report.md`
- Modify: `build/dev-cadence/feature-dev/s-008-document-conventions/03-implementation-plan.md`
- Modify: `build/dev-cadence/feature-dev/s-008-document-conventions/manifest.md`

- [ ] **Step 1: 重新构建并更新 dogfood 安装包**

Run:

```bash
bash scripts/build.sh
bash scripts/install.sh .
```

Expected: `.dev-cadence/skills/document-conventions/SKILL.md` 存在，安装版本为 `0.10.0`。

- [ ] **Step 2: 运行完整开发验证**

Run:

```bash
bash scripts/check-whitespace.sh
bash scripts/check-all.sh
rg --no-ignore -n 'document-conventions|✅|❌|❓|⚠️|ℹ️' src/skills dist/.dev-cadence/skills .dev-cadence/skills
```

Expected: 全部检查 PASS；source、dist 和 dogfood 安装包包含一致关键规则。

- [ ] **Step 3: 完成 implementation record 和 whole-feature review**

记录 `IMPLEMENTATION_BASE_SHA`、两项 plan-task commit、执行检查、变更文件和剩余风险。对 `IMPLEMENTATION_BASE_SHA..FINAL_IMPLEMENTATION_SHA` 做完整 review，填写 `04-code-review-report.md`，Critical/Important finding 必须修复或明确记录。

- [ ] **Step 4: 提交 dogfood 与实现记录**

按 pre-commit review ledger 执行 `plan-task-3` 提交：

```bash
git commit -m "chore(repo): update document conventions dogfood"
```

- [ ] **Step 5: 完成 Development Implementation 条件**

确认：

```text
所有计划步骤已勾选
所有 implementation ledger 条目 verified
FINAL_IMPLEMENTATION_SHA 指向最新实施提交
完整 review 无未解决 Critical/Important finding
完整开发检查通过
```
