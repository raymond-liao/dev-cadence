# S-019 技术方案

## 已确认需求来源

- Requirements: `build/dev-cadence/feature-dev/s-019-final-verification-revision-binding/01-requirements.md`
- Requirements SHA-256: `7fe654dddf820aa526bf60af4a7f98d5b9ccaf3062e1cfcad96c8be0ca6415b8`

## Codebase Exploration Findings

- 三条 Delivery workflow 已分别拥有最终验证、Business Acceptance 与 Completion 边界；它们应共享同一候选身份语义，而不是各自实现 Git 比较逻辑。
- `validate-delivery-record.sh` 是现有跨 workflow 验证入口，但当前只接受 `Artifact` 表头并在任何阶段强制要求实施记录，和新 manifest 使用的 `Artifact Path` 及实施前阶段冲突。
- `tests/delivery-record-contract.sh` 已是脚本行为的契约测试位置，`tests/workflow-symmetry.sh` 已是三 workflow 规则对称性的验证位置。

## 备选方案

### 方案 A：共享 validator 的分阶段核验（推荐）

扩展现有 validator：默认模式只做当前阶段可满足的结构验证；新增最终验证模式校验快照、可达性和 checkpoint 白名单；`--terminal` 在终态验证时包含最终验证规则。三条 workflow 都调用同一脚本，并只负责记录、重验与回退规则。

优点：单一算法、三条 workflow 对称、能在 Business Acceptance 和 Completion 前执行精确重验，也能修复实施前 manifest 的错误拒绝。

### 方案 B：仅在终态 validator 中检查身份

保留现有脚本的主体，只在 `--terminal` 中加入快照检查。

优点：改动较少。缺点：不能在 Business Acceptance 前阻止失效的最终验证，也无法解决实施前 record 的结构验证问题。

### 方案 C：每条 workflow 自行实现 Git 检查

分别在 Feature Dev、Bug Fix 和 Refactor 中写 shell 逻辑。

优点：局部直观。缺点：重复算法、容易漂移，违反当前共享 validator 的所有权。

## ✅ 选定方案

采用方案 A。

### 候选身份

每份最终系统/回归测试报告记录开始和结束时的：

- 完整 `HEAD` SHA、branch、`FINAL_IMPLEMENTATION_SHA`；
- 以 `FINAL_IMPLEMENTATION_SHA` 为基准、排除当前 run 目录后的 raw binary tracked diff object ID；
- 由同一 diff 是否为空得到的 `clean` 或 `dirty` 状态。

diff 使用 Git 原生 `git diff --binary` 输出并经 `git hash-object --stdin` 取身份；不得使用会归一化补丁内容的 `patch-id`。如果 `FINAL_IMPLEMENTATION_SHA` 不可达，身份无效。

### 分阶段验证

- 默认 validator 同时接受历史 `Artifact` 和规范 `Artifact Path` 表头；只有当实施记录实际存在且不是 `pending` 时才要求 Final Implementation SHA 与 changed-files 证据。
- 最终验证模式要求开始/结束快照一致，并在调用时重新计算 branch、`FINAL_IMPLEMENTATION_SHA` 与 tracked diff 身份。
- 从验证结束 `HEAD` 到当前 `HEAD` 的 first-parent 提交仅可为 manifest 中登记、且 tree diff 只涉及当前 run 证据目录的 checkpoint；其他提交使验证失效。
- 候选代码变化回到实施并重新 review/验证；branch、可达性或证据链问题至少回到最终验证阶段。

### Workflow 接入

Feature Dev、Bug Fix 与 Refactor 在写入最终测试报告后、进入 Business Acceptance 前和 Completion 前调用同一最终验证模式。报告、manifest 和三条 workflow 使用相同字段及回退语义。

## 受影响边界

- `src/workflows/feature-dev/SKILL.md`
- `src/workflows/bug-fix/SKILL.md`
- `src/workflows/refactor/SKILL.md`
- `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh`
- `tests/delivery-record-contract.sh`
- `tests/workflow-symmetry.sh`

不改变实施提交身份、风险传递、Refactor 行为基线或未跟踪文件语义。

## 验证策略

为 validator 增加实施前 manifest、历史表头兼容、快照缺失/不一致、final SHA 不可达、branch 或 tracked diff 变化、允许的证据 checkpoint、禁止的候选代码提交等 fixture。为三 workflow 增加对称性断言。最终运行相应契约测试、构建、全量检查与 whitespace 检查。

## Open Questions

无。
