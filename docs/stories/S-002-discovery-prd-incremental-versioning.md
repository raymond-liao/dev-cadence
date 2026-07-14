# S-002 产品设计基线增量更新与版本治理

## 基本信息

- ID：`S-002`
- Version：`7`
- Status：`Blocked`
- Priority：`P1`
- Change Type：Enhancement

## 目标

让 `discovery` 能够在已有 PRD 和 Business Architecture 基线上持续接收新需求、反馈和范围变化，形成可追溯的新版本，同时保留既有产品设计历史。

## 背景

产品设计基线不是一次性文档。首次需求探索完成后，产品目标、范围、业务角色、流程、对象、规则和约束会继续变化。如果没有明确的增量更新和版本治理规则，代理可能直接覆盖既有设计、丢失历史，或者把未解决内容写进正式正文。

## User Story

作为持续维护软件需求的用户，我希望需求变化能够保留原有共识和变化原因，以便团队始终根据最新确认的需求开展后续工作。

## ✅ 范围

- 只有当用户表达更新已有产品设计的意图，并且仓库预检找到可信的产品设计候选文档时，才启动增量更新模式。
- 扫描仓库根目录和正常项目文档目录，根据内容识别已有 PRD、Business Architecture 或同时承担两种职责的综合产品文档，不只根据路径或文件名判断。
- 扫描时排除 `.dev-cadence/`、`dist/`、`build/`、`vendor/`、`node_modules/` 和 `.git/`。
- 读取已确认权威文档的实际路径、当前版本和 Change Log。
- 找到多个候选文档、职责不明确或内容冲突时，向用户说明判断依据并确认权威来源，不自动合并或覆盖。
- 未找到可信候选文档时，不启动 S-002，不自动切换成首次 Discovery；向用户说明未发现现有产品设计基线，并请用户提供路径或重新提出首次创建请求。
- 候选文档不在 Dev Cadence 约定位置时，向用户说明当前路径、建议路径、建议文件名和受影响引用，并询问是否迁移。
- 用户同意迁移时，迁移可以包含目录移动、文件名变更和仓库内引用更新，同时保留原有内容、版本和 Change Log，且不留下互相竞争的重复权威文档。
- 用户不同意迁移时，在原路径继续增量更新，并在 Discovery manifest 中记录实际权威文档路径。
- 一份综合文档同时包含 PRD 和 Business Architecture 内容时，不自动拆分；由用户选择保持单文件或拆分为两份文档。
- 支持 `discovery` 的增量更新模式。
- 对新需求、业务架构变化、修正、替代、拒绝、开放问题和未来范围变化进行分类。
- 识别变化应写入 PRD、Business Architecture 或两者。
- 增量输入遵守 S-006 定义的产品与技术内容边界：产品要求和业务架构内容写入对应产品设计文档，具体实现建议不得因为在需求讨论中出现就写入 PRD 或 Business Architecture。
- 区分产品级约束与候选实现机制；数据地域、法规、兼容性和可测量质量目标等产品约束可以进入 PRD，数据库、框架、协议、API 形状、算法、部署和测试实现等候选机制不得进入产品设计基线。
- 新增技术输入已有明确 Story、Technical Task、技术方案或 Decision 等权威文档时，写入或关联该文档；暂时没有合适承载位置时，通过 S-005 Open Question Registry 登记。
- 发现已有权威 PRD、Business Architecture 或综合产品文档混入技术方案、workflow 状态、审批记录、测试实现、部署运维步骤或其他非产品设计内容时，说明识别依据、建议承载位置和影响范围，不静默删除、改写或迁移。
- 已有混合内容只有在用户明确同意后才迁移或移除；迁移时保留必要历史和仓库引用，并将仍未确认且暂无权威承载位置的事项登记到 Registry。
- PRD 和 Business Architecture 独立管理版本；实质变化时只递增受影响文档的版本并更新对应 Change Log。
- 只有拼写、排版、路径迁移、文件名变更或链接更新时，对应文档不升版。
- 保留已有正文、Rejected Directions、Future Scope 和 Change Log 历史。
- 保持 Open Questions 的未解决状态。
- 已确认的问题不继续保留在 Open Questions；产品或业务结论写回对应正文，技术结论写入对应技术权威文档，相关全局 Registry 条目按 S-005 规则移除并通过其 Change Log 留痕。
- 识别产品设计变化对现有工作项和活动开发任务的潜在影响。
- Discovery manifest 记录本次产品设计基线实际使用的文档路径和版本组合。
- 获取用户对更新后完整产品设计基线的一次重新确认，不按文档分别确认。
- 将工作项调整交给后续 `work-item-planning`，不直接静默改写卡片。

## ❌ 非范围

- 不重新实现首次产品设计基线建立流程。
- 不创建或直接修改 Feature、Story、Bug、Technical Task 和 Roadmap。
- 不决定受影响工作项的最终拆分、状态或实施顺序。
- 不修改目标仓库应用代码。

## 验收标准

1. `discovery` 可以读取现有 PRD 和 Business Architecture 版本，并基于新输入形成一次协调的增量变更。
2. S-002 只有在用户具有更新已有产品设计的意图且仓库中存在可信候选文档时才启动；没有候选文档时不会创建增量更新 run。
3. 仓库扫描能发现非标准路径、非标准文件名和综合产品文档，同时排除安装包、构建产物、运行记录、依赖和第三方目录。
4. 多个候选、职责不明或内容冲突时，workflow 在修改前获得用户对权威来源的确认。
5. 非标准路径或文件名只有在用户明确同意后才迁移；用户拒绝迁移时继续使用原路径，不创建重复权威文档。
6. 综合产品文档只有在用户明确同意后才拆分。
7. PRD 和 Business Architecture 独立管理版本；产品目标、范围、成功标准、业务角色、业务域、流程、对象、状态、规则或约束发生实质变化时，只递增受影响文档的版本并记录变化原因。
8. 只有拼写、排版、路径、文件名或链接变化时，对应文档版本保持不变。
9. 既有正文、Rejected Directions、Future Scope 和 Change Log 历史不会被静默删除或改写；发现历史混合内容时，workflow 会说明识别依据、建议承载位置和影响范围，并在迁移或移除前获得用户明确同意。
10. Open Questions 不会在缺少用户确认时被写成已确定正文。
11. Discovery manifest 记录本次确认的实际文档路径和版本组合；更新后的完整组合得到用户确认前，不成为后续规划的正式基线。
12. 发现现有工作项可能受影响时，workflow 记录影响并移交 `work-item-planning`，不直接静默修改卡片。
13. 新增输入中的产品约束与候选实现机制能够被明确区分，具体数据库、框架、协议、API、算法、部署或测试实现不会写入产品设计基线。
14. 技术输入有明确权威文档时写入或关联该文档；没有合适承载位置时通过 S-005 Registry 保存，不会丢失或伪装成产品要求。
15. 已确认的问题从对应 Open Questions 中移除并写入正确的权威正文；Registry 同步移除相关条目并通过 Change Log 保留索引变化历史。

## Story Relationships

- Extends：`S-001` 首次 Discovery 与产品设计基线。
- Depends On：`S-001` 首次 Discovery 与产品设计基线（已完成）。
- Depends On：`S-005` 全局 Open Question Registry。
- Depends On：`S-006` Discovery 产品与技术内容边界。

## 依赖

- `S-001` 首次 Discovery 与产品设计基线（已完成）。
- `S-005` 全局 Open Question Registry。
- `S-006` Discovery 产品与技术内容边界。

## 后续工作

- Work Item Planning workflow 根据确认后的产品设计基线增量维护 Feature、Story、Bug、Technical Task 和 Roadmap。

## Open Questions

- 无。

## 相关文档

- [需求探索流程](../workflows/discovery.md)
- [S-001 首次 Discovery 与产品设计基线](S-001-initial-discovery-prd-baseline.md)
- [S-005 全局 Open Question Registry](S-005-open-question-registry.md)
- [S-006 Discovery 产品与技术内容边界](S-006-discovery-product-technical-content-boundary.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-13 | 创建 PRD 增量更新与版本治理 Story。 | 将增量需求治理从首次 Discovery 能力中拆出，形成可独立实施和验证的后续 Story。 |
| 2 | 2026-07-13 | 将状态改为 Blocked，并补充 User Story、Story Relationships 和 Open Questions。 | S-002 依赖尚未实现的 S-001，不能标记为可进入开发。 |
| 3 | 2026-07-13 | 重写 User Story，移除 Dev Cadence、PRD 和 workflow 实现表述。 | User Story 应表达用户目标和价值，而不是内部实现方式或交付物。 |
| 4 | 2026-07-13 | 将增量治理范围对齐到 PRD 与 Business Architecture 两文档基线。 | S-001 已确定两份文档共同构成产品设计基线，后续增量流程不能继续使用单一 PRD 模型。 |
| 5 | 2026-07-14 | 将状态更新为 Ready。 | S-001 已通过 Business Acceptance，前置依赖满足。 |
| 6 | 2026-07-14 | 补充增量模式触发、仓库文档发现、迁移选择和独立版本治理规则。 | S-002 必须适配目标仓库已有产品文档，不能只识别 Dev Cadence 默认路径，也不能在缺少现有基线时错误启动更新流程。 |
| 7 | 2026-07-14 | 增加产品与技术内容边界、历史混合内容处理及 Registry 移交规则，并将状态改为 Blocked。 | 增量更新必须避免技术方案进入产品设计基线，同时不能静默删除历史内容或丢失尚无承载位置的技术问题；S-005 和 S-006 尚未完成。 |
