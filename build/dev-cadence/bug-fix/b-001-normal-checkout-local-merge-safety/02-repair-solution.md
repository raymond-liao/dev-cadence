# B-001 普通 Checkout 本地 Merge 安全性：修复方案

## 状态

✅ `confirmed`

用户确认：“可以，继续”。该确认同时确认方案 A 和版本 `0.21.1`，允许进入 Repair Plan；实现仍需后续确认 Repair Plan。

## 方案来源

- [B-001 普通 Checkout 本地 Merge 安全性](../../../../docs/bugs/B-001-normal-checkout-local-merge-safety.md) Version `1`
- [问题诊断](01-problem-diagnosis-record.md)
- `.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`
- 当前代码基线：`9d5324475e3399624df461ce793395f230c24e86`

## 根因

本地 Merge 在用户选择完成方式时没有绑定不可变的交付提交身份。执行阶段重新解析可变的 feature branch 名称，因此可能合入完成门禁之后产生的提交；同时 local-only Merge 路径依赖 `git pull`，并且把测试通过当作主要结果证据，没有验证目标分支包含预期提交。

## 方案决策

### ✅ Selected：方案 A：在 Finishing 的本地 Merge 路径建立提交身份闭环

1. 在展示 Completion 选项前固定 base branch、feature branch 和 `EXPECTED_FEATURE_SHA`。
2. 执行 Merge 前确认当前 feature branch 仍指向 `EXPECTED_FEATURE_SHA`；如果分支已移动，停止本次 Merge，保留分支和工作区，要求重新经过完成门禁。
3. 普通 checkout 的 local-only Merge 不执行 `git pull` 或其他远程依赖，只使用已存在的本地 refs 和提交对象。
4. 如果预期 SHA 已经是 base 的祖先，记录 `already-integrated`；否则只对固定 SHA 执行 Merge，不再按 branch name 解析提交。
5. Merge、checkout、前置检查或结果验证任一步失败时停止，不清理 worktree、不删除任务分支、不报告完成。
6. 合并后验证 base 包含 `EXPECTED_FEATURE_SHA`，记录实际 base HEAD，并检查目标工作区状态符合预期；只有验证成功后才进入既有清理顺序。

### 方案 B：继续按 feature branch 合并，只增加测试和错误提示

不选。它可以改善错误可见性，但不能阻止 branch tip 在用户确认后移动，也不能证明实际合入的是已审查提交。

### 方案 C：只在 Dev Cadence Bug Fix Workflow 中增加包装规则

不选。缺陷位于 vendored Superpowers 的通用 Finishing Merge 路径，包装层无法可靠约束普通 checkout 的最终 `git checkout`、`git pull`、`git merge` 和清理动作；这会留下其他调用路径的同类风险。

## 修复点与边界

### ✅ 纳入范围

- 修改 `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md` 的 base/feature 身份捕获、本地 Merge、already-integrated、失败停止和合并后验证规则。
- 增加针对规则文本和最小 Git 行为的契约测试，覆盖固定 SHA、分支移动、离线 local-only、already-integrated、Merge 失败和结果验证。
- 通过 `bash scripts/build.sh` 同步 `dist/.dev-cadence`，通过安装契约验证分发包携带修复后的 vendored skill。
- 更新根目录 `version`；当前建议使用下一个兼容的修复版本 `0.21.1`，最终在 Repair Plan 确认。

### ❌ 不纳入范围

- 不修改远程 PR 合并策略、push、fetch 或 pull 请求流程。
- 不修改 detached HEAD Finishing；该路径由 `S-032 Detached HEAD Finishing` 负责。
- 不修改 Discard 路径；该路径由 `B-002 普通 Checkout Discard 安全性` 负责。
- 不修改 worktree 所有权识别、worktree 运行记录保存或清理所有权；只保留现有清理顺序，并要求清理只能发生在 Merge 结果验证之后。
- 不修改 `git-commit`、三个 Delivery Workflow 的业务阶段、用户确认门或 manifest 语义。
- 不直接编辑 `dist/.dev-cadence/**` 或 `.dev-cadence/vendor/**`；它们由构建或安装流程生成。

## 可能变更的文件

- Modify: `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`
- Add or modify: `tests/finishing-a-development-branch-contract.sh`，并在 `tests/run-all.sh` 接入
- Modify: `version`，从 `0.21.0` 更新到待确认的修复版本
- Generated: `dist/.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`
- Generated or installed verification target: `.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`

## 相关行为影响

- 正常本地 Merge 在等待期间发现 feature branch 移动时会停止，而不是静默合入新提交。
- 已经集成且身份未变化的任务会得到明确的 `already-integrated` 结果，并继续执行结果验证。
- 没有远程 tracking 信息或远程不可用时，纯本地 Merge 不再因 `git pull` 被阻断。
- Merge 失败或目标身份验证失败时，分支和工作区保留，用户不会得到完成声明。
- 现有测试门禁、四选一 Completion 菜单、成功后 cleanup 顺序和 detached HEAD 的三选一菜单保持不变。

## 修复验收标准

1. Completion 选项展示前记录 base branch、feature branch 和预期 feature SHA。
2. Merge 执行前发现 feature branch 指向不同 SHA 时不会执行 Merge 或清理。
3. local-only Merge 不调用 `git pull`、`git fetch` 或其他远程操作。
4. Merge 使用固定预期 SHA；预期 SHA 已在 base 中时报告 `already-integrated`。
5. checkout、前置状态检查、Merge 或后置身份验证失败时不会报告成功、删除分支或移除工作区。
6. 成功结果验证证明 base 是预期 SHA 的祖先，并记录实际 base HEAD 和工作区状态。
7. source、dist、安装结果和版本保持同步，完整契约检查通过。

## 必须保持不变的行为

- Merge 前仍必须先通过测试验证并获得用户选择。
- 用户选择 Keep As-Is 时不 Merge、不 Push、不清理。
- 用户选择 PR 时仍由用户明确授权 push，且不清理 worktree。
- Discard 仍使用其独立的精确 `discard` 确认，不被本 Bug 改写。
- Detached HEAD 仍不提供本地 Merge 选项。

## 风险与权衡

- 严格要求 feature branch 不得在确认后移动，会让并发追加提交必须重新进入 Completion，但这是避免未审查代码合入的明确代价。
- 仅验证预期 SHA 是 base 祖先不能单独证明没有额外提交，因此必须同时验证 feature branch 身份仍等于预期 SHA。
- “already-integrated” 是否允许自动继续分支清理，需要在实现中遵循已选择的 Completion 语义，并保留分支尖端身份检查。
- 该修复改变安装包内通用 Finishing 规则，必须更新版本并验证 source、dist、安装包同步。

## 回归验证范围

- 普通 checkout 的 Merge locally 成功路径。
- 无远程 tracking 或远程不可用的 local-only 路径。
- feature branch 在用户确认后移动的阻断路径。
- expected SHA 已在 base 中的 already-integrated 路径。
- checkout、Merge 冲突、身份验证失败时的保留现场路径。
- Keep As-Is、PR、Discard 和 detached HEAD 菜单及清理边界未被改变。

## 已确认事项

- 采用方案 A 的“固定 SHA + 分支移动即停止 + local-only Merge + 合并后身份验证”完整闭环。
- 版本从 `0.21.0` 更新为 `0.21.1`。

## 结论

当前 Repair Solution 已完成并确认，进入 Repair Plan；在计划确认前不修改实现文件。
