# S-005 Open Question Registry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为目标仓库提供按需创建、单一正文来源、可迁移和可追溯的共享 Open Question Registry 能力。

**Architecture:** 使用独立 `open-question-registry` skill 拥有 Registry 完整契约，`using-dev-cadence` 仅负责共享能力路由。Shell 契约测试保护核心语义、包含关系和安装结果。

**Tech Stack:** Markdown skills, Bash contract tests, existing build/install scripts.

## Global Constraints

- 完整 Registry 生命周期规则只在共享 skill 维护。
- `docs/open-questions.md` 只在首次真实登记时创建，安装不创建该文档。
- 不覆盖或默认合并仓库已有候选全局问题索引。
- 不直接编辑 `dist/.dev-cadence/**`。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Registry contract | 用失败测试定义共享能力语义 | `tests/open-question-registry-contract.sh`, `tests/run-all.sh` | Focused contract fails for missing skill |
| Task 2: Shared skill and routing | 实现 Registry 契约与入口路由 | `src/skills/open-question-registry/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md` | Focused contract passes |
| Task 3: Package and release integration | 保证分发包、安装和版本正确 | `tests/package-contract.sh`, `tests/install-contract.sh`, `tests/skill-description-contract.sh`, `version` | Full check-all passes |
| Task 4: Delivery records and backlog | 关闭工作项并保存验证证据 | Story, Backlog, run records | Story/Backlog consistent; final checks pass |

## Detailed Tasks

### Task 1: Registry Contract

**Files:**
- Create: `tests/open-question-registry-contract.sh`
- Modify: `tests/run-all.sh`

- [ ] 写入对 skill 文件、按需创建、字段、正文所有权、迁移、移除、Change Log、冲突保护和路由的断言。
- [ ] 运行 `bash tests/open-question-registry-contract.sh`，预期因 `src/skills/open-question-registry/SKILL.md` 不存在而 FAIL。
- [ ] 把 focused contract 接入 `tests/run-all.sh`。

### Task 2: Shared Skill And Routing

**Files:**
- Create: `src/skills/open-question-registry/SKILL.md`
- Modify: `src/skills/using-dev-cadence/SKILL.md`

- [ ] 实现最小共享 skill，明确完整文档结构与生命周期。
- [ ] 在入口增加直接请求和 workflow 复用路由，不把共享能力伪装成六阶段 workflow。
- [ ] 运行 focused contract，预期 PASS。

### Task 3: Package And Release Integration

**Files:**
- Modify: `tests/package-contract.sh`
- Modify: `tests/install-contract.sh`
- Modify: `tests/skill-description-contract.sh`
- Modify: `version`

- [ ] 增加分发包、安装和 description 契约。
- [ ] 将版本更新为 `0.13.0`。
- [ ] 运行 `bash scripts/build.sh` 同步 `dist/.dev-cadence`。
- [ ] 运行 `bash scripts/check-whitespace.sh` 和 `bash scripts/check-all.sh`，预期全部 PASS。

### Task 4: Delivery Records And Backlog

**Files:**
- Modify: `docs/stories/S-005-open-question-registry.md`
- Modify: `docs/backlog.md`
- Create/Modify: `build/dev-cadence/feature-dev/s-005-open-question-registry/*.md`

- [ ] 更新 Story 状态和 Change Log，将 S-005 移入 Backlog 已完成。
- [ ] 重新计算并更新当前可并行实施表，S-006 变为 Ready。
- [ ] 记录实施、Review、系统测试、Business Acceptance 和 Completion 证据。

## Plan Self-Review

- Spec coverage: 12 项验收标准均映射到 Task 1-4。
- Placeholder scan: 无 `TBD`/`TODO`/“稍后实现”。
- Scope: 仅实现 S-005，不扩展后续 workflow 深度接入。
- Freshness decision: 🟢 `ready`；Story Version `2`、三份阶段记录、分支 `codex/s-005-open-question-registry` 与 commit `468a1e8` 一致。

## 计划结论

- Status: ✅ `confirmed`
- Confirmation: 用户已授权不经中途确认持续执行至任务完成。
