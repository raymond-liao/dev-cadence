#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/src/workflows/backlog/SKILL.md"
ENTRY="$ROOT_DIR/src/workflows/using-dev-cadence/SKILL.md"
DOC="$ROOT_DIR/docs/workflows/backlog.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_literal() {
  local label="$1" literal="$2" path="$3"
  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_match() {
  local label="$1" pattern="$2" path="$3"
  rg --no-ignore -n "$pattern" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1" pattern="$2" path="$3"
  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

test -f "$SKILL" || fail "missing src/workflows/backlog/SKILL.md"
test -f "$DOC" || fail "missing docs/workflows/backlog.md"
test ! -e "$ROOT_DIR/src/workflows/discovery" || fail "removed discovery workflow still exists"
test ! -e "$ROOT_DIR/src/workflows/work-item-planning" || fail "removed work-item-planning workflow still exists"

assert_literal "name" "name: backlog" "$SKILL"
assert_literal "description" "description: Use when a user asks to create or register a Story, Task, or Bug card, admit an existing card, or maintain the delivery Backlog without starting implementation." "$SKILL"
assert_literal "asset declaration" "This is an Asset Workflow." "$SKILL"
assert_match "no delivery records" 'must not create `build/dev-cadence/` run manifests?.*stage records?.*confirmation records?.*checkpoint commits?' "$SKILL"

for path in \
  'docs/backlog.md' \
  'docs/stories/S-nnn-<slug>.md' \
  'docs/tasks/T-nnn-<slug>.md' \
  'docs/bugs/B-nnn-<slug>.md'; do
  assert_literal "owned path $path" "$path" "$SKILL"
done

for status in Draft Ready 'In Progress' Blocked Done Superseded Dropped; do
  assert_literal "status $status" "- \`$status\`" "$SKILL"
done

assert_literal "new request path" "### New Request" "$SKILL"
assert_literal "conforming card path" "### Conforming Existing Card" "$SKILL"
assert_literal "nonconforming card path" "### Nonconforming Existing Card" "$SKILL"
assert_match "conforming bypasses recreation" 'bypass card creation and Work Item Analysis|without rewriting it.*do not repeat Work Item Analysis' "$SKILL"
assert_match "Backlog required before claim" 'must enter Backlog before.*claimed|before it can be claimed' "$SKILL"
assert_match "nonconforming standard path" 'Nonconforming.*New Request|standard New Request path' "$SKILL"
assert_match "source preserved" 'do not overwrite or delete the supplied source|preserved.*New Request' "$SKILL"
assert_match "no compatibility mapping" 'do not add compatibility fields.*field mappings.*external-ID mappings.*synchronization metadata' "$SKILL"
assert_match "only conforming identity reuse" 'Only a conforming authoritative card may be reused.*same implementation identity' "$SKILL"
assert_match "nonconforming identity occupied" 'nonconforming source.*counts as occupied for collision avoidance.*must not be reused' "$SKILL"
assert_match "canonical-looking source preserved" 'already occupies a canonical-looking path.*leave that file untouched.*exclude it from Backlog' "$SKILL"
assert_match "fresh card identity" 'Allocate a fresh unused ID and path for the new Dev Cadence card' "$SKILL"
assert_match "nonconforming source not parallel authority" 'preserved nonconforming source is input evidence, not a second authoritative card' "$SKILL"
assert_match "semantic fields" 'semantic fields, not mandatory English heading strings' "$SKILL"
assert_match "explicit empty fields" 'Relationships and Open Questions must still be explicit.*explicit `none`' "$SKILL"

assert_literal "single sequence" "Necessary Clarification -> Backlog Proposal -> Backlog Result Confirmation" "$SKILL"
assert_literal "clarification not gate" "Necessary Clarification is not a formal confirmation gate." "$SKILL"
assert_match "one asset gate" 'At Backlog Result Confirmation' "$SKILL"
assert_match "atomic card Backlog" 'Card creation or admission and its necessary Backlog row are one atomic unit' "$SKILL"
assert_match "no orphan" 'must not create an orphaned card or orphaned Backlog row' "$SKILL"

assert_literal "Backlog owner" "Backlog is the authoritative owner of Backlog structure, lifecycle sections, and recommended pending order." "$SKILL"
assert_literal "pending order authority" 'The row order in `待处理` is the sole authoritative suggested implementation order.' "$SKILL"
assert_literal "section order" '1. `进行中`' "$SKILL"
assert_literal "pending section" '2. `待处理`' "$SKILL"
assert_literal "completed section" '3. `已完成`' "$SKILL"
assert_literal "closed section" '4. `已关闭`' "$SKILL"
assert_literal "table columns" 'ID | Title | Version | Status | Priority' "$SKILL"
assert_match "ordering identity" '`Ordering Version` identifies the latest user-confirmed pending-order decision' "$SKILL"
assert_match "lifecycle no ordering increment" 'Lifecycle synchronization.*must not increment `Ordering Version`' "$SKILL"
assert_literal "pending status mapping" '- `Draft`, `Ready`, or `Blocked` -> `待处理`;' "$SKILL"
assert_literal "in-progress status mapping" '- `In Progress` -> `进行中`;' "$SKILL"
assert_literal "done status mapping" '- `Done` -> `已完成`;' "$SKILL"
assert_literal "closed status mapping" '- `Superseded` or `Dropped` -> `已关闭`.' "$SKILL"
assert_match "atomic lifecycle move" 'Status change across lifecycle sections.*atomically update the card and move its Backlog row' "$SKILL"

assert_match "analysis handoff" 'route.*`work-item-analysis`|routes to `work-item-analysis`' "$SKILL"
assert_match "Story handoff" 'Ready Story.*`feature-dev`' "$SKILL"
assert_match "Task handoff" 'Task routes to `feature-dev`, `bug-fix`, or `refactor`' "$SKILL"
assert_match "Bug handoff" 'Bug routes to `bug-fix`' "$SKILL"
assert_match "no automatic claim" 'must not.*claim.*solely because.*registered|Registration never bypasses Backlog' "$SKILL"

assert_literal "entry route" '.dev-cadence/workflows/backlog/SKILL.md' "$ENTRY"
assert_match "entry conforming route" 'Conforming Existing Card.*`backlog`|conforming existing card.*`backlog`' "$ENTRY"
assert_match "entry nonconforming route" 'Nonconforming Existing Card.*`backlog`|nonconforming.*New Request' "$ENTRY"

assert_not_match "Story Map asset" 'docs/product-planning/story-map\.md' "$SKILL"
assert_not_match "Milestone ID" 'M-nnn' "$SKILL"
assert_not_match "Delivery record names" '01-requirements\.md|02-technical-solution\.md|03-implementation-plan\.md|04-code-review-report\.md' "$SKILL"
assert_not_match "personal paths" '/Users/|/private/tmp|/private/var|[A-Za-z]:\\Users\\' "$SKILL"

printf 'Backlog contract checks passed.\n'
