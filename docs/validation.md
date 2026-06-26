# Dev Cadence 当前验证

本文记录当前仓库维护者常用的验证、发布包生成和 smoke test 命令。它不是业务功能验收指南，也不替代具体任务的 Human acceptance。安装、更新和卸载命令见 [Dev Cadence 安装](installation.md)。

## 回归检查

```bash
bash tests/run-all.sh
```

该命令覆盖 plugin manifest、发布包边界、官方 plugin 规则、thin repo contract、delivery dry run、gate enforcement、Skill package、discipline routes、artifact templates 和 diff whitespace。

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
