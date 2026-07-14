# S-008 技术方案

## 已确认需求来源

- [需求确认](01-requirements.md)
- [S-008 Skill 语义视觉规范](../../../../docs/stories/S-008-skill-semantic-visual-markers.md)，Version `2`

## 推荐方案

新增独立共享辅助 skill `document-conventions`，集中保存 Dev Cadence 管理的 Markdown 公共呈现规范。`using-dev-cadence` 只增加一条前置读取规则；业务 workflow 不复制完整映射，只在代表性的高价值区块实际使用共享语义。

本 Story 先实现语义视觉基础层：五种标识、使用原则、禁止范围和示例。S-009、S-010 后续在同一 skill 中分别增加状态呈现和快捷链接规则。

多方案文档采用显式选择语义：确认后在选定方案标题或决策单元格使用 `✅ Selected`；普通备选方案不加否定标识；明确拒绝使用 `❌ Rejected`；尚未选择使用 `❓ Decision Pending`。推荐状态不能自动升级为 Selected。

## Codebase Exploration Findings

### 视角一：构建与安装边界

- `scripts/build.sh` 直接复制整个 `src/skills` 目录，新建 `src/skills/document-conventions/SKILL.md` 会自动进入 `dist/.dev-cadence/skills/`，不需要修改构建复制逻辑。
- `tests/package-contract.sh` 会校验所有 source skill 与 dist 同步，但 required files 尚未显式要求新共享 skill。
- `tests/install-contract.sh` 验证替换式安装，需要增加安装后新 skill 存在且内容同步的断言。
- 当前仓库跟踪 `.dev-cadence/` 作为 dogfood 安装包，实施后需要运行安装脚本同步，而不是直接编辑该目录。

### 视角二：入口与职责边界

- `src/skills/using-dev-cadence/SKILL.md` 是所有 Dev Cadence 请求的入口，适合规定“写文档前读取共享规范”，但不适合保存完整视觉映射。
- `document-conventions` 不应加入 Available Flows，因为它不处理业务请求、不创建 run，也不与 Feature/Bug/Refactor/Discovery 竞争路由。
- `tests/skill-description-contract.sh` 当前逐项锁定已安装 skill description，需要为共享 skill 增加符合 `Use when` 形式的描述与非流程化校验。

### 视角三：视觉应用与回归风险

- Discovery 的 `Workflow Boundary` 是最清晰的 Must/Must Not 成对区块，适合改为 `### ✅ Discovery Must` 与 `### ❌ Discovery Must Not`。
- `using-dev-cadence`、Feature Dev、Bug Fix 和 Refactor 都有 Red Flags；统一使用 `⚠️` 标题可以提高扫描效率。
- 三个开发 workflow 都有 `Ambiguous Acceptance Feedback`，统一使用 `❓` 可以表达需要澄清，同时保持对称。
- `tests/workflow-symmetry.sh` 会解析部分精确标题，视觉修改必须避开其结构敏感区，或同步调整测试以验证新标题。

## 关键文件

- `src/skills/document-conventions/SKILL.md`：共享文档规范权威来源。
- `src/skills/using-dev-cadence/SKILL.md`：增加写文档前读取共享规范的入口规则，并应用代表性 `⚠️` 标题。
- `src/skills/discovery/SKILL.md`：应用 `✅`/`❌` Workflow Boundary 区块。
- `src/skills/feature-dev/SKILL.md`：应用 `⚠️` Red Flags 与 `❓` 歧义反馈标题。
- `src/skills/bug-fix/SKILL.md`：与 Feature Dev 对称应用。
- `src/skills/refactor/SKILL.md`：与 Feature Dev 对称应用。
- `tests/document-conventions-contract.sh`：验证共享语义、入口接入、代表性使用和禁止范围。
- `tests/run-all.sh`：执行新增契约测试。
- `tests/package-contract.sh`、`tests/install-contract.sh`、`tests/skill-description-contract.sh`：覆盖构建、安装与描述契约。
- `version`：反映新共享 skill 和安装行为变化。

## 备选方案

### 方案 A：把完整视觉规范写入 `using-dev-cadence`

优点是入口一定会读取；缺点是路由职责与文档呈现职责混合，S-009、S-010 会继续膨胀入口文件。拒绝。

### 方案 B：创建普通 Markdown 规范文档

优点是简单；缺点是代理不会自然发现或读取，必须在每个 workflow 重复提醒，执行可靠性较低。拒绝。

### 方案 C：共享辅助 skill，并由入口要求读取

职责清晰、可发现、可继续扩展，又不会进入业务路由表。采用。

## 测试策略

1. 先新增失败的 `tests/document-conventions-contract.sh`，证明共享 skill、入口规则和语义标识尚不存在。
2. 新增 shared skill 和入口接入后运行聚焦测试至通过。
3. 对四个 workflow 做代表性标题更新，并通过 workflow symmetry 与新契约测试防止不对称或语义冲突。
4. 运行构建、package、install、description、whitespace 和完整契约检查。
5. 运行 `scripts/install.sh .` 同步 dogfood 包，再验证 `.dev-cadence` 与 source/dist 一致。

## 风险与约束

- Markdown 标题变化可能影响精确标题解析测试，需要在 RED 阶段先暴露并有针对性地调整。
- Emoji 不能替代规范性文字，否则会削弱规则精度和无障碍阅读。
- S-008 不得提前实现 S-009 状态映射或 S-010 链接完整性。
- `src/vendor/superpowers/**` 不在修改范围内。

## 方案结论

- ✅ Selected：采用共享 `document-conventions` skill。
- 当前用户已明确要求不中途确认，因此该方案按 delegated confirmation 进入实施计划；所有记录仍保留完整阶段边界和证据。
