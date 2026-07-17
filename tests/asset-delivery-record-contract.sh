#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
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

assert_literal "record model section" "## Workflow Record Models" "$ENTRY_SKILL"
assert_literal "Asset class" "Asset Workflow" "$ENTRY_SKILL"
assert_literal "Delivery class" "Delivery Workflow" "$ENTRY_SKILL"

for workflow in Discovery "Work Item Planning" "Work Item Analysis" "Architecture Design"; do
  assert_match "Asset member $workflow" "Asset Workflow.*$workflow|$workflow.*Asset Workflow" "$ENTRY_SKILL"
done

for workflow in "Feature Dev" "Bug Fix" Refactor; do
  assert_match "Delivery member $workflow" "Delivery Workflow.*$workflow|$workflow.*Delivery Workflow" "$ENTRY_SKILL"
done

for rule in \
  'only create or update durable authoritative assets under `docs/`' \
  'must not create `build/dev-cadence/` run manifests' \
  'stage records, confirmation records, checkpoint commits' \
  'must not write commit hashes, approver identities, approval timestamps, or workflow run status into business assets' \
  'Version, Change Log, status, relationships, Open Questions, and Rejected Directions'; do
  assert_literal "Asset rule $rule" "$rule" "$ENTRY_SKILL"
done

for rule in \
  'complete delivery evidence chain' \
  'requirements, diagnosis, or refactor-scope records' \
  'solution, implementation plan, implementation, review, testing, business acceptance, Git integration, and cleanup evidence'; do
  assert_literal "Delivery rule $rule" "$rule" "$ENTRY_SKILL"
done

assert_match "Delivery continuation" 'Delivery Workflow.*manifest|manifest.*Delivery Workflow' "$ENTRY_SKILL"
assert_match "Asset continuation" 'Asset Workflow.*conversation.*user goal.*authoritative asset|conversation.*user goal.*authoritative asset.*Asset Workflow' "$ENTRY_SKILL"
assert_match "single model selection" 'new workflow.*exactly one.*record model|exactly one.*record model.*new workflow' "$ENTRY_SKILL"
assert_match "no mixed model" 'must not mix|do not mix' "$ENTRY_SKILL"
assert_not_match \
  "temporary Discovery exception" \
  'Until S-013 is complete|legacy run-record and checkpoint instructions|Remove this exception when S-013 migrates Discovery' \
  "$ENTRY_SKILL"

assert_match "atomic registry synchronization" 'create.*modify.*migrate.*status.*same operation.*Registry|Registry.*same operation.*create.*modify.*migrate.*status' "$ENTRY_SKILL"
assert_match "unsynchronized workflow gate" 'must not.*advance.*confirmation gate|confirmation gate.*must not.*advance' "$ENTRY_SKILL"
assert_match "delivery temporary ownership" 'build/.*Registry.*temporarily.*full body|Registry.*temporarily.*full body.*build/' "$ENTRY_SKILL"
assert_match "delivery records are not registry authority" 'Registry.*must not.*build/.*authoritative|build/.*must not.*authoritative.*Registry' "$ENTRY_SKILL"

assert_literal "Architecture Design Asset declaration" "This is an Asset Workflow." "$ROOT_DIR/src/skills/architecture-design/SKILL.md"
assert_match "Architecture Design no run records" 'must not create.*run manifest|run manifest.*must not create' "$ROOT_DIR/src/skills/architecture-design/SKILL.md"
assert_literal "Work Item Planning Asset declaration" "This is an Asset Workflow." "$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
assert_match "Work Item Planning durable docs assets" 'durable planning assets under `docs/`|create or update only durable planning assets' "$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
assert_match "Work Item Planning no run records" 'must not create `build/dev-cadence/` run manifests?.*stage records?.*confirmation records?.*checkpoint commits?' "$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
assert_match "Work Item Planning no delivery evidence copy" 'must not copy the Delivery Workflow record chain|Do not copy Delivery Workflow evidence into planning assets' "$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
assert_not_match "Work Item Planning delivery evidence headings" '04-code-review-report\.md|01-requirements\.md|02-technical-solution\.md|03-implementation-plan\.md|Business Acceptance' "$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
assert_literal "Work Item Analysis Asset declaration" "This is an Asset Workflow." "$ROOT_DIR/src/skills/work-item-analysis/SKILL.md"
assert_match "Work Item Analysis durable docs assets" 'authoritative Story, Task, and Bug cards under `docs/`|create or update only authoritative Story, Task, and Bug cards under `docs/`' "$ROOT_DIR/src/skills/work-item-analysis/SKILL.md"
assert_match "Work Item Analysis no run records" 'must not create `build/dev-cadence/` run manifests?.*stage records?.*confirmation records?.*checkpoint commits?' "$ROOT_DIR/src/skills/work-item-analysis/SKILL.md"
assert_match "Work Item Analysis no delivery evidence copy" 'must not copy the Delivery Workflow record chain|Do not copy Delivery Workflow evidence into work-item assets' "$ROOT_DIR/src/skills/work-item-analysis/SKILL.md"
assert_not_match "Work Item Analysis delivery evidence headings" '04-code-review-report\.md|01-requirements\.md|02-technical-solution\.md|03-implementation-plan\.md|Business Acceptance' "$ROOT_DIR/src/skills/work-item-analysis/SKILL.md"

for skill in feature-dev bug-fix refactor; do
  path="$ROOT_DIR/src/skills/$skill/SKILL.md"
  assert_literal "$skill Delivery declaration" "This is a Delivery Workflow." "$path"
  assert_match "$skill complete evidence retention" 'complete.*evidence chain|evidence chain.*complete' "$path"
done

printf 'Asset and Delivery record contract checks passed.\n'
