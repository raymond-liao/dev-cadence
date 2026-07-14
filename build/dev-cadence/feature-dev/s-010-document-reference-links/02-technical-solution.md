# S-010 文档引用快捷链接 - 技术方案

## 输入与边界

- 已确认需求：[需求确认](01-requirements.md)
- 精确路径：`build/dev-cadence/feature-dev/s-010-document-reference-links/01-requirements.md`
- 工作项：[S-010 文档引用快捷链接](../../../../docs/stories/S-010-document-reference-links.md)
- 工作项版本：`3`
- 本方案不改变 workflow 阶段、状态模型或 S-009 状态呈现。

## Codebase Exploration Findings

### 视角一：规则所有权与 workflow 对称接入

- 关键文件：`src/skills/document-conventions/SKILL.md`、`src/skills/using-dev-cadence/SKILL.md`、`src/skills/feature-dev/SKILL.md`、`src/skills/bug-fix/SKILL.md`、`src/skills/refactor/SKILL.md`、`src/skills/discovery/SKILL.md`。
- 现有模式：入口只要求在创建或更新 Dev Cadence 管理的 Markdown 前读取共享规范；共享 skill 已集中拥有语义标识、状态呈现和工作项范围标题契约。
- 约束：完整链接契约只能存在于 `document-conventions`；四个 workflow 需要对称声明应用面和验证时机，不能复制细节。
- 风险：只改共享 skill 会缺少 workflow 完成前检查门禁；在每个 workflow 复制规则会产生漂移。
- 必读文件：上述六个 skill，以及 `src/AGENTS-snippet.md`、根 `AGENTS.md`、`tests/document-conventions-contract.sh`、`tests/workflow-symmetry.sh`。

### 视角二：Markdown 路径、身份与生命周期

- 关键文件：`docs/stories/S-010-document-reference-links.md`、现有 `build/dev-cadence/**/manifest.md` 和阶段记录契约、`src/skills/document-conventions/SKILL.md`。
- 现有模式：manifest 与阶段记录使用仓库相对路径保存可移植身份；当前 S-010 run 已示范“有意义链接 + 精确路径”并存。
- 约束：快捷链接只用于真实存在、面向阅读、生命周期兼容的目标；命令参数、配置、输出位置和机器读取身份保留精确路径。
- 风险：`docs/` 链接 `build/` 会把短期记录升级为长期事实；尚未创建的阶段记录提前链接会制造死链；不可确认的标题锚点会造成表面可点击但实际无效。
- 必读文件：Story、Backlog、当前 run 的 `01-requirements.md` 和 `manifest.md`、S-008/S-009 的技术方案与实现记录、四个 workflow 的 Stage Records 和 Completion 部分。

### 视角三：链接验证与构建/安装契约

- 关键文件：`tests/document-conventions-contract.sh`、`tests/workflow-symmetry.sh`、`tests/run-all.sh`、`scripts/build.sh`、`scripts/check-whitespace.sh`、`scripts/check-all.sh`、`version`。
- 现有模式：Shell 契约测试通过 `rg` 验证规则所有权、语义存在和 workflow 对称性；构建把 `src/` 同步到忽略的 `dist/.dev-cadence/`。
- 约束：测试应验证语义而不锁死显示名称；提交前检查 tracked Markdown，System Testing 再检查当前 run 已生成文档；不能直接编辑 `dist/`。
- 风险：实现通用 Markdown parser 会显著扩大范围，并需处理锚点、转义、外部 URL 等复杂语法；本 Story 的最小可靠交付应把行为写入规范并用契约测试保护，而不是引入未经需求确认的新工具链。
- 必读文件：上述测试和脚本、`version`、`src/.dev-cadence.example.yaml`、`tests/package-contract.sh`、`tests/install-contract.sh`。

## 方案比较

### 方案 A：最小改动

只在 `document-conventions` 添加链接规则，并扩展现有契约测试。

- 优点：改动最少、所有权清晰。
- 缺点：四个 workflow 没有明确的提交前和完成前检查时机，验收标准 11 和 13 缺少可执行接入。

### 方案 B：完整链接检查器

新增独立 Markdown 链接解析脚本，扫描 tracked 文档、解析标题锚点，并接入所有 workflow 和 `check-all`。

- 优点：自动化程度最高。
- 缺点：需要定义完整 Markdown 方言、URL 编码、标题锚点算法和忽略策略，超出当前 Story 的最小范围；容易把历史无关文档问题变成本次阻塞。

### 方案 C：务实平衡

在共享 skill 集中定义选择性链接契约；四个 workflow 对称声明创建记录时应用该契约、提交前检查 tracked Markdown、Completion 前检查当前 run 已生成文档；扩展契约测试验证规则所有权和语义，不新增通用 parser。

- 优点：满足当前验收范围，保持单一规则所有者，避免引入新的状态或工具链，同时为后续独立链接检查器保留空间。
- 缺点：当前完整性检查仍由代理执行现有 shell/文件检查，而非专用 Markdown AST 工具。

## ✅ Selected：方案 C

用户已授权连续执行后续阶段，因此采用方案 C。它在最小改动与可执行门禁之间取得平衡，并符合“不批量修复历史文档、不新增状态”的边界。

## 设计细节

### 共享规则

在 `src/skills/document-conventions/SKILL.md` 增加独立 `Document References` 章节，明确：

- 三项链接条件：目标存在、用于阅读导航、目标生命周期不短于来源；
- 有意义的链接文本和相对于来源文档的仓库内路径；
- 稳定锚点策略；
- 导航链接与精确路径身份并存；
- 未创建目标保持 ⏳ `pending` 与计划路径；
- `docs/` 与 `build/` 生命周期方向；
- 移动/重命名后的链接更新；
- tracked Markdown 提交前检查与当前 run Completion 前检查；
- 禁止本机绝对路径、`file://` 和编辑器 URI；
- 命令、配置、输出位置、机器身份不转换为链接。

### Workflow 接入

在 feature-dev、bug-fix、refactor、discovery 的 Generated Status Presentation 邻近位置增加同构的 `Generated Document References` 规则：

- 所有 Dev Cadence 管理文档遵循共享引用契约；
- 提交前验证 tracked Markdown 本地链接；
- Completion 前验证当前 run 已生成文档的本地链接；
- 不复制三项条件、生命周期方向或 URI 禁止清单。

入口 `using-dev-cadence` 保持不变，因为它已是读取共享规范的唯一入口职责。

### 测试策略

- RED：先扩展 `tests/document-conventions-contract.sh`，断言共享规则和四 workflow 接入；预期因规则缺失失败。
- GREEN：添加最小规则文本，使 focused contract 通过。
- 回归：运行 `tests/document-conventions-contract.sh`、`tests/workflow-symmetry.sh`、`bash scripts/check-whitespace.sh`、`bash scripts/check-all.sh`。
- 分发验证：运行 `bash scripts/build.sh` 后使用 `rg --no-ignore` 比较 `src/` 与 `dist/.dev-cadence/` 的关键规则。
- 运行记录链接验证：对当前 run 的相对 Markdown 目标执行存在性检查，并扫描禁止 URI/本机绝对路径。

## 风险与约束

- ⚠️ 不实现完整 Markdown AST/锚点解析器；可靠锚点检查仅在代理能够确认标题时执行。
- ⚠️ `build/` 记录被忽略，阶段 checkpoint 可能为 `skipped: no tracked changes`，但记录仍必须保持完整。
- ⚠️ 当前分支与 S-004 并行，不能修改主 checkout 的 `AGENTS.md` 或合并其他任务改动。
- 版本：该修改影响可安装包和用户可见 workflow 行为，根 `version` 从 `0.11.0` 更新为 `0.12.0`。

## 技术方案结论

- Status：✅ `confirmed`
- Confirmation：用户于 2026-07-14 授权需求确认后连续完成后续阶段，无需中途再次确认；本方案按该委托确认执行。
