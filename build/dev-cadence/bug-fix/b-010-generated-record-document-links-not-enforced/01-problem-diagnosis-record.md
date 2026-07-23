# B-010 问题诊断记录

- Workflow: `bug-fix`
- Work Item: [B-010 Generated Records Do Not Enforce Navigational Document Links](../../../../docs/delivery/bugs/B-010-generated-record-document-links-not-enforced.md)
- Card path: `docs/bugs/B-010-generated-record-document-links-not-enforced.md`
- Work-item type: `Bug`
- Card Version: `1`
- Visible Status: `In Progress`
- Selected scope: 修正 Feature Dev、Bug Fix、Refactor 生成记录模板中的裸路径导航示例，并补充确定性契约验证
- Status: ✅ `confirmed`
- Branch: `codex/parallel-b012-b010-b014`
- Diagnosis date: `2026-07-19`
- User confirmation: `confirm current version and advance to the next stage`
- Confirmed by: `Raymond Liao <raymond-liao@outlook.com>`
- Confirmed at: `2026-07-19T15:18:41+08:00`

## 报告症状

共享 `document-conventions` 已要求现有仓库文档的阅读导航使用 Markdown 链接，并在需要审计身份时同时保留精确仓库相对路径；但 Feature Dev、Bug Fix 和 Refactor 的 `Code Review Evidence` 模板仍示范裸路径，现有契约测试仍全部通过。

## 期望行为

当代码审查报告已经创建且由 implementation、repair 或 refactor record 用于阅读导航时，`Report` 字段应包含有意义的 source-relative Markdown 链接；同一字段需要审计身份时，应同时保留反引号包围的完整仓库相对路径。

## 实际行为

以下三处模板只展示裸 `build/dev-cadence/.../04-code-review-report.md`：

- `src/skills/feature-dev/SKILL.md` 第 632 行；
- `src/skills/bug-fix/SKILL.md` 第 592 行；
- `src/skills/refactor/SKILL.md` 第 671 行。

三个 workflow 的前文均已接入共享文档引用规则，并明确要求记录链接报告，因此模板示例与同一 skill 的规范要求直接矛盾。

## 复现与证据

1. 运行 `bash tests/document-conventions-contract.sh` 和 `bash tests/delivery-record-contract.sh`，两者均通过。
2. 使用精确正则搜索三套 workflow 的 `- Report: build/dev-cadence/.../04-code-review-report.md`，三处均命中。
3. 反向搜索 `Markdown link + 精确仓库相对路径` 的模板形态，三处均未命中。
4. `tests/document-conventions-contract.sh` 第 125-189 行只验证共享规则文字存在，第 209-245 行只验证 workflow 提及共享规则和完成前检查，不验证模板字段形态。
5. `tests/workflow-symmetry.sh` 第 641-645 行只验证三套 workflow 都包含 `Code Review Evidence` 和 `04-code-review-report.md`，因此三者对称地错误仍会通过。
6. `tests/delivery-record-contract.sh` 的 repair fixture 没有 `Code Review Evidence`；所谓 invalid-link 场景检查的是目标文件缺失，不检查 Markdown 导航链接。
7. `src/skills/using-dev-cadence/scripts/validate-delivery-record.sh` 第 97-145 行只从 Artifact 单元格的反引号中提取审计路径并验证文件和 checkpoint，不检查导航链接；现有 B-006 双表示记录能通过 validator，证明链接与精确路径并存兼容当前解析逻辑。

## 影响范围

- Feature Dev、Bug Fix、Refactor 三套对称的源模板。
- 构建生成的 `dist/.dev-cadence` 和目标仓库安装包。
- 文档引用、workflow 对称性、交付记录验证相关契约测试。

不需要扩展到 Discovery，不批量改写历史 workflow records，不把命令参数、配置值、输出位置、计划路径或机器身份机械转换为链接。

## 根因与置信度

根因已确认：S-010 增加了共享文档引用规范和“规则存在”测试，但没有迁移三处更早存在的 `Code Review Evidence` 模板；测试只检查规则文字、文件名或目标存在性，没有检查受治理模板的 Markdown 导航字段形态。

置信度：高。

## 未决问题与假设

- 无阻塞性业务问题。
- 修复方案阶段需要确定契约断言在 `document-conventions-contract`、`workflow-symmetry` 和 delivery fixture 之间的职责分配，但不需要引入完整 Markdown AST。
- 本诊断不选择最终测试拆分，也不修改源码、测试或历史记录。
