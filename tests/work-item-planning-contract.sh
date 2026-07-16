#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"

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

assert_block() {
  local label="$1"
  local block="$2"
  local path="$3"

  rg --no-ignore -U -F -n -- "$block" "$path" >/dev/null ||
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

assert_file "$SKILL"
assert_literal \
  "description" \
  "description: Use when a user asks to create, update, or review Story Map, milestone, or work-item planning assets in a target project." \
  "$SKILL"
assert_literal "workflow heading" "# Work Item Planning" "$SKILL"
assert_literal "asset declaration" "This is an Asset Workflow." "$SKILL"
assert_match "no delivery records" 'must not create `build/dev-cadence/` run manifests?.*stage records?.*confirmation records?.*checkpoint commits?' "$SKILL"
assert_literal 'no delivery chain copy' 'It must not copy the Delivery Workflow record chain used by `feature-dev`, `bug-fix`, or `refactor`.' "$SKILL"

assert_match "portfolio planning mode" '`portfolio planning`|portfolio planning' "$SKILL"
assert_match "direct intake mode" '`direct intake`|direct intake' "$SKILL"
assert_match "mode boundary" 'support both `portfolio planning` and `direct intake`' "$SKILL"
assert_match "planning scope confirmation stage" 'Planning Inputs And Scope Confirmation' "$SKILL"
assert_match "planning proposal stage" 'Planning Structure Proposal' "$SKILL"
assert_match "planning confirmation stage" 'Planning Result Confirmation' "$SKILL"

assert_match "input precedence conversation" '1\..*current conversation.*explicit user confirmations' "$SKILL"
assert_match "input precedence product assets" '2\..*User Journey, PRD, and Business Architecture assets' "$SKILL"
assert_match "input precedence planning assets" '3\..*Story Map, Backlog, and existing Story / Task / Bug cards' "$SKILL"
assert_match "authoritative asset paths" 'docs/product-planning/story-map\.md|docs/backlog\.md|docs/stories/S-nnn-<slug>\.md|docs/tasks/T-nnn-<slug>\.md|docs/bugs/B-nnn-<slug>\.md' "$SKILL"
assert_literal "feature ownership boundary" "Discovery is the sole owner of confirmed User Journey, PRD, Business Architecture, and Feature identities and conclusions." "$SKILL"
assert_match "cannot create feature cards" 'create Feature cards;' "$SKILL"
assert_match "must not change feature identity" 'change a Feature ID, Type, Title, business identity, or Journey order' "$SKILL"

assert_literal "story map path" "docs/product-planning/story-map.md" "$SKILL"
assert_literal "single logical story map" "Maintain one logical global Story Map. Do not create multiple competing Story Maps unless the user explicitly changes the repository contract." "$SKILL"
assert_match "offline and system backbone" 'reference all confirmed `Offline` and `System` Features' "$SKILL"
assert_match "offline context only" 'keep `Offline` Features as business context only' "$SKILL"
assert_match "system items only" 'allow Stories and only necessary Tasks under `System` Features' "$SKILL"
assert_match "three planning paths" 'Happy Path.*Alternative Path.*Sad Path|Sad Path.*Alternative Path.*Happy Path' "$SKILL"
assert_match "bugs stay out of story map" 'Bug cards do not enter the Story Map' "$SKILL"

assert_match "milestone ids" 'Milestones must use stable `M-nnn` IDs' "$SKILL"
assert_literal "milestone schema" "ID | Title | Goal | Included Work Items | Derived From" "$SKILL"
assert_literal 'MVP rule' '`MVP` is the first user-confirmed milestone. It is not an automatically computed result.' "$SKILL"
assert_match "milestone explicit work items" '`Included Work Items` must list explicit Story or Task IDs' "$SKILL"

assert_match "story id pattern" 'Story: `S-nnn`' "$SKILL"
assert_match "task id pattern" 'Task: `T-nnn`' "$SKILL"
assert_match "bug id pattern" 'Bug: `B-nnn`' "$SKILL"
assert_block "minimum card fields" $'ID\nVersion\nStatus\nTitle\nGoal or business result\nProduct or work-item references\nRelationships\nChange Log' "$SKILL"
assert_literal 'relationships required' '`Relationships` is required. Dependencies, blockers, replacements, related items, and similar planning relationships must be recorded explicitly instead of being implied only by Story Map position or narrative text.' "$SKILL"

for status in '`Draft`' '`Ready`' '`In Progress`' '`Blocked`' '`Done`' '`Superseded`' '`Dropped`'; do
  assert_match "canonical status $status" "$status" "$SKILL"
done
assert_literal 'story ready gate' 'Story must reach `Ready` before entering `feature-dev`.' "$SKILL"
assert_literal 'task ready boundary' 'Task does not need to reach `Ready` before a Delivery Workflow starts, but delivery work still must not modify code before that workflow confirms its own scope.' "$SKILL"
assert_literal 'bug ready boundary' 'Bug may enter `bug-fix` without a `Ready` precondition and without a confirmed root cause.' "$SKILL"

assert_literal 'version starts at one' 'Every Story, Task, and Bug card must use an independent integer Version starting at `1`.' "$SKILL"
assert_match "substantive version increments" 'Increment the Version when confirmed changes alter the card'\''s goal, scope, expected behavior, acceptance or completion conditions, key dependencies, or requirement decisions' "$SKILL"
assert_match "non substantive no increment" 'Do not increment the Version for spelling-only, formatting-only, link-only, execution-status-only, or size-only changes' "$SKILL"
assert_literal "change log schema" "Version | Recorded At | Recorded By | Change | Reason" "$SKILL"
assert_literal "identity timestamp parity" "Identity and timestamp rules must match the repository's other Asset Workflows." "$SKILL"
assert_match "version conflict stop" 'check the current Version and visible facts.*stop.*conflict|stop.*conflict.*current Version and visible facts' "$SKILL"

assert_match "proposal before confirmation" 'keep proposal work in the conversation before confirmation' "$SKILL"
assert_match "authoritative unchanged before confirmation" 'Before confirmation, keep the complete proposal in the conversation and leave authoritative assets unchanged' "$SKILL"
assert_match "atomic write after confirmation" 'atomically write only the confirmed Story Map, milestone, card, and necessary Backlog changes after confirmation' "$SKILL"
assert_match "partial confirmation" 'The user may confirm only part of the proposal; unconfirmed parts must keep their current authoritative content' "$SKILL"

assert_literal "handoff boundary" "After planning confirmation, hand the confirmed Story, Task, or Bug to the matching downstream workflow. Do not copy Delivery Workflow evidence into planning assets." "$SKILL"
assert_match "no standalone work item analysis" '`work-item-analysis` for detailed single-item scope and readiness analysis' "$SKILL"
assert_not_match "delivery stage records" '04-code-review-report\.md|01-requirements\.md|02-technical-solution\.md|03-implementation-plan\.md|Business Acceptance' "$SKILL"
assert_not_match "delivery build records" 'build/dev-cadence/(feature-dev|bug-fix|refactor)/' "$SKILL"
assert_not_match "personal absolute paths" '/Users/|/private/tmp|/private/var|[A-Za-z]:\\Users\\' "$SKILL"

assert_literal "entry route" '.dev-cadence/skills/work-item-planning/SKILL.md' "$ENTRY_SKILL"
assert_match "entry planning route row" 'Plan a portfolio from confirmed User Journey, PRD, and Business Architecture assets, maintain a Story Map, or register a single clear Story, Task, or Bug work item' "$ENTRY_SKILL"
assert_match "entry direct intake route" 'Direct Work Item Intake' "$ENTRY_SKILL"
assert_match "entry discovery boundary" 'only references confirmed Features and must not define or reinterpret them' "$ENTRY_SKILL"
assert_match "entry delivery handoff boundary" 'prepares and hands off work items; it does not replace delivery workflows'\'' implementation, diagnosis, or refactor records' "$ENTRY_SKILL"

printf 'Work item planning contract checks passed.\n'
