#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SCRIPT="$ROOT_DIR/scripts/install.sh"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

test -f "$INSTALL_SCRIPT" || fail "missing installer: scripts/install.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARGET_REPO="$TMP_DIR/target"
mkdir -p "$TARGET_REPO"

bash "$INSTALL_SCRIPT" "$TARGET_REPO"

test -f "$TARGET_REPO/.dev-cadence/version" || fail "first install did not create package"
test -f "$TARGET_REPO/.dev-cadence/skills/git-commit/SKILL.md" || fail "first install did not create git-commit skill"
test -f "$TARGET_REPO/.dev-cadence/skills/document-conventions/SKILL.md" || fail "first install did not create document-conventions skill"
test -f "$TARGET_REPO/.dev-cadence/skills/open-question-registry/SKILL.md" || fail "first install did not create open-question-registry skill"
test -f "$TARGET_REPO/.dev-cadence/skills/work-item-analysis/SKILL.md" || fail "first install did not create work-item-analysis skill"
test ! -e "$TARGET_REPO/docs/open-questions.md" || fail "install created an empty target-repository Open Question Registry"
cmp -s "$ROOT_DIR/version" "$TARGET_REPO/.dev-cadence/version" || fail "installed version differs from source"

printf 'stale\n' > "$TARGET_REPO/.dev-cadence/stale-file"
bash "$INSTALL_SCRIPT" "$TARGET_REPO"

test ! -e "$TARGET_REPO/.dev-cadence/stale-file" || fail "update retained a stale package file"
test ! -d "$TARGET_REPO/.dev-cadence/.dev-cadence" || fail "update nested the package directory"
cmp -s "$ROOT_DIR/version" "$TARGET_REPO/.dev-cadence/version" || fail "updated version differs from source"
cmp -s \
  "$ROOT_DIR/src/skills/git-commit/SKILL.md" \
  "$TARGET_REPO/.dev-cadence/skills/git-commit/SKILL.md" || fail "installed git-commit skill differs from source"
cmp -s \
  "$ROOT_DIR/src/skills/document-conventions/SKILL.md" \
  "$TARGET_REPO/.dev-cadence/skills/document-conventions/SKILL.md" || fail "installed document-conventions skill differs from source"
cmp -s \
  "$ROOT_DIR/src/skills/open-question-registry/SKILL.md" \
  "$TARGET_REPO/.dev-cadence/skills/open-question-registry/SKILL.md" || fail "installed open-question-registry skill differs from source"
cmp -s \
  "$ROOT_DIR/src/skills/work-item-analysis/SKILL.md" \
  "$TARGET_REPO/.dev-cadence/skills/work-item-analysis/SKILL.md" || fail "installed work-item-analysis skill differs from source"

printf 'Install contract checks passed.\n'
