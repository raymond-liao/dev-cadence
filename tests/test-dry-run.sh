#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(mktemp -d /private/tmp/dev-cadence-delivery.XXXXXX)"
DRY_RUN_JSON="${REPO_DIR}/dry-run.json"
SUMMARY_FILE="${REPO_DIR}/summary.txt"
TASK_ID="acceptance-login"
trap 'rm -rf "${REPO_DIR}"' EXIT

node "${ROOT_DIR}/scripts/sync-repo-contract.mjs" init --repo-dir "${REPO_DIR}" --json > /dev/null

node "${ROOT_DIR}/scripts/run-delivery-dry-run.mjs" \
  --repo-dir "${REPO_DIR}" \
  --plugin-dir "${ROOT_DIR}" \
  --task-id "${TASK_ID}" \
  --goal "Develop a login feature" \
  --requested-by "Raymond" \
  --accepted-by "Raymond" \
  --json > "${DRY_RUN_JSON}"

node "${ROOT_DIR}/scripts/check-spec-artifacts.mjs" "${REPO_DIR}/specs"

node "${ROOT_DIR}/scripts/summarize-acceptance.mjs" \
  --specs-dir "${REPO_DIR}/specs" \
  --task-id "${TASK_ID}" > "${SUMMARY_FILE}"

test -f "${REPO_DIR}/specs/${TASK_ID}/00-brief.md"
test -f "${REPO_DIR}/specs/${TASK_ID}/08-acceptance.md"
test -d "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1"
test ! -e "${REPO_DIR}/.ai"
grep -q "Accepted by: Raymond" "${SUMMARY_FILE}"
grep -q "Acceptance: accepted_for_dry_run_scope" "${SUMMARY_FILE}"

node --input-type=module - "${DRY_RUN_JSON}" <<'NODE'
import fs from 'node:fs';

const report = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(report.selected_workflow === 'feature-dev', 'login goal must route to feature-dev');
assert(report.task_class === 'S1', 'login goal must classify as S1');
assert(report.acceptance_status === 'accepted_for_dry_run_scope', 'dry run must record accepted status');
assert(report.scope_reconciliation_status === 'passed_no_product_changes', 'dry run must avoid product changes');
assert(Array.isArray(report.artifact_paths) && report.artifact_paths.length > 0, 'dry run must report artifacts');

console.log('delivery dry run ok');
NODE
