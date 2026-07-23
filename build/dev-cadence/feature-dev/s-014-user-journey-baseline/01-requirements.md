# S-014 需求确认

## 来源与确认

- Work Item: [S-014 Discovery User Journey 与 Feature 基线](../../../../docs/delivery/stories/S-014-user-journey-analysis.md)
- Work Item Version: `2`
- Backlog: [当前可并行实施表](../../../../docs/delivery/backlog.md#当前可并行实施表)
- Status: ✅ `confirmed`
- Confirmation: 用户于 `2026-07-16` 明确要求按照 Backlog 并行实施表开始完成后续任务，授权本任务在已是 Ready 且无 Open Questions 的前提下连续完成 Requirements、Technical Solution 和 Implementation Plan 阶段。
- Business Acceptance 不在该授权内，仍需用户选择固定验收选项。

## ✅ 已确认范围

- 把 User Journey 分析与确认纳入 `discovery`，使阶段顺序变为背景探索、Journey 分析、Journey 确认、PRD 与 Business Architecture 推导、最终产品设计确认。
- 新增唯一权威路径 `docs/product-design/user-journey.md`，与 PRD、Business Architecture 共同组成三资产产品设计基线。
- 定义一条稳定业务线、Journey Map、角色参与、业务阶段、从左到右的业务顺序、`Offline`/`System` Feature 和稳定 `J-nnn`/`F-nnn` 身份。
- Discovery 创建和维护 Journey 内 Feature Definitions；其他 workflow 只能引用已确认 Feature，不重新定义其身份与顺序。
- 建立两道确认门：Journey 确认后才可写入 Journey 并正式推导 PRD/Business Architecture；最终确认后才可写入后两项资产和支撑性维护。
- 让重要 PRD Requirement 与 Business Architecture 的关键业务内容追溯到已确认 Journey/Feature，同时避免复制 Journey Map 或重定义 Feature。
- 支持三资产独立版本，以及增量输入对 Journey 有影响、无影响和“已有 PRD/Business Architecture 但没有 Journey”三类路径。
- 同步权威 source skill、入口路由、双语 README、契约测试、构建后安装包和根版本号。

## ❌ 非范围

- 不实现 Story Map、Milestone、Iteration Plan、统一 Backlog、Work Item Planning 或 Work Item Analysis。
- 不创建 Story、Task、Bug 或 Feature 卡片，不把 System Feature 拆分成工作项。
- 不设计技术架构、代码模块、数据库、API、部署拓扑或应用实现。
- 不新增独立 User Journey workflow、共享 Journey skill、多 Journey 目录、根索引或拆分阈值。
- 不修改 `src/vendor/superpowers/**`。
- 不扩散修改与 S-014 没有直接路由、读取或维护关系的相邻 workflow。

## 验收标准

1. Discovery 从不完整想法进入 Journey 分析和确认，再从已确认 Journey 推导并确认 PRD 与 Business Architecture。
2. Journey 未确认时，不正式推导后两项资产，也不写入权威 Journey 路径。
3. 初次模式创建 Version `1` 的 `docs/product-design/user-journey.md`，包含 Journey ID、业务线边界、Journey Map、Feature Definitions、`Open Questions`、`Rejected Directions` 和 Change Log。
4. Journey Map 与 Feature Definitions 稳定表达角色、阶段、顺序、Type 和 `J-nnn`/`F-nnn` 身份。
5. PRD 与 Business Architecture 引用同一 Journey/Feature 业务身份，不复制或重定义它们。
6. 三项资产独立版本，只有实质受影响的资产升版。
7. 增量输入不影响 Journey 时不重新确认、改写或升版；影响时先确认 Journey 修订。
8. 既有 PRD 或 Business Architecture 缺少 Journey 时，先形成首份 Journey，再只协调实际受影响资产。
9. 两道确认门前，对应权威资产和支撑资产保持不变；反馈只更新会话提案。
10. Discovery 不创建 Story Map、工作项或技术实现。
11. `src/`、`dist/.dev-cadence/`、入口、README 和契约测试一致。
12. 根版本号按新增资产与门禁行为升级。

## 假设与开放问题

- 假设：已确认的 [Discovery 流程设计](../../../../docs/workflows/discovery.md) 是 S-014 的详细业务设计输入；Story Version 2 是范围与验收边界。
- 假设：Change Log 的详细字段沿用该已确认流程设计，不额外发明审批元数据。
- Open Questions: None。
