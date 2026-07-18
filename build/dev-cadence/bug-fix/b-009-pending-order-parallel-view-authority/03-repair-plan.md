# B-009 Repair Plan

- Workflow: `bug-fix`
- Work Item: [B-009 待处理排序与并行视图职责不一致](../../../../docs/bugs/B-009-pending-order-parallel-view-authority.md)
- Status: 🔄 `in_progress`
- Implementation base SHA: `6e18954624df1df45f9afd9141191b002605b724`
- Implementation branch: `codex/fix-b009-pending-order-authority`
- TDD RED evidence: `tests/work-item-planning-contract.sh` 和 `tests/parallel-work-table-contract.sh` 已在修复前失败。

## Task Overview

| Task | Goal | Files | Verification |
|---|---|---|---|
| Task 1: 规则契约 | 让 Work Item Planning 明确唯一顺序来源、派生并行视图和首项阻塞门禁 | `src/skills/work-item-planning/SKILL.md`, `src/skills/using-dev-cadence/SKILL.md` | Work Item Planning、parallel view、routing contracts |
| Task 2: 规划资料同步 | 对齐 Backlog、Work Item Planning 流程说明和 S-017 已确认领取定义 | `docs/backlog.md`, `docs/workflows/work-item-planning.md`, `docs/stories/S-017-work-item-development-workflow-integration.md` | 顺序/列结构检查、链接检查、全文关键规则检索 |
| Task 3: 契约与分发 | 更新测试与版本，构建 source-to-dist 分发包并运行全量检查 | `tests/work-item-planning-contract.sh`, `tests/parallel-work-table-contract.sh`, `tests/routing-contract.sh`, `version` | `bash scripts/build.sh`, `bash scripts/check-whitespace.sh`, `bash scripts/check-all.sh` |

## Detailed Tasks

### Task 1: 规则契约

- [x] 在 `src/skills/work-item-planning/SKILL.md` 的 `Parallel Work View Contract` 中写出 `待处理` 行顺序是唯一权威建议实施顺序。
- [x] 规定并行表是按待处理顺序和依赖关系生成的派生视图，必须保持相对顺序，不得维护独立排序。
- [x] 规定待处理首项不能推进时，必须先由 Work Item Planning 确认并调整排序，不能静默跳过后续项。
- [x] 规定并行表状态只表达生命周期，workflow 路由由 `using-dev-cadence` 和对应 workflow skill 负责。

### Task 2: 规划资料同步

- [x] 从 `docs/backlog.md` 并行表删除 `下一步 Workflow / 入口门禁` 列和逐行路由文本。
- [x] 按当前 `待处理` 顺序同步并行表中的工作项相对顺序，不改 B-009 领取状态，不改 B-005/B-007/B-008 历史状态。
- [x] 更新 `docs/workflows/work-item-planning.md` 和 S-017 的旧职责表述，使其与新的唯一顺序和路由所有权一致；S-017 已一致，因此未改写。

### Task 3: 契约与分发

- [x] 保持测试先行证据，更新契约测试以验证新规则和 Backlog 表结构。
- [x] 将根版本从 `0.23.0` 更新为下一兼容版本，并运行构建同步 `dist/.dev-cadence`；不直接编辑 `dist`。
- [x] 运行工作项、并行视图、路由和全量契约检查；运行 whitespace 检查和本地 Markdown 链接检查。
- [x] 完成实现阶段的独立代码审查，再运行 Regression Verification 并记录结果。

## Expected Results

- RED checks fail on the baseline because the new contract is absent.
- GREEN checks pass after the source rules and planning assets are aligned.
- Full repository checks and generated package checks pass with no direct `dist` edits.

## Completion Conditions For Repair Implementation

- All checklist items are checked with command or file evidence.
- Each implementation commit is reviewed against this plan and its exact parent/tree identity.
- `04-repair-record.md` and `04-code-review-report.md` record implementation and review evidence before Regression Verification.
