#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_NAME="${1:-}"

case "$HOOK_NAME" in
  session-start-codex)
    exec "${SCRIPT_DIR}/session-start-codex"
    ;;
  *)
    echo "Unknown hook: ${HOOK_NAME}" >&2
    exit 2
    ;;
esac
