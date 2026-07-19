#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/src/skills/work-item-planning/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"
BACKLOG="$ROOT_DIR/docs/backlog.md"
WORKFLOW_DOC="$ROOT_DIR/docs/workflows/work-item-planning.md"
FEATURE_SKILL="$ROOT_DIR/src/skills/feature-dev/SKILL.md"
BUG_FIX_SKILL="$ROOT_DIR/src/skills/bug-fix/SKILL.md"
REFACTOR_SKILL="$ROOT_DIR/src/skills/refactor/SKILL.md"

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

assert_literal \
  "target repository output language config" \
  'Before producing workflow guidance, in-conversation proposals, user-facing planning summaries, or planning assets, read `.dev-cadence.yaml` from the target repository root.' \
  "$SKILL"
assert_literal "english output language" '- `output_language: en` uses English.' "$SKILL"
assert_literal "simplified chinese output language" '- `output_language: zh-CN` uses Simplified Chinese.' "$SKILL"
assert_literal "output language fallback" '- If the file or value is missing or unsupported, use English.' "$SKILL"
assert_literal "selected output language surfaces" 'Use the selected language for workflow guidance, in-conversation proposals, user-facing planning summaries, and durable planning assets.' "$SKILL"
assert_not_match "fixed zh-CN output language" 'must write.*`zh-CN`|Do not fall back to `en`' "$SKILL"

assert_match "input precedence conversation" '1\..*current conversation.*explicit user confirmations' "$SKILL"
assert_match "input precedence product assets" '2\..*User Journey, PRD, and Business Architecture assets' "$SKILL"
assert_match "input precedence planning assets" '3\..*Story Map, Backlog, and existing Story / Task / Bug cards' "$SKILL"
assert_literal "authoritative story map path" "docs/product-planning/story-map.md" "$SKILL"
assert_literal "authoritative backlog path" "docs/backlog.md" "$SKILL"
assert_literal "backlog ownership" 'Work Item Planning is the authoritative owner of Backlog structure, lifecycle sections, and planning-maintained ordering.' "$SKILL"
assert_literal "backlog lifecycle sections" 'Use exactly these Backlog lifecycle sections in this order: `进行中`, `待处理`, `已完成`, `已关闭`.' "$SKILL"
assert_literal "backlog five columns" 'Each Backlog lifecycle section must use exactly these columns: `ID | Title | Version | Status | Priority`.' "$SKILL"
assert_literal "backlog pending order preservation" 'Preserve the existing row order inside `待处理` unless the confirmed planning change explicitly updates that recommendation.' "$SKILL"
assert_literal "backlog no duplicate card detail" 'Backlog rows must summarize cards only. Do not duplicate card body details, acceptance conditions, change logs, workflow-run evidence, or other card-only fields in the Backlog table.' "$SKILL"
assert_literal "backlog pending order authority" 'The row order in `待处理` is the sole authoritative suggested implementation order.' "$SKILL"
assert_literal "ordering version identity" '`Ordering Version` is the identity of the latest user-confirmed ordering decision, not a global Backlog version.' "$SKILL"
assert_match "proposal binds version and pending facts" 'proposal.*`Ordering Version`.*`待处理`.*ID.*order' "$SKILL"
assert_match "write revalidates both identities" 're-read.*`Ordering Version`.*`待处理`.*stop.*conflict|stop.*conflict.*re-read' "$SKILL"
assert_match "atomic ordering unit" 'three-part atomic ordering unit.*`待处理`.*`Ordering Version`.*`Ordering Change Log`' "$SKILL"
assert_match "reordering trigger" 'reorder.*existing.*`待处理`|existing.*`待处理`.*reorder' "$SKILL"
assert_match "new item insertion trigger" 'new.*work item.*explicit.*`待处理`.*position|explicit.*`待处理`.*position.*new.*work item' "$SKILL"
assert_match "ordering exception trigger" 'add.*modify.*cancel.*ordering exception|ordering exception.*add.*modify.*cancel' "$SKILL"
assert_match "lifecycle synchronization no trigger" 'lifecycle synchronization.*must not.*increment.*`Ordering Version`|must not.*increment.*`Ordering Version`.*lifecycle synchronization' "$SKILL"
assert_match "completion removal no trigger" 'completed.*move.*must not.*increment.*`Ordering Version`|must not.*increment.*`Ordering Version`.*completed.*move' "$SKILL"
assert_match "mechanical synchronization no trigger" 'mechanical.*synchronization.*must not.*increment.*`Ordering Version`|must not.*increment.*`Ordering Version`.*mechanical.*synchronization' "$SKILL"
assert_match "derived refresh no trigger" 'derived.*planning.*refresh.*must not.*increment.*`Ordering Version`|must not.*increment.*`Ordering Version`.*derived.*planning.*refresh' "$SKILL"
assert_match "format and link no trigger" 'formatting-only.*link-only.*must not.*increment.*`Ordering Version`|must not.*increment.*`Ordering Version`.*formatting-only.*link-only' "$SKILL"
assert_match "ordering history content" '`Ordering Change Log`.*affected.*ID.*relative position.*user.*reason|affected.*ID.*relative position.*user.*reason.*`Ordering Change Log`' "$SKILL"
assert_match "no-change no history" 'no.*ordering.*change.*(do not|must not).*increment.*append|(do not|must not).*increment.*append.*no.*ordering.*change' "$SKILL"
assert_match "partial confirmation remains atomic" 'partial.*confirmation.*must not.*three.*atomic|three.*atomic.*partial.*confirmation.*must not' "$SKILL"
assert_not_match "removed parallel table section" '^## 当前可并行实施表$|^\| 并行组 \|' "$BACKLOG"
assert_not_match "removed parallel view contract" 'Parallel Work View Contract|当前可并行实施表|parallel work table' "$SKILL"
assert_not_match "removed entry parallel view" 'parallel work view|当前可并行实施表|derived parallel view' "$ENTRY_SKILL"
assert_not_match "removed workflow parallel view" '当前可并行实施表|并行表的' "$WORKFLOW_DOC"
assert_not_match "removed feature parallel projection" 'parallel-view projection|current parallel table' "$FEATURE_SKILL"
assert_not_match "removed bug-fix parallel projection" 'parallel-view projection|current parallel table|parallel-table removal' "$BUG_FIX_SKILL"
assert_not_match "removed refactor parallel projection" 'parallel-view projection|current parallel table' "$REFACTOR_SKILL"
assert_match "authoritative story card path" 'docs/stories/S-nnn-<slug>\.md' "$SKILL"
assert_match "authoritative task card path" 'docs/tasks/T-nnn-<slug>\.md' "$SKILL"
assert_match "authoritative bug card path" 'docs/bugs/B-nnn-<slug>\.md' "$SKILL"
assert_literal "docs-only durable planning assets" 'Work Item Planning may persist only authoritative planning assets under `docs/`.' "$SKILL"
assert_literal "no rule package mutation" 'It must not create or update rule documents or modify the installed `.dev-cadence/` package.' "$SKILL"
assert_not_match "rule document durable asset" 'rule document updates' "$SKILL"
assert_literal "feature ownership boundary" "Discovery is the sole owner of confirmed User Journey, PRD, Business Architecture, and Feature identities and conclusions." "$SKILL"
assert_match "cannot create feature cards" 'create Feature cards;' "$SKILL"
assert_match "must not change feature identity" 'change a Feature ID, Type, Title, business identity, or Journey order' "$SKILL"

assert_literal "story map path" "docs/product-planning/story-map.md" "$SKILL"
assert_literal "single logical story map" "Maintain one logical global Story Map. Do not create multiple competing Story Maps unless the user explicitly changes the repository contract." "$SKILL"
assert_match "offline and system backbone" 'reference all confirmed `Offline` and `System` Features' "$SKILL"
assert_match "offline context only" 'keep `Offline` Features as business context only' "$SKILL"
assert_match "system items only" 'allow Stories and only necessary Tasks under `System` Features' "$SKILL"
assert_literal "allowed happy path" '- `Happy Path`' "$SKILL"
assert_literal "allowed alternative path" '- `Alternative Path`' "$SKILL"
assert_literal "allowed sad path" '- `Sad Path`' "$SKILL"
assert_match "story map proposal happy path" 'Work Item Planning may use `Happy Path`' "$SKILL"
assert_match "story map proposal alternative path" 'Work Item Planning may use `Happy Path`, `Alternative Path`' "$SKILL"
assert_match "story map proposal sad path" 'Work Item Planning may use `Happy Path`, `Alternative Path`, and `Sad Path`' "$SKILL"
assert_match "bugs stay out of story map" 'Bug cards do not enter the Story Map' "$SKILL"
assert_literal "story map not execution-status board" "do not treat Story Map as an execution-status board or a workflow-run log" "$SKILL"

assert_match "milestone ids" 'Milestones must use stable `M-nnn` IDs' "$SKILL"
assert_literal "milestone schema" "ID | Title | Goal | Included Work Items | Derived From" "$SKILL"
assert_literal 'MVP rule' '`MVP` is the first user-confirmed milestone. It is not an automatically computed result.' "$SKILL"
assert_match "milestone explicit work items" '`Included Work Items` must list explicit Story or Task IDs' "$SKILL"

assert_match "story id pattern" 'Story: `S-nnn`' "$SKILL"
assert_match "task id pattern" 'Task: `T-nnn`' "$SKILL"
assert_match "bug id pattern" 'Bug: `B-nnn`' "$SKILL"
assert_block "minimum card fields" $'ID\nVersion\nStatus\nTitle\nGoal or business result\nProduct or work-item references\nRelationships\nChange Log' "$SKILL"
assert_literal 'relationships required' '`Relationships` is required. Dependencies, blockers, replacements, related items, and similar planning relationships must be recorded explicitly instead of being implied only by Story Map position or narrative text.' "$SKILL"
assert_literal "shared card ownership" 'Work-item cards are shared assets across workflows; the workflow that creates a card does not exclusively own it.' "$SKILL"
assert_literal "planning-owned card updates" 'Work Item Planning may update planning relationships, Story Map placement, Milestone membership, Size, and Backlog references.' "$SKILL"
assert_literal "analysis-owned card updates" 'Work Item Analysis may update detailed definitions such as the goal, scope, expected behavior, and acceptance conditions.' "$SKILL"
assert_literal "delivery-owned card updates" 'Delivery Workflows may update diagnosis, delivery status, results, verification, and delivery references.' "$SKILL"
assert_literal "discovery traceability boundary" 'Discovery may update traceability relationships only when the user explicitly asks to coordinate product design and work items.' "$SKILL"
assert_literal "shared card conflict stop" 'When any workflow finds a Version or visible-fact conflict, it must stop and require a user decision before continuing.' "$SKILL"
assert_literal "no downstream workflow implementation" 'These shared ownership boundaries do not implement S-017 cross-workflow writeback or the S-037 Work Item Analysis workflow.' "$SKILL"

for status in '`Draft`' '`Ready`' '`In Progress`' '`Blocked`' '`Done`' '`Superseded`' '`Dropped`'; do
  assert_match "canonical status $status" "$status" "$SKILL"
done
assert_literal 'story ready gate' 'Story must reach `Ready` before entering `feature-dev`.' "$SKILL"
assert_literal 'task ready boundary' 'Task does not need to reach `Ready` before a Delivery Workflow starts, but delivery work still must not modify code before that workflow confirms its own scope.' "$SKILL"
assert_literal 'bug ready boundary' 'Bug may enter `bug-fix` without a `Ready` precondition and without a confirmed root cause.' "$SKILL"

assert_literal 'version starts at one' 'Every Story, Task, and Bug card must use an independent integer Version starting at `1`.' "$SKILL"
assert_match "substantive version increments" 'Increment the Version when confirmed changes alter the card'\''s goal, scope, expected behavior, acceptance or completion conditions, key dependencies, or requirement decisions' "$SKILL"
assert_match "non substantive no increment" 'Do not increment the Version for spelling-only, formatting-only, link-only, execution-status-only, or size-only changes' "$SKILL"
assert_literal "shared Change Log contract read" '.dev-cadence/skills/contracts/change-log.md' "$SKILL"
assert_literal "card Change Log follows shared contract" 'For every card Change Log, follow the shared Change Log contract.' "$SKILL"
assert_match "version conflict stop" 'check the current Version and visible facts.*stop.*conflict|stop.*conflict.*current Version and visible facts' "$SKILL"

assert_match "proposal before confirmation" 'keep proposal work in the conversation before confirmation' "$SKILL"
assert_match "authoritative unchanged before confirmation" 'Before confirmation, keep the complete proposal in the conversation and leave authoritative assets unchanged' "$SKILL"
assert_match "atomic write after confirmation" 'atomically write only the confirmed Story Map, milestone, card, and necessary Backlog changes after confirmation' "$SKILL"
assert_match "partial confirmation" 'The user may confirm only part of the proposal; unconfirmed parts must keep their current authoritative content' "$SKILL"

assert_literal "handoff boundary" "After planning confirmation, hand the confirmed Story, Task, or Bug to the matching downstream workflow. Do not copy Delivery Workflow evidence into planning assets." "$SKILL"
assert_match "no standalone detailed analysis replacement" 'does not replace:|It does not replace:' "$SKILL"
assert_match "detailed single-item scope boundary" 'detailed single-item scope and readiness analysis' "$SKILL"
assert_not_match "delivery stage records" '04-code-review-report\.md|01-requirements\.md|02-technical-solution\.md|03-implementation-plan\.md|Business Acceptance' "$SKILL"
assert_not_match "delivery build records" 'build/dev-cadence/(feature-dev|bug-fix|refactor)/' "$SKILL"
assert_not_match "personal absolute paths" '/Users/|/private/tmp|/private/var|[A-Za-z]:\\Users\\' "$SKILL"

assert_literal "entry route" '.dev-cadence/skills/work-item-planning/SKILL.md' "$ENTRY_SKILL"
assert_match "entry planning route row" 'Plan a portfolio from confirmed User Journey, PRD, and Business Architecture assets, maintain a Story Map, or register a single clear Story, Task, or Bug work item' "$ENTRY_SKILL"
assert_match "entry direct intake route" 'Direct Work Item Intake' "$ENTRY_SKILL"
assert_match "entry discovery boundary" 'only references confirmed Features and must not define or reinterpret them' "$ENTRY_SKILL"
assert_match "entry delivery handoff boundary" 'prepares and hands off work items; it does not replace delivery workflows'\'' implementation, diagnosis, or refactor records' "$ENTRY_SKILL"

printf 'Work item planning contract checks passed.\n'
