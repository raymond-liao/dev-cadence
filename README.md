# Dev Cadence

`dev-cadence` 是一套面向 coding agents 的 Codex Plugin，用来把需求澄清、计划、实现、Review、验证和验收组织成可审查、可交接的软件交付节奏。

## Quickstart

推荐把 Dev Cadence 作为业务仓库内置的 repo-embedded runtime 分发，这样流程入口由业务仓库 `AGENTS.md` 强制触发，不依赖全局 Plugin 或 Skill 自动发现。先在本仓库生成 target-repo bundle：

```bash
node scripts/package-target-repo-bundle.mjs --clean
```

同步到业务仓库：

```bash
node scripts/sync-target-repo-bundle.mjs --target /path/to/your/product-repo
```

同步后的业务仓库形态：

```text
your-product-repo/
  AGENTS.md
  .gitignore
  .dev-cadence.yaml
  .dev-cadence/
    VERSION
    manifest.json
    skills/
    references/
    templates/
    scripts/
```

提交业务仓库中的 `AGENTS.md`、`.dev-cadence/`、`.gitignore` 和 `specs/records/.gitkeep`。`.dev-cadence.yaml` 继续作为本地偏好文件，默认加入 `.gitignore`；默认 artifact language 是 `en`，用户可以在本地取消注释改为 `zh`。

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

业务仓库 `AGENTS.md` 会要求普通交付任务先读取 `.dev-cadence/skills/using-dev-cadence/SKILL.md`。Dev Cadence 会在业务仓库里使用 `specs/records/{task_id}/` 记录过程 artifact、Harness 运行证据、验证和人工验收；生成的 HTML 浏览报告放在 `specs/report/`。完整机制见 [docs/overview.md](docs/overview.md)。

## Local Development

维护者需要在本机验证当前源码包时，可以使用：

```bash
./deploy-local.sh
```

这会生成 `dist/codex/` 并安装 `dev-cadence@dev-cadence-local`，只用于本机开发和 smoke test。

完整回归：

```bash
bash tests/run-all.sh
```

重新生成目标仓库内置 bundle：

```bash
node scripts/package-target-repo-bundle.mjs --clean
```

更多安装、更新和卸载命令见 [docs/installation.md](docs/installation.md)；验证和打包检查见 [docs/validation.md](docs/validation.md)。

## Documentation

本仓库文档按用途分层：

- `README.md`：项目入口、安装、使用和维护导航。
- `docs/`：使用者和维护者说明，以及当前设计解释；`docs/archive/` 只保存历史计划、研究和验收记录。
- `skills/`、`references/`、`templates/`、`scripts/`：Dev Cadence 运行时内容，会被打包到业务仓库 `.dev-cadence/`；`references/source-maintenance/` 只用于维护本仓库，不进入业务仓库 runtime。
- `specs/`、`research/`：本地运行或探索过程目录，默认不提交。

| 文档 | 作用 |
|---|---|
| [Dev Cadence 概览](docs/overview.md) | 文档入口和阅读顺序 |
| [Dev Cadence 架构](docs/architecture.md) | Human、Supervisor、Harness 和 Worker Agents 的核心关系 |
| [Dev Cadence 角色](docs/roles/) | Human、Supervisor、Harness 和 Worker Agents 各自负责什么 |
| [Dev Cadence 工作流](docs/workflows/) | Dev Cadence 支持哪些工作流，每类任务怎么走 |
| [Dev Cadence 产物](docs/artifacts/) | `specs/records/{task_id}/` 下每个产物是什么、怎么看 |
| [Dev Cadence Runs](docs/runs/) | `runs/{run_id}/` 下每个 Harness 运行证据是什么、怎么看 |
| [Dev Cadence 门禁](docs/gates/) | G1-G6 gate 控制什么风险、什么时候允许继续 |
| [Dev Cadence 安装](docs/installation.md) | 业务仓库内置 runtime、本机开发安装和卸载命令 |
| [Dev Cadence 当前验证](docs/validation.md) | 当前回归检查、打包和 smoke test 命令 |
| [Codex Plugin 模块边界](docs/codex-plugin-boundaries.md) | 当前 Codex Plugin、Skill、reference、template 和 adapter 的模块边界 |
| [Skill Layout](references/skill-layout.md) | runtime 布局、Skill 边界和版本规则 |
| [Archive](docs/archive/) | 已完成阶段的计划、验收和验证记录 |
