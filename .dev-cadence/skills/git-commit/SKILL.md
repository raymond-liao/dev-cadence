---
name: git-commit
description: 智能提交代码变更到 Git 仓库，遵循 Conventional Commit 规范。当用户说"提交代码"、"帮我 commit"、"创建提交"时使用。自动分析变更内容，生成以用户价值为导向的提交信息，避免技术细节。支持 feat/fix/perf 等类型，自动检测敏感文件。
allowed-tools: Bash, Read, Grep
---

# 智能 Git 提交

自动分析代码变更，生成符合 Conventional Commit 规范的提交信息，重点描述用户价值。

## 严格安全约束

**允许的 Git 命令（白名单）**：
- `git status` - 查看仓库状态
- `git diff` - 查看变更差异（包括 --cached、--staged 等参数）
- `git add` - 暂存文件（仅 `git add .` 或 `git add <具体文件>`）
- `git commit` - 创建提交（仅 `-m` 参数）

**禁止的操作**：
- ❌ 任何修改历史的命令（reset、rebase、amend、cherry-pick 等）
- ❌ 任何远程操作（push、pull、fetch 等）
- ❌ 任何分支操作（checkout、branch、merge 等）
- ❌ 任何标签操作（tag 等）
- ❌ 任何配置修改（config 等）
- ❌ 任何其他 Git 命令
- ❌ 任何非 Git 的 bash 命令

**如用户要求执行白名单外的操作，必须拒绝并说明原因。**

## 执行流程

### 1. 验证环境
- 检查是否在 Git 仓库中
- 检查是否有待提交的变更
- 如无变更，告知用户工作区干净

### 2. 分析变更
使用 `git status` 和 `git diff` 分析变更内容，判断：

| 变更特征 | Type | Scope 示例 |
|---------|------|-----------|
| 新增功能/API | `feat` | auth, payment, search |
| 修复 bug | `fix` | login, cart, api |
| 性能优化 | `perf` | database, render |
| 代码重构 | `refactor` | 模块名 |
| UI/样式 | `style` | ui, theme |
| 文档 | `docs` | readme, api |
| 测试 | `test` | unit, e2e |
| 构建/依赖 | `chore` | deps, build |

### 3. 生成提交信息

**格式**：`<type>(<scope>): <subject>`

**核心原则**：
- **Subject**：描述用户收益，不提技术细节（≤72 字符）
- **Body**：说明背景和用户价值（可选）
- **Footer**：关联 issue 或 breaking changes（可选）

详细规范见 [CONVENTIONS.md](CONVENTIONS.md)

### 4. 安全检查
检查是否包含敏感文件（`.env`、`credentials.json`、包含 `password/secret/key` 的文件），如发现则警告并建议排除。

### 5. 展示并执行提交
向用户展示生成的提交信息（type、scope、subject、body、影响的文件列表），然后直接执行提交。

### 6. 执行提交命令

```bash
git add <具体文件>
git commit -m "<type>(<scope>): <subject>

<body>

<footer>"
```

**严格遵循 Conventional Commit 规范，不添加工具署名或其他额外内容。**

### 7. 显示结果
显示提交 hash 和简要信息，提示用户：
- 运行 `git push` 推送到远程仓库
- 如需修改提交信息，可运行 `git commit --amend` 或 `git reset --soft HEAD~1` 撤销后重新提交

## 重要提示

- 提交信息仅包含：type、scope、subject、body、footer
- 不会自动 push，需用户手动执行
- 优先描述用户价值，避免技术术语
- Breaking changes 使用 `feat!:` 或在 footer 添加 `BREAKING CHANGE:`
- 多个不相关变更应分别提交，保持原子性

---

**版本**: v1.4.0 | **更新**: 2025-12-21 | **变更**: 移除交互确认步骤，直接执行提交
