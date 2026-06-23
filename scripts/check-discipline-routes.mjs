#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

function printHelp() {
  console.log(`Usage: check-discipline-routes.mjs [plugin-dir]

Validates Dev Cadence discipline routing and bundled resource references.

Arguments:
  plugin-dir  Plugin source directory to check. Defaults to the parent directory
              of this script.

Checks:
  - referenced references/, templates/, and scripts/ paths exist
  - delivery-disciplines.md routes to required discipline references
  - required prompt templates exist and are referenced
  - visual companion resources exist and are indexed
  - entrypoint skills reference required shared resources`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

const pluginDir = path.resolve(process.argv[2] || path.join(import.meta.dirname, '..'));
const errors = [];

function fail(message) {
  errors.push(message);
}

function readText(relativePath) {
  return fs.readFileSync(path.join(pluginDir, relativePath), 'utf8');
}

function exists(relativePath) {
  return fs.existsSync(path.join(pluginDir, relativePath));
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
    'adapters.md',
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

function checkArtifactTemplates() {
  const required = [
    'templates/spec/00-brief.md',
    'templates/spec/01-requirements.md',
    'templates/spec/02-design.md',
    'templates/spec/03-tasks.md',
    'templates/spec/04-test-plan.md',
    'templates/spec/05-implementation.md',
    'templates/spec/06-test-report.md',
    'templates/spec/07-review-report.md',
    'templates/spec/08-acceptance.md',
    'templates/runs/run-context.md',
    'templates/runs/execution-report.md',
    'templates/runs/tool-log.md',
    'templates/runs/test-log.md',
    'templates/runs/diff-summary.md',
    'templates/runs/permission-decisions.md',
  ];

  for (const relativePath of required) {
    if (!exists(relativePath)) {
      fail(`missing artifact template: ${relativePath}`);
    }
  }

  const specsRef = readText('references/spec-templates.md');
  for (const relativePath of required) {
    if (!specsRef.includes(relativePath)) {
      fail(`artifact template is not referenced by spec-templates.md: ${relativePath}`);
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

function checkEntrypointReferenceMap() {
  const skillText = [
    'skills/dev-cadence-init/SKILL.md',
    'skills/dev-cadence-deliver/SKILL.md',
    'skills/dev-cadence-maintain/SKILL.md',
    'skills/dev-cadence-authoring/SKILL.md',
  ].map(readText).join('\n');
  const expected = [
    'references/delivery-disciplines.md',
    'references/repository-rule-sync.md',
    'references/authoring-discipline.md',
    'references/skill-layout.md',
  ];
  for (const item of expected) {
    if (!skillText.includes(item)) {
      fail(`entrypoint skills: missing reference to ${item}`);
    }
  }
}

function checkEntrypointSkills() {
  const required = [
    'skills/dev-cadence-init/SKILL.md',
    'skills/dev-cadence-init/agents/openai.yaml',
    'skills/dev-cadence-deliver/SKILL.md',
    'skills/dev-cadence-deliver/agents/openai.yaml',
    'skills/dev-cadence-maintain/SKILL.md',
    'skills/dev-cadence-maintain/agents/openai.yaml',
    'skills/dev-cadence-authoring/SKILL.md',
    'skills/dev-cadence-authoring/agents/openai.yaml',
  ];

  for (const relativePath of required) {
    if (!exists(relativePath)) {
      fail(`missing entrypoint skill resource: ${relativePath}`);
    }
  }

  const layoutText = readText('references/skill-layout.md');
  for (const skillName of ['dev-cadence-init', 'dev-cadence-deliver', 'dev-cadence-maintain', 'dev-cadence-authoring']) {
    if (!layoutText.includes(`${skillName}/`)) {
      fail(`references/skill-layout.md: missing target entrypoint ${skillName}/`);
    }
  }
}

function checkPluginSurface() {
  const required = [
    '.codex-plugin/plugin.json',
    'hooks/hooks-codex.json',
    'hooks/run-hook.cmd',
    'hooks/session-start-codex',
  ];
  for (const relativePath of required) {
    if (!exists(relativePath)) {
      fail(`missing plugin surface resource: ${relativePath}`);
    }
  }
}

if (!fs.existsSync(pluginDir)) {
  console.error(`Plugin directory not found: ${pluginDir}`);
  process.exit(2);
}

checkPluginSurface();
checkPathReferences('references/delivery-disciplines.md');
checkPathReferences('references/visual-companion.md');
checkPathReferences('references/skill-layout.md');
checkDeliveryStateTable();
checkPromptTemplates();
checkArtifactTemplates();
checkVisualCompanionScripts();
checkEntrypointReferenceMap();
checkEntrypointSkills();

if (errors.length > 0) {
  for (const message of errors) {
    console.error(`FAIL ${message}`);
  }
  console.error(`\n${errors.length} failure(s)`);
  process.exit(1);
}

console.log(`OK discipline routes verified for ${path.relative(process.cwd(), pluginDir) || pluginDir}`);
