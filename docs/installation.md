# Dev Cadence 安装

在本机或业务仓库安装 `dev-cadence` Codex Plugin 时，使用这里的命令。安装后的验证、打包检查和 smoke test 见 [Dev Cadence 当前验证](validation.md)。

## 本机安装或更新

维护者在本仓库安装或更新本机插件：

```bash
./deploy-local.sh
```

该脚本会生成 `dist/codex/` 本地 marketplace package，注册 marketplace，并安装 `dev-cadence@dev-cadence-local`。安装或更新后新开 Codex thread，让 Codex 重新加载插件提供的 Skills。

不要把源码仓库根目录直接作为插件安装源；本地发布包位于 `dist/codex/`。

## 业务仓库内置 Marketplace 安装

业务仓库也可以提交自己的 repo-scoped marketplace，让团队成员从业务仓库根目录安装同一份 Dev Cadence 插件。典型形态：

```text
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

`marketplace.json` 的 `source.path` 必须从业务仓库根目录解析到实际 plugin payload。例如 plugin payload 放在 `.agents/plugins/dev-cadence/` 时：

```json
{
  "name": "dev-cadence-health",
  "interface": {
    "displayName": "Dev Cadence Health"
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
codex plugin add dev-cadence@dev-cadence-health
```

`codex plugin marketplace add .` 使用当前业务仓库作为 marketplace source。`codex plugin add` 会把插件安装到当前用户的 Codex cache，例如 `~/.codex/plugins/cache/...`；这属于正常用户本机状态，不表示插件被安装回业务仓库。安装后新开 Codex thread。

如果业务仓库用 `.gitignore` 忽略 `.agents/`，必须显式放行 `.agents/plugins/marketplace.json` 和 plugin payload，否则其他用户 clone 后无法安装。

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
