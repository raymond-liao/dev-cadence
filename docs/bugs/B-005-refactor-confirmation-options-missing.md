# B-005 Refactor 确认阶段未提供用户选项

## 基本信息

- ID：`B-005`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Bug

## 问题目标

修复 Refactor workflow 在需要用户确认的阶段未提供明确、可选择的确认选项，导致用户无法直接判断可用决策及其后果的问题。

## 预期行为

当 Refactor workflow 到达 Requirements Confirmation、Refactor Solution、Refactor Plan 或其他需要用户确认的阶段时，用户可见摘要必须提供明确的决策选项，例如确认继续、要求修改或拒绝，并说明每个选项对 workflow 下一步的影响。

## 已观察行为

用户观察到执行 Refactor workflow 时遇到确认门禁，但提示没有提供可直接选择的选项。当前卡片尚未完成逐阶段复现和根因诊断。

## ✅ 范围

- 检查 Refactor workflow 的所有用户确认门禁及其用户可见提示。
- 明确确认、修改、拒绝或接受风险等实际支持的决策路径。
- 让选项与 workflow 的状态转移、记录更新和下一阶段行为一致。
- 为每个确认门禁增加最小回归检查，防止提示缺少选项或选项与实际行为不一致。

## ❌ 非范围

- 不取消任何已有用户确认门禁。
- 不擅自增加新的 workflow 状态或阶段。
- 不改变 Refactor 的结构目标、实现规则或验收标准。
- 不把确认选项扩散到不需要用户决策的普通进度摘要。

## 验收标准

1. 每个需要用户确认的 Refactor 阶段都显示明确的可选决策及其结果。
2. 用户选择确认、修改或拒绝后，workflow 按对应规则进入正确状态或返回正确阶段。
3. 选项不会声称支持尚未实现的行为；每个选项都有对应的记录和状态处理。
4. 回归检查覆盖至少 Requirements Confirmation、Refactor Solution 和 Refactor Plan 三类确认门禁。

## 已知复现条件

- 执行 Refactor workflow 并到达需要用户确认的阶段。
- 用户可见提示没有提供编号选项或等价的明确决策集合。
- 具体失效阶段、提示来源和状态处理待 Problem Diagnosis 阶段确认。

## 依赖

- 无强制前置依赖。

## Open Questions

- 哪些 Refactor 确认门禁缺少选项，是否所有门禁表现一致？
- 当前提示由 workflow skill、运行时模板还是会话层生成？
- 确认选项是否已经存在于规则文本但没有被用户可见摘要呈现？

## 相关文档

- [Backlog](../backlog.md)
- [Refactor 流程](../workflows/refactor.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-16 | 创建 Refactor 确认阶段缺少用户选项 Bug。 | 记录确认门禁未提供可选择决策的问题，等待诊断。 |
