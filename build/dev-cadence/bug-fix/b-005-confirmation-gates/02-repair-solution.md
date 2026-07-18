# B-005 修复方案

- Status: `confirmed`
- Work Item: [B-005 已安装 Workflow 用户确认门摘要、选项与结果语义不完整](../../../../docs/bugs/B-005-refactor-confirmation-options-missing.md)
- Diagnosis Source: [B-005 问题诊断记录](01-problem-diagnosis-record.md)
- Decision Authority: `delegated continuation authority from user instruction`

## 根因与修复边界

根因是六个 owning Workflow 只分散规定了“需要确认”或“展示完整提案”，没有形成可验证的会话级决策协议。修复只调整 Workflow skill 规则和契约测试，不修改 vendored Superpowers，不新增 Workflow 阶段、状态或通用终止语义。

## ✅ Selected 修复方法：分 Workflow 契约 + 语义契约测试

在六个 owning Workflow skill 中分别补充真实确认门的最低呈现契约：

1. 文件链接前必须先总结当前结论、范围、非范围、关键风险或未决问题。
2. 必须展示该门实际支持的明确选项，并说明下一阶段、资产写入、运行记录、状态和再次确认的影响。
3. Delivery Workflow 的前置阶段使用“确认当前版本并进入下一阶段”与“要求修改并停留当前阶段重提”的最小对称语义。
4. Asset Workflow 保留 Journey、Planning、Architecture 的部分确认、方案选择、迁移、拆分和 Decision Pending 等专用语义。
5. Business Acceptance、Completion、worktree consent、vendored 方案选择和执行模式选择继续由各自契约负责，不重复定义。

测试新增按语义断言的 `tests/confirmation-gates-contract.sh`，验证六个 Workflow 都具备摘要、选项、结果和专用边界，不锁定整段自然语言。

## 备选方案与取舍

### 共享入口规则

把全部确认门规则集中到 `using-dev-cadence`。未选择，因为确认门的业务语义属于各 owning Workflow，集中规则会遮蔽 Asset Workflow 的专用选项并扩大入口选择器职责。

### 单一通用菜单

为所有确认门复制同一组编号选项。未选择，因为它会把部分确认、方案选择、迁移、风险接受和 Decision Pending 误化为不存在的通用动作。

### ✅ Selected 分 Workflow 最小契约

选择此方案，因为它以最小重复补齐共同缺口，同时让每个 Workflow 继续拥有自己的确认内容和结果语义；契约测试只验证语义存在及边界，不绑定措辞。

## 受影响文件与边界

- 修改六个 `src/skills/*/SKILL.md` owning Workflow 规则。
- 新增 `tests/confirmation-gates-contract.sh`，并接入 `tests/run-all.sh`。
- 将根目录 `version` 从 `0.22.0` 提升为 `0.23.0`，作为本批次已安装规则变更的版本更新；后续 B-007、B-008 不重复递增版本。
- 运行 `bash scripts/build.sh` 同步本地 `dist/.dev-cadence`，不直接编辑或强制添加 `dist/`。

## 修复验收标准

- 六个 Workflow 的每个真实用户决策门都明确要求先摘要再给选项和结果影响。
- Delivery 三套前置阶段具备对称的确认/修改并停留语义。
- Asset Workflow 专用语义和 Business Acceptance/Completion 固定菜单未被削弱或重复。
- 新契约测试能在缺少摘要、选项、结果或边界语义时失败，并在修复后通过。
- 构建、安装包契约、工作流对称性、空白检查和全量检查通过。

## 保持不变

- 不取消用户确认门，不增加状态或阶段。
- 不修改 vendored Superpowers。
- 不把普通进度摘要、验证证据或澄清问题变成确认门。
- 不新增没有记录、状态或后续处理支撑的选项。

## 风险

- 六个 skill 的规则文字较长，需通过契约测试保持对称但避免机械复制。
- 版本只在 B-005 分支中递增一次，后续两项记录需明确继承该批次版本，避免合并时产生伪造的多次发布。

