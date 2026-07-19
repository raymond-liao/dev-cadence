# Dev Cadence

[English](README.md)

Dev Cadence 帮助团队以清晰、可审阅、可信赖的方式开展 AI 参与的软件研发，覆盖从产品探索到验证交付的完整过程。

它为 AI 软件研发 agent 提供明确的工作流、确认门禁、长期资产和可验证的交付证据。

## 快速开始

在 Dev Cadence 源码 checkout 中，把 Dev Cadence 安装或更新到目标仓库，然后把目标仓库的 agent 指令接入 Dev Cadence：

```bash
bash scripts/install.sh /path/to/target-repo
```

安装脚本会重新构建分发包并替换目标仓库中已有的 `.dev-cadence` 目录，因此更新时不会残留旧文件，也不会产生嵌套包目录。用户配置位于安装包外的 `.dev-cadence.yaml`，不会被替换。

然后把下面文件里的片段合并到目标仓库根目录的 `AGENTS.md`：

```text
.dev-cadence/AGENTS-snippet.md
```

## 工作方式

当用户提出产品探索、架构设计、需求工作或开发工作时，Dev Cadence 会先判断是否有已安装的工作流适用，而不是直接编写产品文档或代码。

如果有适用的工作流，agent 会先执行该工作流，再进入实现。Asset Workflow 在会话中完成分析和确认门禁，只持久化权威资产；Delivery Workflow 记录阶段证据，并使用 vendored Superpowers 提供的工程方法：brainstorming、systematic debugging、planning、test-driven development、code review、verification 和 branch finishing。

Dev Cadence 不替代 Superpowers。它是在 Superpowers 外层固定业务交付流程：

- 哪个工作流适用；
- 哪些阶段需要用户确认；
- 哪些长期资产或交付记录必须存在；
- 任务产物应该放在哪里；
- 目标仓库使用哪个固定版本的 Superpowers。

每次 Delivery Workflow 运行都应该形成一条交付证据链。Dev Cadence Run Manifest 会把一次运行串起来，记录工作流类型、分支、阶段状态、产物路径、checkpoint commit、验证状态、业务验收状态和最终集成决策。Asset Workflow 不创建 manifest，也不持久化与权威资产重复的过程记录。

因为技能通过目标仓库的 `AGENTS.md` 触发，用户不需要写特殊提示词。安装后，普通产品探索和开发请求应该自动进入匹配的 Dev Cadence 工作流。

## 企业价值

随着 AI 编程代理进入研发团队，企业的核心问题不再只是“AI 能不能写代码”。更难的问题是：AI 生成的交付工作能不能被管理、验证、审阅、验收和审计。

Dev Cadence 帮助团队：

- 降低 AI 生成代码进入主干前的质量风险；
- 降低 AI 决策不可追踪、验证不完整带来的管理风险；
- 让跨团队、跨仓库的 AI 辅助交付保持一致；
- 保留需求、设计决策、测试、评审、验收和集成证据；
- 把好的 AI 开发实践沉淀为可复用的公司级标准。

Dev Cadence 不只是提高单个开发者效率的工具。它是让企业安全、一致地使用 AI 参与真实软件交付的治理层。

## 基础工作流

**discovery** 把不完整的产品想法或业务问题整理成三资产一致的产品设计基线，也可以增量更新已有确认基线：

```text
docs/product-design/user-journey.md
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

```text
Background And Problem Exploration -> User Journey Analysis -> User Journey Confirmation -> PRD And Business Architecture Derivation -> Product Design Confirmation
```

Discovery 负责 User Journey、产品需求和业务架构，不负责技术架构、工作项拆分或应用实现。它有两道确认门：User Journey Confirmation 和 Product Design Confirmation。Discovery 创建并维护 User Journey 中的 Feature Definitions；Work Item Planning 只引用已确认的 Feature，不负责定义 Feature。完整产品设计基线要求 User Journey、PRD 和 Business Architecture 三项资产保持一致。分析阶段和两道确认门都只在会话中执行，primary outputs 是 User Journey、PRD 和 Business Architecture。技术输入可以链接到既有权威技术资产，或按共享 Open Question Registry 自身规则执行支撑性 shared-asset maintenance；这既不是额外的 Discovery 主产物，也不是过程记录。增量模式必须同时具备明确更新意图和可信仓库候选文档；在会话中展示完整修订提案期间保持权威资产不变，Product Design Confirmation 后才原子应用受影响内容、独立版本、Change Log 和支撑资产维护。保留综合单文件时，User Journey、PRD 与 Business Architecture 职责仍分别维护版本。工作项影响移交 `work-item-planning`。

**architecture-design** 用于用户明确提出的目标驱动架构设计、架构方案或架构评审，核心产出只有一份按目标命名的权威文档：

```text
docs/architecture/<goal-slug>.md
```

它按需调查现状，在存在实质差异时比较有意义的备选方案，并把架构图放在文档内且优先使用 Mermaid。它不会由仓库状态自动触发，也不替代交付 workflow 面向当前任务的 Solution。

**work-item-analysis** 用于在进入下游交付 workflow 前，对 Story、Task 和 Bug 进行详细定义分析。

```text
Analysis Scope Confirmation -> Work Item Definition Analysis -> Work Item Confirmation
```

它是 Asset Workflow，既支持单个工作项，也支持用户明确选择的一组工作项；发现已有 Story、Task 或 Bug 卡片时必须复用，并且只在用户确认后把更新写回 `docs/` 下的权威工作项卡片。它不改产品设计基线、不改 Story Map 或 Backlog 顺序、不设计技术方案、不改代码，也不执行测试或业务验收。分析完成后，再把已确认工作项移交给匹配的 Delivery Workflow。

**feature-dev** 用于新增用户可见或系统可见功能，以及对预期行为的主动变更。

```text
Requirements Confirmation -> Technical Solution -> Implementation Plan -> Development Implementation -> System Testing -> Business Acceptance
```

**bug-fix** 用于用户报告的 bug、错误、回归、失败测试、已破坏的预期行为和异常行为。

```text
Problem Diagnosis -> Repair Solution -> Repair Plan -> Repair Implementation -> Regression Verification -> Business Acceptance
```

**refactor** 用于不主动改变预期行为的内部结构、模块化、可维护性、可测试性和依赖关系改进。

```text
Requirements Confirmation -> Refactor Solution -> Refactor Plan -> Refactor Implementation -> Regression Verification -> Business Acceptance
```

详细执行规则在各工作流自己的 skill 里。README 只作为产品和安装说明。

## Workflow 记录

Architecture Design 等 Asset Workflow 只创建或更新 `docs/` 下的权威资产，不为过程重复创建 run manifest、stage record、confirmation record 或 checkpoint commit。

Delivery Workflow 保留下述交付证据。

Delivery Workflow 记录属于目标仓库的正常工作区，不存放在 `.dev-cadence` 里。Discovery 属于 Asset Workflow，不创建这套交付记录。

任务级运行目录会把同一个任务的所有工作流产物放在一起：

```text
build/dev-cadence/<workflow>/<task-slug>/
```

任务级运行索引是 Dev Cadence Run Manifest：

```text
build/dev-cadence/<workflow>/<task-slug>/manifest.md
```

同一个任务目录还会包含阶段记录；如果使用 subagent-driven development，SDD 的任务 brief、实现报告、评审包和进度 ledger 会放在 `sdd/` 目录下。

manifest 应该串联：

- 工作流类型、任务 slug 和目标分支；
- 阶段状态和阶段产物路径；
- checkpoint commit；
- 测试、检查和验证结果；
- 业务验收结论；
- 最终 merge、PR、保留分支或丢弃分支决策。

Dev Cadence 使用共享语义标识加 canonical status 文本呈现明确的用户可见状态，例如 🔄 `in_progress` 或 ⚠️ `ready_with_risk`。文本仍是权威来源，机器读取的正式状态值保持不变；标识只用于提高 manifest、阶段记录、报告、验收摘要和进度更新的扫描效率。

## 配置

如需自定义工作流输出语言，把示例配置复制到目标仓库根目录：

```bash
cp .dev-cadence/.dev-cadence.example.yaml .dev-cadence.yaml
```

然后编辑：

```text
.dev-cadence.yaml
```

支持的值：

- `en` - 英文工作流文档和记录。
- `zh-CN` - 简体中文工作流文档和记录。

Worktree 配置：

- `worktree.enabled: false` - 使用入口准备的专用任务分支，且不创建 worktree。
- `worktree.enabled: true` - 不询问，由入口创建或确认隔离 worktree。
- `worktree.directory` - 优先使用的项目内 worktree 目录。

用户配置不要放在 `.dev-cadence` 里。Dev Cadence 更新时会替换 `.dev-cadence` 目录。

## 运行规则

- `.dev-cadence` 只包含工作流规则和 vendored skills。
- 用户配置放在目标仓库根目录的 `.dev-cadence.yaml`，不要放在 `.dev-cadence` 中。
- 任务产物、计划、报告和验收记录属于目标仓库的正常工作区，不放在 `.dev-cadence` 中。
- 不要在目标仓库里直接编辑 `vendor/superpowers/skills/`。需要修改时，在 Dev Cadence 源码中更新后重新构建。
- 使用或分发该包时，保留 `vendor/superpowers/LICENSE` 和 `vendor/superpowers/RELEASE-NOTES.md`。

## 许可证

Dev Cadence 使用 [MIT License](LICENSE)。

Vendored Superpowers 副本保留其 MIT License，安装包内路径为 `vendor/superpowers/LICENSE`。
