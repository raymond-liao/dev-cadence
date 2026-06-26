# Dev Cadence

`dev-cadence` 是一套面向 coding agents 的 Codex Plugin，用来把需求澄清、计划、实现、Review、验证和验收组织成可审查、可交接的软件交付节奏。

## Quickstart

本仓库是插件源码和本地发布包生成仓库。安装或更新本机插件：

```bash
./deploy-local.sh
```

安装后新开 Codex thread。不要把源码仓库根目录直接作为插件安装源；本地发布包位于 `dist/codex/`。

## Use It

进入业务仓库并启动 Codex：

```bash
cd /path/to/your/project
codex
```

首次启用：

```text
在这个仓库初始化 dev-cadence
```

之后正常提出交付任务：

```text
修复支付回调重复处理的问题
```

Dev Cadence 会在业务仓库里使用 `specs/{task_id}/` 记录过程 artifact、Harness evidence、验证和人工验收。完整机制见 [docs/framework.md](docs/framework.md)。

## Local Development

完整回归：

```bash
bash tests/run-all.sh
```

重新生成本地 Codex 发布包：

```bash
node scripts/package-codex-plugin.mjs --clean
```

更多验证、安装和卸载命令见 [docs/validation.md](docs/validation.md)。

## Documentation

本仓库文档按用途分层，避免把说明文档和运行时规则混成同一个事实源：

- `README.md`：项目入口、安装、使用和维护导航。
- `docs/`：维护者说明和当前设计解释；`docs/archive/` 只保存历史计划、研究和验收记录。
- `skills/`、`references/`、`templates/`、`scripts/`：Codex Plugin 发布内容，也是运行时会加载或调用的材料。
- `specs/`、`research/`：本地运行或探索过程目录，默认不提交。

| 文档 | 作用 |
|---|---|
| [docs/framework.md](docs/framework.md) | 框架概念、职责分层和长期演进方向 |
| [docs/architecture.md](docs/architecture.md) | 角色、分层、Harness、Context 和工具边界 |
| [docs/workflows.md](docs/workflows.md) | Workflow、任务分级、loop、Quality Gate 和 Human Gate |
| [docs/artifacts.md](docs/artifacts.md) | `specs/`、task artifacts、Harness evidence 和事实源规则 |
| [docs/plugin-skill-modularization.md](docs/plugin-skill-modularization.md) | 当前 Plugin、Skill、reference、template 和 adapter 的模块化边界 |
| [docs/validation.md](docs/validation.md) | 当前验证、安装、更新和卸载命令 |
| [references/skill-layout.md](references/skill-layout.md) | 发布包布局和版本规则 |
| [docs/archive/](docs/archive/) | 已完成阶段的计划、验收和验证记录 |
