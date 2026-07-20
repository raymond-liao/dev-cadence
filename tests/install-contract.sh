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
test -f "$TARGET_REPO/.dev-cadence/references/contracts/change-log.md" || fail "first install did not create Change Log contract"
test -f "$TARGET_REPO/.dev-cadence/skills/git-commit/SKILL.md" || fail "first install did not create git-commit skill"
test -f "$TARGET_REPO/.dev-cadence/references/document-conventions/SKILL.md" || fail "first install did not create document-conventions skill"
test -f "$TARGET_REPO/.dev-cadence/skills/open-question-registry/SKILL.md" || fail "first install did not create open-question-registry skill"
test -f "$TARGET_REPO/.dev-cadence/workflows/work-item-analysis/SKILL.md" || fail "first install did not create work-item-analysis skill"
test -f "$TARGET_REPO/.dev-cadence/workflows/using-dev-cadence/scripts/validate-delivery-record.sh" || fail "first install did not create delivery-record validator"
test -f "$TARGET_REPO/.dev-cadence/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh" || fail "first install did not create feature recovery validator"
test ! -e "$TARGET_REPO/docs/open-questions.md" || fail "install created an empty target-repository Open Question Registry"
cmp -s "$ROOT_DIR/version" "$TARGET_REPO/.dev-cadence/version" || fail "installed version differs from source"
cmp -s \
  "$ROOT_DIR/src/references/contracts/change-log.md" \
  "$TARGET_REPO/.dev-cadence/references/contracts/change-log.md" || fail "installed Change Log contract differs from source"
for workflow in using-dev-cadence discovery architecture-design; do
  test -f "$TARGET_REPO/.dev-cadence/workflows/$workflow/SKILL.md" ||
    fail "first install did not create $workflow workflow"
  cmp -s \
    "$ROOT_DIR/src/workflows/$workflow/SKILL.md" \
    "$TARGET_REPO/.dev-cadence/workflows/$workflow/SKILL.md" ||
    fail "first installed $workflow workflow differs from source"
done
test ! -e "$TARGET_REPO/.dev-cadence/skills/using-dev-cadence" || fail "first install retained legacy workflow path"
test ! -e "$TARGET_REPO/.dev-cadence/skills/contracts" || fail "first install retained legacy reference path"

printf 'stale\n' > "$TARGET_REPO/.dev-cadence/stale-file"
bash "$INSTALL_SCRIPT" "$TARGET_REPO"

test ! -e "$TARGET_REPO/.dev-cadence/stale-file" || fail "update retained a stale package file"
test ! -d "$TARGET_REPO/.dev-cadence/.dev-cadence" || fail "update nested the package directory"
cmp -s "$ROOT_DIR/version" "$TARGET_REPO/.dev-cadence/version" || fail "updated version differs from source"
cmp -s \
  "$ROOT_DIR/src/skills/git-commit/SKILL.md" \
  "$TARGET_REPO/.dev-cadence/skills/git-commit/SKILL.md" || fail "installed git-commit skill differs from source"
cmp -s \
  "$ROOT_DIR/src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh" \
  "$TARGET_REPO/.dev-cadence/workflows/using-dev-cadence/scripts/validate-delivery-record.sh" || fail "installed delivery-record validator differs from source"
cmp -s \
  "$ROOT_DIR/src/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh" \
  "$TARGET_REPO/.dev-cadence/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh" || fail "installed feature recovery validator differs from source"
cmp -s \
  "$ROOT_DIR/src/references/document-conventions/SKILL.md" \
  "$TARGET_REPO/.dev-cadence/references/document-conventions/SKILL.md" || fail "installed document-conventions skill differs from source"
cmp -s \
  "$ROOT_DIR/src/skills/open-question-registry/SKILL.md" \
  "$TARGET_REPO/.dev-cadence/skills/open-question-registry/SKILL.md" || fail "installed open-question-registry skill differs from source"
cmp -s \
  "$ROOT_DIR/src/workflows/work-item-analysis/SKILL.md" \
  "$TARGET_REPO/.dev-cadence/workflows/work-item-analysis/SKILL.md" || fail "installed work-item-analysis skill differs from source"
for workflow in using-dev-cadence discovery architecture-design; do
  cmp -s \
    "$ROOT_DIR/src/workflows/$workflow/SKILL.md" \
    "$TARGET_REPO/.dev-cadence/workflows/$workflow/SKILL.md" ||
    fail "updated installed $workflow workflow differs from source"
done
test ! -e "$TARGET_REPO/.dev-cadence/skills/using-dev-cadence" || fail "update retained legacy workflow path"
test ! -e "$TARGET_REPO/.dev-cadence/skills/contracts" || fail "update retained legacy reference path"

printf 'Install contract checks passed.\n'
