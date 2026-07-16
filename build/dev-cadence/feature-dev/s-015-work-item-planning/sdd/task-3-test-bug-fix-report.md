# S-015 Task 3 test_bug 修复报告

- 日期：2026-07-16
- 失败 ID：S015-T3-PKG-001
- 分类：test_bug
- 修复文件：`tests/package-contract.sh`

## 问题

`tests/package-contract.sh` 第 103/104 行使用双引号包裹含反引号的断言字符串，shell 发生命令替换，把 ``Ready``、``feature-dev``、``bug-fix`` 当成命令执行，导致 `command not found`，并让包契约检查错误地失败。

## 修复

保持断言语义不变，将两条断言改为安全的单引号字符串，避免 shell command substitution，同时继续精确匹配原有包含反引号的文案。

## 验证

1. `bash tests/package-contract.sh`：通过
2. `bash scripts/check-all.sh`：通过
3. `bash scripts/check-whitespace.sh`：通过

## 结果

稳定失败已消除；断言未放宽、未删除，且未修改 `tests/package-contract.sh` 之外的受限源码文件。
