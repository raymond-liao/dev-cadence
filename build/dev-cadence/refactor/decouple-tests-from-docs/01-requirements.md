# 需求确认：解除自动化测试对 `docs/` 的依赖

## 状态

🔄 `in_progress` - 等待用户确认。

## 结构目标

移除自动化测试对仓库 `docs/` 下文件和目录的依赖。测试必须直接验证可执行或机器消费的权威源。当测试确实需要具有代表性的 Markdown 内容时，必须创建由测试自身维护的固定样本，不得读取面向人的仓库文档作为 fixture。

## 现状证据

当前测试套件有两处直接以 `docs/` 内容作为输入：

- `tests/discovery-contract.sh` 读取 `docs/workflows/discovery.md` 和 `docs/stories/S-002-discovery-prd-incremental-versioning.md`，随后断言其中的自然语言模式。
- `tests/document-conventions-contract.sh` 扫描 `docs/features`、`docs/stories`、`docs/bugs` 和 `docs/tasks` 下的工作项卡片，随后断言这些人类可读文档的章节标题。

这与仓库的 Documentation Test Boundary 冲突：不得仅为锁定人类可读文档措辞而新增或修改自动化测试。

## ✅ 范围

- 从自动化测试中移除对仓库 `docs/` 文件和目录的直接读取与扫描。
- 删除唯一作用是锁定说明文档措辞的断言。
- 保留对 `src/skills/**`、`src/AGENTS-snippet.md`、脚本、配置、分发包内容及其他可执行或机器消费资产的测试。
- 保留对 workflow 所声明 `docs/` 目标输出路径的断言；此类断言验证 workflow 契约字符串，不读取仓库文档。
- 只有在解析器、检查器或可执行行为确实需要文档形态输入时，才使用测试自身维护的固定 Markdown 样本。
- 验证自动化测试不再把仓库 `docs/` 文件或目录作为输入。

## ❌ 非范围

- 重组或修改 `docs/` 下的文档。
- 改变 workflow 行为或目标仓库产物路径。
- 重写无关的契约测试。
- 为人类可读措辞、链接、格式偏好或文档完整性增加测试。
- 修改 `src/vendor/superpowers/**`。

## 必须保持的行为

- 运行时 workflow 规则和安装包行为的契约检查继续执行。
- `bash scripts/check-all.sh` 继续作为仓库级验证入口。
- `docs/product-design/prd.md` 等 workflow 声明的目标路径仍可作为运行时字面量契约接受测试。
- 工作项章节语义继续在机器消费的规则源上接受测试，不再通过仓库中的具体文档实例验证。

## 成功标准

1. `rg` 找不到任何打开、扫描或断言 `$ROOT_DIR/docs/**` 的测试。
2. 两处现有直接依赖被删除或替换，同时不削弱对可执行规则源的检查。
3. 可执行测试逻辑需要的任何文档形态 fixture 都由测试自身维护。
4. 受影响的聚焦测试通过。
5. `bash scripts/check-all.sh` 通过。

## 风险与假设

- 删除说明文档断言后，可能发现某些预期规则没有在权威源上接受断言。此类规则应针对 `src/skills/**` 测试，不得为了维持断言数量而从 `docs/` 复制文本。
- `tests/document-conventions-contract.sh` 当前同时检查权威 skill 规则和具体 docs 实例；删除实例扫描的目的就是停止把现有工作项文档当作测试 fixture。
- 当前边界内没有未决问题。
