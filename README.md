# Dev Cadence

`dev-cadence` 是一套面向 coding agents 的 Codex Plugin，用来把需求澄清、计划、实现、Review、验证和验收组织成可审查、可交接的软件交付节奏。

## Quickstart

推荐把 Dev Cadence 作为业务仓库内置的 repo-scoped marketplace 分发，这样团队成员从同一个业务仓库安装同一份插件。先在本仓库生成 plugin payload：

```bash
node scripts/package-codex-plugin.mjs --clean
```

把 `dist/codex/plugins/dev-cadence/` 放到业务仓库，例如：

```text
your-product-repo/
  .agents/
    plugins/
      marketplace.json
      dev-cadence/
        .codex-plugin/
        skills/
        references/
        templates/
        scripts/
```

业务仓库的 `.agents/plugins/marketplace.json` 使用团队自己的 marketplace name，并让 `source.path` 指向提交进去的 plugin payload：

```json
{
  "name": "dev-cadence-your-product",
  "interface": {
    "displayName": "Dev Cadence Your Product"
  },
  "plugins": [
    {
      "name": "dev-cadence",
      "source": {
        "source": "local",
        "path": "./.agents/plugins/dev-cadence"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Coding"
    }
  ]
}
```

团队成员在业务仓库根目录安装：

```bash
codex plugin marketplace add .
codex plugin add dev-cadence@dev-cadence-your-product
```

安装后新开 Codex thread。不要把本仓库源码根目录直接作为插件安装源；团队分发应使用业务仓库提交的 `.agents/plugins/marketplace.json` 和 plugin payload。

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

Dev Cadence 会在业务仓库里使用 `specs/records/{task_id}/` 记录过程 artifact、Harness 运行证据、验证和人工验收；生成的 HTML 浏览报告放在 `specs/report/`。完整机制见 [docs/overview.md](docs/overview.md)。

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

重新生成本地 Codex 发布包：

```bash
node scripts/package-codex-plugin.mjs --clean
```

更多安装、更新和卸载命令见 [docs/installation.md](docs/installation.md)；验证和打包检查见 [docs/validation.md](docs/validation.md)。

## Documentation

本仓库文档按用途分层；`docs/` 说明框架和使用方式，发布内容承载可执行规则和模板：

- `README.md`：项目入口、安装、使用和维护导航。
- `docs/`：使用者和维护者说明，以及当前设计解释；`docs/archive/` 只保存历史计划、研究和验收记录。
- `skills/`、`references/`、`templates/`、`scripts/`：Codex Plugin 发布内容，也是运行时会加载或调用的材料。
- `specs/`、`research/`：本地运行或探索过程目录，默认不提交。

| 文档 | 作用 |
|---|---|
| [docs/overview.md](docs/overview.md) | 框架概念、当前文档地图和长期演进方向 |
| [docs/architecture.md](docs/architecture.md) | 角色、分层、Harness、Context 和工具边界 |
| [docs/workflows/](docs/workflows/) | Workflow catalog、路由原则和每类任务路径 |
| [docs/roles/](docs/roles/) | Human、Supervisor、Harness 和 Worker Agent 角色边界 |
| [docs/artifacts/](docs/artifacts/) | `specs/records/{task_id}/` task artifacts 和模板入口 |
| [docs/runs/](docs/runs/) | `runs/{run_id}/` Harness 运行证据说明 |
| [docs/gates/](docs/gates/) | G1-G6 Quality Gates 和 Human Gate 说明 |
| [docs/plugin-skill-modularization.md](docs/plugin-skill-modularization.md) | 当前 Plugin、Skill、reference、template 和 adapter 的模块化边界 |
| [docs/installation.md](docs/installation.md) | 当前安装、更新和卸载命令 |
| [docs/validation.md](docs/validation.md) | 当前验证、发布包生成和 smoke test 命令 |
| [references/skill-layout.md](references/skill-layout.md) | 发布包布局和版本规则 |
| [docs/archive/](docs/archive/) | 已完成阶段的计划、验收和验证记录 |
