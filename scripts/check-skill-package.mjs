#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

function printHelp() {
  console.log(`Usage: check-skill-package.mjs [plugin-dir]

Validates the current Codex Plugin publishing shape for dev-cadence and basic runtime hygiene.

Arguments:
  plugin-dir  dev-cadence source directory to check. Defaults to the parent directory
              of this script.

Checks:
  - Codex plugin manifest and entrypoint SKILL.md frontmatter
  - English-only shipped plugin content
  - absence of legacy external naming
  - absence of runtime auxiliary docs such as README.md
  - JavaScript syntax and shell executable bits under scripts/
  - CLI help for package scripts
  - artifact template fenced yaml blocks have no duplicate keys
  - agents/openai.yaml metadata fields when present`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

const pluginDir = path.resolve(process.argv[2] || path.join(import.meta.dirname, '..'));
const errors = [];
const warnings = [];

function fail(message) {
  errors.push(message);
}

function warn(message) {
  warnings.push(message);
}

function readText(filePath) {
  return fs.readFileSync(filePath, 'utf8');
}

function walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...walk(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }
  return files;
}

function rel(filePath) {
  return path.relative(pluginDir, filePath);
}

function parseSimpleYamlFrontmatter(text, filePath) {
  const match = text.match(/^---\n([\s\S]*?)\n---\n/);
  if (!match) {
    fail(`${rel(filePath)}: missing YAML frontmatter`);
    return null;
  }

  const result = {};
  for (const line of match[1].split('\n')) {
    if (!line.trim()) continue;
    const field = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!field) {
      fail(`${rel(filePath)}: unsupported frontmatter line: ${line}`);
      continue;
    }
    const key = field[1];
    let value = field[2].trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    result[key] = value;
  }
  return result;
}

function checkFrontmatter() {
  const expected = [
    { relativePath: 'skills/dev-cadence-init/SKILL.md', name: 'dev-cadence-init' },
    { relativePath: 'skills/dev-cadence-deliver/SKILL.md', name: 'dev-cadence-deliver' },
    { relativePath: 'skills/dev-cadence-maintain/SKILL.md', name: 'dev-cadence-maintain' },
    { relativePath: 'skills/dev-cadence-authoring/SKILL.md', name: 'dev-cadence-authoring' },
  ];

  for (const item of expected) {
    const skillPath = path.join(pluginDir, item.relativePath);
    if (!fs.existsSync(skillPath)) {
      fail(`${item.relativePath}: missing required file`);
      continue;
    }

    const frontmatter = parseSimpleYamlFrontmatter(readText(skillPath), skillPath);
    if (!frontmatter) continue;

    const allowedKeys = new Set(['name', 'description']);
    for (const key of Object.keys(frontmatter)) {
      if (!allowedKeys.has(key)) {
        fail(`${item.relativePath}: unexpected frontmatter key '${key}'`);
      }
    }

    if (frontmatter.name !== item.name) {
      fail(`${item.relativePath}: expected name '${item.name}', got '${frontmatter.name || ''}'`);
    }

    if (!frontmatter.description) {
      fail(`${item.relativePath}: missing description`);
    } else if (frontmatter.description.length > 1024) {
      fail(`${item.relativePath}: description too long (${frontmatter.description.length} characters)`);
    }

    if (frontmatter.name && !/^[a-z0-9-]+$/.test(frontmatter.name)) {
      fail(`${item.relativePath}: name must use lowercase letters, digits, and hyphens only`);
    }
  }
}

function checkPluginManifest() {
  const manifestPath = path.join(pluginDir, '.codex-plugin', 'plugin.json');
  if (!fs.existsSync(manifestPath)) {
    fail('.codex-plugin/plugin.json: missing required Codex plugin manifest');
    return;
  }

  let manifest;
  try {
    manifest = JSON.parse(readText(manifestPath));
  } catch (error) {
    fail(`.codex-plugin/plugin.json: invalid JSON: ${error.message}`);
    return;
  }

  const required = [
    'name',
    'version',
    'description',
    'author',
    'skills',
    'interface',
  ];
  for (const key of required) {
    if (manifest[key] === undefined) {
      fail(`.codex-plugin/plugin.json: missing ${key}`);
    }
  }
  if (manifest.name !== 'dev-cadence') {
    fail(`.codex-plugin/plugin.json: expected name 'dev-cadence', got '${manifest.name || ''}'`);
  }
  if (manifest.skills !== './skills/') {
    fail(`.codex-plugin/plugin.json: expected skills './skills/', got '${manifest.skills || ''}'`);
  }
  if (manifest.hooks !== './hooks/hooks-codex.json') {
    fail(`.codex-plugin/plugin.json: expected hooks './hooks/hooks-codex.json', got '${manifest.hooks || ''}'`);
  }
}

function shippedFiles() {
  const roots = [
    '.codex-plugin',
    'hooks',
    'skills',
    'references',
    'templates',
    'scripts',
  ];
  const files = [];
  for (const root of roots) {
    const rootPath = path.join(pluginDir, root);
    if (fs.existsSync(rootPath)) {
      files.push(...walk(rootPath));
    }
  }
  return files;
}

function checkLanguageBoundary(files) {
  const chinese = /[\u3400-\u9fff]/;
  for (const filePath of files) {
    if (/\.(png|jpg|jpeg|gif|svg)$/i.test(filePath)) continue;
    const text = readText(filePath);
    if (chinese.test(text)) {
      fail(`${rel(filePath)}: shipped plugin content must be English; found Chinese characters`);
    }
  }
}

function checkForbiddenLegacyNames(files) {
  const wordPattern = (parts) => new RegExp(`\\b${parts.join('')}\\b`, 'i');
  const dottedPattern = (parts) => new RegExp(`\\.${parts.join('')}\\b`, 'i');
  const forbidden = [
    { pattern: wordPattern(['super', 'powers']), label: 'external workflow package name' },
    { pattern: dottedPattern(['super', 'powers']), label: 'external workflow state directory' },
    { pattern: wordPattern(['clau', 'de']), label: 'external assistant name' },
    { pattern: wordPattern(['brain', 'storming']), label: 'external workflow skill name' },
  ];

  for (const filePath of files) {
    if (/\.(png|jpg|jpeg|gif|svg)$/i.test(filePath)) continue;
    const text = readText(filePath);
    for (const item of forbidden) {
      if (item.pattern.test(text)) {
        fail(`${rel(filePath)}: contains legacy external naming '${item.label}'`);
      }
    }
  }
}

function checkNoAuxiliaryDocs(files) {
  const forbiddenBasenames = new Set([
    'README.md',
    'CHANGELOG.md',
    'INSTALLATION_GUIDE.md',
    'QUICK_REFERENCE.md',
  ]);
  for (const filePath of files) {
    if (forbiddenBasenames.has(path.basename(filePath))) {
      fail(`${rel(filePath)}: runtime plugin content should not include auxiliary docs`);
    }
  }
}

function checkScripts() {
  const scriptsDir = path.join(pluginDir, 'scripts');
  if (!fs.existsSync(scriptsDir)) return;

  for (const filePath of walk(scriptsDir)) {
    if (filePath.endsWith('.cjs') || filePath.endsWith('.mjs') || filePath.endsWith('.js')) {
      const result = spawnSync(process.execPath, ['-c', filePath], { encoding: 'utf8' });
      if (result.status !== 0) {
        fail(`${rel(filePath)}: node syntax check failed\n${result.stderr || result.stdout}`);
      }
    }
    if (filePath.endsWith('.sh')) {
      const mode = fs.statSync(filePath).mode;
      if ((mode & 0o111) === 0) {
        fail(`${rel(filePath)}: shell script is not executable`);
      }
    }
  }
}

function checkCliHelp() {
  const commands = [
    {
      script: 'scripts/check-skill-package.mjs',
      requiredText: [
        'Usage: check-skill-package.mjs [plugin-dir]',
        'dev-cadence source directory',
        'SKILL.md frontmatter',
      ],
    },
    {
      script: 'scripts/check-discipline-routes.mjs',
      requiredText: [
        'Usage: check-discipline-routes.mjs [plugin-dir]',
        'dev-cadence source directory',
        'discipline routing',
      ],
    },
    {
      script: 'scripts/check-spec-artifacts.mjs',
      requiredText: [
        'Usage: check-spec-artifacts.mjs [specs-dir]',
        'fenced yaml blocks',
        'duplicate keys',
      ],
    },
    {
      script: 'scripts/init-task-artifacts.mjs',
      requiredText: [
        'Usage: init-task-artifacts.mjs --task-id <task-id> [options]',
        'Initializes Dev Cadence task artifacts',
        '--run-id <id>',
      ],
    },
    {
      script: 'scripts/sync-repo-contract.mjs',
      requiredText: [
        'Usage: sync-repo-contract.mjs <mode> [options]',
        'Initializes, inspects, or repairs',
        'inspect',
      ],
    },
    {
      script: 'scripts/run-delivery-dry-run.mjs',
      requiredText: [
        'Usage: run-delivery-dry-run.mjs --task-id <task-id> --goal <goal> [options]',
        'Creates a minimal Dev Cadence delivery dry run',
        '--accepted-by <name>',
      ],
    },
    {
      script: 'scripts/summarize-acceptance.mjs',
      requiredText: [
        'Usage: summarize-acceptance.mjs --task-id <task-id> [options]',
        'Human-facing acceptance summary',
        'does not accept work',
      ],
    },
  ];

  for (const command of commands) {
    const scriptPath = path.join(pluginDir, command.script);
    if (!fs.existsSync(scriptPath)) {
      fail(`${command.script}: missing script for help validation`);
      continue;
    }

    for (const flag of ['--help', '-h']) {
      const result = spawnSync(process.execPath, [scriptPath, flag], { encoding: 'utf8' });
      if (result.status !== 0) {
        fail(`${command.script} ${flag}: expected exit 0, got ${result.status}`);
        continue;
      }
      for (const expected of command.requiredText) {
        if (!result.stdout.includes(expected)) {
          fail(`${command.script} ${flag}: help output missing '${expected}'`);
        }
      }
    }
  }
}

function checkArtifactTemplateBlocks() {
  const scriptPath = path.join(pluginDir, 'scripts', 'check-spec-artifacts.mjs');
  const templatesDir = path.join(pluginDir, 'templates');
  if (!fs.existsSync(scriptPath)) {
    fail('scripts/check-spec-artifacts.mjs: missing script for template artifact validation');
    return;
  }
  if (!fs.existsSync(templatesDir)) {
    fail('templates/: missing required template directory');
    return;
  }

  const result = spawnSync(process.execPath, [scriptPath, templatesDir], { encoding: 'utf8' });
  if (result.status !== 0) {
    fail(`templates/: artifact template validation failed\n${result.stderr || result.stdout}`);
  }
}

function checkOpenAiYaml() {
  const expected = [
    'skills/dev-cadence-init/agents/openai.yaml',
    'skills/dev-cadence-deliver/agents/openai.yaml',
    'skills/dev-cadence-maintain/agents/openai.yaml',
    'skills/dev-cadence-authoring/agents/openai.yaml',
  ];

  for (const relativePath of expected) {
    const openAiYaml = path.join(pluginDir, relativePath);
    if (!fs.existsSync(openAiYaml)) {
      warn(`${relativePath}: missing optional UI metadata`);
      continue;
    }
    const text = readText(openAiYaml);
    for (const required of ['display_name:', 'short_description:', 'default_prompt:']) {
      if (!text.includes(required)) {
        fail(`${relativePath}: missing ${required}`);
      }
    }
  }
}

if (!fs.existsSync(pluginDir)) {
  console.error(`Plugin directory not found: ${pluginDir}`);
  process.exit(2);
}

const files = shippedFiles();
checkPluginManifest();
checkFrontmatter();
checkLanguageBoundary(files);
checkForbiddenLegacyNames(files);
checkNoAuxiliaryDocs(files);
checkScripts();
checkCliHelp();
checkArtifactTemplateBlocks();
checkOpenAiYaml();

for (const message of warnings) {
  console.warn(`WARN ${message}`);
}

if (errors.length > 0) {
  for (const message of errors) {
    console.error(`FAIL ${message}`);
  }
  console.error(`\n${errors.length} failure(s)`);
  process.exit(1);
}

console.log(`OK checked ${files.length} plugin files in ${path.relative(process.cwd(), pluginDir) || pluginDir}`);
