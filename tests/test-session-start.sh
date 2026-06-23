#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$(mktemp /private/tmp/dev-cadence-session-start.XXXXXX.json)"
trap 'rm -f "${OUTPUT_FILE}"' EXIT

"${ROOT_DIR}/hooks/session-start-codex" > "${OUTPUT_FILE}"

node --input-type=module - "${OUTPUT_FILE}" <<'NODE'
import fs from 'node:fs';

const outputPath = process.argv[2];
const payload = JSON.parse(fs.readFileSync(outputPath, 'utf8'));
const context = payload.hookSpecificOutput?.additionalContext ?? '';

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(payload.hookSpecificOutput?.hookEventName === 'SessionStart', 'hook event must be SessionStart');
assert(context.includes('You have dev-cadence'), 'bootstrap must identify dev-cadence');
assert(context.includes('using-dev-cadence'), 'bootstrap must inject using-dev-cadence');
assert(context.includes('cadence-sync'), 'bootstrap must route repository contract work');
assert(context.includes('cadence-clarify'), 'bootstrap must route clarification work');
assert(context.includes('cadence-tdd'), 'bootstrap must route TDD work');
assert(context.includes('cadence-verify'), 'bootstrap must route verification work');
assert(context.includes('Quality Gates'), 'bootstrap must mention Quality Gates');
assert(context.includes('Human Gates'), 'bootstrap must mention Human Gates');
assert(!context.includes('dev-cadence-authoring'), 'bootstrap must not expose authoring as a user skill');

console.log('session-start hook ok');
NODE
