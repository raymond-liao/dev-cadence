#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FINISHING_SKILL="$ROOT_DIR/src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  local label="$1"
  local path="$2"
  test -f "$path" || fail "$label: missing $path"
}

assert_literal() {
  local label="$1"
  local literal="$2"
  local path="$3"

  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null || fail "missing $label"
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"

  rg --no-ignore -n "$pattern" "$path" >/dev/null || fail "missing $label"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"

  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label"
  fi
}

assert_file "Finishing skill" "$FINISHING_SKILL"
assert_literal "feature branch snapshot" 'FEATURE_BRANCH=$(git branch --show-current)' "$FINISHING_SKILL"
assert_literal "base branch selection" 'BASE_BRANCH=main' "$FINISHING_SKILL"
assert_literal "base branch existence check" 'git show-ref --verify --quiet refs/heads/main' "$FINISHING_SKILL"
assert_literal "expected feature SHA snapshot" 'EXPECTED_FEATURE_SHA=$(git rev-parse "$FEATURE_BRANCH")' "$FINISHING_SKILL"
assert_literal "expected base SHA snapshot" 'EXPECTED_BASE_SHA=$(git rev-parse "$BASE_BRANCH")' "$FINISHING_SKILL"
assert_literal "feature identity recheck" 'test "$(git rev-parse "$FEATURE_BRANCH")" = "$EXPECTED_FEATURE_SHA"' "$FINISHING_SKILL"
assert_literal "base identity recheck" 'test "$(git rev-parse "$BASE_BRANCH")" = "$EXPECTED_BASE_SHA"' "$FINISHING_SKILL"
assert_literal "fixed SHA merge" 'git merge "$EXPECTED_FEATURE_SHA"' "$FINISHING_SKILL"
assert_literal "already integrated verification" 'git merge-base --is-ancestor "$EXPECTED_FEATURE_SHA" "$BASE_BRANCH"' "$FINISHING_SKILL"
assert_literal "already integrated result" 'already-integrated' "$FINISHING_SKILL"
assert_literal "post merge HEAD capture" 'FINAL_BASE_SHA=$(git rev-parse "$BASE_BRANCH")' "$FINISHING_SKILL"
assert_literal "local only wording" 'local-only' "$FINISHING_SKILL"
assert_match "failure stops cleanup" 'failure.*(stop|停止).*(cleanup|清理)|cleanup.*(stop|停止).*(failure|失败)' "$FINISHING_SKILL"
assert_match "identity failure preserves branch" '(branch|分支).*(preserve|保留).*(identity|身份|SHA)' "$FINISHING_SKILL"
assert_not_match "local merge does not pull" '^[[:space:]]*git pull([[:space:]]|$)' "$FINISHING_SKILL"
assert_not_match "local merge does not merge mutable branch" '^[[:space:]]*git merge <feature-branch>' "$FINISHING_SKILL"

printf 'Finishing local merge contract checks passed.\n'
