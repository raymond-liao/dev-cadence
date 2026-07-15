#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_literal() {
  local label="$1"
  local literal="$2"

  rg --no-ignore -F -n -- "$literal" "$ENTRY_SKILL" >/dev/null ||
    fail "missing $label in ${ENTRY_SKILL#"$ROOT_DIR/"}"
}

assert_match() {
  local label="$1"
  local pattern="$2"

  rg --no-ignore -n "$pattern" "$ENTRY_SKILL" >/dev/null ||
    fail "missing $label in ${ENTRY_SKILL#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"

  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_literal "two-stage routing section" "## Two-Stage Routing Decision"
assert_match "candidate discovery stage" 'Stage 1.*candidate|candidate.*read.*skill'
assert_match "selection stage" 'Stage 2.*select|select.*clarify.*handle.*normally'
assert_match "one-percent is not automatic selection" '1%.*does not.*automatically|does not.*automatically.*workflow'

for category in \
  'Initial Discovery' \
  'Incremental Discovery' \
  'Feature' \
  'Bug Fix' \
  'Refactor' \
  'Ordinary Request'
do
  assert_literal "representative category $category" "$category"
done

for marker in '✅' '❌' '❓'; do
  assert_literal "routing marker $marker" "$marker"
done

assert_match "initial baseline route" 'first.*PRD|first.*product-design'
assert_match "existing baseline boundary" 'existing.*PRD|existing.*product-design'
assert_match "incremental route requires intent and candidate" 'intent.*(credible|trusted).*candidate|(credible|trusted).*candidate.*intent'
assert_match "incremental representative route" 'Incremental Discovery.*Select `discovery`.*credible.*candidate|credible.*candidate.*Select `discovery`'
assert_not_match "obsolete unsupported incremental route" 'incremental reconciliation, which is not currently supported|installed initial `discovery` flow.*existing product-design baseline' "$ENTRY_SKILL"
assert_match "missing document does not trigger discovery" 'missing.*PRD.*does not|absence.*PRD.*does not'
assert_match "bug route" 'already.*expected'
assert_match "expected behavior change route" 'intentionally change.*expected behavior'
assert_match "feature route" 'add.*behavior|new system-visible behavior'
assert_match "behavior-preserving refactor route" 'without intentionally changing expected behavior'
assert_match "repository state is insufficient" 'repository state.*does not.*trigger|does not.*trigger.*repository state'
assert_match "one routing clarification question" 'one.*routing clarification question|one necessary.*clarification question'
assert_match "examples are not keyword matching" 'not.*keyword|keywords.*not'
assert_match "new workflow review rule" 'new workflow.*review|review.*new workflow'

for skill in discovery feature-dev bug-fix refactor; do
  assert_not_match \
    "duplicated routing matrix in $skill" \
    '^## Representative Routing Examples$' \
    "$ROOT_DIR/src/skills/$skill/SKILL.md"
done

printf 'Routing contract checks passed.\n'
