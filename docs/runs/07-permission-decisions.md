# permission-decisions.md

## 目的

`permission-decisions.md` 记录高风险操作的审批请求、决策人、时间和理由。

## 写入阶段

Run 中需要权限升级、secret access、database write、destructive action、CI/CD、production 或 release 相关操作时。

## 写入者

Harness 记录请求和决策。决策 owner 必须是具名 Human，不能是 Supervisor、Harness 或 Worker Agent。

## 记录内容

- `Decisions` table: request、risk、decision、decider、time、reason
- requests and decisions summary
- conditions
- deferred or denied requests
- residual risk

## Gate 影响

高风险动作缺少 permission decision 会阻塞相关 Human Gate，进而阻塞后续 Quality Gate 或 final acceptance。

## 如何阅读

确认每个高风险动作都有明确 request、risk、decision、具名 Human decider、time、reason 和 conditions。若请求被 deferred 或 denied，检查 residual risk 是否传递到后续 gate/acceptance 判断。
