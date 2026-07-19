# B-014 修复方案

- Workflow: `bug-fix`
- Work Item: [B-014 单项建卡被错误套用双确认门](../../../../docs/bugs/B-014-single-card-intake-duplicate-confirmation-gates.md)
- Card Version: `1`
- Diagnosis source: `build/dev-cadence/bug-fix/b-014-single-card-intake-duplicate-confirmation-gates/01-problem-diagnosis-record.md`
- Decision: ✅ `confirmed` - 方案一：显式双分支与 Direct Intake 专属门名
- Confirmed by: `Raymond Liao <raymond-liao@outlook.com>`
- Confirmed at: `2026-07-19T15:35:59+08:00`

## 根因与修复边界

`work-item-planning` 虽区分 `portfolio planning` 和 `direct intake`，却在模式定义之后无条件声明共享三阶段序列和两道正式确认门。修复边界是模式专属阶段和确认门，不改变 Work Item Analysis、Delivery Workflow 或 Business Acceptance。

## 方案比较

### 方案一：显式双分支 + Direct Intake 专属门名（推荐，待确认）

Portfolio Planning 保持 `Planning Inputs And Scope Confirmation -> Planning Structure Proposal -> Planning Result Confirmation`。Direct Intake 改为必要澄清（不构成正式门）-> `Direct Intake Proposal` -> `Direct Intake Result Confirmation`，一次展示完整卡片、ID、路径、Priority、关系、依赖和 Backlog 变化。

专属门名让模式、阶段和测试边界都显式分开，最直接地消除根因，推荐采用。

### 方案二：显式双分支 + 复用 `Planning Result Confirmation`

Portfolio Planning 保持现状，Direct Intake 使用必要澄清 -> Direct Intake Proposal -> `Planning Result Confirmation`，并在结果门内按模式切换展示内容。术语变化较少，但同一门名承载两种语义，未来静态检查更容易再次误套用。

### 方案三：保留共享阶段并增加 Direct Intake 跳过例外

保留现有三阶段文字，只声明 Direct Intake 不展示第一道门。该方案留下“共享序列包含但不适用”的矛盾，不能消除根因，不推荐。

## 命名子集与原子一致性

无论采用哪一方案，单张卡片的创建/更新与其必要 Backlog 引用必须是不可拆分的原子单元。若改变 Backlog 排序，该单元还包括 `Ordering Version` 和 `Ordering Change Log` 的同步更新。`confirm only the named subset` 不得确认孤立卡片或孤立 Backlog 行；可独立保持有效的 Story Map、Milestone 等可选引用才允许单独确认。

## 预计修改与影响

- 可能修改：`src/skills/work-item-planning/SKILL.md`、`docs/workflows/work-item-planning.md`、`tests/work-item-planning-contract.sh`、`tests/confirmation-gates-contract.sh`、`tests/install-contract.sh`；通过 `bash scripts/build.sh` 同步 `dist/.dev-cadence`，并按安装包行为变化评估根目录 `version`。
- 不修改：Portfolio Planning 的双门语义、Feature 所有权、卡片版本/状态、Backlog ordering、Work Item Analysis、Delivery Workflow、Business Acceptance 和历史卡片。

## 回归范围与验收标准

- Direct Intake 只有一次正式确认；必要澄清明确不是正式门。
- 合并门包含完整卡片和全部必要 Backlog 变化，并保持原子写入与命名子集约束。
- Portfolio Planning 仍有输入范围门和规划结果门。
- 计划回归：`tests/work-item-planning-contract.sh`、`tests/confirmation-gates-contract.sh`、`tests/package-contract.sh`、`tests/install-contract.sh`、`scripts/check-all.sh`，并核对 source/dist 关键规则同步。

## 风险与用户决策

主要风险是专属门名同步遗漏，以及命名子集被误解为可拆分写入；通过模式块精确契约和原子单元定义缓解。需要用户确认是否采用方案一；未确认前不创建 Repair Plan 或修改源码。
