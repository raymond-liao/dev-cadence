# G4 Verification

## 目的

G4 用来确认变更在进入 Review 或验收前，已经有完整、可复查的验证证据。

## 检查阶段

`test` 或验证检查之后，Review 放行之前。

## 必要输入

- [04-test-plan.md](../artifacts/04-test-plan.md)
- [05-implementation.md](../artifacts/05-implementation.md)
- [06-test-report.md](../artifacts/06-test-report.md)
- 执行命令或测试时的 Harness [test-log.md](../runs/05-test-log.md)
- 变更覆盖范围

## 通过条件

每个受影响的组件和平台都有对应验证，[06-test-report.md](../artifacts/06-test-report.md) 中的 `verification_status` 是 `verified`；或者 Human 明确接受验证不完整的风险。通常由 [Tester](../roles/agents/04-tester.md) 准备验证结论。

## 验证结果

验证结果决定能不能进入 Review 或验收：

- `verified`：该验证的变更面都验证过，并且有可复查证据，可以继续进入 Review。
- `partially_verified`：只验证了一部分。必须写清楚没验证什么、为什么没验证、剩余风险是什么；是否继续由 Human 决定。
- `not_verified`：还没有可信验证。通常不能进入 Review 或验收，除非 Human 明确接受这个风险。
- `blocked_by_environment`：因为环境、权限、依赖或平台条件无法验证。下一步应先解决阻塞或换验证方式；如果仍要继续，必须让 Human 接受这个验证缺口。

## 常见阻塞

- 测试环境阻塞验证。
- 受影响组件缺少对应验证。
- 跳过的检查没有说明剩余风险和后续处理。
- Harness 运行证据缺失。
- S1/S2 实现缺少 pre-implementation status。

## 人工 Override

Human 可以接受不完整验证，但必须写清楚剩余风险、证据缺口、后续处理，以及需要回看时的条件。
