# 需求探索流程

本文说明 Dev Cadence 的 `discovery` 业务流程，包括适用场景、阶段目标、主要产出以及与其他 workflow 的边界。本文面向 Dev Cadence 维护者、流程评审者和希望了解产品需求治理模型的使用者。

目标仓库中的实际执行规则由 `src/workflows/discovery/SKILL.md` 定义并生成安装内容。本文用于说明业务流程设计，不替代 workflow skill。

## 目的

需求探索流程用于把不完整的想法、反馈、业务问题或产品方向整理成经过用户确认的第一版产品设计基线。完整性是探索过程逐步形成的结果，不是输入前提。

完整产品设计基线由三份权威文档组成：

```text
docs/product-design/user-journey.md
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

User Journey 先定义产品支持的一条稳定业务线，包括业务阶段、参与角色、线下与系统 Feature 及其业务顺序。PRD 基于已确认的 User Journey 说明产品为什么存在、为谁服务、提供什么价值和能力。Business Architecture 使用同一份已确认 User Journey 说明产品在业务上如何运作，包括业务角色、业务域、业务能力、流程、业务对象、状态和规则。

User Journey 是可以独立确认和持久化的权威资产。PRD 与 Business Architecture 尚未完成时，已确认的 User Journey 仍然有效；只有三份资产全部确认并保持一致后，才能声称完整产品设计基线已经完成。

## 适用场景

- 从一个模糊想法开始明确要解决的问题和产品方向。
- 首次分析并确认产品支持的业务线和 User Journey。
- 首次建立 PRD。
- 首次建立 Business Architecture。
- 澄清目标用户、业务价值、成功标准、范围、非范围、业务运作方式、约束和开放问题。

Discovery 支持首次建立和增量更新两种模式。增量模式只有在用户明确表达更新已有产品设计的意图，并且仓库扫描找到可信候选文档时才启动；单独的文件存在或单独的更新表述都不足以触发。未找到候选时不会自动切换成首次 Discovery。

## 不适用场景

- 更新或升版已有产品设计基线：使用 Discovery 增量模式。
- 将已确认产品设计基线拆分成 Feature 和工作项：使用后续安装的 `work-item-planning`。
- 对单个 Story、Task 或 Bug 进行技术设计和开发交付：使用相应开发 workflow。
- 设计技术模块、数据库、API、部署拓扑或其他技术架构。
- 修改应用代码、数据库迁移或运行实现验证。

## 流程阶段

| 阶段 | 目标 | 主要产出 |
|---|---|---|
| 1. 背景与问题探索 | 收集原始想法、反馈、业务问题和现状，识别初步目标、价值、范围以及事实、假设和待确认内容。目标、价值和范围在本阶段是后续分析输入，不提前形成正式产品结论。 | 会话内分析。 |
| 2. User Journey 分析 | 围绕一条稳定业务线识别业务边界、稳定业务阶段、参与角色、线下与系统 Feature 及其业务顺序，并使用真实业务过程验证初步目标、价值和范围。 | 完整 User Journey 提案。 |
| 3. User Journey 确认 | 向用户展示完整 Journey Map、Feature 定义、业务线边界、开放问题和拒绝方向。确认前只维护会话提案；确认后才写入或更新权威 User Journey。 | `docs/product-design/user-journey.md`；会话内确认。 |
| 4. PRD 与 Business Architecture 推导 | 基于已确认 User Journey 并行形成产品目标、价值、范围、需求和业务架构，保持两份资产职责分离并建立必要追溯。 | 完整 PRD 与 Business Architecture 提案。 |
| 5. 产品设计基线确认 | 统一说明 PRD 与 Business Architecture 的核心结论、未解决问题、排除项、技术输入处置以及与 User Journey 的一致性。确认前只维护会话提案；确认后才写入或更新两份权威资产。 | `docs/product-design/prd.md`；`docs/product-design/business-architecture.md`；会话内确认。 |

阶段顺序：

```text
Background And Problem Exploration
-> User Journey Analysis
-> User Journey Confirmation
-> PRD And Business Architecture Derivation
-> Product Design Confirmation
```

目标、价值和范围必须经过分析，但不在 User Journey 之前设置独立确认门。它们先作为背景与 Journey 分析输入，等 User Journey 确认后再分别进入 PRD 与 Business Architecture 的正式结论。

Discovery 使用两道确认门。User Journey 未确认时不得开始正式推导 PRD 与 Business Architecture。最终产品设计确认不重新审批 User Journey 正文，但必须确认 PRD 和 Business Architecture 与已确认 User Journey 一致，三份资产之间不存在未说明冲突，并且 Open Questions、排除项和技术输入处置清楚。

所有阶段都只作为会话内工作方法，不创建 manifest 或阶段记录。User Journey 确认前、PRD 与 Business Architecture 确认前，不得在正式路径写入未确认草稿。User Journey 可以在第一道确认门后独立成为权威资产；只有三份资产都确认且一致后，才可以声称完整产品设计基线已完成。

## User Journey 职责

`docs/product-design/user-journey.md` 记录一条稳定业务线的权威 User Journey。Journey 不以单一角色、触发条件或终局划分；只要内容共同服务于同一个稳定业务责任范围，即使存在多个角色、入口、分支和结果，也属于同一 Journey。只有业务责任、价值边界或所有权可以独立成立时，才考虑拆分不同 Journey。

当前只维护一个 User Journey 文档，不提前设计多 Journey 目录、根索引或拆分阈值。User Journey 使用仓库全局唯一的稳定 ID，格式为 `J-nnn`。

User Journey 文档至少包含：

- Journey ID、Version、业务线说明与边界；
- Journey Map；
- Feature Definitions；
- `Open Questions`、`Rejected Directions` 和 `Change Log`。

### Journey Map

Journey Map 使用普通 Markdown Table 表达：

- 行表示参与角色；
- 列从左到右表示业务推进顺序；
- 非空列表头开始一个稳定业务阶段，后续连续空表头继承左侧最近的非空业务阶段；
- 空表头只能表示阶段延续，不能表示没有业务阶段；
- Feature 必须写在对应角色行中，并显示稳定 ID、Type 和 Title；
- 空内容单元格表示该角色在该位置没有已确认 Feature，不是待补全项；
- 相同 Feature 可以由多个角色使用，并在相关角色行中复用同一个稳定 ID；
- Journey Map 只使用表格和从左到右的默认业务顺序，当前不额外表达回退、跳转或条件连接。

结构示例：

| Role | 出差发起与审批 |  |  | 出差安排与执行 |  |
| --- | --- | --- | --- | --- | --- |
| Employee Manager |  |  | `[System] F-003 批准出差` |  |  |
| Employee | `[Offline] F-001 发现出差任务` | `[System] F-002 申请出差` |  |  | `[System] F-005 确认行程方案` |
| Travel Coordinator |  |  |  | `[System] F-004 制定行程方案` |  |

Journey Map 必须区分 `Offline` 与 `System` Feature，但不得把某一种示例配色固化为语义契约。Type 的文本是权威分类；颜色或其他视觉样式只能作为辅助呈现。

### Feature Definitions

线下业务活动与系统内活动统一建模为 Feature，不维护单独的线下活动实体或定义表。Feature 使用仓库全局唯一的稳定 ID，格式为 `F-nnn`，并由 Discovery 创建和维护。Feature 的 Type 不编码进 ID；只要业务身份没有变化，改名或 Type 调整时保留原 ID。

Feature Definitions 使用以下最小字段：

```text
ID | Type | Title | Description
```

Type 当前只允许：

- `Offline`：业务在线下完成，系统不直接承担执行；
- `System`：业务通过系统完成，可以在后续 Work Item Planning 中拆分 Story 或 Task。

Feature 表达 Journey 中的稳定业务能力，不按角色、入口、界面或预期实施方式机械拆分。不同角色使用同一项业务能力时可以复用同一个 Feature；只有业务能力或产品责任本身不同时才拆分 Feature。

## PRD 职责

`docs/product-design/prd.md` 记录：

- 产品背景、问题、愿景和目标；
- 用户、角色、相关方、需求和痛点；
- 用户价值、业务价值和期望结果；
- 成功标准和失败条件；
- 范围、非范围和产品边界；
- 产品能力和产品需求；
- 非功能需求、约束、假设和外部依赖；
- `Open Questions`、`Rejected Directions`、`Future Scope` 和 `Change Log`。

每条重要 Product Requirement 必须引用来源 Journey ID 和相关 Feature ID。普通说明性段落不要求机械增加引用。PRD 不复制 Journey Map 的完整过程内容。

## Business Architecture 职责

`docs/product-design/business-architecture.md` 记录：

- 业务角色、职责、权限和责任边界；
- 业务域、所有权、边界和域间关系；
- 核心与支撑业务能力及其依赖；
- 端到端价值流、业务流程、触发条件、结果、交接点和决策点；
- 核心业务对象、关系、所有权和事实来源；
- 重要状态、生命周期、转换条件和异常状态；
- 业务规则、校验规则、资格规则、权限规则和一致性规则；
- 业务事件、外部参与方、外部系统边界、输入和输出；
- 异常场景、业务架构约束、`Open Questions`、`Rejected Directions` 和 `Change Log`。

Business Architecture 不是技术架构，不规定代码模块、服务、数据库、协议、基础设施或部署设计。

Business Architecture 在描述关键角色、流程、规则、对象或状态时，应引用相关 Journey 或 Feature，但不要求每一条内容机械绑定 Feature。它不得重新定义 Journey Map 或 Feature Definitions 中已有的业务身份。

## 产品、业务与技术内容边界

Discovery 对首次创建和增量更新使用同一套内容边界。增量模式发现历史混合内容时，先说明分类依据、建议承载位置和影响引用；只有用户明确确认后才迁移或移除。

输入按含义、来源、权威程度和目标所有者分类，而不是按是否出现技术名词分类：

- 产品要求描述产品目标、用户、价值、能力、成功标准、产品边界或用户可感知结果。
- 业务架构内容描述业务角色、业务域、业务能力、价值流、流程、业务对象、状态、业务规则、业务事件、异常和外部业务边界。
- 外部或产品级约束描述必须满足的结果或边界，不同时指定实现机制。
- 实现建议描述达到结果的候选机制，需要在后续技术设计阶段结合代码现实评估。
- 技术问题记录尚未解决的实现信息，不把候选答案视为已选择方案。

数据地域、法规限制、兼容要求、可测量的性能与可用性目标，以及用户可感知的安全要求可以进入 PRD。记录时必须表达要求的结果和验证边界，不得顺带确认数据库、框架、协议、云服务、算法或部署方案。

以下内容不得进入 PRD 或 Business Architecture：具体代码模块、服务拆分、数据库产品、框架、库、API 路径、请求响应结构、协议选择、算法、云服务、基础设施、部署拓扑、重试与超时实现参数、测试实现、Mock 方案和运维实现步骤。

技术输入按以下顺序保留：

1. 已有 Story、Task、技术方案、Decision 或其他权威技术文档时，写入或引用该文档。
2. 暂无合适权威文档且信息不应丢失时，复用 S-005 的 Open Question Registry，并记录来源状态和建议解决阶段。
3. 属于 PRD 或 Business Architecture 自身范围的产品或业务问题，继续保留在对应文档的 `Open Questions`。

转移、登记、引用或排除技术输入只表示为后续评估保留上下文，不表示用户接受了技术决策。最终产品设计确认摘要必须列出排除在产品基线之外的重要技术输入、当前承载位置和建议解决阶段。

这些技术处置属于支撑性的共享资产维护，不是 Discovery 的额外主产物或过程记录。Discovery 只在既有权威技术资产的维护规则允许时更新或引用它；没有合适所有者时，按 Open Question Registry 自身的 on-demand 规则调用共享能力。Discovery 不会为了处置技术输入自动创建 Story、Task、Decision 或其他技术设计资产。

## 版本与历史

- User Journey、PRD 和 Business Architecture 的第一版版本号都是 `1`。
- 三份文档各自独立管理版本；只有受影响文档发生实质变化时才递增，拼写、排版、路径、文件名和链接变更不升版。
- User Journey 的业务线边界、业务阶段、角色参与、Feature、顺序或已表达流转发生实质变化时必须升版。
- 每份资产的 Change Log 使用 `Version | Recorded At | Recorded By | Change | Reason`。
- `Recorded At` 使用带时区的 ISO 8601 时间。
- `Recorded By` 使用 Git 配置中的用户身份，优先读取仓库级 `user.name` 和 `user.email`，缺失时读取全局配置；有邮箱时使用 `Name <email>`，只有用户名时只记录 `Name`。用户名和邮箱都不存在时，写入前必须要求用户提供，不得推断。
- `Recorded By` 和 `Recorded At` 只进入 Change Log，不放在文档头部，也不表示业务审批身份或审批时间。
- 产品文档不记录 Git commit hash、checkpoint 或 workflow 状态。
- Discovery 不创建 manifest、阶段记录、确认记录、拒绝记录或 checkpoint 证据；用户确认保留为会话门禁。

## 关键规则

- 输入可以只有一个想法，不要求用户预先提供完整需求、验收标准或实现边界。
- 冲突来源优先采用用户明确确认，其次采用仓库现有文档；未解决冲突保留在 `Open Questions`。
- `Open Questions` 是唯一的未解决事项章节，不额外创建 `Draft Ideas` 或 `Pending Decisions`。
- 已确认答案写回对应正文；明确拒绝的方向保存在 `Rejected Directions`；延后产品范围保存在 PRD `Future Scope`。
- 不得为了让文档看起来完整而虚构用户、需求、流程、业务对象、状态或规则。
- Discovery 只创建和维护 User Journey、Feature、PRD 与 Business Architecture，不创建 Story、Task、Bug 或 Story Map。
- 首次创建产品设计基线前必须完成内容边界检查；候选实现只有在承载位置已记录后才从产品设计草稿中排除，不能直接丢弃。
- 增量输入使用同一边界；已有基线中的历史混合内容不静默删除、改写或迁移。

## 既有基线发现与增量协调

- 扫描仓库根目录和正常项目文档目录，按内容职责识别 User Journey、PRD、Business Architecture 和综合产品文档；排除 `.dev-cadence/`、`dist/`、`build/`、`vendor/`、`node_modules/` 和 `.git/`。
- 多个候选、职责不明或内容冲突时，修改前由用户确认权威来源。
- 非标准路径或文件名只在用户确认后迁移；拒绝迁移时继续维护原权威路径，不创建重复文档。
- 综合产品文档只在用户确认后拆分；选择保留单文件时，同一文件分别维护 `PRD Version` 与 `Business Architecture Version`（或等价职责版本字段），Change Log 标明受影响职责，并且只递增实质变化的职责版本。
- 已有 PRD 或 Business Architecture 但没有 User Journey 时，现有文档作为可信分析输入，不自动视为错误。Discovery 先形成并确认第一份 User Journey，再判断已有 PRD 与 Business Architecture 是否需要协调；只修改实际受影响的资产，不要求推倒重建整个基线。
- 用户明确要求更新现有产品设计时，先判断输入是否实质影响 User Journey。影响时先形成并确认 Journey 修订，再协调 PRD 与 Business Architecture；不影响时不得重新确认、升版或改写 Journey。
- 独立 Story、Task、Bug、开发请求或仓库中存在产品设计文件，都不会自动触发增量 Discovery。增量更新必须同时存在用户明确的产品设计更新意图和可信权威资产。
- 已确认问题从本地 `Open Questions` 移入正确正文；相关 Registry 条目按 S-005 删除并在 Registry `Change Log` 留痕。
- 最终确认摘要列出实际文档路径、前后版本、未升版原因和潜在工作项影响；工作项调整只在用户明确要求时交给 `work-item-planning`，Discovery 不自动修改工作项或 Story Map。
- 每道确认门前先读取当前权威内容和版本，在会话中形成完整 proposed revised asset 与变更摘要；确认前磁盘上的对应权威资产保持原样，用户反馈或拒绝只更新会话 proposal，不创建草稿文件或过程记录。
- User Journey 确认后，才写入受影响的 Journey 内容、递增版本并追加 Change Log。最终产品设计确认后，才写入受影响的 PRD 与 Business Architecture、递增相应版本、追加 Change Log，并执行已确认的迁移、拆分、引用更新和 Registry 等支撑资产维护。
- 产品设计资产保存在目标仓库正常项目空间，不得写入可替换的 `.dev-cadence/` 安装包。
- Discovery 的 primary outputs 是 User Journey、PRD 和 Business Architecture；背景、目标、范围、风险和约束直接进入职责对应的权威文档。技术输入处置产生的共享资产维护不构成额外 Discovery 主产物。
- 首次和增量模式的修改反馈都只更新当前会话 proposal，并在相应确认门前重新展示完整提案。用户拒绝时不修改对应权威资产、不创建额外拒绝记录，也不声称该资产已确认。
- 继续执行 Discovery 时，根据当前会话、用户目标和现有产品设计文档判断上下文，不依赖 manifest 恢复阶段状态。
- Discovery 不要求专用分支或 workflow checkpoint；用户要求保存或提交时遵循目标仓库普通 Git 规则。

## 与其他 Workflow 的关系

```text
想法、反馈、业务问题或产品方向
              |
          discovery
              |
       已确认的 User Journey
              |
  已确认的 PRD + Business Architecture
              |
    work-item-planning（后续能力）
```

用户只需要形成产品方案时，可以在 Discovery 完成后停止。需要形成工作项组合时，在对应 workflow 安装后再进入 Work Item Planning。
