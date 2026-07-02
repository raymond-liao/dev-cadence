#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
REPO_DIR="$(mktemp -d "${TMP_ROOT}/dev-cadence-delivery.XXXXXX")"
DRY_RUN_JSON="${REPO_DIR}/dry-run.json"
SUMMARY_FILE="${REPO_DIR}/summary.txt"
ZH_REPO_DIR="${REPO_DIR}/zh-warning-fixture"
ZH_DRY_RUN_REPO="${REPO_DIR}/zh-dry-run"
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
node "${ROOT_DIR}/scripts/check-gates.mjs" \
  --specs-dir "${REPO_DIR}/specs/records" \
  --task-id "${TASK_ID}"

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

mkdir -p "${ZH_DRY_RUN_REPO}"
node "${ROOT_DIR}/scripts/sync-repo-contract.mjs" init --repo-dir "${ZH_DRY_RUN_REPO}" --json > /dev/null
cat > "${ZH_DRY_RUN_REPO}/.dev-cadence.yaml" <<'EOF'
dev_cadence:
  artifact_language: zh
EOF
node "${ROOT_DIR}/scripts/run-delivery-dry-run.mjs" \
  --repo-dir "${ZH_DRY_RUN_REPO}" \
  --plugin-dir "${ROOT_DIR}" \
  --task-id "zh-login" \
  --goal "实现登录功能" \
  --requested-by "Raymond" \
  --accepted-by "Raymond" \
  --json > "${ZH_DRY_RUN_REPO}/dry-run.json"
grep -q "本 artifact 集用于验证 Dev Cadence 交付路由和证据生成" "${ZH_DRY_RUN_REPO}/specs/records/zh-login/00-brief.md"
grep -q "生成自 CLI 输入和 Dev Cadence 仓库契约" "${ZH_DRY_RUN_REPO}/specs/records/zh-login/01-requirements.md"
grep -q "产品行为未由 dry run 验证" "${ZH_DRY_RUN_REPO}/specs/records/zh-login/08-acceptance.md"
node "${ROOT_DIR}/scripts/check-spec-artifacts.mjs" "${ZH_DRY_RUN_REPO}/specs/records" --warnings-as-errors

node "${ROOT_DIR}/scripts/summarize-acceptance.mjs" \
  --specs-dir "${REPO_DIR}/specs/records" \
  --task-id "${TASK_ID}" > "${SUMMARY_FILE}"

node "${ROOT_DIR}/scripts/summarize-acceptance.mjs" \
  --specs-dir "${ZH_DRY_RUN_REPO}/specs/records" \
  --task-id "zh-login" > "${ZH_DRY_RUN_REPO}/summary.txt"
grep -q "验收摘要: zh-login" "${ZH_DRY_RUN_REPO}/summary.txt"
grep -q "目标: 实现登录功能" "${ZH_DRY_RUN_REPO}/summary.txt"
grep -q "## 可审核证据" "${ZH_DRY_RUN_REPO}/summary.txt"
grep -q "已记录 Raymond 的验收" "${ZH_DRY_RUN_REPO}/summary.txt"
if grep -q "Acceptance Summary" "${ZH_DRY_RUN_REPO}/summary.txt"; then
  echo "zh acceptance summary should not render Human-facing headings in English" >&2
  exit 1
fi

test -f "${REPO_DIR}/specs/records/${TASK_ID}/00-brief.md"
grep -q "### Task 1:" "${REPO_DIR}/specs/records/${TASK_ID}/03-tasks.md"
for artifact in \
  00-brief.md \
  01-requirements.md \
  02-design.md \
  03-tasks.md \
  04-test-plan.md \
  05-implementation.md \
  06-test-report.md \
  07-review-report.md \
  08-acceptance.md; do
  if grep -q '```yaml' "${REPO_DIR}/specs/records/${TASK_ID}/${artifact}"; then
    echo "generated spec artifact should be Markdown-first without fenced YAML: ${artifact}" >&2
    exit 1
  fi
done
for artifact in \
  run-context.md \
  pre-implementation-status.md \
  execution-report.md \
  tool-log.md \
  test-log.md \
  diff-summary.md \
  permission-decisions.md; do
  if grep -q '```yaml' "${REPO_DIR}/specs/records/${TASK_ID}/runs/${TASK_ID}-dry-run-1/${artifact}"; then
    echo "generated run artifact should be readable Markdown/schema-lite without fenced YAML: ${artifact}" >&2
    exit 1
  fi
done
grep -q "## What this run is allowed to do" "${REPO_DIR}/specs/records/${TASK_ID}/runs/${TASK_ID}-dry-run-1/run-context.md"
grep -q "Allowed write paths:" "${REPO_DIR}/specs/records/${TASK_ID}/runs/${TASK_ID}-dry-run-1/run-context.md"
grep -q "## Worktree before implementation" "${REPO_DIR}/specs/records/${TASK_ID}/runs/${TASK_ID}-dry-run-1/pre-implementation-status.md"
grep -q "Implementation Authorized: false" "${REPO_DIR}/specs/records/${TASK_ID}/runs/${TASK_ID}-dry-run-1/pre-implementation-status.md"
grep -q "## What happened" "${REPO_DIR}/specs/records/${TASK_ID}/runs/${TASK_ID}-dry-run-1/execution-report.md"
grep -q "Scope Reconciliation Status: passed_no_product_changes" "${REPO_DIR}/specs/records/${TASK_ID}/runs/${TASK_ID}-dry-run-1/diff-summary.md"
"${ROOT_DIR}/skills/cadence-subagent-development/scripts/task-brief" \
  "${REPO_DIR}/specs/records/${TASK_ID}/03-tasks.md" \
  1 \
  "${REPO_DIR}/task-1-brief.md" > /dev/null
grep -q "### Task 1:" "${REPO_DIR}/task-1-brief.md"
if grep -q "## Gate G3" "${REPO_DIR}/task-1-brief.md"; then
  echo "task brief should stop before the Gate G3 section" >&2
  exit 1
fi
test -f "${REPO_DIR}/specs/records/${TASK_ID}/08-acceptance.md"
test -d "${REPO_DIR}/specs/records/${TASK_ID}/runs/${TASK_ID}-dry-run-1"
test -f "${REPO_DIR}/specs/records/${TASK_ID}/runs/${TASK_ID}-dry-run-1/pre-implementation-status.md"
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

if node "${ROOT_DIR}/scripts/check-spec-artifacts.mjs" "${MISSING_BASELINE_REPO}/specs/missing-baseline" > "${MISSING_BASELINE_REPO}/task-check.out" 2> "${MISSING_BASELINE_REPO}/task-check.err"; then
  cat "${MISSING_BASELINE_REPO}/task-check.out" >&2
  cat "${MISSING_BASELINE_REPO}/task-check.err" >&2
  echo "task directory missing baseline fixture should fail" >&2
  exit 1
fi
grep -q "pre-implementation-status.md" "${MISSING_BASELINE_REPO}/task-check.err"

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
