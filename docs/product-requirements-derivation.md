# 产品需求形成与 Story Map 衔接设计

## 目的

本文说明产品需求如何从原始产品想法和业务问题逐步形成，并定义 User Journey、PRD、Business Architecture、Feature、Story 和 Story Map 之间的关系。

本设计解决的核心问题是：产品设计不能从一段不完整输入直接生成 PRD。PRD 应是产品分析完成后的产品定义和结论汇总，重要需求必须能够追溯到用户目标、User Journey 和具体业务环节。

## 核心原则

- 产品需求必须通过用户和业务分析形成，不能为了快速生成 PRD 而跳过需求发现过程。
- 一个产品可以包含多条 User Journey，例如不同用户角色、业务目标或业务场景各自拥有一条 Journey。
- User Journey 描述用户为完成目标而经历的业务流程，并按业务顺序组织一个或多个 Feature。
- Feature 表达产品在 Journey 对应业务环节提供的特性，一个 Feature 可以拆解出一个或多个 Story。
- PRD 和 Business Architecture 使用同一组产品分析输入，但分别维护产品定义和业务系统设计。
- Story Map 只表达系统业务设计，不承载 Bug、Technical Task、技术架构、开发阶段或 workflow 运行状态。
- Bug 和 Technical Task 进入统一 Backlog，并关联受影响的 Feature 或 Story，但不进入 Story Map。

## 产品需求形成链路

```text
产品想法 / 业务问题
        |
        v
用户、角色与业务目标识别
        |
        v
一条或多条 User Journey 分析
        |
        | 按业务流程识别 Feature 和产品需求
        v
产品需求集合
        |
        +----------------------+
        |                      |
        v                      v
PRD                    Business Architecture
产品目标、范围、能力、需求     角色、流程、对象、状态、规则
        |                      |
        +----------+-----------+
                   |
                   v
            Work Item Planning
                   |
                   v
              Story Map
User Journey -> Feature -> Story -> 路径与 MVP
```

## User Journey 的职责

User Journey 是产品需求分析的基础资产。每条 Journey 围绕一个明确的用户角色、业务目标或业务场景，描述用户从触发流程到获得最终结果所经历的完整业务过程。

User Journey 至少需要帮助分析以下内容：

- 用户或业务角色是谁；
- Journey 在什么条件下开始；
- 用户希望完成什么最终目标；
- 用户依次经历哪些业务环节；
- 每个环节需要完成什么业务任务；
- 每个环节有哪些参与者、交接点和业务结果；
- 每个环节存在哪些需求、问题、约束和机会；
- 正常路径、替代路径和失败路径分别是什么；
- Journey 在什么条件下成功结束、替代结束或失败结束。

一个产品允许存在多条 User Journey。不同 Journey 可以服务不同角色、目标或场景。即使不同 Journey 使用相同的底层机制，也必须按照各自的角色、目标和业务语境命名 Feature，不要为了抽象复用而合并不同的业务含义。

## 从 User Journey 形成 Feature

Feature 是排列在 User Journey 上的产品特性，也可以理解为产品在对应业务环节为用户或业务提供的一项能力。Feature 不是页面、技术模块或开发任务。Story Map 不在 Feature 之外另设 Journey Node、业务需求实体或产品能力层级。

每个 Feature 应能够说明：

```text
用户在这里要完成什么
-> 业务必须提供什么结果
-> 适用哪些业务规则和约束
-> 正常、替代和失败情况是什么
-> 可以拆解出哪些 Story
```

Feature 之间的顺序共同表达用户完成目标所经历的业务流程。只有角色、目标、触发条件、最终结果、Feature 的业务含义、顺序或交接关系发生变化时，才需要更新 User Journey。业务流程没有变化，而只是补充或调整 Feature 下的具体行为、验收范围或交付计划时，只更新 Story Map 或对应 Story。

重要产品需求必须能够追溯到其来源 Journey 和 Feature。Journey、Feature 或需求变化时，应能够判断哪些 PRD 内容和 Story 受到影响。

## PRD 如何形成

PRD 不是原始需求收集记录，也不是 User Journey 的副本。PRD 综合问题探索、用户分析、User Journey 和业务需求，形成经过整理的产品定义。

| PRD 内容 | 主要来源 |
| --- | --- |
| 产品背景和问题 | 原始输入与问题探索 |
| 用户和相关方 | 用户分析与 User Journey 参与者 |
| 用户价值 | Journey 最终目标和各业务环节的结果 |
| 产品范围 | Journey、角色、场景和业务流程边界 |
| 产品能力 | User Journey 中按业务流程识别的 Feature 及其业务结果 |
| 产品需求 | Feature 对应的用户结果、业务规则和约束 |
| 成功标准 | Journey 的成功结果和可测量业务结果 |
| 异常和边界需求 | 替代路径与失败路径 |
| Future Scope | 当前未覆盖的 Journey、Feature、角色或路径 |

每条重要 PRD Requirement 应能够回答：

```text
服务哪个用户或角色
-> 来自哪条 User Journey
-> 对应哪个 Feature
-> 提供什么业务结果
```

PRD 负责汇总和定义产品要提供的价值、能力、结果和边界，不负责保存 Journey 的全部过程分析细节。

## Business Architecture 如何形成

Business Architecture 与 PRD 使用相同的产品分析输入，但关注产品如何作为业务系统运作。

它从 User Journey、Feature 和产品需求中提炼：

- 业务角色、职责和权限边界；
- 业务域及其所有权；
- 端到端价值流和业务流程；
- 流程中的交接点和决策点；
- 核心业务对象及其关系；
- 对象状态和生命周期；
- 业务规则、资格规则和一致性要求；
- 业务事件、外部参与方和外部业务边界；
- 替代流程、失败流程和业务异常。

PRD 与 Business Architecture 必须保持职责分离，同时能够通过 Journey、Feature、业务需求和产品能力建立可追溯关系。

## Story Map 的形成

Work Item Planning 在产品需求和业务设计稳定后生成和维护一张逻辑上的全局 Story Map。

Story Map 的业务结构是：

```text
全局 Story Map
└── 一条或多条 User Journey
    └── 一个或多个 Feature
        └── 一个或多个 Story
```

对应基数关系：

```text
Product 1:N User Journey
User Journey 1:N Feature
Feature 1:N Story
```

Feature 按所属 User Journey 的业务流程排序。Feature 下的 Story 按用户路径类型排序：

1. Happy Path；
2. Alternative Path；
3. Sad Path。

### Happy Path 与 MVP

Happy Path 描述用户在正常条件下完成整条业务流程所需要的 Story。

MVP 不是某一个 Feature 的最小版本，而是从 Journey 起点到终点，使主要业务流程能够端到端成立的 Happy Path Story 集合。任何单个 Feature 即使实现完整，只要整条主业务流程仍无法完成，就不能构成产品 MVP。

### MVP 后计划

Alternative Path 描述用户通过其他选择、入口或业务分支仍然完成目标的情况。Sad Path 描述失败、拒绝、异常、恢复和边界处理。

Alternative Path 和 Sad Path 对应的 Story 构成 MVP 之后的计划，再根据用户价值、业务风险、合规要求、依赖和交付成本进行排序。

### Story Map 边界

Story Map 只包含：

- User Journey；
- Feature；
- Story；
- Happy Path、Alternative Path 和 Sad Path；
- MVP 和后续业务计划。

Story Map 不包含：

- Bug；
- Technical Task；
- 技术架构、模块、数据库或接口设计；
- Requirements、Solution、Implementation、Testing 或 Business Acceptance 等 workflow 阶段；
- workflow manifest、阶段记录、测试状态或实施日志。

Bug 表示既定产品行为没有正确实现。Technical Task 表示支撑产品交付的工程工作。二者都应进入统一 Backlog，并关联相关 Feature 或 Story，但不占据 Story Map 的业务结构。

## 全局 Story Map 的持久化原则

逻辑上一个产品仓库维护一张全局 Story Map。初期项目规模较小时，可以使用单个文档：

```text
docs/story-maps/story-map.md
```

随着需求、Journey、Feature 和 Story 增加，可以按业务阶段、产品区域或交付计划拆分子文档。拆分只是一种物理存储和阅读优化，不产生多张互相竞争的 Story Map。

根文档必须始终作为唯一入口，并保留：

- 全局 Journey 和业务流程顺序；
- 全局 MVP 与后续计划概览；
- 被拆分内容的索引；
- 跨 Journey、Feature、Story 和子文档的关系；
- 全局 Open Questions 和 Change Log。

Story Map 只保存 Feature 和 Story 的名称、稳定 ID、业务顺序、路径分类、交付切片和快捷链接，不复制工作项卡片正文。每个 Feature 和 Story 只能有一个权威卡片位置，根文档和子文档不得重复维护需要同步的完整内容。

## Workflow 顺序影响

当前设计要求 User Journey 分析先于 PRD 生成和 Story Map 规划。建议的能力顺序是：

```text
Discovery 产品分析
-> User Journey 分析
-> PRD 与 Business Architecture 建立或更新
-> Work Item Planning
-> Story Map、Feature 与 Story
-> 统一 Backlog
-> Delivery Workflow
```

这意味着现有 User Journey 工作项不能继续被定义为不阻塞 Work Item Planning 的低优先级可选能力。后续需要单独评估并更新 Discovery、首次产品设计基线、增量产品设计、User Journey 和 Work Item Planning 相关卡片及依赖关系。

## 尚待后续设计

本文尚未确认以下实现细节：

- User Journey 文档的最终持久化路径和模板；
- Journey、Feature 和 Story 的稳定 ID 规则；
- 不同 Journey 使用相同底层机制时的 Feature 业务命名规则；
- PRD Requirement 与 Feature 的具体引用格式；
- 全局 Story Map 的最终 Markdown 布局；
- Story Map 达到什么规模时拆分子文档；
- Feature 卡片的最终目录和模板；
- 增量产品设计如何判断业务流程是否变化，以及如何计算 Journey、PRD、Feature 和 Story 的影响范围。

这些问题应在对应工作项中继续收敛，不应由本文提前推断为已确认规则。
