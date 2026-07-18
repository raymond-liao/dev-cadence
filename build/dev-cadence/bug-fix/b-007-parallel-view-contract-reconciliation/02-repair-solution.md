# B-007 修复方案（设计对齐）

## ✅ Selected

把 B-007 的预期行为、范围、验收标准和 Open Questions 对齐到 B-009：并行视图保持四列；`状态` 只表示卡片生命周期；表级说明明确该视图不拥有 Workflow 入口资格；具体路由由 `using-dev-cadence` 和对应 workflow skill 负责。

## 修复边界

- 更新 B-007 卡片 Version `1 -> 2` 和 Change Log。
- 同步 `docs/backlog.md` 中 B-007 的版本引用。
- 不恢复“下一步 Workflow / 入口门禁”列，不改并行排序，不修改 workflow skill。

## 验收标准

1. B-007 卡片不再要求逐行路由列。
2. 卡片明确状态、依赖和 Workflow 路由由不同权威来源负责。
3. 现有 `tests/parallel-work-table-contract.sh` 继续通过，并明确禁止恢复路由列。
4. B-007 的 Open Question 记录为已解决，不再保持未决。

## 风险

这是规划资产对齐，不改变运行时行为。主要风险是误恢复 B-009 已移除的列，现有契约测试会阻止该回归。
