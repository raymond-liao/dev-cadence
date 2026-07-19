# S-019 最终验证版本绑定

## 基本信息

- ID：`S-019`
- Version：`2`
- Status：`Draft`
- Priority：`P2`
- Change Type：Feature

## 目标

将最终验证结论绑定到精确 commit、branch 和 tracked working-tree 状态，防止代码变化后继续使用过期结论。

## 背景

验证结果如果只关联模糊的“当前代码”，在 commit、分支或已跟踪文件变化后仍可能被误用。最终报告必须能判断被验证版本是否仍与交付候选一致。

## ✅ 范围

- 记录验证开始和结束时的精确 commit 与 branch。
- 记录 tracked working-tree 是否干净及相关差异身份。
- 在进入 Business Acceptance 和 Completion 前检查版本是否仍一致。
- 版本变化时使旧结论失效并返回最早受影响阶段。
- 复用既有 Implementation Base SHA、Final Implementation SHA 和 changed-files 范围，不重新定义实施提交审查身份。

## ❌ 非范围

- 不要求记录 untracked 临时文件，除非它们参与验证。
- 不替代 Refactor 的重构前行为基线。
- 不在本 Story 中定义风险跨阶段传递。

## 验收标准

1. 每个最终验证结论都有可复现的代码版本身份。
2. 验证后发生相关代码变化时不能继续使用旧结论。
3. 三个开发 workflow 对版本失效采用对称处理。

## 依赖

- 无强制前置依赖。

## Open Questions

- Q-009：tracked working-tree 差异使用 patch hash 还是其他稳定身份表达？

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建最终验证版本绑定 Story。 | 防止实现变化后继续沿用过期验证结论。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 收敛为最终验证身份与失效检查。 | 实施提交范围已有身份契约；剩余缺口是验证执行版本、tracked 差异和进入验收前的一致性判断。 |
