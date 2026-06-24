#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(mktemp -d /private/tmp/dev-cadence-delivery.XXXXXX)"
DRY_RUN_JSON="${REPO_DIR}/dry-run.json"
SUMMARY_FILE="${REPO_DIR}/summary.txt"
ZH_REPO_DIR="${REPO_DIR}/zh-warning-fixture"
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

mkdir -p "${ZH_REPO_DIR}/specs/sample"
cat > "${ZH_REPO_DIR}/.dev-cadence.yaml" <<'EOF'
dev_cadence:
  artifact_language: zh
EOF
cat > "${ZH_REPO_DIR}/specs/sample/00-brief.md" <<'EOF'
# Brief

This review report should have been written in Chinese prose.

```yaml
status: passed
```
EOF
if ! node "${ROOT_DIR}/scripts/check-spec-artifacts.mjs" "${ZH_REPO_DIR}/specs" > "${ZH_REPO_DIR}/check.out" 2> "${ZH_REPO_DIR}/check.err"; then
  cat "${ZH_REPO_DIR}/check.out" >&2
  cat "${ZH_REPO_DIR}/check.err" >&2
  exit 1
fi
grep -q "English-looking prose in zh artifact_language" "${ZH_REPO_DIR}/check.err"

node "${ROOT_DIR}/scripts/summarize-acceptance.mjs" \
  --specs-dir "${REPO_DIR}/specs" \
  --task-id "${TASK_ID}" > "${SUMMARY_FILE}"

test -f "${REPO_DIR}/specs/${TASK_ID}/00-brief.md"
test -f "${REPO_DIR}/specs/${TASK_ID}/08-acceptance.md"
test -d "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1"
test -f "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/pre-implementation-status.md"
test ! -e "${REPO_DIR}/.ai"
grep -q "Accepted by: Raymond" "${SUMMARY_FILE}"
grep -q "Acceptance: accepted_for_dry_run_scope" "${SUMMARY_FILE}"

MISSING_BASELINE_REPO="${REPO_DIR}/missing-baseline-fixture"
mkdir -p "${MISSING_BASELINE_REPO}/specs/missing-baseline/runs/implementation-001"
cat > "${MISSING_BASELINE_REPO}/specs/missing-baseline/00-brief.md" <<'EOF'
# Brief

```yaml
task_id: missing-baseline
selected_workflow: bugfix
task_class: S1
```
EOF
cat > "${MISSING_BASELINE_REPO}/specs/missing-baseline/03-tasks.md" <<'EOF'
# Tasks

```yaml
status: executable
task_class: S1
selected_workflow: bugfix
target_files:
  - src/app.py
```
EOF
cat > "${MISSING_BASELINE_REPO}/specs/missing-baseline/05-implementation.md" <<'EOF'
# Implementation

```yaml
status: implemented
changed_files:
  - src/app.py
```
EOF
cat > "${MISSING_BASELINE_REPO}/specs/missing-baseline/runs/implementation-001/diff-summary.md" <<'EOF'
# Diff Summary

```yaml
run_id: implementation-001
planned_files:
  - src/app.py
files_changed:
  - src/app.py
unplanned_changed_files: []
```
EOF
if node "${ROOT_DIR}/scripts/check-spec-artifacts.mjs" "${MISSING_BASELINE_REPO}/specs" > "${MISSING_BASELINE_REPO}/check.out" 2> "${MISSING_BASELINE_REPO}/check.err"; then
  cat "${MISSING_BASELINE_REPO}/check.out" >&2
  cat "${MISSING_BASELINE_REPO}/check.err" >&2
  echo "missing baseline fixture should fail" >&2
  exit 1
fi
grep -q "pre-implementation-status.md" "${MISSING_BASELINE_REPO}/check.err"
grep -q "untracked_files" "${MISSING_BASELINE_REPO}/check.err"

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
