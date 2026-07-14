#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONVENTIONS_SKILL="$ROOT_DIR/src/skills/document-conventions/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"

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

assert_literal \
  "entry convention path" \
  '.dev-cadence/skills/document-conventions/SKILL.md' \
  "$ENTRY_SKILL"
assert_match \
  "entry reads convention before writing" \
  'Before creating or updating.*Dev Cadence-managed Markdown|before.*creat.*Markdown|before.*updat.*Markdown' \
  "$ENTRY_SKILL"

printf 'Document conventions contract checks passed.\n'
