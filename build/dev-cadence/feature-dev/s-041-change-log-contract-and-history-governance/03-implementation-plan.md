# S-041 Change Log 共享契约与历史治理 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立可安装的 Change Log 单一共享契约，完成 Ordering Version 并发治理和现有 57 张工作项卡片的历史迁移。

**Architecture:** `src/skills/contracts/change-log.md` 只拥有公共字段、事件、身份、时间和 legacy 不变量；三个 Asset Workflow 直接读取它并保留各自升版条件。Work Item Planning 独占 Ordering Version 的触发、双重新鲜度和四部分原子写入；历史卡片通过显式映射一次性迁移，后续由只读 Bash 契约测试保护。

**Tech Stack:** Markdown workflow contracts、Bash contract tests、`rg`、`awk`、Git、现有 build/install scripts。

## Global Constraints

- 不新增独立 `change-log` Skill，不增加入口路由或运行时 Markdown mutator。
- 公共规则唯一源是 `src/skills/contracts/change-log.md`；消费者不得复制完整契约。
- Open Question Registry、模板和 `docs/open-questions.md` 必须保持无 Change Log。
- 标准表头固定为 `Version | Recorded At | Recorded By | Change | Reason`；命名维度只替换第一列名称。
- 定义变化先把版本递增 1；状态、交付和重要迁移事件沿用当前版本；合法重复 Version 必须保留。
- 历史 sentinel 固定为 `legacy: recorded-at precision unknown; original YYYY-MM-DD`、`legacy: recorded-at unknown` 和 `legacy: recorded-by unknown`。
- 不从 Git 历史或当前 Git identity 推断旧作者，不把 date-only 补成午夜或伪造时区。
- `Ordering Version` 只表示用户确认的排序决策，不是 Backlog 全局版本。
- 排序写入前必须同时比较 `Ordering Version` 与可见 `待处理` ID 顺序。
- 排序确认必须原子同步 `待处理`、派生并行表、`Ordering Version` 和 `Ordering Change Log`。
- 历史迁移不得删除任何原始重要事件；只改版本治理元数据、表格字段、顺序和迁移说明，不改工作项目标、范围、验收、关系或产品事实。
- 可安装包版本从 `0.25.1` 升为 `0.26.0`；运行 `bash scripts/build.sh`，但不强制提交被忽略的 `dist/`。
- 所有实现提交只包含当前任务文件，使用 `.dev-cadence/skills/git-commit/SKILL.md` 的 staged-only 提交门禁。

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: 共享契约与 Asset Workflow 接入 | 建立公共规则唯一源并移除三个消费者的重复契约 | `src/skills/contracts/change-log.md`、三个 Asset Workflow、四个测试文件 | `bash tests/change-log-contract.sh`；三个 consumer contract tests |
| Task 2: Ordering 与生命周期事件治理 | 建立排序双重 CAS、四部分原子写入和状态/交付事件留痕 | Work Item Planning、入口和三个 Delivery Workflow、相关 tests | planning、parallel、work-item-development、bug sync tests |
| Task 3: 57 张卡片历史迁移 | 统一五列、legacy sentinel、顺序和显式版本语义 | `docs/stories/*.md`、`docs/tasks/*.md`、`docs/bugs/*.md`、`docs/backlog.md` | `bash tests/change-log-contract.sh`；迁移计数与投影检查 |
| Task 4: 分发与发布验证 | 发布 0.26.0 并证明 source/dist/install 一致 | `version`、package/install tests、run records | `bash scripts/check-all.sh`；`rg --no-ignore` 同步检查 |

## Detailed Tasks

### Task 1: 共享契约与 Asset Workflow 接入

**Files:**
- Create: `src/skills/contracts/change-log.md`
- Create: `tests/change-log-contract.sh`
- Modify: `src/skills/discovery/SKILL.md`
- Modify: `src/skills/work-item-planning/SKILL.md`
- Modify: `src/skills/work-item-analysis/SKILL.md`
- Modify: `tests/discovery-contract.sh`
- Modify: `tests/work-item-planning-contract.sh`
- Modify: `tests/work-item-analysis-contract.sh`
- Modify: `tests/run-all.sh`

**Interfaces:**
- Consumes: S-041 requirements and confirmed technical solution.
- Produces: `.dev-cadence/skills/contracts/change-log.md` as the installed read path; public contract literals and three consumer references used by later tasks.

- [x] **Step 1: 创建共享契约 RED 测试**

在 `tests/change-log-contract.sh` 使用现有 `assert_file`、`assert_literal`、`assert_match` 和 `assert_not_match` 风格，至少断言：

```bash
CONTRACT="$ROOT_DIR/src/skills/contracts/change-log.md"
DISCOVERY="$ROOT_DIR/src/skills/discovery/SKILL.md"
PLANNING="$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
ANALYSIS="$ROOT_DIR/src/skills/work-item-analysis/SKILL.md"

assert_file "$CONTRACT"
assert_literal "standard schema" 'Version | Recorded At | Recorded By | Change | Reason' "$CONTRACT"
assert_literal "named version schema" '<Named Version> | Recorded At | Recorded By | Change | Reason' "$CONTRACT"
assert_literal "legacy date sentinel" 'legacy: recorded-at precision unknown; original YYYY-MM-DD' "$CONTRACT"
assert_literal "legacy unknown date" 'legacy: recorded-at unknown' "$CONTRACT"
assert_literal "legacy unknown author" 'legacy: recorded-by unknown' "$CONTRACT"

for consumer in "$DISCOVERY" "$PLANNING" "$ANALYSIS"; do
  assert_literal "shared contract read" '.dev-cadence/skills/contracts/change-log.md' "$consumer"
done
```

同时断言公共契约覆盖定义升版、非升版重要事件、合法重复、追加顺序、纯格式无需记录、Git identity 优先级、禁止审批/commit/workflow 元数据和历史迁移。

- [x] **Step 2: 运行 RED 并确认失败原因**

Run: `bash tests/change-log-contract.sh`

Expected: FAIL，首个失败是缺少 `src/skills/contracts/change-log.md`，而不是 Bash 语法错误。

- [x] **Step 3: 写入最小共享契约**

创建无 YAML frontmatter 的 supporting reference，章节固定为：

```markdown
# Change Log Contract

## Applicability And Ownership
## Version Dimensions And Schema
## Field Semantics
## Versioned Definition Changes
## Non-Versioned Important Events
## Ordering And Duplicate Versions
## Identity And Time
## Legacy Migration
## Forbidden Metadata
## Red Flags
```

写入 Global Constraints 中的精确 schema 和 sentinel。明确新记录必须实时采集身份与带偏移时间；legacy sentinel 只用于历史迁移。

- [x] **Step 4: 接入三个 Asset Workflow**

在三个 workflow 前部共享规则区加入：

```text
Before reading, creating, or updating an owned asset Change Log, read and follow:

.dev-cadence/skills/contracts/change-log.md
```

Discovery 删除公共表头、身份和时间细节，保留 User Journey、PRD、Business Architecture 和组合文档责任版本触发条件。Planning 与 Analysis 删除公共 schema 复制，保留卡片定义变化触发条件。

- [x] **Step 5: 调整 consumer tests 并接入 test runner**

三个现有 consumer test 改为断言精确 contract 路径和 owner-specific increment rules；公共 schema、身份和时间断言移到 `tests/change-log-contract.sh`。在 `tests/run-all.sh` 的 Asset Workflow tests 后调用：

```bash
bash "$ROOT_DIR/tests/change-log-contract.sh"
```

- [x] **Step 6: 运行 GREEN**

Run:

```bash
bash tests/change-log-contract.sh
bash tests/discovery-contract.sh
bash tests/work-item-planning-contract.sh
bash tests/work-item-analysis-contract.sh
```

Expected: 四个命令全部 PASS，且输出对应 contract checks passed。

- [x] **Step 7: 自审与提交**

检查三个 consumer 不再复制完整公共契约，`document-conventions` 和 Registry 未被修改为公共所有者。暂存本 Task 文件，使用 staged-only 门禁提交：

```bash
git commit -m "feat(flow): centralize Change Log contract"
```

### Task 2: Ordering 与生命周期事件治理

**Files:**
- Modify: `src/skills/work-item-planning/SKILL.md`
- Modify: `src/skills/using-dev-cadence/SKILL.md`
- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`
- Modify: `tests/work-item-planning-contract.sh`
- Modify: `tests/parallel-work-table-contract.sh`
- Modify: `tests/work-item-development-workflow-contract.sh`
- Modify: `tests/bug-fix-backlog-sync-contract.sh`
- Modify: `tests/workflow-symmetry.sh`

**Interfaces:**
- Consumes: Task 1 shared contract path and event semantics.
- Produces: Ordering proposal snapshot `{ordering_version, pending_ids}` and lifecycle event rule `same current Version + idempotent Change Log append`.

- [ ] **Step 1: 增加 Ordering RED 断言**

在 `tests/work-item-planning-contract.sh` 增加精确断言：

```bash
assert_literal "ordering version identity" '`Ordering Version` is the identity of the latest user-confirmed ordering decision, not a global Backlog version.' "$SKILL"
assert_match "proposal binds version and pending facts" 'proposal.*`Ordering Version`.*`待处理`.*ID.*order' "$SKILL"
assert_match "write revalidates both identities" 're-read.*`Ordering Version`.*`待处理`.*stop.*conflict|stop.*conflict.*re-read' "$SKILL"
assert_match "atomic ordering unit" '`待处理`.*`当前可并行实施表`.*`Ordering Version`.*`Ordering Change Log`' "$SKILL"
```

增加正向触发、新工作项明确插入、排序例外新增/修改/取消，以及生命周期、完成移出、机械同步、派生刷新、格式/链接不触发的断言。

在 lifecycle tests 中断言状态/交付结果保持 Version、追加当前 Version 事件并幂等去重。

- [ ] **Step 2: 运行 RED**

Run:

```bash
bash tests/work-item-planning-contract.sh
bash tests/work-item-development-workflow-contract.sh
bash tests/bug-fix-backlog-sync-contract.sh
```

Expected: FAIL 于 Ordering 或 lifecycle Change Log 新断言，现有无关断言不失败。

- [ ] **Step 3: 实现 Ordering 所有者规则**

在 Work Item Planning 新增独立 `Backlog Ordering Version And History` 章节，写入：

- 提案快照字段：当前 Ordering Version、完整 pending ID 顺序、建议变化和原因；
- 写前复读双重身份，任一变化停止覆盖并重新提案；
- 四部分原子写入和复读验证；
- 触发与不触发矩阵；
- Ordering Change Log 必须记录受影响 ID、确认后相对位置和用户原因；
- 无实际排序变化不递增、不追加；部分确认不能拆分四部分原子单元。

- [ ] **Step 4: 对齐入口与 Delivery 生命周期事件**

把 claiming 和三个 Delivery lifecycle writeback 的冲突句改为：执行状态变化不递增卡片 Version；当状态转换或交付结果属于重要事件时，按共享契约使用当前 Version 追加 Change Log；重复执行相同写回不得重复追加。

不在这些文件复制完整 schema、identity、time 或 legacy 规则。

- [ ] **Step 5: 运行 GREEN 与对称检查**

Run:

```bash
bash tests/work-item-planning-contract.sh
bash tests/parallel-work-table-contract.sh
bash tests/work-item-development-workflow-contract.sh
bash tests/bug-fix-backlog-sync-contract.sh
bash tests/workflow-symmetry.sh
```

Expected: 全部 PASS；feature、bug-fix、refactor 的 lifecycle 规则保持对称，Bug 特有 repair event 语义保留。

- [ ] **Step 6: 自审与提交**

确认 Ordering 没有变成 Backlog 全局版本，claim/完成同步没有递增 Ordering Version。暂存本 Task 文件并提交：

```bash
git commit -m "feat(planning): govern ordering history"
```

### Task 3: 57 张工作项卡片历史迁移

**Files:**
- Modify: `tests/change-log-contract.sh`
- Modify: `docs/stories/*.md`
- Modify: `docs/tasks/*.md`
- Modify: `docs/bugs/*.md`
- Modify: `docs/backlog.md`

**Interfaces:**
- Consumes: Task 1 schema/sentinel and Task 2 lifecycle semantics.
- Produces: 57 张标准五列卡片、升序历史、显式版本迁移事件和与 Backlog 一致的当前 Version 投影。

- [ ] **Step 1: 增加历史迁移 RED 测试**

扩展 `tests/change-log-contract.sh`，使用 `rg` 和 `awk` 断言：

```bash
CARD_COUNT="$(find "$ROOT_DIR/docs/stories" "$ROOT_DIR/docs/tasks" "$ROOT_DIR/docs/bugs" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
test "$CARD_COUNT" = "57" || fail "expected 57 work-item cards, found $CARD_COUNT"

if rg -n '^\| Version \| Date \| Change \| Reason \|' \
  "$ROOT_DIR/docs/stories" "$ROOT_DIR/docs/tasks" "$ROOT_DIR/docs/bugs"; then
  fail "legacy four-column Change Log remains"
fi

STANDARD_HEADER_COUNT="$(rg -l '^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|' \
  "$ROOT_DIR/docs/stories" "$ROOT_DIR/docs/tasks" "$ROOT_DIR/docs/bugs" | wc -l | tr -d ' ')"
test "$STANDARD_HEADER_COUNT" = "57" || fail "not every work-item card uses the standard schema"
```

再加入：禁止空作者/`-` 作者；date-only 必须变为精确 legacy sentinel；六个已知倒序块按事件顺序排列；Registry 无 Change Log；Backlog 中每个现存卡片 Version 与卡片顶层 Version 相同；16 张归一化卡含迁移事件；合法重复 Version 仍至少覆盖 B-008、B-009、S-015、S-016 和 S-040。

- [ ] **Step 2: 运行 RED 并记录基线**

Run: `bash tests/change-log-contract.sh`

Expected: FAIL，报告 49 张旧四列表头或标准表头数不是 57。

迁移前记录只读基线：57 张卡、152 条历史行、49 张旧表头、137 条缺作者、138 条缺时间精度、11 张重复 Version 卡、6 个倒序块。

- [ ] **Step 3: 完成机械迁移**

对 49 张旧卡和 B-006 的不完整五列记录执行：

```markdown
| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 原 Change | 原 Reason |
```

精确时间戳和已知作者原样保留。不要把 `+0800` 静默改写为 `+08:00`，因为两者都是可确认的原始时间表示。

- [ ] **Step 4: 修复六个倒序块**

按可确认的时间、Version 和因果关系把 B-005、B-007、B-008、S-013、S-014、T-004 调整为从早到晚。相同日期、相同语义 Version 且无进一步证据时稳定保留原相对顺序。

- [ ] **Step 5: 应用显式版本映射**

只对下表执行语义归一化；`row map` 按迁移后时间顺序列出每条原始事件的新 Version：

| Card | Old current | New current | Row map |
| --- | ---: | ---: | --- |
| S-001 | 6 | 4 | `1,2,3,3,4,4` |
| S-002 | 11 | 8 | `1,2,3,4,4,5,6,7,7,8,8` |
| S-003 | 2 | 1 | `1,1` |
| S-004 | 3 | 1 | `1,1,1` |
| S-005 | 3 | 2 | `1,2,2` |
| S-006 | 4 | 1 | `1,1,1,1` |
| S-007 | 4 | 3 | `1,2,3,3` |
| S-008 | 6 | 3 | `1,2,2,2,3,3` |
| S-009 | 3 | 2 | `1,2,2` |
| S-010 | 5 | 3 | `1,2,3,3,3` |
| S-011 | 5 | 2 | `1,2,2,2,2` |
| S-012 | 5 | 2 | `1,1,2,2,2` |
| S-013 | 5 | 3 | `1,1,2,3,3` |
| S-014 | 5 | 2 | `1,2,2,2,2` |
| S-015 | 7 | 4 | `1,2,2,3,4,4,4,4,4` |
| T-001 | 3 | 2 | `1,2,2` |

同步每张卡顶层 Version 和 `docs/backlog.md` 中所有对应 Version 投影。每条被改号记录的原 Reason 后追加 `Legacy migration: original Version X; normalized to Version Y.`，保留原 Reason 全文。每张归一化卡再追加一条当前 Version 的迁移事件，使用当前实时 Git identity/time，Change 记录 `Normalized legacy status and delivery events to reuse the active definition Version.`，Reason 精确记录 `Old current X -> new current Y; original row versions A -> normalized row versions B.`。该事件不再递增 Version。

- [ ] **Step 6: 运行 GREEN 与迁移审计**

Run:

```bash
bash tests/change-log-contract.sh
bash tests/parallel-work-table-contract.sh
git diff --check
```

Expected: 全部 PASS；57 张卡均为五列；旧表头为 0；Registry 无 Change Log；六个倒序块已修复；Backlog Version 投影一致；所有原始 Change/Reason 文本仍存在，新增 16 条迁移事件。

- [ ] **Step 7: 自审与提交**

抽查每类一张卡：旧四列、精确五列、合法重复 Version、倒序块、归一化 Version。暂存 docs 与 migration test，并提交：

```bash
git commit -m "docs(planning): migrate work-item Change Logs"
```

### Task 4: 分发、版本与全量验证

**Files:**
- Modify: `tests/package-contract.sh`
- Modify: `tests/install-contract.sh`
- Modify: `version`
- Modify: `build/dev-cadence/feature-dev/s-041-change-log-contract-and-history-governance/03-implementation-plan.md`
- Generated and ignored: `dist/.dev-cadence/**`

**Interfaces:**
- Consumes: Tasks 1-3 source rules, tests and migrated assets.
- Produces: installable Dev Cadence `0.26.0` with byte-identical shared contract and consumers.

- [ ] **Step 1: 添加 package/install RED 断言**

在 `tests/package-contract.sh` required files 中加入：

```text
dist/.dev-cadence/skills/contracts/change-log.md
```

在 `tests/install-contract.sh` 加入 first install existence 和 source/install `cmp -s`：

```bash
test -f "$TARGET_REPO/.dev-cadence/skills/contracts/change-log.md" || fail "first install did not create Change Log contract"
cmp -s \
  "$ROOT_DIR/src/skills/contracts/change-log.md" \
  "$TARGET_REPO/.dev-cadence/skills/contracts/change-log.md" || fail "installed Change Log contract differs from source"
```

- [ ] **Step 2: 运行 release identity RED**

Run: `test "$(cat version)" = "0.26.0"`

Expected: exit 1，因为当前根版本仍是 `0.25.1`。package/install 新断言用于安装回归覆盖；新 contract 的行为 RED/GREEN 已由 Task 1 证明。

- [ ] **Step 3: 更新版本并构建**

把根 `version` 精确改为：

```text
0.26.0
```

Run: `bash scripts/build.sh`

Expected: `dist/.dev-cadence/version` 为 `0.26.0`，且 `dist/.dev-cadence/skills/contracts/change-log.md` 存在并与 source 一致。

- [ ] **Step 4: 运行发布 GREEN**

Run:

```bash
bash tests/package-contract.sh
bash tests/install-contract.sh
```

Expected: 两个命令 PASS，安装输出显示 Dev Cadence 0.26.0。

- [ ] **Step 5: 运行完整验证**

Run:

```bash
bash scripts/check-whitespace.sh
bash scripts/check-all.sh
rg --no-ignore -n 'legacy: recorded-by unknown|Ordering Version|skills/contracts/change-log.md' src dist/.dev-cadence tests
git diff --check
```

Expected: 全部检查 PASS；关键规则在 source、dist 和 tests 中同步；没有工作区空白错误。

- [ ] **Step 6: 自审与提交**

确认 `dist/` 仍被忽略且未强制暂存。暂存 package/install tests、`version` 和本计划的完成勾选，使用 staged-only 门禁提交：

```bash
git commit -m "chore(release): publish Change Log governance"
```

## Development Implementation Completion Conditions

- [ ] 四个 Task 均有独立 RED/GREEN 证据和 progress commit。
- [ ] `03-implementation-plan.md` 对完成步骤使用 `- [x]`。
- [ ] 公共契约只有一个完整规则源，三个 Asset Workflow 只保留 owner-specific 升版条件。
- [ ] 57 张卡、Backlog、Registry 和 Ordering Version 通过专项验证。
- [ ] source/dist/install 以 `0.26.0` 同步。
- [ ] 每个 SDD Task 通过 task reviewer，最终整个实现范围通过独立 code review。
- [ ] `bash scripts/check-all.sh` 在最终实现提交上通过。

## Plan Confirmation

- Implementation Plan：✅ `confirmed`
- 确认方式：用户于 `2026-07-19T12:02:17+08:00` 授权不中断完成后续工程阶段，并要求最终统一总结重大决策。
- 执行方式：Subagent-Driven Development；主代理逐 Task 审查、集成并完成最终验证。
