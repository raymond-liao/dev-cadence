# Dev Cadence

`dev-cadence` 是一套面向 coding agents 的软件交付工作流系统。它把需求澄清、计划、实现、Review、验证和验收组织成可组合的 Skills，并用任务 artifact 和 Harness evidence 记录过程。

核心目标：让 AI 不只是“开始写代码”，而是按可审查、可验证、可交接的节奏完成软件交付。

## Quickstart

本仓库包含 Codex Plugin 的发布包生成与测试。不要把源码仓库根目录直接作为 Codex Plugin 安装源；先生成本地发布包，再安装到 Codex。

```bash
node scripts/package-codex-plugin.mjs --clean
codex plugin marketplace add ./dist/codex
codex plugin add dev-cadence@dev-cadence-local
```

安装或更新后新开 Codex thread，让 Codex 重新加载插件提供的 Skills 和 hooks。

## Use It

Dev Cadence 的日常使用发生在你的业务代码仓库中。

1. 进入业务仓库并启动 Codex：

```bash
cd /path/to/your/project
codex
```

2. 首次启用时，在 Codex 中说：

```text
在这个仓库初始化 dev-cadence
```

这会创建薄仓库契约：`AGENTS.md`、`.gitignore`、`.dev-cadence.yaml` 和 `specs/.gitkeep`。完整规则、模板和脚本仍由插件持有，不复制到业务仓库。

3. 之后正常提出交付任务：

```text
开发一个登录功能，支持邮箱密码登录、错误提示、登录成功后跳转到首页
```

或者：

```text
修复支付回调重复处理的问题
```

Dev Cadence 会把任务过程写入 `specs/{task_id}/`，包括需求 artifact、计划、Harness evidence、验证记录和人工验收记录。

## How It Works

Dev Cadence 从一次普通开发请求开始介入。它不会默认直接改代码，而是先判断任务类型、澄清目标和验收标准，然后选择合适的 workflow 和执行纪律。

核心角色：

- `Supervisor` 控制 workflow、状态、预算和 gates，不直接写代码。
- `Harness` 管理每次 Agent 执行的上下文、工具、权限、日志和证据。
- Worker Agents 执行具体任务，通过 artifacts 协作，而不是依赖聊天记录交接。
- `Quality Gate` 和 `Human Gate` 控制验证、Review、风险接受和最终验收。

## Basic Workflow

1. **Intent and design** - 在写代码前澄清目标、范围、非目标、约束和验收标准。
2. **Planning** - 把已确认的设计拆成可执行任务，标明文件、验证方式和风险点。
3. **Implementation** - 默认采用测试先行的实现纪律；不适合 TDD 时记录替代反馈方式。
4. **Review** - 按计划和代码质量两层检查，严重问题阻塞继续交付。
5. **Verification** - 用测试、脚本、人工检查或运行证据证明结果成立。
6. **Acceptance** - 把最终结果交给具名 Human 验收，不能只靠 Agent 自称完成。

Agent 会在任务开始前检查相关 Skills 和 references。工作流是默认纪律，不是建议清单。

## What's Inside

当前 Codex Plugin 发布内容包括：

| 入口 | 用途 |
|---|---|
| `dev-cadence-init` | 初始化目标仓库的薄契约 |
| `dev-cadence-deliver` | 执行 feature、bugfix、refactor、review、research-spike 和 incident 工作 |
| `dev-cadence-maintain` | 检查、同步、修复或升级目标仓库配置 |
| `dev-cadence-authoring` | 维护 Dev Cadence 自身发布内容 |

共享规则位于 `references/`，任务和 evidence 模板位于 `templates/`，本地校验和辅助工具位于 `scripts/`。

## Local Development

重新生成本地 Codex 发布包：

```bash
node scripts/package-codex-plugin.mjs --clean
```

首次把发布包注册到本机 Codex：

```bash
codex plugin marketplace add ./dist/codex
```

更新插件缓存：

```bash
codex plugin add dev-cadence@dev-cadence-local
```

完整回归：

```bash
bash tests/run-all.sh
```

## Documentation

| 文档 | 作用 |
|---|---|
| [docs/framework.md](docs/framework.md) | 完整框架方案 |
| [docs/plugin-skill-modularization.md](docs/plugin-skill-modularization.md) | Plugin、Skill、reference、template 和 adapter 的模块化边界 |
| [docs/dev-cadence-roadmap.md](docs/dev-cadence-roadmap.md) | 当前路线图和完成状态 |
| [docs/acceptance-guide.md](docs/acceptance-guide.md) | 当前阶段验收方式 |
| [docs/research-findings.md](docs/research-findings.md) | 稳定研究结论 |
| [docs/validation-notes.md](docs/validation-notes.md) | pressure test 和 visual companion 验证结论 |
