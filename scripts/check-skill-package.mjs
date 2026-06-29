#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const EXPECTED_SKILLS = [
  'using-dev-cadence',
  'cadence-clarify',
  'cadence-plan',
  'cadence-research',
  'cadence-executing-plans',
  'cadence-subagent-development',
  'cadence-dispatch-parallel',
  'cadence-tdd',
  'cadence-debug',
  'cadence-request-review',
  'cadence-review',
  'cadence-verify',
  'cadence-sync',
];

function printHelp() {
  console.log(`Usage: check-skill-package.mjs [plugin-dir]

Validates the current Codex Plugin publishing shape for dev-cadence and basic runtime hygiene.

Arguments:
  plugin-dir  dev-cadence source directory to check. Defaults to the parent directory
              of this script.

Checks:
  - Codex plugin manifest and entrypoint SKILL.md frontmatter
  - official manifest path rules and absence of plugin hooks
  - generated marketplace metadata when present
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

function walk(targetPath) {
  const stat = fs.statSync(targetPath);
  if (stat.isFile()) {
    return [targetPath];
  }
  if (!stat.isDirectory()) {
    return [];
  }

  const entries = fs.readdirSync(targetPath, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const fullPath = path.join(targetPath, entry.name);
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

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function isInside(baseDir, candidatePath) {
  const relative = path.relative(baseDir, candidatePath);
  return relative === '' || (!relative.startsWith('..') && !path.isAbsolute(relative));
}

function validateRelativePath(value, label, options = {}) {
  const {
    baseDir = pluginDir,
    mustExist = true,
    expectedKind = 'any',
    preferAssets = false,
  } = options;

  if (!isNonEmptyString(value)) {
    fail(`${label}: path must be a non-empty string`);
    return null;
  }

  if (!value.startsWith('./')) {
    fail(`${label}: path must start with './'`);
  }

  if (path.isAbsolute(value)) {
    fail(`${label}: path must be relative, not absolute`);
    return null;
  }

  const resolvedPath = path.resolve(baseDir, value);
  if (!isInside(baseDir, resolvedPath)) {
    fail(`${label}: path must stay inside ${path.relative(pluginDir, baseDir) || '.'}`);
    return null;
  }

  if (mustExist && !fs.existsSync(resolvedPath)) {
    fail(`${label}: path does not exist: ${value}`);
    return resolvedPath;
  }

  if (mustExist && expectedKind !== 'any') {
    const stat = fs.statSync(resolvedPath);
    if (expectedKind === 'directory' && !stat.isDirectory()) {
      fail(`${label}: expected a directory path`);
    }
    if (expectedKind === 'file' && !stat.isFile()) {
      fail(`${label}: expected a file path`);
    }
  }

  if (preferAssets) {
    const relativeToPlugin = path.relative(pluginDir, resolvedPath);
    if (!relativeToPlugin.startsWith(`assets${path.sep}`)) {
      warn(`${label}: visual assets should live under ./assets/ when possible`);
    }
  }

  return resolvedPath;
}

function validateUrl(value, label) {
  if (value === undefined) return;
  if (!isNonEmptyString(value)) {
    fail(`${label}: URL must be a non-empty string`);
    return;
  }
  try {
    const parsed = new URL(value);
    if (parsed.protocol !== 'http:' && parsed.protocol !== 'https:') {
      fail(`${label}: URL must use http or https`);
    }
  } catch {
    fail(`${label}: invalid URL`);
  }
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
  const expected = EXPECTED_SKILLS.map((name) => ({
    relativePath: `skills/${name}/SKILL.md`,
    name,
  }));

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
    return null;
  }

  let manifest;
  try {
    manifest = JSON.parse(readText(manifestPath));
  } catch (error) {
    fail(`.codex-plugin/plugin.json: invalid JSON: ${error.message}`);
    return null;
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
  } else if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(manifest.name)) {
    fail('.codex-plugin/plugin.json: name must be stable kebab-case');
  }
  if (!isNonEmptyString(manifest.version)) {
    fail('.codex-plugin/plugin.json: version must be a non-empty string');
  } else if (!/^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/.test(manifest.version)) {
    fail('.codex-plugin/plugin.json: version should use semver such as 0.1.0');
  }
  if (!isNonEmptyString(manifest.description)) {
    fail('.codex-plugin/plugin.json: description must be a non-empty string');
  }
  if (manifest.skills !== './skills/') {
    fail(`.codex-plugin/plugin.json: expected skills './skills/', got '${manifest.skills || ''}'`);
  } else {
    validateRelativePath(manifest.skills, '.codex-plugin/plugin.json: skills', { expectedKind: 'directory' });
  }
  if (manifest.hooks !== undefined) {
    fail('.codex-plugin/plugin.json: hooks must not be registered');
  }

  validateOptionalManifestPaths(manifest);
  validateManifestInterface(manifest);
  checkPluginRootShape();

  return manifest;
}

function validateOptionalManifestPaths(manifest) {
  const componentFields = [
    { key: 'mcpServers', expectedBasename: '.mcp.json' },
    { key: 'apps', expectedBasename: '.app.json' },
  ];

  for (const item of componentFields) {
    const value = manifest[item.key];
    if (value === undefined) continue;
    const resolvedPath = validateRelativePath(value, `.codex-plugin/plugin.json: ${item.key}`, { expectedKind: 'file' });
    if (resolvedPath && path.basename(resolvedPath) !== item.expectedBasename) {
      fail(`.codex-plugin/plugin.json: ${item.key} should point to ${item.expectedBasename}`);
    }
    if (resolvedPath && fs.existsSync(resolvedPath)) {
      validateJsonFile(resolvedPath, `.codex-plugin/plugin.json: ${item.key}`);
    }
  }
}

function validateJsonFile(filePath, label) {
  try {
    JSON.parse(readText(filePath));
  } catch (error) {
    fail(`${label}: referenced JSON file is invalid: ${error.message}`);
  }
}

function validateManifestInterface(manifest) {
  if (!isPlainObject(manifest.interface)) {
    fail('.codex-plugin/plugin.json: interface must be an object');
    return;
  }

  for (const key of ['displayName', 'shortDescription', 'longDescription', 'developerName', 'category']) {
    if (!isNonEmptyString(manifest.interface[key])) {
      fail(`.codex-plugin/plugin.json: interface.${key} must be a non-empty string`);
    }
  }

  if (manifest.interface.capabilities !== undefined) {
    if (!Array.isArray(manifest.interface.capabilities) || !manifest.interface.capabilities.every(isNonEmptyString)) {
      fail('.codex-plugin/plugin.json: interface.capabilities must be an array of non-empty strings');
    }
  }

  if (manifest.interface.defaultPrompt !== undefined) {
    const defaultPrompt = manifest.interface.defaultPrompt;
    if (Array.isArray(defaultPrompt)) {
      if (!defaultPrompt.every(isNonEmptyString)) {
        fail('.codex-plugin/plugin.json: interface.defaultPrompt entries must be non-empty strings');
      }
    } else if (!isNonEmptyString(defaultPrompt)) {
      fail('.codex-plugin/plugin.json: interface.defaultPrompt must be a string or string array');
    }
  }

  if (manifest.interface.brandColor !== undefined && !/^#[0-9A-Fa-f]{6}$/.test(manifest.interface.brandColor)) {
    fail('.codex-plugin/plugin.json: interface.brandColor must be a #RRGGBB color');
  }

  for (const key of ['websiteURL', 'privacyPolicyURL', 'termsOfServiceURL']) {
    validateUrl(manifest.interface[key], `.codex-plugin/plugin.json: interface.${key}`);
  }

  for (const key of ['composerIcon', 'logo']) {
    if (manifest.interface[key] !== undefined) {
      validateRelativePath(manifest.interface[key], `.codex-plugin/plugin.json: interface.${key}`, {
        expectedKind: 'file',
        preferAssets: true,
      });
    }
  }

  if (manifest.interface.screenshots !== undefined) {
    if (!Array.isArray(manifest.interface.screenshots)) {
      fail('.codex-plugin/plugin.json: interface.screenshots must be an array');
    } else {
      manifest.interface.screenshots.forEach((item, index) => {
        validateRelativePath(item, `.codex-plugin/plugin.json: interface.screenshots[${index}]`, {
          expectedKind: 'file',
          preferAssets: true,
        });
      });
    }
  }
}

function checkPluginRootShape() {
  const codexPluginDir = path.join(pluginDir, '.codex-plugin');
  if (fs.existsSync(codexPluginDir)) {
    for (const entry of fs.readdirSync(codexPluginDir, { withFileTypes: true })) {
      if (entry.name !== 'plugin.json') {
        fail(`.codex-plugin/${entry.name}: only plugin.json belongs in .codex-plugin/`);
      }
    }
  }

  const hooksDir = path.join(pluginDir, 'hooks');
  if (fs.existsSync(hooksDir)) {
    fail('hooks/: this plugin does not ship lifecycle hooks');
  }
}

function checkMarketplace(manifest) {
  if (!manifest) return;

  const candidateFiles = [
    path.join(pluginDir, '..', '..', '.agents', 'plugins', 'marketplace.json'),
    path.join(pluginDir, '.agents', 'plugins', 'marketplace.json'),
  ].map((candidate) => path.resolve(candidate));

  const marketplaceFile = candidateFiles.find((candidate) => fs.existsSync(candidate));
  if (!marketplaceFile) return;

  const marketplaceRoot = path.resolve(path.dirname(marketplaceFile), '..', '..');
  let marketplace;
  try {
    marketplace = JSON.parse(readText(marketplaceFile));
  } catch (error) {
    fail(`${path.relative(pluginDir, marketplaceFile)}: invalid JSON: ${error.message}`);
    return;
  }

  const label = path.relative(pluginDir, marketplaceFile) || marketplaceFile;
  if (!isNonEmptyString(marketplace.name)) {
    fail(`${label}: missing marketplace name`);
  }
  if (!isPlainObject(marketplace.interface)) {
    fail(`${label}: interface must be an object`);
  } else if (!isNonEmptyString(marketplace.interface.displayName)) {
    fail(`${label}: interface.displayName must be a non-empty string`);
  }
  if (!Array.isArray(marketplace.plugins)) {
    fail(`${label}: plugins must be an array`);
    return;
  }

  const matchingEntries = marketplace.plugins.filter((entry) => entry && entry.name === manifest.name);
  if (matchingEntries.length !== 1) {
    fail(`${label}: expected exactly one plugin entry named ${manifest.name}`);
    return;
  }

  const entry = matchingEntries[0];
  if (!isPlainObject(entry.policy)) {
    fail(`${label}: plugin policy must be an object`);
  } else {
    if (!isNonEmptyString(entry.policy.installation)) {
      fail(`${label}: policy.installation must be set`);
    }
    if (!isNonEmptyString(entry.policy.authentication)) {
      fail(`${label}: policy.authentication must be set`);
    }
  }
  if (!isNonEmptyString(entry.category)) {
    fail(`${label}: plugin category must be set`);
  }

  const sourcePath = marketplaceEntrySourcePath(entry.source, label);
  if (!sourcePath) return;
  const resolvedSourcePath = validateRelativePath(sourcePath, `${label}: source.path`, {
    baseDir: marketplaceRoot,
    expectedKind: 'directory',
  });
  if (!resolvedSourcePath) return;

  const expectedPluginDir = path.resolve(pluginDir);
  if (resolvedSourcePath !== expectedPluginDir) {
    fail(`${label}: source.path must resolve to ${path.relative(marketplaceRoot, expectedPluginDir)}`);
  }
}

function marketplaceEntrySourcePath(source, label) {
  if (isNonEmptyString(source)) {
    return source;
  }
  if (!isPlainObject(source)) {
    fail(`${label}: source must be a local path string or source object`);
    return null;
  }
  if (source.source === 'local') {
    if (!isNonEmptyString(source.path)) {
      fail(`${label}: local source.path must be set`);
      return null;
    }
    return source.path;
  }
  if (source.source === 'url' || source.source === 'git-subdir') {
    if (!isNonEmptyString(source.url)) {
      fail(`${label}: git-backed source.url must be set`);
    }
    if (source.path !== undefined) {
      validateRelativePath(source.path, `${label}: git source.path`, { baseDir: pluginDir, mustExist: false });
    }
    return null;
  }

  fail(`${label}: unsupported source.source '${source.source || ''}'`);
  return null;
}

function shippedFiles() {
  const roots = [
    '.codex-plugin',
    'skills',
    'references',
    'templates',
    'scripts',
    'assets',
    '.mcp.json',
    '.app.json',
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
  const prefixPattern = (parts) => new RegExp(`\\b${parts.join('')}`, 'i');
  const dottedPattern = (parts) => new RegExp(`\\.${parts.join('')}\\b`, 'i');
  const forbidden = [
    { pattern: wordPattern(['super', 'powers']), label: 'external workflow package name' },
    { pattern: dottedPattern(['super', 'powers']), label: 'external workflow state directory' },
    { pattern: wordPattern(['clau', 'de']), label: 'external assistant name' },
    { pattern: wordPattern(['brain', 'storming']), label: 'external workflow skill name' },
    { pattern: wordPattern(['prime', 'radiant']), label: 'external brand name' },
    { pattern: prefixPattern(['brain', 'storm_']), label: 'external visual companion environment prefix' },
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
      script: 'scripts/package-codex-plugin.mjs',
      requiredText: [
        'Usage: package-codex-plugin.mjs [options]',
        'Builds the Codex Plugin publishing package',
        '--output-dir <dir>',
      ],
    },
    {
      script: 'scripts/check-skill-package.mjs',
      requiredText: [
        'Usage: check-skill-package.mjs [plugin-dir]',
        'dev-cadence source directory',
        'SKILL.md frontmatter',
        'official manifest path rules',
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
        '--warnings-as-errors',
      ],
    },
    {
      script: 'scripts/check-gates.mjs',
      requiredText: [
        'Usage: check-gates.mjs --task-id <task-id> [options]',
        'Quality Gate and Human Gate',
        '--allow-pending-acceptance',
      ],
    },
    {
      script: 'scripts/check-before-commit.mjs',
      requiredText: [
        'Usage: check-before-commit.mjs [options]',
        'Checks Dev Cadence readiness before creating a Git commit',
        '--task-id <id>',
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
    {
      script: 'scripts/generate-spec-report.mjs',
      requiredText: [
        'Usage: generate-spec-report.mjs [options]',
        'static Dev Cadence specs HTML report',
        'Markdown and YAML task',
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
  const expected = EXPECTED_SKILLS.map((name) => `skills/${name}/agents/openai.yaml`);

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
const manifest = checkPluginManifest();
checkMarketplace(manifest);
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
