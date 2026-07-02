# Dev Cadence

Dev Cadence 是一套面向 AI coding agents 的工程交付纪律，用来把 AI 参与的软件变更组织成可审查、可交接、可验证、可验收的交付过程。

它的目标是让 AI agents 成为真实软件工程中可信赖的交付参与者。

## 核心架构

```text
┌──────────────────────────────────────────────────────────────┐
│                          Human                               │
│             Risk acceptance / final decisions                │
└──────────────────────────────┬───────────────────────────────┘
                               │ decisions, constraints
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                       Supervisor                             │
│                 Workflow control / next step                 │
└───────────────┬──────────────────────────────┬───────────────┘
                │ execution request            │ run result
                ▼                              ▲
┌──────────────────────────────────────────────────────────────┐
│                         Harness                              │
│              Safe execution boundary / recording             │
└───────────────┬──────────────────────────────┬───────────────┘
                │ controlled context           │ artifacts/evidence
                ▼                              ▲
┌──────────────────────────────────────────────────────────────┐
│                      Worker Agents                           │
│                 Concrete engineering work                    │
└──────────────────────────────────────────────────────────────┘
```
一句话区分：

```text
Human 决定是否接受风险。
Supervisor 决定下一步该做什么。
Harness 负责这一步怎么被安全执行和记录。
Worker Agents 负责完成具体研发工作。
```

核心约束：

1. Human 是最终意图、风险接受和最终验收的来源。
2. Supervisor 控制 workflow state、routing、预算、循环和升级，不亲自写代码。
3. Harness 包住一次执行，负责上下文、权限、工具边界、日志和证据记录。
4. Worker Agents 交付具体研发产物，不能自行宣布完成或接受风险。
5. Chat 不是事实来源，已确认 artifact 和实际执行证据才是后续执行依据。

## 快速开始

安装、同步、使用和本仓库维护命令见 [Dev Cadence 安装](docs/installation.md)。

## 文档入口

- [Dev Cadence 概览](docs/overview.md)：愿景、定位和阅读顺序。
- [Dev Cadence 安装](docs/installation.md)：业务仓库内置 runtime、本机开发安装和卸载命令。
- [Dev Cadence 当前验证](docs/validation.md)：当前回归检查、打包和 smoke test 命令。
