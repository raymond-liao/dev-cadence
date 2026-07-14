# S-024 Bug 诊断门禁

## 基本信息

- ID：`S-024`
- Version：`1`
- Status：`Draft`
- Priority：`P2`
- Change Type：Feature

## 目标

阻止根因未验证或问题仍有歧义的 bug-fix run 进入 Repair Solution。

## 背景

在问题边界或根因尚未确认时设计修复方案，容易修错问题、扩大影响面或把需求歧义误判为实现缺陷。Repair Solution 前需要明确的诊断就绪条件。

## ✅ 范围

- 定义进入 Repair Solution 前必须满足的诊断条件。
- 要求已验证根因或足以支持修复边界的因果证据。
- 对问题歧义、需求冲突和证据不足给出返回或阻塞路径。
- 在诊断记录和 manifest 中保存门禁决策。

## ❌ 非范围

- 不要求建卡时确认根因。
- 不在本 Story 中定义 RED/GREEN proof 格式。
- 不把需求变更继续作为 Bug 修复处理。

## 验收标准

1. 根因未验证且缺少替代因果证据时不能进入 Repair Solution。
2. 歧义问题会返回澄清或保持阻塞，不会伪装为已诊断。
3. 门禁决策和依据可在持久化记录中恢复。

## 依赖

- 无强制前置依赖。

## Open Questions

- 哪些替代因果证据足以在无法完全复现时通过门禁？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 Bug 诊断门禁 Story。 | 防止在问题和根因仍不明确时过早设计修复。 |
