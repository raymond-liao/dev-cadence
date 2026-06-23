# Dev Cadence

Dev Cadence 是一套 AI-native 软件交付框架，当前仓库提供它的 Codex Plugin 发布实现。

它的目标是让 AI 交付工作从“单 Agent 写代码”升级为：

```text
Human + Harness-Mediated Multi-Agent Team
```

核心设计是：

- `Supervisor` 控制 workflow、状态、预算和 gates，不直接写代码。
- `Harness` 约束每次 Agent 执行的上下文、工具、权限、日志和证据。
- Worker Agents 通过 artifacts 协作，而不是通过聊天记录交接。
- `Quality Gate` 和 `Human Gate` 控制验证、Review、风险接受和最终验收。

完整框架方案见 [docs/framework.md](docs/framework.md)。

## 当前状态

当前仓库已经完成 Codex Plugin 的 root-level 发布结构：

```text
dev-cadence/
  .codex-plugin/
  hooks/
  skills/
  references/
  templates/
  scripts/
  docs/
  tests/
```

发布包由源码仓库生成。不要把源码仓库根目录直接作为 Codex Plugin 安装源。

## 文档入口

| 文档 | 作用 |
|---|---|
| [docs/framework.md](docs/framework.md) | Dev Cadence 完整框架方案 |
| [docs/plugin-skill-modularization.md](docs/plugin-skill-modularization.md) | Plugin、Skill、reference、template 和 adapter 的模块化边界 |
| [docs/skill-authoring-prespec.md](docs/skill-authoring-prespec.md) | Plugin 编制前置规格 |
| [docs/dev-cadence-roadmap.md](docs/dev-cadence-roadmap.md) | 当前阶段路线图和完成状态 |
| [docs/acceptance-guide.md](docs/acceptance-guide.md) | 当前阶段验收方式 |
| [docs/research-findings.md](docs/research-findings.md) | 早期研究中沉淀下来的稳定结论 |
| [docs/validation-notes.md](docs/validation-notes.md) | pressure test 和 visual companion 验证结论 |

## Plugin 内容

当前 Codex Plugin 发布内容包括：

```text
.codex-plugin/plugin.json
hooks/
skills/
  dev-cadence-init/
  dev-cadence-deliver/
  dev-cadence-maintain/
  dev-cadence-authoring/
references/
templates/
scripts/
```

四个 user-facing Skills 的边界：

| Skill | 用途 |
|---|---|
| `dev-cadence-init` | 初始化目标仓库的 thin repo-local contract |
| `dev-cadence-deliver` | 执行 feature、bugfix、refactor、review、research-spike 和 incident 工作 |
| `dev-cadence-maintain` | inspect、sync、repair、diagnose 或升级目标仓库配置 |
| `dev-cadence-authoring` | 维护 Dev Cadence 自身发布内容 |

共享规则、模板和脚本由 plugin 持有，不复制到每个目标仓库。

## 生成发布包

在源码仓库根目录执行：

```bash
node scripts/package-codex-plugin.mjs --clean
```

默认生成：

```text
dist/codex/
  marketplace.json
  plugins/
    dev-cadence/
```

`dist/codex/plugins/dev-cadence/` 是实际 Codex Plugin payload，只包含运行所需的 `.codex-plugin/`、`hooks/`、`skills/`、`references/`、`templates/` 和 `scripts/`。

源码仓库中的 `README.md`、`AGENTS.md`、`docs/`、`tests/`、`.git/`、本地 `specs/` 和本地 `research/` 不进入发布包。

## 本地安装到 Codex

这里的 `marketplace` 是 Codex CLI 的本地插件来源目录。`codex plugin marketplace add dist/codex` 只会把 `dist/codex` 注册到本机 Codex 配置中，不会上传插件，也不会发布到公开市场。

首次安装：

```bash
node scripts/package-codex-plugin.mjs --clean
codex plugin marketplace add dist/codex
codex plugin add dev-cadence@dev-cadence-local
```

更新本地发布包后：

```bash
node scripts/package-codex-plugin.mjs --clean
codex plugin add dev-cadence@dev-cadence-local
```

安装或更新后新开 Codex thread，以便 Codex 重新加载 skills 和 hook。

## 目标仓库契约

在业务仓库中启用 Dev Cadence 时，默认只生成 thin repo-local contract：

```text
AGENTS.md
.gitignore
.dev-cadence.yaml
specs/
  .gitkeep
```

`AGENTS.md` 负责把普通交付工作路由到 Dev Cadence。`.dev-cadence.yaml` 保存本地偏好并被 `.gitignore` 忽略。`specs/{task_id}/` 保存任务 artifacts、Harness evidence 和 Human acceptance。

## 本仓库本地目录策略

源码仓库不长期追踪运行过程目录：

- `specs/` 是本地 dry run 或任务执行生成物；
- `research/` 是临时探索工作区；
- 稳定模板保留在 `templates/`；
- 稳定设计依据和验证结论保留在 `docs/`。

这两个目录已加入 `.gitignore`。

## 验证

完整回归：

```bash
bash tests/run-all.sh
```

该命令覆盖：

- Codex Plugin manifest；
- 发布包边界；
- session-start hook；
- thin repo-local contract；
- delivery dry run 生成的临时 specs 和 Harness evidence；
- Plugin source self-check；
- discipline route check；
- artifact templates；
- diff whitespace。

定位问题时可单独运行：

```bash
node scripts/check-skill-package.mjs .
node scripts/check-discipline-routes.mjs .
node scripts/check-spec-artifacts.mjs templates
node scripts/package-codex-plugin.mjs --clean
```

## 语言边界

- 项目文档使用中文，包括 `README.md`、`docs/**` 和 `AGENTS.md`。
- 发布用 Plugin 内容使用英文，包括 `.codex-plugin/**`、`hooks/**`、`skills/**`、`references/**`、`templates/**` 和 `scripts/**` 下的说明文字、YAML keys、status values、workflow IDs 和 gate IDs。
- 任务 artifact 的自然语言正文由 `artifact_language` 决定；文件名、YAML 字段、状态枚举、workflow ID 和 gate ID 保持英文。
