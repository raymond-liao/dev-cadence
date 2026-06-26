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

| 文档 | 作用 |
|---|---|
| [docs/framework.md](docs/framework.md) | 完整框架方案 |
| [docs/plugin-skill-modularization.md](docs/plugin-skill-modularization.md) | Plugin、Skill、reference、template 和 adapter 的模块化边界 |
| [docs/validation.md](docs/validation.md) | 当前验证、安装、更新和卸载命令 |
| [references/skill-layout.md](references/skill-layout.md) | 发布包布局和版本规则 |
| [docs/archive/](docs/archive/) | 已完成阶段的计划、验收和验证记录 |
