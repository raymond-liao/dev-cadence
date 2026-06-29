# Dev Cadence 安装

推荐把 `dev-cadence` Codex Plugin 提交到业务仓库的 repo-scoped marketplace，让团队成员从业务仓库根目录安装同一份插件。本机安装只用于维护者开发、调试和 smoke test。安装后的验证、打包检查和 smoke test 见 [Dev Cadence 当前验证](validation.md)。

## 业务仓库内置 Marketplace 安装

先在 Dev Cadence 源码仓库生成发布包：

```bash
cd /path/to/dev-cadence
node scripts/package-codex-plugin.mjs --clean
```

把 `dist/codex/plugins/dev-cadence/` 复制或同步到业务仓库的 plugin payload 目录。典型形态：

```text
your-product-repo/
  .agents/
    plugins/
      marketplace.json
      dev-cadence/
        .codex-plugin/
          plugin.json
        skills/
        references/
        templates/
        scripts/
```

业务仓库的 `.agents/plugins/marketplace.json` 需要使用该仓库自己的 marketplace name；`source.path` 必须从业务仓库根目录解析到实际 plugin payload。例如 plugin payload 放在 `.agents/plugins/dev-cadence/` 时：

```json
{
  "name": "dev-cadence-your-product",
  "interface": {
    "displayName": "Dev Cadence Your Product"
  },
  "plugins": [
    {
      "name": "dev-cadence",
      "source": {
        "source": "local",
        "path": "./.agents/plugins/dev-cadence"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Coding"
    }
  ]
}
```

团队成员在业务仓库根目录执行：

```bash
codex plugin marketplace add .
codex plugin add dev-cadence@dev-cadence-your-product
```

`codex plugin marketplace add .` 使用当前业务仓库作为 marketplace source。`codex plugin add` 会把插件安装到当前用户的 Codex cache，例如 `~/.codex/plugins/cache/...`；这属于正常用户本机状态，不表示插件被安装回业务仓库。安装后新开 Codex thread。

如果业务仓库用 `.gitignore` 忽略 `.agents/`，必须显式放行 `.agents/plugins/marketplace.json` 和 plugin payload，否则其他用户 clone 后无法安装。

## 维护者本机安装

维护者需要验证当前源码包时，可以在 Dev Cadence 源码仓库运行：

```bash
./deploy-local.sh
```

该脚本会生成 `dist/codex/` 本地 marketplace package，注册 marketplace，并安装 `dev-cadence@dev-cadence-local`。这条路径只用于本机开发、调试和 smoke test；团队使用应优先通过业务仓库内置 marketplace 分发。

不要把源码仓库根目录直接作为插件安装源；打包产物位于 `dist/codex/`。

## 本机卸载

移除本仓库发布包安装的插件：

```bash
codex plugin remove dev-cadence@dev-cadence-local
codex plugin marketplace remove dev-cadence-local
```

第一条移除已安装插件和本地 cache；第二条移除本机 marketplace source。

如果是业务仓库内置 marketplace，把 `dev-cadence-local` 替换为该业务仓库 `marketplace.json` 里的 `name`，例如：

```bash
codex plugin remove dev-cadence@dev-cadence-health
codex plugin marketplace remove dev-cadence-health
```
