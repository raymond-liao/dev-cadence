# 需求探索流程

本文说明 Dev Cadence 的 `discovery` 业务流程，包括适用场景、阶段目标、主要产出以及与其他 workflow 的边界。本文面向 Dev Cadence 维护者、流程评审者和希望了解产品需求治理模型的使用者。

目标仓库中的实际执行规则由 `src/skills/discovery/SKILL.md` 定义并生成安装内容。本文用于说明业务流程设计，不替代 workflow skill。

## 目的

需求探索流程用于把不完整的想法、反馈、业务问题或产品方向整理成经过用户确认的第一版产品设计基线。完整性是探索过程逐步形成的结果，不是输入前提。

第一版产品设计基线由两份文档组成：

```text
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

PRD 说明产品为什么存在、为谁服务、提供什么价值和能力。Business Architecture 说明产品在业务上如何运作，包括业务角色、业务域、业务能力、流程、业务对象、状态和规则。

## 适用场景

- 从一个模糊想法开始明确要解决的问题和产品方向。
- 首次建立 PRD。
- 首次建立 Business Architecture。
- 澄清目标用户、业务价值、成功标准、范围、非范围、业务运作方式、约束和开放问题。

当前 S-001 只支持首次建立产品设计基线。如果任一产品设计文档已经存在，不得覆盖或静默执行增量更新；已有基线的增量维护由后续 S-002 实现。

## 不适用场景

- 更新或升版已有产品设计基线：由后续 S-002 实现。
- 将已确认产品设计基线拆分成 Feature 和工作项：使用后续安装的 `work-item-planning`。
- 对单个 Story、Bug 或 Technical Task 进行技术设计和开发交付：使用相应开发 workflow。
- 设计技术模块、数据库、API、部署拓扑或其他技术架构。
- 修改应用代码、数据库迁移或运行实现验证。

## 流程阶段

| 阶段 | 目标 | 主要产出 |
|---|---|---|
| 1. 背景与问题探索 | 收集原始想法、反馈、业务问题和现状，明确动机、目标用户、问题陈述，并区分事实、假设和待确认内容。 | `01-background-and-problem.md` |
| 2. 目标与价值定义 | 明确期望结果、用户价值、业务价值、成功标准和不处理该问题的影响。 | `02-goals-and-value.md` |
| 3. 范围与业务架构分析 | 明确范围、非范围、业务角色、业务域、能力、流程、业务对象、状态、规则、约束、风险和开放问题。 | `03-scope-and-business-architecture.md` |
| 4. 产品设计基线建立 | 把当前结论写入第一版 PRD 和 Business Architecture；保留开放问题、拒绝方向、未来范围和各自的 Change Log。 | `docs/product-design/prd.md`；`docs/product-design/business-architecture.md` |
| 5. 产品设计确认 | 向用户统一说明两份文档的核心结论、未解决问题、排除项和后续边界，由用户一次确认完整基线。 | `05-product-design-confirmation-record.md` |

阶段顺序：

```text
Background And Problem Exploration
-> Goal And Value Definition
-> Scope And Business Architecture Analysis
-> Product Design Baseline Creation
-> Product Design Confirmation
```

前四个阶段共同形成一套产品设计，不在每个小节后反复要求确认。最后一次确认同时覆盖 PRD 和 Business Architecture。

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

## 版本与历史

- 两份文档的第一版版本号都是 `1`。
- 两份文档各自维护 Change Log，记录版本、日期、变化摘要和原因。
- 产品文档不记录 Git commit hash、用户审批人、审批时间、checkpoint 或 workflow 状态。
- 用户确认和 checkpoint 证据保存在 `build/dev-cadence/discovery/<discovery-slug>/manifest.md` 和最终确认记录中。
- S-001 不定义版本递增或已有文档协调规则；这些能力由 S-002 实现。

## 关键规则

- 输入可以只有一个想法，不要求用户预先提供完整需求、验收标准或实现边界。
- 冲突来源优先采用用户明确确认，其次采用仓库现有文档；未解决冲突保留在 `Open Questions`。
- `Open Questions` 是唯一的未解决事项章节，不额外创建 `Draft Ideas` 或 `Pending Decisions`。
- 已确认答案写回对应正文；明确拒绝的方向保存在 `Rejected Directions`；延后产品范围保存在 PRD `Future Scope`。
- 不得为了让文档看起来完整而虚构用户、需求、流程、业务对象、状态或规则。
- `discovery` 不创建 Feature、Story、Bug 或 Technical Task，不维护工作项 Roadmap。
- 产品设计资产保存在目标仓库正常项目空间，不得写入可替换的 `.dev-cadence/` 安装包。
- 不生成额外业务 Run Log；Dev Cadence manifest 和阶段记录保存 workflow 执行过程。

## 与其他 Workflow 的关系

```text
想法、反馈、业务问题或产品方向
              |
          discovery
              |
  已确认的 PRD + Business Architecture
              |
    work-item-planning（后续能力）
```

用户只需要形成产品方案时，可以在 Discovery 完成后停止。需要形成工作项组合时，在对应 workflow 安装后再进入 Work Item Planning。
