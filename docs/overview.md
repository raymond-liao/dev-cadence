# Dev Cadence 概览

Dev Cadence 是一套面向 AI coding agents 的工程交付纪律。它把需求澄清、计划、实现、验证、Review 和人工验收组织成可审查、可交接、可验证、可验收的软件交付节奏。

## 定位

Dev Cadence 不是一个插件，也不是项目管理系统。它是一套 AI-native software delivery discipline，用来约束 AI agents 在真实代码仓库中的交付过程。

Codex Plugin 和 repo-embedded runtime 是当前分发和执行形态，不是 Dev Cadence 的项目本体。长期看，Dev Cadence Core 应保持平台无关，可以被不同 agent runtime 实现。

## 愿景

Dev Cadence 的愿景，是让 AI agents 成为真实软件工程中可信赖的交付参与者。

它不追求单纯让 AI 更快写代码，而是让 AI 参与的软件变更具备清晰意图、明确范围、受控执行、可验证证据和最终的人类风险接受。Dev Cadence 通过 Human、Supervisor、Harness 和 Worker Agents 的职责分离，以及 artifacts、runs、gates 和 acceptance 的证据体系，让 AI coding agents 从“能写代码的工具”进化为“能够在真实工程体系中可信交付的软件协作者”。

## 解决的问题

Dev Cadence 主要解决 AI agent 参与软件交付时的工程风险：

- 需求和上下文容易在多轮执行中漂移。
- 改动过程缺少可审查、可交接的事实依据。
- 测试、Review、验证和验收证据容易散落在聊天记录中。
- Worker Agent 容易自行宣布完成或接受风险。
- 多 agent 协作缺少稳定的任务边界和交接协议。

## 核心模型

Dev Cadence 的核心架构只区分四类角色：Human、Supervisor、Harness 和 Worker Agents。

- Human 决定目标、约束、权限、风险接受和最终验收。
- Supervisor 决定 workflow state、routing、gate 和下一步。
- Harness 负责安全执行边界、上下文注入、工具权限、日志和证据记录。
- Worker Agents 负责完成需求、设计、计划、实现、测试、Review 和研究等具体工程工作。

完整角色关系见 [Dev Cadence 架构](architecture.md)。

## 怎么阅读

| 文档 | 说明                                              |
|---|-------------------------------------------------|
| [Dev Cadence 架构](architecture.md) | Human、Supervisor、Harness 和 Worker Agents 的核心关系  |
| [Dev Cadence 角色](roles/) | Human、Supervisor、Harness 和 Worker Agents 各自负责什么 |
| [Dev Cadence 工作流](workflows/) | Dev Cadence 支持哪些工作流，每类任务怎么走                     |
| [Dev Cadence 产物](artifacts/) | `specs/records/{task_id}/` 下每个产物是什么、怎么看         |
| [Dev Cadence Runs](runs/) | `runs/{run_id}/` 下每个 Harness 运行证据是什么、怎么看        |
| [Dev Cadence 门禁](gates/) | G1-G6 gate 控制什么风险、什么时候允许继续                      |
| [Dev Cadence 安装](installation.md) | 业务仓库内置 runtime、本机开发安装和卸载命令                      |
| [Dev Cadence 当前验证](validation.md) | 当前回归检查、打包和 smoke test 命令                        |
| [Codex Plugin 模块边界](codex-plugin-boundaries.md) | 当前 Codex Plugin 的模块边界、薄仓库契约和发布资源                |
