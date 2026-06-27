# 02-design.md

## 目的

`02-design.md` 记录选定技术方案、架构约束、备选方案、受影响组件、风险、ADR 需求和 G2 Design readiness。

## 写入阶段

需要 design 的任务进入 `design` 阶段时写入。

## 写入者

Architect 或 Planner，取决于任务风险和仓库实践。

## 必要输入

- [01-requirements.md](01-requirements.md)
- 现有 architecture docs 或 ADRs
- 相关代码、APIs、schemas、contracts 或平台约束

## 记录内容

- problem 和 chosen approach
- alternatives considered
- affected components
- data or control flow
- risks 和 required decisions
- required ADRs
- Gate G2 record

## Gate 影响

高风险或架构敏感任务需要 G2。缺少已接受的 design 或 ADR 证据时，S2 工作不能进入 implementation。

## 如何阅读

阅读它可以理解为什么选择当前技术方案，以及 implementation 必须保持哪些架构约束。

## 模板来源

- [templates/spec/02-design.md](../../templates/spec/02-design.md)
- [references/spec-templates.md](../../references/spec-templates.md)
