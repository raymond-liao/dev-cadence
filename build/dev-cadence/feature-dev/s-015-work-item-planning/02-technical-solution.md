# S-015 工作项规划 Workflow 与工作项契约：技术方案

## 状态

✅ `confirmed`

## Codebase Exploration Findings

- `src/skills/using-dev-cadence/SKILL.md` 是集中入口路由；当前只列出 Discovery、Architecture Design、Feature Dev、Bug Fix 和 Refactor，必须补入 Work Item Planning 的适用边界。
- `src/skills/discovery/SKILL.md` 已将 User Journey/Feature 设为 Discovery 的权威资产，并把工作项影响交接给 `work-item-planning`；新 skill 必须只读引用这些资产。
- `src/skills/architecture-design/SKILL.md` 和三个 Delivery Workflow skill 已形成 Asset/Delivery 记录边界；新 skill 应属于 Asset Workflow，不得复制 Delivery manifest、阶段记录或 checkpoint 规则。
- `docs/workflows/work-item-planning.md` 已给出组合规划、单项登记、Story Map、Milestone、卡片和 Backlog 的完整业务契约；本次将其压缩为可执行约束而不发明新状态。
- `scripts/build.sh` 会自动复制整个 `src/skills`；契约测试需显式检查新文件、入口路由、source/dist 同步和安装包完整性。

## 方案比较

### 最小变更方案

只新增 `src/skills/work-item-planning/SKILL.md`，再补入口和基础 package 检查。改动少，但无法覆盖新 workflow 的资产边界、状态契约和用户确认原子写回要求，回归风险高。

### 清晰分层方案

为工作项模型、Story Map、Backlog、并发写回分别拆成多个 skill 文件和脚本。职责最细，但会引入新的安装结构、引用关系和维护面，超出 S-015 的最小可交付范围。

### ✅ Selected：务实平衡方案

新增一个完整的 `work-item-planning` skill，复用现有 `document-conventions` 与集中路由；用一组专门契约测试覆盖可安装性、Asset/Delivery 边界、资产所有权、确认门和核心卡片规则；用既有 `scripts/build.sh` 同步 dist。工作项模型保持在同一 skill 内，便于目标仓库按一个入口执行，同时不实现 S-016/S-037/S-038/S-039 的后续能力。

## 资产边界与数据流

```text
Discovery
  -> 已确认 User Journey + Feature + PRD + Business Architecture
  -> work-item-planning（会话提案）
  -> 用户确认
  -> Story Map + Milestone + 轻量 Story/Task/Bug + 必要 Backlog 引用
  -> 用户选择后移交 feature-dev / bug-fix / refactor
```

- User Journey、Feature、PRD、Business Architecture 归 Discovery 所有；Work Item Planning 只能读取和引用。
- Story Map 唯一路径为 `docs/product-planning/story-map.md`；Backlog 仍是 `docs/backlog.md` 的统一资产，S-015 只定义其首次创建和规划引用边界。
- 组合规划读取全部已确认 Offline/System Feature，保持 Journey 顺序；Offline Feature 不放系统 Story/Task，Bug 不进入 Story Map。
- 单项登记只创建或复用当前轻量卡片及必要 Backlog 引用，不强制重画 Story Map。
- 用户确认前不能写入正式资产；确认后写入前重新读取并比较版本，冲突时停止并让用户决策。

## 测试策略

- 先用契约测试锁定 skill 的入口、模式、所有权、状态、路径、确认和禁止项。
- 用 `tests/routing-contract.sh` 验证集中入口和相邻 workflow 边界。
- 用 `tests/package-contract.sh` 验证新 skill 进入分发包且 source/dist 一致。
- 用 `tests/skill-description-contract.sh` 验证新 skill 的精确 description 与不泄漏流程摘要。
- 运行 `bash scripts/build.sh`、`bash scripts/check-whitespace.sh` 和 `bash scripts/check-all.sh`，并用 `rg --no-ignore` 做关键规则 source/dist 同步核对。

## 约束与风险

- 本仓库没有实际产品基线文件，不能用 Story 卡片替代目标仓库的产品输入。
- 版本、状态和 Change Log 规则必须与 `document-conventions` 保持一致；状态变化不应被误写为定义版本变化。
- 新 skill 只能定义 S-015 的规划职责，必须明确后续 S-016、S-037、S-038、S-039 的停止边界。
- `dist/` 是构建产物，必须由脚本生成。

## 关联需求

本方案基于 [需求确认记录](01-requirements.md)，对应 `docs/stories/S-015-work-item-planning-workflow-contract.md` 的 12 条验收标准。
