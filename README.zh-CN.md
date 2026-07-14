# Dev Cadence

[English](README.md)

Dev Cadence 是一个面向 AI 编程代理的软件交付治理框架。它把 AI 的开发行为组织成可配置的业务流程，并为每次交付生成可审计的阶段记录、测试证据、验收结论和集成决策。

它基于固定版本的 vendored Superpowers，以及一小组项目级指令，让交付阶段变得可见、可审阅、可重复。

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

当用户提出产品探索、需求工作或开发工作时，Dev Cadence 会先判断是否有已安装的工作流适用，而不是直接编写产品文档或代码。

如果有适用的工作流，agent 会先执行该工作流，再进入实现。它会确认业务可读的阶段产物，记录阶段证据，然后使用 vendored Superpowers 提供的工程方法：brainstorming、systematic debugging、planning、test-driven development、code review、verification 和 branch finishing。

Dev Cadence 不替代 Superpowers。它是在 Superpowers 外层固定业务交付流程：

- 哪个工作流适用；
- 哪些阶段需要用户确认；
- 哪些记录必须存在；
- 任务产物应该放在哪里；
- 目标仓库使用哪个固定版本的 Superpowers。

每次工作流运行都应该形成一条交付证据链。Dev Cadence Run Manifest 会把一次运行串起来，记录工作流类型、分支、阶段状态、产物路径、checkpoint commit、验证状态、业务验收状态和最终集成决策。

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

**discovery** 把不完整的产品想法或业务问题整理成第一版产品设计基线：

```text
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

```text
Background And Problem Exploration -> Goal And Value Definition -> Scope And Business Architecture Analysis -> Product Design Baseline Creation -> Product Design Confirmation
```

Discovery 负责产品需求和业务架构，不负责技术架构、工作项拆分或应用实现。当前 S-001 只创建第一版基线；增量更新由 S-002 实现。

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

## 交付证据

工作流记录属于目标仓库的正常工作区，不存放在 `.dev-cadence` 里。

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

## 包含内容

```text
.dev-cadence/
  version
  LICENSE
  .dev-cadence.example.yaml
  README.md
  README.zh-CN.md
  AGENTS-snippet.md
  skills/
    using-dev-cadence/
      SKILL.md
    discovery/
      SKILL.md
    feature-dev/
      SKILL.md
    bug-fix/
      SKILL.md
    refactor/
      SKILL.md
  vendor/
    superpowers/
      LICENSE
      RELEASE-NOTES.md
      skills/
```

主要部分：

- `AGENTS-snippet.md` - 合并到目标仓库根目录 `AGENTS.md` 的片段。
- `skills/using-dev-cadence/` - 工作流入口选择器。
- `skills/discovery/` - 首次产品探索和产品设计基线工作流。
- `skills/feature-dev/` - 功能开发工作流。
- `skills/bug-fix/` - Bug 修复工作流。
- `skills/refactor/` - 保持行为不变的重构工作流。
- `.dev-cadence.example.yaml` - 目标仓库运行时配置示例。
- `vendor/superpowers/` - Dev Cadence 使用的固定 Superpowers 副本。

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

- `worktree.enabled: false` - 除非用户明确要求，否则在当前 checkout 中工作。
- `worktree.enabled: true` - 不询问，自动创建或确认隔离 worktree。
- `worktree.directory` - 优先使用的项目内 worktree 目录。

用户配置不要放在 `.dev-cadence` 里。Dev Cadence 更新时会替换 `.dev-cadence` 目录。

## 运行规则

- `.dev-cadence` 只包含工作流规则和 vendored skills。
- 用户配置放在目标仓库根目录的 `.dev-cadence.yaml`，不要放在 `.dev-cadence` 中。
- 任务产物、计划、报告和验收记录属于目标仓库的正常工作区，不放在 `.dev-cadence` 中。
- 不要在目标仓库里直接编辑 `vendor/superpowers/skills/`。需要修改时，在 Dev Cadence 源码中更新后重新构建。
- 使用或分发该包时，保留 `vendor/superpowers/LICENSE` 和 `vendor/superpowers/RELEASE-NOTES.md`。

## 源码开发

源码树在 `src/` 下镜像安装包：

```text
src/
  AGENTS-snippet.md
  .dev-cadence.example.yaml
  skills/
  vendor/
```

构建安装包：

```bash
bash scripts/build.sh
```

构建脚本只会替换 `dist/.dev-cadence`。

把安装包安装或更新到目标仓库：

```bash
bash scripts/install.sh /path/to/target-repo
```

运行源码、分发包、安装和 workflow 契约检查：

```bash
bash scripts/check-all.sh
```

## 许可证

Dev Cadence 使用 MIT License。见 `LICENSE`。

Vendored Superpowers 副本使用 MIT License。见 `vendor/superpowers/LICENSE`。
