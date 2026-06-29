#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

node "${ROOT_DIR}/tests/cadence-clarify-visual/contract.test.mjs"
node "${ROOT_DIR}/tests/cadence-clarify-visual/server.test.mjs"
node "${ROOT_DIR}/tests/cadence-clarify-visual/lifecycle.test.mjs"

echo "cadence clarify visual tests ok"
