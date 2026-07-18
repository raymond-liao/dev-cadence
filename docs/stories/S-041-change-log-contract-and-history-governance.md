# S-041 Change Log 共享契约与历史记录治理

## 基本信息

- ID：`S-041`
- Version：`1`
- Status：`Draft`
- Priority：`P1`
- Change Type：Enhancement

## 目标

将 Change Log 公共规则集中到 `src/skills/contracts/change-log.md`，让各 workflow 复用同一契约，并按明确的迁移边界治理现有记录，避免表头、版本、身份和时间规则继续漂移。

## 背景

当前 Change Log 规则重复出现在多个 workflow skill 和说明文档中，实际 Story、Task、Bug 记录又存在旧四列表头、重复版本、倒序历史和不完整身份时间等问题。规则没有单一共享契约时，后续新增或更新记录容易再次产生不一致。

## User Story

作为维护 Dev Cadence 规则和交付资产的用户，我希望 Change Log 公共规则由一份可复用契约统一定义，并能按明确边界治理已有记录，以便不同 workflow 产生的历史记录具有一致、可审计的格式和版本语义。

## ✅ 范围

- 新增 `src/skills/contracts/change-log.md` 作为 Change Log 公共契约。
- 统一定义表头、字段语义、时间和身份来源、版本递增条件、追加顺序、禁止元数据以及历史迁移规则。
- 让 `discovery`、`work-item-planning` 和 `work-item-analysis` 读取共享契约。
- 各 workflow 只保留自身资产的实质变化和版本升版条件，不复制完整公共规则。
- 保持 Open Question Registry 不包含 Change Log。
- 审查并治理现有 Story、Task、Bug 的 Change Log，包括重复版本、倒序记录、旧表头和纯状态升版问题。
- 同步 source、dist、安装包和契约验证。

## ❌ 非范围

- 不新增独立 `change-log` Skill。
- 不把所有资产的 Change Log 合并到一个文件。
- 不修改产品设计、业务事实或既有工作项的非 Change Log 内容。
- 不创建全局 release `CHANGELOG.md`。
- 不在缺少历史作者或精确时间时伪造记录。
- 不把历史 Change Log 迁移策略扩展为全仓库其他文档的无关重写。

## 验收标准

1. `src/skills/contracts/change-log.md` 成为 Change Log 公共规则的唯一源文件，覆盖字段、身份、时间、版本、追加、禁止项和历史迁移要求。
2. `discovery`、`work-item-planning` 和 `work-item-analysis` 明确读取共享契约，并只保留各自资产范围内的升版语义。
3. 共享契约不被 `document-conventions`、入口 Skill 或各 workflow 重复复制成另一套完整规则。
4. Registry 规则、模板和实际 `docs/open-questions.md` 保持无 Change Log。
5. 现有 Story、Task、Bug Change Log 的重复版本、倒序记录、旧表头和纯执行状态升版得到治理，或被明确记录为待迁移的 legacy 历史。
6. 缺少历史作者或精确时间的记录不会被静默推断；迁移结果明确区分原始事实和迁移信息。
7. source、dist、安装包和契约验证保持同步，并覆盖共享契约读取和关键 Change Log 不变量。

## Story Relationships

- Related：[S-010 文档引用快捷链接](S-010-document-reference-links.md)
- Related：[S-040 Open Question Registry 全量索引与引用契约](S-040-open-question-registry-index-and-reference-contract.md)

## 依赖

- 无。

## Open Questions

- 旧记录缺少准确时间和作者时，是保留为明确标记的 legacy 记录，还是由用户确认历史元数据后迁移为标准五列表格？

## 相关文档

- ⏳ `src/skills/contracts/change-log.md`（实施后创建）
- [S-010 文档引用快捷链接](S-010-document-reference-links.md)
- [S-040 Open Question Registry 全量索引与引用契约](S-040-open-question-registry-index-and-reference-contract.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-18T09:15:19+08:00 | Raymond Liao <raymond-liao@outlook.com> | 创建 Change Log 共享契约与历史记录治理 Story。 | 用户确认将公共规则集中到 `src/skills/contracts/change-log.md`，并治理现有 Change Log 的格式、版本和元数据一致性。 |
