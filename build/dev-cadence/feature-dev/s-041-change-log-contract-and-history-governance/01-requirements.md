# S-041 需求确认

## 状态

- 当前状态：🔄 `in_progress`
- 权威需求来源：[S-041 Change Log 共享契约与历史记录治理](../../../../docs/stories/S-041-change-log-contract-and-history-governance.md)

## 工作项身份

- 卡片路径：`docs/stories/S-041-change-log-contract-and-history-governance.md`
- 工作项类型：Story
- 当前 Version：`3`
- 当前可见 Status：`In Progress`
- 选定范围：卡片 Version 3 的完整范围、非范围、已确认需求决策和验收标准 1-14。

## 当前结论

S-041 的需求定义完整、无开放问题，可以进入技术方案阶段。项目当前没有 PRD、User Journey 或独立 Feature 资产；本次交付只实现 S-041，不创建或补充这些相邻资产，也不因此重新解释卡片中已经确认的业务结论。

## ✅ 包含范围

- 建立 `src/skills/contracts/change-log.md`，作为 Change Log 公共契约的唯一规则源。
- 让 Discovery、Work Item Planning 和 Work Item Analysis 读取共享契约，并只保留各自拥有的资产升版语义。
- 定义标准版本维度和资产所有者命名版本维度，统一时间、身份、变更与原因字段语义。
- 区分需要升版的定义变化和不升版但必须留痕的重要事件，允许同一 Version 记录多个不同事件。
- 定义 legacy 未知元数据标识和历史迁移规则，保留原有重要事件，不伪造作者或时间。
- 治理现有 Story、Task、Bug 的旧表头、倒序记录、重复 Version 语义和纯执行状态升版。
- 让 Work Item Planning 维护 Backlog 的 `Ordering Version`、排序提案新鲜度、排序历史和原子同步。
- 保留当前 Backlog 排序历史，不把生命周期或机械同步迁移为排序历史。
- 同步 source、dist、安装包行为和契约验证；按仓库规则评估并更新根目录 `version`。

## ❌ 排除范围

- 不创建 PRD、User Journey、Feature 资产或新的工作项。
- 不新增独立 `change-log` Skill，不修改 vendored Superpowers。
- 不创建全局 release `CHANGELOG.md`，不合并各资产的 Change Log。
- 不修改产品设计、业务事实或工作项的非 Change Log 内容。
- 不为 Backlog 建立覆盖全部内容的全局 Version。
- 不把生命周期、完成项移动、机械同步或派生视图刷新记录为排序决策。
- 不伪造缺失的历史作者、日期或时间精度，不删除合法的重要历史事件。
- 不扩张为全仓库其他文档的无关重写。
- 本阶段不包含技术方案、实施计划、代码修改、系统测试或业务验收。

## 验收标准

权威验收标准为 S-041 Version 3 的 1-14 条，汇总为以下可验证结果：

1. 共享契约唯一性、字段语义、版本与非升版事件、legacy 迁移和禁止项完整。
2. 三个 Asset Workflow 读取共享契约，且不复制另一套完整公共规则。
3. Open Question Registry 保持无 Change Log。
4. 现有 Story、Task、Bug 历史完成迁移治理且不丢失重要事件。
5. source、dist、安装包和契约测试保持同步。
6. `Ordering Version` 只表达用户确认的排序决策，并具有新鲜度冲突门禁。
7. 排序确认原子同步待处理顺序、派生并行表、排序版本和排序历史。
8. 当前 Backlog 排序历史得到保留，正常重排、无变化、非排序同步、旧版本冲突和派生视图同步都有验证覆盖。

## 风险、假设与开放问题

- 开放问题：无。
- 需求假设：卡片 Version 3 是当前权威定义，且已通过 Work Item Analysis 达到 `Ready`。
- 范围约束：项目没有 PRD 不构成本次交付阻塞，也不授权创建产品设计资产。
- 探索模式：该功能涉及共享契约、多个 workflow、历史资产迁移、构建与测试，技术方案阶段使用增强探索模式。
- 主要风险：历史记录迁移可能误删合法事件或伪造元数据；排序版本规则可能与现有生命周期同步混淆；共享契约抽取可能留下重复或竞争规则源。

## 生命周期写回

- 卡片：`Ready` -> `In Progress`，Version 保持 `3`，Change Log 不变。
- Backlog：S-041 从 `待处理` 移入 `进行中`，其余待处理项顺序不变。
- 派生并行视图：S-041 状态同步为 `In Progress`，并行组不变。
- 排序历史：按用户明确决定不重排，`Ordering Version` 和 `Ordering Change Log` 不变。
- 交付结果：待 Development Implementation、System Testing、Business Acceptance 和 Completion 完成后写回。

## 用户确认

- 需求确认：⏳ `pending`
- 确认效果：确认后进入 Technical Solution；请求修改则留在本阶段，更新本记录后重新确认。

