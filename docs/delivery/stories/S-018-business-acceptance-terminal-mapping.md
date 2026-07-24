# S-018 Delivery 终态映射与 Manual Recovery

## 基本信息

- ID：`S-018`
- Version：`4`
- Status：`Done`
- Priority：`P1`
- Change Type：Feature

## 目标

让三个开发 workflow 的业务验收结果和无法正常 Completion 的恢复结果都进入明确、可审计的终态路径。

## 背景

业务验收决策如果没有明确映射到 manifest 终态和后续动作，run 可能停留在不一致状态，或将带风险接受和拒绝错误地当作普通完成。正常 Completion 无法继续时也需要保留原因、恢复尝试和资产状态，而不是遗留 `pending` run。

## 角色、场景与业务价值

- 角色：维护 Dev Cadence Delivery workflow 的交付负责人，以及对交付结果作出业务验收决定的业务验收者。
- 场景：三个 Delivery workflow 已形成可供业务验收的结果；验收者选择接受、拒绝或接受残余风险，或者已接受的 run 在正常 Completion 中遭遇无法在当前 run 内恢复的阻断。
- 业务价值：每个业务决定和异常收尾都有可恢复、可审计的状态转换，后续维护者不会将返工、风险接受、正常集成和人工恢复混为成功完成。

## ✅ 范围

- 定义三个验收决策各自允许的 Completion 路径。
- 明确每种决策对应的 manifest 终态和后续动作。
- 记录 `accepted_with_risk` 的风险引用和责任。
- 定义仅在正常 Completion 确实无法继续时适用的 manual recovery 路径，以及 `abandoned` 终态的最小记录。
- 记录 manual recovery 的原因、已尝试恢复动作、代码/分支/worktree/运行记录的保留状态和后续责任。
- 用对称契约测试覆盖三个开发 workflow。

## ❌ 非范围

- 不改变业务验收决策枚举。
- 不自动替用户选择验收结果。
- 不在本 Story 中处理 Bug `not-a-bug` 终态。
- 不修改具体 merge、discard 或 worktree 命令。
- 不把仍可正常恢复的失败标记为 `abandoned`。
- 不删除后续人工恢复所需的证据。

## 可观察行为与业务规则

- Business Acceptance 的固定三项决策枚举保持不变。`accepted` 必须写入业务验收记录和 manifest 的 `accepted` 状态后进入正常 Completion；只有 Completion 的实际集成结果可以把 manifest 的整体状态更新为 `integrated`。
- `accepted_with_risk` 必须记录每项被接受风险的稳定引用、风险说明和后续责任人；它与 `accepted` 一样进入正常 Completion。若 Completion 形成 `integrated`，manifest 与业务验收记录仍必须保留原业务验收决定、风险引用和责任，`integrated` 只表达集成结果，不得抹去风险接受事实。
- `rejected` 必须记录拒绝理由，但不得进入 Completion、不得报告成功、不得标记为 `integrated`。理由必须足以确定最早受影响阶段；workflow 必须将该阶段返回 `in_progress`，将受影响的后续阶段和已失效证据返回 `pending` 或标记为失效，并将 run 恢复为 `in_progress`。理由不足以确定返工阶段时，workflow 必须停留在 Business Acceptance 请求澄清，不得猜测。
- manual recovery 只适用于已作出 `accepted` 或 `accepted_with_risk` 决定、正常 Completion 已被证明无法继续的例外。允许的阻断限于无法在当前 run 内恢复的 Git、分支或 worktree 状态，无法取得的必要权限，或不可恢复的外部环境阻断。
- 在进入 manual recovery 前，workflow 必须记录被阻断的正常 Completion 动作和证据、至少一次已尝试且失败的恢复动作、继续恢复为何不可行，以及用户明确确认放弃正常 Completion。可重试工具故障、验证或 Review 失败、未完成验收、普通返工、用户请求 discard，或仍可通过正常路径恢复的情况不得进入 manual recovery。
- manual recovery 的最小记录必须包含阻断类别与证据、已尝试恢复动作及结果、用户确认、代码/分支/worktree/run 记录的保留状态、后续责任人与下一步。仅当这些记录完整、所有阶段不再为 `pending` 且 checkpoint 值不再为 `pending` 时，manifest 才可进入 `abandoned`；不得删除人工恢复所需证据，也不得改变具体 merge、discard 或 worktree 命令。
- 三个 Delivery workflow 必须以对称规则实现上述转换。契约测试必须覆盖三种业务验收决定、`accepted_with_risk` 的风险保留、`rejected` 回到最早受影响阶段、允许与禁止的 manual recovery 条件、`abandoned` 的最小记录及其无 `pending` 终态约束。

## 验收标准

1. 三种业务验收决策都具有明确、互不混淆且在三个 Delivery workflow 中对称的后续行为。
2. `accepted` 与 `accepted_with_risk` 都进入正常 Completion；最终集成时仍能从 manifest 和业务验收记录识别原业务验收决定。
3. `accepted_with_risk` 的每项已接受风险都有稳定引用、说明和责任人；集成不会抹去这些信息。
4. `rejected` 不会进入 Completion 或被报告为成功；理由足够时，run 回到最早受影响阶段，理由不足时停留在 Business Acceptance。
5. 只有已接受 run 的正常 Completion 被不可恢复的 Git/worktree、权限或外部环境阻断，并且已有失败恢复尝试与用户明确确认时，三个 workflow 才可形成 `abandoned`。
6. `abandoned` 的记录包含阻断证据、恢复尝试、用户确认、资产保留状态、后续责任和下一步，且 manifest 不含 `pending` 阶段或 checkpoint。
7. 可恢复场景、验证或 Review 失败、普通返工、未完成验收和 discard 不会被 manual recovery 绕过。
8. 对称契约测试覆盖正常映射、返工回退、风险保留、manual recovery 的允许与拒绝路径，以及 `abandoned` 终态完整性。

## Story Relationships

- Supersedes：历史工作项 `S-023` Manual Recovery 终态；来源卡已删除。

## 依赖

- 三个 Delivery workflow 的最终验证、Business Acceptance、Completion 和 manifest 契约保持可用。
- 现有 delivery-record validator 与 workflow 对称契约测试可扩展，以验证终态记录完整性。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Business Acceptance 终态映射 Story。 | 闭环验收决策、manifest 终态和后续动作。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 吸收 S-023，扩展为 Delivery 终态映射与 manual recovery。 | 两项工作共同修改 Completion 状态机、manifest 终态和三个 workflow 的对称契约，拆分不形成独立交付价值。 |
| 3 | 2026-07-19T20:23:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 补全 manual recovery 的恢复优先、证据保留和命令边界，并修正标题。 | 确保吸收 S-023 后不会绕过可恢复失败或丢失人工恢复证据。 |
| 4 | 2026-07-20T17:33:03+0800 | Raymond Liao <raymond-liao@outlook.com> | 明确业务验收三种决策、返工回退、风险保留、manual recovery 条件和最小记录，并将 Story 标记为 `Ready`。 | 用户确认 `rejected` 返回最早受影响阶段；仅在正常 Completion 已失败且不可恢复时，经用户确认进入 `abandoned`。 |
| 4 | 2026-07-21T14:18:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 将 Story 状态更新为 `In Progress`。 | 用户明确请求开始实施；S-018 已是用户确认的 `Ready` Story。 |
| 4 | 2026-07-21T22:12:49+0800 | Raymond Liao <raymond-liao@outlook.com> | 将 Story 状态更新为 `Done`。 | 已接受的交付已本地集成并通过合并后验证。 |
