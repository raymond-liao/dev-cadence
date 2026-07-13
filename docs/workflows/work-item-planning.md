# 工作项规划流程

本文说明 Dev Cadence 的 `work-item-planning` 业务流程，包括适用场景、阶段目标、主要产出以及与其他 workflow 的边界。本文面向 Dev Cadence 维护者、流程评审者和希望了解工作项治理模型的使用者。

目标仓库中的实际执行规则将由 `src/skills/work-item-planning/SKILL.md` 定义并生成安装内容。本文用于说明业务流程设计，不替代 workflow skill。

## 目的

工作项规划流程是 Feature、Story、Bug 和 Technical Task 卡片的统一创建与维护入口。它既可以读取已确认的 PRD 并规划一组工作项，也可以接收用户直接提出的单项工作并建立对应卡片。卡片可以从只有 ID 和标题开始，随后在分析中逐步完善。

## 适用场景

- 首次将已确认 PRD 拆分成 Feature 和工作项。
- 增量维护已有 Feature、Story、Bug、Technical Task 和 Roadmap。
- 根据新需求、用户反馈、已知缺陷或工程需求增加和调整卡片。
- 为没有现有卡片的单项功能、Bug 或技术任务创建并确认工作项卡片。
- 分析工作项的依赖、阻塞、优先级、实施顺序和下一步动作。

## 不适用场景

- 从模糊想法建立或更新 PRD：使用 `discovery`。
- 对单个工作项进行技术设计和开发实施：使用 `feature-dev`、`bug-fix` 或 `refactor`。
- 执行发布、部署或生产事故处理：不属于当前流程范围。

## 流程阶段

| 阶段 | 目标 | 主要产出 |
|---|---|---|
| 1. 规划输入确认 | 读取已确认的 PRD 和现有规划资产，或者读取用户直接提出的单项工作；判断本次采用组合规划模式还是单项登记模式，并明确受影响范围。 | 规划模式；输入基线；受影响范围 |
| 2. Feature 组织 | 在组合规划模式下，按用户能力、业务领域或平台关注点建立或调整 Feature；单项登记模式不强制创建或关联 Feature。 | `F-nnn` Feature 卡片或 Feature 关联结论 |
| 3. 工作项识别 | 从 PRD、反馈、缺陷、工程需求或单项请求中识别 Story、Bug 和 Technical Task，为每项工作分配稳定 ID 和标题。 | `S-nnn`、`B-nnn`、`T-nnn` 卡片 |
| 4. 卡片分析 | 逐步补充目标、范围、验收或完成条件、业务或技术规则、依赖、开放问题、相关决策和 Change Log，并更新成熟度状态。 | 已更新的工作项卡片 |
| 5. 关系与顺序规划 | 识别依赖、阻塞、扩展、修改、替代和关联关系，并综合用户价值、风险降低、基础能力和可测试性确定建议顺序。 | 工作项关系；建议实施顺序 |
| 6. Roadmap 确认 | 汇总 Feature 和工作项的状态、优先级、依赖及下一步动作，由用户确认本次规划结果。 | 已确认的 Roadmap 更新 |

## 规划模式

### 组合规划模式

组合规划模式用于从已确认的 PRD 建立或增量维护一组规划资产：

```text
已确认的 PRD
      |
Feature 拆分
      |
多个 S / B / T 卡片
      |
依赖、顺序和 Roadmap
```

该模式必须记录使用的 PRD 版本，并在产品级需求发生变化时返回 `discovery` 更新 PRD。

### 单项登记模式

单项登记模式用于处理没有现有卡片的明确工作请求：

```text
单项功能、Bug 或技术任务
          |
识别 S / B / T 类型
          |
创建和分析一张卡片
          |
用户确认进入开发所需的信息
          |
移交对应开发 workflow
```

该模式不要求先有 PRD，不强制创建 Feature，也不重排无关工作项。新卡片仍必须进入统一 Roadmap，以保持项目级追溯能力。

## 工作项模型

| 类型 | ID | 职责 |
|---|---|---|
| Feature | `F-nnn` | 组织共享业务能力、领域或平台关注点，不直接进入开发 workflow。 |
| Story | `S-nnn` | 描述需要新增或有意改变的用户或业务行为。 |
| Bug | `B-nnn` | 描述既有预期行为与实际行为之间的偏差；创建时不要求已经确认根因。 |
| Technical Task | `T-nnn` | 描述工程能力、技术债、基础设施或治理工作，不伪装成用户故事。 |

工作项类型说明工作为什么存在，开发 workflow 说明工作如何交付：

```text
S-nnn -> feature-dev
B-nnn -> bug-fix
T-nnn -> feature-dev / bug-fix / refactor
```

## 卡片状态

- `Draft`：工作项已经被识别，但仍在分析。
- `Needs Review`：已形成可审阅内容，等待用户或业务确认。
- `Ready`：工作项已经具备进入对应开发 workflow 的条件；它不表示已经完成该开发 workflow 的需求确认、问题诊断或技术设计。
- `Blocked`：被开放问题、决策冲突或未满足依赖阻塞。
- `In Progress`：正在通过开发 workflow 交付。
- `Done`：开发、验证和业务验收已经闭环。
- `Superseded`：已被新的工作项替代，不应再选择实施。
- `Dropped`：经过明确决策后不再计划处理。

## 卡片版本与历史

- 每张 Feature、Story、Bug 和 Technical Task 卡片使用从 `1` 开始的独立递增整数版本号。
- 目标、范围、验收或完成条件、行为预期、依赖、约束或决策发生实质变化时必须升版并增加卡片内 Change Log。
- 仅修正拼写、排版或链接时不升版。
- Change Log 记录版本、日期、变化摘要和原因，不记录 Git commit hash。
- 卡片版本是 workflow 引用和影响判断使用的业务身份；Git 历史负责保存完整旧内容。

## 卡片与开发记录的边界

工作项卡片是长期、跨运行的权威定义。开发 workflow 的第一阶段记录保存本次运行使用的卡片版本、选定范围和用户确认，不完整复制卡片并形成第二份权威需求。

Story 或 Technical Task 进入 `feature-dev` 或 `refactor` 时，第一阶段记录至少引用：

```text
Work Item
Card Path
Card Version
Selected Scope For This Run
Included Acceptance Or Completion Criteria
Explicit Exclusions
Run-Specific Clarifications
User Confirmation
```

Bug 卡片保存长期问题身份、期望行为、已观察行为、影响和已知复现条件。`bug-fix` 的问题诊断记录保存本次调查产生的复现证据、假设、根因、因果证据、修复边界和回归风险。

准确分工是：

```text
工作项卡片：工作项的权威定义和长期演进
阶段记录：本次 workflow 使用的卡片版本、选定范围和确认结果
manifest：本次 workflow 的运行状态、阶段索引和 checkpoint commit
Git 历史：卡片和规则文件的完整内容历史
```

## 卡片创建与移交

- `work-item-planning` 是 Feature、Story、Bug 和 Technical Task 卡片的唯一创建者。
- `using-dev-cadence` 收到开发请求时先检查是否存在对应卡片；没有卡片时必须先进入 `work-item-planning`，不得由开发 workflow 自行建卡。
- 用户不需要手动发起两次请求。入口选择器可以先运行单项登记模式，卡片确认后再路由到对应开发 workflow。
- 请求引用已有卡片时必须复用，不创建重复 ID 或平行卡片。
- 单项登记只处理当前工作，不执行批量拆解、无关 Roadmap 重排或无关需求分析。
- 卡片达到 `Ready` 且不存在阻止启动的依赖后，移交 `feature-dev`、`bug-fix` 或 `refactor`。
- 开发 workflow 启动后将卡片更新为 `In Progress`；完成后回写 `Done`、验收结果和交付引用。

## 关键规则

- 卡片可以从只有 ID 和标题开始；`Draft`、`Blocked` 和 `Ready` 描述分析成熟度，不是卡片是否允许存在的条件。
- 不得为了消除 `Draft` 或 `Blocked` 而机械拆分缺乏独立价值或独立验收意义的工作项。
- Technical Task 不必强制归属某个 Feature；跨 Feature 的平台、基础设施和治理任务可以独立存在，但必须记录影响范围。
- Bug 不要求在建卡时确认根因；根因定位属于 `bug-fix` 的问题诊断阶段。
- Roadmap 是汇总视图，不是卡片详细内容的权威来源；标题、状态和关系变化时必须同步。
- 产品级需求发生变化时不得在卡片中静默改写 PRD，应返回 `discovery` 更新并确认 PRD 后再进行增量规划。
- 已进入开发的卡片升版后必须判断当前 run 是否受影响；受影响时返回最早受影响阶段，不受影响时记录判断依据。
- 工作项卡片和 Roadmap 保存在目标仓库正常项目空间，不得写入可替换的 `.dev-cadence/` 安装包。
- 不生成额外业务 Run Log；Dev Cadence manifest 和阶段记录保存 workflow 执行过程。

## 与其他 Workflow 的关系

```text
已确认的 PRD
      |
work-item-planning
      |
F / S / B / T + Roadmap
      |
feature-dev / bug-fix / refactor
```

`discovery` 负责 PRD，`work-item-planning` 负责创建和维护工作项，三个开发 workflow 负责消费已有卡片并完成单项交付。明确的单项请求如果没有卡片，先经过 `work-item-planning` 的单项登记模式，再进入对应开发 workflow。
