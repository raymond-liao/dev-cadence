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
assert_literal "exact installed commit skill path" '`.dev-cadence/skills/git-commit/SKILL.md`' "$ENTRY"
assert_match "managed context boundary" 'Workflow.*shared capability|shared capability.*Workflow' "$ENTRY"
assert_match "ordinary commit exclusion" 'ordinary.*commit.*[Dd]o not.*git-commit|[Dd]o not.*git-commit.*ordinary.*commit' "$ENTRY"
assert_literal "subagent task brief" 'When dispatching a subagent that may create a commit, include `.dev-cadence/skills/git-commit/SKILL.md`, the owning Dev Cadence context, and the staged-only constraint in the subagent task brief.' "$ENTRY"
assert_literal "subagent owning context" "the owning Dev Cadence context" "$ENTRY"
assert_literal "subagent staged-only constraint" "the staged-only constraint" "$ENTRY"

assert_match "internal-only description" '^description: Use when using-dev-cadence delegates a Dev Cadence-managed commit\.$' "$COMMIT_SKILL"
assert_match "delegated context required" '[Rr]efuse.*direct|direct.*[Rr]efuse|must be delegated' "$COMMIT_SKILL"
assert_match "staged path inspection" 'git diff (--cached|--staged) --name-only|git diff --name-only (--cached|--staged)' "$COMMIT_SKILL"
assert_match "cached diff inspection" 'git diff (--cached|--staged)' "$COMMIT_SKILL"
assert_match "staged content inspection" '[Cc]ontent.*git diff (--cached|--staged)|git diff (--cached|--staged).*content' "$COMMIT_SKILL"
assert_match "no staging rule" 'must not.*git add|[Dd]o not.*git add' "$COMMIT_SKILL"
assert_not_match "git add command" '^[[:space:]]*git add([[:space:]]|$)' "$COMMIT_SKILL"
assert_match "mixed declared scope blocks" '[Ss]top.*more than one declared Dev Cadence.*scope|more than one declared Dev Cadence.*scope.*[Ss]top' "$COMMIT_SKILL"
assert_match "sensitive files block" '[Ss]ensitive.*block|block.*[Ss]ensitive' "$COMMIT_SKILL"
assert_match "non-example env files block" '[Nn]on-example.*\.env|\.env.*[Nn]on-example' "$COMMIT_SKILL"
assert_match "runtime dev cadence config blocks" '[Rr]untime.*\.dev-cadence\.yaml|\.dev-cadence\.yaml.*[Rr]untime' "$COMMIT_SKILL"
assert_match "credential filename indicators block" '[Cc]redential.*secret.*token|secret.*token.*[Cc]redential|token.*[Cc]redential.*secret' "$COMMIT_SKILL"
assert_match "private key files block" '\.pem.*\.key|\.key.*\.pem|id_rsa.*id_ed25519|id_ed25519.*id_rsa' "$COMMIT_SKILL"
assert_match "private key material blocks" 'PRIVATE KEY' "$COMMIT_SKILL"
assert_match "runtime artifact policy blocks" '[Pp][Ii][Dd].*log.*[Pp]olicy|log.*[Pp][Ii][Dd].*[Pp]olicy' "$COMMIT_SKILL"
assert_match "live credential values block" '[Ll]ive.*password.*secret.*token.*API key.*credential|password.*secret.*token.*API key.*credential.*[Ll]ive' "$COMMIT_SKILL"
assert_match "machine-specific absolute paths block" '[Mm]achine-specific.*absolute path|absolute path.*[Mm]achine-specific' "$COMMIT_SKILL"
assert_match "benign content distinction" '[Pp]laceholder.*example.*test fixture|test fixture.*[Pp]laceholder.*example|example.*test fixture.*[Pp]laceholder' "$COMMIT_SKILL"
assert_match "uncertainty blocks" '[Ii]f uncertain.*block|block.*[Ii]f uncertain' "$COMMIT_SKILL"
assert_match "optional scope" 'scope.*optional|optional.*scope' "$COMMIT_SKILL"
assert_match "style means formatting" 'style.*format|format.*style' "$COMMIT_SKILL"
assert_match "build and ci types" '`build`.*`ci`|`ci`.*`build`' "$COMMIT_SKILL"
assert_match "technical language allowed" 'technical.*when.*accura|accura.*technical' "$COMMIT_SKILL"
assert_match "control returns to caller" 'return.*caller|caller.*control' "$COMMIT_SKILL"
assert_match "no follow-up git suggestions" 'must not suggest.*push.*amend.*reset|[Dd]o not suggest.*push.*amend.*reset' "$COMMIT_SKILL"

printf 'Git commit contract checks passed.\n'
