#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
REPO_DIR="$(mktemp -d "${TMP_ROOT}/dev-cadence-repo-contract.XXXXXX")"
INIT_JSON="${REPO_DIR}/init.json"
INSPECT_JSON="${REPO_DIR}/inspect.json"
REPAIR_JSON="${REPO_DIR}/repair.json"
trap 'rm -rf "${REPO_DIR}"' EXIT

node "${ROOT_DIR}/scripts/sync-repo-contract.mjs" init --repo-dir "${REPO_DIR}" --json > "${INIT_JSON}"

test -f "${REPO_DIR}/AGENTS.md"
test -f "${REPO_DIR}/.gitignore"
test -f "${REPO_DIR}/.dev-cadence.yaml"
test -d "${REPO_DIR}/specs"
test -d "${REPO_DIR}/specs/records"
test -f "${REPO_DIR}/specs/records/.gitkeep"
test ! -e "${REPO_DIR}/.ai"
grep -q "dev-cadence" "${REPO_DIR}/AGENTS.md"
grep -q ".dev-cadence/skills/using-dev-cadence/SKILL.md" "${REPO_DIR}/AGENTS.md"
grep -q "Do not rely on global plugin or Skill auto-discovery" "${REPO_DIR}/AGENTS.md"
grep -qx ".dev-cadence.yaml" "${REPO_DIR}/.gitignore"

node "${ROOT_DIR}/scripts/sync-repo-contract.mjs" inspect --repo-dir "${REPO_DIR}" --json > "${INSPECT_JSON}"

rm "${REPO_DIR}/.dev-cadence.yaml"
node "${ROOT_DIR}/scripts/sync-repo-contract.mjs" repair --repo-dir "${REPO_DIR}" --json > "${REPAIR_JSON}"
test -f "${REPO_DIR}/.dev-cadence.yaml"
test ! -e "${REPO_DIR}/.ai"

node --input-type=module - "${INIT_JSON}" "${INSPECT_JSON}" "${REPAIR_JSON}" <<'NODE'
import fs from 'node:fs';

const [initPath, inspectPath, repairPath] = process.argv.slice(2);
const init = JSON.parse(fs.readFileSync(initPath, 'utf8'));
const inspect = JSON.parse(fs.readFileSync(inspectPath, 'utf8'));
const repair = JSON.parse(fs.readFileSync(repairPath, 'utf8'));

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(init.initialized === true, 'init report must be initialized');
assert(init.files_added.includes('AGENTS.md'), 'init must add AGENTS.md');
assert(init.files_added.includes('.gitignore'), 'init must add .gitignore');
assert(init.files_added.includes('.dev-cadence.yaml'), 'init must add .dev-cadence.yaml');
assert(init.files_added.includes('specs/records/.gitkeep'), 'init must add specs/records/.gitkeep');
assert(!init.files_added.some((file) => file.startsWith('.ai/')), 'init must not add .ai files');

assert(inspect.initialized === true, 'inspect report must see initialized repo');
assert(repair.initialized === true, 'repair report must be initialized');
assert(repair.files_added.includes('.dev-cadence.yaml'), 'repair must restore .dev-cadence.yaml');

console.log('repo contract ok');
NODE
