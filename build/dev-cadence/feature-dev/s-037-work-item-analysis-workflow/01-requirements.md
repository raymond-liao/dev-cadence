# S-037 工作项分析 Workflow：需求确认

## 状态

✅ `confirmed`

## 确认依据

用户于 2026-07-17 要求开始实施 S-037。S-037 Version `1` 的唯一依赖 S-015 Version `7`、Status `Done`，且卡片 Open Questions 为“无”；本次进入交付前将其状态校正为 `Ready`。

## ✅ 纳入范围

- 新增可安装的 `work-item-analysis` workflow skill。
- 支持单项分析和用户明确选择工作项集合的批量分析。
- 复用已有 Story、Task、Bug 卡片；缺卡时允许创建轻量卡片并在同一次分析中完善。
- 为 Story、Task、Bug 定义各自的分析字段、成熟度规则、重复/冲突处理和用户确认门。
- 明确 Work Item Analysis 与 Discovery、Work Item Planning、Bug Fix、Feature Dev、Refactor 的边界。
- 接入入口路由、构建分发、契约测试、安装验证和必要的公开说明。

## ❌ 排除范围

- 不修改 User Journey、Feature、PRD 或 Business Architecture。
- 不修改 Story Map、Milestone、Size、Iteration Plan 或 Backlog 排序。
- 不设计技术方案，不调查 Bug 根因，不执行代码实现、测试或业务验收。
- 不自动扩展批量分析范围，不自动删除、合并或替代工作项卡片。
- 不直接编辑 `dist/.dev-cadence/**`。

## 验收标准

1. 安装包可路由到 `work-item-analysis` workflow。
2. Workflow 支持 Story、Task、Bug 的单项和明确批量分析。
3. 已有卡片被复用，缺卡不会产生重复 ID 或平行权威定义。
4. Story、Task、Bug 使用各自明确的分析字段和成熟度门禁。
5. Story 只有在定义完整并经用户确认后进入 `Ready`；Task 和 Bug 不被统一门禁机械阻塞。
6. Work Item Analysis 不越界承担产品设计、Backlog 规划或 Bug 根因诊断。
7. source、dist、安装包、入口路由和契约测试保持同步。

## 开放问题与假设

- `docs/workflows/work-item-analysis.md` 是当前业务说明，新增 `src/skills/work-item-analysis/SKILL.md` 后以该执行规则为权威来源。
- 本分支不修改根 `version`；两个并行任务集成时由主代理统一升级版本并重新构建。

## 需求来源

- `docs/stories/S-037-work-item-analysis-workflow.md`
- `docs/workflows/work-item-analysis.md`
- `src/skills/using-dev-cadence/SKILL.md`
- `src/skills/work-item-planning/SKILL.md`

