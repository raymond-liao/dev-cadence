# S-041 Change Log 共享契约与历史记录治理

## 基本信息

- ID：`S-041`
- Version：`2`
- Status：`Draft`
- Priority：`P1`
- Change Type：Enhancement

## 目标

将 Change Log 公共规则集中到 `src/skills/contracts/change-log.md`，让各 workflow 复用同一契约，并按明确的迁移边界治理现有记录，避免表头、版本、身份和时间规则继续漂移。

## 背景

当前 Change Log 规则重复出现在多个 workflow skill 和说明文档中，实际 Story、Task、Bug 记录又存在旧四列表头、重复版本、倒序历史和不完整身份时间等问题。现有规则还没有明确区分“需要升版的定义变化”和“需要留痕但不升版的重要事件”，导致重复 Version 既可能是合法的状态或交付记录，也可能是错误的版本治理。规则没有单一共享契约时，后续新增或更新记录容易再次产生不一致。

## User Story

作为维护 Dev Cadence 规则和交付资产的用户，我希望 Change Log 公共规则由一份可复用契约统一定义，并能按明确边界治理已有记录，以便不同 workflow 产生的历史记录具有一致、可审计的格式和版本语义。

## ✅ 范围

- 新增 `src/skills/contracts/change-log.md` 作为 Change Log 公共契约。
- 将 Change Log 定义为重要变更历史，覆盖需要升版的定义变化，以及状态转换、交付结果等需要审计但不升版的重要事件。
- 统一定义表头、字段语义、时间和身份来源、版本递增条件、非升版事件、重复 Version、追加顺序、禁止元数据以及历史迁移规则。
- 定义变化必须先递增资产 Version，再使用新 Version 追加记录；非升版重要事件必须沿用事件发生时的当前 Version，因此同一 Version 可以出现多条具有不同事件语义的记录。
- 让 `discovery`、`work-item-planning` 和 `work-item-analysis` 读取共享契约。
- 各 workflow 只保留自身资产的实质变化和版本升版条件，不复制完整公共规则。
- 保持 Open Question Registry 不包含 Change Log。
- 审查并治理现有 Story、Task、Bug 的 Change Log，包括重复 Version 的语义、倒序记录、旧表头和纯状态升版问题。
- 历史迁移必须保留原有重要事件；不得仅为使 Version 唯一而删除状态或交付记录。
- 历史记录缺少准确时间、时间精度或作者时，必须在对应字段使用共享契约规定的明确 legacy 未知标识，并保留能够确认的原始信息，不得静默推断或伪造。
- 同步 source、dist、安装包和契约验证。

## ❌ 非范围

- 不新增独立 `change-log` Skill。
- 不把所有资产的 Change Log 合并到一个文件。
- 不修改产品设计、业务事实或既有工作项的非 Change Log 内容。
- 不创建全局 release `CHANGELOG.md`。
- 不在缺少历史作者或精确时间时伪造记录。
- 不要求 Change Log 的 Version 值全局唯一，也不把合法的非升版事件改写成新的资产版本。
- 不把纯拼写、格式或不改变责任关系的链接修正当作必须记录的重要事件。
- 不把历史 Change Log 迁移策略扩展为全仓库其他文档的无关重写。

## 验收标准

1. `src/skills/contracts/change-log.md` 成为 Change Log 公共规则的唯一源文件，覆盖字段、身份、时间、版本、非升版事件、重复 Version、追加、禁止项和历史迁移要求。
2. `discovery`、`work-item-planning` 和 `work-item-analysis` 明确读取共享契约，并只保留各自资产范围内的升版语义。
3. 共享契约不被 `document-conventions`、入口 Skill 或各 workflow 重复复制成另一套完整规则。
4. 定义变化使用递增后的新 Version 记录；状态转换、交付结果等非升版重要事件使用事件发生时的当前 Version 记录，重复 Version 不会被机械判定为错误。
5. 纯拼写、格式或不改变责任关系的链接修正不要求写入 Change Log；是否记录其他非升版事件必须由共享契约给出可执行边界。
6. Registry 规则、模板和实际 `docs/open-questions.md` 保持无 Change Log。
7. 现有 Story、Task、Bug Change Log 的重复 Version 语义、倒序记录、旧表头和纯执行状态升版得到治理；历史重要事件不因格式迁移或 Version 重复而被删除。
8. 缺少历史作者、准确时间或时间精度的记录不会被静默推断；标准五列表格使用统一 legacy 未知标识，并明确区分可确认的原始事实和迁移信息。
9. source、dist、安装包和契约验证保持同步，并覆盖共享契约读取、升版与非升版事件、legacy 迁移和其他关键 Change Log 不变量。

## 已确认需求决策

- [Q-023 历史 Change Log 缺失元数据迁移](../open-questions.md#q-023) 已解决：采用“完整的重要变更历史”模型，不将 Change Log 限制为唯一 Version 列表。
- 需要审计但不改变资产定义的状态转换和交付结果必须追加记录并沿用当前 Version；同一 Version 的多条不同事件记录是合法历史。
- 历史迁移必须保留重要事件。缺失作者、准确时间或时间精度时使用共享契约定义的明确 legacy 未知标识，不要求用户补造历史元数据，也不得从弱证据静默推断。

## Story Relationships

- Related：[S-010 文档引用快捷链接](S-010-document-reference-links.md)
- Related：[S-040 Open Question Registry 全量索引与引用契约](S-040-open-question-registry-index-and-reference-contract.md)

## 依赖

- 无。

## Open Questions

- 无。

## 相关文档

- ⏳ `src/skills/contracts/change-log.md`（实施后创建）
- [S-010 文档引用快捷链接](S-010-document-reference-links.md)
- [S-040 Open Question Registry 全量索引与引用契约](S-040-open-question-registry-index-and-reference-contract.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-18T09:15:19+08:00 | Raymond Liao <raymond-liao@outlook.com> | 创建 Change Log 共享契约与历史记录治理 Story。 | 用户确认将公共规则集中到 `src/skills/contracts/change-log.md`，并治理现有 Change Log 的格式、版本和元数据一致性。 |
| 2 | 2026-07-18T15:00:09+08:00 | Raymond Liao <raymond-liao@outlook.com> | 确认 Change Log 保存完整的重要变更历史，补充非升版事件、重复 Version 和 legacy 元数据迁移规则，并解决 Q-023。 | 用户选择方案 2，要求状态和交付等重要事件保留历史、沿用当前 Version，且不得通过删除历史或伪造元数据完成迁移。 |
