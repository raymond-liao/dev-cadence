#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK_SCRIPT="$ROOT_DIR/scripts/check-whitespace.sh"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

test -f "$CHECK_SCRIPT" || fail "missing whitespace checker: scripts/check-whitespace.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p \
  "$TMP_DIR/repo/scripts" \
  "$TMP_DIR/repo/src/vendor" \
  "$TMP_DIR/repo/.dev-cadence/vendor"
cp "$CHECK_SCRIPT" "$TMP_DIR/repo/scripts/check-whitespace.sh"
git -C "$TMP_DIR/repo" init -q

printf 'clean\n' > "$TMP_DIR/repo/example.txt"
printf 'vendored trailing space \n' > "$TMP_DIR/repo/src/vendor/source-copy.md"
printf 'installed vendored trailing space \n' > "$TMP_DIR/repo/.dev-cadence/vendor/installed-copy.md"
git -C "$TMP_DIR/repo" add \
  example.txt \
  scripts/check-whitespace.sh \
  src/vendor/source-copy.md \
  .dev-cadence/vendor/installed-copy.md
git -C "$TMP_DIR/repo" -c user.name=Test -c user.email=test@example.com commit -qm "test: clean baseline"

bash "$TMP_DIR/repo/scripts/check-whitespace.sh" || fail "checker rejected a clean repository"

printf 'new source vendored trailing space \n' > "$TMP_DIR/repo/src/vendor/new-source-copy.md"
printf 'new installed vendored trailing space \n' > "$TMP_DIR/repo/.dev-cadence/vendor/new-installed-copy.md"
git -C "$TMP_DIR/repo" add \
  src/vendor/new-source-copy.md \
  .dev-cadence/vendor/new-installed-copy.md

bash "$TMP_DIR/repo/scripts/check-whitespace.sh" || fail "checker rejected newly staged vendored files"

printf 'trailing space \n' > "$TMP_DIR/repo/example.txt"
git -C "$TMP_DIR/repo" add example.txt
git -C "$TMP_DIR/repo" -c user.name=Test -c user.email=test@example.com commit -qm "test: add whitespace error"

if bash "$TMP_DIR/repo/scripts/check-whitespace.sh" >/dev/null 2>&1; then
  fail "checker accepted a committed whitespace error"
fi

printf 'Whitespace contract checks passed.\n'
