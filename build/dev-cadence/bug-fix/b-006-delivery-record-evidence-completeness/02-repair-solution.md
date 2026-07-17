# B-006 修复方案

- Status: `confirmed`
- Work Item: [B-006 Delivery 记录证据完整性](../../../../docs/bugs/B-006-delivery-record-evidence-completeness.md)
- Diagnosis Source: `build/dev-cadence/bug-fix/b-006-delivery-record-evidence-completeness/01-problem-diagnosis-record.md`
- Workflow: `bug-fix`
- Repair Branch: `codex/b-006-delivery-record-evidence-completeness`

## 用户确认

- Decision: `confirmed`
- User Feedback: `那可以，就按你的方案来`
- Confirmed At: `2026-07-17T18:17:23+0800`

## 修复目标

让新的 `feature-dev`、`bug-fix` 和 `refactor` 运行在进入终态前都具备可独立恢复的交付证据。权威证据必须来自 manifest、阶段记录、代码审查报告、测试报告和 Git 提交身份，不依赖会被清理的 SDD scratch 文件。

## 修复边界

### 1. 统一终态证据契约

对三个 Delivery Workflow 的实施记录、修复记录和重构记录统一规定：

- 存在已提交的实现或修复变更时，最终实现 SHA 与实际 Changed Files 必须同时存在；Changed Files 必须来自实际实现提交范围，不得为 `pending`。
- 没有 tracked 变更时，明确记录 `skipped: no tracked changes`，不得用空白或 `pending` 代替。
- Completion readiness 检查必须拒绝缺失、占位或互相矛盾的终态证据。

### 2. 绑定阶段记录与 checkpoint tree

每个阶段的 checkpoint 流程必须满足：

1. 先写入或更新当前阶段记录。
2. 创建只包含当前范围的阶段 checkpoint，使其 tree 包含该阶段记录及相关交付证据。
3. 读取 checkpoint tree，验证阶段记录路径确实存在，并验证记录中的提交身份可解析。
4. 更新 manifest，将阶段 checkpoint 绑定到已验证的 commit；如果 manifest 回填产生后续提交，必须保留前一个 commit 作为该阶段 checkpoint，而不是把未包含阶段记录的代码提交冒充 checkpoint。
5. 终态 manifest 不得保留 `pending` checkpoint。

阶段 checkpoint 与实现提交仍然是不同概念；本方案不改变现有实现提交审查 ledger 和阶段顺序。

### 3. 划清 SDD 临时证据边界

- 不再把 `sdd/progress.md` 或其他 ignored SDD scratch 路径作为最终实施、修复或重构记录的权威链接。
- 最终 Review 结论、修复提交和任务完成状态必须回填到对应的长期阶段记录和代码审查报告。
- SDD scratch 仍可用于活动运行期间恢复任务，但清理后不影响运行进入终态。

### 4. 增加真实运行记录验证

新增可复用的 Delivery record validator，并由契约测试覆盖：

- manifest 的阶段状态、artifact 路径和 checkpoint 值；
- 本地记录链接是否存在；
- 终态记录是否残留 `pending` 或空的 Changed Files；
- checkpoint commit tree 是否包含其阶段记录；
- 最终实现 SHA、Changed Files、Review 结论和测试结论是否一致；
- SDD scratch 不作为完成条件。

测试必须包含有效 fixture 和负例 fixture，分别证明合法记录通过，以及占位符、断链和错误 checkpoint 会失败。S-014 作为历史失败样本保留，不在本 Bug 中回写其历史记录或产品实现。

## 预计变更范围

- `src/skills/feature-dev/SKILL.md`
- `src/skills/bug-fix/SKILL.md`
- `src/skills/refactor/SKILL.md`
- 新增记录验证脚本及其契约测试
- `tests/run-all.sh` 的测试接入
- `version`、构建生成的分发包和必要的 source/dist 契约

不修改 Delivery 阶段顺序、用户确认门、状态枚举、S-014 产品设计或业务代码行为。

## 修复验收标准

1. 三套 Delivery Workflow 的终态记录契约对称，并且 committed-change 与 no-tracked-change 两种情况都有明确证据。
2. 新生成的阶段 checkpoint 能通过 Git tree 验证找到对应阶段记录；manifest 不再把不包含记录的代码提交标作该阶段 checkpoint。
3. 终态记录不依赖 `sdd/progress.md`，清理 SDD scratch 后仍能恢复最终 Review、实现范围和提交追踪。
4. 真实记录 validator 的正例通过，且能检测 `pending`、断链、错误 checkpoint tree 和遗漏最终 Review 的负例。
5. source、dist、版本和全部现有契约检查保持一致。

## 保持不变的行为

- 不改变 `feature-dev`、`bug-fix`、`refactor` 的业务阶段顺序。
- 不改变用户确认门的语义和固定选项。
- 不把 Business Acceptance 自动推导为已确认。
- 不修改应用业务代码或 S-014 历史运行记录。
- 不把 SDD scratch 强制变成长期提交资产。

## 备选方案与取舍

### 仅修正 S-014

不采用。只能修复一个历史样本，不能阻止三套 Workflow 继续生成同类不完整记录。

### 只增加静态规则文字

不采用。现有静态契约已经通过，但无法检测真实 commit tree 和记录链接，无法覆盖本 Bug 的主要失败模式。

### 将 SDD progress ledger 永久提交

不采用。会违反 vendored SDD 对 scratch 生命周期的设计，并把恢复细节错误提升为长期交付资产。

## 风险与用户决策

- 记录验证器需要解析当前 Markdown 记录契约；实施时必须优先复用现有文档和状态约定，避免引入第二套状态模型。
- 历史运行记录可能无法满足新契约；本次只阻止新的不完整终态，不回写 S-014。
- 需要用户确认本方案后，才能进入 Repair Plan 并开始测试和代码修改。
