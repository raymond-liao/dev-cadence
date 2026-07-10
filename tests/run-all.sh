#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT_DIR/tests/package-contract.sh"
bash "$ROOT_DIR/tests/workflow-symmetry.sh"
bash "$ROOT_DIR/tests/skill-description-contract.sh"
bash "$ROOT_DIR/tests/install-contract.sh"
bash "$ROOT_DIR/tests/whitespace-contract.sh"
