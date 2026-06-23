#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const SPEC_TEMPLATES = [
  '00-brief.md',
  '01-requirements.md',
  '02-design.md',
  '03-tasks.md',
  '04-test-plan.md',
  '05-implementation.md',
  '06-test-report.md',
  '07-review-report.md',
  '08-acceptance.md',
];

const RUN_TEMPLATES = [
  'run-context.md',
  'execution-report.md',
  'tool-log.md',
  'test-log.md',
  'diff-summary.md',
  'permission-decisions.md',
];

function printHelp() {
  console.log(`Usage: init-task-artifacts.mjs --task-id <task-id> [options]

Initializes Dev Cadence task artifacts from bundled templates.

Required:
  --task-id <id>       Task directory name under the specs directory.

Options:
  --run-id <id>        Also initialize Harness evidence under runs/<run-id>.
  --specs-dir <dir>    Specs output directory. Defaults to specs.
  --plugin-dir <dir>   Dev Cadence plugin source directory. Defaults to the
                       parent directory of this script.
  --skill-dir <dir>    Deprecated alias for --plugin-dir.
  --overwrite          Replace existing artifact files. Defaults to skip.
  --dry-run            Report planned writes without creating files.
  --json               Print machine-readable JSON report.
  -h, --help           Show this help text.

Examples:
  init-task-artifacts.mjs --task-id 20260622-login
  init-task-artifacts.mjs --task-id 20260622-login --run-id 20260622-1030-developer-1
  init-task-artifacts.mjs --task-id 20260622-login --specs-dir specs --dry-run`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    pluginDir: path.resolve(path.join(import.meta.dirname, '..')),
    specsDir: path.resolve('specs'),
    taskId: null,
    runId: null,
    overwrite: false,
    dryRun: false,
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--task-id') {
      options.taskId = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--run-id') {
      options.runId = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--specs-dir') {
      options.specsDir = path.resolve(readValue(argv, index, arg));
      index += 1;
    } else if (arg === '--plugin-dir') {
      options.pluginDir = path.resolve(readValue(argv, index, arg));
      index += 1;
    } else if (arg === '--skill-dir') {
      options.pluginDir = path.resolve(readValue(argv, index, arg));
      index += 1;
    } else if (arg === '--overwrite') {
      options.overwrite = true;
    } else if (arg === '--dry-run') {
      options.dryRun = true;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  validateId('task-id', options.taskId);
  if (options.runId !== null) {
    validateId('run-id', options.runId);
  }

  return options;
}

function readValue(argv, index, arg) {
  const value = argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`${arg} requires a value`);
  }
  return value;
}

function validateId(label, value) {
  if (!value) {
    throw new Error(`Missing required --${label}`);
  }
  if (!/^[a-z0-9][a-z0-9._-]*$/.test(value)) {
    throw new Error(`Invalid ${label}: use lowercase letters, digits, dots, underscores, and hyphens only`);
  }
}

function rel(filePath) {
  const relativePath = path.relative(process.cwd(), filePath);
  if (!relativePath || relativePath.startsWith('..') || path.isAbsolute(relativePath)) {
    return filePath;
  }
  return relativePath;
}

function createReport(options) {
  const taskDir = path.join(options.specsDir, options.taskId);
  return {
    task_id: options.taskId,
    run_id: options.runId,
    specs_dir: rel(options.specsDir),
    task_dir: rel(taskDir),
    run_dir: options.runId ? rel(path.join(taskDir, 'runs', options.runId)) : null,
    dry_run: options.dryRun,
    overwrite: options.overwrite,
    created: [],
    overwritten: [],
    skipped_existing: [],
    missing_templates: [],
  };
}

function copyTemplates(options, report, templateDir, destinationDir, templateNames) {
  for (const templateName of templateNames) {
    const sourcePath = path.join(templateDir, templateName);
    const destinationPath = path.join(destinationDir, templateName);
    const destination = rel(destinationPath);

    if (!fs.existsSync(sourcePath)) {
      report.missing_templates.push(rel(sourcePath));
      continue;
    }

    if (fs.existsSync(destinationPath)) {
      if (!options.overwrite) {
        report.skipped_existing.push(destination);
        continue;
      }
      if (!options.dryRun) {
        fs.mkdirSync(path.dirname(destinationPath), { recursive: true });
        fs.copyFileSync(sourcePath, destinationPath);
      }
      report.overwritten.push(destination);
      continue;
    }

    if (!options.dryRun) {
      fs.mkdirSync(path.dirname(destinationPath), { recursive: true });
      fs.copyFileSync(sourcePath, destinationPath);
    }
    report.created.push(destination);
  }
}

function initialize(options) {
  const report = createReport(options);
  const specTemplateDir = path.join(options.pluginDir, 'templates', 'spec');
  const runTemplateDir = path.join(options.pluginDir, 'templates', 'runs');
  const taskDir = path.join(options.specsDir, options.taskId);

  copyTemplates(options, report, specTemplateDir, taskDir, SPEC_TEMPLATES);

  if (options.runId) {
    copyTemplates(options, report, runTemplateDir, path.join(taskDir, 'runs', options.runId), RUN_TEMPLATES);
  }

  return report;
}

function printReport(report) {
  console.log(`Task artifacts: ${report.task_dir}`);
  if (report.run_dir) {
    console.log(`Run artifacts: ${report.run_dir}`);
  }
  console.log(`Mode: ${report.dry_run ? 'dry-run' : 'write'}${report.overwrite ? ', overwrite' : ', skip existing'}`);
  console.log(`Created: ${report.created.length}`);
  console.log(`Overwritten: ${report.overwritten.length}`);
  console.log(`Skipped existing: ${report.skipped_existing.length}`);
  console.log(`Missing templates: ${report.missing_templates.length}`);

  for (const [label, values] of [
    ['created', report.created],
    ['overwritten', report.overwritten],
    ['skipped_existing', report.skipped_existing],
    ['missing_templates', report.missing_templates],
  ]) {
    if (values.length === 0) continue;
    console.log(`\n${label}:`);
    for (const value of values) {
      console.log(`- ${value}`);
    }
  }
}

try {
  const options = parseArgs(process.argv.slice(2));
  const report = initialize(options);
  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    printReport(report);
  }
  if (report.missing_templates.length > 0) {
    process.exit(1);
  }
} catch (error) {
  console.error(`ERROR ${error.message}`);
  console.error('Run with --help for usage.');
  process.exit(2);
}
