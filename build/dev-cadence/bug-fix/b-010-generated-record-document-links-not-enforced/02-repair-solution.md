# B-010 修复方案

- Workflow: `bug-fix`
- Work Item: [B-010 Generated Records Do Not Enforce Navigational Document Links](../../../../docs/bugs/B-010-generated-record-document-links-not-enforced.md)
- Card Version: `1`
- Diagnosis source: `build/dev-cadence/bug-fix/b-010-generated-record-document-links-not-enforced/01-problem-diagnosis-record.md`
- Decision: ❓ `pending`

## 根因与修复边界

S-010 增加了共享文档引用规则，但没有迁移三套 workflow 中更早存在的 `Code Review Evidence` 裸路径模板；现有测试只检查规则文字、文件名和目标存在性。修复边界是三处模板形态与确定性契约，不扩展为通用 Markdown 解析器或历史记录迁移。

## 方案比较

### 方案 A：模板修正 + 对称性契约 + 双表示 fixture（推荐，待确认）

将 Feature Dev、Bug Fix、Refactor 的 `Report` 行统一为有意义的相对 Markdown 链接，并在同一行保留反引号包围的完整仓库相对路径。强化 `tests/workflow-symmetry.sh` 对三套完整 `Report` 行的精确断言，并把 delivery fixture 更新为链接与精确路径双表示。保持 validator 不变，因为它已经从反引号路径读取审计身份。

该方案职责清晰，直接覆盖模板回归和机器解析兼容性，推荐采用。

### 方案 B：把模板断言放入共享 document-conventions 契约

同样修正三套模板和 delivery fixture，但由 `tests/document-conventions-contract.sh` 检查具体 `Code Review Evidence` 形态。可行，但会让共享语义测试拥有具体 workflow 模板知识，并可能与对称性测试重复。

### 方案 C：扩展 runtime validator 强制导航链接

让 `validate-delivery-record.sh` 解析实现记录中的 `Report` 字段并拒绝裸路径。它能约束运行时记录，但会扩大 validator 到本地化展示和 Markdown 结构解析，超出当前卡片范围并增加生命周期误报风险。

## 预计修改与影响

- 可能修改：`src/skills/feature-dev/SKILL.md`、`src/skills/bug-fix/SKILL.md`、`src/skills/refactor/SKILL.md`、`tests/workflow-symmetry.sh`、`tests/delivery-record-contract.sh`；通过 `bash scripts/build.sh` 同步 `dist/.dev-cadence`，并按安装包行为变化评估根目录 `version`。
- 不修改：`src/skills/document-conventions/SKILL.md`、`src/skills/using-dev-cadence/scripts/validate-delivery-record.sh`、Discovery、无关历史 records。
- 相关影响：三套生成模板的阅读导航和交付记录 fixture；审计路径解析、checkpoint、Changed Files 等现有 validator 行为保持不变。

## 必须保持不变

- 精确仓库相对路径继续作为机器可读审计身份；链接只负责阅读导航。
- 未创建目标继续使用 pending 与计划路径，不创建无效链接。
- 命令、配置、输出位置、代码示例、SHA 和 Changed Files 不机械转换为链接。

## 回归范围与验收标准

- 三套 `Report` 模板同时包含相对 `04-code-review-report.md` 链接和完整反引号路径。
- 任一模板回退为裸路径时对称性契约失败。
- 双表示 fixture 通过现有 validator，缺失 artifact、checkpoint tree、SHA、Changed Files 等负例仍失败。
- 计划回归：`tests/workflow-symmetry.sh`、`tests/document-conventions-contract.sh`、`tests/delivery-record-contract.sh`、`tests/package-contract.sh`、`scripts/check-all.sh`，并用 `rg --no-ignore` 检查 source/dist 同步。

## 风险与用户决策

主要风险是 shell 断言过宽或显示文本被错误锁定；通过锚定完整 `Report` 行、相对目标和 workflow-specific 路径缓解。需要用户确认是否采用方案 A；未确认前不创建 Repair Plan 或修改源码。
