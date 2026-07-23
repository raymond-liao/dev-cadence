# Dev Cadence

Dev Cadence 是面向 AI 编程代理的软件实施治理规则包。它从工作项接入开始，覆盖设计、计划、实施、验证、验收和 Git 集成，使开发过程可审阅、可恢复、可验证。

Dev Cadence 不负责产品探索、PRD、User Journey、Feature 定义、Story Map、Milestone、MVP 或产品组合规划。产品分析可以在其他系统完成；实施工作通过 Dev Cadence 的卡片与 Backlog 契约进入交付。

[English](README.md)

## 快速开始

把 Dev Cadence 安装到另一个仓库：

```bash
git clone <your-dev-cadence-repository-url>
cd dev-cadence
bash scripts/install.sh /path/to/target-repository
```

然后把以下文件中的 Markdown 片段复制到目标仓库根 `AGENTS.md`：

```text
/path/to/target-repository/.dev-cadence/AGENTS-snippet.md
```

## 实施模型

Dev Cadence 拥有实施工作项和仓库内 Backlog：

```text
新需求或已有卡片
-> Backlog 准入
-> 必要时执行单卡需求分析
-> docs/delivery/backlog.md
-> 认领
-> feature-dev | bug-fix | refactor
-> 方案、实施计划、实施、Review、验证和验收
-> 卡片与 Backlog 生命周期回写
```

卡片使用仓库级稳定 ID：

- Story：`S-nnn`
- Task：`T-nnn`
- Bug：`B-nnn`

已有卡片完整满足 Dev Cadence 卡片和成熟度契约时，可以不重新建卡、不重复分析，直接登记到 Backlog。不符合要求的外部卡片保持原状，并作为新需求输入进入标准建卡流程。

## Workflow

### backlog

创建 Story、Task 和 Bug 卡片，校验用户提供的卡片，登记合规卡片，并拥有 `docs/delivery/backlog.md` 的结构、生命周期分区和待处理建议顺序。

Backlog 不执行产品分析、详细单卡分析、技术诊断、开发、测试或验收。

### work-item-analysis

每次只分析一张已有 Story、Task 或 Bug 卡片，明确目标、范围、预期行为或完成条件、依赖、约束和 Open Questions。

Story 是否达到 `Ready` 只取决于自身实施定义，不要求 PRD、Feature、User Journey 或 Story Map 引用。Bug 技术根因仍由 `bug-fix` 负责。

### architecture-design

针对明确的独立架构目标创建或更新一份架构资产，不替代 Delivery Workflow 的任务级方案。

### feature-dev

从已进入 Backlog 的 Story 或 Task 交付新增或有意改变的用户可见、系统可见行为。

```text
需求确认 -> 技术方案 -> 实施计划 -> 开发实施 -> 系统测试 -> 业务验收 -> 完成
```

### bug-fix

从已进入 Backlog 的 Bug 卡片诊断并修复未正常工作的既有预期行为。

```text
问题诊断 -> 修复方案 -> 修复计划 -> 修复实施 -> 修复验证 -> 业务验收 -> 完成
```

### refactor

从已进入 Backlog 的 Task 卡片改善内部结构，同时不主动改变预期行为。

```text
重构范围 -> 重构方案 -> 重构计划 -> 重构实施 -> 重构验证 -> 业务验收 -> 完成
```

## 资产与记录

Asset Workflow 在 `docs/` 下维护长期权威资产：

```text
docs/delivery/backlog.md
docs/delivery/open-questions.md
docs/delivery/stories/S-nnn-<slug>.md
docs/delivery/tasks/T-nnn-<slug>.md
docs/delivery/bugs/B-nnn-<slug>.md
docs/architecture/<goal-slug>.md
```

Delivery Workflow 在以下位置维护可恢复证据：

```text
build/dev-cadence/<workflow>/<task-slug>/
```

交付记录包括活动 manifest、确认输入、任务级方案、实施计划、实施证据、Code Review、系统验证、业务验收、Git 集成和清理证据。这些记录不存放在安装后的 `.dev-cadence` 包中。

## 配置

把示例配置复制到目标仓库根目录：

```bash
cp .dev-cadence/.dev-cadence.example.yaml .dev-cadence.yaml
```

支持字段：

```yaml
output_language: zh-CN

worktree:
  enabled: false
  directory: .worktrees
```

`.dev-cadence.yaml` 是目标仓库运行时配置；除非目标仓库明确选择版本化，否则不应提交。

## 运行规则

- `.dev-cadence/` 是可替换的安装包内容。
- 工作项卡片、Backlog、架构资产和交付记录属于目标仓库，不属于安装包。
- 安装或升级 Dev Cadence 不授权删除已有产品文档或其他用户数据。
- 本仓库以 `src/workflows/**` 为 workflow 行为权威来源；`dist/.dev-cadence/**` 由 `bash scripts/build.sh` 生成。

## 许可证

Dev Cadence 使用 [MIT License](LICENSE)。
