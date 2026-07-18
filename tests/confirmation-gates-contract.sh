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

asset_skills=(
  src/skills/discovery/SKILL.md
  src/skills/work-item-planning/SKILL.md
  src/skills/architecture-design/SKILL.md
)
delivery_skills=(
  src/skills/feature-dev/SKILL.md
  src/skills/bug-fix/SKILL.md
  src/skills/refactor/SKILL.md
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

assert_match "Discovery Journey confirmation" 'User Journey Confirmation' src/skills/discovery/SKILL.md
assert_match "Discovery product confirmation" 'Product Design Confirmation' src/skills/discovery/SKILL.md
assert_match "Planning result confirmation" 'Planning Result Confirmation' src/skills/work-item-planning/SKILL.md
assert_match "Architecture pending semantics" 'Decision Pending' src/skills/architecture-design/SKILL.md

for skill in "${asset_skills[@]}" "${delivery_skills[@]}"; do
  assert_not_match "generic confirmation menu replacing terminal menus" 'Business Acceptance.*Confirmation Gate Presentation|Completion.*Confirmation Gate Presentation' "$skill"
done

printf 'Confirmation gates contract checks passed.\n'
