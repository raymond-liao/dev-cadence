#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_literal() {
  local label="$1" literal="$2" path="$3"
  rg --no-ignore -F -n -- "$literal" "$ROOT_DIR/$path" >/dev/null ||
    fail "missing $label in $path"
}

assert_match() {
  local label="$1" pattern="$2" path="$3"
  rg --no-ignore -n "$pattern" "$ROOT_DIR/$path" >/dev/null ||
    fail "missing $label in $path"
}

assert_not_match() {
  local label="$1" pattern="$2" path="$3"
  if rg --no-ignore -n "$pattern" "$ROOT_DIR/$path" >/dev/null; then
    fail "unexpected $label in $path"
  fi
}

BACKLOG="src/workflows/backlog/SKILL.md"
ANALYSIS="src/workflows/work-item-analysis/SKILL.md"
ARCHITECTURE="src/workflows/architecture-design/SKILL.md"
DELIVERY=(
  src/workflows/feature-dev/SKILL.md
  src/workflows/bug-fix/SKILL.md
  src/workflows/refactor/SKILL.md
)

assert_literal "Backlog sequence" "Necessary Clarification -> Backlog Proposal -> Backlog Result Confirmation" "$BACKLOG"
assert_literal "Backlog clarification boundary" "Necessary Clarification is not a formal confirmation gate." "$BACKLOG"
assert_match "Backlog assets unchanged before gate" 'Before Backlog Result Confirmation.*authoritative assets unchanged' "$BACKLOG"
assert_match "Backlog proposal current conclusion" 'current conclusion' "$BACKLOG"
assert_match "Backlog proposal scope" 'included card and Backlog changes' "$BACKLOG"
assert_match "Backlog proposal risks" 'contract failures, conflicts, dependencies, or Open Questions' "$BACKLOG"
assert_match "Backlog confirm choice" 'confirm the proposed result' "$BACKLOG"
assert_match "Backlog revise choice" 'request changes' "$BACKLOG"

assert_literal "Analysis sequence" "Necessary Clarification -> Work Item Definition Proposal -> Work Item Confirmation" "$ANALYSIS"
assert_literal "Analysis clarification boundary" "Necessary Clarification is not a formal confirmation gate." "$ANALYSIS"
assert_match "Analysis assets unchanged before gate" 'Before Work Item Confirmation.*authoritative assets unchanged' "$ANALYSIS"
assert_match "Analysis proposal current conclusion" 'current analysis conclusion' "$ANALYSIS"
assert_match "Analysis proposal scope" 'proposed goal, included scope, excluded scope' "$ANALYSIS"
assert_match "Analysis proposal risks" 'assumptions, dependencies, risks, and Open Questions' "$ANALYSIS"
assert_match "Analysis confirm choice" 'confirm the proposed definition' "$ANALYSIS"
assert_match "Analysis revise choice" 'request changes' "$ANALYSIS"

assert_match "Architecture pending semantics" 'Decision Pending' "$ARCHITECTURE"

for skill in "${DELIVERY[@]}"; do
  assert_match "confirmation gate presentation heading" '^## Confirmation Gate Presentation$' "$skill"
  assert_match "stage conclusion summary" 'stage conclusion|current conclusion' "$skill"
  assert_match "scope summary" 'included scope|excluded scope|scope and non-scope' "$skill"
  assert_match "risk or question summary" 'risks? or open questions|risks? and open questions' "$skill"
  assert_match "advance choice" 'confirm.*advance|confirm.*next stage|advance to the next stage' "$skill"
  assert_match "revise choice" 'request.*change.*remain|revise.*current stage|remain at the current stage' "$skill"
  assert_match "Business Acceptance menu" 'same user-visible message.*fixed numbered options|same message.*fixed numbered options' "$skill"
  assert_match "Completion menu" 'Completion.*menu.*must.*present|finishing flow.*menu.*must.*present' "$skill"
  assert_not_match "generic gate replaces terminal menus" 'Business Acceptance.*Confirmation Gate Presentation|Completion.*Confirmation Gate Presentation' "$skill"
done

assert_not_match "removed Discovery gate" 'User Journey Confirmation|Product Design Confirmation' "$BACKLOG"
assert_not_match "removed planning gate" 'Portfolio Planning Confirmation|Direct Intake Result Confirmation' "$BACKLOG"

printf 'Confirmation gates contract checks passed.\n'
