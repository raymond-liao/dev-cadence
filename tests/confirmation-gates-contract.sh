#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  rg --no-ignore -n "$pattern" "$ROOT_DIR/$path" >/dev/null || fail "missing $label in $path"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  if rg --no-ignore -n "$pattern" "$ROOT_DIR/$path" >/dev/null; then
    fail "unexpected $label in $path"
  fi
}

section_between_headings() {
  local start_heading="$1"
  local end_heading="$2"
  local path="$3"

  awk -v start="$start_heading" -v end="$end_heading" '
    $0 == start { in_section = 1; next }
    in_section && $0 == end { in_section = 0 }
    in_section { print }
  ' "$ROOT_DIR/$path"
}

assert_section_count() {
  local label="$1"
  local start_heading="$2"
  local end_heading="$3"
  local literal="$4"
  local expected="$5"
  local path="$6"
  local section count

  section="$(section_between_headings "$start_heading" "$end_heading" "$path")"
  count="$(printf '%s\n' "$section" | (rg -o -F -- "$literal" || true) | wc -l | tr -d ' ')"
  test "$count" -eq "$expected" || fail "expected $label count $expected, got $count in $path"
}

assert_section_literal() {
  local label="$1"
  local start_heading="$2"
  local end_heading="$3"
  local literal="$4"
  local path="$5"
  local section

  section="$(section_between_headings "$start_heading" "$end_heading" "$path")"
  [[ "$section" == *"$literal"* ]] || fail "missing $label between ${start_heading} and ${end_heading} in $path"
}

asset_skills=(
  src/workflows/discovery/SKILL.md
  src/workflows/work-item-planning/SKILL.md
  src/workflows/architecture-design/SKILL.md
)
delivery_skills=(
  src/workflows/feature-dev/SKILL.md
  src/workflows/bug-fix/SKILL.md
  src/workflows/refactor/SKILL.md
)

for skill in "${asset_skills[@]}" "${delivery_skills[@]}"; do
  assert_match "confirmation gate presentation heading" '^## Confirmation Gate Presentation$' "$skill"
  assert_match "stage conclusion summary" 'stage conclusion|current conclusion' "$skill"
  assert_match "scope summary" 'included scope|excluded scope|scope and non-scope' "$skill"
  assert_match "risk or question summary" 'risks? or open questions|risks? and open questions' "$skill"
  assert_match "evidence link boundary" 'evidence link|record.*evidence' "$skill"
  assert_match "choice result impact" 'choice.*next stage|choice.*asset|choice.*record|choice.*status' "$skill"
done

for skill in "${delivery_skills[@]}"; do
  assert_match "advance choice" 'confirm.*advance|confirm.*next stage|advance to the next stage' "$skill"
  assert_match "revise and stay choice" 'request.*change.*remain|revise.*current stage|remain at the current stage' "$skill"
  assert_match "Business Acceptance same-message menu" 'same user-visible message.*fixed numbered options|same message.*fixed numbered options' "$skill"
  assert_match "Business Acceptance delegation boundary" '[Dd]elegated continuation.*must not.*Business Acceptance.*Completion|[Dd]elegated continuation.*cannot.*Business Acceptance.*Completion' "$skill"
  assert_match "Completion menu presentation" 'Completion.*menu.*must.*present|finishing flow.*menu.*must.*present' "$skill"
done

assert_match "Discovery Journey confirmation" 'User Journey Confirmation' src/workflows/discovery/SKILL.md
assert_match "Discovery product confirmation" 'Product Design Confirmation' src/workflows/discovery/SKILL.md
assert_match "Planning result confirmation" 'Planning Result Confirmation' src/workflows/work-item-planning/SKILL.md
assert_match "Architecture pending semantics" 'Decision Pending' src/workflows/architecture-design/SKILL.md

assert_section_count \
  "Portfolio Planning formal confirmation gates" \
  "### Portfolio Planning Confirmation Gates" \
  "### Direct Intake Confirmation Gates" \
  "formal confirmation gate for Portfolio Planning" \
  2 \
  src/workflows/work-item-planning/SKILL.md
assert_section_count \
  "Direct Intake formal confirmation gates" \
  "### Direct Intake Confirmation Gates" \
  "## Story Map Contract" \
  "formal confirmation gate for Direct Intake" \
  1 \
  src/workflows/work-item-planning/SKILL.md
assert_section_literal \
  "Direct Intake clarification boundary" \
  "### Direct Intake Confirmation Gates" \
  "## Story Map Contract" \
  "Necessary Clarification is not a formal confirmation gate" \
  src/workflows/work-item-planning/SKILL.md
assert_section_literal \
  "Direct Intake result confirmation name" \
  "### Direct Intake Confirmation Gates" \
  "## Story Map Contract" \
  "Direct Intake Result Confirmation" \
  src/workflows/work-item-planning/SKILL.md

for skill in "${asset_skills[@]}" "${delivery_skills[@]}"; do
  assert_not_match "generic confirmation menu replacing terminal menus" 'Business Acceptance.*Confirmation Gate Presentation|Completion.*Confirmation Gate Presentation' "$skill"
done

printf 'Confirmation gates contract checks passed.\n'
