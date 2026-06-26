# 仓库指南

## 项目结构与模块组织

本仓库记录一套 AI-native 软件交付框架，并打包 `dev-cadence` Codex Plugin。

- `README.md`：项目入口、安装、验证和文档导航。
- `docs/`：当前框架方案、Plugin 模块边界、验证/安装说明，以及 `docs/archive/` 下的历史计划和过程记录。
- `.codex-plugin/plugin.json`：Codex Plugin manifest。
- `skills/`：发布用入口 Skills。
- `references/`：发布用框架 references。
- `templates/`：发布用 task artifacts、Harness evidence 和 prompt templates。
- `scripts/`：发布用校验、初始化和辅助脚本。

新增框架 reference 时，放在 `references/` 下最相关的现有 reference 附近。当前说明放在 `docs/` 顶层；阶段性计划、验收 runbook、研究记录和过期过程文档放在 `docs/archive/`。`specs/` 和 `research/` 是本地运行或探索过程目录，默认不提交。

## 构建、测试与开发命令

本仓库没有应用构建流水线。常用本地检查包括：

- `rg --files`：快速列出项目文件。
- `rg "term" README.md docs AGENTS.md .codex-plugin skills references templates scripts tests`：搜索框架术语，避免定义冲突。
- `bash tests/run-all.sh`：运行 Codex Plugin manifest、package 边界、repo contract、delivery dry-run、`dev-cadence` source、artifact templates 和 diff whitespace 回归检查。
- `node scripts/package-codex-plugin.mjs --clean`：生成本地 Codex marketplace source 到 `dist/codex`，用于本机安装，不会上传发布。
- `node scripts/check-skill-package.mjs .`、`node scripts/check-discipline-routes.mjs .`、`node scripts/check-spec-artifacts.mjs templates`：定位问题时可单独运行。
- `git diff -- README.md docs AGENTS.md .gitignore .codex-plugin skills references templates scripts tests`：提交前检查文档、测试和 Plugin 变更。

如果新增生成产物或脚本，请在同一次变更中记录对应命令。

## 写作风格与命名约定

大多数内容是 Markdown。使用 ATX heading（`#`、`##`）、短章节，以及必要时带语言提示的 fenced code block。保持框架术语一致，例如 `Supervisor`、`Harness`、`Context Pack`、`Human Gate` 和 `Quality Gate`。

语言边界：

- 项目文档使用中文，包括 `README.md`、`docs/**` 和本文件。
- 发布用 Plugin 内容使用英文，包括 `.codex-plugin/**`、`skills/**`、`references/**`、`templates/**`、`scripts/**` 下的说明文字、YAML keys、status values、workflow IDs 和 gate IDs。
- 任务 artifact 的自然语言正文由 `artifact_language` 决定；文件名、YAML 字段、状态枚举、workflow ID 和 gate ID 保持英文。

Markdown reference 文件名使用小写连字符，例如 `quality-gates.md` 或 `skill-layout.md`。

## 测试指南

当前自动化回归测试入口是 `bash tests/run-all.sh`。它覆盖 Codex Plugin manifest、发布包边界、目标仓库薄契约，以及 delivery dry-run artifact 生成。文档类变更仍需阅读渲染后的 Markdown、检查链接和路径、搜索重复或冲突规则。涉及 Skill 行为变更时，检查对应 `skills/*/SKILL.md` 以及它直接引用的 `references/` 文件。

未来如果加入代码示例或工具，优先使用 TDD。如果 TDD 不适合文档类工作，说明采用的替代反馈。

## Commit 与 Pull Request 指南

近期历史使用 Conventional Commits，例如 `docs(skill): prepare authoring pre-spec` 和 `docs(framework): ...`。文档变更优先使用 `docs(scope): concise summary`。

Pull request 应包含目的、影响目录、重要术语或策略变更，以及执行过的手工验证。有关联 issue 或设计说明时请链接。

## Agent 专用指令

不要把聊天记录当作框架行为的持久事实来源。规则变化时更新稳定 artifact。

使用能够保持安全、证据、可审查性和交接质量的最小流程。XP/TDD 补充本框架中的 Worker Agent 执行层；它不替代 `Supervisor`、`Harness`、`Quality Gate` 或 `Human Gate` 的职责。
