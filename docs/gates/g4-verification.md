# G4 Verification

## 目的

G4 确保 changed behavior 在 review approval 或 acceptance 前有完整、可复现的 verification 证据。

## 检查阶段

`test` 或 verification checkpoint 之后，review approval 之前。

## 必要输入

- [04-test-plan.md](../artifacts/04-test-plan.md)
- [05-implementation.md](../artifacts/05-implementation.md)
- [06-test-report.md](../artifacts/06-test-report.md)
- 执行命令或测试时的 Harness [test-log.md](../runs/05-test-log.md)
- changed-component coverage

## 通过条件

每个 affected component 和 changed platform 都有对应 verification，且 verification status 是 `verified`；或者具名 Human Gate 接受 incomplete verification。

## Verification Status 取值

允许值：

```text
verified
partially_verified
not_verified
blocked_by_environment
```

只有 `verified` 可以单独通过 G4。

## 常见阻塞

- Test environment 阻塞验证。
- Changed components 缺少对应 coverage。
- Skipped checks 缺少 residual risk 和 follow-up。
- Harness 运行证据缺失。
- S1/S2 implementation 缺少 pre-implementation status。

## 人工 Override

具名 Human 可以接受 incomplete verification，但必须记录 residual risk、证据缺口、follow-up，以及适用时的 revisit condition。

## 相关产物

- [06-test-report.md](../artifacts/06-test-report.md)
- [Tester](../roles/agents/04-tester.md)
