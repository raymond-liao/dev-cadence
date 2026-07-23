# S-035 Refactor 测试敏感性检查

## 基本信息

- ID：`S-035`
- Version：`1`
- Status：`Done`
- Priority：`P2`
- Change Type：Refactor

## 目标

当 Refactor 新增 characterization 或 contract test 保护既有行为时，通过可逆 sensitivity check 证明测试能够检测预期行为变化。

## 背景

保护既有行为的测试可能在首次运行时直接通过，但“通过”本身不能证明测试对目标行为敏感。需要临时扰动受保护行为或使用 mutation tooling，观察预期失败后恢复原行为并再次通过。

## ✅ 范围

- 对新增的既有行为 characterization 或 contract test 执行可逆 sensitivity check。
- 允许临时扰动受保护行为或使用 mutation tooling。
- 要求测试因预期原因失败，再恢复原行为并确认通过。
- 禁止保留 mutation 或为了制造 RED 改变期望行为。
- 使用契约测试保护 Refactor workflow 中的 sensitivity check 规则。

## ❌ 非范围

- 不要求已经证明敏感的现有测试重复执行 mutation。
- 不为纯结构测试制造虚假的 RED 阶段。
- 不改变 Refactor 的行为保持目标。

## 验收标准

1. 新增既有行为保护测试不能仅凭首次通过成为基线证据。
2. sensitivity check 能证明测试会对目标行为变化产生预期失败。
3. 临时扰动完全恢复，最终行为和测试均保持绿色。
4. 契约测试防止该规则从 Refactor workflow 中丢失。

## 依赖

- 无强制前置依赖。

## 历史交付证据

- Implementation Commit：`c743f8c047452b22d9cc32c0636880e914342bd5`。
- 主要修改：`src/skills/refactor/SKILL.md`。
- 验证契约：`tests/workflow-symmetry.sh` 中的 `refactor characterization sensitivity check` 断言。
- 该能力随行为保持型 Refactor workflow 首次交付。

## Open Questions

- 无。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 根据既有实现和 Git 历史补录已完成 Story。 | 原能力已在 `c743f8c` 交付，但 Backlog 仅保留纯文本完成项。 |
