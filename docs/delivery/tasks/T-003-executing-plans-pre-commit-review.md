# T-003 Executing-Plans 实施提交前审查

## 基本信息

- ID：`T-003`
- Version：`1`
- Status：`Done`
- Priority：`P1`
- Change Type：Workflow Governance

## 任务目标

为 `executing-plans` 路径下的每个实施提交建立提交前审查和提交身份验证机制，确保实际提交与已审查的 staged snapshot 一致。

## 背景

实施提交如果只在提交后审查，或无法证明 commit parent 与 tree 对应审查时的状态，就可能遗漏未审查改动。Feature、Bug Fix 和 Refactor 需要对称的提交前门禁，同时不能把阶段 checkpoint 当作实施提交。

## ✅ 范围

- 在三个开发 workflow 中增加 `Executing-Plans Pre-Commit Review` 契约。
- 记录 implementation base、review unit、Expected parent、Reviewed tree 和提交后身份。
- 在提交前审查完整 staged diff，并在提交前后验证 parent 与 tree。
- 支持 progress、plan-task、final-review-fix 和 recovery-fix 单元。
- 区分实施提交、阶段 checkpoint 和无法分类的提交。
- 使用对称契约测试保护三个 workflow 的规则。

## ❌ 非范围

- 不改变 subagent-driven-development 的任务提交审查模式。
- 不把阶段 checkpoint 纳入实施提交 ledger。
- 不通过 amend 或改写历史伪造提交前证据。

## 完成条件

1. 三个 workflow 在 executing-plans 路径下都要求提交前审查完整 staged snapshot。
2. 实际提交的 parent 和 tree 能与审查证据进行精确或追溯验证。
3. 发现身份不一致时停止后续普通实施提交并进入恢复处理。
4. 对称契约测试覆盖提交类型、ledger、身份和最终整体审查。

## 依赖

- 无强制前置依赖。

## 历史交付证据

- Implementation Commit：`804fe8e03186eaf00f67db8b8026050ac85afca0`。
- 主要修改：`src/skills/feature-dev/SKILL.md`、`src/skills/bug-fix/SKILL.md`、`src/skills/refactor/SKILL.md`。
- 验证契约：`tests/workflow-symmetry.sh`。
- 版本在该提交中完成更新。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 根据既有实现和 Git 历史补录已完成 Technical Task。 | 原工作已在 `804fe8e` 完成交付，但 Backlog 仅保留纯文本完成项。 |
