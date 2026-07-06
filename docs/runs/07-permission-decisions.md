# permission-decisions.md

## 目的

`permission-decisions.md` 记录高风险操作和 Git lifecycle 操作的审批请求、source、动作分类、决策人或 owner、时间、条件、证据和理由。

## 写入阶段

Run 中需要权限升级、secret access、database write、destructive action、CI/CD、production、release、final merge/push，或 branch delete/worktree remove 等 destructive cleanup 操作时。授权 checkpoint/fix commit 也应记录 source、action、intent 和 conditions，但它不是 final acceptance。

## 写入者

Harness 记录请求和决策。Final acceptance、production、release、material destructive actions 的决策 owner 必须是具名 Human；Supervisor/controller 可以记录已授权的 low-risk checkpoint/fix commit 或执行 G6 后 finalization，但不能替代 Human acceptance。

## 记录内容

- schema-lite labels: `Decision log status`、`Decision count`、`No permission requests`
- `Decisions` table: request id、source、git action、intent、category、risk、decision、decider/owner、time、conditions、evidence、reason
- machine-readable `decision_entries`: `request_id`、`source`、`git_action`、`intent`、`category`、`risk`、`decision`、`decider_owner`、`time`、`conditions`、`evidence`、`reason`、`residual_risk`
- requests and decisions summary；无请求时用 `N/A`、`none` 或 `not_applicable_*`，不要留空或发明决策
- conditions
- deferred or denied requests
- residual risk

## Gate 影响

高风险动作缺少 permission decision 会阻塞相关 Human Gate，进而阻塞后续 Quality Gate 或 final acceptance。

## 如何阅读

确认每个高风险动作都有明确 request、source、risk、decision、具名 Human decider、time、reason 和 conditions。对 Git lifecycle 动作，确认 category 区分 checkpoint/fix、destructive cleanup、final merge/push/release。若请求被 deferred 或 denied，检查 residual risk 是否传递到后续 gate/acceptance 判断。
