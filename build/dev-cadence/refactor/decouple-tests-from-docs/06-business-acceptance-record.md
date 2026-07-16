# 业务验收记录：解除自动化测试对 `docs/` 的依赖

## 状态

⏳ `pending` - 等待用户验收决定。

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

⏳ `pending`

请用户选择：

1. 接受本次重构，无剩余风险。
2. 接受但记录明确的剩余风险。
3. 拒绝并说明需要修改的范围。
