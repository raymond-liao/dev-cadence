# 回归测试报告：解除自动化测试对 `docs/` 的依赖

## 状态

✅ `passed` - 最终回归验证通过。

## 验证命令与结果

| 检查 | 结果 |
| --- | --- |
| `bash tests/discovery-contract.sh` | ✅ `passed` |
| `bash tests/document-conventions-contract.sh` | ✅ `passed` |
| `bash scripts/check-whitespace.sh` | ✅ `passed` |
| `bash scripts/check-all.sh` | ✅ `passed` |
| `rg -n '\\$ROOT_DIR/docs|DISCOVERY_WORKFLOW|S002_STORY|WORK_ITEM_DIRS|find .*docs' tests --glob '*.sh'` | ✅ `passed`：无输出，退出码为 1 |
| `git diff --check` | ✅ `passed` |

## 覆盖结论

- 两处仓库 `docs/` 直接输入已移除。
- 对 `src/skills/**`、入口 skill、安装片段和目标仓库路径契约的检查仍然执行。
- 没有新增 Markdown fixture，也没有为人类可读文档措辞增加测试。

## 残余风险

- 现有 docs 实例不再被自动化测试扫描；这属于已确认的测试边界调整。
- 未发现需要额外生产行为验证的变更。
