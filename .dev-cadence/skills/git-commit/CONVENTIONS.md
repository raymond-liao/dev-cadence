# Conventional Commits 规范详解

本文档基于 [Conventional Commits v1.0.0 规范](https://www.conventionalcommits.org/en/v1.0.0/)，结合用户价值导向的提交信息编写原则。

---

## 规范摘要

Conventional Commits 是一个轻量级的提交信息约定，为创建清晰的提交历史提供简单规则，使自动化工具开发更加便捷。此规范与语义化版本控制（SemVer）相辅相成。

## 提交信息结构

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

---

## 核心元素

### Type（必需）

**官方规定的核心类型**：

| Type | SemVer 对应 | 说明 |
|------|-----------|------|
| `feat` | MINOR | 新增功能 |
| `fix` | PATCH | 修复 bug |
| `BREAKING CHANGE` | MAJOR | 破坏性变更（在 footer 或使用 `!`） |

**扩展类型**（基于 Angular 约定，被广泛采用）：

| Type | 用途 | 何时使用 |
|------|------|----------|
| `build` | 构建系统 | 影响构建系统或外部依赖（webpack、gulp、npm） |
| `chore` | 杂项 | 其他不修改 src 或 test 的变更 |
| `ci` | 持续集成 | CI 配置文件和脚本的变更（Travis、Circle、GitHub Actions） |
| `docs` | 文档 | 仅文档变更 |
| `style` | 代码格式 | 不影响代码含义的变更（空格、格式化、缺失的分号） |
| `refactor` | 重构 | 既不修复 bug 也不添加功能的代码变更 |
| `perf` | 性能 | 提升性能的代码变更 |
| `test` | 测试 | 添加缺失的测试或修正现有测试 |

### Scope（可选）

代码库中受影响的特定部分，放在圆括号内。

**示例**：
- `feat(auth): 添加 OAuth2.0 支持`
- `fix(parser): 处理特殊字符转义`
- `perf(api): 优化数据库查询`

**常见 scope**：
- 模块名：`auth`、`payment`、`search`
- 功能区域：`ui`、`api`、`database`
- 组件名：`header`、`sidebar`、`cart`
- 依赖管理：`deps`

### Description（必需）

简短描述变更内容。

**规则**：
- 紧跟类型/作用域后的冒号和空格
- 使用祈使句、现在时态（"change" 而非 "changed" 或 "changes"）
- 不大写首字母
- 结尾不加句号

### Body（可选）

提供额外的上下文信息。

**规则**：
- 与 description 之间空一行
- 可包含多个段落
- 使用祈使句、现在时态
- 说明变更的动机，对比前后行为
- 每行不超过 120 字符（现代宽屏显示器下的合理限制）

### Footer（可选）

一个或多个页脚，遵循 [git trailer 格式](https://git-scm.com/docs/git-interpret-trailers)。

**常见用法**：
- 关联 issue：`Closes #123` 或 `Fixes #456`
- 破坏性变更：`BREAKING CHANGE: 描述`
- 其他元数据：`Reviewed-by: Name`、`Refs: #789`

---

## Breaking Changes（破坏性变更）

破坏性变更必须在提交中明确标识，有两种方式：

### 方式 1：在 type/scope 后添加 `!`

```
feat!: 移除对 Node 10 的支持
```

```
feat(api)!: 更改用户认证端点路径
```

### 方式 2：在 footer 中使用 BREAKING CHANGE

```
feat: 更新认证流程

BREAKING CHANGE: 旧的 /api/auth 端点已移除，请使用 /api/v2/auth
```

**注意**：
- `BREAKING CHANGE` 必须全部大写
- 可以同时使用 `!` 和 BREAKING CHANGE footer
- 破坏性变更可以是任何 type（不仅限于 feat）

---

## 官方规范详细说明（16 条规则）

1. 提交**必须**以 type 为前缀，type 由名词组成：feat、fix 等，后跟**可选的** scope、**可选的** `!`，以及**必需的**冒号和空格
2. 当提交向代码库添加新功能时，**必须**使用 `feat` type
3. 当提交修复 bug 时，**必须**使用 `fix` type
4. scope **可以**在 type 后提供。scope **必须**是描述代码库某个部分的名词，放在圆括号内
5. description **必须**紧跟 type/scope 前缀后的冒号和空格
6. description 是对代码变更的简短总结
7. **可以**在简短 description 后提供更长的 body，为代码变更提供额外的上下文信息。body **必须**在 description 后空一行开始
8. body 是自由格式的，**可以**包含多个由空行分隔的段落
9. 一个或多个 footer **可以**在 body 后空一行提供。每个 footer **必须**包含一个词标记，后跟 `:<space>` 或 `<space>#` 分隔符，然后是字符串值
10. footer 的标记**必须**使用 `-` 代替空格字符，例如 `Acked-by`（这有助于区分 footer 和多段 body）
11. footer 的值**可以**包含空格和换行符，解析**必须**在下一个有效的 footer 标记/分隔符对出现时终止
12. 破坏性变更**必须**在提交中标识，通过在 type/scope 前缀后紧跟 `!`，或作为 footer 中的一项
13. 如果作为 footer，破坏性变更**必须**包含大写文本 `BREAKING CHANGE`，后跟冒号、空格和描述
14. 如果在 type/scope 前缀中包含 `!`，**可以**省略 `BREAKING CHANGE:` footer，并且 `!` 就足以表明这是破坏性变更
15. 除 `feat` 和 `fix` 外的其他 type **可以**在提交信息中使用
16. Conventional Commits 的实现**不得**将组成信息的单元视为大小写敏感，**除了** BREAKING CHANGE（**必须**大写）

---

## 官方示例

### 示例 1：包含 description 和 breaking change footer

```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### 示例 2：使用 `!` 标记 breaking change

```
feat!: send an email to the customer when a product is shipped
```

### 示例 3：包含 scope 和 `!`

```
feat(api)!: send an email to the customer when a product is shipped
```

### 示例 4：包含 `!` 和 BREAKING CHANGE footer

```
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

### 示例 5：不含 body

```
docs: correct spelling of CHANGELOG
```

### 示例 6：包含 scope

```
feat(lang): add Polish language
```

### 示例 7：包含多段 body 和多个 footer

```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```

---

## 为什么使用 Conventional Commits

### 优势

1. **自动生成 CHANGELOG**
   - 按类型分组变更
   - 突出显示破坏性变更

2. **自动确定语义版本号**
   - `fix` → PATCH (0.0.x)
   - `feat` → MINOR (0.x.0)
   - `BREAKING CHANGE` → MAJOR (x.0.0)

3. **向团队和利益相关者传达变更性质**
   - 结构化的提交历史
   - 易于理解的变更类型

4. **触发构建和发布流程**
   - CI/CD 可根据提交类型自动化操作
   - 自动发布新版本

5. **便于项目贡献**
   - 降低贡献门槛
   - 统一的提交风格

6. **更易于探索提交历史**
   - 按类型过滤提交
   - 快速定位特定变更

---

## 用户价值导向原则

虽然 Conventional Commits 规定了格式，但我们在**描述内容**时应遵循用户价值导向。

### 核心思想

提交信息应该让**非技术人员**也能理解这次改动带来的价值。

### ✅ 好的示例（关注用户价值）

```
feat(auth): 支持记住登录状态

用户登录一次后，7 天内访问网站无需重复登录，
提升使用便利性。

Closes #234
```

**为什么好**：
- 说明用户能做什么（免登录 7 天）
- 说明用户收益（便利性提升）
- 避免技术细节（JWT、Redis 等）

### ❌ 不好的示例（过度技术化）

```
feat(auth): 实现 JWT token 持久化机制

添加 Redis 缓存 session，使用 HS256 算法签名 JWT，
设置 7 天过期时间。

Closes #234
```

**为什么不好**：
- 只说了技术实现
- 不了解技术的人看不懂
- 没有说明用户价值

### 平衡技术与价值

**推荐做法**：
- **Description**：用户价值（非技术人员能懂）
- **Body**：可包含必要的技术细节（给开发者看）

```
feat(auth): 支持记住登录状态

用户登录一次后，7 天内访问网站无需重复登录。

实现方式：使用 JWT token 持久化，Redis 缓存 session，
7 天过期时间。

Closes #234
```

---

## 常见场景示例

### 场景 1：新增功能

```
feat(payment): 支持微信支付

用户可以在结算时选择微信支付，支持扫码和 H5 两种方式。

Closes #456
```

### 场景 2：修复 Bug

```
fix(cart): 修复购物车总价计算错误

解决当商品数量超过 10 件时总价显示不准确的问题。

Fixes #789
```

### 场景 3：性能优化

```
perf(search): 优化搜索响应速度

商品搜索响应时间从平均 2 秒降至 0.3 秒。
```

### 场景 4：破坏性变更

```
feat(api)!: 升级到 API v2

BREAKING CHANGE: 移除了 /api/v1/users 端点，请迁移到 /api/v2/users。
迁移指南：https://docs.example.com/api-v2-migration

Closes #1000
```

### 场景 5：依赖更新

```
chore(deps): 升级 React 到 18.0

修复已知安全漏洞，提升渲染性能。
```

### 场景 6：CI 配置

```
ci: 添加自动化测试到 GitHub Actions

每次 PR 自动运行单元测试和 E2E 测试。
```

### 场景 7：重构

```
refactor(checkout): 简化结算流程代码

将结算步骤从 5 步减少到 3 步，代码更易维护，
用户可以更快完成购买。
```

### 场景 8：文档更新

```
docs: 新增快速开始指南

帮助新用户在 5 分钟内完成首次配置。
```

---

## FAQ（常见问题）

### Q1：初始开发阶段如何处理提交信息？

即使在 0.y.z 版本，也应遵循 Conventional Commits。第一个稳定版本是 1.0.0。

### Q2：提交类型是否区分大小写？

实现**不得**区分大小写，但推荐使用小写（`feat` 而非 `FEAT`），**除了** `BREAKING CHANGE` 必须大写。

### Q3：如果提交符合多个类型怎么办？

尽量拆分成多个提交。Conventional Commits 的优势之一是鼓励更有组织的提交。

### Q4：这会阻碍快速开发和迭代吗？

反而会加速。结构化的历史让团队更容易长期做出贡献。

### Q5：如何处理回滚？

使用 `revert` type，并在 body 中引用被回滚的提交 SHA：

```
revert: 回滚微信支付功能

This reverts commit 667ecc1654a317a13331b17617d973392f415f02.
```

---

## 检查清单

提交前检查：

- [ ] Type 正确（feat/fix/chore/docs 等）
- [ ] Subject ≤72 字符
- [ ] Description 使用祈使句、现在时态
- [ ] Description 首字母小写，无句号
- [ ] 如有 scope，格式正确：`type(scope):`
- [ ] 如有 body，与 description 空一行
- [ ] 如有破坏性变更，使用 `!` 或 BREAKING CHANGE
- [ ] 如有 footer，格式符合 git trailer
- [ ] **重点**：description 描述用户价值，避免技术术语

---

## 工具推荐

- **commitlint**：验证提交信息格式
- **commitizen**：交互式生成符合规范的提交信息
- **standard-version**：基于提交自动生成 CHANGELOG 和版本号
- **semantic-release**：全自动版本管理和发布

---

**参考资源**：
- [Conventional Commits 官方规范](https://www.conventionalcommits.org/)
- [语义化版本控制](https://semver.org/)
- [Angular 提交规范](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [Git Trailer 格式](https://git-scm.com/docs/git-interpret-trailers)
