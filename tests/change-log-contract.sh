#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/src/skills/contracts/change-log.md"
DISCOVERY="$ROOT_DIR/src/skills/discovery/SKILL.md"
PLANNING="$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
ANALYSIS="$ROOT_DIR/src/skills/work-item-analysis/SKILL.md"
BACKLOG="$ROOT_DIR/docs/backlog.md"
REGISTRY="$ROOT_DIR/docs/open-questions.md"
WORK_ITEM_DIRS=(
  "$ROOT_DIR/docs/stories"
  "$ROOT_DIR/docs/tasks"
  "$ROOT_DIR/docs/bugs"
)
WORK_ITEM_FILES=(
  "$ROOT_DIR/docs/stories/"*.md
  "$ROOT_DIR/docs/tasks/"*.md
  "$ROOT_DIR/docs/bugs/"*.md
)

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

card_path() {
  local id="$1"
  local path

  path="$(find "${WORK_ITEM_DIRS[@]}" -maxdepth 1 -name "$id-*.md" -print)"
  test -n "$path" || fail "missing work-item card $id"
  test "$(printf '%s\n' "$path" | wc -l | tr -d ' ')" = "1" ||
    fail "multiple work-item cards found for $id"
  printf '%s\n' "$path"
}

history_versions() {
  awk '
    /^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$/ {
      in_change_log = 1
      next
    }
    in_change_log && /^\|[-:| ]+\|$/ { next }
    in_change_log && /^\| [0-9]+ \|/ {
      version = $2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", version)
      versions = versions (versions == "" ? "" : ",") version
      next
    }
    in_change_log { in_change_log = 0 }
    END { print versions }
  ' FS='|' "$1"
}

assert_history_versions() {
  local id="$1"
  local expected="$2"
  local path
  local actual

  path="$(card_path "$id")"
  actual="$(history_versions "$path")"
  test "$actual" = "$expected" ||
    fail "$id history versions are $actual, expected $expected"
}

assert_normalized_card() {
  local id="$1"
  local old_current="$2"
  local new_current="$3"
  local old_rows="$4"
  local new_rows="$5"
  local path
  local top_version
  local migration_change='Normalized legacy status and delivery events to reuse the active definition Version.'
  local migration_reason="Old current $old_current -> new current $new_current; original row versions $old_rows -> normalized row versions $new_rows."

  path="$(card_path "$id")"
  top_version="$(sed -n 's/^- Version[：:][[:space:]]*`\([0-9][0-9]*\)`.*/\1/p' "$path")"
  test "$top_version" = "$new_current" ||
    fail "$id top Version is $top_version, expected $new_current"
  assert_history_versions "$id" "$new_rows,$new_current"
  assert_literal "$id migration change" "$migration_change" "$path"
  assert_literal "$id migration reason" "$migration_reason" "$path"
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

CARD_COUNT="$(find "${WORK_ITEM_DIRS[@]}" -maxdepth 1 -name '*.md' -print | wc -l | tr -d ' ')"
test "$CARD_COUNT" = "57" || fail "expected 57 work-item cards, found $CARD_COUNT"

if rg -n '^\| Version \| Date \| Change \| Reason \|' "${WORK_ITEM_DIRS[@]}"; then
  fail "legacy four-column Change Log remains"
fi

STANDARD_HEADER_COUNT="$(rg -l '^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|' \
  "${WORK_ITEM_DIRS[@]}" | wc -l | tr -d ' ')"
test "$STANDARD_HEADER_COUNT" = "57" ||
  fail "not every work-item card uses the standard schema"

if rg -n '^\| [0-9]+ \| [0-9]{4}-[0-9]{2}-[0-9]{2} \|' "${WORK_ITEM_DIRS[@]}"; then
  fail "date-only Recorded At remains"
fi

awk '
  function trim(value) {
    gsub(/^[[:space:]`]+|[[:space:]`]+$/, "", value)
    return value
  }
  /^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$/ {
    in_change_log = 1
    next
  }
  in_change_log && /^\|[-:| ]+\|$/ { next }
  in_change_log && /^\| [0-9]+ \|/ {
    author = trim($4)
    if (author == "" || author == "-") {
      printf "invalid Recorded By in %s:%d\n", FILENAME, FNR > "/dev/stderr"
      invalid = 1
    }
    next
  }
  in_change_log { in_change_log = 0 }
  END { exit invalid }
' FS='|' "${WORK_ITEM_FILES[@]}" || fail "empty or placeholder Recorded By remains"

assert_not_match "Registry Change Log" '^## Change Log$' "$REGISTRY"

while IFS= read -r card; do
  id="$(sed -n 's/^- ID[：:][[:space:]]*`\([^`]*\)`.*/\1/p' "$card")"
  version="$(sed -n 's/^- Version[：:][[:space:]]*`\([0-9][0-9]*\)`.*/\1/p' "$card")"
  test -n "$id" || fail "missing top-level ID in ${card#"$ROOT_DIR/"}"
  test -n "$version" || fail "missing top-level Version in ${card#"$ROOT_DIR/"}"
  backlog_version="$(awk -F'|' -v id="\`$id\`" '
    function trim(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }
    trim($2) == id {
      value = trim($4)
      gsub(/`/, "", value)
      print value
    }
  ' "$BACKLOG")"
  test "$backlog_version" = "$version" ||
    fail "$id Backlog Version is $backlog_version, expected $version"
done < <(find "${WORK_ITEM_DIRS[@]}" -maxdepth 1 -name '*.md' -print | LC_ALL=C sort)

assert_normalized_card S-001 6 4 '1,2,3,4,5,6' '1,2,3,3,4,4'
assert_normalized_card S-002 11 8 '1,2,3,4,5,6,7,8,9,10,11' '1,2,3,4,4,5,6,7,7,8,8'
assert_normalized_card S-003 2 1 '1,2' '1,1'
assert_normalized_card S-004 3 1 '1,2,3' '1,1,1'
assert_normalized_card S-005 3 2 '1,2,3' '1,2,2'
assert_normalized_card S-006 4 1 '1,2,3,4' '1,1,1,1'
assert_normalized_card S-007 4 3 '1,2,3,4' '1,2,3,3'
assert_normalized_card S-008 6 3 '1,2,3,4,5,6' '1,2,2,2,3,3'
assert_normalized_card S-009 3 2 '1,2,3' '1,2,2'
assert_normalized_card S-010 5 3 '1,2,3,4,5' '1,2,3,3,3'
assert_normalized_card S-011 5 2 '1,2,3,4,5' '1,2,2,2,2'
assert_normalized_card S-012 5 2 '1,2,3,4,5' '1,1,2,2,2'
assert_normalized_card S-013 5 3 '1,2,3,4,5' '1,1,2,3,3'
assert_normalized_card S-014 5 2 '1,2,3,4,5' '1,2,2,2,2'
assert_normalized_card S-015 7 4 '1,2,3,4,5,6,7,7,7' '1,2,2,3,4,4,4,4,4'
assert_normalized_card T-001 3 2 '1,2,3' '1,2,2'

assert_history_versions B-005 '1,2,3,4,4'
assert_history_versions B-007 '1,2,2'
assert_history_versions B-008 '1,2,2'
assert_history_versions S-013 '1,1,2,3,3,3'
assert_history_versions S-014 '1,2,2,2,2,2'
assert_history_versions T-004 '1,2,3,4'

for id in B-008 B-009 S-015 S-016 S-040; do
  path="$(card_path "$id")"
  versions="$(history_versions "$path" | tr ',' '\n')"
  duplicate="$(printf '%s\n' "$versions" | LC_ALL=C sort | uniq -d | head -1)"
  test -n "$duplicate" || fail "$id no longer retains a legal duplicate Version"
done

ORIGINAL_HISTORY_COUNT="$(awk '
  /^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$/ {
    in_change_log = 1
    next
  }
  in_change_log && /^\|[-:| ]+\|$/ { next }
  in_change_log && /^\| [0-9]+ \|/ {
    change = $5
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", change)
    if (change != "Normalized legacy status and delivery events to reuse the active definition Version.") count++
    next
  }
  in_change_log { in_change_log = 0 }
  END { print count }
' FS='|' "${WORK_ITEM_FILES[@]}")"
test "$ORIGINAL_HISTORY_COUNT" = "152" ||
  fail "expected 152 preserved original history rows, found $ORIGINAL_HISTORY_COUNT"

ORIGINAL_HISTORY_HASH="$(awk -v root="$ROOT_DIR/" '
  function trim(value) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
    return value
  }
  FNR == 1 { in_change_log = 0 }
  /^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$/ {
    in_change_log = 1
    next
  }
  in_change_log && /^\|[-:| ]+\|$/ { next }
  in_change_log && /^\| [0-9]+ \|/ {
    change = trim($5)
    reason = trim($6)
    if (change == "Normalized legacy status and delivery events to reuse the active definition Version.") next
    sub(/ Legacy migration: original Version [0-9]+; normalized to Version [0-9]+\.$/, "", reason)
    path = FILENAME
    sub("^" root, "", path)
    print path "\t" change "\t" reason
    next
  }
  in_change_log { in_change_log = 0 }
' FS='|' "${WORK_ITEM_FILES[@]}" | LC_ALL=C sort | shasum -a 256 | awk '{print $1}')"
test "$ORIGINAL_HISTORY_HASH" = "a5aa15c78a430862b65ab4857308cfeebac170db202f1649c05bcbc01bbb5630" ||
  fail "original Change/Reason history content changed"

printf 'Change Log contract checks passed.\n'
