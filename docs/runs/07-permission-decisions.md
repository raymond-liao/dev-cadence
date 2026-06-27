# permission-decisions.md

## 目的

`permission-decisions.md` 记录高风险操作的审批请求、决策人、时间和理由。

## 写入阶段

Run 中需要权限升级、secret access、database write、destructive action、CI/CD、production 或 release 相关操作时。

## 写入者

Harness 记录请求和决策。决策 owner 必须是具名 Human，不能是 Supervisor、Harness 或 Worker Agent。

## 记录内容

- requested action
- reason
- risk if skipped
- requested by
- decision
- decided by
- decided at
- conditions
- follow-up

## Gate 影响

高风险动作缺少 permission decision 会阻塞相关 Human Gate，进而阻塞后续 Quality Gate 或 final acceptance。

## 如何阅读

确认每个高风险动作都有明确 decision owner、decision、conditions 和 follow-up。
