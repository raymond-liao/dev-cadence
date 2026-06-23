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
assert(context.includes('`dev-cadence` available'), 'bootstrap must identify dev-cadence');
assert(context.includes('dev-cadence-init'), 'bootstrap must list init skill');
assert(context.includes('dev-cadence-deliver'), 'bootstrap must list deliver skill');
assert(context.includes('dev-cadence-maintain'), 'bootstrap must list maintain skill');
assert(context.includes('dev-cadence-authoring'), 'bootstrap must list authoring skill');
assert(context.includes('AGENTS.md, .gitignore, specs/'), 'bootstrap must describe thin repo contract');
assert(context.includes('Do not create a .ai/ directory'), 'bootstrap must prohibit default .ai creation');

console.log('session-start hook ok');
NODE
