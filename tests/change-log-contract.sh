#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/src/skills/contracts/change-log.md"
DISCOVERY="$ROOT_DIR/src/skills/discovery/SKILL.md"
PLANNING="$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
ANALYSIS="$ROOT_DIR/src/skills/work-item-analysis/SKILL.md"

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

assert_not_literal() {
  local label="$1"
  local literal="$2"
  local path="$3"

  if rg --no-ignore -F -n -- "$literal" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_file "$CONTRACT"
assert_literal "standard schema" 'Version | Recorded At | Recorded By | Change | Reason' "$CONTRACT"
assert_literal "named version schema" '<Named Version> | Recorded At | Recorded By | Change | Reason' "$CONTRACT"
assert_literal "legacy date sentinel" 'legacy: recorded-at precision unknown; original YYYY-MM-DD' "$CONTRACT"
assert_literal "legacy unknown date" 'legacy: recorded-at unknown' "$CONTRACT"
assert_literal "legacy unknown author" 'legacy: recorded-by unknown' "$CONTRACT"

assert_literal "definition increment" 'Increment the owned version by 1 before recording a confirmed definition change.' "$CONTRACT"
assert_literal "non-versioned important event" "Record a status transition, delivery result, or important migration with the event's current version; do not increment the version solely for that event." "$CONTRACT"
assert_literal "duplicate version allowed" 'Multiple rows with the same version are valid when they describe different events.' "$CONTRACT"
assert_literal "append order" 'Append new records in event order.' "$CONTRACT"
assert_literal "formatting excluded" 'Do not record spelling-only, formatting-only, or link-only changes that do not alter an owned responsibility.' "$CONTRACT"
assert_literal "git identity priority" 'Read `user.name` and `user.email` from repository-level Git config before global Git config.' "$CONTRACT"
assert_literal "full identity format" 'When both values are available, record `Name <email>`; when only one is available, retain that confirmed value.' "$CONTRACT"
assert_literal "identity missing prompt" 'When both identity values are unavailable, ask the user before writing a new record.' "$CONTRACT"
assert_literal "offset timestamp" 'New records must use a timezone-offset ISO 8601 `Recorded At` value captured when the event occurs.' "$CONTRACT"
assert_literal "legacy migration only" 'Use these sentinel values only for historical migration; never use them for a new record.' "$CONTRACT"
assert_literal "historical identity inference forbidden" 'Do not infer historical identity from current Git configuration' "$CONTRACT"
assert_match "forbidden approval metadata" 'Do not record.*approv' "$CONTRACT"
assert_match "forbidden commit metadata" 'Do not record.*commit hash' "$CONTRACT"
assert_match "forbidden workflow metadata" 'Do not record.*workflow (stage|run)' "$CONTRACT"
assert_not_match "yaml frontmatter" '^---$' "$CONTRACT"

PUBLIC_CONTRACT_LITERALS=(
  'Version | Recorded At | Recorded By | Change | Reason'
  '<Named Version> | Recorded At | Recorded By | Change | Reason'
  'Increment the owned version by 1 before recording a confirmed definition change.'
  "Record a status transition, delivery result, or important migration with the event's current version; do not increment the version solely for that event."
  'Multiple rows with the same version are valid when they describe different events.'
  'Append new records in event order.'
  'Do not record spelling-only, formatting-only, or link-only changes that do not alter an owned responsibility.'
  'New records must use a timezone-offset ISO 8601 `Recorded At` value captured when the event occurs.'
  'Read `user.name` and `user.email` from repository-level Git config before global Git config.'
  'When both values are available, record `Name <email>`; when only one is available, retain that confirmed value.'
  'When both identity values are unavailable, ask the user before writing a new record.'
  'legacy: recorded-at precision unknown; original YYYY-MM-DD'
  'legacy: recorded-at unknown'
  'legacy: recorded-by unknown'
  'Use these sentinel values only for historical migration; never use them for a new record.'
  'Do not infer historical identity from current Git configuration'
  'Do not record approval metadata, approver identity, approval timestamp, commit hashes, workflow stage, workflow run metadata, or runtime status as Change Log fields.'
)

for consumer in "$DISCOVERY" "$PLANNING" "$ANALYSIS"; do
  assert_literal "shared contract read" '.dev-cadence/skills/contracts/change-log.md' "$consumer"

  for literal in "${PUBLIC_CONTRACT_LITERALS[@]}"; do
    assert_not_literal "duplicated public Change Log contract detail" "$literal" "$consumer"
  done
done

printf 'Change Log contract checks passed.\n'
