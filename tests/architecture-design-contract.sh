#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/src/workflows/architecture-design/SKILL.md"
ENTRY="$ROOT_DIR/src/workflows/using-dev-cadence/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  test -f "$1" || fail "missing ${1#"$ROOT_DIR/"}"
}

assert_literal() {
  local label="$1"
  local literal="$2"
  local path="$3"
  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  rg --no-ignore -n "$pattern" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_file "$SKILL"
assert_literal "Asset declaration" "This is an Asset Workflow." "$SKILL"
assert_match "explicit trigger" 'explicitly asks.*architecture design|architecture design.*explicit' "$SKILL"
assert_match "no automatic trigger" 'must not.*automatically|do not.*automatically' "$SKILL"

for input in goal 'design object' scope 'non-scope' constraints 'detail level' 'output name'; do
  assert_match "confirmed input $input" "$input" "$SKILL"
done

for subject in 'current code' 'existing documentation' 'component boundaries' 'data and interfaces' 'external dependencies' 'deployment environment' 'quality attributes'; do
  assert_literal "investigation subject $subject" "$subject" "$SKILL"
done
assert_match "missing-state assumptions" 'unavailable.*assumptions|assumptions.*unavailable' "$SKILL"
assert_match "meaningful option count" '2-3.*meaningful|two or three.*meaningful' "$SKILL"
assert_match "no artificial options" '[Dd]o not.*invent.*alternatives|must not.*manufacture.*alternatives' "$SKILL"

for marker in '✅ Selected' '❌ Rejected' '❓ Decision Pending'; do
  assert_literal "solution marker $marker" "$marker" "$SKILL"
done
assert_match "recommendation not selection" 'recommendation.*not.*selection|recommended.*must not.*Selected' "$SKILL"
assert_literal "single output" 'docs/architecture/<goal-slug>.md' "$SKILL"
assert_match "portable goal slug" 'kebab-case' "$SKILL"
assert_literal \
  "no preset classification naming" \
  'Do not derive `<goal-slug>` from a preset architecture scale or Scope classification such as Product, Capability, or Work Item, and do not add those classifications as filename prefixes.' \
  "$SKILL"
assert_match "goal-only filename meaning" 'filename.*only.*confirmed.*specific goal|only.*specific goal.*filename' "$SKILL"
assert_match "avoid redundant architecture suffix" 'do not.*append.*architecture|does not.*repeat.*architecture' "$SKILL"
assert_match "tailored sections" '[Oo]mit.*not applicable|[Dd]o not.*empty sections' "$SKILL"
assert_match "Mermaid preferred" '[Pp]refer Mermaid|Mermaid.*preferred' "$SKILL"
assert_match "diagram not separate output" 'part of.*architecture document|not.*separate.*output' "$SKILL"
assert_match "not approved before confirmation" 'must not.*approved.*before|[Bb]efore.*confirmation.*must not.*approved' "$SKILL"
assert_match "confirmation summary" 'output path.*selected option.*key decisions.*open questions' "$SKILL"

assert_match "no process records" 'must not create.*run manifest|no.*run manifest' "$SKILL"
assert_match "no stage records" 'stage records' "$SKILL"
assert_match "no checkpoints" 'checkpoint commits' "$SKILL"
assert_match "no implementation" 'must not.*modify code|do not.*modify code' "$SKILL"
assert_match "no planning" 'implementation plan|work-item decomposition' "$SKILL"
assert_match "does not replace delivery solution" 'must not replace|does not replace' "$SKILL"

assert_literal "available workflow route" '.dev-cadence/workflows/architecture-design/SKILL.md' "$ENTRY"
assert_match "explicit architecture route" 'Architecture Design.*explicit|explicit.*Architecture Design' "$ENTRY"
assert_match "repository state does not route" 'architecture.*repository state.*does not|repository state.*does not.*architecture' "$ENTRY"
assert_match "delivery solution boundary" 'architecture-design.*does not replace|does not replace.*architecture-design' "$ENTRY"

assert_not_match "Discovery temporary exception" 'Until S-013|legacy run-record' "$SKILL"

printf 'Architecture Design contract checks passed.\n'
