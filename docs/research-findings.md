# Dev Cadence 研究结论

本文沉淀早期 `research/` 工作区中仍然有效的稳定结论。原始 research 工作区属于过程材料，不再作为仓库长期结构保留。

## 核心结论

Dev Cadence 的主判断成立：AI-native 软件交付不应停留在“单 Agent 写代码”，而应组织成：

```text
Human + Harness-Mediated Multi-Agent Team
```

更完整的框架表达是：

```text
Supervisor-Controlled
Harness-Mediated
Artifact-First
Spec-Driven
Quality-Gated
Multi-Agent Development Framework
```

其中最关键的取舍是：

- Agent 之间通过结构化 artifact 交接，而不是依赖聊天上下文。
- Supervisor 控制 workflow、状态、预算和 gates，不直接写代码。
- Harness 不是 Agent，而是每次 Agent 执行的运行边界，负责上下文注入、工具策略、权限、日志和证据。
- Tester 和 Reviewer 独立于 Developer，不能由 Developer 自行宣布完成。
- Human Gate 必须区分 approval、review、info 和 notify，不应把所有人类参与都写成同一种确认。
- `tests pass` 不够，必须记录可复现的验证证据、验证范围和残余风险。
- 任务需要分级，避免低风险任务流程过重，也避免高风险任务门禁不足。

## 已吸收的设计约束

早期研究中已被当前框架吸收的约束包括：

- 引入 Harness run context 和 execution report。
- 使用 Supervisor 状态机，而不是只写角色职责。
- 定义 `S0`、`S1`、`S2`、`incident` 和 `research-spike` 等任务分类。
- 将 Context Pack 与 Harness Run Context 分开：前者回答 Agent 应该知道什么，后者回答本次执行允许怎么做。
- 将需求、设计、任务、实现、测试、Review 和验收都落到持久 artifact。
- 对循环设置上限，超过上限必须升级给 Human。
- 对 incident 保留快速路径，但要求事后补偿 artifact 和风险记录。

## 已废弃的早期建议

早期 research 中出现过一些过渡方案，当前不再作为目标架构：

- 不再把 Dev Cadence 定义成单一简化版 Skill MVP。
- 不再把 Tester 和 Reviewer 合并成一个长期角色。
- 不再把 Harness 设计成一个普通 Worker Agent。
- 不再把源码仓库中的 research 工作区或历史 specs 当作测试和验收依据。

这些内容属于探索阶段的成本控制建议，不是当前框架 contract。

## 对当前仓库的影响

`research/` 下的 agents、workspace、wip 和原始报告属于过程材料。稳定结论保留在本文和其他 `docs/` 文档中；后续如果需要新的调研，可以临时创建本地工作区，但不应默认提交到仓库。

