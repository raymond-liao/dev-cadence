# S-037 工作项分析 Workflow：技术方案

## 状态

✅ `confirmed`

## 需求来源

本方案基于 [需求确认记录](01-requirements.md)、S-037 Version `1` 和现有业务说明。

## Codebase Exploration Findings

- `src/skills/using-dev-cadence/SKILL.md` 是集中路由和流程优先级的权威入口，需要新增 Work Item Analysis 的路由、边界和交接说明。
- `docs/workflows/work-item-analysis.md` 已完整描述业务流程，但 `src/skills/work-item-analysis/SKILL.md` 尚不存在；新增 skill 必须将该业务契约压缩为可执行规则。
- `scripts/build.sh` 会复制整个 `src/skills`，因此新增 skill 不需要额外复制脚本，但必须补充契约测试确认 source/dist/package 一致。
- `tests/routing-contract.sh` 和 `tests/package-contract.sh` 已覆盖入口与安装包契约；新增专用 `tests/work-item-analysis-contract.sh` 并接入 `tests/run-all.sh` 可以锁定语义边界。
- README 双语工作流说明是用户可见安装行为的一部分，需要补充新 workflow 的适用范围和职责边界。

## 方案比较

### 最小变更方案

只新增 skill 文件并在入口加入一行路由。实现快，但无法保证用户看到的路由说明、安装包、边界规则和回归测试同步。

### 清晰分层方案

拆分 Story/Task/Bug 分析为三个独立 skill，并新增独立路由模块。职责细，但与当前一个 workflow 一个 skill 的安装结构不一致，扩大维护面。

### ✅ Selected：务实平衡方案

新增单一 `work-item-analysis` skill，复用现有 `document-conventions` 和集中入口；以专用契约测试覆盖三类工作项字段、Ready 门禁、卡片复用、分析边界和 Asset/Delivery 记录边界；同步双语 README、构建和安装契约。业务说明继续作为设计资料，执行 skill 作为安装后的权威规则。

## 边界与数据流

```text
Discovery / Work Item Planning
        -> 轻量 Story / Task / Bug
        -> work-item-analysis
        -> 用户确认的权威卡片
        -> feature-dev / bug-fix / refactor
```

- Work Item Analysis 只更新用户选定的工作项卡片，不改变产品基线、Story Map、Milestone、Size、Iteration Plan 或 Backlog 顺序。
- Story 必须满足定义完整且用户确认后才进入 `Ready`；Task 不设统一 Ready 硬门禁；Bug 分析不替代 Bug Fix 根因诊断。
- Asset Workflow 不创建 `build/dev-cadence/` 运行记录；本 Story 的 Delivery Workflow 记录只记录安装规则的实现和验证。

## 测试策略

- 先为新 skill、路由和安装内容写失败契约检查。
- 使用 focused `tests/work-item-analysis-contract.sh`，再运行 `tests/routing-contract.sh`、`tests/package-contract.sh` 和完整 `bash scripts/check-all.sh`。
- 构建后用 `rg --no-ignore` 检查 source/dist 中 skill、路由和关键边界规则同步。

## 风险与约束

- 新增 skill 影响安装包行为，最终集成必须升级根版本；并行分支不各自修改 `version`。
- 入口路由必须区分“分析工作项”和“实现工作项”，避免把 S-037 误写成 Delivery Workflow。
- README 只增加用户可见的 workflow 说明，不复制完整执行规则。

