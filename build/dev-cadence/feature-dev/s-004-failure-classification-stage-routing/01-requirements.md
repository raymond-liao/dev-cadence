# S-004 实施与测试失败分类和阶段返回 - 需求确认

## 需求来源

- 工作项：[S-004 实施与测试失败分类和阶段返回](../../../../docs/delivery/stories/S-004-failure-classification-stage-routing.md)
- 工作项路径：`docs/stories/S-004-failure-classification-stage-routing.md`
- 工作项版本：`1`
- 前置工作：[S-003 实施前方案新鲜度门禁](../../../../docs/delivery/stories/S-003-implementation-design-freshness-gate.md)
- Backlog：[当前可并行实施表](../../../../docs/delivery/backlog.md#当前可并行实施表)

## ✅ 确认范围

- 为 feature-dev、bug-fix 和 refactor 定义同一稳定分类值域：`implementation_bug`、`test_bug`、`environment_issue`、`unclear_requirement`、`design_conflict`、`architecture_conflict`、`missing_dependency`。
- 触发范围覆盖实施、编译或构建、自动测试、回归验证和实现阶段 code review 的阻塞问题。
- 每个失败使用稳定 ID，并记录证据、分类依据、处理轮次、返回目标和处理结果；重新分类和重跑继续沿用可追踪身份。
- 实现缺陷返回对应 Implementation；需求不清返回最早需求或诊断阶段；设计与架构冲突返回对应 Solution，架构冲突还必须重评相关 Architecture 和 Decision。
- 测试缺陷进入测试资产修正步骤，不得删除、跳过或削弱有效测试来掩盖实现失败。
- 环境问题保持当前业务阶段并记录可重复证据与解除条件，不得伪装成实现失败、测试通过或 `ready`。
- 缺失依赖返回能够解决依赖的最早阶段；当前任务无法解决时阻塞 run 并记录解除条件。
- 没有新增证据、修正动作或环境变化时，不得原样重试同一失败。
- 修正后重新执行与失败 ID 对应的检查，并记录 `closed`、`reclassified` 或 `blocked` 结果。
- 返回早期阶段时复用 S-003 的回退语义：最早受影响阶段设为 `in_progress`，后续受影响阶段设为 `pending`，失效证据标记为 `superseded`，刷新并重新确认后才能继续。

## ❌ 非目标

- 不规定固定的全局最大重试次数。
- 不替代 systematic-debugging、TDD、code review 或 verification-before-completion 的具体方法。
- 不实现 CI 平台、测试框架或环境自动修复。
- 不处理 Business Acceptance 决策、Completion 集成选择或未关闭风险向后续阶段的完整传递。
- 不允许仅根据失败表象、没有可检查证据地分类。

## 验收标准

1. 三个 workflow 使用完全相同的七个 canonical 分类值，并只在阶段名称映射上保留 workflow 差异。
2. 实施、review、System Testing 或 Regression Verification 的阻塞失败都进入统一的分类、记录和路由流程。
3. 失败记录至少包含稳定 ID、证据、分类依据、轮次、返回目标和结果。
4. 每个分类都有明确的返回、保持当前阶段或阻塞行为，并与 S-003 的回退与 `superseded` 规则一致。
5. `test_bug` 规则明确禁止通过删除、跳过或削弱有效测试消除实现失败。
6. `environment_issue` 和当前任务无法解决的 `missing_dependency` 不会产生虚假的 passed、failed 或 ready 结论。
7. 重试前必须存在新增证据、修正动作或环境变化；重跑后记录 `closed`、`reclassified` 或 `blocked`。
8. validated 且阻塞的 review finding 创建或关联 failure ID，并保留来源 finding ID；非阻塞 finding 继续使用既有 review 证据模型。
9. 对称契约测试验证分类值域、路由、记录字段、重试门禁和重跑结果，现有 Verification Decision Gate 契约继续通过。

## 待确认假设

- 完整 failure record 由触发失败的阶段记录保存；manifest 只保存当前阻塞或阶段返回摘要，避免双份 ledger 漂移。
- 失败结果使用固定值 `closed`、`reclassified`、`blocked`。
- `environment_issue` 不回退阶段；当前 stage 设为 `blocked`，overall status 保持 `in_progress`，解除后在同一阶段重跑。
- `test_bug` 的测试资产所有者不在当前任务控制范围时，分类仍为 `test_bug`，并记录外部 owner 与解除条件；不改写为 `missing_dependency`。
- `missing_dependency` 根据受影响决策返回最早可解决阶段：需求依赖返回需求/诊断，方案依赖返回 Solution，执行依赖返回 Plan 或 Implementation。
- `architecture_conflict` 指 Architecture、Decision 或跨模块约束失效；其他已确认局部方案冲突归 `design_conflict`。
- 只有 validated 且阻塞的 review finding 进入 failure lifecycle，并通过 source finding ID 关联，避免重复身份。
- Story 中的统一最大恢复轮次问题保留为后续工作，本任务不作默认限制。

## 探索模式

采用 Enhanced Exploration。技术方案需要分别核对三个 workflow 的阶段与记录映射、S-003 与 Verification Decision Gate 的状态回退、契约测试结构三个视角。
