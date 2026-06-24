#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKETPLACE_DIR="${ROOT_DIR}/dist/codex"
PLUGIN_SELECTOR="dev-cadence@dev-cadence-local"

usage() {
  cat <<'EOF'
Usage: ./deploy-local.sh [options]

Build and install the local dev-cadence Codex Plugin package.

Options:
  --skip-marketplace-add  Skip marketplace registration and only install the plugin.
  -h, --help              Show this help text.

Environment:
  CODEX_HOME              Optional Codex home override. Useful for smoke tests.
EOF
}

SKIP_MARKETPLACE_ADD=0

for arg in "$@"; do
  case "${arg}" in
    --skip-marketplace-add)
      SKIP_MARKETPLACE_ADD=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR unknown option: ${arg}" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v codex > /dev/null 2>&1; then
  echo "ERROR codex CLI not found in PATH" >&2
  exit 1
fi

echo "==> Build local marketplace package"
node "${ROOT_DIR}/scripts/package-codex-plugin.mjs" --clean

if [[ "${SKIP_MARKETPLACE_ADD}" != "1" ]]; then
  echo "==> Register local marketplace"
  codex plugin marketplace add "${MARKETPLACE_DIR}"
fi

echo "==> Install local plugin"
codex plugin add "${PLUGIN_SELECTOR}"

echo "==> Installed ${PLUGIN_SELECTOR}"
echo "Open a new Codex thread to reload plugin skills."
