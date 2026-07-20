#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY_SKILL="$ROOT_DIR/src/skills/open-question-registry/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/workflows/using-dev-cadence/SKILL.md"

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

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_multiline_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  rg --no-ignore -U -n "$pattern" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_file "$REGISTRY_SKILL"
assert_not_match "legacy remove lifecycle description" 'description:.*remove repository-level unresolved questions' "$REGISTRY_SKILL"
assert_literal "registry target path" 'docs/open-questions.md' "$REGISTRY_SKILL"
assert_match "on-demand creation" 'only when.*first.*question|first.*registration.*create|create.*only when.*question' "$REGISTRY_SKILL"
assert_match "no install creation" 'install.*must not.*create|do not create.*during install' "$REGISTRY_SKILL"
assert_match "candidate discovery" 'candidate.*registry|existing.*question.*document|competing.*index' "$REGISTRY_SKILL"
assert_match "conflict blocks writes" 'do not overwrite|must not overwrite|block.*write|stop.*clarif' "$REGISTRY_SKILL"

assert_literal "questions table" '| ID | Status | Question | Authoritative Source |' "$REGISTRY_SKILL"
assert_literal "global question id" 'Q-nnn' "$REGISTRY_SKILL"
assert_literal "id link example" '[Q-001](#q-001)' "$REGISTRY_SKILL"
assert_literal "detail anchor example" '### Q-001' "$REGISTRY_SKILL"
for status in Open Resolved Rejected Invalid Superseded; do
  assert_literal "question status $status" "$status" "$REGISTRY_SKILL"
done
assert_match "scan existing maximum id" 'scan.*existing.*maximum.*Q-nnn|existing.*maximum.*Q-nnn.*scan' "$REGISTRY_SKILL"
assert_match "id increments from Q-001" 'Q-001.*increment|increment.*Q-001' "$REGISTRY_SKILL"
assert_match "terminal ids are not reused" 'terminal.*ID.*must not.*reuse|must not.*reuse.*terminal.*ID' "$REGISTRY_SKILL"

assert_match "open group first ordering" 'Open.*group.*first.*ascending.*ID' "$REGISTRY_SKILL"
assert_match "non-open group ordering" 'non-Open.*group.*after.*ascending.*ID' "$REGISTRY_SKILL"
assert_match "details cover every question" 'Question Details.*every question.*ascending.*ID' "$REGISTRY_SKILL"
assert_match "assigned authoritative body" 'durable authoritative.*only.*title.*link|only.*title.*link.*durable authoritative' "$REGISTRY_SKILL"
assert_match "registry temporary full body" 'no durable authority.*Registry temporarily owns.*full body|Registry temporarily owns.*full body.*no durable authority' "$REGISTRY_SKILL"
assert_match "single full-body source" 'one full-body source|single full-body source' "$REGISTRY_SKILL"
assert_multiline_match "migration sequence" '1\. Add the full body.*\n2\. Verify the authoritative document.*\n3\. Replace the Registry temporary body.*\n4\. Verify no second full body remains' "$REGISTRY_SKILL"
assert_match "terminal retention" 'terminal.*remain|retain.*terminal|do not.*remove.*terminal' "$REGISTRY_SKILL"
assert_match "registry has no change log" 'Registry.*must not.*Change Log|Do not.*Change Log.*Registry' "$REGISTRY_SKILL"
assert_not_match "legacy eight-field table" '\| ID \| Type \| Status \| Owner \| Summary \| Authoritative Source \| Impact \| Suggested Resolution Stage \|' "$REGISTRY_SKILL"
assert_not_match "legacy current questions heading" '^## Current Open Questions$' "$REGISTRY_SKILL"
assert_not_match "legacy unassigned details heading" '^## Unassigned Question Details$' "$REGISTRY_SKILL"
assert_not_match "terminal removal rule" 'Remove the entry from the current index|remove any Registry temporary body|current.*index.*remove' "$REGISTRY_SKILL"
assert_not_match "registry change log structure" '^## Change Log$|^\| Date \| ID \| Change \| Final Location \|$' "$REGISTRY_SKILL"
assert_not_match "optional Registry indexing semantics" 'Registry indexes them when repository-level visibility is useful|index.*when useful|optional.*index' "$REGISTRY_SKILL"

assert_literal "entry registry skill path" '.dev-cadence/skills/open-question-registry/SKILL.md' "$ENTRY_SKILL"
assert_match "direct registry route" 'view.*Open Questions|maintain.*Open Questions|repository-level.*Open Questions' "$ENTRY_SKILL"
assert_match "workflow registry reuse" 'current artifact.*cannot.*hold|cannot.*reasonably.*hold|reuse.*Registry' "$ENTRY_SKILL"

printf 'Open Question Registry contract checks passed.\n'
