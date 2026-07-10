#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  fail "usage: bash scripts/install.sh /path/to/target-repository"
fi

test -d "$1" || fail "target repository directory does not exist: $1"

TARGET_REPO="$(cd "$1" && pwd -P)"
PACKAGE_DIR="$ROOT_DIR/dist/.dev-cadence"
TARGET_DIR="$TARGET_REPO/.dev-cadence"

bash "$ROOT_DIR/scripts/build.sh"
test -d "$PACKAGE_DIR" || fail "build did not create dist/.dev-cadence"

STAGING_DIR="$(mktemp -d "$TARGET_REPO/.dev-cadence.install.XXXXXX")"
cleanup() {
  if [[ -n "${STAGING_DIR:-}" && -d "$STAGING_DIR" ]]; then
    rm -rf "$STAGING_DIR"
  fi
}
trap cleanup EXIT

cp -R "$PACKAGE_DIR/." "$STAGING_DIR"
rm -rf "$TARGET_DIR"
mv "$STAGING_DIR" "$TARGET_DIR"
STAGING_DIR=""

printf 'Installed Dev Cadence %s to %s\n' "$(<"$ROOT_DIR/version")" "$TARGET_DIR"
