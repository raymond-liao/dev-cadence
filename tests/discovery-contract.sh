#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISCOVERY_SKILL="$ROOT_DIR/src/skills/discovery/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"
AGENTS_SNIPPET="$ROOT_DIR/src/AGENTS-snippet.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  local label="$1"
  local path="$2"

  test -f "$path" || fail "missing $label: ${path#"$ROOT_DIR/"}"
}

assert_literal() {
  local label="$1"
  local literal="$2"
  local path="$3"

  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null || fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"

  rg --no-ignore -n "$pattern" "$path" >/dev/null || fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"

  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_file "Discovery skill" "$DISCOVERY_SKILL"

assert_literal \
  "Discovery description" \
  "description: Use when a user wants to explore an incomplete product idea, business problem, or product direction and create the first PRD and Business Architecture baseline in a target project." \
  "$DISCOVERY_SKILL"

assert_literal \
  "Discovery stage sequence" \
  "Background And Problem Exploration -> Goal And Value Definition -> Scope And Business Architecture Analysis -> Product Design Baseline Creation -> Product Design Confirmation" \
  "$DISCOVERY_SKILL"

for literal in \
  'build/dev-cadence/discovery/<discovery-slug>/manifest.md' \
  '01-background-and-problem.md' \
  '02-goals-and-value.md' \
  '03-scope-and-business-architecture.md' \
  '05-product-design-confirmation-record.md' \
  'docs/product-design/prd.md' \
  'docs/product-design/business-architecture.md'
do
  assert_literal "Discovery artifact $literal" "$literal" "$DISCOVERY_SKILL"
done

for literal in \
  'explicit user confirmations' \
  'existing repository documents' \
  'Open Questions' \
  'Rejected Directions' \
  'Future Scope' \
  'Document Information' \
  'Last Updated' \
  'Change Log' \
  'Business Actors And Responsibilities' \
  'Business Domains And Boundaries' \
  'Business Capability Map' \
  'Value Streams And Business Processes' \
  'Business Objects And Relationships' \
  'State And Lifecycle Models' \
  'Business Rules And Policies' \
  'Business Events And External Boundaries'
do
  assert_literal "Discovery rule $literal" "$literal" "$DISCOVERY_SKILL"
done

assert_match "input precedence" 'prefer.*explicit user confirmations.*existing repository documents' "$DISCOVERY_SKILL"
assert_match "conflict preservation" 'conflict.*Open Questions|Open Questions.*conflict' "$DISCOVERY_SKILL"
assert_literal "single unresolved section" 'Use `Open Questions` as the only unresolved-material section.' "$DISCOVERY_SKILL"
assert_not_match "Draft Ideas heading" '^#{1,6} Draft Ideas$' "$DISCOVERY_SKILL"
assert_not_match "Pending Decisions heading" '^#{1,6} Pending Decisions$' "$DISCOVERY_SKILL"
assert_match "existing document refusal" 'either.*product-design document.*exists|either.*prd\.md.*business-architecture\.md.*exists' "$DISCOVERY_SKILL"
assert_match "no document approval metadata" 'do not.*approval metadata|must not.*approval metadata' "$DISCOVERY_SKILL"
assert_match "one final confirmation" 'one.*consolidated.*confirmation' "$DISCOVERY_SKILL"
assert_literal "checkpoint is not confirmation" 'A checkpoint commit does not count as user confirmation.' "$DISCOVERY_SKILL"
assert_match "ignored run records stay ignored" 'ignored.*run records.*do not force-add|do not force-add.*ignored.*run records' "$DISCOVERY_SKILL"
assert_match "no push without request" 'Do not push unless the user explicitly asks' "$DISCOVERY_SKILL"

for pattern in \
  'Do not create.*Feature.*Story.*Bug.*Technical Task' \
  'Do not.*technical architecture' \
  'Do not.*database migrations|Do not.*migrations' \
  'Do not.*application code'
do
  assert_match "Discovery boundary $pattern" "$pattern" "$DISCOVERY_SKILL"
done

assert_literal "entry Discovery flow" '.dev-cadence/skills/discovery/SKILL.md' "$ENTRY_SKILL"
assert_match "entry initial discovery route" 'incomplete product idea|broad product idea' "$ENTRY_SKILL"
assert_match "entry initial business architecture route" 'initial.*Business Architecture|first.*Business Architecture' "$ENTRY_SKILL"
assert_match "entry existing baseline boundary" 'existing.*PRD|existing.*product-design' "$ENTRY_SKILL"

for flow in feature-dev bug-fix refactor; do
  assert_literal "entry direct $flow flow" ".dev-cadence/skills/$flow/SKILL.md" "$ENTRY_SKILL"
done

assert_match "AGENTS discovery trigger" 'product discovery|product ideas|requirements work' "$AGENTS_SNIPPET"

printf 'Discovery contract checks passed.\n'
