#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_test() {
  local test_script="$1"
  echo "==> ${test_script}"
  bash "${ROOT_DIR}/${test_script}"
}

run_command() {
  echo "==> $*"
  (cd "${ROOT_DIR}" && "$@")
}

run_test "tests/test-manifest.sh"
run_test "tests/test-shell-syntax.sh"
run_test "tests/test-codex-plugin-package.sh"
run_test "tests/test-plugin-official-rules.sh"
run_test "tests/test-sync-repo-contract.sh"
run_test "tests/test-current-contract-terms.sh"
run_test "tests/test-dry-run.sh"
run_test "tests/test-gate-enforcement.sh"
run_test "tests/test-spec-report.sh"
run_test "tests/test-codex-install-smoke.sh"
run_test "tests/cadence-clarify-visual/run-all.sh"
run_command node scripts/check-skill-package.mjs .
run_command node scripts/check-discipline-routes.mjs .
run_command node scripts/check-spec-artifacts.mjs templates
run_command git diff --check

echo "All tests passed"
