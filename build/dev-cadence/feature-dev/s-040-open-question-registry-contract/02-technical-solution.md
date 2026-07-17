# S-040 技术方案

## 确认的需求来源

- [S-040 需求确认](01-requirements.md)
- [S-040 Open Question Registry 全量索引与引用契约](../../../../docs/stories/S-040-open-question-registry-index-and-reference-contract.md)

## Codebase Exploration Findings

### Registry 结构与引用契约

- `src/skills/open-question-registry/SKILL.md` 已经集中负责按需创建、候选文档发现、稳定 ID、单一正文来源和迁移顺序，但现有模板是八字段 `Current Open Questions`，并明确要求终态删除与 Registry Change Log。
- `src/skills/document-conventions/SKILL.md` 已集中负责可移植链接、稳定锚点和文档生命周期方向，但没有显式 ID 字段与 `ID + 标题` 的链接文本边界。
- `tests/open-question-registry-contract.sh` 和 `tests/document-conventions-contract.sh` 使用 Shell + `rg` 契约断言，当前正向锁定旧行为。

### Workflow 协作与生命周期

- `src/skills/using-dev-cadence/SKILL.md` 是所有业务 workflow 的必经入口，适合保存“任何 workflow 修改 Open Question 时必须同步 Registry”的共享协作规则。
- `src/skills/discovery/SKILL.md` 存在两处明确冲突：局部 Open Questions 只在“有用时”索引，以及问题解决后删除 Registry 条目并写 Change Log。
- Architecture Design 和 Work Item Planning 会更新长期 `docs/` 资产，但没有与 S-040 直接冲突的局部生命周期契约。Feature Dev、Bug Fix 和 Refactor 的阶段记录位于 `build/`，不能被长期 `docs/open-questions.md` 反向引用为权威来源。
- `scripts/build.sh` 会整体复制 `src/skills`，`tests/package-contract.sh` 已通过 source/dist 逐文件同步检查，不需修改构建脚本。

### 仓库协作规则

- 根 `AGENTS.md` 是本源码仓库的协作规则；`src/AGENTS-snippet.md` 会进入目标仓库安装包，不应承载本仓库特有的子代理偏好。
- 子代理可执行已确认、边界清晰的实施任务；主代理保留 workflow 路由、用户门禁、集成审查、最终验证和 Git 集成责任。如实施方法要求任务级进度提交，子代理可在主代理审查范围内创建该提交，但不独立执行合并、push、验收或分支清理。

## 方案比较

### 方案 A：只修改 Registry 和文档规范

仅更新 `open-question-registry`、`document-conventions` 和对应测试。改动最小，但 `using-dev-cadence` 和 Discovery 仍会要求旧的终态删除行为，无法满足全 workflow 原子同步，不可采用。

### 方案 B：在六个 workflow 中复制同步契约

在 Discovery、Architecture Design、Work Item Planning、Feature Dev、Bug Fix 和 Refactor 分别写入编号、状态、排序和迁移规则。局部可见性强，但会形成多套权威契约，后续容易漂移，也违反现有共享 skill 责任边界。

### ✅ Recommended：共享契约 + 入口协作 + 定点冲突清理

- `open-question-registry` 作为 Registry 结构、编号、状态、排序、正文所有权、迁移和终态保留的唯一权威。
- `document-conventions` 作为所有 Dev Cadence 文档链接文本的唯一权威。
- `using-dev-cadence` 只定义 workflow 与共享能力的协作：局部权威资产与 Registry 必须原子同步，未同步不得越过当前确认门禁。
- 只修改已存在直接冲突的 Discovery 规则；其他 workflow 通过必经入口获得同步契约，不复制完整规则。

这一方案在满足 S-040 全量索引的同时，保持单一规则来源，改动边界也最清晰。当前只是推荐，需要用户确认后才成为选定方案。

## 详细设计

### Open Question Registry

- 保留按需创建和候选 Registry 发现机制。
- 创建模板只包含 `# Open Question Registry`、`## Questions` 四字段总表和 `## Question Details`。首个真实问题与文件同次创建，不写空占位行。
- 新问题分配全局 `Q-nnn`，通过扫描 Registry 与候选权威资产确定已用最大编号，只增不减，不复用终态编号。
- 总表 ID 使用 `[Q-001](#q-001)`，`Question Details` 使用 `### Q-001`。`Open` 行按 ID 升序在前，一切非 `Open` 行按 ID 升序在后；详情始终按 ID 升序。
- 有长期权威资产时，详情仅保留问题标题与 `Q-nnn + 标题` 快捷链接；无长期权威资产时，Registry 临时保存完整正文。
- 终态先把结论写入权威资产，再把 Registry 状态更新为 `Resolved`、`Rejected`、`Invalid` 或 `Superseded`；条目与编号永久保留，不建 Change Log。

### Workflow 原子同步

- 任何 workflow 在确认后的资产更新中新增、修改、迁移或改变 Open Question 状态时，必须在同一次操作中同步 Registry。
- 未决的 requirement、risk、assumption 或 review finding 不会仅因出现在 workflow 记录中而自动升级为 Open Question；只有被明确表达为需要追踪的 Open Question 才进入 Registry。
- 如当前 workflow 记录位于 `build/` 且没有生命周期足够长的权威资产，Registry 临时保存完整正文；该 workflow 记录使用同一 `Q-nnn` 与 Registry 快捷链接，Registry 不反向链接 `build/` 为长期权威来源。
- 原子更新中任一侧失败、编号冲突或权威正文不明时，停止并保持当前门禁未确认，不留下只有局部资产或只有 Registry 的单边状态。

### 文档引用

- 显式 ID 字段可使用 ID-only 链接文本。
- 显式 ID 字段之外，当被引用资产同时具有稳定 ID 和标题时，链接文本必须包含 `ID + 标题`。
- 被引用资产没有稳定 ID 时，链接文本必须使用能说明目标内容或责任的明确标题。
- Registry skill 只声明必须遵守 `document-conventions`，不复制通用三分契约。

### 本仓库子代理协作

- 在根 `AGENTS.md` 的“讨论与规则设计边界”与“构建与验证”之间增加独立“子代理协作边界”小节。
- 不修改 `src/AGENTS-snippet.md`，不把源码仓库的工作偏好安装到目标仓库。

## 影响文件与边界

### 预计修改

- `src/skills/open-question-registry/SKILL.md`
- `src/skills/document-conventions/SKILL.md`
- `src/skills/using-dev-cadence/SKILL.md`
- `src/skills/discovery/SKILL.md`
- `tests/open-question-registry-contract.sh`
- `tests/document-conventions-contract.sh`
- `tests/discovery-contract.sh`
- `tests/asset-delivery-record-contract.sh`
- `AGENTS.md`
- `version`

### 不直接修改

- `docs/open-questions.md` 及其当前 `OQ-001` 数据。
- `src/skills/architecture-design/SKILL.md`、`src/skills/work-item-planning/SKILL.md`、`src/skills/feature-dev/SKILL.md`、`src/skills/bug-fix/SKILL.md` 和 `src/skills/refactor/SKILL.md`；它们通过 `using-dev-cadence` 统一获得协作契约。
- `scripts/build.sh`、`scripts/install.sh`、`tests/package-contract.sh` 和 `src/vendor/superpowers/**`。
- `dist/.dev-cadence/**` 不直接编辑，只由 `bash scripts/build.sh` 生成。

## 测试策略

- 先修改契约测试，使它们因缺失 S-040 新契约、仍存在旧契约而失败。
- Registry 测试覆盖四字段表、`Q-nnn`、五状态、Open-first 排序、内部锚点、详情顺序、单一正文、终态保留、无 Registry Change Log 和原子同步。
- Document Conventions 测试覆盖 ID-only 例外、`ID + 标题` 和无 ID 资产的明确标题。
- Discovery 测试保留“已解决问题移出局部 Open Questions”，改为断言 Registry 终态保留且无 Change Log。
- Asset/Delivery 记录契约测试断言入口层对两类 workflow 的原子同步与 `build/` 生命周期边界。
- 实施后运行聚焦契约、`bash scripts/build.sh`、`bash scripts/check-whitespace.sh`、`bash scripts/check-all.sh`，并使用 `rg --no-ignore` 验证 source/dist 关键规则同步。

## 版本策略

本变更替换已安装的 Registry 生命周期行为，并改变所有 workflow 的 Open Question 协作契约。根 `version` 从 `0.19.0` 升至 `0.20.0`。

## 风险与约束

- 必须限定“无 Change Log”为 Registry 结构契约，不能禁止其他长期资产使用 Change Log。
- 编号分配必须扫描已有 `Q-nnn` 并拒绝碰撞，不能因本次不迁移当前 `OQ-001` 而忽略未来数据安全。
- 长期 `docs/` 不得将 `build/` 阶段记录作为权威链接目标。
- 契约测试应锁定可执行语义，不锁死整段自然语言。
- 根 `AGENTS.md` 是本仓库工作规则，无需为其措辞单独增加自动化测试。

## 方案状态

- 选定状态：❓ `Decision Pending`
- 推荐方案：共享契约 + 入口协作 + 定点冲突清理
- 待用户确认后，再进入 Implementation Plan。
