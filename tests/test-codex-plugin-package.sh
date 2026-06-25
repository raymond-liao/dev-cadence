#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="$(mktemp -d /private/tmp/dev-cadence-codex-plugin.XXXXXX)"
PLUGIN_DIR="${PACKAGE_DIR}/plugins/dev-cadence"
MARKETPLACE_FILE="${PACKAGE_DIR}/.agents/plugins/marketplace.json"
SAFETY_ROOT="$(mktemp -d /private/tmp/dev-cadence-package-safety.XXXXXX)"
trap 'rm -rf "${PACKAGE_DIR}" "${SAFETY_ROOT}"' EXIT

assert_exists() {
  local relative_path="$1"
  test -e "${PLUGIN_DIR}/${relative_path}" || {
    echo "missing expected package path: ${relative_path}" >&2
    exit 1
  }
}

assert_absent() {
  local relative_path="$1"
  test ! -e "${PLUGIN_DIR}/${relative_path}" || {
    echo "unexpected package path: ${relative_path}" >&2
    exit 1
  }
}

assert_command_fails_with() {
  local expected_text="$1"
  shift
  local output_file="${SAFETY_ROOT}/command-output.txt"

  if "$@" > "${output_file}" 2>&1; then
    echo "expected command to fail: $*" >&2
    exit 1
  fi

  grep -Fq "${expected_text}" "${output_file}" || {
    echo "expected failure text: ${expected_text}" >&2
    cat "${output_file}" >&2
    exit 1
  }
}

mkdir -p "${SAFETY_ROOT}/source"

assert_command_fails_with \
  "Refusing to package into the source repository root" \
  node "${ROOT_DIR}/scripts/package-codex-plugin.mjs" \
    --source-dir "${SAFETY_ROOT}/source" \
    --output-dir "${SAFETY_ROOT}/source"

assert_command_fails_with \
  "Refusing to package inside source tree outside dist/" \
  node "${ROOT_DIR}/scripts/package-codex-plugin.mjs" \
    --source-dir "${SAFETY_ROOT}/source" \
    --output-dir "${SAFETY_ROOT}/source/package"

assert_command_fails_with \
  "Refusing to package into a directory that contains the source repository" \
  node "${ROOT_DIR}/scripts/package-codex-plugin.mjs" \
    --source-dir "${SAFETY_ROOT}/source" \
    --output-dir "${SAFETY_ROOT}"

node "${ROOT_DIR}/scripts/package-codex-plugin.mjs" --output-dir "${PACKAGE_DIR}" --clean --json > "${PACKAGE_DIR}/package-report.json"

node "${ROOT_DIR}/scripts/package-codex-plugin.mjs" --output-dir "${PACKAGE_DIR}" --json > "${PACKAGE_DIR}/package-report-no-clean.json"

test -f "${MARKETPLACE_FILE}" || {
  echo "missing expected .agents/plugins/marketplace.json" >&2
  exit 1
}

test ! -e "${PACKAGE_DIR}/marketplace.json" || {
  echo "unexpected legacy root marketplace.json" >&2
  exit 1
}

assert_exists ".codex-plugin/plugin.json"
assert_exists "skills/using-dev-cadence/SKILL.md"
assert_exists "skills/cadence-clarify/SKILL.md"
assert_exists "skills/cadence-plan/SKILL.md"
assert_exists "skills/cadence-execute/SKILL.md"
assert_exists "skills/cadence-tdd/SKILL.md"
assert_exists "skills/cadence-debug/SKILL.md"
assert_exists "skills/cadence-review/SKILL.md"
assert_exists "skills/cadence-verify/SKILL.md"
assert_exists "skills/cadence-sync/SKILL.md"
assert_absent "skills/dev-cadence-authoring"
assert_exists "references/skill-layout.md"
assert_exists "references/delivery-disciplines.md"
assert_exists "templates/spec/00-brief.md"
assert_exists "templates/runs/run-context.md"
assert_exists "templates/runs/pre-implementation-status.md"
assert_exists "templates/prompts/implementer.md"
assert_exists "scripts/sync-repo-contract.mjs"
assert_exists "scripts/package-codex-plugin.mjs"
assert_exists "scripts/run-delivery-dry-run.mjs"
assert_exists "scripts/check-gates.mjs"
assert_exists "scripts/check-before-commit.mjs"
assert_exists "scripts/visual-companion/server.cjs"

test ! -e "${PLUGIN_DIR}/assets" || {
  echo "unexpected optional assets directory in package fixture" >&2
  exit 1
}
test ! -e "${PLUGIN_DIR}/.mcp.json" || {
  echo "unexpected optional .mcp.json in package fixture" >&2
  exit 1
}
test ! -e "${PLUGIN_DIR}/.app.json" || {
  echo "unexpected optional .app.json in package fixture" >&2
  exit 1
}

assert_absent "docs"
assert_absent "hooks"
assert_absent "research"
assert_absent "specs"
assert_absent "tests"
assert_absent "AGENTS.md"
assert_absent "README.md"
assert_absent ".git"
assert_absent ".idea"
assert_absent ".gitignore"

node "${ROOT_DIR}/scripts/check-skill-package.mjs" "${PLUGIN_DIR}" > /dev/null
node "${ROOT_DIR}/scripts/check-discipline-routes.mjs" "${PLUGIN_DIR}" > /dev/null

node --input-type=module - "${PACKAGE_DIR}" "${PLUGIN_DIR}" <<'NODE'
import fs from 'node:fs';
import path from 'node:path';

const packageDir = process.argv[2];
const pluginDir = process.argv[3];
const marketplace = JSON.parse(fs.readFileSync(path.join(packageDir, '.agents/plugins/marketplace.json'), 'utf8'));
const manifest = JSON.parse(fs.readFileSync(path.join(pluginDir, '.codex-plugin/plugin.json'), 'utf8'));

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(marketplace.name === 'dev-cadence-local', 'marketplace name must be dev-cadence-local');
assert(marketplace.interface.displayName === 'Dev Cadence Local', 'marketplace display name must be set');
assert(marketplace.plugins.length === 1, 'marketplace must ship one plugin entry');
assert(marketplace.plugins[0].name === 'dev-cadence', 'marketplace plugin entry must be dev-cadence');
assert(marketplace.plugins[0].source.source === 'local', 'marketplace source must be local');
assert(marketplace.plugins[0].source.path === './plugins/dev-cadence', 'marketplace source path must point at packaged plugin');

assert(manifest.name === 'dev-cadence', 'package manifest name must be dev-cadence');
assert(manifest.skills === './skills/', 'package manifest must point at bundled skills');
assert(manifest.hooks === undefined, 'package manifest must not register hooks');
assert(manifest.mcpServers === undefined, 'package manifest must not reference missing MCP config');
assert(manifest.apps === undefined, 'package manifest must not reference missing app config');

const shippedFiles = [];
function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(fullPath);
    } else {
      shippedFiles.push(path.relative(pluginDir, fullPath));
    }
  }
}
walk(pluginDir);

assert(!shippedFiles.some((file) => file.startsWith('docs/')), 'package must exclude docs');
assert(!shippedFiles.some((file) => file.startsWith('hooks/')), 'package must exclude hooks');
assert(!shippedFiles.some((file) => file.startsWith('research/')), 'package must exclude research');
assert(!shippedFiles.some((file) => file.startsWith('specs/')), 'package must exclude historical specs');
assert(!shippedFiles.some((file) => file.startsWith('tests/')), 'package must exclude tests');
assert(!shippedFiles.includes('AGENTS.md'), 'package must exclude repo-local AGENTS.md');
assert(!shippedFiles.includes('README.md'), 'package must exclude project README');

console.log('codex package boundary ok');
NODE
