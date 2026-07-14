# S-011 目标驱动的架构设计 Workflow

## 基本信息

- ID：`S-011`
- Version：`2`
- Status：`Ready`
- Priority：`P1`
- Change Type：Feature

## 目标

新增一个轻量、目标驱动的 `architecture-design` workflow。仅当用户明确要求进行架构设计时启动，围绕用户确认的目标完成必要调查、方案选择和架构设计，并将结果写入 `docs/architecture/<goal-slug>.md`。

## 背景

当前 Discovery 明确不负责技术架构，Feature Dev、Bug Fix 和 Refactor 则只在各自交付流程中维护局部 Solution。仓库缺少一个可以直接响应独立架构设计请求的 workflow。

产品架构、系统架构、模块架构、集成架构或某条业务链路的架构设计虽然分析尺度不同，但没有必要预设多套 Scope、目录结构和产物契约。用户明确要求设计什么，workflow 就应围绕该目标确定边界、调查现状、比较有意义的方案并形成一份可确认的架构文档。

## User Story

作为需要进行架构设计的用户，我希望明确提出架构目标后获得一份与该目标对应的架构文档，以便评审和确认关键边界、组件职责、交互方式、技术决策及风险，而不必先选择产品级、能力级或工作项级架构分类。

## 范围

- 新增 `architecture-design` workflow，并由 `using-dev-cadence` 在用户明确要求架构设计、架构方案或架构评审时选择该 workflow。
- workflow 不根据仓库状态、Discovery 完成、Feature 开始或其他开发活动自动触发。
- 首先与用户确认架构目标、设计对象、范围、非范围、关键约束、期望详细程度和产物名称。
- 根据目标调查必要的当前代码、现有文档、组件边界、数据与接口、外部依赖、部署环境和质量属性约束。
- 当目标仓库或必要现状不存在时，允许基于用户提供的背景继续设计，但必须显式记录关键假设。
- 当存在实质不同的选择时，比较 `2-3` 个候选方案；不存在有意义的备选方案时，不强制凑数。
- 方案标题遵守共享文档规范：用户确认的方案标记为 `✅ Selected`，明确拒绝的方案标记为 `❌ Rejected`，仍未决策时标记为 `❓ Decision Pending`，未选但仍有效的方案保持中性。
- 推荐方案在用户确认前不得标记为 `✅ Selected`。
- 架构文档根据实际目标包含必要内容，例如架构目标、范围与非范围、当前现状、驱动因素与约束、备选方案、选定架构、组件职责、数据与交互、外部边界、关键技术决策、质量属性、风险、开放问题和验证方式。
- 文档章节按任务需要裁剪，不要求生成与当前架构目标无关的空章节。
- 架构图直接作为架构文档的一部分，优先使用 Mermaid；只有 Mermaid 无法清晰表达时才使用其他图形资产。
- 用户确认前，文档不得声称架构已经批准；确认摘要必须说明产物路径、选定方案、关键决策和未解决问题。
- 核心产出物只有一份架构文档，路径为 `docs/architecture/<goal-slug>.md`。
- `<goal-slug>` 根据用户确认的架构目标生成清晰、可移植的 kebab-case 文件名，不使用固定的 Product、Capability 或 Work Item 分类命名。
- 当目录已经表达文档类型时，文件名默认不重复追加 `architecture`；只有避免歧义确有必要时才保留该词。
- 更新安装、构建和契约验证，使新 workflow 能进入可安装 `.dev-cadence` 包并被入口正确发现。

## 非范围

- 不在用户没有明确提出架构设计目标时自动启动该 workflow。
- 不预设 Product、Capability、Work Item 等架构 Scope 分类。
- 不为不同架构尺度定义多套输出目录或固定文件名。
- 不自动成为 Discovery、Feature Dev、Bug Fix、Refactor 或 Work Item Planning 的必经阶段。
- 不替代现有开发 workflow 中面向当前交付任务的 Technical Solution、Repair Solution 或 Refactor Solution。
- 不负责需求发现、工作项拆分、实施计划、代码修改、系统测试或发布部署。
- 本 Story 暂不定义架构 workflow 的 run manifest、stage record、checkpoint commit 或其他过程记录。
- 不强制为没有实质方案分歧的设计制造多个候选方案。
- 不要求为不适用的架构主题保留空章节或绘制无信息增益的图。

## 验收标准

1. 用户明确要求进行架构设计、架构方案或架构评审时，入口能够选择 `architecture-design` workflow。
2. 用户未明确提出架构目标时，其他产品或开发请求不会因为可能涉及技术内容而自动进入该 workflow。
3. workflow 在设计前确认架构目标、范围、非范围、约束、详细程度和产物名称。
4. workflow 根据用户目标调查必要的代码、文档、组件、数据、接口、依赖、运行环境和质量属性约束，并在缺少现状时记录假设。
5. 存在实质不同方案时比较 `2-3` 个候选方案；不存在有意义的差异时允许直接形成单一方案。
6. 方案选择遵守 `Selected`、`Rejected`、`Decision Pending` 和中性备选的统一语义，推荐不会在用户确认前被误标为已选定。
7. 架构文档包含理解和评审当前目标所需的架构边界、组件职责、交互、决策、风险和验证方式，并允许删除不适用章节。
8. 架构图是架构文档的一部分，优先使用 Mermaid，且不会被当作唯一架构产出物。
9. 唯一规定的核心产出物位于 `docs/architecture/<goal-slug>.md`，文件名根据用户确认的目标生成，不使用预设 Scope 分类。
10. 用户确认前文档不会声称架构已批准，确认摘要能够指出产物、选定方案、关键决策和开放问题。
11. workflow 不自动修改代码、拆分工作项、生成实施计划或替代现有开发 workflow 的局部 Solution。
12. Story 实现后，source、dist 和安装包中的 workflow 内容保持同步，并有契约验证覆盖入口路由、显式触发、目标命名和边界规则。

## Story Relationships

- Follows：`S-012` Asset 与 Delivery Workflow 记录边界。
- Related：Feature Dev、Bug Fix 和 Refactor 的 Solution 阶段。
- Related：`S-006` Discovery 产品与技术内容边界。

## 依赖

- `S-008` Skill 语义视觉规范。
- `S-012` Asset 与 Delivery Workflow 记录边界。

## 后续工作

- 在有实际需求后，再评估是否需要为架构文档增加独立版本治理或变更记录规则。
- 后续审计需求应优先通过架构文档自身的版本与变化记录解决，不重新引入独立 run manifest、阶段记录或 checkpoint。
- Work Item Planning 后续可以引用已经存在的架构文档，但本 Story 不建立强制前置关系。

## Open Questions

- 无。

## 相关文档

- [S-001 首次 Discovery 与产品设计基线](S-001-initial-discovery-prd-baseline.md)
- [S-006 Discovery 产品与技术内容边界](S-006-discovery-product-technical-content-boundary.md)
- [S-008 Skill 语义视觉规范](S-008-skill-semantic-visual-markers.md)
- [S-012 Asset 与 Delivery Workflow 记录边界](S-012-asset-delivery-workflow-record-boundary.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建目标驱动的架构设计 Workflow Story。 | 为用户明确提出的架构目标提供统一、轻量的设计流程和按目标命名的单一架构文档产出。 |
| 2 | 2026-07-14 | 增加 Asset Workflow 记录边界依赖。 | 架构设计应复用统一的无独立过程记录契约，而不是单独定义例外。 |
