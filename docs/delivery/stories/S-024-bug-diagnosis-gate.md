# S-024 Bug 诊断门禁

## 基本信息

- ID：`S-024`
- Version：`3`
- Status：`Dropped`
- Priority：`P2`
- Change Type：Feature

## 目标

在 bug-fix 的 Problem Diagnosis 阶段明确三类结果：确认缺陷后进入 Repair Solution、确认非缺陷后正常关闭、证据不足时继续诊断或阻塞。

## 背景

在问题边界或根因尚未确认时设计修复方案，容易修错问题、扩大影响面或把需求歧义误判为实现缺陷。Repair Solution 前需要明确的诊断就绪条件。

## ✅ 范围

- 定义进入 Repair Solution 前必须满足的诊断条件。
- 要求已验证根因或足以支持修复边界的因果证据。
- 对问题歧义、需求冲突和证据不足给出返回或阻塞路径。
- 在诊断记录和 manifest 中保存门禁决策。
- 定义 `not-a-bug` 判断所需证据、用户确认、终态记录和需求变更的后续路由。

## ❌ 非范围

- 不要求建卡时确认根因。
- 不在本 Story 中定义 RED/GREEN proof 格式。
- 不在该路径实施行为变更。
- 不把用户取消修复等同于 `not-a-bug`。

## 验收标准

1. 根因未验证且缺少替代因果证据时不能进入 Repair Solution。
2. 已确认非缺陷的问题能够以 `not-a-bug` 终态结束，并保存依据和用户确认；需求变更会路由到正确流程。
3. 歧义或证据不足的问题会返回澄清或保持阻塞，不会伪装为已诊断或非缺陷。
4. 门禁决策和依据可在持久化记录中恢复。

## Story Relationships

- [S-022 Bug `not-a-bug` 终态](S-022-bug-not-a-bug-terminal-state.md) 已与本卡一同停止；两卡均不作为独立交付项实施。

## 依赖

- 无强制前置依赖。

## Open Questions

- [Q-011 Bug 非缺陷终态命名](../open-questions.md#q-011) 已标记为 `Invalid`：本卡已停止，不再需要为该交付项选择 manifest 终态命名。
- [Q-013 替代因果证据门槛](../open-questions.md#q-013) 已标记为 `Invalid`：本卡已停止，不再需要为该交付项定义替代因果证据门槛。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Bug 诊断门禁 Story。 | 防止在问题和根因仍不明确时过早设计修复。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 吸收 S-022，明确诊断阶段的缺陷、非缺陷和未决三类结果。 | `not-a-bug` 是诊断门禁的另一种结果，必须与进入 Repair Solution 的条件共同维护。 |
| 3 | 2026-07-19T20:23:56+0800 | Raymond Liao <raymond-liao@outlook.com> | 补全用户取消修复不等于 `not-a-bug` 的边界。 | 防止将处理意愿与缺陷性质混淆。 |
| 3 | 2026-07-21T14:44:22+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Dropped，并将 Q-011 与 Q-013 标记为 Invalid。 | 用户确认停止该工作项；不再进入 Ready 或交付。 |
