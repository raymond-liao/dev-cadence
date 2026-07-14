#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY_SKILL="$ROOT_DIR/src/skills/open-question-registry/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  local path="$1"
  test -f "$path" || fail "missing required file: ${path#"$ROOT_DIR/"}"
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

assert_file "$REGISTRY_SKILL"
assert_literal "registry target path" 'docs/open-questions.md' "$REGISTRY_SKILL"
assert_match "on-demand creation" 'only when.*first.*question|first.*registration.*create|create.*only when.*question' "$REGISTRY_SKILL"
assert_match "no install creation" 'install.*must not.*create|do not create.*during install' "$REGISTRY_SKILL"
assert_match "candidate discovery" 'candidate.*registry|existing.*question.*document|competing.*index' "$REGISTRY_SKILL"
assert_match "conflict blocks writes" 'do not overwrite|must not overwrite|block.*write|stop.*clarif' "$REGISTRY_SKILL"

for field in 'ID' 'Type' 'Status' 'Owner' 'Authoritative Source' 'Impact' 'Suggested Resolution Stage'; do
  assert_literal "registry field $field" "$field" "$REGISTRY_SKILL"
done

assert_match "stable ids" 'stable.*ID|ID.*stable' "$REGISTRY_SKILL"
assert_match "authoritative body ownership" 'full.*body.*authoritative|authoritative.*full.*body|complete.*context.*authoritative' "$REGISTRY_SKILL"
assert_match "temporary full body" 'no authoritative|without.*authoritative|unassigned.*question' "$REGISTRY_SKILL"
assert_match "single body source" 'single.*body|one.*body|do not keep.*two|must not.*duplicate' "$REGISTRY_SKILL"
assert_match "migration" 'migrat.*authoritative|authoritative.*migrat' "$REGISTRY_SKILL"
assert_match "terminal removal" 'resolved|rejected|invalid|superseded' "$REGISTRY_SKILL"
assert_match "remove from current index" 'remove.*current.*index|current.*index.*remove' "$REGISTRY_SKILL"
assert_literal "change log" 'Change Log' "$REGISTRY_SKILL"
assert_match "change log events" 'added.*migrated.*removed|addition.*migration.*removal' "$REGISTRY_SKILL"
assert_match "change log avoids full body" 'Change Log.*must not.*full|do not.*full.*Change Log|without.*full.*body' "$REGISTRY_SKILL"
assert_match "local open questions retained" 'PRD.*Business Architecture|Business Architecture.*PRD' "$REGISTRY_SKILL"

assert_literal "entry registry skill path" '.dev-cadence/skills/open-question-registry/SKILL.md' "$ENTRY_SKILL"
assert_match "direct registry route" 'view.*Open Questions|maintain.*Open Questions|repository-level.*Open Questions' "$ENTRY_SKILL"
assert_match "workflow registry reuse" 'current artifact.*cannot.*hold|cannot.*reasonably.*hold|reuse.*Registry' "$ENTRY_SKILL"

printf 'Open Question Registry contract checks passed.\n'
