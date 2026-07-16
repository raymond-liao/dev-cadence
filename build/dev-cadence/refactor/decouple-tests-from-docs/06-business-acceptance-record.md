# 业务验收记录：解除自动化测试对 `docs/` 的依赖

## 状态

✅ `accepted` - 用户验收通过。

## 交付摘要

- 删除 `tests/discovery-contract.sh` 对仓库 `docs/` 文档的直接读取和文本断言。
- 删除 `tests/document-conventions-contract.sh` 对仓库 `docs/` 工作项实例的目录扫描。
- 保留权威 `src/skills/**`、安装规则和目标仓库输出路径契约检查。
- 未修改 `docs/**`、workflow 行为或安装包内容。

## 证据

- 实现提交：`fe6997d26c363063fd6d948cfa41379fb05f7014`
- [代码审查报告](04-code-review-report.md)：✅ `passed`，无 Critical/Important/Minor 发现。
- [回归测试报告](05-regression-test-report.md)：✅ `passed`。

## 验收决定

✅ `accepted`

- 决定：接受本次重构，无新增剩余风险。
- 用户反馈：“没发现问题，继续”。
- 日期：`2026-07-16`。
