# S-006 Discovery 产品与技术内容边界

## 基本信息

- ID：`S-006`
- Version：`1`
- Status：`Done`
- Priority：`P1`
- Change Type：Enhancement

## 目标

让 Discovery 在接收包含技术讨论的需求输入时，准确区分产品要求、业务架构内容和实现建议，确保 PRD 与 Business Architecture 不混入技术方案，同时不丢失可能影响后续设计的技术信息。

## 背景

用户在分析产品需求时经常同时提到技术方向，例如数据库、框架、协议、接口、部署方式或算法。这些信息可能是外部强制约束，也可能只是未经评估的实现建议。当前 Discovery 已声明不设计技术架构，但缺少可执行的分类、承载和移交规则，代理仍可能把具体实现方案写入 PRD，或者为了保持产品文档纯粹而丢弃用户提供的技术上下文。

产品设计文档应描述产品为什么存在、为谁服务、需要产生什么结果以及业务如何运作。技术方案应在相关工作项的技术设计阶段基于产品要求和代码现实进行评估，不能因为在需求讨论中被提到就成为产品基线的一部分。

## User Story

作为使用产品设计文档指导后续交付的用户，我希望产品要求与实现建议被清楚分开，以便 PRD 保持稳定和可理解，同时后续技术设计仍能获得有价值的输入。

## ✅ 范围

- 为 Discovery 的首次创建和增量更新模式定义共同的产品、业务与技术内容边界。
- PRD 只保存产品目标、用户和相关方、价值、成功标准、范围、产品能力、产品需求、用户可感知结果、非功能要求、产品约束、假设和外部依赖。
- Business Architecture 只保存业务角色、业务域、业务能力、价值流、流程、业务对象、状态、业务规则、业务事件、异常和外部业务边界。
- PRD 和 Business Architecture 不保存具体代码模块、服务拆分、数据库产品、框架、库、API 路径、请求响应结构、协议选择、算法、基础设施、部署拓扑、重试或超时实现参数、测试实现、Mock 方案或运维实现步骤。
- 对用户在需求讨论中提到的技术内容进行来源忠实的分类，不因为具体技术名词出现就自动视为已确认方案。
- 区分外部或产品级约束与实现建议：约束描述必须满足的结果或边界，实现建议描述达到结果的候选机制。
- 数据地域、法规限制、兼容要求、可测量的性能目标、可用性目标和用户可感知安全要求等产品约束可以写入 PRD，但不得同时选择未经确认的实现机制。
- 数据库、框架、协议、云服务、模块划分、接口形状和部署方式等候选实现不写入 PRD 或 Business Architecture。
- 明确属于后续技术设计、且已有对应 Story、Technical Task、技术方案或 Decision 文档的内容，写入或引用该权威文档。
- 暂时没有合适权威文档承载、但不应丢失的技术问题或实现建议，通过 `S-005` 提供的 Open Question Registry 登记。
- PRD 和 Business Architecture 自身范围内尚未解决的问题继续保存在各自的 `Open Questions`，不因为全局 Registry 而迁出。
- Discovery 的最终确认摘要说明哪些技术输入被排除在产品设计基线之外、其当前承载位置以及后续应在哪个阶段评估。
- 对技术输入的转移、登记或排除不得被描述为用户已经接受的技术决策。
- 首次 Discovery 创建产品文档前执行内容边界检查，防止技术方案进入初始基线。
- 增量 Discovery 更新已有文档时识别新输入中的技术方案内容；已有基线中历史遗留的混合内容由 S-002 的协调和用户确认规则处理，不静默删除或迁移。
- 为内容分类、产品约束与实现机制区分、Registry 移交和产品文档禁止内容增加契约验证。

## ❌ 非范围

- 不在 Discovery 中评估或确认具体技术方案。
- 不创建系统架构、API Contract、数据库设计、部署设计或测试方案文档。
- 不自动创建 Feature、Story、Bug 或 Technical Task。
- 不把所有非功能需求都视为技术方案；可验证的产品级质量要求仍属于 PRD。
- 不在本 Story 中实现 Open Question Registry；该能力由 S-005 负责。
- 不在本 Story 中实现已有产品设计文档的发现、迁移、独立升版或 Change Log 协调；这些能力由 S-002 负责。

## 验收标准

1. Discovery 对首次创建和增量更新使用一致的产品、业务与技术内容边界。
2. PRD 能保存产品结果、产品约束和可验证的非功能要求，但不会保存达到这些结果的具体实现机制。
3. Business Architecture 能保存业务运作模型，但不会保存软件模块、数据库、协议、基础设施或部署设计。
4. 用户提到具体技术产品或实现方式时，workflow 不会自动把它升级为已确认产品要求或技术决策。
5. 外部强制约束和产品级质量目标能够与数据库、框架、协议、算法等候选实现明确区分。
6. 已有明确权威文档的技术输入被写入或关联到该文档；没有合适承载位置的技术输入通过 S-005 Registry 保存。
7. PRD 和 Business Architecture 各自范围内的未解决产品或业务问题仍保留在对应文档中。
8. Discovery 最终确认摘要能说明被排除在产品基线之外的技术输入、承载位置和建议解决阶段。
9. 初始产品设计基线不会包含具体 API、数据库、框架、协议、部署或测试实现方案。
10. 增量更新不会静默删除已有文档中的技术内容，而是遵守 S-002 的权威来源、迁移和用户确认规则。
11. 契约测试覆盖内容边界、分类规则、产品约束例外、Registry 移交和产品文档禁止内容。

## Story Relationships

- Follows：`S-005` 全局 Open Question Registry。
- Precedes：`S-002` 产品设计基线增量更新与版本治理。
- Extends：`S-001` 首次 Discovery 与产品设计基线。

## 依赖

- `S-005` 全局 Open Question Registry。

## 后续工作

- S-002 使用本 Story 的内容边界检查增量输入，并在用户确认后协调已有混合内容。
- Work Item Planning 和开发 workflow 读取被移交的技术问题，在对应工作项或技术方案阶段进行评估。

## Open Questions

- 无。

## 相关文档

- [需求探索流程](../../workflows/discovery.md)
- [S-001 首次 Discovery 与产品设计基线](S-001-initial-discovery-prd-baseline.md)
- [S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)
- [S-005 全局 Open Question Registry](S-005-open-question-registry.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Discovery 产品与技术内容边界 Story。 | 防止技术方案混入产品设计基线，同时保留用户在需求讨论中提供的有价值技术输入。 |
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 完成 Discovery 内容分类、产品约束例外、技术输入移交、基线检查与契约验证。 | S-006 的 11 项验收标准已实现，S-012 可进入实施。 Legacy migration: original Version 2; normalized to Version 1. |
| 1 | legacy: recorded-at precision unknown; original 2026-07-15 | legacy: recorded-by unknown | 将状态从 Done 修正为 In Progress。 | 实现与系统测试已完成，但批量执行授权不构成 Business Acceptance。 Legacy migration: original Version 3; normalized to Version 1. |
| 1 | legacy: recorded-at precision unknown; original 2026-07-15 | legacy: recorded-by unknown | 记录 Business Acceptance 并将状态更新为 Done。 | 用户选择 `1. Accept`，S-006 交付结果已验收。 Legacy migration: original Version 4; normalized to Version 1. |
| 1 | 2026-07-19T13:07:24+0800 | Raymond Liao <raymond-liao@outlook.com> | Normalized legacy status and delivery events to reuse the active definition Version. | Old current 4 -> new current 1; original row versions 1,2,3,4 -> normalized row versions 1,1,1,1. |
