# research-report.md

## 目的

`research-report.md` 记录 research spike 的问题、约束、证据来源、方案比较、建议、信心、证据缺口、风险和 open questions。

## 写入阶段

`research`。

## 写入者

Researcher；必要时由 Architect 补充设计影响。

## 必要输入

- [00-brief.md](00-brief.md)
- [01-requirements.md](01-requirements.md)
- approved sources、仓库代码、测试、文档或外部资料
- Human 给定的研究边界或 decision boundary

## 记录内容

- research question
- constraints 和 non-goals
- decision boundary
- sources reviewed
- comparison criteria
- options
- recommendation
- confidence 和 evidence gaps
- risks、open questions 和 Human decisions
- follow-up delivery 是否需要另起交付流程

## Gate 影响

Research spike 不自动进入 implementation、test 或 review gate chain。缺少 `research-report.md` 时，research-spike 的证据不完整；如果建议影响长期方向、成本、风险、生产行为、安全、隐私或数据处理，需要 Human Gate 决策。

## 如何阅读

把它当作 decision input，而不是 implementation approval。只有 Human 明确批准后续交付时，才进入 `cadence-clarify`、`cadence-plan` 和后续实现流程。
