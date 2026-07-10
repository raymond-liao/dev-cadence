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

mkdir -p "$TMP_DIR/repo/scripts"
cp "$CHECK_SCRIPT" "$TMP_DIR/repo/scripts/check-whitespace.sh"
git -C "$TMP_DIR/repo" init -q

printf 'clean\n' > "$TMP_DIR/repo/example.txt"
git -C "$TMP_DIR/repo" add example.txt scripts/check-whitespace.sh
git -C "$TMP_DIR/repo" -c user.name=Test -c user.email=test@example.com commit -qm "test: clean baseline"

bash "$TMP_DIR/repo/scripts/check-whitespace.sh" || fail "checker rejected a clean repository"

printf 'trailing space \n' > "$TMP_DIR/repo/example.txt"
git -C "$TMP_DIR/repo" add example.txt
git -C "$TMP_DIR/repo" -c user.name=Test -c user.email=test@example.com commit -qm "test: add whitespace error"

if bash "$TMP_DIR/repo/scripts/check-whitespace.sh" >/dev/null 2>&1; then
  fail "checker accepted a committed whitespace error"
fi

printf 'Whitespace contract checks passed.\n'
