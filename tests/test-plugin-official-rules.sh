#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
FIXTURE_DIR="$(mktemp -d "${TMP_ROOT}/dev-cadence-plugin-rules.XXXXXX")"
trap 'rm -rf "${FIXTURE_DIR}"' EXIT

PLUGIN_DIR="${FIXTURE_DIR}/plugins/dev-cadence"
mkdir -p "${PLUGIN_DIR}"
cp -R "${ROOT_DIR}/.codex-plugin" "${PLUGIN_DIR}/.codex-plugin"
cp -R "${ROOT_DIR}/skills" "${PLUGIN_DIR}/skills"
cp -R "${ROOT_DIR}/references" "${PLUGIN_DIR}/references"
cp -R "${ROOT_DIR}/templates" "${PLUGIN_DIR}/templates"
cp -R "${ROOT_DIR}/scripts" "${PLUGIN_DIR}/scripts"

mkdir -p "${FIXTURE_DIR}/.agents/plugins"
cat > "${FIXTURE_DIR}/.agents/plugins/marketplace.json" <<'JSON'
{
  "name": "dev-cadence-local",
  "interface": {
    "displayName": "Dev Cadence Local"
  },
  "plugins": [
    {
      "name": "dev-cadence",
      "source": {
        "source": "local",
        "path": "./plugins/dev-cadence"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Coding"
    }
  ]
}
JSON

node "${ROOT_DIR}/scripts/check-skill-package.mjs" "${PLUGIN_DIR}" > /dev/null

printf '{}\n' > "${PLUGIN_DIR}/.mcp.json"
printf '{}\n' > "${PLUGIN_DIR}/.app.json"
node --input-type=module - "${PLUGIN_DIR}/.codex-plugin/plugin.json" <<'NODE'
import fs from 'node:fs';

const manifestPath = process.argv[2];
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
manifest.mcpServers = './.mcp.json';
manifest.apps = './.app.json';
fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
NODE
node "${ROOT_DIR}/scripts/check-skill-package.mjs" "${PLUGIN_DIR}" > /dev/null

assert_fails_with() {
  local expected_text="$1"
  local output_file="${FIXTURE_DIR}/failure.txt"

  if node "${ROOT_DIR}/scripts/check-skill-package.mjs" "${PLUGIN_DIR}" > "${output_file}" 2>&1; then
    echo "expected check-skill-package.mjs to fail" >&2
    exit 1
  fi

  grep -Fq "${expected_text}" "${output_file}" || {
    echo "expected failure text: ${expected_text}" >&2
    cat "${output_file}" >&2
    exit 1
  }
}

node --input-type=module - "${PLUGIN_DIR}/.codex-plugin/plugin.json" <<'NODE'
import fs from 'node:fs';

const manifestPath = process.argv[2];
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
manifest.skills = 'skills/';
fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
NODE
assert_fails_with ".codex-plugin/plugin.json: expected skills './skills/'"

node --input-type=module - "${PLUGIN_DIR}/.codex-plugin/plugin.json" <<'NODE'
import fs from 'node:fs';

const manifestPath = process.argv[2];
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
manifest.skills = './skills/';
manifest.mcpServers = '../outside.json';
fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
NODE
assert_fails_with ".codex-plugin/plugin.json: mcpServers: path must stay inside ."

node --input-type=module - "${PLUGIN_DIR}/.codex-plugin/plugin.json" <<'NODE'
import fs from 'node:fs';

const manifestPath = process.argv[2];
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
delete manifest.mcpServers;
fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
NODE
mkdir -p "${PLUGIN_DIR}/hooks"
assert_fails_with "hooks/: this plugin does not ship lifecycle hooks"
rm -rf "${PLUGIN_DIR}/hooks"

node --input-type=module - "${FIXTURE_DIR}/.agents/plugins/marketplace.json" <<'NODE'
import fs from 'node:fs';

const marketplacePath = process.argv[2];
const marketplace = JSON.parse(fs.readFileSync(marketplacePath, 'utf8'));
marketplace.plugins[0].source.path = "plugins/dev-cadence";
fs.writeFileSync(marketplacePath, `${JSON.stringify(marketplace, null, 2)}\n`);
NODE
assert_fails_with "../../.agents/plugins/marketplace.json: source.path: path must start with './'"

echo "plugin official rules ok"
