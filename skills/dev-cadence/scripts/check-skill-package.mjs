#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

function printHelp() {
  console.log(`Usage: check-skill-package.mjs [skill-dir]

Validates the Dev Cadence skill package structure and basic runtime hygiene.

Arguments:
  skill-dir  Skill package directory to check. Defaults to the parent directory
             of this script.

Checks:
  - SKILL.md frontmatter name and description
  - English-only shipped skill package content
  - absence of legacy external naming
  - absence of runtime auxiliary docs such as README.md
  - JavaScript syntax and shell executable bits under scripts/
  - artifact template fenced yaml blocks have no duplicate keys
  - agents/openai.yaml metadata fields when present`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

const skillDir = path.resolve(process.argv[2] || path.join(import.meta.dirname, '..'));
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
  return path.relative(skillDir, filePath);
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
  const skillPath = path.join(skillDir, 'SKILL.md');
  if (!fs.existsSync(skillPath)) {
    fail('SKILL.md: missing required file');
    return;
  }

  const frontmatter = parseSimpleYamlFrontmatter(readText(skillPath), skillPath);
  if (!frontmatter) return;

  const allowedKeys = new Set(['name', 'description']);
  for (const key of Object.keys(frontmatter)) {
    if (!allowedKeys.has(key)) {
      fail(`SKILL.md: unexpected frontmatter key '${key}'`);
    }
  }

  if (frontmatter.name !== 'dev-cadence') {
    fail(`SKILL.md: expected name 'dev-cadence', got '${frontmatter.name || ''}'`);
  }

  if (!frontmatter.description) {
    fail('SKILL.md: missing description');
  } else if (frontmatter.description.length > 1024) {
    fail(`SKILL.md: description too long (${frontmatter.description.length} characters)`);
  }

  if (frontmatter.name && !/^[a-z0-9-]+$/.test(frontmatter.name)) {
    fail(`SKILL.md: name must use lowercase letters, digits, and hyphens only`);
  }
}

function checkLanguageBoundary(files) {
  const chinese = /[\u3400-\u9fff]/;
  for (const filePath of files) {
    if (/\.(png|jpg|jpeg|gif|svg)$/i.test(filePath)) continue;
    const text = readText(filePath);
    if (chinese.test(text)) {
      fail(`${rel(filePath)}: Skill package content must be English; found Chinese characters`);
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
      fail(`${rel(filePath)}: runtime Skill packages should not include auxiliary docs`);
    }
  }
}

function checkScripts() {
  const scriptsDir = path.join(skillDir, 'scripts');
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
        'Usage: check-skill-package.mjs [skill-dir]',
        'Defaults to the parent directory',
        'SKILL.md frontmatter',
      ],
    },
    {
      script: 'scripts/check-discipline-routes.mjs',
      requiredText: [
        'Usage: check-discipline-routes.mjs [skill-dir]',
        'Defaults to the parent directory',
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
  ];

  for (const command of commands) {
    const scriptPath = path.join(skillDir, command.script);
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
  const scriptPath = path.join(skillDir, 'scripts', 'check-spec-artifacts.mjs');
  const templatesDir = path.join(skillDir, 'templates');
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
  const openAiYaml = path.join(skillDir, 'agents', 'openai.yaml');
  if (!fs.existsSync(openAiYaml)) {
    warn('agents/openai.yaml: missing optional UI metadata');
    return;
  }
  const text = readText(openAiYaml);
  for (const required of ['display_name:', 'short_description:', 'default_prompt:']) {
    if (!text.includes(required)) {
      fail(`agents/openai.yaml: missing ${required}`);
    }
  }
}

if (!fs.existsSync(skillDir)) {
  console.error(`Skill directory not found: ${skillDir}`);
  process.exit(2);
}

const files = walk(skillDir);
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

console.log(`OK checked ${files.length} files in ${path.relative(process.cwd(), skillDir) || skillDir}`);
