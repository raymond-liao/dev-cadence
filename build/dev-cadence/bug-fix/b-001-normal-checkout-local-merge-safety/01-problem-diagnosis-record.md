# B-001 普通 Checkout 本地 Merge 安全性：问题诊断

## 状态

✅ `confirmed`

用户确认：“没问题，继续”。该确认允许进入 Repair Solution；Repair Plan 和实现仍需后续分别确认。

## 诊断来源

- [B-001 普通 Checkout 本地 Merge 安全性](../../../../docs/bugs/B-001-normal-checkout-local-merge-safety.md) Version `1`
- `.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`
- 基线检查：`bash scripts/check-all.sh`，结果为通过
- 隔离临时 Git 仓库中的最小行为复现

## 报告症状

普通 checkout 选择本地 Merge 后，Finishing 规则没有在用户选择 Merge 时固定“本次要合入的具体提交”。执行阶段再次按照可变的 base branch 和 feature branch 名称操作，并且先执行依赖远程的 `git pull`。合并后只要求运行测试，没有要求验证目标分支包含预期提交。

## 预期行为

本地 Merge 必须只处理用户在完成门禁时确认的目标分支、任务分支和预期提交。远程不可用不应阻断纯本地合并；如果预期提交已经在目标分支中，应得到明确的已集成结果；如果身份、前置条件或合并结果无法验证，应停止并保留现场，不能报告完成或进入清理。

## 实际行为

当前 vendored finishing 规则：

1. 通过 `git merge-base HEAD main` 或 `master` 推测 base，但没有持久化任务分支和预期 feature SHA。
2. 用户选择本地 Merge 后执行 `git checkout <base-branch>`、`git pull`、`git merge <feature-branch>`。
3. `git pull` 在没有远程跟踪信息的本地仓库中失败；规则没有定义一个独立的 local-only 分支路径。
4. `git merge <feature-branch>` 在执行时解析 feature branch 当前尖端，而不是用户完成门禁时观察的提交。
5. 合并后的验证只运行测试，没有验证目标分支是否包含预期 SHA，也没有验证任务分支是否在预期 SHA 之后产生了额外提交。

## 影响范围

- 可能把用户未审查的后续提交一并合入目标分支。
- 远程不可用或没有 tracking 配置时，纯本地交付可能被错误阻断。
- feature 已经集成、feature 分支已移动或 merge 只产生无操作结果时，系统缺少明确的结果分类和 SHA 证据。
- 如果后续清理继续执行，可能删除仍包含未合入提交的任务分支引用。
- 最终记录可能声称“已 Merge 且测试通过”，但没有证明目标分支包含本次确认的交付版本。

本 Bug 只涉及普通 checkout 的本地 Merge；不包含远程 PR、detached HEAD Finishing 或 Discard 路径。

## Bug 分类

✅ 已确认是 Bug，而不是预期行为变更。卡片 Version `1` 已给出明确的安全预期和验收标准；问题在于执行规则没有兑现这些预期。

## 复现信息

### 环境

- Repository: `dev-cadence`
- Branch: `codex/b-001-normal-checkout-local-merge-safety`
- Commit: `9d5324475e3399624df461ce793395f230c24e86`
- Runtime: 本地 Git 命令行；临时复现仓库无远程 tracking 配置
- Configuration: `output_language: zh-CN`，worktree 已启用

### 复现步骤

1. 创建 `main` 和 `feature` 两个分支。
2. 在 `feature` 上创建用户完成门禁时应合入的 `reviewed_sha`。
3. 在用户选择 Merge 之后，再向同一 `feature` 分支追加 `unreviewed_follow_up`，使分支尖端移动到 `feature_tip_at_merge`。
4. 按当前规则切换到 `main`，执行 `git pull`，再执行 `git merge feature`。
5. 检查目标分支的 HEAD 与祖先关系。

### 复现结果

- `git pull` 返回状态 `1`，提示当前分支没有 tracking information。
- 随后 `git merge feature` 返回状态 `0`，目标分支移动到了后来的 `feature_tip_at_merge`。
- `reviewed_sha` 和后续 `feature_tip_at_merge` 都成为目标分支祖先；因此当前规则不能区分“确认版本已合入”和“未审查后续提交也被合入”。
- 该复现没有依赖网络，也没有修改目标仓库；临时仓库只用于验证命令序列。

## 根因假设与证据

### 根因假设

根因是本地 Merge 的对象身份只由执行时的 branch name 解析决定，缺少从完成门禁到实际 Merge 的不可变提交身份绑定；同时规则把 remote-aware `git pull` 放进 local-only Merge 路径，并把“测试通过”当成了 Merge 结果验证的主要证据。

### 证据

- `finishing-a-development-branch` 的 base 检测只记录 merge-base 结果，没有固定待合入提交。
- 本地 Merge 命令使用 `git merge <feature-branch>`，因此会读取执行时的 branch tip。
- 同一命令序列在临时仓库中复现了 tracking 缺失导致的 `git pull` 失败，以及随后仍可成功合入移动后的 feature tip。
- 当前规则的合并后步骤只有测试命令，没有 `git merge-base --is-ancestor <expected-sha> <base-branch>` 或等价的目标身份验证。

### 置信度

高。规则文本和最小 Git 行为复现相互一致；尚未进入修复，因此没有把修复方案当作诊断证据。

## 开放问题与假设

- 假设“预期 SHA”是完成门禁时已经通过当前 Workflow 审查、测试和用户决策的任务分支提交，而不是执行 Merge 时重新解析的 branch tip。
- 需要在 Repair Solution 阶段明确：任务分支在完成门禁后如果发生移动，是停止并要求重新确认，还是只合入已固定 SHA 并保留后续分支内容。
- 需要在 Repair Solution 阶段明确：already-integrated 且任务分支没有额外提交时，是否允许按用户已选择的 Merge 路径继续清理；本诊断阶段不预先决定该策略。

## 结论

`B-001 普通 Checkout 本地 Merge 安全性` 的问题已完成根因诊断，当前可以进入 Repair Solution。进入下一阶段前需要用户确认本诊断记录。
