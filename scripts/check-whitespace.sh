#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

if git grep -n -I -E '[[:blank:]]+$' -- . ':(exclude)src/vendor/**'; then
  printf 'FAIL: tracked source files contain trailing whitespace.\n' >&2
  exit 1
fi

git diff --check
git diff --cached --check
