# S-019 最终验证版本绑定 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让三条 Delivery workflow 的最终验证只能复用于同一验证候选，并由共享 validator 强制核验。

**Architecture:** 以 `validate-delivery-record.sh` 为唯一的快照、可达性和 checkpoint 白名单实现。Feature Dev、Bug Fix 与 Refactor 只声明相同的记录字段、调用时机和回退规则。

**Tech Stack:** Bash、Git、Markdown workflow contracts、shell contract tests。

## Global Constraints

- tracked 身份必须来自相对 `FINAL_IMPLEMENTATION_SHA` 的 raw binary diff，不使用 `patch-id`。
- 排除仅当前 run 证据目录的 diff；不得把未跟踪文件纳入候选。
- 默认 validator 必须支持实施前 run；最终验证与终态模式必须严格拒绝缺失或失效身份。
- 三条 Delivery workflow 保持对称；不改变实施提交身份、风险传递或 Refactor 基线。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Validator 生命周期 | 支持规范/历史 manifest 表头和实施前结构验证 | validator, delivery-record contract | 新增 fixture RED/GREEN |
| Task 2: 候选快照核验 | 实现最终验证身份与 checkpoint 白名单 | validator, delivery-record contract | 快照失效/允许 checkpoint fixture |
| Task 3: Workflow 对称接入 | 三条 workflow 在最终验证、验收和 Completion 使用同一规则 | 三条 SKILL, symmetry test | symmetry RED/GREEN |
| Task 4: 包验证与版本 | 构建可安装包并验证发布输入 | version, build output | targeted + full checks |

## Detailed Tasks

### Task 1: Validator 生命周期

**Files:**
- Modify: `tests/delivery-record-contract.sh`
- Modify: `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh`

**Interfaces:**
- Consumes: manifest Stage Table。
- Produces: 默认模式可验证 in-progress run，且同时接受 `Artifact` 与 `Artifact Path`。

- [x] **Step 1: 写出失败的 in-progress fixture**

在 `tests/delivery-record-contract.sh` 创建仅含 Requirements artifact、表头为 `Artifact Path`、无 implementation record 的 run，并断言：

```bash
run_validator "$in_progress_run" || fail "in-progress manifest should validate structurally"
```

- [x] **Step 2: 运行 RED 检查**

Run: `bash tests/delivery-record-contract.sh`

Expected: 失败，原因是 validator 不识别 `Artifact Path` 或错误要求 implementation record。

- [x] **Step 3: 最小实现**

修改 validator 的表头匹配和实施记录门槛：

```bash
/^\| Stage \| Status \| Artifact( Path)? \| User Confirmation \| Checkpoint Commit \| Notes \|$/
```

只有当 implementation artifact path 不是 `pending` 时才执行 Final Implementation SHA 与 changed-files 校验；`--terminal` 仍要求实施和系统测试记录。

- [x] **Step 4: 运行 GREEN 检查**

Run: `bash tests/delivery-record-contract.sh`

Expected: 新 in-progress fixture 通过，既有 terminal fixture 继续通过。

- [x] **Step 5: 提交单元**

Run: `git add tests/delivery-record-contract.sh src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh && git commit -m "fix(flow): validate in-progress delivery records"`

### Task 2: 候选快照核验

**Files:**
- Modify: `tests/delivery-record-contract.sh`
- Modify: `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh`

**Interfaces:**
- Consumes: 测试报告中的开始/结束 `HEAD`、branch、`FINAL_IMPLEMENTATION_SHA`、binary diff object ID 与 clean/dirty 状态。
- Produces: 最终验证模式和 `--terminal` 的明确通过/失败结果。

- [x] **Step 1: 写出失败场景**

为缺失快照、开始/结束不一致、final SHA 不可达、branch 变化、tracked diff 变化、允许证据 checkpoint 和禁止候选代码提交分别添加 fixture，例如：

```bash
expect_validator_failure "$run" --final-verification "tracked snapshot changed"
```

- [x] **Step 2: 运行 RED 检查**

Run: `bash tests/delivery-record-contract.sh`

Expected: 新失效场景未被拒绝或新模式尚不存在。

- [x] **Step 3: 最小实现**

增加 `--final-verification` 模式。用以下稳定输入计算身份：

```bash
git diff --binary "$FINAL_IMPLEMENTATION_SHA" -- . ":(exclude)$RUN_DIR" | git hash-object --stdin
```

验证 final SHA 可达、开始/结束字段一致、当前重算身份一致；遍历验证结束后 first-parent 提交，只接受 manifest 记录且 diff 限于 `$RUN_DIR/` 的 checkpoint。

- [x] **Step 4: 运行 GREEN 检查**

Run: `bash tests/delivery-record-contract.sh`

Expected: 所有允许/拒绝 fixture 与错误信息一致。

- [x] **Step 5: 提交单元**

Run: `git add tests/delivery-record-contract.sh src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh && git commit -m "feat(flow): bind final verification to candidate identity"`

### Task 3: Workflow 对称接入

**Files:**
- Modify: `src/workflows/feature-dev/SKILL.md`
- Modify: `src/workflows/bug-fix/SKILL.md`
- Modify: `src/workflows/refactor/SKILL.md`
- Modify: `tests/workflow-symmetry.sh`

**Interfaces:**
- Consumes: validator `--final-verification`。
- Produces: 三条 workflow 的相同记录字段、重验点和回退边界。

- [x] **Step 1: 写出失败的对称性断言**

在 `tests/workflow-symmetry.sh` 断言三条 workflow 都包含：开始/结束候选身份字段、Business Acceptance 与 Completion 前的最终验证调用、候选变化回实施并重新 review/验证、证据 checkpoint 白名单。

- [x] **Step 2: 运行 RED 检查**

Run: `bash tests/workflow-symmetry.sh`

Expected: 缺少新字段和调用的断言失败。

- [x] **Step 3: 最小规则修改**

在各自 System/Regression Testing、Business Acceptance、Completion 和终态检查清单中写入同义的记录、调用和回退规则；调用：

```bash
bash .dev-cadence/workflows/using-dev-cadence/scripts/validate-delivery-record.sh \
  build/dev-cadence/<workflow>/<slug> --final-verification
```

- [x] **Step 4: 运行 GREEN 检查**

Run: `bash tests/workflow-symmetry.sh && bash tests/delivery-record-contract.sh`

Expected: 对称性和 validator 契约均通过。

- [x] **Step 5: 提交单元**

Run: `git add src/workflows/feature-dev/SKILL.md src/workflows/bug-fix/SKILL.md src/workflows/refactor/SKILL.md tests/workflow-symmetry.sh && git commit -m "feat(flow): enforce final verification freshness"`

### Task 4: 包验证与版本

**Files:**
- Modify: `version`
- Generated: `dist/.dev-cadence/`

**Interfaces:**
- Consumes: 已通过的 source 契约测试。
- Produces: 含 S-019 行为的可安装包。

- [x] **Step 1: 评估版本单元**

将 S-019 与并行 S-038 作为同一可安装包发布单元；在合并顺序确定后只更新一次根 `version` 到下一个 minor 版本，并在两个运行记录中说明该共享版本决定。

- [x] **Step 2: 构建与验证**

Run: `bash scripts/build.sh && bash scripts/check-all.sh && bash scripts/check-whitespace.sh`

Expected: source 与 dist 同步，所有契约检查通过。

- [x] **Step 3: 检查关键规则同步**

Run: `rg --no-ignore 'final verification|FINAL_IMPLEMENTATION_SHA|Artifact Path' src dist/.dev-cadence`

Expected: source 与 dist 均包含最终规则。

- [x] **Step 4: 提交单元**

Run: `git add version && git commit -m "feat(release): publish workflow verification updates"`

## Plan Self-Review

- 每项 S-019 验收标准均映射到 validator fixture 或 symmetry 断言。
- 没有引入新 skill、风险模型或未跟踪文件语义。
- 所有源码修改都先有失败的 shell 契约测试。
