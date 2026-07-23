# S-005 全局 Open Question Registry - 需求确认

## 需求来源

- 工作项：[S-005 全局 Open Question Registry](../../../../docs/delivery/stories/S-005-open-question-registry.md)
- 版本：`2`
- 排序依据：[Backlog](../../../../docs/delivery/backlog.md) 中第一个 Ready 工作项。

## ✅ 确认范围

- 提供独立的共享 Open Question Registry skill，作为仓库级未决问题的单一索引维护能力。
- 仅在首次确实需要登记问题时按需创建 `docs/open-questions.md`；安装和无问题 workflow 不创建空文档。
- Registry 记录稳定 ID、类型、状态、Owner、权威来源、影响和建议解决阶段。
- 有权威文档时 Registry 只保存摘要和链接；无权威承载位置时可暂存完整正文。
- 问题获得归属时迁移正文并保持单一正文来源；问题解决、拒绝、失效或被替代时从当前索引移除。
- Registry 使用 Change Log 追溯新增、迁移和移除，但不在历史中复制完整问题正文。
- 用户可直接请求查看或维护仓库级 Open Questions，`using-dev-cadence` 能路由到共享能力。
- 增加契约测试保护按需创建、全局索引、单一正文来源、迁移、移除、Change Log、冲突保护和入口路由。

## ❌ 非范围

- 不把 PRD、Business Architecture 或工作项的问题正文复制到 Registry。
- 不移除各权威文档自身的 `Open Questions`。
- 不在安装时生成或覆盖目标仓库的 `docs/open-questions.md`。
- 不自动回答、关闭问题或创建工作项。
- 不实现 S-002 的增量产品设计版本治理，不实现后续 Work Item Planning。
- 不向 feature-dev、bug-fix、refactor 或 discovery 复制完整 Registry 生命周期规则。

## 验收标准

验收标准以 Story Version `2` 中的 12 项为权威来源，实施必须全部覆盖。

## 假设与开放问题

- Story 明确记录 Open Questions 为“无”，当前无阻塞决策。
- “独立共享能力”解释为新的 `src/skills/open-question-registry/SKILL.md`，而非新增一个六阶段业务 workflow。
- 任务影响可安装包和用户可见规则，版本预计从 `0.12.0` 升至 `0.13.0`。
- 采用 Enhanced Exploration，因为任务横跨 skill 所有权、入口路由、安装包和契约测试。

## 需求结论

- Status: ✅ `confirmed`
- Confirmation: 用户于 2026-07-14 授权从 Backlog 选取下一个任务并无需中途确认地完整交付。
