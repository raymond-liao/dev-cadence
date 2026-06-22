# 仓库指南

## 项目结构与模块组织

本仓库记录一套 AI-native 软件交付框架，并打包 `dev-cadence` Codex Skill。

- `README.md`：主要框架方案和架构概览。
- `docs/`：支撑性设计说明。
- `skills/dev-cadence/`：Skill package，包含 `SKILL.md`、`agents/` 和 `references/`。
- `research/`：研究、agent prompts、材料、分析、验证和报告。

新增框架 reference 时，放在最相关的现有 reference 附近。探索性或研究专用材料放在 `research/` 下，不要放进 `skills/`，除非它属于要发布的 Skill。

## 构建、测试与开发命令

本仓库没有应用构建流水线。常用本地检查包括：

- `rg --files`：快速列出项目文件。
- `rg "term" README.md skills docs research`：搜索框架术语，避免定义冲突。
- `node skills/dev-cadence/scripts/check-skill-package.mjs skills/dev-cadence`：校验 Skill package 结构、语言边界和脚本状态。
- `node skills/dev-cadence/scripts/check-discipline-routes.mjs skills/dev-cadence`：校验 discipline routes、prompt templates 和 bundled resources。
- `git diff -- README.md skills docs research`：提交前检查文档和 Skill 变更。

如果新增生成产物或脚本，请在同一次变更中记录对应命令。

## 写作风格与命名约定

大多数内容是 Markdown。使用 ATX heading（`#`、`##`）、短章节，以及必要时带语言提示的 fenced code block。保持框架术语一致，例如 `Supervisor`、`Harness`、`Context Pack`、`Human Gate` 和 `Quality Gate`。

语言边界：

- 项目文档使用中文，包括 `README.md`、`docs/**` 和本文件。
- 发布用 Skill package 内容使用英文，包括 `skills/dev-cadence/**` 下的 `SKILL.md`、`agents/`、`references/`、模板说明、YAML keys、status values、workflow IDs 和 gate IDs。
- 任务 artifact 的自然语言正文由 `artifact_language` 决定；文件名、YAML 字段、状态枚举、workflow ID 和 gate ID 保持英文。

Markdown reference 文件名使用小写连字符，例如 `quality-gates.md` 或 `skill-layout.md`。保留 research agent 文件的现有编号前缀，例如 `00.orchestrator.md`。

## 测试指南

当前未配置自动化测试。通过阅读渲染后的 Markdown、检查链接和路径、搜索重复或冲突规则来验证变更。涉及 Skill 行为变更时，检查 `skills/dev-cadence/SKILL.md` 以及它直接引用的 `skills/dev-cadence/references/` 文件。

未来如果加入代码示例或工具，优先使用 TDD。如果 TDD 不适合文档类工作，说明采用的替代反馈。

## Commit 与 Pull Request 指南

近期历史使用 Conventional Commits，例如 `docs(skill): prepare authoring pre-spec` 和 `docs(framework): ...`。文档变更优先使用 `docs(scope): concise summary`。

Pull request 应包含目的、影响目录、重要术语或策略变更，以及执行过的手工验证。有关联 issue 或 research note 时请链接。

## Agent 专用指令

不要把聊天记录当作框架行为的持久事实来源。规则变化时更新稳定 artifact。

使用能够保持安全、证据、可审查性和交接质量的最小流程。XP/TDD 补充本框架中的 Worker Agent 执行层；它不替代 `Supervisor`、`Harness`、`Quality Gate` 或 `Human Gate` 的职责。
