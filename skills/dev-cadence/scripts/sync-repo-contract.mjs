#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const START_MARKER = '<!-- dev-cadence:start -->';
const END_MARKER = '<!-- dev-cadence:end -->';

const AGENTS_SECTION = `${START_MARKER}
## AI Delivery Workflow

For software delivery tasks in this repository, use the Dev Cadence plugin.

This applies to feature development, bugfixes, refactoring, code review, research spikes, incident fixes, and any request that changes or evaluates repository behavior.

Read \`.ai/config.yaml\` and \`.ai/overrides/**\` when present. Write task artifacts and Harness evidence under \`specs/{task_id}/\`.

The user does not need to invoke a Skill name or choose a workflow. Dev Cadence infers \`workflow_hint\`, routes \`selected_workflow\`, records \`selection_reason\`, and follows its plugin-owned policies, templates, and gates.

Use direct execution without task specs only for explicitly trivial questions or non-delivery requests.
${END_MARKER}
`;

const CONFIG_YAML = `dev_cadence:
  artifact_language: en
  specs_dir: specs
  implementation_discipline: default
  verification_discipline: default
  review_profile: normal
`;

const LOCAL_YAML = `# Local Dev Cadence preferences.
# Uncomment and change this value to override generated artifact prose language for your local work.
# Supported values:
# - en: English
# - zh: Chinese, Simplified Chinese by default
# dev_cadence:
#   artifact_language: en
`;

function printHelp() {
  console.log(`Usage: sync-repo-contract.mjs --mode <mode> [options]

Initializes, inspects, or repairs the Dev Cadence thin repo-local contract.

Modes:
  inspect       Read repo-local contract status without writing.
  init          Create missing thin-contract files.
  sync          Reconcile generated thin-contract entrypoints.
  repair        Restore missing thin-contract files.
  diagnose      Report routing and contract issues without writing.

Options:
  --repo-dir <dir>   Target repository directory. Defaults to current working directory.
  --dry-run          Report planned writes without changing files.
  --json             Print machine-readable JSON report.
  -h, --help         Show this help text.

Writes are limited to root AGENTS.md, root .gitignore, .ai/config.yaml,
.ai/local.yaml, .ai/overrides/.gitkeep, and specs/.gitkeep.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    mode: null,
    repoDir: process.cwd(),
    dryRun: false,
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--mode') {
      options.mode = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--repo-dir') {
      options.repoDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--dry-run') {
      options.dryRun = true;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  const supportedModes = new Set(['inspect', 'init', 'sync', 'repair', 'diagnose']);
  if (!options.mode || !supportedModes.has(options.mode)) {
    throw new Error(`Missing or unsupported --mode. Use one of: ${[...supportedModes].join(', ')}`);
  }

  options.repoDir = path.resolve(options.repoDir);
  return options;
}

function readValue(argv, index, arg) {
  const value = argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`${arg} requires a value`);
  }
  return value;
}

function rel(repoDir, filePath) {
  return path.relative(repoDir, filePath) || '.';
}

function readIfExists(filePath) {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : null;
}

function ensureParent(filePath) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

function hasNonGitkeepEntries(dir) {
  if (!fs.existsSync(dir)) return false;
  return fs.readdirSync(dir).some((entry) => entry !== '.gitkeep');
}

function createReport(options) {
  return {
    mode: options.mode,
    repository: options.repoDir,
    initialized: false,
    dry_run: options.dryRun,
    metadata: {
      start_marker: START_MARKER,
      end_marker: END_MARKER,
    },
    files_added: [],
    files_updated: [],
    files_preserved: [],
    local_overlays: [],
    conflicts: [],
    manual_review_required: [],
    forbidden_changes_avoided: [
      'product source',
      'tests',
      'migrations',
      'build scripts',
      'deployment files',
      'application configuration',
      'task-specific specs',
    ],
    verification: [],
    next_steps: [],
  };
}

function record(report, field, repoDir, filePath) {
  const value = rel(repoDir, filePath);
  if (!report[field].includes(value)) {
    report[field].push(value);
  }
}

function writeFileIfNeeded(options, report, filePath, content) {
  const current = readIfExists(filePath);
  if (current === content) {
    record(report, 'files_preserved', options.repoDir, filePath);
    return;
  }

  if (current === null) {
    record(report, 'files_added', options.repoDir, filePath);
  } else {
    record(report, 'files_updated', options.repoDir, filePath);
  }

  if (!options.dryRun && shouldWrite(options.mode)) {
    ensureParent(filePath);
    fs.writeFileSync(filePath, content);
  }
}

function shouldWrite(mode) {
  return mode === 'init' || mode === 'sync' || mode === 'repair';
}

function updateAgentsContent(existing) {
  const normalized = existing || '';
  const start = normalized.indexOf(START_MARKER);
  const end = normalized.indexOf(END_MARKER);

  if (start !== -1 && end !== -1 && end > start) {
    const before = normalized.slice(0, start).trimEnd();
    const after = normalized.slice(end + END_MARKER.length).trimStart();
    return [before, AGENTS_SECTION.trimEnd(), after].filter(Boolean).join('\n\n') + '\n';
  }

  if (start !== -1 || end !== -1) {
    return null;
  }

  const prefix = normalized.trimEnd();
  return [prefix, AGENTS_SECTION.trimEnd()].filter(Boolean).join('\n\n') + '\n';
}

function reconcileAgents(options, report) {
  const agentsPath = path.join(options.repoDir, 'AGENTS.md');
  const existing = readIfExists(agentsPath);
  const next = updateAgentsContent(existing);

  if (next === null) {
    report.conflicts.push('AGENTS.md has only one Dev Cadence marker');
    report.manual_review_required.push('Repair AGENTS.md marker pair before automatic sync');
    return false;
  }

  if (!shouldWrite(options.mode)) {
    if (existing && existing.includes(START_MARKER) && existing.includes(END_MARKER)) {
      record(report, 'files_preserved', options.repoDir, agentsPath);
    } else {
      report.next_steps.push('Add Dev Cadence AI Delivery Workflow section to AGENTS.md');
    }
    return true;
  }

  writeFileIfNeeded(options, report, agentsPath, next);
  return true;
}

function reconcileGitignore(options, report) {
  const gitignorePath = path.join(options.repoDir, '.gitignore');
  const existing = readIfExists(gitignorePath);
  const lines = existing ? existing.split(/\r?\n/) : [];
  const hasEntry = lines.some((line) => line.trim() === '.ai/local.yaml');

  if (!shouldWrite(options.mode)) {
    if (hasEntry) {
      record(report, 'files_preserved', options.repoDir, gitignorePath);
    } else {
      report.next_steps.push('Add .ai/local.yaml to .gitignore');
    }
    return;
  }

  if (hasEntry) {
    record(report, 'files_preserved', options.repoDir, gitignorePath);
    return;
  }

  const base = existing === null ? '' : existing.trimEnd();
  const next = `${base}${base ? '\n' : ''}.ai/local.yaml\n`;
  writeFileIfNeeded(options, report, gitignorePath, next);
}

function reconcileConfig(options, report) {
  const configPath = path.join(options.repoDir, '.ai', 'config.yaml');
  const existing = readIfExists(configPath);

  if (existing !== null) {
    record(report, 'files_preserved', options.repoDir, configPath);
    if (!existing.includes('dev_cadence:')) {
      report.conflicts.push('.ai/config.yaml exists without dev_cadence key');
      report.manual_review_required.push('Review .ai/config.yaml before automatic config merge');
    }
    return;
  }

  if (!shouldWrite(options.mode)) {
    report.next_steps.push('Create .ai/config.yaml with Dev Cadence defaults');
    return;
  }

  writeFileIfNeeded(options, report, configPath, CONFIG_YAML);
}

function reconcileLocal(options, report) {
  const localPath = path.join(options.repoDir, '.ai', 'local.yaml');
  if (fs.existsSync(localPath)) {
    record(report, 'files_preserved', options.repoDir, localPath);
    return;
  }

  if (!shouldWrite(options.mode)) {
    report.next_steps.push('Create .ai/local.yaml with commented local preferences');
    return;
  }

  writeFileIfNeeded(options, report, localPath, LOCAL_YAML);
}

function reconcileGitkeep(options, report, dir, gitkeepPath) {
  if (fs.existsSync(gitkeepPath)) {
    record(report, 'files_preserved', options.repoDir, gitkeepPath);
    return;
  }

  if (hasNonGitkeepEntries(dir)) {
    record(report, 'local_overlays', options.repoDir, dir);
    return;
  }

  if (!shouldWrite(options.mode)) {
    report.next_steps.push(`Create ${rel(options.repoDir, gitkeepPath)}`);
    return;
  }

  writeFileIfNeeded(options, report, gitkeepPath, '');
}

function inspectUnknownAi(options, report) {
  const aiDir = path.join(options.repoDir, '.ai');
  if (!fs.existsSync(aiDir)) return;

  const known = new Set(['config.yaml', 'local.yaml', 'overrides']);
  for (const entry of fs.readdirSync(aiDir)) {
    if (!known.has(entry)) {
      record(report, 'local_overlays', options.repoDir, path.join(aiDir, entry));
    }
  }
}

function verify(options, report) {
  const agents = readIfExists(path.join(options.repoDir, 'AGENTS.md')) || '';
  const gitignore = readIfExists(path.join(options.repoDir, '.gitignore')) || '';
  const configExists = fs.existsSync(path.join(options.repoDir, '.ai', 'config.yaml'));
  const localExists = fs.existsSync(path.join(options.repoDir, '.ai', 'local.yaml'));
  const overridesExists = fs.existsSync(path.join(options.repoDir, '.ai', 'overrides'));
  const specsExists = fs.existsSync(path.join(options.repoDir, 'specs'));

  report.verification.push({
    check: 'AGENTS.md routes normal delivery to Dev Cadence',
    status: agents.includes(START_MARKER) && agents.includes('Dev Cadence plugin') ? 'pass' : 'missing',
  });
  report.verification.push({
    check: '.ai/config.yaml exists',
    status: configExists ? 'pass' : 'missing',
  });
  report.verification.push({
    check: '.ai/local.yaml exists and is ignored',
    status: localExists && gitignore.split(/\r?\n/).some((line) => line.trim() === '.ai/local.yaml') ? 'pass' : 'missing',
  });
  report.verification.push({
    check: '.ai/overrides/ exists',
    status: overridesExists ? 'pass' : 'missing',
  });
  report.verification.push({
    check: 'specs/ exists',
    status: specsExists ? 'pass' : 'missing',
  });
  report.verification.push({
    check: 'no product files were in allowed write set',
    status: 'pass',
  });

  report.initialized = report.verification
    .filter((item) => item.check !== 'no product files were in allowed write set')
    .every((item) => item.status === 'pass');
}

function reconcile(options) {
  if (!fs.existsSync(options.repoDir)) {
    throw new Error(`Repository directory not found: ${options.repoDir}`);
  }
  if (!fs.statSync(options.repoDir).isDirectory()) {
    throw new Error(`Repository path is not a directory: ${options.repoDir}`);
  }

  const report = createReport(options);

  const agentsOk = reconcileAgents(options, report);
  if (!agentsOk) {
    inspectUnknownAi(options, report);
    verify(options, report);
    report.next_steps.push('Repair AGENTS.md marker conflict before running sync or repair again');
    return report;
  }

  reconcileGitignore(options, report);
  reconcileConfig(options, report);
  reconcileLocal(options, report);
  reconcileGitkeep(options, report, path.join(options.repoDir, '.ai', 'overrides'), path.join(options.repoDir, '.ai', 'overrides', '.gitkeep'));
  reconcileGitkeep(options, report, path.join(options.repoDir, 'specs'), path.join(options.repoDir, 'specs', '.gitkeep'));
  inspectUnknownAi(options, report);
  verify(options, report);

  if (report.initialized) {
    report.next_steps.push('Use Dev Cadence delivery routing for ordinary repository work');
  } else if (options.mode === 'inspect' || options.mode === 'diagnose') {
    report.next_steps.push('Run init, sync, or repair mode to create missing thin-contract files');
  }

  return report;
}

function printReport(report) {
  console.log(`Mode: ${report.mode}${report.dry_run ? ' (dry-run)' : ''}`);
  console.log(`Repository: ${report.repository}`);
  console.log(`Initialized: ${report.initialized ? 'yes' : 'no'}`);

  for (const field of ['files_added', 'files_updated', 'files_preserved', 'local_overlays', 'conflicts', 'manual_review_required', 'next_steps']) {
    const values = report[field];
    if (!values || values.length === 0) continue;
    console.log(`\n${field}:`);
    for (const value of values) {
      console.log(`- ${value}`);
    }
  }

  console.log('\nverification:');
  for (const item of report.verification) {
    console.log(`- ${item.status}: ${item.check}`);
  }
}

try {
  const options = parseArgs(process.argv.slice(2));
  const report = reconcile(options);
  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    printReport(report);
  }
  if (report.conflicts.length > 0) {
    process.exit(1);
  }
} catch (error) {
  console.error(`ERROR ${error.message}`);
  console.error('Run with --help for usage.');
  process.exit(2);
}
