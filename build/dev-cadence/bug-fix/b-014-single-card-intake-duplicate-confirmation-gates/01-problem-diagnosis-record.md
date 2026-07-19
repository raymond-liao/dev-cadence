# B-014 问题诊断记录

- Workflow: `bug-fix`
- Work Item: [B-014 单项建卡被错误套用双确认门](../../../../docs/bugs/B-014-single-card-intake-duplicate-confirmation-gates.md)
- Card path: `docs/bugs/B-014-single-card-intake-duplicate-confirmation-gates.md`
- Work-item type: `Bug`
- Card Version: `1`
- Visible Status: `In Progress`
- Selected scope: 修正 `direct intake` 对共享双确认门的错误继承，保留 `portfolio planning` 双确认门
- Status: 🔄 `in_progress`
- Branch: `codex/parallel-b012-b010-b014`
- Diagnosis date: `2026-07-19`

## 报告症状

已经明确目标与范围的单张 Story、Task 或 Bug 建卡请求，在必要澄清之外仍先进入 `Planning Inputs And Scope Confirmation`，随后又进入 `Planning Result Confirmation`，重复确认用户已经表达清楚的输入与范围。

## 期望行为

`direct intake` 在必要澄清完成后只经过一次正式确认。该确认一次展示完整卡片、ID、路径、Priority、关系和 Backlog 位置，用户确认后原子写入卡片及必要规划引用。`portfolio planning` 继续保留输入范围确认和规划结果确认两道门。

## 实际行为

`src/skills/work-item-planning/SKILL.md` 先区分 `portfolio planning` 与 `direct intake`，但随后对两种模式无条件应用同一个三阶段序列，并分别把输入范围确认和结果确认定义为真实决策门。Direct Intake 只限制资产修改范围，没有自己的阶段或门禁分支。

## 复现与证据

1. 读取 `src/skills/work-item-planning/SKILL.md` 第 36-39 行，确认 skill 支持两种模式。
2. 读取第 143-152 行，确认 Direct Intake 只定义资产边界，没有定义单独确认流程。
3. 读取第 154-160 行，确认两个模式之后存在无条件共享的三阶段序列。
4. 读取第 176-177 行，确认 `Planning Inputs And Scope Confirmation` 与 `Planning Result Confirmation` 都是正式决策门。
5. 运行 `bash tests/work-item-planning-contract.sh` 和 `bash tests/confirmation-gates-contract.sh`。现有测试通过，但前者只分别检查模式和三个阶段字符串存在，后者只检查结果确认门存在，没有验证模式与门禁数量的对应关系。

当前主线程实际运行的相关基线检查中，`tests/work-item-planning-contract.sh` 通过，证明现有契约无法识别 Direct Intake 错误继承双确认门。

## 影响范围

- 所有明确单卡 Direct Intake，包括 Story、Task 和 Bug。
- `src/skills/work-item-planning/SKILL.md` 及其构建生成的分发包和安装副本。
- `docs/workflows/work-item-planning.md` 中同时描述组合规划与单项登记的共享阶段说明。
- 相关 Work Item Planning 与确认门契约测试。

不影响 Portfolio Planning 应保留的双确认门，不涉及 Work Item Analysis、Delivery Workflow、Business Acceptance 或历史卡片改写。现有结果确认后的原子写入规则本身没有失效证据。

## 根因与置信度

根因已确认：模式选择与阶段序列没有建立显式分支。Direct Intake 虽被定义为独立模式，但共享 Stage Sequence 和 Confirmation Gate Presentation 无条件套用于两种模式；测试只验证词句存在，没有验证 Direct Intake 仅有一个正式门、Portfolio Planning 仍有两个正式门。

置信度：高。

## 未决问题与假设

- 无阻塞性业务问题。
- 修复方案阶段需要选择 Direct Intake 合并门的正式名称，并保证“只确认命名子集”不会拆散卡片与必要 Backlog 引用的原子一致性单元。
- 本诊断不选择具体修复方案，也不修改源码或测试。
