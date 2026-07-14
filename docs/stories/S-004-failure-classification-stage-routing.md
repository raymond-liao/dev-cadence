# S-004 实施与测试失败分类和阶段返回

## 基本信息

- ID：`S-004`
- Version：`1`
- Status：`Ready`
- Priority：`P2`
- Change Type：Enhancement

## 目标

让开发 workflow 对实施、构建和测试失败使用统一分类，并根据根因返回正确阶段，避免所有失败都被当作代码问题反复交给实现阶段处理。

## 背景

一次失败可能来自实现缺陷、测试本身、环境、需求不清、方案冲突、架构冲突或缺失依赖。当前 workflow 要求记录检查和返工，但没有为这些失败提供跨 workflow 一致的分类与路由规则，代理可能无差别重试、修改有效测试，或在需要重新确认需求和方案时继续修代码。

## User Story

作为审阅 AI 交付过程的用户，我希望失败能够根据真实原因返回正确处理阶段，以便每轮返工都解决根因，而不是重复尝试或引入新的错误。

## 范围

- 为 `feature-dev`、`bug-fix` 和 `refactor` 定义对称的失败分类与阶段返回规则。
- 覆盖实施、编译或构建、自动测试、回归验证和实现阶段 review 发现的阻塞问题。
- 使用稳定分类：`implementation_bug`、`test_bug`、`environment_issue`、`unclear_requirement`、`design_conflict`、`architecture_conflict` 和 `missing_dependency`。
- 为每个失败分配稳定 ID，并记录失败证据、分类依据、当前轮次、返回目标和处理结果。
- `implementation_bug` 返回对应 Implementation 阶段。
- `test_bug` 返回测试资产所有者或当前 Implementation 阶段中的测试修正步骤，不允许通过削弱有效测试解决。
- `unclear_requirement` 返回 Requirements Confirmation、Problem Diagnosis 或对应最早需求阶段。
- `design_conflict` 返回 Technical Solution、Repair Solution 或 Refactor Solution。
- `architecture_conflict` 返回对应 Solution 阶段，并要求重新评估相关架构和 Decision。
- `environment_issue` 保持当前业务阶段，记录环境阻塞和可重复证据；不得伪装为实现通过或失败。
- `missing_dependency` 返回能够解决依赖的最早阶段；无法在当前任务解决时将 run 标记为 blocked 并说明解除条件。
- 同一失败在没有新增证据、修正或环境变化时不得原样重试。
- 修正后重新运行与失败 ID 对应的检查，并记录该失败是否关闭、重新分类或仍然阻塞。

## 非范围

- 不在本 Story 中规定固定的全局最大重试次数。
- 不替代 `systematic-debugging`、TDD、code review 或 verification-before-completion 的具体方法。
- 不实现 CI 平台、测试框架或环境自动修复。
- 不处理 Business Acceptance 决策和 Completion 集成选择。
- 不允许代理仅根据失败表象分类；分类必须引用可检查证据。

## 验收标准

1. 三个开发 workflow 使用同一组稳定失败分类和值域。
2. 每种分类都有明确的业务阶段返回目标或阻塞处理方式。
3. 每个失败记录稳定 ID、证据、分类依据、轮次、返回目标和最终结果。
4. 实现缺陷返回 Implementation，需求不清返回最早需求阶段，方案或架构冲突返回对应 Solution 阶段。
5. 测试缺陷能够被修正，但 workflow 不允许删除、跳过或削弱有效测试来消除实现失败。
6. 环境问题与缺失依赖不会被错误记录成实现失败、测试通过或 ready 结论。
7. 没有新证据或状态变化时，workflow 不会原样重复同一失败处理。
8. 修正后重新执行与失败 ID 对应的检查，并记录关闭、重新分类或持续阻塞结果。
9. 契约测试对称验证三个 workflow 的分类值、返回规则和记录要求。

## Story Relationships

- Follows：`S-003` 实施前方案新鲜度门禁。
- Related：实施风险传递、Review 风险传递和最小验证阶段门禁任务。

## 依赖

- 无硬性前置 Story。
- 建议在 `S-003` 之后实施，以复用方案失效与返回早期阶段的统一语义。

## 后续工作

- 端到端验证任务覆盖失败分类在开发、测试、验证和返工链路中的传递。
- 风险传递任务负责将未关闭失败和已接受风险传递到 System Testing 与 Business Acceptance。

## Open Questions

- 是否需要在后续 Story 中为连续失败设置统一最大恢复轮次，还是由各 workflow 根据风险和失败类型决定？

## 相关文档

- [Backlog](../backlog.md)
- [功能开发流程](../workflows/feature-dev.md)
- [Bug 修复流程](../workflows/bug-fix.md)
- [重构流程](../workflows/refactor.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建实施与测试失败分类和阶段返回 Story。 | 让返工根据失败根因返回正确阶段，并阻止无差别重试或削弱有效测试。 |
