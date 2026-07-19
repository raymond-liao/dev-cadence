# S-041 技术方案

## 状态

- 当前状态：✅ `confirmed`
- 需求来源：[S-041 需求确认](01-requirements.md)（`build/dev-cadence/feature-dev/s-041-change-log-contract-and-history-governance/01-requirements.md`）
- 确认依据：用户授权在不中途请求确认的情况下完成 Technical Solution、Implementation Plan、Development Implementation 和 System Testing，并在最终统一总结重大决策。

## 当前结论

采用“不可路由的 supporting contract + workflow 所有者规则 + 一次性显式迁移 + 契约测试”的务实方案。公共 Change Log 语义集中到 `src/skills/contracts/change-log.md`；Discovery、Work Item Planning 和 Work Item Analysis 读取它，只保留各自资产的升版条件。Work Item Planning 继续独占 Backlog 排序决策，并使用 `Ordering Version` 与可见 `待处理` 顺序组成双重新鲜度身份。

本方案不新增 Skill、不引入运行时 Markdown 改写器，也不把 Change Log 规则放入 `document-conventions` 或 `using-dev-cadence`。现有入口和 Delivery Workflow 中与“状态、交付事件需要留痕但不升版”冲突的句子只做定点对齐，不复制完整公共契约。

## Codebase Exploration Findings

### 共享契约与消费者边界

- `src/skills/discovery/SKILL.md` 当前同时包含产品资产升版语义和公共表头、时间、身份规则；产品资产升版语义保留，公共部分迁出。
- `src/skills/work-item-planning/SKILL.md` 当前拥有卡片版本、Backlog 排序和派生并行表，但缺少 Ordering Version 的触发矩阵、提案快照和原子同步单元。
- `src/skills/work-item-analysis/SKILL.md` 当前重复卡片 Change Log 表头；应改为读取共享契约并只保留定义变化的升版条件。
- `src/skills/document-conventions/SKILL.md` 只拥有 Markdown 展示规则，不能承载 Change Log 业务语义，否则会错误覆盖 Delivery records 和明确无 Change Log 的 Registry。
- `src/skills/using-dev-cadence/SKILL.md` 及三个 Delivery Workflow 存在“执行状态变化保持 Change Log 不变”的冲突表述；需要定点改为“Version 不变，按共享契约追加重要事件”，并保持幂等。

### 历史资产审计

- 审计范围为 `docs/stories/*.md`、`docs/tasks/*.md` 和 `docs/bugs/*.md`，共 57 张卡、152 条历史记录。
- 49 张卡、136 条记录仍使用旧四列表头；137 条缺少作者，138 条缺少准确时间或时间精度。
- 11 张卡存在重复 Version。重复组均可由定义变化与状态/交付事件解释，必须保留，不能机械去重。
- 6 张卡存在非升序历史块：B-005、B-007、B-008、S-013、S-014 和 T-004。
- 34 条记录属于明确或强候选的状态、验收、实施或交付事件，却占用了新 Version。迁移必须使用显式 per-card 映射，不使用文本关键词自动改号。
- `docs/open-questions.md` 当前无 Change Log，并由 Registry skill 与测试明确禁止；迁移必须排除它。

### Ordering Version、构建与测试

- `docs/backlog.md` 已保存 `Ordering Version` 1-3 和三条排序历史，现有历史全部保留。
- 仅比较 `Ordering Version` 会漏掉不升排序版本的生命周期变化；仅比较行顺序会漏掉排序例外变化，因此提案写入前必须同时比较版本与 `待处理` ID 顺序。
- 排序确认的最小原子单元是 `待处理`、派生并行表、`Ordering Version` 和 `Ordering Change Log`；不得部分确认或部分写入。
- `scripts/build.sh` 会复制整个 `src/skills`，新 contract 会自然进入 dist；package/install 测试仍应显式验证它存在且与 source 一致。
- 当前根版本是 `0.25.1`。本次改变可安装 workflow 行为并增加公共契约，使用次版本 `0.26.0`。

## 方案比较

### 方案 A：继续在三个 Workflow 内分别维护

改动最小，但继续存在竞争规则源，无法阻止字段、身份、legacy 和重复 Version 语义再次漂移，也直接违反 S-041 的单一来源要求。

### 方案 B：新增 Change Log Skill 或运行时迁移器

隔离程度高，但 Change Log 没有独立用户目标和路由入口；新增 Skill 会制造路由与所有权成本。运行时迁移器还会与 Asset Workflow 的业务判断竞争写权限，并需要额外补偿语义，超出本卡范围。

### ✅ Selected 方案 C：Supporting Contract 与所有者特定规则

新增普通 supporting reference，由三个 Asset Workflow 直接读取；公共契约负责稳定不变量，workflow 负责资产特定触发条件。历史迁移通过本次交付中的显式映射完成，后续只保留只读契约验证，不提供通用自动改写接口。

该方案满足单一所有者、最小路由面和可验证性，且与现有 `document-conventions`、Registry shared capability 的组织方式一致。

## 组件与职责

### 1. 共享 Change Log 契约

`src/skills/contracts/change-log.md` 无 frontmatter，不是 Skill，也不参与 `using-dev-cadence` 路由。它定义：

- 标准维度表头 `Version | Recorded At | Recorded By | Change | Reason`；
- 资产所有者可定义命名版本维度，字段表头为 `<Named Version> | Recorded At | Recorded By | Change | Reason`；
- 定义变化先把版本递增 1，再用新版本追加记录；
- 状态转换、交付结果、重要迁移等非定义事件沿用事件发生时的当前版本；
- 同一 Version 多条不同事件合法，重复本身不是错误；
- 纯拼写、格式和不改变责任关系的链接修正不要求记录；
- 按事件发生顺序追加，历史迁移可恢复明确顺序时改为升序，证据不足时稳定保留原相对顺序；
- 禁止提交哈希、审批人、审批时间、workflow stage 和运行状态等过程元数据。

实时新增记录的 `Recorded At` 必须是带时区偏移的 ISO 8601 时间。`Recorded By` 优先读取仓库级 Git identity，再使用全局配置；有姓名和邮箱时使用 `Name <email>`，只有姓名或邮箱时保留可确认的单项，二者都缺失时写入前询问用户。

历史迁移使用以下固定 sentinel：

- 已知原日期但时间或时区未知：`legacy: recorded-at precision unknown; original YYYY-MM-DD`
- 日期完全未知：`legacy: recorded-at unknown`
- 作者未知：`legacy: recorded-by unknown`

sentinel 只用于历史迁移，不能替代新事件的实时身份和时间采集。

### 2. Workflow 消费边界

- Discovery 保留 User Journey、PRD、Business Architecture 及组合文档责任版本的升版条件。
- Work Item Planning 保留 Story/Task/Bug 卡片规划事实的升版条件，以及 Ordering Version 的全部递增、并发和原子写入语义。
- Work Item Analysis 保留工作项定义变化的升版条件。
- `using-dev-cadence` 和 Delivery Workflow 仅对齐卡片生命周期写回：Version 不变，但状态和交付结果属于重要事件时追加当前 Version 记录；重复执行不得重复追加同一事件。
- Open Question Registry 继续明确无 Change Log。

### 3. Ordering Version 双重新鲜度门禁

形成排序提案时记录：

1. 当前 `Ordering Version`；
2. `待处理` 中按可见顺序排列的工作项 ID；
3. 建议变化、受影响项、确认后相对位置和原因。

写入前重新读取同一两项身份。任一不一致都停止覆盖并重新形成提案。两项一致且用户确认后，先构造完整后状态，再一次性写入并复读验证以下四部分：

- `待处理` 顺序；
- 派生并行表；
- 递增后的 `Ordering Version`；
- 新增的 `Ordering Change Log` 记录。

重新排列已有项、将新项插入明确位置、增加/修改/取消排序例外会递增 Ordering Version。无实际排序变化、生命周期同步、完成项移出、标题/卡片 Version/Priority 机械同步、派生表刷新、格式和链接变化均不递增。

### 4. 历史迁移

迁移分为机械层和语义层：

- 机械层统一 57 张卡为五列，替换缺失元数据为固定 sentinel，保留所有原始 Change 和 Reason 文本。
- 语义层使用显式清单治理 6 个倒序块和 34 条版本候选；不得根据关键词自动判断。
- 明确的状态、验收和交付事件改为沿用事件发生前的当前定义版本；随后定义变化按连续整数重新编号。
- 当语义版本变化时，同步卡片顶层 Version 和 `docs/backlog.md` 的 Version 投影；这只修复版本治理元数据，不改变目标、范围、验收、关系或其他业务事实。
- 每条被改号的历史记录在 Reason 中保留原始 Version 的迁移说明；每张被归一化的卡追加一条当前版本迁移事件，记录旧/新顶层 Version 和迁移依据。
- 混合了定义变化与状态变化的同一条历史记录按定义变化处理：先升版，再记录同一行中的状态结果。
- 证据不足的同日同版本记录稳定保留原相对顺序，并通过 Recorded At sentinel 明确精度未知。

### 5. 验证与分发

新增 `tests/change-log-contract.sh`，覆盖共享契约和全量卡片迁移不变量，并接入 `tests/run-all.sh`。现有三个 consumer test 改为验证“读取共享契约 + 自有升版条件”，不再复制公共细节断言。

验证矩阵包括：

- 定义升版、状态复用、合法重复 Version、纯格式不记录；
- legacy 作者/时间 sentinel、旧表头清零、历史行序与事件保留；
- 57 张卡五列、Version 正整数、卡片/Backlog Version 投影一致；
- Registry skill、模板和实际 Registry 无 Change Log；
- Ordering 正常重排、无变化、非排序同步、旧版本冲突、可见顺序冲突和四部分原子同步；
- source/dist、package/install 和版本一致性。

`bash scripts/build.sh` 生成 dist，但 dist 保持忽略，不强制提交。

## 数据流

### 普通资产事件

1. Owning workflow 读取共享契约和资产当前 Version。
2. 判断事件是否改变资产定义。
3. 定义变化递增 Version；重要非定义事件保留当前 Version；不重要格式事件不记录。
4. 获取实时身份和时间，追加五列表格记录。
5. 写入前复核 Version 和可见事实，冲突时停止。

### 排序事件

1. Planning 读取 Ordering Version 和待处理顺序。
2. 形成绑定这两项身份的提案。
3. 用户确认后复读双重身份。
4. 构造并写入四部分完整后状态。
5. 复读验证；失败时不得报告部分状态为新权威结果。

## 风险与约束

- 历史迁移范围大，最大风险是丢失事件或错误改号；通过显式映射、事件文本多重集和行数验证控制。
- 版本归一化会改变卡片与 Backlog 的版本元数据；必须在同一实现任务中原子同步，不更新已完成 Delivery run 的历史快照。
- 双重新鲜度门禁只能保护当前 checkout 的可见事实，跨 worktree 冲突仍由 Git merge conflict 作为第二道防线；本卡不引入全局锁服务。
- 新 contract 会改变安装包行为，根版本必须升级到 `0.26.0`。
- `dist/` 是生成且忽略的产物，只用于构建和验证。

## 高层测试策略

- 先添加会因 contract 不存在、消费者仍复制规则、Ordering 规则缺失和旧卡片格式而失败的契约测试。
- 分任务完成公共规则、Ordering 规则和历史迁移，每个任务运行聚焦测试。
- 构建 dist 后用 package/install 测试验证安装内容。
- 最终运行 `bash scripts/check-whitespace.sh`、`bash scripts/check-all.sh`、关键规则 `rg --no-ignore` 同步检查和全量 Markdown 本地链接检查。

## 确认结果

- Technical Solution：✅ `confirmed`
- 确认方式：用户于 `2026-07-19T12:02:17+08:00` 授权不中断完成后续工程阶段；本方案在该授权范围内选择务实方案 C。
- 下一阶段：Implementation Plan。
