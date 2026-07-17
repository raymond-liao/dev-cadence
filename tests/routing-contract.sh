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
  'Work Item Portfolio Planning' \
  'Direct Work Item Intake' \
  'Work Item Analysis' \
  'Discovery Boundary' \
  'Feature' \
  'Bug Fix' \
  'Refactor' \
  'Delivery Handoff' \
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
assert_match "work item planning route" 'Work Item Portfolio Planning.*Select `work-item-planning`|Select `work-item-planning`.*Work Item Portfolio Planning'
assert_match "direct work item intake route" 'Direct Work Item Intake.*Select `work-item-planning`|Select `work-item-planning`.*Direct Work Item Intake'
assert_match "work item analysis route" 'Work Item Analysis.*Select `work-item-analysis`|Select `work-item-analysis`.*Work Item Analysis'
assert_match "work item analysis batch route" 'selected batch of Story, Task, or Bug definitions|Story, Task, or Bug definition.*batch'
assert_match "work item analysis boundary" 'detailed work-item definition analysis rather than portfolio planning or delivery execution|does not replace downstream delivery workflows'
assert_match "work item planning asset boundary" 'work-item-planning.*Asset Workflow.*must not create Delivery run records|must not create Delivery run records.*work-item-planning'
assert_match "work item discovery boundary" 'Discovery Boundary.*must not define or reinterpret|must not define or reinterpret.*Discovery Boundary'
assert_match "work item repository state boundary" 'Do not auto-start `work-item-planning` merely because the repository already contains Story cards, Task cards, Bug cards, Backlog entries, or a Story Map; repository state alone does not trigger the workflow\.'
assert_match "delivery handoff route" 'Delivery Handoff.*Select `feature-dev`, `bug-fix`, or `refactor`|Select `feature-dev`, `bug-fix`, or `refactor`.*Delivery Handoff'
assert_match "Journey baseline route" 'User Journey.*Feature.*Select `discovery`|Select `discovery`.*User Journey.*Feature'
assert_match "product Feature ownership" 'product.*Feature.*Discovery|Discovery.*product.*Feature'
assert_match "implementation Feature boundary" 'implement.*Feature.*feature-dev|feature-dev.*implement.*Feature'
assert_match "routing uses intent" 'Feature.*intent|intent.*Feature'
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

for skill in discovery feature-dev bug-fix refactor work-item-planning work-item-analysis; do
  assert_not_match \
    "duplicated routing matrix in $skill" \
    '^## Representative Routing Examples$' \
    "$ROOT_DIR/src/skills/$skill/SKILL.md"
done

printf 'Routing contract checks passed.\n'
