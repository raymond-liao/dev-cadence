#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  rg --no-ignore -n "$pattern" "$ROOT_DIR/$path" >/dev/null || fail "$label: missing '$pattern' in $path"
}

assert_match "stable git common directory resolution" \
  'git rev-parse --git-common-dir' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "worktree config propagation" \
  'copy.*\.dev-cadence\.yaml|\.dev-cadence\.yaml.*copy' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "configuration snapshot" \
  'configuration snapshot|resolved language identity|output_language.*manifest' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "visible fallback" \
  'fallback.*visible|explain.*fallback|missing.*unsupported.*English' \
  "src/skills/using-dev-cadence/SKILL.md"

for workflow in feature-dev bug-fix refactor; do
  assert_match "$workflow shared config reference" \
    'using-dev-cadence|configuration propagation|configuration snapshot' \
    "src/skills/$workflow/SKILL.md"
done

printf 'Configuration contract checks passed.\n'
