#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"
COMMIT_SKILL="$ROOT_DIR/src/skills/git-commit/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
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

assert_literal "shared commit section" "## Shared Commit Capability" "$ENTRY"
assert_literal "installed commit skill path" ".dev-cadence/skills/git-commit/SKILL.md" "$ENTRY"
assert_match "managed context boundary" 'Workflow.*shared capability|shared capability.*Workflow' "$ENTRY"
assert_match "ordinary commit exclusion" 'ordinary.*commit.*[Dd]o not.*git-commit|[Dd]o not.*git-commit.*ordinary.*commit' "$ENTRY"
assert_match "subagent dispatch propagation" 'subagent.*task brief.*git-commit|git-commit.*subagent.*task brief' "$ENTRY"

assert_match "internal-only description" '^description: Use when using-dev-cadence delegates a Dev Cadence-managed commit\.$' "$COMMIT_SKILL"
assert_match "delegated context required" '[Rr]efuse.*direct|direct.*[Rr]efuse|must be delegated' "$COMMIT_SKILL"
assert_match "cached diff inspection" 'git diff (--cached|--staged)' "$COMMIT_SKILL"
assert_match "no staging rule" 'must not.*git add|[Dd]o not.*git add' "$COMMIT_SKILL"
assert_not_match "git add command" '^[[:space:]]*git add([[:space:]]|$)' "$COMMIT_SKILL"
assert_match "sensitive files block" '[Ss]ensitive.*block|block.*[Ss]ensitive' "$COMMIT_SKILL"
assert_match "optional scope" 'scope.*optional|optional.*scope' "$COMMIT_SKILL"
assert_match "style means formatting" 'style.*format|format.*style' "$COMMIT_SKILL"
assert_match "build and ci types" '`build`.*`ci`|`ci`.*`build`' "$COMMIT_SKILL"
assert_match "technical language allowed" 'technical.*when.*accura|accura.*technical' "$COMMIT_SKILL"
assert_match "control returns to caller" 'return.*caller|caller.*control' "$COMMIT_SKILL"
assert_match "no follow-up git suggestions" 'must not suggest.*push.*amend.*reset|[Dd]o not suggest.*push.*amend.*reset' "$COMMIT_SKILL"

printf 'Git commit contract checks passed.\n'
