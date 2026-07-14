#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONVENTIONS_SKILL="$ROOT_DIR/src/skills/document-conventions/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"
DISCOVERY_SKILL="$ROOT_DIR/src/skills/discovery/SKILL.md"
FEATURE_SKILL="$ROOT_DIR/src/skills/feature-dev/SKILL.md"
BUG_FIX_SKILL="$ROOT_DIR/src/skills/bug-fix/SKILL.md"
REFACTOR_SKILL="$ROOT_DIR/src/skills/refactor/SKILL.md"

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

assert_file "document-conventions skill" "$CONVENTIONS_SKILL"
assert_literal "auxiliary boundary" "not a business workflow" "$CONVENTIONS_SKILL"
assert_literal "no run boundary" "does not create a workflow run" "$CONVENTIONS_SKILL"

for marker in '✅' '❌' '❓' '⚠️' 'ℹ️'; do
  assert_literal "semantic marker $marker" "$marker" "$CONVENTIONS_SKILL"
done

assert_match \
  "text accompanies emoji" \
  'explicit text|text.*reason|not.*only source of meaning' \
  "$CONVENTIONS_SKILL"
assert_match \
  "selective use" \
  'selective|Do not add.*ordinary|not.*ordinary prose' \
  "$CONVENTIONS_SKILL"
assert_match \
  "machine-sensitive exclusion" \
  'filenames|paths|commands|IDs|configuration|canonical status' \
  "$CONVENTIONS_SKILL"
assert_literal "selected solution marker" "✅ Selected" "$CONVENTIONS_SKILL"
assert_literal "rejected solution marker" "❌ Rejected" "$CONVENTIONS_SKILL"
assert_literal "pending solution marker" "❓ Decision Pending" "$CONVENTIONS_SKILL"
assert_match \
  "unselected alternatives stay neutral" \
  'unselected.*neutral|alternatives.*neutral|Do not mark.*unselected.*Rejected' \
  "$CONVENTIONS_SKILL"
assert_match \
  "recommendation is not selection" \
  'recommend.*not.*Selected|Do not mark.*recommend.*Selected|recommendation.*confirmed' \
  "$CONVENTIONS_SKILL"

for status_display in \
  '✅.*`confirmed`.*`completed`.*`accepted`.*`passed`.*`resolved`.*`integrated`' \
  '🟢.*`ready`' \
  '🔄.*`in_progress`' \
  '⏳.*`pending`' \
  '⛔.*`blocked`.*`not_ready`' \
  '⚠️.*`ready_with_risk`.*`accepted_with_risk`' \
  '❌.*`failed`.*`rejected`' \
  '⏭️.*`skipped`'; do
  assert_match "status display mapping $status_display" "$status_display" "$CONVENTIONS_SKILL"
done

assert_match \
  "canonical status remains visible" \
  'emoji.*canonical status|canonical status.*emoji|marker.*canonical status' \
  "$CONVENTIONS_SKILL"
assert_match \
  "canonical status uses inline code" \
  'inline code|backticks|`emoji \+ canonical status`' \
  "$CONVENTIONS_SKILL"
assert_match \
  "status is not machine parsed from emoji" \
  'machine.*emoji|emoji.*machine|not.*machine.*source' \
  "$CONVENTIONS_SKILL"
assert_match \
  "backlog and work item avoid duplicate markers" \
  'Backlog.*work-item|work-item.*Backlog|checkbox.*duplicate|duplicate.*checkbox' \
  "$CONVENTIONS_SKILL"

assert_literal \
  "entry convention path" \
  '.dev-cadence/skills/document-conventions/SKILL.md' \
  "$ENTRY_SKILL"
assert_match \
  "entry reads convention before writing" \
  'Before creating or updating.*Dev Cadence-managed Markdown|before.*creat.*Markdown|before.*updat.*Markdown' \
  "$ENTRY_SKILL"

assert_literal "entry warning heading" "## ⚠️ Red Flags" "$ENTRY_SKILL"
assert_literal "discovery required boundary" "### ✅ Discovery Must" "$DISCOVERY_SKILL"
assert_literal "discovery forbidden boundary" "### ❌ Discovery Must Not" "$DISCOVERY_SKILL"

for skill in "$FEATURE_SKILL" "$BUG_FIX_SKILL" "$REFACTOR_SKILL"; do
  assert_match "workflow warning heading" '^### ⚠️ .*Red Flags$' "$skill"
  assert_literal "ambiguous feedback heading" "### ❓ Ambiguous Acceptance Feedback" "$skill"
done

for skill in "$DISCOVERY_SKILL" "$FEATURE_SKILL" "$BUG_FIX_SKILL" "$REFACTOR_SKILL"; do
  assert_match \
    "workflow applies shared status presentation" \
    'status summaries?.*document-conventions|document-conventions.*status summaries?|shared status.*mapping|status presentation.*shared' \
    "$skill"
  assert_match \
    "workflow status surfaces" \
    'manifest.*stage|stage.*report|report.*acceptance|status summary' \
    "$skill"
done

printf 'Document conventions contract checks passed.\n'
