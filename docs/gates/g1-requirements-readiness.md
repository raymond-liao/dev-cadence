# G1 Requirements Readiness

## 目的

G1 防止 intent、scope、non-goals、acceptance criteria 和 verification approach 尚不清楚时就开始 implementation。

## 检查阶段

`requirements` 之后，planning 或 implementation 之前。

## 必要输入

- [00-brief.md](../artifacts/00-brief.md)
- [01-requirements.md](../artifacts/01-requirements.md)
- Requirements Readiness Check
- 当 ambiguity 实质影响 implementation 或 acceptance 时，需要 Human clarification

## 通过条件

scope、non-goals、constraints、acceptance criteria 和 verification approach 清楚，且实质歧义已由具名 Human 解决或明确延后。

## 常见阻塞

- Expected behavior 不清楚。
- Reference behavior 或 comparison dimension 是从代码推断的，而不是被确认的。
- Scope reduction 或 non-goal 基于 agent assumption。
- Clarification 被归因给 Supervisor、Harness、Worker Agent 或 repository 证据。
- 用户 correction 使之前的 requirements 失效。

## 人工 Override

具名 Human 可以选择或延后某个 interpretation。该 decision 必须记录到 [01-requirements.md](../artifacts/01-requirements.md)；repository 证据本身不能让 G1 通过。
