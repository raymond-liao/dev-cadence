# Dev Cadence 概览

Dev Cadence 是一套面向 coding agents 的 AI-native 软件交付协作框架。它把需求澄清、计划、实现、验证、Review 和人工验收组织成可审查、可交接的交付节奏。

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
