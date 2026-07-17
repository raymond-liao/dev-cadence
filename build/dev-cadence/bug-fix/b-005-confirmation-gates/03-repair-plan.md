# B-005 修复计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task with verification checkpoints.

**Goal:** 补齐六个已安装 Workflow 的确认门摘要、选项和结果语义，并用语义契约测试保护其闭环。

**Architecture:** 规则继续由六个 owning Workflow skill 分别持有；不新增运行时模板或跨 Workflow 状态。测试通过一个独立 shell 契约脚本按语义检查六套规则，并由构建脚本生成分发包。

**Tech Stack:** Markdown workflow rules, Bash contract tests, `bash scripts/build.sh`, repository shell checks.

## Global Constraints

- 只修改 `src/skills/**`、`tests/**` 和根目录 `version`；不编辑 `dist/.dev-cadence/**`。
- 不修改 `src/vendor/superpowers/**`。
- 六个 Workflow 规则及测试输出使用英文源规则风格；运行记录沿用 `zh-CN`。
- 不新增 Workflow 阶段、状态、终态或未实现的停止/回滚动作。
- 使用测试先行：先加入能证明契约缺口的断言并观察基线失败，再修改规则使其通过。

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Confirmation rule contract | 为六个 owning Workflow 补齐摘要、选项、结果影响和专用边界规则 | `src/skills/discovery/SKILL.md`, `src/skills/work-item-planning/SKILL.md`, `src/skills/architecture-design/SKILL.md`, `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, `src/skills/refactor/SKILL.md` | `tests/confirmation-gates-contract.sh` |
| Task 2: Semantic contract coverage | 新增六 Workflow 语义契约测试并接入总测试 | `tests/confirmation-gates-contract.sh`, `tests/run-all.sh` | 单独脚本与 `bash tests/run-all.sh` |
| Task 3: Package/version synchronization | 更新批次版本并构建安装包 | `version`, generated `dist/.dev-cadence/` | `bash scripts/build.sh`, `bash tests/package-contract.sh` |

## Detailed Tasks

### Task 1: Confirmation rule contract

**Files:**
- Modify: `src/skills/discovery/SKILL.md` near User Journey and Product Design confirmation rules.
- Modify: `src/skills/work-item-planning/SKILL.md` near Planning stage sequence and result confirmation.
- Modify: `src/skills/architecture-design/SKILL.md` near design-goal and asset confirmation rules.
- Modify: `src/skills/feature-dev/SKILL.md` near Requirements Confirmation, Technical Solution, and Implementation Plan.
- Modify: `src/skills/bug-fix/SKILL.md` near Problem Diagnosis, Repair Solution, and Repair Plan.
- Modify: `src/skills/refactor/SKILL.md` near Requirements Confirmation, Refactor Solution, and Refactor Plan.

- [ ] Add the shared minimum: stage conclusion, included/excluded scope, risks/open questions before evidence links; actual choices; effects on next stage, writes, records, status, and re-confirmation.
- [ ] Keep Delivery choices symmetric without replacing stage-specific content.
- [ ] Keep Asset-specific partial confirmation, candidate selection, migration/split, and Decision Pending semantics explicit.
- [ ] Run `bash tests/confirmation-gates-contract.sh` before the rule edits and record the expected missing-contract failure.
- [ ] Run it again after edits and require exit code 0.

### Task 2: Semantic contract coverage

**Files:**
- Create: `tests/confirmation-gates-contract.sh`.
- Modify: `tests/run-all.sh` to invoke the new script once.

- [ ] Assert each of the six source skills contains a confirmation-gate contract and an evidence-link boundary.
- [ ] Assert Delivery skills contain both advance and revise/stay semantics without testing exact prose.
- [ ] Assert Asset skills retain their specialized confirmation terms and do not acquire Delivery-only menus.
- [ ] Assert Business Acceptance and Completion are excluded from the new generic pre-stage contract.
- [ ] Run `bash tests/confirmation-gates-contract.sh` and `bash tests/run-all.sh`.

### Task 3: Package/version synchronization

**Files:**
- Modify: `version` from `0.22.0` to `0.23.0`.
- Generate: `dist/.dev-cadence/**` with `bash scripts/build.sh`; do not hand-edit generated output.

- [ ] Run `bash scripts/build.sh`.
- [ ] Run `bash tests/package-contract.sh` and verify source/dist parity.
- [ ] Run `bash scripts/check-whitespace.sh` and `git diff --check`.
- [ ] Record the final changed-file set and implementation commit in `04-repair-record.md`.

## Completion Conditions

- Every acceptance criterion in B-005 maps to a passing contract or full-suite check.
- No source rule contains a generic option that its workflow cannot execute.
- `dist/.dev-cadence` is generated from source and no generated artifact is manually edited or force-added.
- A whole-branch review has no unresolved Critical or Important findings.

## Plan Self-Review

- Scope coverage: all six Workflow skills, tests, build output, and version handling are represented.
- Placeholder scan: no implementation step depends on an unspecified file, function, or later decision.
- Boundary check: Business Acceptance and Completion remain owned by their existing fixed contracts.
