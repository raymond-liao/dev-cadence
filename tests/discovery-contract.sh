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
assert_match "analysis stays conversational" 'analysis stages.*current conversation|current conversation.*analysis stages' "$DISCOVERY_SKILL"
assert_match "no process records" '[Mm]ust not create.*run manifest.*stage records.*confirmation records|[Dd]o not create.*run manifest.*stage records.*confirmation records' "$DISCOVERY_SKILL"
assert_match "no Discovery checkpoints" '[Mm]ust not require.*dedicated branch.*checkpoint|[Dd]o not require.*dedicated branch.*checkpoint' "$DISCOVERY_SKILL"
assert_match "ordinary Git rules" 'ordinary Git rules' "$DISCOVERY_SKILL"
assert_match "conversation-based continuation" 'current conversation.*user.*goal.*authoritative.*documents|authoritative.*documents.*current conversation' "$DISCOVERY_SKILL"
assert_not_match "legacy Discovery run directory" 'build/dev-cadence/discovery/' "$DISCOVERY_SKILL"
assert_not_match "legacy Discovery stage records" '01-background-and-problem\.md|02-goals-and-value\.md|03-scope-and-business-architecture\.md|05-product-design-confirmation-record\.md' "$DISCOVERY_SKILL"
assert_not_match "legacy Discovery manifest" 'Discovery manifest|manifest\.md|update the manifest|record.*manifest' "$DISCOVERY_SKILL"

for literal in \
  'Product And Technical Content Boundary' \
  'product requirement' \
  'business architecture content' \
  'external or product-level constraint' \
  'implementation suggestion' \
  'source-faithful' \
  'concrete code modules' \
  'database products' \
  'API paths' \
  'request or response schemas' \
  'protocol choices' \
  'deployment topology' \
  'retry or timeout implementation parameters' \
  '.dev-cadence/skills/open-question-registry/SKILL.md' \
  'technical input excluded from the product-design baseline' \
  'suggested resolution stage'
do
  assert_literal "Discovery content boundary $literal" "$literal" "$DISCOVERY_SKILL"
done

assert_match "meaning-based classification" 'classify.*meaning.*source|meaning.*source.*classif' "$DISCOVERY_SKILL"
assert_match "technical name is not confirmation" 'technical (name|product|term).*(must not|does not).*confirmed|must not.*technical (name|product|term).*confirmed' "$DISCOVERY_SKILL"
assert_match "product constraint result boundary" 'constraint.*required result|required result.*constraint' "$DISCOVERY_SKILL"
assert_literal "product constraints belong in PRD" 'Product-level constraints belong in the PRD, not Business Architecture.' "$DISCOVERY_SKILL"
assert_not_match "Business Architecture product constraint exception" 'Business Architecture.*unless recording an explicit product constraint' "$DISCOVERY_SKILL"
assert_match "measurable quality targets allowed" 'data residency.*regulatory.*compatibility.*performance.*availability.*security' "$DISCOVERY_SKILL"
assert_match "mechanism excluded from product baseline" 'database.*framework.*protocol.*cloud service.*module.*interface.*deployment' "$DISCOVERY_SKILL"
assert_match "authoritative technical handoff" 'Story.*Technical Task.*technical solution.*Decision|Decision.*technical solution.*Technical Task.*Story' "$DISCOVERY_SKILL"
assert_match "Registry fallback" 'no.*authoritative.*(document|owner).*(Open Question Registry|open-question-registry)|Open Question Registry.*no.*authoritative' "$DISCOVERY_SKILL"
assert_match "local product questions retained" 'PRD.*Business Architecture.*Open Questions|Open Questions.*PRD.*Business Architecture' "$DISCOVERY_SKILL"
assert_match "handoff is not acceptance" 'must not.*accepted technical decision|do not.*accepted technical decision' "$DISCOVERY_SKILL"
assert_match "initial boundary gate" 'Before.*initial.*baseline|initial.*baseline.*before' "$DISCOVERY_SKILL"
assert_match "incremental input boundary" 'incremental.*new input|new input.*incremental' "$DISCOVERY_SKILL"
assert_match "historical migration delegated to S-002" 'historical.*S-002|S-002.*historical' "$DISCOVERY_SKILL"

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
assert_not_match "temporary Discovery exception" 'Until S-013 is complete|Remove this exception when S-013 migrates Discovery' "$ENTRY_SKILL"

for flow in feature-dev bug-fix refactor; do
  assert_literal "entry direct $flow flow" ".dev-cadence/skills/$flow/SKILL.md" "$ENTRY_SKILL"
done

assert_match "AGENTS discovery trigger" 'product discovery|product ideas|requirements work' "$AGENTS_SNIPPET"

printf 'Discovery contract checks passed.\n'
