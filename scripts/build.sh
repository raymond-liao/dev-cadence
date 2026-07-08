#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$ROOT_DIR/dist/.dev-cadence"

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

cp "$ROOT_DIR/version" "$TARGET_DIR/version"
cp "$ROOT_DIR/src/config.md" "$TARGET_DIR/config.md"
cp "$ROOT_DIR/README.md" "$TARGET_DIR/README.md"
cp "$ROOT_DIR/src/AGENTS-snippet.md" "$TARGET_DIR/AGENTS-snippet.md"
cp -R "$ROOT_DIR/src/skills" "$TARGET_DIR/skills"
cp -R "$ROOT_DIR/src/vendor" "$TARGET_DIR/vendor"
