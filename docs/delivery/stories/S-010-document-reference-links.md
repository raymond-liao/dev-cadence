# S-010 文档引用快捷链接

## 基本信息

- ID：`S-010`
- Version：`3`
- Status：`Done`
- Priority：`P1`
- Change Type：Enhancement

## 目标

让 Dev Cadence 生成的产品设计、工作项、manifest、阶段记录、测试报告和验收文档使用可点击的 Markdown 快捷链接引用其他文档，使用户能够直接导航到相关上下文，而不需要复制相对路径后手动查找。

## 背景

当前 workflow 经常要求文档记录其他资料的仓库相对路径，例如需求来源、技术方案、实施计划、测试报告、工作项或产品设计文档。只把路径写成普通文本或行内代码虽然可移植，但阅读者无法直接打开目标文档，长流程中的来源追踪和阶段切换效率较低。

文档引用与路径数据不是同一概念。面向阅读者的引用应当可导航；用于记录文件身份、命令参数、输出位置或尚未创建的计划路径时，仍需要保留精确路径文本。缺少统一规则时，代理可能把所有路径都变成链接、生成错误的相对路径，或者创建指向尚不存在文件的失效链接。

## User Story

作为阅读 Dev Cadence 交付文档的用户，我希望文档之间的引用可以直接点击打开，以便快速追踪需求、方案、实施、验证和验收上下文。

## ✅ 范围

- 在 S-008 创建、S-009 扩展的 `document-conventions` 共享 skill 中增加统一文档引用链接规则。
- `using-dev-cadence` 继续只负责要求 workflow 在创建或更新 Dev Cadence 管理的 Markdown 前读取共享规范，不保存完整链接契约。
- 当正文、列表、表格或摘要引用已经存在的仓库内文档时，使用 `[有意义的名称](相对路径)` 形式，不只显示普通文本或行内代码路径。
- 只有同时满足“目标真实存在、引用面向阅读导航、目标生命周期不短于来源文档”时才使用快捷链接；不满足条件时保留精确路径和状态说明。
- Markdown 链接使用相对于当前文档位置的可移植路径，不持久化本机绝对路径或编辑器专用 URI。
- 链接文本说明文档职责或内容，例如 `产品需求文档`、`技术方案`、`系统测试报告`，避免只重复完整文件路径作为名称。
- 需要定位到具体章节时，使用目标文档的稳定标题锚点；不存在稳定锚点时链接到文档本身，不编造不可用锚点。
- Manifest 的阶段表、来源索引和最终结果引用在目标文档存在后使用快捷链接。
- 当 manifest 或阶段记录既需要阅读导航又需要保存精确产物身份时，同时保留有意义的快捷链接和仓库相对路径字段；链接不能替代审计所需的路径身份。
- Requirements、Solution、Plan、Implementation、Review、Testing、Verification、Business Acceptance 和 Completion 记录之间的来源与结果引用使用快捷链接。
- PRD、Business Architecture、Open Question Registry、Feature、Story、Bug、Technical Task、Decision 和相关设计文档之间的阅读引用使用快捷链接。
- 外部网页或远程资料使用标准 Markdown URL 链接，并使用有意义的来源名称。
- 文件路径作为命令参数、配置值、输出位置、文件身份、代码示例或机器需要读取的精确值时，继续使用行内代码或代码块，不强制转换为链接。
- 目标文档尚未创建时，不生成伪装成可用引用的失效链接；使用 `⏳ pending` 等明确状态和计划路径，目标创建并验证存在后再更新为快捷链接。
- 长期文档只能链接到生命周期相同或更稳定的目标：`docs/` 下的产品设计、工作项和治理文档不得把 `build/` 下可能被忽略或清理的运行记录作为权威链接目标。
- `build/` 运行记录可以链接同一 run 内已存在的阶段记录，也可以链接 `docs/` 下的长期文档；链接不能把临时运行记录升级为长期业务事实来源。
- 移动或重命名文档时，更新仓库内受影响的 Markdown 链接，并验证不存在遗留的旧引用。
- 对本地 Markdown 链接执行完整性检查：从来源文档目录解析相对路径，验证目标存在，并在支持可靠验证时检查章节锚点。
- 包含空格或特殊字符的目标路径必须使用合法且可验证的 Markdown 链接写法，不通过本机专用路径绕过转义问题。
- 提交前检查 tracked Markdown 文档中的本地链接；workflow 完成阶段前检查当前 run 内已生成文档的本地链接。
- 更新已实现 workflow 的文档输出接入规则，保持 feature-dev、bug-fix、refactor 和 discovery 对共享 `document-conventions` 的使用方式对称；各 workflow 不复制完整链接契约。
- 更新契约测试，验证关键文档引用使用 Markdown 链接、路径保持仓库相对且不包含本机绝对路径，同时避免锁死具体链接文本。

## ❌ 非范围

- 不把所有出现的文件路径都机械转换为链接。
- 不为尚不存在的计划产物创建失效链接。
- 不用快捷链接替代 manifest、阶段记录或审计证据所需的精确仓库相对路径字段。
- 不使用 `file://`、`vscode://` 或其他编辑器专用 URI。
- 不把本机绝对路径写入持久化项目文档。
- 不允许 `docs/` 长期文档依赖 `build/` 临时记录作为权威来源。
- 不在本 Story 中实现文档搜索、站点生成器或链接预览界面。
- 不要求批量重写不属于当前 workflow 或没有阅读导航价值的历史路径数据。

## 验收标准

1. 已存在仓库文档之间的阅读引用使用可点击 Markdown 链接，而不是只显示普通相对路径。
2. 链接文本能够说明目标文档的职责或内容，不要求用户根据文件名猜测用途。
3. 只有真实存在、面向阅读且生命周期兼容的目标使用快捷链接；其他路径继续以精确文本和状态表达。
4. 需要引用具体章节时只使用真实、稳定的标题锚点，不生成虚构锚点。
5. 仓库内链接相对于当前文档正确解析，并保持跨机器和不同 checkout 路径可移植。
6. Manifest 和阶段记录需要审计身份时同时保存快捷链接和精确仓库相对路径。
7. `docs/` 长期文档不会把 `build/` 临时运行记录作为权威链接目标；运行记录可以链接同一 run 产物和长期文档。
8. 尚未创建的计划产物显示状态和路径，创建并验证后才转换为快捷链接。
9. 命令参数、配置值、输出位置和文件身份继续使用精确路径文本，不被错误转换为链接。
10. 文档移动或重命名后，相关链接得到更新且不会保留旧路径引用。
11. 提交前检查 tracked Markdown 链接，workflow 完成前检查当前 run 已生成文档的链接，失效目标会阻止完成声明。
12. 持久化文档不包含本机绝对路径、`file://` 或编辑器专用 URI。
13. Feature、Bug Fix、Refactor 和 Discovery 的同类文档引用规则保持对称。
14. 链接规则只在 `document-conventions` 中集中维护，各 workflow 和入口不包含可能漂移的完整副本。
15. 契约测试覆盖共享 skill 接入、选择性链接、路径身份保留、生命周期方向、目标存在性和禁止 URI，同时避免锁死具体显示名称。

## Story Relationships

- Follows：`S-009` 生成文档状态呈现。
- Related：现有 workflow 的 manifest 和阶段记录契约。
- Precedes：`S-005` 全局 Open Question Registry。

## 依赖

- `S-009` 生成文档状态呈现。

## 后续工作

- S-005、S-006、S-002 和 Work Item Planning 创建的新文档直接使用本 Story 的链接契约。
- 后续新增 workflow 必须区分可导航文档引用与仅作为数据保存的精确路径。

## Open Questions

- 无。

## 相关文档

- [S-005 全局 Open Question Registry](S-005-open-question-registry.md)
- [S-008 Skill 语义视觉规范](S-008-skill-semantic-visual-markers.md)
- [S-009 生成文档状态呈现](S-009-generated-status-presentation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建文档引用快捷链接 Story。 | 让跨文档来源和结果引用可以直接导航，同时保留路径数据的精确性和可移植性。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 增加选择性链接、路径身份、文档生命周期和链接完整性规则。 | 只有真实存在且适合导航的目标才应使用快捷链接，长期文档不能依赖临时记录，审计路径也不能被链接替代。 |
| 3 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 明确链接规则扩展共享 `document-conventions` skill，并依赖 S-009。 | 文档公共规则需要集中维护，入口和各 workflow 只负责读取与遵守，不能复制多套链接契约。 |
| 3 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 开始实施并进入业务验收前状态。 | 技术方案、实现、review 和系统测试已完成，等待用户业务验收。 Legacy migration: original Version 4; normalized to Version 3. |
| 3 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 完成业务验收。 | 用户选择 `Accept with residual risk`；交付结果已接受，已披露并接受链接与锚点仍依赖代理验证的残余风险。 Legacy migration: original Version 5; normalized to Version 3. |
| 3 | 2026-07-19T13:07:24+0800 | Raymond Liao <raymond-liao@outlook.com> | Normalized legacy status and delivery events to reuse the active definition Version. | Old current 5 -> new current 3; original row versions 1,2,3,4,5 -> normalized row versions 1,2,3,3,3. |
