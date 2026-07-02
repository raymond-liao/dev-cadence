# Skill 能力对标改造计划

## 背景

Dev Cadence 的 Skills 最初参考了 superpowers 的 Skills，但当前实现存在明显问题：不少 Skill 只保留了 Dev Cadence 的 Supervisor、Harness、Gate 外壳，缺少原 Skill 中真正约束 Agent 行为的操作细节、停手机制、反模式、示例和验证规则。

本计划的目标不是把 superpowers 原文机械复制进 Dev Cadence，而是保证 Dev Cadence 的 Skill 在能力强度上不低于对应 superpowers Skill，并且仍然符合 Dev Cadence 的架构边界。

## 对标原则

每个 Skill 改造时必须同时满足以下标准：

1. 结构适配 Dev Cadence：保留 `using-dev-cadence` Supervisor、Harness evidence、Quality Gate、Human Gate 和 artifact 规则。
2. 能力不弱于参考 Skill：保留参考 Skill 的核心流程、硬规则、红旗、停止条件、失败处理和关键示例。
3. 参考来源同时覆盖 superpowers 源码态和安装态：
   - 源码态：`/Users/raymond/git/github/superpowers/skills`
   - 安装态：`/Users/raymond/.codex/plugins/cache/openai-api-curated/superpowers/3fdeeb49/skills`
4. 当源码态和安装态不同，先记录差异，再判断采用哪一版；不能只看单一来源后直接改。
5. Progressive disclosure 不能滥用：只被一个 Skill 使用、且属于该 Skill 核心方法论的内容，优先放回该 Skill 的 `SKILL.md` 或 Skill-local 文件；不要塞进全局 `references/`。
6. 全局 `references/` 只放跨 Skill 共享的规则、协议和 artifact/gate/harness 契约。
7. 不做空洞压缩：不能只保留口号，例如 “find root cause” 或 “write failing test”；必须保留 Agent 容易违反规则时的具体防护。
8. 不做“能力点摘要式确认”：对标时必须检查文件级结构和行为触发力。参考 Skill 中用于阻止 Agent 偷懒的 anti-pattern、gate function、示例、✅/❌ 标记、quick reference、red flags、stop condition 等，如果是行为约束的一部分，不能因为“内容摘要里提到了”就删掉或压扁。
9. 可回归检查：每次改造都要补或更新检查，至少覆盖关键章节、强制短语、引用关系和包边界。
10. 中文/英文边界不变：`docs/**` 用中文；发布用 `skills/**`、`references/**`、`templates/**`、`scripts/**` 用英文。
11. 发布产物不能出现其他产品或上游项目的信息。`superpowers`、其 Skill 名称、来源路径和对标关系只允许出现在本文档和 `docs/archive/**` 历史记录中；不得写入 `skills/**`、`references/**`、`templates/**`、`scripts/**`、`.codex-plugin/**` 或目标仓库 runtime。
12. 不为了存储记录给具体 Skill 增加不必要能力：参照 `cadence-plan` 的实现，具体行为 Skill 应输出可交接的内容、字段、证据和风险；持久 artifact 写入、记录更新、Harness evidence capture 和 gate 状态记录由 Supervisor/Harness 或明确的同步/验证路径负责。对标时要检查是否有 Skill 因“方便记录”而获得了超出行为纪律的写入、更新或记录职责。

## 内容归属规则

当前 `references/` 有一类问题：一些内容看起来只是为了让 `SKILL.md` 变薄而被移走，但并没有被多个 Skill 复用。这会降低 Skill 自包含程度，也会让 Agent 激活 Skill 后看不到足够强的行为约束。

后续改造按以下归属规则执行：

| 内容类型 | 应放位置 | 说明 |
|---|---|---|
| Skill 的触发条件、硬规则、必做步骤、停手机制、红旗、常见偷懒理由 | `skills/<skill>/SKILL.md` | Agent 激活 Skill 后必须立即看到。 |
| 只服务单个 Skill 的长示例、prompt 模板、脚本说明、视觉辅助说明 | `skills/<skill>/...` | 保持 Skill-local，不放全局 `references/`。 |
| 两个或更多 Skill 共同使用的规则 | `references/` | 例如 Harness、Quality Gate、Human Gate、Context Pack、artifact schema。 |
| 全局 workflow、task class、Supervisor routing、repo contract | `references/` | 属于 Dev Cadence 框架协议，不属于单个 Skill。 |
| 维护 Dev Cadence 自身 Skill 的资料 | `references/source-maintenance/` | 不进入目标仓库 runtime。 |

因此，像 `cadence-debug` 当前把大量只属于 debugging 的方法论拆进 `references/debugging-discipline.md`、`root-cause-tracing.md`、`condition-based-waiting.md`、`defense-in-depth.md` 的情况，需要重新评估：

- 如果只由 `cadence-debug` 使用，应优先内联进 `skills/cadence-debug/SKILL.md` 或移动到 `skills/cadence-debug/` 下的 Skill-local 资源。
- 如果 `cadence-tdd`、`cadence-executing-plans`、`cadence-code-review` 等也会稳定复用，才保留在全局 `references/`。
- 不允许为了“看起来模块化”而牺牲 Skill 激活后的行为强度。

## 记录/存储能力边界复核

`cadence-plan` 的新边界作为后续复核基准：Skill 负责产出 implementation plan content，以及可被 Supervisor/Harness 放入 `03-tasks.md`、`04-test-plan.md` 的内容；它不直接拥有 artifact 写入、记录更新、gate 状态写入或执行 Skill 选择权。

后续需要对 `cadence-plan` 之外的所有 Dev Cadence Skill 做一次横向检查，判断是否存在“为了存储记录而支持了不必要能力”的责任漂移。检查重点：

- 具体行为 Skill 是否写成了直接 `write`、`update`、`record` 持久 artifact、Harness evidence、gate status 或 acceptance record。
- Skill 是否只是需要返回 handoff fields，却被描述成记录拥有者。
- Skill 是否因为要写记录而引入了 artifact 路径、schema 或状态流转细节，削弱了自身行为纪律。
- `recording`、`artifact-ready`、`Supervisor/Harness recording` 等 wording 是否仍然表达“交接给 Supervisor/Harness”，而不是由该 Skill 执行持久写入。
- 例外 Skill 是否确实属于 Supervisor、Harness、sync、verify 或 artifact authoring 路径；如果不是，应改成返回 outcome、evidence、skipped checks、residual risk 和需要记录的字段。

本轮先只把复核项纳入计划，不修改各 Skill 内容。实际处理时逐个 Skill 给出：当前 wording、是否越界、建议改法、需要同步的 regression check。

## 对标完成定义

一个 Skill 完成对标，必须满足：

- 有明确对应的参考 Skill，或明确说明 Dev Cadence 自有 Skill 不需要外部对应。
- `SKILL.md` 里有足够强的触发条件、核心规则、必做步骤、禁止事项和 Supervisor handoff。
- 详细规则放在恰当位置：单 Skill 核心规则留在该 Skill；跨 Skill 共享协议才放全局 reference；`SKILL.md` 明确何时加载额外资源。
- superpowers 参考 Skill 中会防止 Agent 偷懒的内容没有被削弱，包括 iron law、red flags、common rationalizations、stop conditions、review/verification checkpoints 等。
- 配套 reference/script 不是只按主题覆盖；其原本依赖的结构、示例、✅/❌ 对照、gate function、quick reference 和 red flags 已保留或用同等强度的 Dev Cadence 版本替代。
- 已完成记录/存储能力边界复核：具体行为 Skill 没有因为 artifact/Harness 记录需求而获得不必要的写入、更新或记录职责；必要的记录字段以 handoff 形式返回。
- 已对比 superpowers 源码态和安装态，并记录采用依据。
- `scripts/check-discipline-routes.mjs` 或其他测试能防止关键章节再次被删空。
- `bash tests/run-all.sh` 通过。

## 状态标识

- Checkbox：`[x]` 表示该 Skill 的本轮改造已完成；`[ ]` 表示仍需处理。
- 能力标识：`✅` 表示已确认 Dev Cadence Skill 不弱于对应 superpowers Skill；`❌` 表示尚未确认；`N/A` 表示无直接对应 superpowers Skill，只做 Dev Cadence 内部一致性 review。

## 对照表

| 完成 | Dev Cadence Skill | 参考 superpowers Skill | 能力 | 当前判断 | 改造重点或完成说明 |
|---|---|---|---|---|---|
| [x] | `using-dev-cadence` | `using-superpowers` | ✅ | 已完成 | 已确认源码态与安装态基本一致，源码态新增更多平台工具映射但不进入 Dev Cadence runtime；已强化 platform-neutral Skill activation contract、small-chance mandatory activation、before-any-response/action、activation sequence、process Skill priority、rationalization red flags、questions-as-tasks 和 Worker dispatch boundary，同时保留用户/仓库指令优先级、Supervisor routing、Harness/Gate/Human acceptance 边界。 |
| [x] | `cadence-clarify` | `brainstorming` | ✅ | 已完成 | 已确认 markdown 以源码态为主、visual companion scripts 以安装态为主，并单独适配源码态首屏 auto-open 能力；已保留 hard gate、just-in-time visual companion、one-question flow、2-3 approaches、design approval、spec self-review、Human artifact review 和 planning handoff，并完成 Dev Cadence 命名、目录、URL fallback 和 Supervisor handoff 适配。 |
| [x] | `cadence-plan` | `writing-plans` | ✅ | 已完成 | 已确认源码态与安装态基本一致，源码态新增 Global Constraints、Interfaces 和 task right-sizing 细节更完整，采用源码态并做 Dev Cadence 适配；已补 executable-plan hard rule、scope decomposition、file structure planning、task right-sizing、plan header/shape、task structure、no placeholders、test-plan mapping、self-review 和 Supervisor execution handoff；plan reviewer prompt 已按单 Skill 资源归属移动到 `skills/cadence-plan/`。 |
| [x] | `cadence-executing-plans` | `executing-plans` | ✅ | 已完成 | 已确认源码态与安装态基本一致，源码态仅平台说明更完整；以短 Skill 形式覆盖 critical plan review、按任务顺序执行、verification failure 停手、blocker handling 和 handoff；明确它只是 implementation execution discipline，不能选择其他 Skill、标记 gate 完成或替代 Supervisor。 |
| [x] | `cadence-subagent-development` | `subagent-driven-development` | ✅ | 已完成 | 已确认源码态比安装态新增 pre-flight plan review、task brief/report file handoff、progress ledger、task reviewer 合并 review 和 final review 包装细节；Dev Cadence 采用其 fresh Worker、continuous execution、status handling、file handoff、task-scoped reviewer、prompt construction、review anti-pattern 和 red flags 的行为强度，但不继承 commit、worktree、final branch finishing 或 record-owning 语义；已补 Skill-local implementer prompt、task reviewer prompt、`sdd-workspace`、`task-brief`、`review-package`，目录使用 `.dev-cadence/sdd/`；local progress ledger 只作 resume map，不作 gate/acceptance/persistent evidence；implementation discipline evidence 由 Supervisor-selected context 传入，不在本 Skill 硬编码 TDD 证据词。 |
| [x] | `cadence-dispatch-parallel` | `dispatching-parallel-agents` | ✅ | 已完成 | 已确认源码态与安装态基本一致，源码态补充了“同一响应并行 dispatch”的平台无关说明；Dev Cadence 采用其 independent-domain gate、when-to-use/when-not-to-use、focused self-contained prompt、common mistakes 和 integration verification 行为强度，并适配 Supervisor 控制、Harness handoff、gate-relevant observations 和不直接记录 gate/status 的边界。 |
| [x] | `cadence-tdd` | `test-driven-development` | ✅ | 已完成 | 已确认 TDD iron law、RED 失败证据、事后实现处理、good tests、rationalizations、stuck handling、debug integration 和 testing anti-patterns 能力不弱于对应 Skill。 |
| [x] | `cadence-debug` | `systematic-debugging` | ✅ | 已完成 | 已确认 root-cause-first hard rule、四阶段调试、假设验证、失败后升级、human correction signals、common rationalizations、示例代码语言边界、root-cause tracing、condition-based waiting、defense-in-depth 和污染定位脚本能力不弱于对应 Skill，并保持 debugging 技术文件为 Skill-local 资源。 |
| [x] | `cadence-request-code-review` | `requesting-code-review` | ✅ | 已完成 | 已确认 review 触发时机、精确上下文、只读 reviewer、必须检查实际 diff/files/evidence、reviewer prompts、severity、明确 verdict、spec compliance 和 code quality 两阶段 review 能力不弱于对应 Skill。 |
| [x] | `cadence-code-review` | `receiving-code-review` | ✅ | 已完成 | 已确认源码态和安装态基本一致，只有上游私人口令/CLAUDE wording 差异不进入发布内容；已收窄为 code review feedback handling，并保留 verify-before-implement、禁止表演式同意、unclear feedback 停手、source-specific handling、YAGNI check、pushback、correct-feedback response、pushback correction、common mistakes、逐项处理、GitHub thread reply 和 code re-review handoff；非代码反馈回 Supervisor 按 intent/design/implementation/evidence 重新分类。 |
| [x] | `cadence-verify` | `verification-before-completion` | ✅ | 已完成 | 已补 no completion claims without fresh evidence、gate function、claim matrix、red flags、rationalization prevention、key patterns、when-to-apply、bottom line，并保留 Human acceptance/report 规则。 |
| [ ] | `cadence-research` | 无直接对应 | N/A | Dev Cadence 自有 | 保留，后续只做 internal research-spike、workflow、artifact、Human decision 边界一致性 review。 |
| [ ] | `cadence-sync` | 无直接对应 | N/A | Dev Cadence 自有 | 保留，后续只做 repo contract、目标仓库 runtime 和同步脚本边界 review。 |

暂不处理：

- `using-git-worktrees`：用户已明确当前先不需要。
- `finishing-a-development-branch`：Dev Cadence 当前不接管 merge/PR/worktree lifecycle；只在未来明确需要时再设计等价 Skill。
- `writing-skills`：它是维护 Dev Cadence 自身 Skills 的方法论，已归入 source-maintenance 方向；不作为目标 runtime Skill。

## 改造顺序

### P0：先补最容易导致错误行为的纪律类 Skill

- [x] ✅ `cadence-debug`
   - 风险：当前薄壳容易导致 Agent 在未定位根因前直接修。
   - 参考：源码态和安装态的 `systematic-debugging`、其配套 `root-cause-tracing`、`condition-based-waiting`、`defense-in-depth`。
   - 产出：已强化 `SKILL.md`；debug-only 技术文件已保留在 `skills/cadence-debug/`；已补检查覆盖 hard rule、四阶段、red flags、示例代码语言边界、condition-based waiting quick patterns、固定延迟边界和 defense-in-depth 四层结构。

- [x] ✅ `cadence-tdd`
   - 风险：当前只描述 Red-Green-Refactor，不足以阻止跳过 RED 或事后补测试。
   - 参考：`test-driven-development`。
   - 产出：强化 implementation discipline、testing anti-patterns 和检查。

- [x] ✅ `cadence-verify`
   - 风险：Agent 容易在没有新鲜验证证据时声称完成。
   - 参考：`verification-before-completion`。
   - 产出：强化 completion claim gate、claim matrix、rationalization prevention。

### P1：补执行和 review 链路

- [x] ✅ `cadence-plan`
   - 参考：`writing-plans`。
   - 产出：已强化 executable-plan hard rule、file structure planning、task right-sizing、plan document shape、task structure、no placeholders、test-plan mapping、self-review 和 execution handoff；保留 Dev Cadence 的 Supervisor/Harness artifact-ready handoff 边界，不直接拥有 artifact 写入职责；`plan-document-reviewer.md` 已作为 `cadence-plan` Skill-local prompt 保留。

- [x] ✅ `cadence-executing-plans`
   - 参考：`executing-plans`。
   - 产出：已强化执行前 plan review、按任务顺序执行、验证失败停手、blocker handling 和 handoff；保持短 Skill 形态，只应用 Supervisor-selected execution context，不由 plan 或自身选择其他 Skill，不标记 gate 完成。

- [x] ✅ `cadence-subagent-development`
   - 参考：`subagent-driven-development`。
   - 产出：已补 fresh Worker per task、continuous execution stop conditions、pre-flight plan review、focused context construction、file-based task brief/report/review package handoff、Skill-local implementer prompt、Skill-local task reviewer prompt、Skill-local `sdd-workspace`/`task-brief`/`review-package` scripts、local progress ledger resume 语义、status handling、task-scoped review、reviewer prompt construction、red flags 和 handoff；明确不并行派发、不默认 commit、不写 persistent records、不标记 gate 或 final acceptance，也不直接引用其他 Skill prompt 或硬编码 TDD 证据词。

- [x] ✅ `cadence-dispatch-parallel`
   - 参考：`dispatching-parallel-agents`。
   - 产出：已强化 parallel dispatch gate、when-to-use/when-not-to-use、prompt structure、same-step/tool-batch dispatch、common mistakes、Worker summary distrust、actual diff/artifact inspection、systematic Worker error spot-check、integrated verification 和 Supervisor handoff；保持为并行 Worker 编排纪律，不拥有 gate/status 或 persistent record 写入职责。

- [x] ✅ `cadence-request-code-review`
   - 参考：`requesting-code-review`。
   - 重点：已确认 review 触发时机、上下文构造、只读 reviewer、实际 diff/files/evidence 检查、reviewer prompt、severity、明确 verdict 和反馈处理边界。

- [x] ✅ `cadence-code-review`
   - 参考：`receiving-code-review`。
   - 产出：已强化 code review feedback reception response pattern、forbidden responses、YAGNI gate、pushback/correction handling、common mistakes、Supervisor handoff 和 code re-review 边界；非代码反馈不在此 Skill 处理。

### P2：复核入口和自有 Skill

- [x] ✅ `using-dev-cadence`
    - 参考：`using-superpowers`。
    - 产出：已强化 platform-neutral Skill activation contract、“任何小概率适用都必须先进入 Supervisor”的不可协商规则、activation sequence、process Skill first、反 rationalization red flags、questions-as-tasks 和 Worker dispatch boundary；不引入上游平台工具映射 references，保留用户/仓库显式指令优先于 Dev Cadence discipline 的边界，不让 Supervisor 覆盖 Worker prompt 或 Harness controller。

- [x] ✅ `cadence-clarify`
    - 参考：`brainstorming`。
    - 重点：已按特例确认，markdown 以源码态为主，visual companion scripts 以安装态为主；首屏 auto-open 能力单独适配，同时保持 Dev Cadence runtime 内容自洽。

- [ ] N/A `cadence-research`
    - Dev Cadence 自有。
    - 重点：检查 research-spike 是否和 workflow、artifact、Human decision 边界一致。

- [ ] N/A `cadence-sync`
    - Dev Cadence 自有。
    - 重点：检查 repo contract 操作边界、目标仓库 runtime 设计和同步脚本一致性。

### P3：横向复核记录/存储能力边界

- [ ] 检查 `cadence-plan` 之外所有 Skill 的 artifact/Harness/gate/record wording。
   - 基准：参照 `cadence-plan`，具体行为 Skill 只产出可交接内容或字段，不直接写入持久记录。
   - 范围：`using-dev-cadence`、`cadence-clarify`、`cadence-executing-plans`、`cadence-subagent-development`、`cadence-dispatch-parallel`、`cadence-tdd`、`cadence-debug`、`cadence-request-code-review`、`cadence-code-review`、`cadence-verify`、`cadence-research`、`cadence-sync`。
   - 产出：逐个 Skill 标记 `OK` / `需要收窄` / `允许例外`，并列出应从“写入/记录”改成“返回 handoff fields”的具体 wording。
   - 回归：必要时更新 `scripts/check-discipline-routes.mjs`，防止 concrete Skill 重新出现直接写入 persistent records、record Harness evidence 或拥有 gate status 写入职责的 wording。

## 每个 Skill 的执行步骤

每改一个 Skill，按以下步骤执行：

1. 读取 Dev Cadence 当前 Skill、直接引用 references、相关 tests。
2. 读取对应 superpowers 源码态 Skill 和直接配套 references/scripts。
3. 读取对应 superpowers 安装态 Skill 和直接配套 references/scripts。
4. 做三方差距清单：Dev Cadence 当前版、superpowers 源码态、superpowers 安装态。
5. 判断参考采用依据：源码态更新是否更好、安装态是否包含运行所需生成内容、两者冲突时采用哪一版。
6. 做章节级差距清单：缺少、弱化、Dev Cadence 不适用、Dev Cadence 已替代。
7. 决定内容归属：必须立即看到的规则进 `SKILL.md`；只服务该 Skill 的长内容进 Skill-local 文件；跨 Skill 共享规则才进全局 `references/`。
8. 检查记录/存储能力边界：如果 Skill 只是具体行为纪律，应只返回 handoff fields，不直接写入或更新持久 artifact、Harness evidence、gate status 或 acceptance record。
9. 修改 Skill/reference。
10. 更新 `scripts/check-discipline-routes.mjs` 或新增测试，覆盖关键强制规则、资源归属边界和记录/存储职责边界。
11. 跑 targeted checks。
12. 跑 `bash tests/run-all.sh`。
13. 向 Human 汇报差异和验证结果，等待确认后再提交。

对标完成后的发布内容必须只讲 Dev Cadence 自己的规则。即使内容来源参考了 superpowers，也不能在 runtime Skill 或 reference 中写“参考 superpowers”“对应 systematic-debugging”之类的信息。

## 首轮建议

建议先改 `cadence-debug`，因为它当前和 `systematic-debugging` 的差距最大，而且 bugfix 场景最容易暴露 Agent 猜测、乱修、跳过验证的问题。

`cadence-debug` 完成后，再按 `cadence-tdd`、`cadence-verify` 推进。这样先把最核心的“不能乱修、不能跳过测试、不能无证据宣布完成”三条纪律补牢。
