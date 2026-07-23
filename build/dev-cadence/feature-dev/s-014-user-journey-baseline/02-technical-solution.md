# S-014 技术方案

## 来源与确认

- Confirmed Requirement: [需求确认](01-requirements.md)
- Work Item: [S-014 Discovery User Journey 与 Feature 基线](../../../../docs/delivery/stories/S-014-user-journey-analysis.md)
- Business Design: [Discovery 流程设计](../../../../docs/workflows/discovery.md)
- Status: ✅ `confirmed`
- Confirmation: delegated by the user's parallel implementation instruction on `2026-07-16`。

## Codebase Exploration Findings

### Perspective 1：Discovery 行为与资产契约

- `src/skills/discovery/SKILL.md` 当前把 PRD 与 Business Architecture 定义为仅有主产物，并使用一道最终确认门；S-014 需要替换阶段、持久化、版本和增量路由，而不是追加互相冲突的旁路规则。
- 现有内容分类、技术输入处置、Asset Workflow 无运行记录等边界可保留，并扩展到三资产模型。
- 关键风险是旧的 `only primary outputs`、`one consolidated confirmation` 和提前写入初次资产等语句残留。

### Perspective 2：入口、公开说明与安装边界

- `src/skills/using-dev-cadence/SKILL.md` 需要按“产品级 Journey/Feature 定义”路由到 Discovery，同时保留“实现 Feature 行为”到 Feature Dev 的意图边界。
- `README.md` 与 `README.zh-CN.md` 仍公开说明两资产、旧阶段和单门禁，必须同步。
- `scripts/build.sh` 已完整复制 version、README 和 skills，不改构建逻辑；通过构建同步 `dist/.dev-cadence/`。

### Perspective 3：测试与产品设计一致性

- `tests/discovery-contract.sh` 已锁定旧模型，适合作为 TDD RED 的主入口；`tests/routing-contract.sh` 补产品 Feature 与实施 Feature 的路由边界。
- `tests/package-contract.sh` 已验证 skills 和 version 的 source/dist 一致性，但未验证双语 README；本任务补充 README 分发契约。
- `docs/workflows/discovery.md` 已完整描述目标态并保持不变；`docs/product-requirements-derivation.md` 的未来多 Journey 讨论不在本次实现范围内。

## 主代理已读关键文件

- `docs/stories/S-014-user-journey-analysis.md`
- `docs/workflows/discovery.md`
- `docs/product-requirements-derivation.md`
- `src/skills/discovery/SKILL.md`
- `src/skills/using-dev-cadence/SKILL.md`
- `src/skills/open-question-registry/SKILL.md`
- `README.md`
- `README.zh-CN.md`
- `tests/discovery-contract.sh`
- `tests/routing-contract.sh`
- `tests/package-contract.sh`
- `scripts/build.sh`

## 方案比较

### ✅ Selected：Discovery 内聚的三资产契约

直接重构 `src/skills/discovery/SKILL.md` 的资产、阶段、确认、增量和完成输出，以已确认业务设计为单一目标态；入口和公开说明只保留必要摘要，测试锁定关键正向与负向契约。

优点：行为权威集中、改动与 S-014 责任边界一致、避免独立 Journey workflow 与 Discovery 竞争所有权。缺点：Discovery skill 会增加篇幅，需要通过章节边界和负向测试防止旧新规则并存。

### Alternative：新增共享 Journey capability

把 Journey/Feature 契约抽成共享 skill，由 Discovery 调用。边界更细，但当前只有 Discovery 拥有写权限，会增加路由、安装和同步表面，且违反本任务不新增独立能力层的最小范围。

### Alternative：只补最小规则文本

只添加路径、阶段和几个断言，保留现有资产与增量章节。改动最少，但旧的一道门、提前写入和双资产完成语义会继续存在，无法满足验收标准。

## 推荐实现

### 1. Discovery 权威规则

- 把主产物定义为 User Journey、PRD 和 Business Architecture，并明确 Journey 可在第一道门后独立成为权威资产，完整基线只有三项一致且最终确认后完成。
- 阶段改为：`Background And Problem Exploration -> User Journey Analysis -> User Journey Confirmation -> PRD And Business Architecture Derivation -> Product Design Confirmation`。
- 初次与增量模式在每道门前都只维护会话 proposal；第一道门后只写受影响 Journey，第二道门后才写受影响 PRD/Business Architecture 和已确认支撑维护。
- 增加 User Journey 契约：单一权威路径、稳定业务线、普通 Markdown Journey Map、角色行、顺序列、连续空表头继承、`J-nnn`、`F-nnn`、`Offline`/`System`、最小 Feature Definitions 字段、稳定 ID 和跨角色复用。
- 分配新 ID 前扫描现有产品设计身份并拒绝碰撞；业务身份不变时保留 ID，遇到冲突或无法判定时保留为 Open Question，不静默重编号。
- PRD 的重要 Product Requirement 引用 Journey 与 Feature；Business Architecture 在关键业务内容中引用同一身份，不复制 Journey Map 或 Feature Definitions。
- 增量模式先判断 Journey 影响；无影响时保留其字节、版本与确认状态，有影响时先走 Journey 门；只有 PRD/Business Architecture 的旧仓库先建立首份 Journey，再协调实际受影响资产。

### 2. 路由与公开说明

- 入口表、代表性例子与优先级明确产品级 User Journey/Feature 基线属于 Discovery；不使用孤立 `Feature` 关键词改变交付路由。
- 双语 README 同步三资产路径、五阶段、两道门、Feature 所有权和 Work Item Planning 只引用已确认 Feature 的边界。
- `src/AGENTS-snippet.md` 现有触发词已覆盖，不修改。

### 3. 测试、构建与版本

- 先修改 Discovery 与 routing 契约形成 RED，再修改 source 使其 GREEN。
- 增加旧双资产、旧阶段、单门和禁止 Discovery 定义 Feature 的负向断言，防止新旧规则并存。
- Package contract 增加双语 README 文件与 source/dist 同步检查。
- 运行 `bash scripts/build.sh` 同步分发包，根版本从 `0.17.1` 升到 `0.18.0`，因为新增权威资产和 workflow 门禁属于向后可见的功能变化。

## 受影响模块与边界

- 权威行为：`src/skills/discovery/SKILL.md`
- 跨 workflow 路由：`src/skills/using-dev-cadence/SKILL.md`
- 公开说明：`README.md`、`README.zh-CN.md`
- 契约测试：`tests/discovery-contract.sh`、`tests/routing-contract.sh`、`tests/package-contract.sh`
- 分发身份：`version`、构建生成的 `dist/.dev-cadence/**`
- 保持不变：`src/vendor/superpowers/**`、相邻 Delivery workflow、Open Question Registry、已有业务流程设计文档。

## 测试策略

- RED/GREEN：定向运行 Discovery、routing、package 契约。
- 构建同步：运行 `bash scripts/build.sh`，再用 `rg --no-ignore` 核对 source/dist 的三资产、阶段、ID 和门禁关键规则。
- 回归：运行 whitespace 检查和 `bash scripts/check-all.sh`。
- Review：检查旧语句残留、规则冲突、链接、绝对路径、vendor 修改和版本同步。

## 风险与约束

- 规则文档是可执行行为契约，测试应锁定行为，不锁定 `docs/**` 自然语言措辞。
- Journey/Feature 身份变化是语义判断；规则必须要求保守处理冲突，测试只能验证契约存在，不能模拟全部语义判断。
- `dist/` 被忽略，只通过构建生成，不强制加入提交。
- Business Acceptance 仍保留为独立用户决定，不由并行实施指令替代。
