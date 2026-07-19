# B-013 问题诊断记录

- 状态：✅ `confirmed`
- 记录时间：`2026-07-19T21:30:32+0800`
- 最近确认：`2026-07-19T21:34:40+0800`，选项 1：确认当前诊断并进入 Repair Solution。
- 工作项：[B-013 Story Ready 错误依赖 Feature 关联](../../../../docs/bugs/B-013-story-ready-feature-reference-required.md)
- 工作项类型：`Bug`
- 卡片 Version：`2`
- 卡片可见状态：`In Progress`
- 选定范围：纠正 Story `Ready` 对主 System Feature 的错误强制依赖，并验证已有 Feature 追踪与真正产品级结论缺口的边界；不改变 Task、Bug 或 Delivery Workflow 资格。

## 报告的症状

定义已完整、且不依赖产品级 Feature 的独立 Story 不能进入 `Ready`。当前规则要求其先具备主 System Feature，并在缺少 Feature identity 时返回 Discovery。

## 期望行为

Story 在角色、目标、价值、范围、可观察行为、验收条件、依赖、阻塞性问题和用户确认均明确后可以进入 `Ready`。已有 Feature 或 Story Map 来源的 Story 保留其已确认追踪关系；没有 Feature 且不需要新建或改变产品级结论的独立 Story 不应仅因此返回 Discovery。

## 实际行为与复现证据

1. `src/skills/work-item-analysis/SKILL.md` 的 Story 分析字段将“primary System Feature and required product traceability”列为最低定义项，并规定 Story `Ready` 必须具备“primary Feature”。
2. 同一源文件把缺少“necessary Feature identity”与缺少 User Journey、PRD 或 Business Architecture 结论合并处理，要求返回 Discovery；这使 Feature 缺失本身成为路由条件。
3. 构建后的 `dist/.dev-cadence/skills/work-item-analysis/SKILL.md` 和当前安装包 `.dev-cadence/skills/work-item-analysis/SKILL.md` 均包含相同强制条件，说明该问题会进入分发和运行时规则。
4. 针对期望契约的最小 RED 检查检测到当前 `Ready` 规则仍含“primary Feature”，输出：`RED: Story Ready gate still requires primary Feature.`
5. 工作区在构建后执行 `bash scripts/check-all.sh` 通过，表明既有契约测试没有表达无 Feature 独立 Story 的正确行为，因而无法阻止此回归。

## 影响范围

- 规则源：`src/skills/work-item-analysis/SKILL.md`。
- 定义契约测试：`tests/work-item-analysis-contract.sh`。
- 可能需要澄清入口语义的相邻规则：`src/skills/using-dev-cadence/SKILL.md`，仅限确保其不暗示 Feature 缺失本身触发 Discovery。
- 可安装分发包：`dist/.dev-cadence/` 与当前安装包 `.dev-cadence/`；根目录 `version` 需在修复方案阶段按包行为变更评估并更新。

## 根因假设与置信度

**根因：** `work-item-analysis` 将“已有 Feature 的追踪要求”错误泛化为每一张 Story 进入 `Ready` 的必要条件，并将缺少 Feature identity 与真正缺少或改变产品级结论混为同一 Discovery 路由条件。该规则把独立的内部 Story 强制耦合到并不需要的产品设计基线。

**证据：** 同一错误措辞存在于 source、生成分发包和当前安装包；最小 RED 检查直接命中该门禁；既有全量检查通过但未覆盖无 Feature 的独立 Story。

**置信度：** 高。

## 复现条件

1. 仓库没有适用的已确认 Feature，或待分析 Story 并不依赖任何产品级结论。
2. Story 的角色、目标、价值、范围、行为、验收条件、依赖和阻塞性问题均已明确。
3. 用户确认该工作项定义并请求将 Story 更新为 `Ready`。
4. 当前规则仅因没有主 System Feature 或 Feature identity 而阻止 `Ready`，并返回 Discovery。

## 开放问题与假设

- 开放问题：无。
- 假设：来自 Story Map 或已有 Feature 定义的 Story 已拥有可验证的 Feature 引用；本次修复只要求保留该既有关系，不创建、修改或重新解释 Feature。

## 诊断结论

✅ 已确认 B-013 是既有规则错误：Feature 是在存在时应保留的追踪关系，不是所有 Story `Ready` 的通用前置条件。只有 Story 实际需要新建或改变产品级结论时，才应返回 Discovery。用户已于 `2026-07-19T21:34:40+0800` 选择选项 1，确认诊断并允许进入 Repair Solution。诊断范围不包含产品设计资产、Story Map 结构或其他工作项类型的入口规则。
