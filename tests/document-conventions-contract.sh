#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONVENTIONS_SKILL="$ROOT_DIR/src/skills/document-conventions/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"
DISCOVERY_SKILL="$ROOT_DIR/src/skills/discovery/SKILL.md"
FEATURE_SKILL="$ROOT_DIR/src/skills/feature-dev/SKILL.md"
BUG_FIX_SKILL="$ROOT_DIR/src/skills/bug-fix/SKILL.md"
REFACTOR_SKILL="$ROOT_DIR/src/skills/refactor/SKILL.md"
WORK_ITEM_DIRS=(
  "$ROOT_DIR/docs/features"
  "$ROOT_DIR/docs/stories"
  "$ROOT_DIR/docs/bugs"
  "$ROOT_DIR/docs/tasks"
)

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

for work_item_dir in "${WORK_ITEM_DIRS[@]}"; do
  [[ -d "$work_item_dir" ]] || continue

  while IFS= read -r work_item; do
    assert_literal "included scope heading" "## ✅ 范围" "$work_item"
    assert_literal "excluded scope heading" "## ❌ 非范围" "$work_item"

    if rg -n '^## (范围|非范围)$' "$work_item" >/dev/null; then
      fail "legacy scope heading in ${work_item#"$ROOT_DIR/"}"
    fi
  done < <(find "$work_item_dir" -maxdepth 1 -type f -name '*.md' -print)
done

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

printf 'Document conventions contract checks passed.\n'
