# S-003 实施前方案新鲜度门禁

## 基本信息

- ID：`S-003`
- Version：`2`
- Status：`Done`
- Priority：`P1`
- Change Type：Enhancement

## 目标

让开发 workflow 在进入实现前重新验证已确认方案和实施计划仍与当前需求、决策及代码现实一致，避免代理根据已经过期的假设继续修改代码。

## 背景

Requirements、Technical Solution 和 Implementation Plan 得到确认后，工作项、产品设计、依赖、代码结构或接口仍可能发生变化。当前 workflow 能在用户主动提出变更时返回最早受影响阶段，但缺少进入实现前的统一新鲜度检查，无法系统识别会话中断、并行修改或仓库状态变化造成的方案失效。

## User Story

作为依赖 AI 完成软件交付的用户，我希望代理在开始实现前确认既有方案仍然有效，以便交付不会建立在已经失效的需求或代码假设上。

## 范围

- 为 `feature-dev`、`bug-fix` 和 `refactor` 增加对称的实施前方案新鲜度门禁。
- 在进入 Development Implementation、Repair Implementation 或 Refactor Implementation 前执行检查。
- 对比当前工作项卡片版本、已确认需求或诊断记录、方案记录、实施计划和当前代码状态。
- 在目标仓库存在产品设计、架构、Decision、依赖状态或其他权威资料时，检查其变化是否影响当前方案。
- 识别卡片版本变化、范围变化、已接受决策变化、关键依赖变化、计划文件或接口假设失效、代码结构显著偏离方案等过期信号。
- 在 manifest 和当前阶段记录中保存本次检查使用的输入身份、检查结果和证据摘要。
- 方案仍有效时继续实现，不要求用户重复确认未变化内容。
- 需求、范围或验收标准变化时，返回 Requirements Confirmation、Problem Diagnosis 或对应最早业务阶段。
- 架构、数据、接口、安全或修复策略假设失效时，返回 Technical Solution、Repair Solution 或 Refactor Solution。
- 只有任务拆分、文件清单、顺序或验证步骤失效时，返回 Implementation Plan、Repair Plan 或 Refactor Plan。
- 返回早期阶段后，将受影响的后续确认和验证证据标记为 superseded，完成更新和重新确认后才允许再次进入实现。

## 非范围

- 不要求每次实现前重新执行完整 Requirements 或 Technical Solution。
- 不因为无关代码变化或格式变化使方案失效。
- 不在本 Story 中实现工作项卡片创建或产品设计版本治理。
- 不替代实施后的代码审查和 System Testing。
- 不处理最终验证结果与精确 commit 绑定；该能力由现有独立 backlog 任务负责。

## 验收标准

1. 三个开发 workflow 在进入实现前执行结构对称的方案新鲜度检查。
2. 检查至少覆盖当前卡片版本、已确认阶段记录、实施计划和相关代码现实。
3. 权威产品设计、架构、Decision 或依赖变化存在时，workflow 能判断其是否使当前方案失效。
4. 检查通过时 workflow 直接继续实现，不制造无意义的重复用户确认。
5. 需求、方案或计划分别失效时，workflow 返回正确的最早受影响阶段，而不是继续实现或一律返回 Requirements。
6. 返回早期阶段后，所有受影响的后续证据被明确标记为 superseded，并在重新确认前阻止实现。
7. manifest 或阶段记录能够说明检查使用的输入、结论和主要依据。
8. 无关仓库变化不会错误阻止实现。
9. 契约测试对称验证 `feature-dev`、`bug-fix` 和 `refactor` 的门禁和返回规则。

## Story Relationships

- Precedes：`S-004` 实施与测试失败分类和阶段返回。
- Related：工作项卡片与现有开发 workflow 接入任务。

## 依赖

- 无硬性前置 Story。
- 工作项卡片接入完成后，可使用更稳定的卡片版本身份增强检查证据。

## 后续工作

- `S-004` 使用明确的方案冲突分类返回相应方案阶段。
- 最终验证版本绑定任务负责验证结果与精确 commit 的时效性。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)
- [功能开发流程](../workflows/feature-dev.md)
- [Bug 修复流程](../workflows/bug-fix.md)
- [重构流程](../workflows/refactor.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建实施前方案新鲜度门禁 Story。 | 防止开发 workflow 根据已经被需求、决策或代码现实淘汰的方案继续实施。 |
| 2 | 2026-07-14 | 完成实施前方案新鲜度门禁并通过业务验收。 | 三个 Delivery workflow、对称契约和安装包已验证完成。 |
