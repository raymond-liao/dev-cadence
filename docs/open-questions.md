# Open Question Registry

## Current Open Questions

| ID | Type | Status | Owner | Summary | Authoritative Source | Impact | Suggested Resolution Stage |
| --- | --- | --- | --- | --- | --- | --- | --- |
| OQ-001 | Cross-cutting | Open | Unassigned | 工作项应如何记录产生依据，以及何时需要独立的 Decision 资产？ | Registry temporary body | 缺少统一规则时，卡片可能只能说明实施依赖，无法稳定追溯其产生原因；新增集中式决策文档又可能与现有权威资产形成双写。 | Work Item Analysis 与资产治理设计 |

## Unassigned Question Details

### OQ-001 工作项产生依据与 Decision 资产边界

#### Context

Backlog 中的 `Depends On` 只表达实施前置关系，不能说明工作项为什么产生。现有卡片通常通过背景、目标和 Change Log Reason 描述问题，但没有统一、可验证的来源追溯规则。

集中式 Decision 文档可以提高跨卡片决策的可发现性，但如果复制 PRD、Business Architecture、架构文档、工作项卡片或 Delivery 方案已经拥有的结论，会形成需要同步的重复权威来源。

#### Unresolved Question

- 工作项是否必须记录产生它的权威事实、决策、上游工作项或缺陷证据？
- 只影响一张卡片的决策是否应由该卡片自身持有？
- 同时影响多张卡片、多个 workflow 或长期架构边界的决策应由现有权威资产、独立 Decision 文档还是决策索引持有？
- 如果引入 `docs/decisions.md`，它的所有者、适用范围、状态模型和维护触发点应如何定义？
- Open Question 解决并产生工作项后，如何保留从问题、确认结论到工作项的追溯，同时避免复制完整正文？

#### Impact

在该问题解决前，新增卡片可能继续缺少一致的产生依据；后续维护者难以判断卡片是否仍然有效、上游结论变化会影响哪些卡片，以及某项工作为什么被单独拆分。直接增加全局 Decision 文档也存在职责重叠和内容失真的风险。

#### Known Constraints

- `Depends On` 继续只表达实施依赖，不承担产生依据或决策追溯职责。
- 一个事实或问题必须只有一个完整正文来源，其他资产只保存必要摘要和链接。
- 未确认方向不得写成已接受决策或强制卡片契约。
- 新增 Decision 资产前必须先定义所有者、用途和维护方式。
- Open Question Registry 只维护未解决问题，不作为已确认决策历史或 Backlog 的替代品。

#### Suggested Next Step

在 Work Item Analysis 与资产治理设计中比较卡片内持有、独立 Decision 权威资产和决策索引三种方式，确认最小适用边界、单一正文来源和跨 workflow 维护责任后，再决定是否修改卡片契约或新增 `docs/decisions.md`。

## Change Log

| Date | ID | Change | Final Location |
| --- | --- | --- | --- |
| 2026-07-17 | OQ-001 | 登记工作项产生依据与 Decision 资产边界问题，由 Registry 暂时持有完整正文。 | Registry temporary body |
