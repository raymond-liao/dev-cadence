# 工作项规划流程

本文说明 Dev Cadence 的 `work-item-planning` 业务流程，包括适用场景、阶段目标、Story Map、Milestone、估算、工作项和 Backlog 的职责边界。本文面向 Dev Cadence 维护者、流程评审者和希望了解工作项治理模型的使用者。

目标仓库中的实际执行规则将由 `src/workflows/work-item-planning/SKILL.md` 定义并生成安装内容。本文用于说明业务流程设计，不替代 workflow skill。

## 目的

工作项规划流程把已确认的产品设计组织成可以审阅和调整的交付结构。它维护 Story Map、Milestone、Iteration Plan、轻量 Story、Task、Bug 卡片和统一 Backlog，但不重新分析 Feature，也不负责把所有工作项细化到可以实施的程度。

产品级组合规划使用以下输入：

```text
已确认的 User Journey
+ 已确认的 PRD
+ 已确认的 Business Architecture
        |
work-item-planning
        |
Story Map + Milestone + Iteration Plan + 轻量工作项 + Backlog
```

Feature 由 Discovery 在 User Journey 中创建和维护。Work Item Planning 只引用已确认的 Feature，不创建 Feature 卡片，不改变 Feature ID、Type、标题、业务身份或顺序。

## 适用场景

- 根据已确认的产品设计基线形成或更新 Story Map。
- 从 System Feature 识别轻量 Story 和必要 Task。
- 根据 Path 提出 MVP 和后续 Milestone 候选，并由用户确认阶段性交付范围。
- 对 Story Map 中的 Story 和 Task 进行相对 Size 估算。
- 根据团队假设、首个迭代容量校准、优先级、依赖和 Size 形成完整 Iteration Plan。
- 创建或复用明确单项请求对应的轻量 Story、Task 或 Bug 卡片。
- 协调工作项的规划关系、优先级、建议顺序和 Backlog 汇总。
- 在用户明确要求时，协调产品设计变化对现有 Story Map、Milestone、卡片关系和 Backlog 的影响。

## 不适用场景

- 建立或改变 User Journey、Feature、PRD 或 Business Architecture：使用 `discovery`。
- 详细分析 Story、Task 或 Bug 的需求和问题定义：使用后续安装的 `work-item-analysis`。
- 调查 Bug 根因、设计修复方案或实施修复：使用 `bug-fix`。
- 为 Story 设计技术方案或实施产品行为：使用 `feature-dev`。
- 实施 Task 或行为保持的结构调整：根据目标使用 `feature-dev`、`bug-fix` 或 `refactor`。
- 执行发布、部署或生产事故处理：不属于当前流程范围。

## 规划模式

### 组合规划模式

组合规划模式读取已确认的 User Journey、PRD 和 Business Architecture，形成或增量维护产品级规划结构：

```text
Journey 中的 Offline / System Feature
        |
Story Map Backbone
        |
System Feature 下的 Story 和必要 Task
        |
Path、Milestone、Iteration Plan、Size 和 Backlog
```

缺少形成完整规划所需的产品结论时，不得在 Work Item Planning 中猜测或补写产品需求。需要形成新的产品结论时返回 Discovery。产品设计基线不完整时仍可使用单项登记模式，但不得声称已经形成完整 Story Map。

### 单项登记模式

单项登记模式处理用户直接提出的明确 Story、Task 或 Bug：

```text
明确单项请求
    |
创建或复用轻量卡片
    |
更新必要 Backlog 引用
```

单项登记不自动修改 User Journey、PRD、Business Architecture、Story Map 或 Milestone，也不重排无关工作项。只有用户明确要求把单项工作纳入产品规划时，才评估并更新受影响的规划资产。

## 流程阶段

Work Item Planning 按模式使用不同的阶段和正式确认门。

### 组合规划模式阶段

```text
Planning Inputs And Scope Confirmation
    -> Planning Structure Proposal
    -> Planning Result Confirmation
```

组合规划保留两道正式确认门：先确认权威输入与范围，再确认完整规划结果。用户可以只确认结果提案中的命名子集；未确认部分保持现有权威内容不变。

### 单项登记模式阶段

```text
Necessary Clarification (not a formal confirmation gate)
    -> Direct Intake Proposal
    -> Direct Intake Result Confirmation
```

必要澄清只补齐创建或复用单张卡片所需的缺失事实，不把已经明确的输入和范围重新包装成确认门。`Direct Intake Result Confirmation` 是单项登记唯一正式确认门，一次展示完整卡片、ID、仓库相对路径、Priority、Relationships、依赖和全部必要 Backlog 变化。用户确认后，卡片与必要 Backlog 引用作为一个原子单元写入；如果确认改变 `待处理` 顺序，同一原子单元还包括 `Ordering Version` 和 `Ordering Change Log`。

在两种模式中，阶段都只作为会话内工作方法，不创建 manifest、阶段记录或 checkpoint。用户确认前不得把提案写入正式资产。单项登记的 `confirm only the named subset` 不能拆出孤立卡片或孤立 Backlog 行；可独立保持有效的 Story Map、Milestone 等可选引用才允许单独确认。

规划确认不表示 Story Map 中的所有卡片已经达到 `Ready`。组合规划允许创建只有稳定 ID、标题、所属 Feature、Path、Milestone 候选和初步 Size 的轻量 `Draft` 卡片。

## Story Map

Story Map 是 Work Item Planning 维护的产品级交付结构。默认路径为：

```text
docs/product-planning/story-map.md
```

当前只维护一张逻辑上的全局 Story Map，不提前设计子目录、拆分阈值或多张竞争 Story Map。

### Backbone（Feature 主干）

Backbone 是 Story Map 顶部按业务顺序排列的 Feature 主干。它从已确认的 User Journey 中提取 Offline 和 System Feature，保留完整业务线及其先后关系，并作为下方 Story 和必要 Task 的组织框架。Backbone 不是新的业务资产，不复制或重新定义 Feature。

- Story Map 必须按 User Journey 从左到右引用全部 Offline 和 System Feature。
- Feature 表头必须显示 Type、Feature ID 和 Title。
- Offline Feature 保留业务上下文，但其下不创建系统 Story 或 Task。
- System Feature 下可以放置 Story，以及使 Feature 或 Milestone 成立所必需的 Task。
- 同一个 Feature 在 Journey Map 多个角色行中出现时，在 Story Map Backbone 中只出现一次。
- Story Map 不重新定义或改变 Feature；发现 Feature 缺失、含义不清或顺序需要变化时返回 Discovery。

### Markdown Table 布局

Story Map 使用普通 Markdown Table：

- 第一列固定为 `Path`。
- 后续列按 Journey 业务顺序表示 Feature。
- 每个 Path 可以占多行；Path 名称只写在第一行，后续连续空白单元格继承上方最近的非空 Path。
- 每个单元格只放一个 Story 或 Task，并显示 Size、稳定 ID 和 Title。
- 空单元格表示该位置没有工作项，不是待补全项。
- Story 必须有且只有一个主要 System Feature；可以关联其他 Feature，但在 Story Map 中只出现一次。
- Task 可以选择关联 Feature 或 Story；没有明确产品关系的 Task 可以只进入 Backlog。
- Bug 不进入 Story Map，只进入 Backlog并关联受影响的 Feature或Story。

同一个 Feature、同一个 Path 的工作项数量决定 Feature 使用的列数：

```text
1-5 个工作项   -> 1 列
6-10 个工作项  -> 2 列
11 个及以上    -> 3 列
```

最多使用三列。Feature 的实际列数取其所有 Path 中需要的最大列数。非空 Feature 表头开始一个 Feature，后续连续空表头继承左侧最近的非空 Feature；下一个非空 Feature 表头开始下一个 Feature。

多列时按先从左到右、再从上到下的顺序放置工作项。Feature 从左到右保持 Journey 业务顺序；同一 Feature、同一 Path 中的工作项位置从左到右、从上到下表达优先级和建议交付顺序。位置不自动表示硬依赖，必须先完成的依赖仍在卡片或 Backlog 中明确记录。

示例：

| Path | `[System] F-001 申请出差` |  | `[System] F-002 批准出差` |
| --- | --- | --- | --- |
| Happy Path | `[M] S-001 提交出差申请` | `[S] S-002 查看申请状态` | `[M] S-007 批准完整申请` |
|  | `[S] T-003 准备默认申请规则` |  | `[S] S-008 查看审批资料` |
| Alternative Path | `[M] S-009 补充申请信息` |  | `[M] S-010 要求补充资料` |
| Sad Path | `[L] S-011 处理提交失败` |  | `[M] S-012 拒绝出差申请` |

### Path

Path 是 Story Map 中的规划分类，不是工作项类型或状态：

- `Happy Path`：完成主要业务价值的路径。
- `Alternative Path`：业务可以继续，但采用不同处理方式的路径。
- `Sad Path`：业务失败、终止或需要恢复的路径。

同一个工作项只在 Story Map 中出现一次。Path 只保存在 Story Map 中，不作为 Story 或 Task 卡片必须同步的权威字段。

## Milestone 与 MVP

代理必须根据 Path 提出 Milestone 候选，但不得自动把候选写成正式规划。默认候选是：

```text
MVP                 -> 默认从 Happy Path 提出
Alternative Paths   -> 默认从 Alternative Path 提出
Failure And Recovery -> 默认从 Sad Path 提出
```

默认候选不是固定范围。用户可以把 Alternative 或 Sad Path 工作项纳入 MVP，把非必要 Happy Path 工作项移到后续 Milestone，合并或拆分候选，并调整标题和目标。

正式 Milestone 至少包含：

```text
ID | Title | Goal | Included Work Items | Derived From
```

- Milestone 使用稳定的 `M-nnn` ID。
- MVP 是用户确认的第一个 Milestone，不是自动计算结果。
- `Included Work Items` 必须固定记录具体 Story 和 Task ID，不能只动态引用整个 Path。
- `Derived From` 可以记录建议来源 Path，但新增 Path 工作项不会自动进入已确认 Milestone。
- 同一个工作项同时只能属于一个未完成 Milestone；后续 Milestone可以依赖已经完成的工作项，但不得重复计算范围。
- Milestone 不复制卡片正文、状态或验收条件。
- Milestone 默认不包含日期；只有用户明确需要时才记录目标日期。
- 未经用户确认的内容必须标记为 proposed，不得写入权威 Story Map。

Milestone 使用独立表格放在 Story Map 主表之后，避免破坏 `Path x Feature` 布局。

## Size 估算

相对 Size 估算是 Work Item Planning 的条件能力。仅使用以下唯一枚举：

```text
XS / S / M / L / XL / ?
```

Size 表示相对工作量、复杂度和已知不确定性的综合判断；不得转换为人日、工期、团队容量或任何容量承诺。`?` 表示现有信息不足以形成可信估算，必须保留，不得为了完成规划而猜测为确定等级。

在适用的 Story Map 和卡片已经存在，或已包含在当前规划提案后，Work Item Planning 提出一个范围清楚、规模适中且具有代表性的基准候选，并说明选择理由。用户必须确认该卡片为 `M`，然后才可估算其他工作项。Story Map 记录基准工作项 ID、基准卡片 Version、选择理由和 `Needs Size Re-estimation: yes|no`；该标记是规划元数据，不是工作项状态。

估算遵循以下边界：

```text
确认 M 基准
-> 相对估算 Story Map 中的 Story 和必要 Task
-> 在当前已确认 Planning 范围内估算独立 Task 和 Bug
-> 汇总并等待 Planning Result Confirmation
-> 原子写入卡片、Story Map 和 Backlog 的 Size 投影
```

Bug 不进入 Story Map。Story Map 必须显示 Story 和必要 Task 的 Size、按 Path 和 Milestone 的分布，以及 `XL`、`?` 和显著不确定性的明确汇总。卡片记录每项已确认的 Size；卡片 Change Log 记录 Size 确认、失效和重新估算，但仅 Size 的变化不得递增卡片 Version。

Backlog 生命周期表继续严格使用 `ID | Title | Version | Status | Priority` 五列，不得增加 Size 列。适用的已估算卡片通过独立的 `Size Summary` 汇总，列严格为 `ID | Size | Needs Re-estimation`。相对 Size 估算作为规划结果的一部分，必须在 Planning Result Confirmation 后原子写入卡片 Size、Story Map 基准与分布及 Backlog `Size Summary`。

增量规划在基准卡仍存在、不是 `Superseded` 且其 Version 与 Story Map 基准快照一致时复用已确认基准。基准卡被删除、标记为 `Superseded` 或 Version 不再匹配快照时，基准失效；Planning 必须选择替代基准并请用户重新确认，之后才可估算或重新估算受影响工作项。用户也可以调整单项 Size 或选择替代基准，但结果仍需等待适用的 Planning Result Confirmation 才能写入。

其他 workflow 发现实质范围变化可能使既有估算失效时，只能在卡片标记 `Needs Size Re-estimation: yes` 并写明原因，然后返回 Work Item Planning；不得自行修改 Size、Story Map、Backlog `Size Summary` 或基准。该能力不创建或修改 Iteration Plan，也不进行 S-039 的容量校准。

## Iteration Plan（迭代计划）

Iteration Plan 是 Story Map 内的完整分批实施路线，不创建独立 Sprint Plan 文件。它说明整个规划预计分成哪些有顺序的迭代、每个迭代包含哪些工作项、迭代目标和规模如何，以及排期依赖的团队与容量假设。

Iteration Plan 与 Path、Milestone 的职责不同：

```text
Path
= 业务路径分类和默认优先级

Milestone
= 用户确认的阶段性业务目标和范围

Iteration Plan
= 在团队容量、Size、依赖和风险约束下形成的分批实施路线
```

不得把 Path 或 Milestone 机械映射成 Iteration。一个 Milestone 可以跨多个 Iteration；一个 Iteration 也可以推进多个 Milestone。Iteration 可以跨 Feature 和 Path，但必须形成明确的迭代目标，并尊重 Story Map 优先级和硬依赖。

### 默认团队假设

首次形成 Iteration Plan 时，Work Item Planning 默认使用：

```text
Team Size: 8
Team Profile: Cross-functional delivery team
Availability: Normal
Iteration Capacity: Not calibrated
```

默认假设用于让规划可以立即开始，不表示目标仓库已经确认真实团队配置。不得从 Git 作者、提交历史或系统账户推断团队人数、角色或可用性。仓库已有可信团队配置时优先读取；没有时使用默认假设。

开始时不得要求用户一次性确认团队人数、成员组成、技能、休假、历史吞吐量和其他完整参数。只有发现明确专业能力瓶颈、用户说明特殊可用性，或仓库事实与默认假设冲突时，才提出一个当前规划必需的问题。

### 首个迭代容量校准

Work Item Planning 必须先只形成一个候选迭代，不得在容量尚未校准时直接把全部工作排入多个 Iteration。候选必须综合：

- 当前优先 Milestone；
- Story Map 顺序；
- Story 的 `Ready` 状态；
- Task 和 Bug 的不确定性；
- 硬依赖；
- 已确认 Size；
- 默认团队假设；
- 是否形成可验证的阶段性结果；
- 是否集中放入过多 `L`、`XL` 或 `?` 工作项；
- 是否存在明显的专业能力瓶颈。

候选摘要至少展示 Iteration Goal、工作项 ID、类型、Size、选择原因、Size 分布、团队假设和已知不确定性。然后使用以下确认问题：

> 当前候选按“8 人跨职能团队、正常可用性”的默认假设形成。你认为这些卡片安排在一个迭代内是否合适？如果工作量偏多或偏少，或者实际团队人数、角色构成、可用性与默认假设不同，请说明差异；我会先调整当前迭代，再以确认后的容量安排后续迭代。

用户只回答“合适”即可继续，不需要逐项确认团队配置。其他回答按以下规则处理：

- 用户认为工作量偏多或偏少时，代理根据优先级、依赖和业务闭环主动调整候选，不要求用户自行计算容量。
- 用户补充团队人数、角色构成或可用性时，更新团队画像，检查专业能力瓶颈并重新形成首个候选迭代。
- 用户不确定时，采用保守方案，减少候选范围并保留容量缓冲。
- 用户只要求移入或移出某张卡片时，重新检查 Size 分布、依赖和迭代目标，其他团队假设保持不变。

首个迭代确认后，它的工作项组合、Size 分布和当时采用的团队画像共同构成当前 Iteration Plan 的容量基准。

### 剩余迭代安排

容量基准确认后，Work Item Planning 才安排剩余工作项：

- 后续 Iteration 的规模参考已确认首个迭代，不使用跨团队通用的 `Size -> 人日` 换算。
- 比较工作项总量以及 `XS / S / M / L / XL / ?` 分布，不只比较卡片数量。
- 保持硬依赖、Story Map 优先级和 Milestone 目标。
- 避免把多个 `XL`、`?` 或高风险 Bug 集中在同一个 Iteration。
- 检查团队角色构成带来的专业能力瓶颈；没有具体构成时明确沿用默认跨职能团队假设。
- 每个 Iteration 必须有明确 Goal；工作无法合理装入时增加 Iteration，不为了减少迭代数量而超载。
- 工作项可以暂不安排 Iteration，继续保留在 Story Map 或 Backlog。
- 同一个未完成工作项只能安排到一个 Iteration。

完整计划必须说明哪些 Iteration 与容量基准相近、哪些因依赖而偏小、哪些包含较高不确定性，以及哪些判断依赖默认团队配置。用户确认完整 Iteration Plan 后才写入 Story Map。

### Story Map 中的记录

Story Map 至少保存规划依据和完整 Iteration Plan：

```text
Iteration Planning Basis
-> Team Size
-> Team Profile
-> Availability
-> Capacity Baseline Iteration
-> Baseline Size Distribution
-> Known Constraints

Iteration Plan
-> Iteration
-> Goal
-> Included Work Items
-> Size Distribution
-> Dependencies
-> Risks And Uncertainty
```

Iteration 不提前绑定固定日期，除非用户明确要求。Iteration Plan 可以引用 Story Map 中的 Story 和必要 Task，也可以引用本次实施路线需要的 Bug 或只存在于 Backlog 的独立 Task；后两类工作项不会因此进入 Story Map 主表。

进入 Iteration Plan 的 Bug 和独立 Task 也必须使用同一基准卡完成 Size 估算。它们的 Size 写入卡片和 Backlog，并进入 Iteration 的 Size 分布，但不会因此写入 Story Map 主表。

工作项未完成时不得自动移动到下一 Iteration，必须在后续 Work Item Planning 中重新确认。调整 Iteration 不改变工作项定义，因此不自动递增卡片版本。Iteration Plan 不保存实际开发进度；状态仍由卡片和 Backlog 管理。

增量规划默认复用现有团队画像和容量基准。团队规模、角色构成、可用性或实际交付能力明显变化时，必须重新形成并确认一个候选迭代，再更新剩余计划。

## 工作项模型

| 类型 | ID | 规划职责 |
| --- | --- | --- |
| Story | `S-nnn` | 表达某类用户或业务角色希望实现的目标和价值，并归属于一个主要 System Feature。 |
| Task | `T-nnn` | 表达使 Feature、Story 或交付范围成立，但不适合写成 User Story 的明确工作。 |
| Bug | `B-nnn` | 表达既有预期行为与已观察行为之间的候选偏差；建卡时不要求确认根因。 |

Feature 使用 Discovery 分配的 `F-nnn`，不是工作项卡片类型。Story、Task 和 Bug ID 在仓库内全局唯一。

Task 可以使用可选 `Nature` 描述其性质，例如 `Functional`、`Technical`、`Business Preparation`、`Migration` 或 `Verification`。`Nature` 不产生不同状态模型或独立卡片类型。

## 轻量卡片与状态

Work Item Planning 可以创建轻量卡片：

```text
ID
Version
Status
Title
简短目标或业务结果
产品或工作项引用
Size（进入 Story Map 时）
Change Log
```

卡片状态使用：

- `Draft`：工作项已识别，但尚未完成需要的分析。
- `Ready`：Story 已经完成 Work Item Analysis 并具备进入 `feature-dev` 的条件；其他类型可以使用，但不是统一开发硬门禁。
- `In Progress`：正在通过 Delivery Workflow 交付。
- `Blocked`：被开放问题、决策冲突或未满足依赖阻塞。
- `Done`：开发、验证和业务验收已经闭环。
- `Superseded`：已被新的工作项替代，不应再选择实施。
- `Dropped`：经过明确决策后不再计划处理。

Story 必须达到 `Ready` 才能进入 `feature-dev`。Task 不强制提前达到 `Ready`，可以在对应 Delivery Workflow 开始时分析目标、范围和完成条件；用户确认本次实施范围前不得修改代码。Bug 可以直接进入 `bug-fix`，不以 `Ready` 或已知根因为启动条件。

Task 分析发现实际需要新的产品行为时，不得继续把它伪装成 Task；必须建立或关联 Story，并按 Story 的 Work Item Analysis 和 `Ready` 规则处理。

## Backlog 与关系

统一 Backlog 是工作项状态、优先级、关系、阻塞和建议实施顺序的权威汇总视图。Story Map 保存业务结构、Path、Milestone 和 Size，不复制卡片正文；Backlog 也不复制卡片详细定义。

Backlog 的首次创建、文档结构、排序规则和规划使用方式必须由 Work Item Planning 定义。组合规划或单项登记发现目标仓库尚无统一 Backlog 时，由 Work Item Planning 在用户确认规划结果后创建；不得要求其他 workflow 先创建 Backlog，也不得创建 Product Backlog、Sprint Backlog 或其他平行工作项集合。

Work Item Planning 是 Backlog 结构、生命周期区块和规划排序契约的唯一权威来源。统一 Backlog 必须固定使用 `进行中`、`待处理`、`已完成`、`已关闭` 四个生命周期区块，并且四个区块都使用 `ID | Title | Version | Status | Priority` 五列表头。

Backlog 行只汇总卡片身份和规划状态；卡片正文、验收条件、Change Log、workflow 运行证据和其他卡片专属字段继续留在卡片或交付记录中，不在 Backlog 表格重复。`待处理` 区块从上到下是唯一权威的建议实施顺序，除非本次已确认规划明确改变该建议，否则不得重排。待处理首项不能推进时，必须先确认并调整待处理顺序，不得静默跳过。

`已关闭` 区块保留历史关闭摘要时，如果对应的旧事项已经没有存续中的当前卡片，可以继续保留一行紧凑摘要，并对不再属于当前卡片的字段使用 `-`，而不是伪造新的卡片元数据。

其他 workflow 可以按照既有 Backlog 结构同步其职责范围内的工作项生命周期变化，但不得重新定义 Backlog 布局、改变规划排序规则或执行无关工作项重排。需要改变 Backlog 结构、优先级或规划顺序时必须返回 Work Item Planning。

- 组合规划更新本次范围内的工作项和必要关系，不机械重排无关 Backlog。
- 单项登记只更新当前卡片及必要 Backlog 引用。
- Task 可以关联 Feature 或 Story；没有明确产品关系的通用 Task 可以只进入 Backlog。
- Bug 关联受影响的 Feature 或 Story，但不进入 Story Map。
- 硬依赖、阻塞、替代和关联关系必须显式记录，不能只依赖 Story Map 位置推断。

## 卡片版本与共享修改权

- 每张 Story、Task 和 Bug 卡片使用从 `1` 开始的独立递增整数版本号。
- 目标、范围、预期行为、验收或完成条件、关键依赖或需求决策发生实质变化时必须升版。
- 仅修正拼写、排版、链接、执行状态或 Size 时不升版。
- Change Log 使用 `Version | Recorded At | Recorded By | Change | Reason`；身份和时间规则与其他 Asset Workflow 保持一致。
- Git 历史负责保存完整旧内容，卡片不记录 commit hash、checkpoint 或 workflow 状态。

卡片是跨 workflow 共享的长期权威资产，不由创建它的 workflow 独占。各 workflow 可以在自身职责范围内根据已确认事实创建或更新卡片：

- Work Item Planning 更新规划关系、Story Map、Milestone、Size 和 Backlog 信息。
- Work Item Analysis 更新目标、范围、预期行为、验收或完成条件、异常现象、影响和需求决策。
- Delivery Workflow 更新诊断证据、选定范围、交付状态、结果、验证、验收和交付引用。
- Discovery 只有在用户明确要求协调产品设计与工作项时才更新产品追溯关系，不因产品资产变化自动改卡。

发现已有卡片时必须复用，不得创建重复 ID 或平行卡片。写回前必须检查当前卡片版本；发现事实或版本冲突时不得静默覆盖，必须展示冲突并由用户决定。

## 产品设计变化的规划协调

Discovery 发现工作项可能受影响时，只报告影响，不自动修改 Story Map、Milestone、卡片或 Backlog。用户明确要求协调规划时，Work Item Planning：

1. 对比 Feature ID、Type、标题、业务身份和顺序；
2. 识别受影响的 Story Map 位置、Milestone、卡片关系和 Backlog；
3. 对被删除或替代 Feature 下的工作项提出保留、移动、标记 `Superseded` 或移出 Story Map 的方案；
4. 用户确认后原子更新所有受影响规划资产。

不得因为 Feature 变化自动删除 Story、Task 或 Bug，也不得用已实现代码反向改写产品设计共识。

## 与其他 Workflow 的关系

```text
discovery
-> User Journey + Feature + PRD + Business Architecture

work-item-planning
-> Story Map + Milestone + Iteration Plan + 轻量 Story / Task / Bug + Backlog

work-item-analysis
-> 单项或批量分析 Story / Task / Bug

feature-dev / bug-fix / refactor
-> 技术方案、实施、验证、验收和交付证据
```

Work Item Planning 负责回答需要交付哪些工作以及如何组织，不负责详细回答每个工作项具体要交付什么，也不负责回答如何实现。
