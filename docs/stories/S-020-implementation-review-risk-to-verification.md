# S-020 实施与 Review 风险传递到验证阶段

## 基本信息

- ID：`S-020`
- Version：`1`
- Status：`Draft`
- Priority：`P2`
- Change Type：Feature

## 目标

使用稳定 ID 将跳过的实施检查、未解决 review finding 和已接受 review 风险完整写入最终验证报告。

## 背景

实施和 Review 阶段产生的风险如果只保存在原阶段记录中，最终验证可能错误地按无已知风险执行和汇报。

## ✅ 范围

- 为跳过检查、未解决 finding 和已接受风险保留稳定 ID。
- 将这些 ID 及其状态传递到最终验证输入与报告。
- 记录验证对每项风险执行的检查和剩余结论。
- 对三个开发 workflow 建立对称契约。

## ❌ 非范围

- 不自动关闭 review finding。
- 不把风险传递等同于风险已被接受。
- 不在本 Story 中处理验证风险到业务验收的下一跳。

## 验收标准

1. 实施和 Review 的未闭环风险不会在进入验证时丢失。
2. 最终验证报告可按稳定 ID 追溯风险来源和当前状态。
3. 跳过检查明确影响验证结论或剩余风险。

## 依赖

- 实施和 Review 记录需提供稳定风险身份。

## Open Questions

- Q-010：不同阶段的风险 ID 是否共享统一命名空间？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建实施与 Review 风险传递 Story。 | 防止已知风险在最终验证前断链。 |
