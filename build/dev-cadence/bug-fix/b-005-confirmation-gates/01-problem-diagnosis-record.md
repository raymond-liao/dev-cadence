# B-005 问题诊断记录

- Status: `in_progress`
- Work Item: [B-005 已安装 Workflow 用户确认门摘要、选项与结果语义不完整](../../../../docs/delivery/bugs/B-005-refactor-confirmation-options-missing.md)
- Workflow: `bug-fix`
- Diagnosis Branch: `codex/b-005-confirmation-gates`
- Diagnosis Baseline: `ec0ee0c6b6dc07c30537c9fd1789c3af4165f6f3`

## 报告症状

已安装 Workflow 到达用户决策门时，部分提示只要求用户确认、选择或打开阶段文件，没有在会话中总结当前阶段结论，也没有完整说明每个可选决定会如何影响下一阶段、资产写入、运行记录和状态。

## 预期行为

每个真实用户决策门都应先提供当前阶段摘要，再列出该门实际支持的明确选项，并说明选择后的下一步和记录结果。完整阶段记录应作为可追溯证据链接，而不能替代会话摘要。不同 Workflow 的专用语义应保留，不应伪造不存在的停止、回滚或关闭选项。

## 实际行为

### 1. Discovery 的两个确认门缺少统一的会话级结果契约

Discovery 要求在 User Journey Confirmation 展示完整 Journey，在 Product Design Confirmation 展示完整 PRD 和 Business Architecture，但只规定“ask for explicit confirmation”，没有规定确认请求必须先摘要当前结论、范围、风险、未决问题，也没有定义确认/修改并停留等结果语义的最低呈现要求。证据：`src/skills/discovery/SKILL.md:351-355`、`src/skills/discovery/SKILL.md:377-397`。

### 2. Work Item Planning 的规划结果确认缺少门级选项和结果影响说明

Planning 规定确认前保留提案、确认后原子写入，但只描述 Planning Result Confirmation 的阶段目标，没有规定用户在确认请求中看到的当前摘要、候选变化、未决项和各选择对资产写入与保留内容的影响。证据：`src/skills/work-item-planning/SKILL.md:148-156`、`src/skills/work-item-planning/SKILL.md:322-330`。

### 3. Architecture Design 的确认请求只覆盖设计摘要，不覆盖所有结果边界

Architecture Design 要求展示输出路径、选项、关键决定和 Open Questions，但没有把每个实际选项对后续阶段、文档写入和 Decision Pending 的结果约束写成可检查契约。证据：`src/skills/architecture-design/SKILL.md:65-78`、`src/skills/architecture-design/SKILL.md:106-110`。

### 4. 三个 Delivery Workflow 的前置确认门没有共同的最小选择语义

Feature Dev、Bug Fix 和 Refactor 都要求用户确认需求、方案和计划，但这些阶段规则主要规定要呈现哪些内容与记录路径，没有明确要求“确认当前版本并进入下一阶段”和“要求修改并停留当前阶段重提”的结果语义。证据：`src/skills/feature-dev/SKILL.md:289-312`、`src/skills/bug-fix/SKILL.md:242-269`、`src/skills/refactor/SKILL.md:305-330`。

### 5. 测试只验证门存在，未验证门的语义闭环

基线 `bash tests/run-all.sh` 通过，但现有契约测试偏向检查 Workflow 段落、记录路径和固定菜单存在，没有对六个 Workflow 的“摘要、门、选项、结果”关系建立语义断言。因此规则缺口可在全绿测试下持续存在。

## 影响范围

直接影响 `discovery`、`work-item-planning`、`architecture-design`、`feature-dev`、`bug-fix` 和 `refactor` 的真实用户决策门。Business Acceptance 与 Completion 的既有固定菜单是独立契约，不属于本次诊断发现的缺口。问题影响用户能否在会话中作出可追溯决定和后续阶段能否正确推进，不直接改变业务代码运行时行为。

## 复现证据

1. 阅读六个 owning Workflow skill 的确认门规则，能够找到“要求确认”或“展示完整文件内容”的要求。
2. 对照各自的阶段边界，无法为所有真实确认门找到同时覆盖阶段摘要、明确选项和选择结果影响的共同契约。
3. 运行 `bash scripts/build.sh` 后执行 `bash tests/run-all.sh`，现有测试全部通过，证明当前测试不能捕获该语义缺口。

## 根因分析

### RC-001：确认门只定义了触发点，没有定义会话级决策协议

- 证据：各 Workflow 以“ask for explicit confirmation”或显示文件/提案为主要约束，门前摘要、选项与结果影响没有形成共同的可验证契约。
- 结果：不同代理会用不同粒度提示用户，文件路径可能被误当作确认内容，用户无法快速判断自己确认的范围和后果。
- 置信度：高。

### RC-002：领域专用选项与通用前置门语义没有分层

- 证据：Discovery、Planning、Architecture 有方案选择、部分确认、迁移或 Decision Pending 等专用语义；Delivery 前置阶段则没有对称的最小结果语义。
- 结果：简单增加一个通用菜单会丢失业务语义，现行测试也无法阻止“看似有选项、实际没有支撑”的虚假选项。
- 置信度：高。

### RC-003：契约测试验证结构而非决策闭环

- 证据：基线测试通过，但没有逐 Workflow 验证摘要、选项、结果与后续处理的一致性。
- 结果：规则文本看起来完整，但真实确认门仍可能只要求“确认”。
- 置信度：高。

## Bug 确认结论

当前证据足以确认这是跨六个已安装 Workflow 的真实规则与契约测试缺陷，不是单个会话提示或 Refactor 单点问题。修复边界应保持 Business Acceptance、Completion、各 Asset Workflow 专用选择语义和既有终态契约不变。

## 当前未决问题

- Repair Solution 需要为六个 Workflow 的确认门分别定义最小摘要字段、选项和结果影响，不能直接复制一套菜单。
- Repair Solution 需要决定契约测试采用按语义断言的最小共享 helper，还是在各 Workflow 测试中保留独立断言；不得锁定整段自然语言。

## 2026-07-18 回归复核

- 新症状：S-017 的 Business Acceptance 用户提示未展示固定编号选项，运行记录却使用 delegated continuation 形成验收结论。
- 新证据：三个 Delivery skill 虽列出固定菜单，但没有要求摘要与完整菜单必须在同一条消息中展示，也没有禁止 delegated continuation 代替 Business Acceptance 或 Completion 决策。
- 根因补充：原契约测试只覆盖前置确认门，不能捕获终态菜单呈现和委托边界。
- 结论：原实现的前置确认门修复仍有效，但终态提示契约不完整；原 Regression Verification 与 Business Acceptance 对当前回归不再有效。
