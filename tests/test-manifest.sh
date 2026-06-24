#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT_DIR}/.codex-plugin/plugin.json"

node --input-type=module - "${ROOT_DIR}" <<'NODE'
import fs from 'node:fs';
import path from 'node:path';

const root = process.argv[2];
const manifestPath = path.join(root, '.codex-plugin', 'plugin.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(manifest.name === 'dev-cadence', 'manifest name must be dev-cadence');
assert(manifest.skills === './skills/', 'manifest skills path must be ./skills/');
assert(manifest.hooks === undefined, 'manifest must not register hooks by default');

const skillsDir = path.join(root, manifest.skills);
assert(fs.statSync(skillsDir).isDirectory(), 'manifest skills directory must exist');

const requiredSkills = [
  'using-dev-cadence',
  'cadence-clarify',
  'cadence-plan',
  'cadence-execute',
  'cadence-tdd',
  'cadence-debug',
  'cadence-review',
  'cadence-verify',
  'cadence-sync',
];

for (const skill of requiredSkills) {
  const skillPath = path.join(skillsDir, skill, 'SKILL.md');
  assert(fs.statSync(skillPath).isFile(), `missing SKILL.md for ${skill}`);
}

console.log('manifest contract ok');
NODE

test -f "${MANIFEST}"
