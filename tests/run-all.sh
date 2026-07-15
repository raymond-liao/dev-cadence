#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT_DIR/tests/package-contract.sh"
bash "$ROOT_DIR/tests/asset-delivery-record-contract.sh"
bash "$ROOT_DIR/tests/architecture-design-contract.sh"
bash "$ROOT_DIR/tests/discovery-contract.sh"
bash "$ROOT_DIR/tests/document-conventions-contract.sh"
bash "$ROOT_DIR/tests/open-question-registry-contract.sh"
bash "$ROOT_DIR/tests/routing-contract.sh"
bash "$ROOT_DIR/tests/workflow-symmetry.sh"
bash "$ROOT_DIR/tests/skill-description-contract.sh"
bash "$ROOT_DIR/tests/install-contract.sh"
bash "$ROOT_DIR/tests/whitespace-contract.sh"
