# Dev Cadence 概览

Dev Cadence 是一套面向 coding agents 的 AI-native 软件交付协作框架。它把需求澄清、计划、实现、验证、Review 和人工验收组织成可审查、可交接的交付节奏。

本文是 Dev Cadence 的说明入口。框架说明应与运行时规则保持一致；可执行规则和模板由 `skills/`、`references/`、`templates/` 和 `scripts/` 承载。

## 核心模型

```text
Supervisor-Controlled
Harness-Mediated
Artifact-First
Spec-Driven
Quality-Gated
Multi-Agent Development Framework
```

核心判断：

1. Agent 之间通过结构化产物交接，不依赖自由聊天。
2. Supervisor 控制流程、状态、预算和门禁，不亲自写代码。
3. Harness 约束上下文、工具、权限和证据采集。
4. Worker Agents 负责具体研发产物。
5. Chat 不是持久事实来源；spec、ADR、测试报告、Review 报告和 Harness 运行证据才是事实来源。

## 怎么阅读

| 文档 | 读者问题 |
|---|---|
| [workflows/](workflows/) | Dev Cadence 支持哪些工作流，每类任务怎么走 |
| [roles/](roles/) | Human、Supervisor、Harness 和 Worker Agents 各自负责什么 |
| [artifacts/](artifacts/) | `specs/{task_id}/` 下每个产物是什么、怎么看 |
| [runs/](runs/) | `runs/{run_id}/` 下每个 Harness 运行证据是什么、怎么看 |
| [gates/](gates/) | G1-G6 gate 控制什么风险、什么时候允许继续 |
| [architecture.md](architecture.md) | 为什么要分 Supervisor、Harness、Worker、Context 和 Tooling 边界 |
| [plugin-skill-modularization.md](plugin-skill-modularization.md) | 当前 Codex Plugin 的模块边界和发布资源 |
| [installation.md](installation.md) | 本机安装、更新和卸载命令 |
| [validation.md](validation.md) | 当前回归检查、打包和 smoke test 命令 |

## 当前发布形态

当前 `dev-cadence` Codex Plugin 采用 root-level source layout：

```text
.codex-plugin/
skills/
references/
templates/
scripts/
```

发布内容分工：

- `skills/`：Codex Skill 入口和工作纪律入口。
- `references/`：运行时规则、gate、workflow、Harness、adapter 和 discipline。
- `templates/`：task artifact、Harness 运行证据和 Worker prompt 模板。
- `scripts/`：package、检查、artifact 初始化、repo contract 同步和 optional visual companion 工具。

## 演进方向

Dev Cadence Core 应保持平台无关。Codex Plugin 是当前优先落地形态，不是最终平台形态的全部。后续可以在真实任务验证稳定后演进为：

```text
Codex Plugin publishing target
  -> Thin repo-local contract + specs
  -> Protocol Harness
  -> Workflow Automation
  -> Agent Orchestration Platform
  -> Enterprise Control Plane
```

平台化准入条件包括：真实任务覆盖足够、gate 规则趋稳、Harness 运行证据可审计、权限审批清楚、团队确认流程收益大于流程负担。
