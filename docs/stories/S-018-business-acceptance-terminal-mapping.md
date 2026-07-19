# S-018 Delivery 终态映射与 Manual Recovery

## 基本信息

- ID：`S-018`
- Version：`3`
- Status：`Draft`
- Priority：`P1`
- Change Type：Feature

## 目标

让三个开发 workflow 的业务验收结果和无法正常 Completion 的恢复结果都进入明确、可审计的终态路径。

## 背景

业务验收决策如果没有明确映射到 manifest 终态和后续动作，run 可能停留在不一致状态，或将带风险接受和拒绝错误地当作普通完成。正常 Completion 无法继续时也需要保留原因、恢复尝试和资产状态，而不是遗留 `pending` run。

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

## 验收标准

1. 三种业务验收决策都具有明确且互不混淆的 Completion 行为。
2. manifest 终态与验收记录保持一致。
3. `rejected` 不会被报告为成功完成，`accepted_with_risk` 不会丢失风险。
4. 正常 Completion 确实无法继续时，三个 workflow 可以在用户确认后形成包含恢复与保留信息的 `abandoned` 终态。
5. 可恢复场景仍优先执行正常恢复，manual recovery 不会绕过正常 Completion。
6. manual recovery 保留后续人工恢复所需的证据。

## Story Relationships

- Supersedes：[S-023 Manual Recovery 终态](S-023-manual-recovery-terminal-state.md)。

## 依赖

- 最终验证和业务验收记录契约保持可用。

## Open Questions

- [Q-008 Business Acceptance 的 rejected 路径](../open-questions.md#q-008)：`rejected` 应返回返工阶段还是进入独立关闭终态，是否需要按原因区分？
- [Q-012 Manual Recovery 的允许条件](../open-questions.md#q-012)：哪些失败类别允许进入 manual recovery，哪些必须继续阻塞？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Business Acceptance 终态映射 Story。 | 闭环验收决策、manifest 终态和后续动作。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 吸收 S-023，扩展为 Delivery 终态映射与 manual recovery。 | 两项工作共同修改 Completion 状态机、manifest 终态和三个 workflow 的对称契约，拆分不形成独立交付价值。 |
| 3 | 2026-07-19T20:23:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 补全 manual recovery 的恢复优先、证据保留和命令边界，并修正标题。 | 确保吸收 S-023 后不会绕过可恢复失败或丢失人工恢复证据。 |
