# 重构方案：解除自动化测试对 `docs/` 的依赖

## 状态

🔄 `in_progress` - 等待用户确认。

## 当前结构问题

测试脚本把两种不同责任混在一起：

1. 验证 `src/skills/**` 等机器消费的规则源是否包含必要契约。
2. 把 `docs/` 下的说明文档和工作项实例当作测试 fixture，锁定自然语言和当前目录结构。

第二种责任会使文档重组变成测试耦合，也违反仓库对 `docs/` 的测试边界。当前基线测试虽然通过，但通过只说明现有文档恰好满足断言，不说明这些文档应该继续承担测试契约。

## 方案比较

### 方案一：删除 docs 实例断言，保留权威源断言

- 从 `tests/discovery-contract.sh` 删除对 `docs/workflows/discovery.md`、S-002 Story 和 Backlog 的直接路径变量及文档措辞断言。
- 从 `tests/document-conventions-contract.sh` 删除 `WORK_ITEM_DIRS` 及扫描 `docs/**` 工作项的循环。
- 保留已有的 `src/skills/**`、`src/AGENTS-snippet.md`、脚本和安装契约断言。
- 若某条规则尚未在权威源测试，针对 `src/skills/**` 增加最小断言，而不是复制 docs 文本。

优点：改动最小、边界清晰、不会制造伪 fixture。缺点：不再验证当前 docs 实例是否符合共享文档约定；这是有意取消的责任，不是遗漏。

### 方案二：把 docs 内容复制为测试内 heredoc fixture

将当前被读取的 Markdown 片段复制到测试脚本中的固定字符串，再继续断言。

优点：测试不再依赖仓库路径。缺点：仍然是在锁定人类可读文档措辞，fixture 与真实文档会逐渐漂移，无法证明权威规则源正确。因此不适合作为本次重构的主要方案。

### 方案三：新增通用 Markdown 契约解析器并用测试样本验证

实现一个测试辅助程序，读取测试自身维护的 Markdown 样本，验证标题、链接或状态语义，再由规则源测试验证契约。

优点：如果仓库确实有需要执行的 Markdown 解析行为，边界最完整。缺点：当前测试没有这样的生产解析器或可执行 Markdown 行为；新增解析器会扩大范围和维护成本，属于无必要的新能力。

## ❓ Decision Pending：建议方案

建议采用方案一，并保留方案三作为未来确有机器消费 Markdown 行为时的独立任务。方案一直接消除错误的测试输入边界，不改变 workflow、安装包或 docs 内容。

## 目标结构

```text
tests/
  discovery-contract.sh            -> 读取 src/skills、src/AGENTS-snippet、脚本或安装契约源
  document-conventions-contract.sh -> 读取 document-conventions 与各 workflow skill
  其他测试                         -> 使用测试内样本或真实可执行输入，不读取 docs 实例
```

`docs/` 仍可作为开发者阅读和 workflow 设计说明，但不再是自动化测试的输入边界。

## 外部契约保护

- 不改变 `src/skills/**` 的规则文本。
- 不改变 `src/AGENTS-snippet.md`、安装脚本、构建产物路径或目标仓库运行时路径。
- 不改变 `docs/` 文档内容或目录。
- 不删除对 `docs/product-design/prd.md` 等目标仓库输出路径字符串的契约断言；这些断言验证源规则声明，而非读取本仓库 docs。
- `bash scripts/check-all.sh` 仍是最终回归入口。

## 行为基线

已执行：

- `bash tests/discovery-contract.sh`：通过。
- `bash tests/document-conventions-contract.sh`：通过。

实施前还需执行完整 `bash scripts/check-all.sh`，并记录结果。由于本次只移除测试耦合，不新增兼容行为，不需要新增生产代码测试；删除的 docs 实例扫描不应由新的文档措辞测试替代。

## 迁移与回滚

1. 先删除两处直接 docs 输入。
2. 检查剩余断言是否仍针对 `src/skills/**` 等权威源；仅在发现权威源覆盖缺口时补最小源测试。
3. 运行两个聚焦测试，再运行完整检查。
4. 若权威源断言被误删或完整检查暴露缺口，回滚到本次重构前的提交，恢复对应源测试；不恢复 docs fixture。

## 风险

- 删除 docs 实例扫描后，某些历史文档可能不再被自动检查；这正是文档与自动化契约解耦的预期结果。
- 若 `document-conventions` 的某些规则只存在于 docs 实例而不在 skill 中，需把规则补到 skill 源再测试；不能继续把实例当权威源。
- 现有测试脚本是 shell 文本契约，修改后必须检查没有残留 `$ROOT_DIR/docs` 读取、`find docs` 扫描或 docs 文件断言。
