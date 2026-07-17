# B-006 问题诊断记录

- Status: `in_progress`
- Work Item: [B-006 Delivery 记录证据完整性](../../../../docs/bugs/B-006-delivery-record-evidence-completeness.md)
- Workflow: `bug-fix`
- Diagnosis Branch: `codex/b-006-delivery-record-evidence-completeness`
- Diagnosis Baseline: `9834d2ee4c3536196e7844bfc697ed724088a7ea`

## 报告症状

Delivery Workflow 在实施、代码审查、系统测试和 Completion 期间会产生多次记录提交，但最终 manifest、阶段记录和提交身份可能互不一致。S-014 是当前可验证样本：运行已标记为 integrated，仍存在过期占位符、阶段 checkpoint 与记录 tree 脱节，以及对临时 SDD 文件的错误引用。

## 预期行为

一个进入完成状态的 Delivery Workflow 运行，应能够只依靠仓库中的 manifest、阶段记录、代码审查报告、测试报告和 Git 提交身份恢复：

- 实际实现范围和最终实现提交；
- 每个已完成阶段对应的最新阶段记录及其 checkpoint；
- 代码审查和测试结论；
- 所有影响交付结论的修复提交。

SDD 的 progress ledger 只用于活动运行期间的恢复，不应成为完成后必须存在的长期交付证据。

## 实际行为

### 1. 完成记录允许占位符残留

当前 S-014 实施记录同时具有：

- `Status: completed`；
- `Final Implementation SHA: 1c03992`；
- `Changed Files: pending`。

三个 Delivery Workflow 的规则都使用“implementation commit hash or changed files”，Completion 检查也使用“final implementation commit hash or final changed-files state”，因此规则本身允许这种不完整终态。

### 2. 阶段 checkpoint 没有绑定阶段记录所在 tree

S-014 的提交关系如下：

| Commit | 记录状态 | 对应文件 tree |
| --- | --- | --- |
| `1c03992` | manifest 标记为 Development Implementation checkpoint | 不包含 `04-implementation-record.md`、`04-code-review-report.md` 或 `05-system-test-report.md` |
| `abd43ea` | manifest 标记为 System Testing checkpoint | 不包含上述三个阶段记录 |
| `d0ec273` | 后续补入实施记录、代码审查报告和系统测试报告 | 包含三份记录及 manifest |

因此 manifest 的阶段 checkpoint 并不是包含对应阶段记录的真实证据提交。后续提交虽然补入记录，但没有把阶段 checkpoint 重新绑定到包含这些记录的 tree。

### 3. 长期记录错误引用 SDD 临时产物

S-014 实施记录引用 `sdd/progress.md`，但该文件当前不存在。Vendored SDD 规则将 progress ledger 定义为 ignored scratch，且明确说明 `git clean -fdx` 会删除它。该文件不能承担完成运行的长期权威证据职责。

### 4. 没有真实运行记录验证器

现有测试主要使用 `rg` 对三套 Workflow 的规则文本做静态契约检查，没有验证：

- 完成状态下是否还存在 `pending` 占位符；
- manifest 引用的本地记录是否存在；
- checkpoint commit 的 tree 是否包含对应阶段记录；
- 最终 review 与最终实现提交是否覆盖完整提交范围。

## 影响范围

问题直接影响 `feature-dev`、`bug-fix` 和 `refactor` 三个 Delivery Workflow。它不会改变业务代码运行行为，但会使交付记录无法独立恢复，也可能让不完整证据被错误地推进到 Business Acceptance 或 Completion。

## 复现证据

在诊断基线 `9834d2ee4c3536196e7844bfc697ed724088a7ea` 上：

1. 查看 `build/dev-cadence/feature-dev/s-014-user-journey-baseline/04-implementation-record.md`，可见 `Status: completed` 与 `Changed Files: pending` 同时存在。
2. 查看同目录的 manifest，可见 Development Implementation checkpoint 为 `1c03992`，System Testing checkpoint 为 `abd43ea`。
3. 对两个 checkpoint 执行记录文件存在性检查：两个 commit tree 都不包含 `04-implementation-record.md`、`04-code-review-report.md` 或 `05-system-test-report.md`。
4. 对当前工作区执行 `test -e build/dev-cadence/feature-dev/s-014-user-journey-baseline/sdd/progress.md`，结果为文件不存在。
5. 查看提交顺序可见 `d0ec273` 才加入三份阶段记录，晚于两个被 manifest 引用的 checkpoint。

## 根因分析

### RC-001：终态证据契约是替代关系而不是完整关系

- 证据：三套 Delivery Workflow 都允许“commit hash 或 changed files”。
- 结果：有最终 SHA 时，代理可以不填写 Changed Files；记录仍能通过文字门禁。
- 置信度：高。

### RC-002：checkpoint 规则只要求写入 hash，没有证明 commit tree 与阶段记录绑定

- 证据：规则要求更新 manifest 并记录 checkpoint，但没有要求验证 checkpoint tree 包含最新阶段记录。
- 结果：代码提交或治理提交被标为阶段 checkpoint，真正的记录提交却出现在后面。
- 置信度：高。

### RC-003：SDD 临时恢复信息与长期交付证据没有分层

- 证据：Vendored SDD 将 progress ledger 定义为 ignored scratch；S-014 实施记录却把它作为 `Progress Ledger` 长期链接。
- 结果：记录引用不存在或已清理的文件，且最终 review 状态无法从权威记录恢复。
- 置信度：高。

### RC-004：验证层只验证规则文本，没有验证实际运行产物

- 证据：现有 workflow symmetry/package 测试是源文件正则和分发一致性检查，未读取真实 run manifest 或调用 Git tree 证据。
- 结果：规则文本可以通过，而 S-014 这样的实际运行记录仍然不完整。
- 置信度：高。

## Bug 确认结论

当前证据足以确认这是一个真实的治理规则和记录验证缺陷，不是单纯的 S-014 个案录入错误。根因覆盖规则契约、checkpoint 身份绑定、SDD 证据边界和验证测试四个层面。

## 当前未决问题

- Repair Solution 需要决定“已提交实现”的 Changed Files 与最终 commit SHA 的精确必需关系，以及无 tracked changes 时的表达方式。
- Repair Solution 需要决定 checkpoint 是要求 tree 包含当前阶段记录，还是要求单独的 record checkpoint 与 manifest 更新形成可验证的两步绑定。
- Repair Solution 需要定义三套 Delivery Workflow 的公共规则放置位置，保持对称且不重复完整规则。

以上问题属于下一阶段 Repair Solution；本诊断记录不预先替代用户确认的修复方案。

