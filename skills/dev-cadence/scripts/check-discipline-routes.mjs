#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const skillDir = path.resolve(process.argv[2] || path.join(import.meta.dirname, '..'));
const errors = [];

function fail(message) {
  errors.push(message);
}

function readText(relativePath) {
  return fs.readFileSync(path.join(skillDir, relativePath), 'utf8');
}

function exists(relativePath) {
  return fs.existsSync(path.join(skillDir, relativePath));
}

function extractBacktickPaths(text) {
  const paths = new Set();
  for (const match of text.matchAll(/`([^`]+)`/g)) {
    const value = match[1].trim();
    if (/^(references|templates|scripts)\/[A-Za-z0-9._/-]+\/?$/.test(value)) {
      paths.add(value);
    }
  }
  return paths;
}

function checkPathReferences(sourceFile) {
  const text = readText(sourceFile);
  for (const referencedPath of extractBacktickPaths(text)) {
    if (!exists(referencedPath)) {
      fail(`${sourceFile}: referenced path does not exist: ${referencedPath}`);
    }
  }
}

function checkDeliveryStateTable() {
  const sourceFile = 'references/delivery-disciplines.md';
  const text = readText(sourceFile);
  const required = [
    'intent-and-design-discipline.md',
    'visual-companion.md',
    'planning-discipline.md',
    'implementation-discipline.md',
    'testing-anti-patterns.md',
    'execution-orchestration.md',
    'debugging-discipline.md',
    'root-cause-tracing.md',
    'condition-based-waiting.md',
    'defense-in-depth.md',
    'review-discipline.md',
    'verification-discipline.md',
    'authoring-discipline.md',
    'skill-pressure-testing.md',
  ];

  for (const fileName of required) {
    if (!text.includes(fileName)) {
      fail(`${sourceFile}: missing required route to ${fileName}`);
    }
    if (!exists(`references/${fileName}`)) {
      fail(`${sourceFile}: route target missing: references/${fileName}`);
    }
  }
}

function checkPromptTemplates() {
  const required = [
    'templates/prompts/spec-document-reviewer.md',
    'templates/prompts/plan-document-reviewer.md',
    'templates/prompts/implementer.md',
    'templates/prompts/spec-compliance-reviewer.md',
    'templates/prompts/code-quality-reviewer.md',
    'templates/prompts/code-reviewer.md',
  ];

  for (const relativePath of required) {
    if (!exists(relativePath)) {
      fail(`missing prompt template: ${relativePath}`);
    }
  }

  const refs = [
    'references/intent-and-design-discipline.md',
    'references/planning-discipline.md',
    'references/execution-orchestration.md',
    'references/review-discipline.md',
    'references/agent-blueprints.md',
  ];
  const combined = refs.map(readText).join('\n');
  for (const relativePath of required) {
    if (!combined.includes(relativePath)) {
      fail(`prompt template is not referenced by discipline or blueprint: ${relativePath}`);
    }
  }
}

function checkVisualCompanionScripts() {
  const required = [
    'references/visual-companion.md',
    'scripts/visual-companion/start-server.sh',
    'scripts/visual-companion/stop-server.sh',
    'scripts/visual-companion/server.cjs',
    'scripts/visual-companion/helper.js',
    'scripts/visual-companion/frame-template.html',
  ];

  for (const relativePath of required) {
    if (!exists(relativePath)) {
      fail(`missing visual companion resource: ${relativePath}`);
    }
  }

  const visualRef = readText('references/visual-companion.md');
  for (const relativePath of required.slice(1)) {
    if (!visualRef.includes(relativePath)) {
      fail(`references/visual-companion.md: missing script reference ${relativePath}`);
    }
  }
}

function checkSkillReferenceMap() {
  const skillText = readText('SKILL.md');
  const expected = [
    'references/delivery-disciplines.md',
    'references/visual-companion.md',
    'templates/prompts/',
    'scripts/check-skill-package.mjs',
    'scripts/check-discipline-routes.mjs',
    'scripts/visual-companion/',
  ];
  for (const item of expected) {
    if (!skillText.includes(item)) {
      fail(`SKILL.md: Reference Map missing ${item}`);
    }
  }
}

if (!exists('SKILL.md')) {
  console.error(`Skill directory not found or missing SKILL.md: ${skillDir}`);
  process.exit(2);
}

checkPathReferences('SKILL.md');
checkPathReferences('references/delivery-disciplines.md');
checkPathReferences('references/visual-companion.md');
checkPathReferences('references/skill-layout.md');
checkDeliveryStateTable();
checkPromptTemplates();
checkVisualCompanionScripts();
checkSkillReferenceMap();

if (errors.length > 0) {
  for (const message of errors) {
    console.error(`FAIL ${message}`);
  }
  console.error(`\n${errors.length} failure(s)`);
  process.exit(1);
}

console.log(`OK discipline routes verified for ${path.relative(process.cwd(), skillDir) || skillDir}`);
