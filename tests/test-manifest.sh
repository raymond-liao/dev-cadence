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
assert(manifest.hooks === './hooks/hooks-codex.json', 'manifest hooks path must be ./hooks/hooks-codex.json');

const skillsDir = path.join(root, manifest.skills);
const hooksPath = path.join(root, manifest.hooks);
assert(fs.statSync(skillsDir).isDirectory(), 'manifest skills directory must exist');
assert(fs.statSync(hooksPath).isFile(), 'manifest hooks file must exist');

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

const hooks = JSON.parse(fs.readFileSync(hooksPath, 'utf8'));
const sessionHooks = hooks.hooks?.SessionStart ?? [];
assert(sessionHooks.length > 0, 'SessionStart hooks must be configured');
assert(
  sessionHooks.some((entry) =>
    entry.hooks?.some((hook) => hook.command?.includes('session-start-codex'))
  ),
  'SessionStart must invoke session-start-codex'
);

console.log('manifest contract ok');
NODE

test -f "${MANIFEST}"
