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

assert_block() {
  local label="$1"
  local block="$2"
  local path="$3"

  rg --no-ignore -U -F -n -- "$block" "$path" >/dev/null || fail "missing $label in ${path#"$ROOT_DIR/"}"
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
  "description: Use when a user wants to explore a product idea or update an existing product-design baseline in a target project." \
  "$DISCOVERY_SKILL"

assert_literal \
  "User Journey output" \
  "docs/product-design/user-journey.md" \
  "$DISCOVERY_SKILL"

assert_literal "Journey analysis stage" 'User Journey Analysis' "$DISCOVERY_SKILL"
assert_literal "Journey confirmation stage" 'User Journey Confirmation' "$DISCOVERY_SKILL"
assert_literal "derivation stage" 'PRD And Business Architecture Derivation' "$DISCOVERY_SKILL"
assert_literal \
  "Discovery stage sequence" \
  "Background And Problem Exploration -> User Journey Analysis -> User Journey Confirmation -> PRD And Business Architecture Derivation -> Product Design Confirmation" \
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
assert_match "incremental intent and candidate trigger" 'intent.*update.*existing.*(baseline|product-design).*(credible|trusted).*candidate|(credible|trusted).*candidate.*intent.*update' "$DISCOVERY_SKILL"
assert_match "no candidate does not fall back" 'no.*(credible|trusted).*candidate.*must not.*(initial|first-time)|must not.*(initial|first-time).*no.*(credible|trusted).*candidate' "$DISCOVERY_SKILL"
assert_match "content based candidate discovery" 'content.*not.*(path|file name)|not.*(path|file name).*content' "$DISCOVERY_SKILL"
for excluded in '.dev-cadence/' 'dist/' 'build/' 'vendor/' 'node_modules/' '.git/'; do
  assert_literal "candidate scan excludes $excluded" "$excluded" "$DISCOVERY_SKILL"
done
assert_match "multiple candidate authority confirmation" 'multiple.*candidate.*confirm.*authoritative|confirm.*authoritative.*multiple.*candidate' "$DISCOVERY_SKILL"
assert_match "non-standard path migration choice" 'non-standard.*(path|file name).*confirm.*migrat|confirm.*migrat.*non-standard' "$DISCOVERY_SKILL"
assert_match "combined document split choice" 'combined.*document.*confirm.*split|confirm.*split.*combined.*document' "$DISCOVERY_SKILL"
assert_match "incremental proposal before mutation" 'incremental mode.*(proposal|proposed revised baseline).*(must not|do not).*modif.*authoritative|authoritative.*unchanged.*(proposal|confirmation)' "$DISCOVERY_SKILL"
assert_match "feedback updates proposal only" '(feedback|rejection).*(proposal|proposed revised baseline).*authoritative.*unchanged|authoritative.*unchanged.*(feedback|rejection)' "$DISCOVERY_SKILL"
assert_match "confirmed atomic baseline write" 'After.*confirm.*atomic.*(write|apply)|atomic.*(write|apply).*after.*confirm' "$DISCOVERY_SKILL"
assert_match "supporting maintenance after confirmation" 'supporting asset maintenance.*after.*confirm|after.*confirm.*supporting asset maintenance' "$DISCOVERY_SKILL"
assert_match "no incremental draft files" 'Do not.*(draft|proposal).*(file|process artifact)|must not.*(draft|proposal).*(file|process artifact)' "$DISCOVERY_SKILL"
assert_match "independent product document versions" 'PRD.*Business Architecture.*independent.*version|independent.*version.*PRD.*Business Architecture' "$DISCOVERY_SKILL"
assert_match "combined document responsibility versions" 'combined document.*`PRD Version`.*`Business Architecture Version`|`PRD Version`.*`Business Architecture Version`.*combined document' "$DISCOVERY_SKILL"
assert_match "combined responsibility change log" 'combined document.*Change Log.*responsibility|Change Log.*responsibility.*combined document' "$DISCOVERY_SKILL"
assert_match "combined path reports two versions" 'same.*path.*(PRD|product).*[Vv]ersion.*Business Architecture.*[Vv]ersion|one path.*two.*responsibility.*version' "$DISCOVERY_SKILL"
assert_match "non-material change keeps version" 'spelling.*formatting.*path.*file name.*link.*must not.*version|must not.*version.*spelling.*formatting' "$DISCOVERY_SKILL"
assert_match "historical mixed content confirmation" 'historical mixed.*explicit.*confirm|explicit.*confirm.*historical mixed' "$DISCOVERY_SKILL"
assert_match "resolved local questions removed" 'confirmed.*remove.*Open Questions|remove.*Open Questions.*confirmed' "$DISCOVERY_SKILL"
assert_match "registry coordination" 'Registry.*Change Log|Change Log.*Registry' "$DISCOVERY_SKILL"
assert_match "work item impact handoff" 'work-item-planning.*impact|impact.*work-item-planning' "$DISCOVERY_SKILL"
assert_match "current draft remains editable" 'current.*Discovery.*(draft|working baseline).*(feedback|rejection|changes).*edit|edit.*current.*Discovery.*(draft|working baseline)' "$DISCOVERY_SKILL"
assert_match "startup baseline snapshot" 'At.*workflow start.*record|workflow start.*whether.*document.*exist' "$DISCOVERY_SKILL"
assert_match "no document approval metadata" 'do not.*approval metadata|must not.*approval metadata' "$DISCOVERY_SKILL"
assert_match "two confirmation gates" 'two confirmation gates|two.*confirmation.*gates' "$DISCOVERY_SKILL"
assert_match "Journey gate blocks derivation" 'User Journey.*confirmed.*before.*PRD.*Business Architecture|do not.*derive.*PRD.*Business Architecture.*until.*User Journey.*confirmed' "$DISCOVERY_SKILL"
assert_match "Journey identity" 'J-nnn|J-[0-9]{3}' "$DISCOVERY_SKILL"
assert_match "Feature identity" 'F-nnn|F-[0-9]{3}' "$DISCOVERY_SKILL"
assert_literal "User Journey contract heading" '### User Journey Contract' "$DISCOVERY_SKILL"
assert_block \
  "User Journey section schema" \
  $'Document Information\nJourney ID\nBusiness Line And Boundary\nJourney Map\nFeature Definitions\nOpen Questions\nRejected Directions\nChange Log' \
  "$DISCOVERY_SKILL"
assert_literal "Journey Map format" 'normal Markdown Table' "$DISCOVERY_SKILL"
assert_match "Journey Map role rows" 'Rows represent roles' "$DISCOVERY_SKILL"
assert_match "Journey Map ordered columns" 'columns represent.*business sequence.*left to right' "$DISCOVERY_SKILL"
assert_match "Journey Map inherited empty headers" 'contiguous.*empty.*column headers.*inherits.*nearest.*non-empty.*stage header.*left' "$DISCOVERY_SKILL"
assert_literal "Feature definition fields" 'ID | Type | Title | Description' "$DISCOVERY_SKILL"
assert_match "Feature types" 'Offline.*System|System.*Offline' "$DISCOVERY_SKILL"
assert_match "stable Feature identity" 'rename.*Type.*retain.*ID|retain.*ID.*rename.*Type' "$DISCOVERY_SKILL"
assert_match "shared Feature identity" 'multiple roles.*same Feature|same Feature.*multiple roles' "$DISCOVERY_SKILL"
assert_match "PRD traceability" 'Product Requirement.*Journey.*Feature' "$DISCOVERY_SKILL"
assert_match "Business Architecture traceability" 'Business Architecture.*Journey.*Feature' "$DISCOVERY_SKILL"
assert_match "Journey unaffected incremental path" 'does not affect.*User Journey.*do not.*reconfirm.*rewrite.*increment|do not.*reconfirm.*rewrite.*increment.*User Journey' "$DISCOVERY_SKILL"
assert_match "legacy baseline migration" 'PRD.*Business Architecture.*without.*User Journey|without.*User Journey.*PRD.*Business Architecture' "$DISCOVERY_SKILL"
assert_match "Journey gate link validation" 'Before User Journey Confirmation.*(verify|check).*Journey proposal.*local (links|references)|Journey proposal.*local (links|references).*before User Journey Confirmation' "$DISCOVERY_SKILL"
assert_match "Journey link check does not create assets" 'Before User Journey Confirmation.*do not.*(derive|create).*authoritative asset' "$DISCOVERY_SKILL"
assert_match "Product Design gate link validation" 'Before Product Design Confirmation.*(verify|check).*(three|all three).*product-design.*local links|(three|all three).*product-design.*local links.*before Product Design Confirmation' "$DISCOVERY_SKILL"
assert_match "Product Design link check does not write unconfirmed assets" 'Before Product Design Confirmation.*without writing.*not-yet-confirmed authoritative asset' "$DISCOVERY_SKILL"
assert_match "analysis stays conversational" 'analysis stages.*current conversation|current conversation.*analysis stages' "$DISCOVERY_SKILL"
assert_match "no process records" '[Mm]ust not create.*run manifest.*stage records.*confirmation records|[Dd]o not create.*run manifest.*stage records.*confirmation records' "$DISCOVERY_SKILL"
assert_match "no Discovery checkpoints" '[Mm]ust not require.*dedicated branch.*checkpoint|[Dd]o not require.*dedicated branch.*checkpoint' "$DISCOVERY_SKILL"
assert_match "ordinary Git rules" 'ordinary Git rules' "$DISCOVERY_SKILL"
assert_match "conversation-based continuation" 'current conversation.*user.*goal.*authoritative.*documents|authoritative.*documents.*current conversation' "$DISCOVERY_SKILL"
assert_match "primary outputs only" 'only primary.*outputs|primary.*outputs.*PRD.*Business Architecture' "$DISCOVERY_SKILL"
assert_match "technical disposition is supporting maintenance" 'supporting shared-asset maintenance|shared-asset maintenance.*not.*Discovery' "$DISCOVERY_SKILL"
assert_match "no automatic technical card creation" 'Do not automatically create.*Story.*Technical Task.*Decision|Do not create.*Story.*Technical Task.*Decision' "$DISCOVERY_SKILL"
assert_not_match "legacy Discovery run directory" 'build/dev-cadence/discovery/' "$DISCOVERY_SKILL"
assert_not_match "legacy Discovery stage records" '01-background-and-problem\.md|02-goals-and-value\.md|03-scope-and-business-architecture\.md|05-product-design-confirmation-record\.md' "$DISCOVERY_SKILL"
assert_not_match "legacy Discovery manifest" 'Discovery manifest|manifest\.md|update the manifest|record.*manifest' "$DISCOVERY_SKILL"
assert_not_match "legacy stage sequence" 'Goal And Value Definition -> Scope And Business Architecture Analysis' "$DISCOVERY_SKILL"
assert_not_match "dual-only primary outputs" 'only primary.*outputs.*PRD.*Business Architecture' "$DISCOVERY_SKILL"
assert_not_match "single gate for all assets" 'one consolidated user confirmation covering both product-design documents' "$DISCOVERY_SKILL"

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
assert_not_match "future S-002 delegation" 'S-002 owns incremental|later product-design versioning capability' "$DISCOVERY_SKILL"

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
