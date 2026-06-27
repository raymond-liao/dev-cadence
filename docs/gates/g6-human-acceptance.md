# G6 Human Acceptance

## 目的

G6 确保具名 Human 接受最终输出和剩余风险。

## 检查阶段

`acceptance` 阶段；在声明最终完成、commit readiness、merge 或 release 之前。

## 必要输入

- 所有 required task artifacts
- verification status
- review decision
- evidence reviewed
- residual risk 和 skipped checks
- [08-acceptance.md](../artifacts/08-acceptance.md)

## 通过条件

[08-acceptance.md](../artifacts/08-acceptance.md) 命名 Human accepter，并记录 accepted scope、evidence reviewed、residual risk 和 decision。

## 常见阻塞

- `accepted_by_human` 为空。
- Accepter 是 Supervisor、Harness、Developer、Tester、Reviewer 或未指定 agent。
- Residual risk 未记录。
- S2 work 缺少 required requirement、architecture、permission 或 final Human Gate decisions。
- 只有 commit request，但没有 [08-acceptance.md](../artifacts/08-acceptance.md)。

## 人工 Override

G6 本身就是最终 [Human](../roles/01-human.md) decision。它必须记录在 [08-acceptance.md](../artifacts/08-acceptance.md)，不能被 agent claim、review approval、passing tests 或 commit request 替代。
