# 工作项分析流程

本文说明 Dev Cadence 的 `work-item-analysis` 业务流程，包括 Story、Task 和 Bug 的单项或批量分析、用户确认、卡片更新，以及与 Discovery、Work Item Planning 和 Delivery Workflow 的边界。本文面向 Dev Cadence 维护者、流程评审者和希望了解工作项需求治理模型的使用者。

目标仓库中的实际执行规则将由 `src/skills/work-item-analysis/SKILL.md` 定义并生成安装内容。本文用于说明业务流程设计，不替代 workflow skill。

## 目的

工作项分析流程把轻量 Story、Task 或 Bug 完善为经过用户确认的权威工作项定义。它既支持分析一个工作项，也支持用户明确选择一组工作项进行批量分析。

Work Item Analysis 负责回答工作项具体要解决什么、包含什么、排除什么，以及如何判断目标成立。它不重新建立产品级需求，不规划 Story Map、Milestone 或 Backlog 顺序，也不设计技术实现。

```text
轻量 Story / Task / Bug 或用户直接输入
                |
       work-item-analysis
                |
经过确认的工作项卡片
```

Work Item Analysis 是 Asset Workflow。它只创建或更新长期权威卡片，不创建 `build/dev-cadence/` run manifest、阶段记录、确认记录或 checkpoint。

## 适用场景

- 分析一个 Story 的用户目标、范围、行为、规则和验收条件。
- 分析一个 Task 的目标、范围、完成条件和影响。
- 收集 Bug 的异常现象、期望行为、实际行为、影响和已知复现条件，并确认它是否应作为 Bug 处理。
- 批量分析用户明确选择的一组 Story、Task 和 Bug。
- 补充或修订已有工作项卡片的权威定义。
- 识别工作项之间的重复、重叠、冲突和直接依赖，并由用户决定如何处理。

## 不适用场景

- 建立或改变 Journey、Feature、PRD 或 Business Architecture：使用 `discovery`。
- 创建或更新 Story Map、Milestone、Size 估算、规划优先级或 Backlog 顺序：使用 `work-item-planning`。
- 调查并证明 Bug 根因、设计修复方案或实施修复：使用 `bug-fix`。
- 设计技术方案、修改代码、执行实现测试或完成业务验收：使用对应 Delivery Workflow。

## 分析模式

### 单项分析

单项分析只处理一个 Story、Task 或 Bug。请求引用已有卡片时必须复用；没有卡片时可以创建轻量卡片并在同一次分析中完善。

### 批量分析

批量分析处理用户明确选择的工作项集合：

```text
选定工作项集合
-> 读取共同产品和规划上下文
-> 逐项分析
-> 识别重复、重叠、依赖和冲突
-> 展示逐项结果
-> 用户确认全部或部分更新
```

- 不得自动把范围扩展到整个 Backlog。
- 每张卡片保持独立 ID、版本、状态、正文和 Change Log。
- 共同背景可以复用为分析输入，但不能用一份批量摘要替代各卡片的权威内容。
- 某张卡片信息不足时可以保持 `Draft` 或进入 `Blocked`，不阻止其他卡片完成分析。
- 用户可以只确认部分卡片；未确认卡片保持原权威内容不变。
- 发现重复或重叠时必须提出合并、替代或保留建议，不得自动删除或合并卡片。

## 流程阶段

| 阶段 | 目标 | 主要产出 |
| --- | --- | --- |
| 1. 分析范围确认 | 确认单项或批量模式、选定卡片、当前版本、权威产品和规划输入，以及本次不处理的内容。 | 分析范围；输入基线 |
| 2. 工作项定义分析 | 按类型分析 Story、Task 或 Bug，区分事实、假设、开放问题和候选方向；识别重复、冲突和产品基线缺口。 | 完整工作项提案 |
| 3. 工作项确认 | 逐项展示拟议正文、状态、版本变化、未决问题和后续路由；用户确认后原子更新被接受的卡片。 | 已确认的卡片更新；后续 workflow 路由 |

确认前只维护会话提案，不得提前写入正式卡片。用户反馈只更新当前提案并重新展示受影响内容。

## Story 分析

Story 从用户或业务角色视角表达其目标和价值。分析至少明确：

- 用户或业务角色；
- 目标、场景和期望业务价值；
- 主要 System Feature 及必要产品追溯；
- 包含范围和明确排除范围；
- 可观察的产品行为；
- 适用业务规则和约束；
- 验收条件；
- 直接依赖、开放问题和已确认决策。

Story 必须达到 `Ready` 才能进入 `feature-dev`。达到 `Ready` 至少要求目标、范围、主要 Feature、验收条件和阻止开发的开放问题已经明确，并且用户已确认工作项定义。

Work Item Analysis 不为 Story 选择技术方案。分析发现需要新的 Journey、Feature、产品责任或业务架构结论时，必须返回 Discovery，不能把新的产品级结论静默写进 Story。

## Task 分析

Task 表达使 Feature、Story 或交付目标成立，但不适合写成 User Story 的明确工作。分析可以明确：

- 工作目标和必要性；
- 包含范围和排除范围；
- 完成条件；
- 相关 Feature、Story 或影响范围；
- 适用约束、依赖、风险和开放问题；
- 可选 `Nature`。

Task 不强制在实施前经过 Work Item Analysis，也不强制达到 `Ready`。对应 Delivery Workflow 可以在开始实施时补充并确认目标、范围和完成条件，但确认本次实施范围前不得修改代码。

Task 分析发现实际需要新的用户或业务行为时，不得继续把它包装成 Task；必须建立或关联 Story，并按 Story 的分析和 `Ready` 规则处理。

## Bug 分析及与 Bug Fix 的边界

Work Item Analysis 对 Bug 是可选入口。它可以：

- 收集和整理异常现象；
- 明确已有期望行为和已观察行为；
- 分析影响范围和严重程度；
- 记录已知环境、触发条件和复现信息；
- 判断现有证据是否支持把问题作为 Bug 处理；
- 区分 Bug、预期行为变更和信息不足；
- 定义修复后的业务验收预期；
- 关联受影响的 Feature、Story 或其他工作项。

Work Item Analysis 不调查或确认技术根因。`bug-fix` 的核心职责是：

```text
补充必要异常和复现信息
-> 实际复现或建立等价失败证据
-> 调查假设
-> 找到并证明根因
-> 确定修复边界和回归风险
-> 实施、验证和业务验收
```

用户明确报告异常并要求调查或修复时，可以直接进入 `bug-fix`，不得因为缺少 Work Item Analysis、完整复现步骤、`Ready` 状态或已知根因而拒绝启动。`bug-fix` 可以创建或补充 Bug 卡片，并复用已有卡片中的已确认事实。

Work Item Analysis 把 Bug 标记为 `Ready` 只表示信息适合开始诊断，不表示根因已经找到。`Ready` 不是进入 `bug-fix` 的硬前置条件。

`bug-fix` 发现实际行为符合现有预期时，不得伪造根因；必须说明当前证据不支持该问题是 Bug，并由用户决定关闭、转为 Story，或返回 Work Item Analysis。信息不足时应继续补充证据，只有无法建立异常或预期行为时才要求必要的用户输入。

## 产品基线与规划边界

Work Item Analysis 可以读取 User Journey、PRD、Business Architecture、Story Map、Milestone、Backlog 和相关卡片，但只更新选定工作项的权威定义。

- 发现缺少产品级结论时返回 Discovery。
- 发现需要改变 Story Map、Milestone、Size 或 Backlog 顺序时，只记录规划影响并返回 Work Item Planning。
- 不根据代码现状反向修改产品需求。
- 不把技术方案、模块、数据库、API、协议或实现参数写成已经确认的工作项需求。
- Discovery、Work Item Planning 或 Delivery Workflow 已确认的事实可以作为输入，但发生冲突时不得静默覆盖。

## 卡片更新与版本

- Work Item Analysis 可以创建或修改 Story、Task 和 Bug 卡片，不独占卡片维护权。
- 发现已有卡片时必须复用，不得创建重复 ID 或平行卡片。
- 目标、范围、预期行为、验收或完成条件、关键依赖或需求决策发生实质变化时必须递增卡片版本。
- 只有内容实质变化的卡片才升版；拼写、排版、链接、执行状态或 Size 变化不升版。
- Change Log 使用 `Version | Recorded At | Recorded By | Change | Reason`，不记录 Git commit hash、checkpoint 或 workflow 状态。
- 写回前必须检查当前卡片版本；发现并发变化或事实冲突时停止覆盖并由用户决定。
- Work Item Analysis 不修改 Size。发现范围变化可能导致 Size 失效时标记需要重新估算，并返回 Work Item Planning。

## 确认与后续路由

最终确认必须逐项说明：

- 卡片路径、当前版本和拟议版本；
- 工作项类型、目标、范围和关键条件；
- 状态是否变化及原因；
- 未解决问题、冲突和风险；
- 是否需要 Discovery 或 Work Item Planning 协调；
- 下一步 Delivery Workflow。

确认后的默认路由：

```text
Ready Story -> feature-dev
Task -> feature-dev / bug-fix / refactor，按实施目标选择
Bug -> bug-fix，不要求 Ready
```

批量分析不会自动批量启动 Delivery Workflow。用户明确选择要交付的工作项后，分别按卡片类型和关系进入相应 workflow。

## 与其他 Workflow 的关系

```text
discovery
-> 产品级需求与 Feature

work-item-planning
-> Story Map、Milestone、轻量工作项、Size 和 Backlog

work-item-analysis
-> 单项或批量完善 Story、Task 和 Bug

feature-dev / bug-fix / refactor
-> 技术方案、实现、验证、验收和交付证据
```

Work Item Analysis 负责确认和定义工作项；`bug-fix` 负责通过诊断找到并证明 Bug 根因；Delivery Workflow 负责如何实现并证明交付完成。
