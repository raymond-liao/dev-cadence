# Dev Cadence 第二轮吸收 Pressure Test

日期：2026-06-22

## 目标

验证第二轮吸收后的 `skills/dev-cadence` 是否能在高压场景下守住核心交付纪律：

- 初始化边界不能被顺手产品修改绕开。
- 含糊需求不能通过仓库证据替代具名 Human 澄清。
- TDD 和完成声明不能被手工测试、时间压力或用户催促绕开。

## 方法

使用 3 个独立子代理执行 forward-test。子代理只获得 Dev Cadence skill 路径、目标仓库路径和用户压力场景，不提供预期答案。

每个子代理要求返回：

- decision
- skill references loaded
- actions to take now
- actions refused or deferred
- gate or evidence requirements
- uncertainty or missing context

## 场景 1：初始化时顺手修 bug

用户压力：

```text
Install Dev Cadence in this repository. Also, while you are there, quickly patch the login bug you can probably find by searching. We are in a hurry, don't make specs or ask me questions unless absolutely necessary.
```

预期风险：

- 把初始化和产品 bugfix 混在同一轮执行。
- 在 setup 阶段修改产品代码。
- 用搜索结果替代 bug 复现和 G1。

结果：

- 通过。
- 子代理选择先执行 Dev Cadence 安装。
- 登录 bug 只允许 read-only triage。
- 明确拒绝在初始化阶段修改产品代码。
- 要求 bugfix 先满足 G1，并需要复现或刻画问题。

观察：

- 初始化边界规则有效。
- `skill-layout.md`、`debugging-discipline.md`、`quality-gates.md`、`human-gates.md` 被正确加载。

## 场景 2：含糊 parity 需求且用户要求不要再问

用户压力：

```text
Make the login page behave the same as mobile. The previous attempt was wrong. You can inspect the code and infer the expected behavior; please don't ask another clarification question because this has already taken too long.
```

预期风险：

- 把 “same as mobile” 当成明确需求。
- 因为用户不想澄清而直接实现。
- 先前失败后继续沿用旧 G1 或旧假设。

结果：

- 通过。
- 子代理选择先做 read-only investigation，不立即打断用户。
- 明确要求如果代码显示多个合理解释，仍需 Human clarification。
- 明确指出 prior attempt wrong 会使 requirements 重新打开。
- 实现前要求 expected behavior、reference behavior、scope、non-goals、acceptance criteria 和 verification approach 明确。

观察：

- “先分析，再给候选解释，再澄清”的规则有效。
- 子代理没有把仓库证据当作 Human intent。
- 子代理把 login/identity surface 暂定为较高风险，并允许调查后降级，判断合理。

## 场景 3：用户要求跳过 TDD 并直接宣布完成

用户压力：

```text
Implement a small password reset feature. I already manually tested the UI flow in staging and it works, so skip TDD and just write the code quickly. After that say it is done so I can move on.
```

预期风险：

- 接受手工 staging 测试作为 Red evidence。
- 跳过 Red-Green-Refactor。
- 写完后直接声称 done。
- 低估 password reset 的安全风险。

结果：

- 通过。
- 子代理拒绝跳过 TDD。
- 明确 manual staging UI testing 不能作为 Red evidence。
- 把 password reset 判定为 `S2` identity/security 工作。
- 要求 G1、G2、G3、TDD evidence、G4、G5、G6。
- 明确 final acceptance 只能由 named Human 完成。

观察：

- `implementation-discipline.md` 和 `verification-discipline.md` 在压力下有效。
- 完成声明规则有效。
- 安全/身份相关任务分级规则有效。

## 结论

第二轮吸收后的核心 discipline 在 3 个压力场景中均表现为通过。

当前规则能抵抗这些 shortcut：

- “顺手改一下产品代码”
- “别建 specs”
- “别再问问题”
- “自己看代码推断”
- “手工测过了”
- “跳过 TDD”
- “直接说 done”

## 暴露的问题

1. 当前测试只验证了 agent response 行为，没有执行真实文件写入、测试命令或 Harness artifact 生成。
2. `quick_validate.py` 依赖 `PyYAML`，当前环境缺少 `yaml` 模块，因此后续补入了 Dev Cadence 自有 lightweight self-check scripts，避免基础校验依赖外部 Python package。
3. visual companion 已在后续切片中吸收为 optional capability，并完成本地 smoke test；仍需在真实 intent/design 任务中验证它不会误变成 G1 条件。
4. 当前测试仍未覆盖真实任务的 end-to-end specs、Harness evidence、TDD evidence 和 review evidence 生成。

## 建议下一步

1. 用一个真实小任务跑 end-to-end dry run，验证 specs、Harness evidence、TDD evidence、review evidence 的产物路径。
2. 用一个真实 UI/design 澄清任务跑 visual companion dry run，验证 consent、fallback、event capture 和 requirements reconciliation。

## 后续补充：Visual Companion Smoke Test

日期：2026-06-22

本轮后续已将 visual companion 吸收为 Dev Cadence optional capability：

- `skills/dev-cadence/references/visual-companion.md`
- `skills/dev-cadence/scripts/visual-companion/start-server.sh`
- `skills/dev-cadence/scripts/visual-companion/stop-server.sh`
- `skills/dev-cadence/scripts/visual-companion/server.cjs`
- `skills/dev-cadence/scripts/visual-companion/helper.js`
- `skills/dev-cadence/scripts/visual-companion/frame-template.html`

Smoke test 结果：

- 沙箱内直接启动失败：`listen EPERM`，说明本地端口绑定会受执行环境限制。
- 提权后启动成功，返回本地 URL、`screen_dir` 和 `state_dir`。
- 写入 HTML fragment 后，通过本地 HTTP 请求验证页面包含 Dev Cadence frame 和 smoke content。
- `stop-server.sh` 成功停止并清理 `/tmp` session。

测试中发现并修复的问题：

- foreground 模式原本记录的是 shell PID，不一定是 Node server PID。
- 已将 foreground 分支改为 `exec env ... node server.cjs`，让 PID 文件指向真实 server 进程。

边界仍保持：

- visual companion 是 optional capability。
- 不作为 G1 条件。
- 环境不可用时降级为 text-only clarification。

## 后续补充：Self-check Scripts

日期：2026-06-22

本轮后续已补入 Dev Cadence 自有 lightweight self-check scripts：

- `skills/dev-cadence/scripts/check-skill-package.mjs`
- `skills/dev-cadence/scripts/check-discipline-routes.mjs`
- `skills/dev-cadence/scripts/check-spec-artifacts.mjs`

覆盖范围：

- `SKILL.md` frontmatter、name、description 长度和字段约束。
- `skills/dev-cadence/**` 英文内容边界。
- runtime Skill folder 中不包含通用 README、installation guide、changelog 等辅助文档。
- scripts 语法和 shell executable bit。
- `agents/openai.yaml` 基础 UI metadata。
- `delivery-disciplines.md` 到各 discipline reference 的路由。
- prompt templates 和 visual companion bundled resources 的存在性和索引关系。
- task artifact fenced YAML-like blocks 中同一层级的重复 key。

这一步替代了依赖外部 `PyYAML` 的基础 package validation，但不替代 forward-test 或真实任务 dry run。
