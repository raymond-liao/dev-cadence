# S-008 需求确认

## 需求来源

- [S-008 Skill 语义视觉规范](../../../../docs/delivery/stories/S-008-skill-semantic-visual-markers.md)，Version `2`
- 当前对话对适用范围的补充：语义 emoji 适用于 skill 中的正反例、成对边界、Red Flags 和其他高价值对比区块。

## 已确认范围

1. 创建 `src/skills/document-conventions/SKILL.md` 共享辅助 skill，并将其包含在构建后的 `.dev-cadence` 安装包中。
2. 将 `document-conventions` 定义为 Dev Cadence 管理的 Markdown 公共呈现规则权威来源；它不是业务 workflow，不创建 workflow run。
3. 定义稳定语义：
   - `✅`：必须、适用、正确或通过；
   - `❌`：禁止、不适用、错误或失败；
   - `❓`：歧义、未解决或需要澄清；
   - `⚠️`：风险、例外、警告或有条件执行；
   - `ℹ️`：确有必要的补充说明。
4. 每个标识必须配合明确文字、决定或原因，emoji 不能成为唯一语义来源。
5. 选择性应用于 Must/Must Not、Allowed/Forbidden、正例/反例/歧义例、Passed/Failed 和 Red Flags 等高价值对比与决策结构。
6. 不机械装饰普通正文和普通列表项。
7. 不在文件名、路径、命令、ID、配置值、Git 引用、机器读取值或正式状态枚举中加入 emoji。
8. 更新 `using-dev-cadence`：任何 workflow 创建或更新 Dev Cadence 管理的 Markdown 前必须读取 `document-conventions`；入口不复制完整语义映射。
9. 在当前已安装 workflow 的代表性高价值区块应用共享语义，不改变业务规则、阶段、确认门禁或状态机。
10. 增加契约测试，覆盖共享 skill、分发包、入口接入、稳定语义、文字伴随和代表性 workflow 应用。
11. 同步可安装包，并评估版本号，因为本次修改改变安装后的 workflow 行为。
12. 多方案比较文档在用户确认选项后使用 `✅ Selected` 标识最终选择；未选但仍有效的方案保持中性，明确拒绝才使用 `❌ Rejected`，尚未决策时使用 `❓ Decision Pending`。

## 非目标

- 不实现 S-009 的 manifest、报告和用户摘要状态呈现。
- 不实现 S-010 的文档链接规范或链接完整性检查。
- 不给每个标题、段落或列表项增加 emoji。
- 不用视觉标识替代 `must`、`do not`、`when`、`before`、`after` 等规范性措辞。
- 不改变 workflow 路由、阶段顺序、确认要求、状态值或 Completion 语义。
- 不增加新的业务 workflow、workflow run 类型或 Available Flows 路由项。
- 不修改 vendored Superpowers 文件。

## 验收标准

1. `src/skills/document-conventions/SKILL.md` 存在，构建和安装后位于 `.dev-cadence/skills/document-conventions/SKILL.md`。
2. 共享 skill 明确说明它是文档规范辅助能力，不是业务 workflow，也不创建 run。
3. 五种标识具有稳定且不冲突的含义，并始终保留文字说明。
4. Must/Must Not、正例/反例/歧义例和 Red Flags 能使用一致标识提高扫描效率。
5. 普通正文和机器敏感字面值不会被机械装饰。
6. `using-dev-cadence` 要求写入 Dev Cadence 管理的 Markdown 前读取共享规范，且不复制完整映射。
7. Discovery、Feature Dev、Bug Fix 和 Refactor 包含代表性高价值语义标识，业务规则保持不变。
8. 源 skill、分发包和当前 dogfood 安装包包含一致规则。
9. 契约测试覆盖共享 skill 打包、入口接入、稳定语义和代表性使用，不锁死所有自然语言。
10. 现有仓库检查通过，版本号与安装行为变化一致更新。
11. 技术方案等多方案文档能够区分已选、未选但有效、明确拒绝和尚待决策四种状态，不会把推荐误写成已确认选择。

## 假设

- 当前构建脚本会复制 `src/skills` 下全部目录，因此新增 skill 目录不需要重构构建脚本，只需补充契约验证。
- S-008 只要求代表性 workflow 视觉改造，不做穷举式重排版。
- S-009 和 S-010 后续继续扩展同一个共享 skill。

## Open Questions

- 无。
