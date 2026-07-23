#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY="$ROOT_DIR/src/workflows/using-dev-cadence/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_literal() {
  local label="$1" literal="$2" path="${3:-$ENTRY}"
  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_match() {
  local label="$1" pattern="$2" path="${3:-$ENTRY}"
  rg --no-ignore -n "$pattern" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1" pattern="$2" path="$3"
  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_literal "two-stage routing" "## Two-Stage Routing Decision"
assert_match "candidate reading" 'Stage 1.*Discover candidates'
assert_match "selection" 'Stage 2.*Select the action'
assert_match "one percent boundary" '1%.*does not automatically select or start'
assert_match "intent routing" 'intended outcome.*not on isolated keywords'

for path in \
  '.dev-cadence/workflows/backlog/SKILL.md' \
  '.dev-cadence/workflows/work-item-analysis/SKILL.md' \
  '.dev-cadence/workflows/architecture-design/SKILL.md' \
  '.dev-cadence/workflows/feature-dev/SKILL.md' \
  '.dev-cadence/workflows/bug-fix/SKILL.md' \
  '.dev-cadence/workflows/refactor/SKILL.md'; do
  assert_literal "available flow $path" "$path"
done

for category in \
  'New Work Item' \
  'Conforming Existing Card' \
  'Nonconforming Existing Card' \
  'Single-card Analysis' \
  'Product Analysis' \
  'Architecture Design' \
  'Feature' \
  'Bug Fix' \
  'Refactor' \
  'Ordinary Request'; do
  assert_literal "representative category $category" "$category"
done

for marker in '✅' '❌' '❓'; do
  assert_literal "routing marker $marker" "$marker"
done

assert_match "new card route" 'New Work Item.*Select `backlog`'
assert_match "conforming card route" 'Conforming Existing Card.*Select `backlog`.*do not recreate or reanalyze'
assert_match "nonconforming card route" 'Nonconforming Existing Card.*Select `backlog`.*preserve the source.*New Request'
assert_match "single card route" 'Single-card Analysis.*Select `work-item-analysis`.*only that card'
assert_match "product analysis outside" 'Product Analysis.*No Dev Cadence workflow applies.*outside this package'
assert_match "architecture explicit route" 'Architecture Design.*Select `architecture-design`'
assert_match "architecture state boundary" 'Architecture Repository State.*Do not start `architecture-design`'
assert_match "bug route" 'Bug Fix.*`bug-fix`'
assert_match "mixed intent clarification" 'Mixed Intent.*Ask one necessary routing clarification question'

assert_match "backlog owns admission" '`backlog`.*work-item admission|work-item admission.*`backlog`'
assert_match "analysis one card" '`work-item-analysis` only for exactly one existing conforming card'
assert_match "conforming bypass" 'conforming existing card may bypass creation and Work Item Analysis'
assert_match "backlog still required" 'must still enter Backlog before claim'
assert_match "nonconforming new request" 'nonconforming supplied card is preserved and treated as New Request input'
assert_match "missing card route" 'If either is absent, route to `backlog`'
assert_match "delivery cannot repair card" 'Do not create or repair a card inside a Delivery Workflow'
assert_match "ready Story route" 'Ready Story.*eligible.*`feature-dev`'
assert_match "Task route" 'Task.*eligible.*Delivery request'
assert_match "Bug route without Ready" 'Bug.*eligible.*`bug-fix` without.*Ready'

assert_not_match "removed discovery flow" '\.dev-cadence/workflows/discovery/SKILL\.md' "$ENTRY"
assert_not_match "removed planning flow" '\.dev-cadence/workflows/work-item-planning/SKILL\.md' "$ENTRY"
assert_not_match "batch analysis" 'selected batch|batch analysis' "$ENTRY"

for skill in backlog work-item-analysis architecture-design feature-dev bug-fix refactor; do
  assert_not_match \
    "duplicated routing matrix in $skill" \
    '^## Representative Routing Examples$' \
    "$ROOT_DIR/src/workflows/$skill/SKILL.md"
done

printf 'Routing contract checks passed.\n'
