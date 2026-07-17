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
  'git rev-parse .*--git-common-dir' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "worktree config propagation" \
  'copy.*\.dev-cadence\.yaml|\.dev-cadence\.yaml.*copy' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "deterministic config comparison" \
  'cmp -s' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "deterministic config overwrite" \
  'cp -f' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "configuration snapshot" \
  'configuration snapshot|resolved language identity|output_language.*manifest' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "snapshot precedence" \
  'snapshot.*first|snapshot.*before' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "visible fallback" \
  'fallback.*visible|explain.*fallback|missing.*unsupported.*English' \
  "src/skills/using-dev-cadence/SKILL.md"
assert_match "propagation failure handling" \
  'propagation failure.*stop|stop workflow output|environment failure' \
  "src/skills/using-dev-cadence/SKILL.md"

for workflow in feature-dev bug-fix refactor; do
  assert_match "$workflow shared config reference" \
    'using-dev-cadence|configuration propagation|configuration snapshot' \
    "src/skills/$workflow/SKILL.md"
done

for workflow in discovery architecture-design work-item-planning work-item-analysis; do
  assert_match "$workflow shared config reference" \
    'Configuration Identity And Worktree Continuation|configuration propagation' \
    "src/skills/$workflow/SKILL.md"
done

assert_match "work-item-analysis selected language" \
  'Use the selected language' \
  "src/skills/work-item-analysis/SKILL.md"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
PRIMARY_ROOT="$TMP_DIR/primary"
WORKTREE="$TMP_DIR/worktree"
mkdir -p "$PRIMARY_ROOT"
PRIMARY_ROOT="$(cd "$PRIMARY_ROOT" && pwd -P)"
git -C "$PRIMARY_ROOT" init -q
git -C "$PRIMARY_ROOT" config user.email "configuration-contract@example.invalid"
git -C "$PRIMARY_ROOT" config user.name "Configuration Contract"
printf '%s\n' '.dev-cadence.yaml' > "$PRIMARY_ROOT/.gitignore"
printf '%s\n' 'output_language: zh-CN' > "$PRIMARY_ROOT/.dev-cadence.yaml"
printf '%s\n' 'fixture' > "$PRIMARY_ROOT/marker.txt"
git -C "$PRIMARY_ROOT" add .gitignore marker.txt
git -C "$PRIMARY_ROOT" commit -q -m 'create configuration fixture'
git -C "$PRIMARY_ROOT" worktree add -q "$WORKTREE" -b fixture-worktree HEAD

test -f "$PRIMARY_ROOT/.dev-cadence.yaml" || fail "fixture primary config missing"
test ! -e "$WORKTREE/.dev-cadence.yaml" || fail "fixture worktree unexpectedly inherited ignored config"
COMMON_GIT_DIR="$(git -C "$WORKTREE" rev-parse --path-format=absolute --git-common-dir)"
test "$(dirname "$COMMON_GIT_DIR")/.dev-cadence.yaml" = "$PRIMARY_ROOT/.dev-cadence.yaml" \
  || fail "fixture common-directory config source mismatch"
CONFIG_SOURCE="$PRIMARY_ROOT/.dev-cadence.yaml"
CONFIG_TARGET="$WORKTREE/.dev-cadence.yaml"
printf '%s\n' 'output_language: en' > "$CONFIG_TARGET"
if ! cmp -s "$CONFIG_SOURCE" "$CONFIG_TARGET"; then
  cp -f "$CONFIG_SOURCE" "$CONFIG_TARGET"
fi
test -f "$CONFIG_TARGET" || fail "fixture propagated config missing"
cmp -s "$CONFIG_SOURCE" "$CONFIG_TARGET" || fail "fixture propagated config differs"
rg -q '^output_language: zh-CN$' "$CONFIG_TARGET" || fail "fixture propagated language mismatch"

printf 'Configuration contract checks passed.\n'
