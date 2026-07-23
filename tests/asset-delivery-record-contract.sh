#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY="$ROOT_DIR/src/workflows/using-dev-cadence/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_literal() {
  local label="$1" literal="$2" path="$3"
  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_match() {
  local label="$1" pattern="$2" path="$3"
  rg --no-ignore -n "$pattern" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1" pattern="$2" path="$3"
  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_literal "record model section" "## Workflow Record Models" "$ENTRY"
assert_match "Asset membership" 'Asset Workflow.*Backlog.*Work Item Analysis.*Architecture Design' "$ENTRY"
assert_match "Delivery membership" 'Delivery Workflow.*Feature Dev.*Bug Fix.*Refactor' "$ENTRY"
assert_match "Asset docs only" 'Asset Workflows only create or update durable authoritative assets under `docs/`' "$ENTRY"
assert_match "Asset no run records" 'must not create `build/dev-cadence/` run manifests.*stage records.*checkpoint commits' "$ENTRY"
assert_match "Asset no process metadata" 'must not write commit hashes, approver identities, approval timestamps, or workflow run status' "$ENTRY"
assert_match "new workflow classification" 'new workflow.*exactly one record model' "$ENTRY"
assert_match "no model mixing" 'must not mix the models' "$ENTRY"
assert_match "Delivery evidence" 'complete delivery evidence chain.*requirements, diagnosis, or refactor-scope records' "$ENTRY"

for skill in backlog work-item-analysis architecture-design; do
  path="$ROOT_DIR/src/workflows/$skill/SKILL.md"
  assert_literal "$skill Asset declaration" "This is an Asset Workflow." "$path"
  assert_match "$skill no run records" 'must not create.*run manifest|must not create `build/dev-cadence/` run manifests' "$path"
  assert_not_match "$skill delivery evidence filenames" '04-code-review-report\.md|01-requirements\.md|02-technical-solution\.md|03-implementation-plan\.md' "$path"
done

for skill in feature-dev bug-fix refactor; do
  path="$ROOT_DIR/src/workflows/$skill/SKILL.md"
  assert_literal "$skill Delivery declaration" "This is a Delivery Workflow." "$path"
  assert_match "$skill evidence chain" 'complete.*evidence chain|evidence chain.*complete' "$path"
done

assert_not_match "removed Discovery model" 'Asset Workflow:.*Discovery' "$ENTRY"
assert_not_match "removed planning model" 'Asset Workflow:.*Work Item Planning' "$ENTRY"

printf 'Asset and Delivery record contract checks passed.\n'
