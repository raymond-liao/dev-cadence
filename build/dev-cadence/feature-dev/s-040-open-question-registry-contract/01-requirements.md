# S-040 需求确认

## 需求来源

- 权威工作项：[S-040 Open Question Registry 全量索引与引用契约](../../../../docs/stories/S-040-open-question-registry-index-and-reference-contract.md)
- 工作项身份：`S-040` Version `1`，Status `Ready`，Priority `P1`
- 实施授权：用户于 `2026-07-17` 明确要求实施 Backlog 中的第一张卡。
- 附加授权：用户同时明确允许将“实施 Backlog 卡片时优先使用子代理节省主会话上下文”的协作规则更新到本仓库根 `AGENTS.md`。

## 已确认范围

- 将 `docs/open-questions.md` 的规则定义为覆盖仓库全部 Open Questions 的统一 Registry。
- 使用全局稳定的 `Q-nnn` 编号，同一编号必须同时存在于 Registry 与问题权威资产中。
- Registry 顶部只使用一张 `ID | Status | Question | Authoritative Source` 总表；`Open` 按 ID 升序在前，其他状态按 ID 升序在后。
- 状态最小集合为 `Open`、`Resolved`、`Rejected`、`Invalid` 和 `Superseded`。
- 总表 ID 使用 ID-only 内部链接，跳转到由稳定 ID 决定的 `### Q-nnn` 详情锚点。
- `Question Details` 按 ID 升序。已有权威资产时，Registry 只保留标题与有意义的快捷链接；没有权威资产时，Registry 临时保存完整正文。
- 终态问题保留在 Registry 中，不删除；Registry 不再使用 Change Log 保存生命周期历史。
- 任何 workflow 新增问题、改变状态或迁移正文时，权威资产和 Registry 必须在同一次操作中同步。
- 通用快捷链接文本规则归 `document-conventions` 所有：只有显式 ID 字段允许 ID-only；其他带 ID 与标题的资产必须显示 `ID + 标题`，无 ID 资产使用明确标题。
- 更新入口协作和契约测试，并同步可安装分发包。
- 在根 `AGENTS.md` 增加最小协作规则：实施 Backlog 工作项且平台支持子代理时，优先委派边界清晰的实施任务；主代理保留 workflow 路由、用户确认、集成审查、验证、Git 变更和最终汇报职责，不因此自动创建用户可见的新任务。

## ❌ 非范围

- 不在本 Story 中迁移当前 `docs/open-questions.md` 数据。
- 不在本 Story 中为所有存量局部 Open Questions 初始化 `Q-nnn`。
- 不批量清理无关历史链接文本。
- 不解答尚未收敛的 Decision 与 Open Question 资产边界问题。
- 不新增业务 workflow，不将 Registry 升级为六阶段交付流程。
- 不把问题完整正文同时复制到 Registry 和权威资产。
- 不把子代理协作规则扩张为要求委派需求确认、用户决策、Git 变更或最终验收。

## 验收标准

1. S-040 的 11 项验收标准全部由实施与可执行契约检查覆盖。
2. Open Question Registry 规则不再要求终态删除和 Change Log，且不会与旧 S-005 契约并存。
3. 全量索引、稳定编号、排序、内部锚点、单一正文、终态保留和 workflow 原子同步都有契约测试证据。
4. `document-conventions` 实施快捷链接文本规则，且 Open Question Registry 引用该共享规则而不复制一套通用契约。
5. `src/` 和构建生成的 `dist/.dev-cadence/` 包含同步规则，根 `version` 根据用户可见 workflow 行为变化更新。
6. 根 `AGENTS.md` 的子代理协作规则仅影响本源码仓库的后续协作，不进入可安装包，不要求为该文档措辞新增自动化测试。
7. `bash scripts/check-whitespace.sh` 和 `bash scripts/check-all.sh` 通过，规则关键文本经 `rg --no-ignore` 证明 source 与 dist 同步。

## 开放问题与假设

- Open Questions：无。
- 假设：子代理协作规则放在根 `AGENTS.md` 的“讨论与规则设计边界”附近，但作为独立“任务委派与主代理职责”小节，避免与产品 workflow 规则混同。

## 确认结论

- 需求状态：✅ `confirmed`
- 确认依据：用户先前已逐项确认 S-040 的 Registry 与引用契约，并于 `2026-07-17` 明确要求“现在实施第一个卡”，同时明确授权根 `AGENTS.md` 协作规则更新。
