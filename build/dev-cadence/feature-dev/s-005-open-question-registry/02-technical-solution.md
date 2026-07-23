# S-005 全局 Open Question Registry - 技术方案

## 输入与边界

- 已确认需求：[需求确认](01-requirements.md)
- 工作项：[S-005 全局 Open Question Registry](../../../../docs/delivery/stories/S-005-open-question-registry.md)
- 工作项版本：`2`

## Codebase Exploration Findings

### 视角一：共享规则所有权

- 关键文件：`src/skills/document-conventions/SKILL.md`、`src/skills/using-dev-cadence/SKILL.md`、四个业务 workflow skill。
- 现有模式：共享语义规则由独立 skill 单一拥有，入口 skill 负责选择和路由。
- 约束：Registry 是持久业务资产，不应放入 `build/` 运行记录，也不应把完整规则复制到每个 workflow。
- 必读文件：`src/skills/using-dev-cadence/SKILL.md`、`src/skills/document-conventions/SKILL.md`、`src/skills/discovery/SKILL.md`、`src/skills/feature-dev/SKILL.md`、`src/skills/bug-fix/SKILL.md`、`src/skills/refactor/SKILL.md`、`src/AGENTS-snippet.md`、`AGENTS.md`。

### 视角二：索引与正文生命周期

- 关键文件：Story S-005、S-002、S-006、S-010，以及 `docs/workflows/discovery.md`。
- 现有模式：PRD、Business Architecture 和工作项保留各自的 Open Questions；长期资产使用 Version/Change Log 追溯。
- 约束：Registry 只索引已有权威来源，仅对无承载位置问题暂存完整正文；终态问题从当前索引移除。
- 必读文件：`docs/stories/S-005-open-question-registry.md`、`docs/stories/S-002-discovery-prd-incremental-versioning.md`、`docs/stories/S-006-discovery-product-technical-content-boundary.md`、`docs/stories/S-010-document-reference-links.md`、`docs/workflows/discovery.md`、`src/skills/document-conventions/SKILL.md`。

### 视角三：构建、安装与契约验证

- 关键文件：`scripts/build.sh`、`tests/package-contract.sh`、`tests/install-contract.sh`、`tests/routing-contract.sh`、`tests/skill-description-contract.sh`、`tests/run-all.sh`。
- 现有模式：构建整体复制 `src/skills`；Shell 契约测试验证规则语义、路由、包内容和安装结果。
- 约束：测试应保护行为语义，不锁定大段自然语言；`dist/` 只由构建生成。
- 必读文件：上述六个测试/脚本，`version`、`src/.dev-cadence.example.yaml`、`tests/document-conventions-contract.sh`、`tests/workflow-symmetry.sh`。

## 方案比较

### 方案 A：把 Registry 规则并入 document-conventions

- 优点：少一个 skill。
- 缺点：文档呈现规范与业务资产生命周期职责混合，不符合 Story 的“独立共享能力”。

### 方案 B：每个 workflow 各自维护 Registry 规则

- 优点：各 workflow 上下文完整。
- 缺点：生命周期规则重复，容易漂移，且违反 Story 明确的共享能力要求。

### 方案 C：独立共享 skill，入口集中路由

- 优点：单一规则所有者，按需被用户和业务 workflow 复用；构建和安装自然包含。
- 缺点：入口需区分“业务 workflow”与“共享资产能力”。

## ✅ Selected：方案 C

用户授权代理自主做出任务内决策。方案 C 最符合现有共享 skill 模式，同时避免向相邻 workflow 扩散完整规则。

## 设计细节

- 新增 `src/skills/open-question-registry/SKILL.md`，定义适用性、候选文档发现、按需创建模板、字段契约、单一正文来源、迁移、终态移除、Change Log 和冲突处理。
- `using-dev-cadence` 在业务 workflow 表之外新增共享能力路由；直接查看/维护请求读取该 skill，workflow 遇到当前产物无法承载的问题时也复用它。
- 新增 `tests/open-question-registry-contract.sh`，验证按需创建、字段、正文所有权、迁移、移除、Change Log、候选冲突保护和路由。
- 更新 package/install/description 契约和 `tests/run-all.sh`；构建后验证 `src/` 与 `dist/` 同步。
- 将根 `version` 升至 `0.13.0`，因为新增可安装的用户可见能力。

## 测试策略

- RED：先运行新 Registry contract，预期因 skill 缺失而失败。
- GREEN：实现最小规则和路由，使 focused contract 通过。
- 回归：`bash scripts/check-whitespace.sh`、`bash scripts/check-all.sh`。
- 分发：`bash scripts/build.sh` 后用 `rg --no-ignore` 确认 `src/` 与 `dist/.dev-cadence/` 关键规则同步。

## 风险与约束

- 候选全局问题文档的命名可能不统一；规则必须先搜索并在歧义时阻塞写入，不能自动建立竞争索引。
- Registry 是规则驱动的 Markdown 资产，本 Story 不新增专用解析器或 CLI。
- 业务 workflow 的深度接入属于 S-006、S-002、S-017 等后续任务；当前只提供可复用共享能力和入口。

## 技术方案结论

- Status: ✅ `confirmed`
- Confirmation: 用户于 2026-07-14 授权连续执行，方案在已确认 Story 边界内自主选定。
