#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONVENTIONS_SKILL="$ROOT_DIR/src/references/document-conventions/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/workflows/using-dev-cadence/SKILL.md"
BACKLOG_SKILL="$ROOT_DIR/src/workflows/backlog/SKILL.md"
ANALYSIS_SKILL="$ROOT_DIR/src/workflows/work-item-analysis/SKILL.md"
FEATURE_SKILL="$ROOT_DIR/src/workflows/feature-dev/SKILL.md"
BUG_FIX_SKILL="$ROOT_DIR/src/workflows/bug-fix/SKILL.md"
REFACTOR_SKILL="$ROOT_DIR/src/workflows/refactor/SKILL.md"

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
assert_literal "localized work item included scope heading" "## ✅ <localized included-scope heading>" "$CONVENTIONS_SKILL"
assert_literal "localized work item excluded scope heading" "## ❌ <localized excluded-scope heading>" "$CONVENTIONS_SKILL"
assert_match \
  "work item scope heading localization" \
  'output_language|document.*language|localized' \
  "$CONVENTIONS_SKILL"
assert_literal "work item scope red flags" "### ⚠️ Red Flags" "$CONVENTIONS_SKILL"
assert_match "work item scope red flag table" "\| Thought \| Reality \|" "$CONVENTIONS_SKILL"
assert_match \
  "work item types" \
  'Feature.*Story.*Bug.*Task' \
  "$CONVENTIONS_SKILL"
assert_match \
  "scope marker meaning boundary" \
  'included|applicable|包含|适用' \
  "$CONVENTIONS_SKILL"
assert_match \
  "non-scope marker meaning boundary" \
  'excluded|not applicable|排除|不适用' \
  "$CONVENTIONS_SKILL"
assert_match \
  "scope markers do not mean quality" \
  'quality|acceptance|质量|验收' \
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

assert_literal "document reference section" "## Document References" "$CONVENTIONS_SKILL"
assert_match \
  "selective document link conditions" \
  'target.*exist.*reading navigation.*lifecycle|exist.*navigation.*lifecycle' \
  "$CONVENTIONS_SKILL"
assert_match \
  "meaningful document link text" \
  'meaningful.*link text|link text.*responsibility|link text.*content' \
  "$CONVENTIONS_SKILL"
assert_match "id-only explicit field exception" 'explicit ID field.*ID-only|ID-only.*explicit ID field' "$CONVENTIONS_SKILL"
assert_match "stable id and title link text" 'stable ID.*title.*link text|link text.*ID.*title' "$CONVENTIONS_SKILL"
assert_match "asset without id uses title" 'without.*stable ID.*title|no.*stable ID.*meaningful title' "$CONVENTIONS_SKILL"
assert_match "id-only forbidden outside id field" 'outside.*ID field.*must not.*ID-only|ID-only.*must not.*outside.*ID field' "$CONVENTIONS_SKILL"
assert_match \
  "source-relative repository links" \
  'relative to the source document|source document.*relative|relative.*current document' \
  "$CONVENTIONS_SKILL"
assert_match \
  "stable heading anchors" \
  'stable.*heading anchor|heading anchor.*stable|confirm.*anchor' \
  "$CONVENTIONS_SKILL"
assert_match \
  "navigation and exact identity coexist" \
  'navigation.*exact repository-relative path|link.*exact.*path|exact.*path.*link' \
  "$CONVENTIONS_SKILL"
assert_match \
  "uncreated targets remain pending" \
  'not.*created.*pending|pending.*planned path|target.*exists.*link' \
  "$CONVENTIONS_SKILL"
assert_match \
  "docs do not depend on build records" \
  'docs/.*do not.*build/|docs/.*must not.*build/|build/.*temporary.*docs/' \
  "$CONVENTIONS_SKILL"
assert_match \
  "build records may link durable documents" \
  'build/.*same run|build/.*docs/' \
  "$CONVENTIONS_SKILL"
assert_match \
  "renamed document links are updated" \
  'move.*rename.*update.*link|rename.*update.*link' \
  "$CONVENTIONS_SKILL"
assert_match \
  "tracked markdown links checked before commit" \
  'Before.*commit.*all tracked Markdown|all tracked Markdown.*before.*commit' \
  "$CONVENTIONS_SKILL"
assert_match \
  "current run links checked before completion" \
  'Before.*Completion.*current run|current run.*before.*Completion' \
  "$CONVENTIONS_SKILL"
assert_match \
  "machine path values remain exact" \
  'command arguments|configuration values|output locations|machine-readable.*identity' \
  "$CONVENTIONS_SKILL"
assert_match \
  "portable URI boundary" \
  'file://.*vscode://|vscode://.*file://|editor-specific URI' \
  "$CONVENTIONS_SKILL"
assert_match \
  "no machine absolute paths" \
  'machine-specific absolute path|local absolute path|/Users/' \
  "$CONVENTIONS_SKILL"
assert_match \
  "spaces and special characters use valid links" \
  'spaces.*special characters.*valid.*Markdown link|special characters.*legal.*Markdown link' \
  "$CONVENTIONS_SKILL"

assert_literal \
  "entry convention path" \
  '.dev-cadence/references/document-conventions/SKILL.md' \
  "$ENTRY_SKILL"
assert_match \
  "entry reads convention before writing" \
  'Before creating or updating.*Dev Cadence-managed Markdown|before.*creat.*Markdown|before.*updat.*Markdown' \
  "$ENTRY_SKILL"

assert_literal "entry warning heading" "## ⚠️ Red Flags" "$ENTRY_SKILL"
assert_literal "Backlog conventions reference" ".dev-cadence/references/document-conventions/SKILL.md" "$BACKLOG_SKILL"
assert_literal "Work Item Analysis conventions reference" ".dev-cadence/references/document-conventions/SKILL.md" "$ANALYSIS_SKILL"

for skill in "$FEATURE_SKILL" "$BUG_FIX_SKILL" "$REFACTOR_SKILL"; do
  assert_match "workflow warning heading" '^### ⚠️ .*Red Flags$' "$skill"
  assert_literal "ambiguous feedback heading" "### ❓ Ambiguous Acceptance Feedback" "$skill"
done

for skill in "$FEATURE_SKILL" "$BUG_FIX_SKILL" "$REFACTOR_SKILL"; do
  assert_match \
    "workflow applies shared status presentation" \
    'status summaries?.*document-conventions|document-conventions.*status summaries?|shared status.*mapping|status presentation.*shared' \
    "$skill"
  assert_match \
    "workflow applies shared document references" \
    'document references?.*document-conventions|document-conventions.*document references?|shared document-reference' \
    "$skill"
  assert_match \
    "workflow checks tracked markdown before commit" \
    'all tracked Markdown.*before.*commit|before.*commit.*all tracked Markdown' \
    "$skill"
done

for skill in "$BACKLOG_SKILL" "$ANALYSIS_SKILL"; do
  assert_match \
    "asset workflow uses repository-relative evidence" \
    'repository-relative evidence paths' \
    "$skill"
done

for skill in "$FEATURE_SKILL" "$BUG_FIX_SKILL" "$REFACTOR_SKILL"; do
  assert_match \
    "workflow status surfaces" \
    'manifest.*stage|stage.*report|report.*acceptance|status summary' \
    "$skill"
  assert_match \
    "workflow checks current run before completion" \
    'current run.*before.*Completion|before.*Completion.*current run' \
    "$skill"
done

if rg --no-ignore -n 'target.*exist.*reading navigation.*lifecycle' "$ENTRY_SKILL" >/dev/null; then
  fail "entry skill duplicates the complete document-reference selection contract"
fi

printf 'Document conventions contract checks passed.\n'
