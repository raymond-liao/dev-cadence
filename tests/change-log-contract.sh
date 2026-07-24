#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/src/references/contracts/change-log.md"
BACKLOG_SKILL="$ROOT_DIR/src/workflows/backlog/SKILL.md"
ANALYSIS="$ROOT_DIR/src/workflows/work-item-analysis/SKILL.md"
BACKLOG="$ROOT_DIR/docs/delivery/backlog.md"
REGISTRY="$ROOT_DIR/docs/delivery/open-questions.md"
MIGRATION_CHANGE='Normalized legacy status and delivery events to reuse the active definition Version.'
ORIGINAL_ROW_COUNTS='B-001:1
B-002:3
B-003:1
B-004:2
B-005:5
B-006:2
B-007:3
B-008:3
B-009:3
B-010:1
B-011:1
B-012:1
S-003:2
S-004:3
S-005:3
S-007:4
S-008:6
S-009:3
S-010:5
S-011:5
S-012:5
S-016:5
S-017:5
S-018:1
S-019:1
S-025:1
S-027:1
S-029:1
S-030:1
S-035:1
S-036:2
S-037:2
S-040:2
S-041:3
T-001:3
T-003:1
T-004:4'
WORK_ITEM_DIRS=(
  "$ROOT_DIR/docs/delivery/stories"
  "$ROOT_DIR/docs/delivery/tasks"
  "$ROOT_DIR/docs/delivery/bugs"
)
WORK_ITEM_FILES=(
  "$ROOT_DIR/docs/delivery/stories/"*.md
  "$ROOT_DIR/docs/delivery/tasks/"*.md
  "$ROOT_DIR/docs/delivery/bugs/"*.md
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
  local path="$1"
  local limit="${2:-0}"

  awk -v limit="$limit" '
    /^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$/ {
      in_change_log = 1
      next
    }
    in_change_log && /^\|[-:| ]+\|$/ { next }
    in_change_log && /^\| [0-9]+ \|/ {
      if (limit > 0 && row_count >= limit) next
      row_count++
      version = $2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", version)
      versions = versions (versions == "" ? "" : ",") version
      next
    }
    in_change_log { in_change_log = 0 }
    END { print versions }
  ' FS='|' "$path"
}

history_signatures() {
  local path="$1"
  local limit="$2"

  awk -v limit="$limit" '
    function trim(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }
    /^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$/ {
      in_change_log = 1
      next
    }
    in_change_log && /^\|[-:| ]+\|$/ { next }
    in_change_log && /^\| [0-9]+ \|/ {
      recorded_at = trim($3)
      change = trim($5)
      if (change != "Normalized legacy status and delivery events to reuse the active definition Version." && row_count < limit) {
        row_count++
        print recorded_at " || " change
      }
      next
    }
    in_change_log { in_change_log = 0 }
  ' FS='|' "$path"
}

assert_history_versions() {
  local id="$1"
  local expected="$2"
  local path
  local actual
  local expected_rows

  path="$(card_path "$id")"
  expected_rows="$(printf '%s\n' "$expected" | awk -F, '{ print NF }')"
  actual="$(history_versions "$path" "$expected_rows")"
  test "$actual" = "$expected" ||
    fail "$id history versions are $actual, expected $expected"
}

assert_history_signatures() {
  local id="$1"
  shift
  local path
  local actual
  local expected
  local expected_rows

  path="$(card_path "$id")"
  expected_rows="$#"
  actual="$(history_signatures "$path" "$expected_rows")"
  expected="$(printf '%s\n' "$@")"
  test "$actual" = "$expected" ||
    fail "$id history event order does not match the confirmed sequence"
}

assert_normalized_card() {
  local id="$1"
  local old_current="$2"
  local new_current="$3"
  local old_rows="$4"
  local new_rows="$5"
  local path
  local top_version
  local migration_change="$MIGRATION_CHANGE"
  local migration_reason="Old current $old_current -> new current $new_current; original row versions $old_rows -> normalized row versions $new_rows."

  path="$(card_path "$id")"
  top_version="$(sed -n 's/^- Version[：:][[:space:]]*`\([0-9][0-9]*\)`.*/\1/p' "$path")"
  test "$top_version" = "$new_current" ||
    fail "$id top Version is $top_version, expected $new_current"
  assert_history_versions "$id" "$new_rows,$new_current"
  assert_literal "$id migration change" "$migration_change" "$path"
  assert_literal "$id migration reason" "$migration_reason" "$path"

  awk -F'|' -v id="$id" -v old_csv="$old_rows" -v new_csv="$new_rows" '
    function trim(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }
    BEGIN {
      expected_rows = split(old_csv, old_versions, ",")
      split(new_csv, new_versions, ",")
    }
    /^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$/ {
      in_change_log = 1
      next
    }
    in_change_log && /^\|[-:| ]+\|$/ { next }
    in_change_log && /^\| [0-9]+ \|/ && row_count < expected_rows {
      row_count++
      reason = trim($6)
      suffix = "Legacy migration: original Version " old_versions[row_count] "; normalized to Version " new_versions[row_count] "."
      has_suffix = index(reason, suffix) > 0
      if (old_versions[row_count] != new_versions[row_count] && !has_suffix) {
        printf "%s row %d is missing exact migration suffix\n", id, row_count > "/dev/stderr"
        invalid = 1
      }
      if (old_versions[row_count] == new_versions[row_count] && reason ~ /Legacy migration: original Version/) {
        printf "%s row %d has an unexpected migration suffix\n", id, row_count > "/dev/stderr"
        invalid = 1
      }
      next
    }
    END {
      if (row_count != expected_rows) invalid = 1
      exit invalid
    }
  ' "$path" || fail "$id normalized row migration suffixes do not match the explicit map"
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

for consumer in "$BACKLOG_SKILL" "$ANALYSIS"; do
  assert_literal "shared contract read" '.dev-cadence/references/contracts/change-log.md' "$consumer"

  for literal in "${PUBLIC_CONTRACT_LITERALS[@]}"; do
    assert_not_literal "duplicated public Change Log contract detail" "$literal" "$consumer"
  done
done

CARD_COUNT="$(find "${WORK_ITEM_DIRS[@]}" -maxdepth 1 -name '*.md' -print | wc -l | tr -d ' ')"
test "$CARD_COUNT" = "42" || fail "expected 42 current work-item cards, found $CARD_COUNT"

if rg -n '^\| Version \| Date \| Change \| Reason \|' "${WORK_ITEM_DIRS[@]}"; then
  fail "legacy four-column Change Log remains"
fi

STANDARD_HEADER_COUNT="$(rg -l '^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|' \
  "${WORK_ITEM_DIRS[@]}" | wc -l | tr -d ' ')"
test "$STANDARD_HEADER_COUNT" = "42" ||
  fail "not every current work-item card uses the standard schema"

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

ORIGINAL_METADATA="$(while IFS=: read -r id expected_rows; do
  path="$(card_path "$id")"
  awk -F'|' -v id="$id" -v limit="$expected_rows" '
    function trim(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }
    /^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$/ {
      in_change_log = 1
      next
    }
    in_change_log && /^\|[-:| ]+\|$/ { next }
    in_change_log && /^\| [0-9]+ \|/ && row_count < limit {
      row_count++
      print id "\t" trim($3) "\t" trim($4)
      next
    }
    END {
      if (row_count != limit) exit 1
    }
  ' "$path" || fail "$id has fewer than $expected_rows original rows"
done <<< "$ORIGINAL_ROW_COUNTS")"

test "$(printf '%s\n' "$ORIGINAL_METADATA" | wc -l | tr -d ' ')" = "96" ||
  fail "explicit original-row cohort is not 96 rows"

ORIGINAL_METADATA_HASH="$(printf '%s\n' "$ORIGINAL_METADATA" |
  LC_ALL=C sort | shasum -a 256 | awk '{print $1}')"
test "$ORIGINAL_METADATA_HASH" = "457fc09eee913fb51a328c1a48bb39705ab8dcf1a12892258e16057029ac1a4b" ||
  fail "original Recorded At/Recorded By migration metadata changed: $ORIGINAL_METADATA_HASH"

printf '%s\n' "$ORIGINAL_METADATA" | awk -F'\t' '
  $2 ~ /^legacy: recorded-at/ {
    if ($2 ~ /^legacy: recorded-at precision unknown; original [0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
      precision_unknown++
    } else if ($2 == "legacy: recorded-at unknown") {
      date_unknown++
    } else {
      printf "malformed legacy Recorded At for %s: %s\n", $1, $2 > "/dev/stderr"
      invalid = 1
    }
  }
  $3 ~ /^legacy: recorded-by/ {
    if ($3 == "legacy: recorded-by unknown") {
      author_unknown++
    } else {
      printf "malformed legacy Recorded By for %s: %s\n", $1, $3 > "/dev/stderr"
      invalid = 1
    }
  }
  END {
    if (precision_unknown != 82) {
      printf "legacy precision-unknown count is %d, expected 82\n", precision_unknown > "/dev/stderr"
      invalid = 1
    }
    if (date_unknown != 0) {
      printf "legacy recorded-at-unknown count is %d, expected 0\n", date_unknown > "/dev/stderr"
      invalid = 1
    }
    if (author_unknown != 81) {
      printf "legacy recorded-by-unknown count is %d, expected 81\n", author_unknown > "/dev/stderr"
      invalid = 1
    }
    exit invalid
  }
' || fail "legacy sentinel values or counts do not match the migration baseline"

assert_not_match "Registry Change Log" '^## Change Log$' "$REGISTRY"
assert_not_match "Registry Change Log table" '^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$' "$REGISTRY"

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

assert_normalized_card S-003 2 1 '1,2' '1,1'
assert_normalized_card S-004 3 1 '1,2,3' '1,1,1'
assert_normalized_card S-005 3 2 '1,2,3' '1,2,2'
assert_normalized_card S-007 4 3 '1,2,3,4' '1,2,3,3'
assert_normalized_card S-008 6 3 '1,2,3,4,5,6' '1,2,2,2,3,3'
assert_normalized_card S-009 3 2 '1,2,3' '1,2,2'
assert_normalized_card S-010 5 3 '1,2,3,4,5' '1,2,3,3,3'
assert_normalized_card S-011 5 2 '1,2,3,4,5' '1,2,2,2,2'
assert_normalized_card S-012 5 2 '1,2,3,4,5' '1,1,2,2,2'
assert_normalized_card T-001 3 2 '1,2,3' '1,2,2'

MIGRATION_CARD_IDS="$(rg -l -F "$MIGRATION_CHANGE" "${WORK_ITEM_DIRS[@]}" |
  sed -E 's#.*/((S|T|B)-[0-9]+)-[^/]+\.md#\1#' | LC_ALL=C sort)"
EXPECTED_MIGRATION_CARD_IDS='S-003
S-004
S-005
S-007
S-008
S-009
S-010
S-011
S-012
T-001'
test "$(printf '%s\n' "$MIGRATION_CARD_IDS" | wc -l | tr -d ' ')" = "10" ||
  fail "expected exactly 10 migration-event cards"
test "$MIGRATION_CARD_IDS" = "$EXPECTED_MIGRATION_CARD_IDS" ||
  fail "migration-event card set differs from the explicit normalization set"
MIGRATION_EVENT_COUNT="$(rg -o -F "$MIGRATION_CHANGE" "${WORK_ITEM_DIRS[@]}" |
  wc -l | tr -d ' ')"
test "$MIGRATION_EVENT_COUNT" = "10" ||
  fail "expected exactly 10 migration events, found $MIGRATION_EVENT_COUNT"

MIGRATION_SUFFIX_COUNT="$(rg -o 'Legacy migration: original Version [0-9]+; normalized to Version [0-9]+\.' \
  "${WORK_ITEM_DIRS[@]}" | wc -l | tr -d ' ')"
test "$MIGRATION_SUFFIX_COUNT" = "20" ||
  fail "expected exactly 20 normalized-row migration suffixes, found $MIGRATION_SUFFIX_COUNT"

assert_history_versions B-005 '1,2,3,4,4'
assert_history_versions B-007 '1,2,2'
assert_history_versions B-008 '1,2,2'
assert_history_versions T-004 '1,2,3,4'

assert_history_signatures B-005 \
  'legacy: recorded-at precision unknown; original 2026-07-16 || 创建 Refactor 确认阶段缺少用户选项 Bug。' \
  'legacy: recorded-at precision unknown; original 2026-07-17 || 将问题从 Refactor 扩展为六个已安装 Workflow 的确认门选项与结果语义缺口。' \
  'legacy: recorded-at precision unknown; original 2026-07-17 || 将确认门问题扩展为“先展示内容摘要，再提供选项和结果语义”，并明确文件只能作为证据链接。' \
  'legacy: recorded-at precision unknown; original 2026-07-18 || 补充 S-017 用户验收提示未展示可选项的现象，并关联 S-017 与 S-018。' \
  'legacy: recorded-at precision unknown; original 2026-07-18 || 完成当前终态菜单补强交付并将状态更新为 `Done`。'
assert_history_signatures B-007 \
  'legacy: recorded-at precision unknown; original 2026-07-17 || 创建并行视图状态与 Workflow 入口资格混用 Bug。' \
  'legacy: recorded-at precision unknown; original 2026-07-18 || 按 B-009 的已验收决定改用四列表级职责边界，移除逐行入口资格列要求并关闭 Q-005。' \
  'legacy: recorded-at precision unknown; original 2026-07-18 || 完成当前设计对齐交付并将状态更新为 `Done`。'
assert_history_signatures B-008 \
  '2026-07-18T06:54:19+0800 || 创建 Bug 卡片。' \
  '2026-07-18T19:29:42+0800 || 将完成同步明确为成功 merge 后的 Bug 卡片与 Backlog 原子写回，并补充交付引用、执行 Change Log、冲突和幂等要求。' \
  '2026-07-18T20:43:37+0800 || 完成当前卡片与 Backlog 写回补强交付并将状态更新为 `Done`。'
assert_history_signatures T-004 \
  'legacy: recorded-at precision unknown; original 2026-07-17 || 创建 Git 提交 skill 接入任务。' \
  'legacy: recorded-at precision unknown; original 2026-07-17 || 明确 Workflow 与 `git-commit` 的职责边界、pre-staged 调用顺序及适用提交类型。' \
  'legacy: recorded-at precision unknown; original 2026-07-17 || 将 `git-commit` 收敛为由 `using-dev-cadence` 集中路由的内部共享能力。' \
  'legacy: recorded-at precision unknown; original 2026-07-17 || 将调用边界扩展为所有已安装 Workflow 和入口路由的 shared capability，并固化提交信息规则。'

for id in B-008 B-009 S-016 S-040; do
  path="$(card_path "$id")"
  versions="$(history_versions "$path" | tr ',' '\n')"
  duplicate="$(printf '%s\n' "$versions" | LC_ALL=C sort | uniq -d | head -1)"
  test -n "$duplicate" || fail "$id no longer retains a legal duplicate Version"
done

ORIGINAL_HISTORY_COUNT="$(printf '%s\n' "$ORIGINAL_ROW_COUNTS" |
  awk -F: '{ count += $2 } END { print count }')"
test "$ORIGINAL_HISTORY_COUNT" = "96" ||
  fail "explicit original-row cohort is $ORIGINAL_HISTORY_COUNT rows, expected 96"

ORIGINAL_HISTORY_HASH="$(while IFS=: read -r id expected_rows; do
  path="$(card_path "$id")"
  relative_path="${path#"$ROOT_DIR/"}"
  awk -F'|' -v path="$relative_path" -v limit="$expected_rows" '
    function trim(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }
    /^\| Version \| Recorded At \| Recorded By \| Change \| Reason \|$/ {
      in_change_log = 1
      next
    }
    in_change_log && /^\|[-:| ]+\|$/ { next }
    in_change_log && /^\| [0-9]+ \|/ && row_count < limit {
      row_count++
      change = trim($5)
      reason = trim($6)
      sub(/ Legacy migration: original Version [0-9]+; normalized to Version [0-9]+\.$/, "", reason)
      print path "\t" change "\t" reason
      next
    }
    END {
      if (row_count != limit) exit 1
    }
  ' "$path" || fail "$id original-row payload cohort is incomplete"
done <<< "$ORIGINAL_ROW_COUNTS" | LC_ALL=C sort | shasum -a 256 | awk '{print $1}')"
test "$ORIGINAL_HISTORY_HASH" = "fa4e90835bb86327074e083dd52fdc31dfed26d470fea4ac364abc90f6fc5cee" ||
  fail "original Change/Reason history content changed: $ORIGINAL_HISTORY_HASH"

printf 'Change Log contract checks passed.\n'
