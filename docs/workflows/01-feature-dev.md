# feature-dev

## 什么时候使用

`feature-dev` 用于新增用户可见行为或系统行为。

完整运行时规则见 [workflows.md](../../references/workflows.md)；风险增强规则见 [task-classes.md](../../references/task-classes.md)。

## 标准路径

```text
需求确认 -> 技术调研 -> 制定实施计划 -> 架构设计（可选） -> TDD 开发实施 -> 测试验收
```

当功能改变 public contract、架构、数据模型或跨模块行为时，必须进入 `架构设计`。

## 路线图

| 角色 | 需求确认 | 技术调研 | 制定实施计划 | 架构设计（可选） | TDD 开发实施 | 测试验收 |
|---|---|---|---|---|---|---|
| Human | 说明业务目标、用户场景、成功标准、范围和非目标，并确认需求。 | 补充业务约束、现有流程和不可破坏的用户体验。 | 确认实施计划覆盖业务目标，决定范围取舍。 | 对影响产品能力、数据、安全或长期成本的方案做 decision / risk acceptance。 | 对权限扩大、范围变化或业务取舍做 decision。 | 试用或审阅结果，做具名验收、拒绝验收或接受剩余风险。 |
| Supervisor | 选择 `feature-dev`，组织需求澄清，确保 G1 满足。 | 判断调研深度和停止条件，控制问题不扩散。 | 判断计划是否能交付业务结果、可验证且范围受控。 | 判断是否需要架构设计，控制 G2、升级和回环。 | 授权执行边界，处理偏离、阻塞、返工和 review findings。 | 汇总验证、review、gate 与风险，提交 Human decision。 |
| Harness | 保存需求、验收标准、边界和确认记录。 | 保存调研问题、结论、证据和未决风险。 | 保存任务、授权范围、测试计划和风险记录。 | 保存设计方案、取舍、确认记录和风险接受依据。 | 约束文件、命令、权限和证据捕获边界。 | 保存验证命令、结果、跳过项、review 结论和 acceptance 记录。 |
| Planner（Worker） | 整理需求草案、验收标准、业务边界和验证思路供确认。 | 汇总调研结论，把不确定性转成计划约束或待决问题。 | 拆分可交付任务、依赖、目标文件、测试计划和风险。 | 将已确认设计约束并入任务拆分和执行顺序。 | 根据执行反馈调整任务切片或返工建议。 | 提供计划完成度、剩余范围和后续建议。 |
| Architect（Worker） | 识别是否存在 public contract、架构、数据模型或跨模块影响。 | 调研可选技术路径、兼容性、迁移成本和架构风险。 | 检查计划是否保留关键架构约束。 | 产出设计方案、接口边界、迁移约束和风险说明供确认。 | 对实现偏离设计的情况给出修正建议。 | 判断验证是否覆盖设计敏感点，并提供技术风险输入。 |
| Developer（Worker） | 评估需求可实现性、实现影响和技术疑点。 | 验证关键技术假设，识别实现路径和主要风险。 | 反馈任务依赖、文件边界、实现顺序和测试切入点。 | 评估设计方案的实现成本与落地风险。 | 按授权计划实现变更，优先走 Red-Green-Refactor，并修复有效 findings。 | 提供变更摘要、已验证内容和剩余风险输入。 |
| Tester（Worker） | 协助把业务需求转成可验证的验收标准和场景。 | 识别高风险业务路径、回归面和测试数据需求。 | 形成聚焦测试、回归验证和验收检查计划。 | 补充架构敏感场景的验证要求。 | 为实现提供测试反馈或测试用例补充。 | 运行聚焦验证和相关回归，报告命令、结果、跳过项和风险。 |
| Reviewer（Worker） | — | 预识别可能影响 review 的技术风险。 | 确认计划具备可 review 的边界和输入。 | 评审设计一致性、可维护性和回归风险。 | 对实际 diff 做 spec compliance 和 code quality review；有效 findings 返回修复循环。 | 提供未解决 finding、review verdict 和验收前风险输入。 |

## 主要角色

- Supervisor 负责分类请求并控制状态流转。
- Planner 负责澄清需求并写出可执行任务。
- Architect 在 `S2` 或设计敏感任务中参与。
- Developer 通过 Harness 实现限定范围内的变更。
- Tester 验证变更行为。
- Reviewer 检查 spec compliance 和 code quality。
- Human 确认需求并做最终验收。

## 主要产物

- [00-brief.md](../artifacts/00-brief.md)
- [01-requirements.md](../artifacts/01-requirements.md)
- 需要时写 [02-design.md](../artifacts/02-design.md)
- [03-tasks.md](../artifacts/03-tasks.md)
- [04-test-plan.md](../artifacts/04-test-plan.md)
- [05-implementation.md](../artifacts/05-implementation.md)
- [06-test-report.md](../artifacts/06-test-report.md)
- [07-review-report.md](../artifacts/07-review-report.md)
- [08-acceptance.md](../artifacts/08-acceptance.md)

## Gate 重点

- G1 确认目标、范围、非目标、验收标准和验证方式。
- G2 在架构敏感设计需要确认时启用。
- G3 确认任务可执行且范围受控。
- G4 确认验证证据覆盖变更组件。
- G5 确认 Review 没有未解决的 blocker 或 major issue。
- G6 记录具名 Human acceptance。

## Human 介入点

需求确认、高风险设计或权限边界、不完整验证 override，以及最终验收都需要 Human decision。
