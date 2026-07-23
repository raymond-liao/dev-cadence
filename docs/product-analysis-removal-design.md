# Dev Cadence 产品分析能力移除方案

## 文档状态

- 状态：已实施并通过验证，尚未提交
- 适用仓库：Dev Cadence 源码仓库
- 目的：明确移除产品级分析能力后，Dev Cadence 保留的软件实施治理边界

本文记录已经确认并实施的能力边界及实施结果。它不是 workflow 执行规则，不替代 `src/workflows/**/SKILL.md`；实际执行以 workflow skill 为准。

## 背景

当前 Dev Cadence 同时包含产品分析、工作项规划、单卡需求分析和软件交付能力。产品方案、User Journey、Feature、Story Map、Milestone、MVP 等内容使项目承担了超出软件实施治理的产品职责，增加了流程重量、规则数量和偏离实施目标的风险。

Dev Cadence 后续应聚焦软件实施，但这不意味着移除工作项治理。实施仍然需要自己的 Story、Task、Bug 卡片、单卡需求分析能力和统一 Backlog。

## 已确认需求

1. Dev Cadence 不再负责产品级分析和产品组合规划。
2. Dev Cadence 必须保留自己的 `docs/delivery/backlog.md`。
3. Dev Cadence 必须保留自己的 Story、Task 和 Bug 卡片。
4. Dev Cadence 必须保留针对单张卡片的需求分析能力。
5. 已在外部完成分析的卡片，如果符合 Dev Cadence 卡片要求，可以不重新建卡、不重复执行单卡需求分析，直接登记到 Backlog 后进入实施。
6. 外部卡片如果不符合 Dev Cadence 卡片要求，不增加专用转换或兼容流程，而是把它作为新需求输入，执行标准建卡流程。
7. 不符合要求的外部卡片不应被覆盖或删除；当前方案不额外设计归档目录、字段映射、外部 ID 映射或双向同步机制。
8. 用户明确授权开始修改前，本方案只用于讨论和设计，不触发 workflow、Backlog、工作项、版本或 Git 变更；本次实施已在获得授权后开始。

## 目标能力边界

Dev Cadence 的目标责任链为：

```text
需求或已有工作项
-> 工作项准入
-> 必要的单卡需求分析
-> Dev Cadence Backlog
-> 工作项认领
-> Feature Dev / Bug Fix / Refactor
-> 方案、计划、实施、Review、测试和验收
-> 卡片与 Backlog 生命周期回写
```

Dev Cadence 从可形成实施工作项的输入开始承担责任，不再向上负责发现产品问题、定义产品能力或规划产品组合。

## Workflow 结构

### `backlog`

现有 `work-item-planning` 应收窄并改名为 `backlog`。

`backlog` 拥有以下职责：

- 创建 Dev Cadence Story、Task 和 Bug 卡片；
- 校验用户放入的外部卡片是否符合 Dev Cadence 卡片契约；
- 将合规卡片及其必要 Backlog 引用作为一个原子变更登记；
- 维护 Backlog 的结构、排序和工作项生命周期；
- 在卡片需要需求分析时路由到 `work-item-analysis`；
- 在卡片满足实施条件后路由到对应 Delivery Workflow。

`backlog` 不负责：

- 产品问题探索；
- PRD、Business Architecture 或 User Journey；
- Feature 定义或产品能力设计；
- Story Map、Milestone、MVP 或跨卡产品组合规划；
- 复制 `work-item-analysis` 的单卡分析过程；
- 复制 Delivery Workflow 的方案、计划、实施或验证记录。

`backlog` 具有独立用户目标和权威资产所有权：用户可以直接要求创建工作项、登记合规外部卡片、维护 Backlog 或调整实施顺序。该职责不能合并到 `work-item-analysis`，因为合规外部卡片不需要重复分析。

### `work-item-analysis`

`work-item-analysis` 继续作为独立 workflow，每次只分析一张 Story、Task 或 Bug 卡片。

它负责补充和确认单卡实施所需的目标、范围、完成条件、依赖、约束和未决问题，并根据工作项类型判断是否满足下游实施条件。

它不负责：

- 产品级需求发现；
- Feature 或 User Journey 定义；
- Story Map、Milestone 或 MVP；
- Backlog 结构、排序和生命周期所有权；
- 技术根因分析、技术方案或实施计划。

分析完成后，卡片返回 `backlog` 完成登记或状态同步，再由入口路由到对应 Delivery Workflow。

### Delivery Workflows

以下 workflow 保留其软件实施职责：

- `feature-dev`：新增或有意改变系统可见行为；
- `bug-fix`：恢复已经存在但未正确工作的预期行为；
- `refactor`：在不主动改变预期行为的前提下改善内部结构。

Delivery Workflow 继续负责需求确认记录、技术方案或修复方案、Implementation Plan、实现、Review、测试、业务验收、Git 集成和完成后的生命周期回写。移除产品分析不得删除这些实施阶段。

## 工作项准入流程

### 新需求

```text
用户提出新需求
-> `backlog` 创建 Story / Task / Bug 卡片
-> 根据卡片类型和成熟度判断是否需要 `work-item-analysis`
-> 卡片满足实施条件
-> 登记到 Backlog
-> 认领并进入对应 Delivery Workflow
```

该流程不自动把 workflow 内部阶段提升为新的卡片状态，也不因为移除产品分析而增加新的成熟度状态。

### 符合要求的外部卡片

```text
用户放入外部已分析卡片
-> `backlog` 校验 Dev Cadence 卡片契约
-> 校验通过
-> 不重新建卡
-> 不重复执行 `work-item-analysis`
-> 登记到 Backlog
-> 认领并进入对应 Delivery Workflow
```

“符合要求”必须同时表示卡片结构可由 Dev Cadence 管理，并且内容与成熟度足以进入对应实施流程。只有文件格式相似但实施信息不足的卡片不能绕过标准建卡和分析流程。

### 不符合要求的外部卡片

```text
用户放入外部卡片
-> `backlog` 校验未通过
-> 不执行格式转换、字段映射或兼容导入
-> 将其内容视为新需求输入
-> 执行标准建卡流程
-> 必要时执行 `work-item-analysis`
-> 登记到 Backlog
-> 进入实施
```

标准建卡流程创建的 Dev Cadence 卡片是后续 Backlog 和交付生命周期使用的权威卡片。原始输入保持原状，但当前方案不为它增加专用归档、同步或长期所有权规则。

## Backlog 与卡片所有权

- Story、Task 和 Bug 卡片保存工作项的完整事实、范围、完成条件、关系和自身状态。
- `docs/delivery/backlog.md` 汇总工作项并表达统一实施入口、当前生命周期和建议实施顺序。
- Backlog 只登记符合 Dev Cadence 契约的权威卡片。
- 卡片与必要 Backlog 引用必须原子创建或更新，不能产生孤立卡片或孤立 Backlog 行。
- Delivery Workflow 完成、关闭或改变工作项生命周期时，继续按现有闭环要求同步卡片和 Backlog。
- 状态模型保持满足当前实施治理的最小集合；本方案不新增状态。

## 移除范围

实施本方案时，应从 Dev Cadence 的可安装包、入口路由、规则、说明和契约测试中移除以下产品级能力：

- Discovery 产品探索；
- PRD；
- Business Architecture；
- User Journey；
- Feature Definition；
- Story Map；
- Milestone；
- MVP 与后续产品切片；
- 从产品资产推导工作项；
- 产品资产变化向规划资产传播；
- 跨卡产品组合规划及其确认门禁。

`work-item-planning` 中的 Direct Intake、卡片创建、Backlog 登记、排序和生命周期职责不应随 Portfolio Planning 一起删除，而应迁移到 `backlog`。

## 明确保留范围

- `using-dev-cadence` 的交付入口选择与活动任务恢复；
- `backlog` 的工作项准入与 Backlog 所有权；
- `work-item-analysis` 的单卡需求分析；
- Story、Task 和 Bug 卡片；
- `feature-dev`、`bug-fix` 和 `refactor`；
- 任务级方案与 Implementation Plan；
- 实现、Review、测试、验证和业务验收；
- Delivery Workflow 的 manifest 和阶段记录；
- Git、分支、worktree、checkpoint、恢复和清理治理；
- 卡片与 Backlog 的交付生命周期闭环。

## 不在本方案范围

以下相邻能力不因本方案自动保留、删除或重构，应在后续单独评估：

- 独立的 `architecture-design` workflow；
- Open Question Registry；
- 外部工作项系统集成；
- 外部卡片格式适配器；
- 原始外部卡片的专用归档体系；
- 卡片跨系统双向同步。

## 实施影响

获得明确实施授权后，至少需要评估和修改：

- `src/workflows/using-dev-cadence/SKILL.md` 的候选路由、资产模型、认领和交接规则；
- 将 `src/workflows/work-item-planning/SKILL.md` 收窄并迁移为 `src/workflows/backlog/SKILL.md`；
- `src/workflows/work-item-analysis/SKILL.md` 中对 Discovery、Story Map、Milestone 和旧规划 workflow 的依赖；
- `feature-dev`、`bug-fix` 和 `refactor` 对卡片、Backlog 及完成写回的入口引用；
- `src/AGENTS-snippet.md` 和目标仓库接入说明；
- 产品分析、工作项规划、路由、安装包和工作项交付相关契约测试；
- README 与 `docs/workflows/**` 下受行为变化影响的说明；
- 根目录 `version`。移除已发布 workflow 并重命名入口属于破坏性变更，应按 breaking change 评估版本。

构建或升级过程不得自动删除目标仓库中已有的 PRD、User Journey、Story Map 或其他业务文档。新版 Dev Cadence 可以停止读取和维护这些资产，但不能把能力移除解释为删除用户数据的授权。

## 验证原则

实施后的契约验证至少应证明：

1. 安装包不再包含 Discovery 和产品组合规划入口。
2. `backlog` 是卡片创建、外部卡准入和 Backlog 维护的唯一 owner。
3. 合规外部卡片可以绕过建卡和单卡分析，但不能绕过 Backlog。
4. 不合规外部卡片只能进入标准新需求建卡流程，不存在隐式格式转换。
5. `work-item-analysis` 不再依赖产品级 Feature、User Journey 或 Story Map。
6. Story、Task 和 Bug 仍能分别进入正确的 Delivery Workflow。
7. 认领、实施、完成、关闭和恢复过程中，卡片与 Backlog 继续保持一致。
8. Feature Dev、Bug Fix 和 Refactor 的方案、计划、测试、Review 与业务验收证据链保持完整。

## 实施结果

- 已完成现有 workflow、共享能力、supporting reference、脚本和测试盘点，并将工作项准入与 Backlog 所有权收敛到 `backlog`。
- 已定义 Story、Task 和 Bug 的最小结构与成熟度条件，不再要求 Feature、Story Map 或其他产品分析资产作为实施前置。
- 合规卡片可以直接登记 Backlog；不合规来源保持原状，并以全新未占用 ID 和路径进入标准建卡流程，避免覆盖或身份冲突。
- `work-item-analysis` 只分析一张已登记的合规卡片，且只允许在 `Draft`、`Ready` 和 `Blocked` 之间更新定义成熟度。
- 安装包版本已更新为 `0.34.0`；构建与完整契约验证结果以本次实施的最终校验输出为准。
