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
- 如果 `cadence-tdd`、`cadence-executing-plans`、`cadence-review` 等也会稳定复用，才保留在全局 `references/`。
- 不允许为了“看起来模块化”而牺牲 Skill 激活后的行为强度。

## 对标完成定义

一个 Skill 完成对标，必须满足：

- 有明确对应的参考 Skill，或明确说明 Dev Cadence 自有 Skill 不需要外部对应。
- `SKILL.md` 里有足够强的触发条件、核心规则、必做步骤、禁止事项和 Supervisor handoff。
- 详细规则放在恰当位置：单 Skill 核心规则留在该 Skill；跨 Skill 共享协议才放全局 reference；`SKILL.md` 明确何时加载额外资源。
- superpowers 参考 Skill 中会防止 Agent 偷懒的内容没有被削弱，包括 iron law、red flags、common rationalizations、stop conditions、review/verification checkpoints 等。
- 配套 reference/script 不是只按主题覆盖；其原本依赖的结构、示例、✅/❌ 对照、gate function、quick reference 和 red flags 已保留或用同等强度的 Dev Cadence 版本替代。
- 已对比 superpowers 源码态和安装态，并记录采用依据。
- `scripts/check-discipline-routes.mjs` 或其他测试能防止关键章节再次被删空。
- `bash tests/run-all.sh` 通过。

## 状态标识

- Checkbox：`[x]` 表示该 Skill 的本轮改造已完成；`[ ]` 表示仍需处理。
- 能力标识：`✅` 表示已确认 Dev Cadence Skill 不弱于对应 superpowers Skill；`❌` 表示尚未确认；`N/A` 表示无直接对应 superpowers Skill，只做 Dev Cadence 内部一致性 review。

## 对照表

| 完成 | Dev Cadence Skill | 参考 superpowers Skill | 能力 | 当前判断 | 改造重点或完成说明 |
|---|---|---|---|---|---|
| [ ] | `using-dev-cadence` | `using-superpowers` | ❌ | 部分对标 | 强化“必须先检查适用 Skill”的不可协商规则，同时保留 Dev Cadence 的用户/仓库指令优先级。 |
| [x] | `cadence-clarify` | `brainstorming` | ✅ | 已完成 | 已确认 markdown 以源码态为主、visual companion scripts 以安装态为主，并单独适配源码态首屏 auto-open 能力；已保留 hard gate、just-in-time visual companion、one-question flow、2-3 approaches、design approval、spec self-review、Human artifact review 和 planning handoff，并完成 Dev Cadence 命名、目录、URL fallback 和 Supervisor handoff 适配。 |
| [ ] | `cadence-plan` | `writing-plans` | ❌ | 明显过薄 | 补 file structure planning、bite-sized tasks、plan header/shape、no placeholders、self-review、execution handoff。 |
| [ ] | `cadence-executing-plans` | `executing-plans` | ❌ | 过薄 | 补 plan critical review、按任务执行、验证失败停手、blocker handling、完成后进入 review/verify 的 Dev Cadence 等价流程。 |
| [ ] | `cadence-subagent-development` | `subagent-driven-development` | ❌ | 中等但不完整 | 补 fresh Worker context、continuous execution 边界、prompt templates、status handling、两阶段 review 的强制顺序和红旗。 |
| [ ] | `cadence-dispatch-parallel` | `dispatching-parallel-agents` | ❌ | 中等但不完整 | 补 when-to-use/when-not-to-use、prompt structure、common mistakes、parallel integration verification。 |
| [x] | `cadence-tdd` | `test-driven-development` | ✅ | 已完成 | 已确认 TDD iron law、RED 失败证据、事后实现处理、good tests、rationalizations、stuck handling、debug integration 和 testing anti-patterns 能力不弱于对应 Skill。 |
| [x] | `cadence-debug` | `systematic-debugging` | ✅ | 已完成 | 已确认 root-cause-first hard rule、四阶段调试、假设验证、失败后升级、human correction signals、common rationalizations、示例代码语言边界、root-cause tracing、condition-based waiting、defense-in-depth 和污染定位脚本能力不弱于对应 Skill，并保持 debugging 技术文件为 Skill-local 资源。 |
| [x] | `cadence-request-code-review` | `requesting-code-review` | ✅ | 已完成 | 已确认 review 触发时机、精确上下文、只读 reviewer、必须检查实际 diff/files/evidence、reviewer prompts、severity、明确 verdict、spec compliance 和 code quality 两阶段 review 能力不弱于对应 Skill。 |
| [x] | `cadence-review` | `receiving-code-review` | ✅ | 已完成 | 已确认源码态和安装态基本一致，只有上游私人口令/CLAUDE wording 差异不进入发布内容；已收窄为 code review feedback handling，并保留 verify-before-implement、禁止表演式同意、unclear feedback 停手、source-specific handling、YAGNI check、pushback、correct-feedback response、pushback correction、common mistakes、逐项处理、GitHub thread reply 和 code re-review handoff；非代码反馈回 Supervisor 按 intent/design/implementation/evidence 重新分类。 |
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

- [ ] ❌ `cadence-plan`
   - 参考：`writing-plans`。
   - 重点：计划质量直接影响执行质量，必须补 bite-sized tasks、file structure、no placeholders、self-review。

- [ ] ❌ `cadence-executing-plans`
   - 参考：`executing-plans`。
   - 重点：执行前 plan review、按任务执行、验证失败停手、blocker handling。

- [ ] ❌ `cadence-subagent-development`
   - 参考：`subagent-driven-development`。
   - 重点：fresh Worker context、continuous execution、两阶段 review、状态处理和 prompt template。

- [ ] ❌ `cadence-dispatch-parallel`
   - 参考：`dispatching-parallel-agents`。
   - 重点：只在独立问题域使用、prompt structure、integration verification。

- [x] ✅ `cadence-request-code-review`
   - 参考：`requesting-code-review`。
   - 重点：已确认 review 触发时机、上下文构造、只读 reviewer、实际 diff/files/evidence 检查、reviewer prompt、severity、明确 verdict 和反馈处理边界。

- [x] ✅ `cadence-review`
   - 参考：`receiving-code-review`。
   - 产出：已强化 code review feedback reception response pattern、forbidden responses、YAGNI gate、pushback/correction handling、common mistakes、Supervisor handoff 和 code re-review 边界；非代码反馈不在此 Skill 处理。

### P2：复核入口和自有 Skill

- [ ] ❌ `using-dev-cadence`
    - 参考：`using-superpowers`。
    - 重点：强化 routing discipline，但不能覆盖用户/仓库显式指令。

- [x] ✅ `cadence-clarify`
    - 参考：`brainstorming`。
    - 重点：已按特例确认，markdown 以源码态为主，visual companion scripts 以安装态为主；首屏 auto-open 能力单独适配，同时保持 Dev Cadence runtime 内容自洽。

- [ ] N/A `cadence-research`
    - Dev Cadence 自有。
    - 重点：检查 research-spike 是否和 workflow、artifact、Human decision 边界一致。

- [ ] N/A `cadence-sync`
    - Dev Cadence 自有。
    - 重点：检查 repo contract 操作边界、目标仓库 runtime 设计和同步脚本一致性。

## 每个 Skill 的执行步骤

每改一个 Skill，按以下步骤执行：

1. 读取 Dev Cadence 当前 Skill、直接引用 references、相关 tests。
2. 读取对应 superpowers 源码态 Skill 和直接配套 references/scripts。
3. 读取对应 superpowers 安装态 Skill 和直接配套 references/scripts。
4. 做三方差距清单：Dev Cadence 当前版、superpowers 源码态、superpowers 安装态。
5. 判断参考采用依据：源码态更新是否更好、安装态是否包含运行所需生成内容、两者冲突时采用哪一版。
6. 做章节级差距清单：缺少、弱化、Dev Cadence 不适用、Dev Cadence 已替代。
7. 决定内容归属：必须立即看到的规则进 `SKILL.md`；只服务该 Skill 的长内容进 Skill-local 文件；跨 Skill 共享规则才进全局 `references/`。
8. 修改 Skill/reference。
9. 更新 `scripts/check-discipline-routes.mjs` 或新增测试，覆盖关键强制规则和资源归属边界。
10. 跑 targeted checks。
11. 跑 `bash tests/run-all.sh`。
12. 向 Human 汇报差异和验证结果，等待确认后再提交。

对标完成后的发布内容必须只讲 Dev Cadence 自己的规则。即使内容来源参考了 superpowers，也不能在 runtime Skill 或 reference 中写“参考 superpowers”“对应 systematic-debugging”之类的信息。

## 首轮建议

建议先改 `cadence-debug`，因为它当前和 `systematic-debugging` 的差距最大，而且 bugfix 场景最容易暴露 Agent 猜测、乱修、跳过验证的问题。

`cadence-debug` 完成后，再按 `cadence-tdd`、`cadence-verify` 推进。这样先把最核心的“不能乱修、不能跳过测试、不能无证据宣布完成”三条纪律补牢。
