# Dev Cadence 当前验证

这些命令用于当前仓库维护者做回归检查、发布包生成和 smoke test。它们不是业务功能验收指南，也不替代具体任务的 Human acceptance；安装、更新和卸载命令见 [Dev Cadence 安装](installation.md)。

## 回归检查

```bash
bash tests/run-all.sh
```

该命令覆盖 plugin manifest、发布包边界、官方 plugin 规则、thin repo contract、delivery dry run、gate enforcement、specs HTML report、Skill package、discipline routes、artifact templates 和 diff whitespace。

## 生成 Specs HTML Report

```bash
node scripts/generate-spec-report.mjs --specs-dir specs/records --report-dir specs/report
```

该命令从现有 `specs/records/{task_id}/` Markdown/YAML artifact 生成静态浏览视图：`specs/report/index.html`、`specs/report/assets/style.css`、`specs/report/{task_id}/index.html`、`specs/report/{task_id}/*.html`、`specs/report/{task_id}/runs/{run_id}/index.html` 和 `specs/report/{task_id}/runs/{run_id}/*.html`。报告用于快速浏览 JaCoCo 风格任务 summary、Gate Summary、problem row、run evidence、artifact HTML 详情和 raw artifact 链接；事实源仍是 `specs/records/` 下的 Markdown/YAML artifact。

## 生成发布包

```bash
node scripts/package-codex-plugin.mjs --clean
```

生成的本地 marketplace root 位于 `dist/codex/`，实际 plugin payload 位于 `dist/codex/plugins/dev-cadence/`。发布包不包含源码仓库的 `README.md`、`AGENTS.md`、`docs/`、`hooks/`、`research/`、`specs/`、`tests/` 或 `.git/`。

## 可选真实安装 Smoke Test

```bash
RUN_CODEX_INSTALL_TEST=1 bash tests/test-codex-install-smoke.sh
```

该检查会调用真实 Codex 安装流程，适合在确认本机 Codex 环境可用时执行。
