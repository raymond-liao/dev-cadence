# S-007 Workflow 入口路由示例

## 基本信息

- ID：`S-007`
- Version：`3`
- Status：`Ready`
- Priority：`P1`
- Change Type：Enhancement

## 目标

让 `using-dev-cadence` 使用少量代表性请求示例解释各 workflow 的触发边界，帮助代理在执行 1% 适用性检查后稳定选择、排除或澄清候选 workflow，同时避免在每个具体 skill 中重复维护完整路由规则。

## 背景

当前入口选择器已经要求：只要有 1% 的可能某个 Dev Cadence flow 适用，就必须读取候选 skill；读取后再根据明确匹配、歧义或不匹配决定使用 workflow、询问一个澄清问题或正常处理。这一两阶段机制能够避免代理过早跳过 workflow。

但现有入口主要使用“广泛产品想法”“明确 Feature”“预期行为异常”等抽象描述，缺少少量可直接映射用户表达的代表性例子。仅靠抽象定义可能使首次 Discovery、增量 Discovery、Feature、Bug 和 Refactor 的边界解释不稳定。另一方面，把完整示例矩阵复制到每个 workflow skill 会造成重复、文档膨胀和规则漂移。

## User Story

作为使用 Dev Cadence 发起不同类型软件工作的用户，我希望代理能够根据我的实际表达稳定选择正确流程，以便请求不会因为抽象术语理解差异而进入错误 workflow。

## ✅ 范围

- 保持 `using-dev-cadence` 为跨 workflow 选择和优先级的唯一权威来源。
- 保留“1% 可能适用时先读取候选 skill”的检查规则，并明确它不等于自动启动该 workflow。
- 明确两阶段判断：先发现并读取候选 workflow，再决定使用、改选、澄清或正常处理。
- 在 `using-dev-cadence` 中增加简短的代表性请求表，至少覆盖首次 Discovery、增量 Discovery、Feature、Bug、Refactor 和不适用 Dev Cadence 的普通请求。
- 每类代表性请求说明预期决定和关键原因，不只列关键词。
- 代表性请求使用易扫描的视觉标识：`✅` 表示适用或应选择的 workflow，`❌` 表示不适用或不应选择的 workflow，`❓` 表示信息不足、需要一个路由澄清问题；标识必须同时配合简短文字原因，不能只依赖颜色或 emoji 传达语义。
- 增加容易混淆的边界例子，包括首次建立与更新已有产品设计、缺少 PRD 与用户产品探索意图、Bug 与预期行为变更、Feature 与保持行为不变的重构。
- 明确仓库状态不能单独触发 workflow；缺少 PRD、存在代码、存在卡片或存在测试本身都必须结合用户意图判断。
- 对无法根据当前请求确定主目标的情况，继续只问一个必要的路由澄清问题。
- 具体 workflow skill 只保留其自身适用条件、停止条件和确有必要的局部 Red Flags，不要求复制全局示例矩阵。
- 新增 workflow 时，评审其是否需要在入口代表性请求表或相邻边界中增加一条示例；没有实际歧义时不强制增加。
- 更新契约测试，验证入口包含两阶段语义、所有已安装 workflow 的代表性覆盖和关键边界类别，但不锁死完整自然语言句子。

## ❌ 非范围

- 不因为请求与软件相关就强制启动某个 workflow。
- 不把 1% 检查规则改成 1% 可能适用即执行 workflow。
- 不为每个 workflow 建立重复的完整 Trigger Contract 或示例矩阵。
- 不通过大量关键词枚举替代语义判断。
- 不在本 Story 中实现新的业务 workflow。
- 不在本 Story 中实现 S-002 增量 Discovery 或 S-005 Open Question Registry。

## 验收标准

1. `using-dev-cadence` 明确区分“候选 skill 检查”和“workflow 正式选择”两个阶段。
2. 1% 规则只要求发现并读取可能适用的候选 skill，不会被解释成自动启动 workflow。
3. 入口包含首次 Discovery、增量 Discovery、Feature、Bug、Refactor 和普通非 workflow 请求的代表性例子。
4. 正例、反例和歧义例分别使用 `✅`、`❌` 和 `❓` 标识，并同时提供文字决定与原因，便于扫描且不只依赖视觉符号。
5. 示例能区分首次建立与更新产品设计、缺少文档与产品探索意图、缺陷修复与预期行为变更、功能开发与行为保持重构。
6. 仓库状态不会在缺少相应用户意图时单独触发 workflow。
7. 歧义请求只触发一个必要的路由澄清问题，不被代理任意归类。
8. 各具体 workflow 不需要复制入口的完整示例矩阵，只保留自身局部边界。
9. 契约测试验证两阶段规则、三类视觉标识、已安装 workflow 覆盖和关键边界类别，同时避免锁死整段自然语言措辞。

## Story Relationships

- Follows：`S-008` Skill 语义视觉规范。
- Precedes：`S-005` 全局 Open Question Registry。
- Related：`S-002` 产品设计基线增量更新与版本治理、`S-006` Discovery 产品与技术内容边界。

## 依赖

- `S-008` Skill 语义视觉规范。

## 后续工作

- S-005 在入口中增加 Registry 的直接请求路由时，沿用本 Story 的集中路由和代表性示例规则。
- S-002 实现后，将增量 Discovery 的当前占位边界更新为可执行路由。

## Open Questions

- 无。

## 相关文档

- [S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)
- [S-005 全局 Open Question Registry](S-005-open-question-registry.md)
- [S-006 Discovery 产品与技术内容边界](S-006-discovery-product-technical-content-boundary.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 Workflow 入口路由示例 Story。 | 用集中、有限的代表性示例补足抽象路由规则，同时保留 1% 候选检查与正式 workflow 选择的两阶段语义。 |
| 2 | 2026-07-14 | 增加正例、反例和歧义例的 emoji 标识规则。 | 路由示例需要便于快速扫描，同时保留文字原因以避免只依赖视觉符号表达语义。 |
| 3 | 2026-07-14 | 增加对统一 Skill 语义视觉规范的依赖。 | 路由示例应复用共享 emoji 语义，而不是在 S-007 中独立定义视觉语言。 |
