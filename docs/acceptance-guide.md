# Dev Cadence 验收指南

本文用于验收当前阶段的 Dev Cadence，而不是验收某个业务功能是否已经实现。

当前阶段的验收目标是确认：

- 方案路线图 R1-R7 已闭环；
- `dev-cadence` Codex 发布结构、routes、templates 和 dry-run 生成的 specs 仍然可校验；
- thin repo-local contract 可以初始化；
- delivery dry run 可以生成 task artifacts、Harness evidence 和 acceptance summary；
- 用户可以直接阅读验收摘要，不需要自己翻多个 artifact 文件。

## 1. 确认阶段范围

先查看路线图：

```bash
sed -n '1,240p' docs/dev-cadence-roadmap.md
```

验收时重点确认 R1-R7 都是 `done`：

- R1：Adapter reference
- R2：Artifact 初始化脚本
- R3：入口 Skills 拆分
- R4：Thin repo 初始化与维护 runtime
- R5：Delivery runtime 最小闭环
- R6：Acceptance 展示体验
- R7：Visual Companion 真实验证

如果你认可 R1-R7 就是当前阶段范围，并且它们都记录为 `done`，阶段范围验收通过。

## 2. 运行核心检查

在仓库根目录执行：

```bash
bash tests/run-all.sh
```

预期结果：

- `tests/run-all.sh` 依次输出 manifest、Codex package boundary、repo contract 和 delivery dry-run 测试通过
- `tests/run-all.sh` 内部会调用 `package-codex-plugin.mjs` 并验证生成包边界
- `check-skill-package.mjs` 输出 `OK checked ... plugin files in ...`
- `check-discipline-routes.mjs` 输出 `OK discipline routes verified for ...`
- `test-dry-run.sh` 会对临时生成的 `specs/` 运行 artifact 检查
- `check-spec-artifacts.mjs templates` 输出 `OK checked spec artifacts ...`
- `git diff --check` 没有输出并且退出码为 0

这些检查证明包结构、发布边界、引用关系、artifact 模板、临时生成 artifact、核心脚本行为和 diff whitespace 没有结构性错误；它们不证明真实用户产品功能行为。

## 3. 生成本地 Codex 发布包

在仓库根目录执行：

```bash
node scripts/package-codex-plugin.mjs --clean
```

预期生成：

```text
dist/codex/
  .agents/
    plugins/
      marketplace.json
  plugins/
    dev-cadence/
```

`dist/codex/` 是本地 marketplace root，Codex CLI 读取其中的 `.agents/plugins/marketplace.json`；`dist/codex/plugins/dev-cadence/` 是实际 plugin payload。plugin payload 应只包含 `.codex-plugin/`、`skills/`、`references/`、`templates/` 和 `scripts/`，不包含源码仓库的 `README.md`、`AGENTS.md`、`docs/`、`hooks/`、`research/`、`specs/`、`tests/` 或 `.git/`。

## 4. 运行最小 dry run

创建临时仓库目录：

```bash
tmp="$(mktemp -d /tmp/dev-cadence-acceptance.XXXXXX)"
```

初始化 thin repo-local contract：

```bash
node scripts/sync-repo-contract.mjs init --repo-dir "$tmp"
```

初始化成功时，输出里应包含：

```text
Mode: init
Initialized: yes
```

并列出这些新增文件：

```text
AGENTS.md
.gitignore
.dev-cadence.yaml
specs/.gitkeep
```

然后运行一次 delivery dry run：

```bash
node scripts/run-delivery-dry-run.mjs \
  --repo-dir "$tmp" \
  --task-id acceptance-login \
  --goal "Develop a login feature" \
  --accepted-by Raymond
```

预期输出应包含：

```text
Workflow: feature-dev
Task class: S1
Acceptance: accepted_for_dry_run_scope
Verification: partially_verified
Scope reconciliation: passed_no_product_changes
```

这里的 `accepted_for_dry_run_scope` 只表示 dry run 范围被接受，不表示登录功能已经开发完成。

## 5. 查看验收摘要

执行：

```bash
node scripts/summarize-acceptance.mjs \
  --specs-dir "$tmp/specs" \
  --task-id acceptance-login
```

重点看这些字段：

```text
Goal: Develop a login feature
Workflow: feature-dev
Task class: S1
Implementation: dry_run_complete
Scope reconciliation: passed_no_product_changes
Verification: partially_verified
Review decision: approved_with_minor_notes
Acceptance: accepted_for_dry_run_scope
Accepted by: Raymond
```

还应看到：

```text
## Changed Files
- None

## Blockers
- None
```

以及 residual risk：

```text
Dry run evidence cannot prove product behavior.
Product behavior remains unverified.
```

这两个 residual risk 是预期结果，因为 dry run 的目标是验证 Dev Cadence 流程闭环，不是实现和验证真实登录功能。

## 6. 检查 dry run 生成的 artifacts

可选执行：

```bash
node scripts/check-spec-artifacts.mjs "$tmp/specs"
```

预期输出：

```text
OK checked spec artifacts in ...
```

如果想看生成内容，查看：

```bash
find "$tmp/specs/acceptance-login" -type f | sort
```

应包含：

- `00-brief.md`
- `01-requirements.md`
- `02-design.md`
- `03-tasks.md`
- `04-test-plan.md`
- `05-implementation.md`
- `06-test-report.md`
- `07-review-report.md`
- `08-acceptance.md`
- `runs/acceptance-login-dry-run-1/run-context.md`
- `runs/acceptance-login-dry-run-1/execution-report.md`
- `runs/acceptance-login-dry-run-1/tool-log.md`
- `runs/acceptance-login-dry-run-1/test-log.md`
- `runs/acceptance-login-dry-run-1/diff-summary.md`
- `runs/acceptance-login-dry-run-1/permission-decisions.md`

## 7. 通过标准

当前阶段可以接受，当以下条件都成立：

- R1-R7 在路线图中都是 `done`；
- 核心检查命令全部通过；
- `sync-repo-contract.mjs init` 能初始化临时目录；
- delivery dry run 能生成 artifacts 和 run evidence；
- acceptance summary 能直接显示目标、workflow、task class、scope reconciliation、verification、review、acceptance、blockers 和 residual risk；
- summary 明确说明 dry run 不验证产品行为；
- 没有把 Supervisor、Harness、Developer、Tester 或 Reviewer 记录为 final human accepter。

## 8. 不通过或需要反馈的情况

出现以下情况时，不应验收通过：

- 核心检查命令失败；
- `sync-repo-contract.mjs init` 没有生成 thin contract；
- dry run 没有生成 `specs/{task_id}/` 或 `runs/{run_id}/`；
- summary 需要用户手动翻多个文件才能判断是否接受；
- summary 没有显示 residual risk；
- 没有 `--accepted-by` 时仍然显示 final acceptance passed；
- 文档或脚本暗示 dry run 已经验证真实产品行为。

## 9. 验收结论怎么表达

如果以上都符合预期，可以回复：

```text
接受当前阶段。
```

如果只接受部分内容，建议指出具体项，例如：

```text
核心检查通过，但 acceptance summary 的 residual risk 说明不清楚，需要调整。
```

验收结论应该写入对应 task 的 `08-acceptance.md`，聊天记录本身不作为长期事实来源。
