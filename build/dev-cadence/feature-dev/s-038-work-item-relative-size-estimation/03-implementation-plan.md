# S-038 工作项相对 Size 估算 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 Work Item Planning 中提供可确认、可重新估算且不伪装为工期的相对 Size 能力。

**Architecture:** Size、基准和同步投影由 Work Item Planning 独占；卡片承载单项 Size，Story Map 承载基准与分布，Backlog 承载不改变生命周期表的 Size Summary。其他 workflow 只标记重新估算需要。

**Tech Stack:** Markdown workflow contracts、Bash contract tests、构建脚本。

## Global Constraints

- 唯一枚举是 `XS | S | M | L | XL | ?`，不转换为人日、工期或容量。
- 用户必须确认 `M` 基准；信息不足保持 `?`。
- Backlog 生命周期表保持五列，Size 使用独立 Summary。
- Size-only 变化不递增卡片 Version，不创建 Iteration Plan 或修改 S-039。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Planning Size 契约 | 定义基准、枚举、投影和重新估算流程 | Planning skill, planning contract | 估算与失效 RED/GREEN |
| Task 2: 下游标记边界 | 确保非 Planning workflow 只标记失效 | workflow skills, analysis/symmetry tests | ownership RED/GREEN |
| Task 3: 用户说明与包验证 | 同步使用说明、构建分发包并评估版本 | docs, version, dist | targeted + full checks |

## Detailed Tasks

### Task 1: Planning Size 契约

**Files:**
- Modify: `src/workflows/work-item-planning/SKILL.md`
- Modify: `tests/work-item-planning-contract.sh`

**Interfaces:**
- Consumes: 已形成的 Story Map、卡片、Backlog。
- Produces: 基准确认、Size 提案、卡片/Story Map/Backlog Size Summary 的原子写入契约。

- [x] **Step 1: 写出失败的 Planning 契约断言**

在 `tests/work-item-planning-contract.sh` 断言唯一枚举、`M` 基准确认、复用和失效、`?` 保留、`XL`/不确定性汇总、Size-only 不升 Version、五列表不变及 `Size Summary`：

```bash
assert_contains "$PLANNING_SKILL" 'XS.*S.*M.*L.*XL.*\\?'
assert_contains "$PLANNING_SKILL" 'Size Summary'
```

- [x] **Step 2: 运行 RED 检查**

Run: `bash tests/work-item-planning-contract.sh`

Expected: 新 Size 契约断言失败。

- [x] **Step 3: 最小规则修改**

在 Planning 中增加条件性 Relative Size Estimation：基准候选和理由、用户确认 `M`、复用/失效、卡片字段、Story Map 基准与分布、Backlog `Size Summary`、原子写入和 Change Log 规则。保留 Story Map 的 Story/Task 和 Backlog 五列边界。

- [x] **Step 4: 运行 GREEN 检查**

Run: `bash tests/work-item-planning-contract.sh`

Expected: 首次估算、复用、失效、不确定性和投影契约全部通过。

- [x] **Step 5: 提交单元**

Run: `git add src/workflows/work-item-planning/SKILL.md tests/work-item-planning-contract.sh && git commit -m "feat(planning): add relative size estimation"`

### Task 2: 下游标记边界

**Files:**
- Modify: `src/workflows/feature-dev/SKILL.md`
- Modify: `src/workflows/bug-fix/SKILL.md`
- Modify: `src/workflows/refactor/SKILL.md`
- Modify: `src/workflows/work-item-analysis/SKILL.md`
- Modify: `tests/work-item-analysis-contract.sh`
- Modify: `tests/workflow-symmetry.sh`

**Interfaces:**
- Consumes: 实质范围变化的工作项卡。
- Produces: `Needs Size Re-estimation: yes` 与原因，并移交 Work Item Planning。

- [x] **Step 1: 写出失败的 ownership 断言**

在 Analysis 契约和 Delivery symmetry 测试中断言非 Planning workflow 不修改 `Size`，只设置重新估算标记并返回 Planning：

```bash
assert_workflows 'size re-estimation handoff' 'must not modify Size' 'must not modify Size' 'must not modify Size'
```

- [x] **Step 2: 运行 RED 检查**

Run: `bash tests/work-item-analysis-contract.sh && bash tests/workflow-symmetry.sh`

Expected: 新所有权断言失败。

- [x] **Step 3: 最小规则修改**

在三个 Delivery workflow 的 card/change handling 边界和 Work Item Analysis 的 planning handoff 中写入相同限制：范围实质变化时仅标记 Size 需重新估算及原因，不得改 Size、Story Map、Backlog Summary 或基准。

- [x] **Step 4: 运行 GREEN 检查**

Run: `bash tests/work-item-analysis-contract.sh && bash tests/workflow-symmetry.sh`

Expected: 规则对称且 Analysis 仍不拥有 Size。

- [x] **Step 5: 提交单元**

Run: `git add src/workflows/feature-dev/SKILL.md src/workflows/bug-fix/SKILL.md src/workflows/refactor/SKILL.md src/workflows/work-item-analysis/SKILL.md tests/work-item-analysis-contract.sh tests/workflow-symmetry.sh && git commit -m "feat(planning): route size re-estimation to planning"`

### Task 3: 用户说明与包验证

**Files:**
- Modify: `docs/workflows/work-item-planning.md`
- Modify: `version`
- Generated: `dist/.dev-cadence/`

**Interfaces:**
- Consumes: 已通过的 source Planning 与 ownership 契约。
- Produces: 与 source 对齐的用户说明和包含 S-038 的可安装包。

- [x] **Step 1: 更新现有 Planning 说明**

同步已有 `docs/workflows/work-item-planning.md` 的 Size 说明：基准 Version、失效标记、`?`、`XL`、Size Summary 和不属于 S-039 的边界。不要把它作为 workflow 权威来源。

- [x] **Step 2: 运行文档与 source 检查**

Run: `bash tests/work-item-planning-contract.sh && bash scripts/check-whitespace.sh`

Expected: source 契约和 whitespace 均通过。

- [x] **Step 3: 评估版本并构建**

将 S-019 与 S-038 作为同一发布单元，合并顺序确定后只更新一次根 `version` 到下一个 minor 版本，并在两个运行记录中记录共享版本决定。

Run: `bash scripts/build.sh && bash scripts/check-all.sh`

Expected: source 与 dist 同步，全量检查通过。

- [x] **Step 4: 检查关键规则同步**

Run: `rg --no-ignore 'Relative Size Estimation|Size Summary|Needs Size Re-estimation' src dist/.dev-cadence`

Expected: source 与 dist 同步包含 Size 契约。

- [x] **Step 5: 提交单元**

Run: `git add docs/workflows/work-item-planning.md version && git commit -m "feat(release): publish planning size updates"`

## Plan Self-Review

- 每项 S-038 验收标准都有 Planning、ownership 或 package 验证覆盖。
- 没有创建新 skill、状态、容量模型或 Iteration Plan。
- 所有可执行规则先由 shell 契约测试建立 RED，再进行最小 GREEN 修改。
