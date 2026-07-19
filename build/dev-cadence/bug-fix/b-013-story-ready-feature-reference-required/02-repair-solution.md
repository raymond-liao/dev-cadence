# B-013 修复方案

- 状态：🔄 `in_progress`（方案待用户确认）
- 记录时间：`2026-07-19T21:36:44+0800`
- 前置诊断：[B-013 问题诊断记录](01-problem-diagnosis-record.md)
- 工作项：[B-013 Story Ready 错误依赖 Feature 关联](../../../../docs/bugs/B-013-story-ready-feature-reference-required.md)

## 根因

`work-item-analysis` 把已有 Feature 的追踪关系写成所有 Story 的通用 `Ready` 前置条件，并把单纯缺少 Feature identity 当作必须返回 Discovery 的情况。这与独立 Story 可以不依赖产品级结论的既有期望相冲突。

## ❓ Decision Pending：建议修复方式

1. 将 Story 的最小分析字段和 `Ready` 门禁改为角色、目标、价值、范围、可观察行为、业务规则、验收条件、依赖、阻塞性 Open Questions 与用户确认；主 System Feature 改为“当已有适用 Feature 或 Story Map 追踪关系时必须保留”的条件性字段。
2. 将 Discovery 路由改为仅在 Story 需要新建或改变 User Journey、Feature、PRD 或 Business Architecture 等产品级结论时触发；明确不得仅因缺少 Feature 或产品设计基线而返回 Discovery。
3. 在入口选择器中添加同一边界，确保对 `work-item-analysis` 的路由说明不会把缺少 Feature 本身解释为 Discovery 触发条件。
4. 扩展工作项分析和路由契约测试，覆盖四类场景：无 Feature 的完整独立 Story、已有 Feature 引用的 Story、真实产品级结论缺口、S-042 历史回归。
5. 将根目录 `version` 从 `0.26.4` 递增为 `0.26.5`，随后运行构建和安装脚本同步 `dist/.dev-cadence/` 与当前 worktree 的 `.dev-cadence/`。

## 修复边界

### 包含

- `src/skills/work-item-analysis/SKILL.md`：Story 字段、`Ready` 门禁和 Discovery 返回条件。
- `src/skills/using-dev-cadence/SKILL.md`：Work Item Analysis 的入口语义边界。
- `tests/work-item-analysis-contract.sh`、`tests/routing-contract.sh`：上述四类场景的契约断言。
- `version`、生成分发包和当前安装包的同步验证。

### 不包含

- 创建、修改或重新解释 Feature、User Journey、PRD、Business Architecture 或 Story Map。
- 修改 S-042 的定义、版本或 `Ready` 状态。
- 改变 Task、Bug、`feature-dev`、`bug-fix` 或 `refactor` 的入口资格。
- 与 Story `Ready` 无关的 Work Item Analysis 规则重写。

## 影响与回归范围

- 已有关联 Feature 的 Story 必须继续保留已确认的追踪关系。
- 真正依赖新建或变化产品级结论的 Story 必须继续返回 Discovery。
- Story 的其他 `Ready` 条件和用户确认门必须保持不变。
- Task、Bug 与 Delivery Workflow 路由必须保持不变。
- source、`dist/.dev-cadence/` 和当前 `.dev-cadence/` 必须在构建和安装后含相同的新规则及 `0.26.5` 版本。

## 验收条件映射

| B-013 验收条件 | 修复方式 | 验证 |
| --- | --- | --- |
| 1、5、6 | 移除 Feature 强制门禁，保留完整 Story 定义与确认条件 | 工作项分析契约测试 |
| 2 | 把 Feature 改为已有来源时的保留性追踪关系 | 工作项分析契约测试 |
| 3、4 | 收窄 Discovery 路由为实际产品级结论缺口 | 工作项分析与路由契约测试 |
| 7 | 不改 Task、Bug、Delivery 路由文字与契约 | 全量检查 |
| 8 | 增加四种场景的回归断言 | 聚焦契约测试与全量检查 |
| 9 | 递增版本，构建并安装后比较 source、dist、安装包 | 构建、安装、包契约检查 |

## 风险与取舍

- 风险：把“可选”写得过宽会让来自已有 Feature 或 Story Map 的 Story 丢失可追踪性。缓解方式是明确“已有适用关系必须保留”，并以契约测试锁定。
- 风险：只改 `work-item-analysis` 而不改入口说明会保留路由歧义。缓解方式是加入入口级边界和路由测试。
- 取舍：不为独立 Story 创造虚假的 Feature；真正的产品级含义缺口仍交给 Discovery，维持资产所有权边界。

## 修复验收结论

该方案以最小规则与测试变更恢复 B-013 的预期行为，同时不改变产品级资产所有权或其他工作项类型的交付资格。方案尚未获确认；确认前不得编写 Repair Plan 或修改实现规则。
