#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { readArtifactData } from './markdown-artifacts.mjs';
import { defaultReportDirForSpecsDir, normalizeSpecsDir, RECORDS_DIR, resolveDefaultSpecsDir } from './specs-paths.mjs';

const REQUIRED_FILES = [
  '00-brief.md',
  '05-implementation.md',
  '06-test-report.md',
  '07-review-report.md',
  '08-acceptance.md',
];

function printHelp() {
  console.log(`Usage: summarize-acceptance.mjs --task-id <task-id> [options]

Prints a Human-facing acceptance summary from Dev Cadence task artifacts.

Required:
  --task-id <id>       Task directory name under the specs directory.

Options:
  --specs-dir <dir>    Specs records directory. Defaults to specs/records,
                       or legacy specs when it already contains task dirs.
  --report-dir <dir>   Generated specs report directory. Defaults to specs/report
                       when --specs-dir is specs/records.
  --require-report     Fail when specs/report/{task-id}/index.html is missing.
  --json               Print machine-readable JSON.
  -h, --help           Show this help text.

The summary is read-only. It does not accept work or modify 08-acceptance.md.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    specsDir: resolveDefaultSpecsDir(),
    reportDir: null,
    taskId: null,
    requireReport: false,
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--task-id') {
      options.taskId = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--specs-dir') {
      options.specsDir = normalizeSpecsDir(readValue(argv, index, arg));
      index += 1;
    } else if (arg === '--report-dir') {
      options.reportDir = path.resolve(readValue(argv, index, arg));
      index += 1;
    } else if (arg === '--require-report') {
      options.requireReport = true;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  validateId('task-id', options.taskId);
  if (!options.reportDir) {
    options.reportDir = defaultReportDirForSpecsDir(options.specsDir);
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

function rel(baseDir, filePath) {
  return path.relative(baseDir, filePath) || '.';
}

function reportDisplayBase(specsDir) {
  if (path.basename(specsDir) === RECORDS_DIR) {
    return path.dirname(path.dirname(specsDir));
  }
  return path.dirname(specsDir);
}

function readArtifact(taskDir, fileName) {
  const filePath = path.join(taskDir, fileName);
  if (!fs.existsSync(filePath)) {
    return { fileName, path: filePath, exists: false, data: {}, text: '' };
  }
  const text = fs.readFileSync(filePath, 'utf8');
  return {
    fileName,
    path: filePath,
    exists: true,
    data: readArtifactData(text),
    text,
  };
}

function runFiles(taskDir) {
  const runsDir = path.join(taskDir, 'runs');
  if (!fs.existsSync(runsDir)) return [];

  const result = [];
  for (const runId of fs.readdirSync(runsDir).sort()) {
    const runDir = path.join(runsDir, runId);
    if (!fs.statSync(runDir).isDirectory()) continue;
    for (const file of fs.readdirSync(runDir).sort()) {
      const fullPath = path.join(runDir, file);
      if (fs.statSync(fullPath).isFile()) {
        result.push(fullPath);
      }
    }
  }
  return result;
}

function asList(value) {
  if (Array.isArray(value)) return value;
  if (value === null || value === undefined || value === '') return [];
  return [value];
}

function hasNamedHuman(value) {
  if (Array.isArray(value)) return value.some((item) => hasNamedHuman(item));
  if (value === null || value === undefined) return false;
  if (typeof value === 'boolean') return false;
  const text = String(value).trim().toLowerCase();
  return ![
    '',
    'false',
    'true',
    'yes',
    'no',
    'none',
    'null',
    'n/a',
    'na',
    'tbd',
    'todo',
    'pending',
    'unknown',
    'supervisor',
    'harness',
    'developer',
    'tester',
    'reviewer',
    'agent',
    'worker',
    'codex',
    'assistant',
    'ai',
  ].includes(text);
}

function displayHuman(value) {
  if (!hasNamedHuman(value)) return null;
  if (Array.isArray(value)) return value.find((item) => hasNamedHuman(item));
  return value;
}

function scopeReconciliationStatus(value) {
  if (!value) return null;
  if (typeof value === 'string') return value;
  if (Array.isArray(value)) return value.length > 0 ? value.join(', ') : null;
  if (typeof value === 'object') return value.status || value.decision || null;
  return String(value);
}

function summarize(options) {
  const taskDir = path.join(options.specsDir, options.taskId);
  if (!fs.existsSync(taskDir)) {
    throw new Error(`Task artifacts not found: ${taskDir}`);
  }
  const reportEntryPath = path.join(options.reportDir, options.taskId, 'index.html');
  const reportEntryExists = fs.existsSync(reportEntryPath);
  const reportEntry = rel(reportDisplayBase(options.specsDir), reportEntryPath);

  const artifacts = Object.fromEntries(REQUIRED_FILES.map((file) => [file, readArtifact(taskDir, file)]));
  const missing = Object.values(artifacts).filter((artifact) => !artifact.exists).map((artifact) => artifact.fileName);
  const runs = runFiles(taskDir);

  const brief = artifacts['00-brief.md'].data;
  const implementation = artifacts['05-implementation.md'].data;
  const testReport = artifacts['06-test-report.md'].data;
  const reviewReport = artifacts['07-review-report.md'].data;
  const acceptance = artifacts['08-acceptance.md'].data;

  const acceptedByHuman = displayHuman(acceptance.accepted_by_human);
  const needsHumanAcceptance = !acceptedByHuman || acceptance.status === 'blocked_pending_named_human';
  const residualRisk = [
    ...asList(testReport.residual_risk),
    ...asList(reviewReport.residual_risk),
    ...asList(acceptance.residual_risk_accepted),
  ].filter(Boolean);
  const displayResidualRisk = needsHumanAcceptance
    ? residualRisk
    : residualRisk.filter((item) => !isPendingAcceptanceRisk(item));
  const evidence = [
    ...Object.values(artifacts).filter((artifact) => artifact.exists).map((artifact) => rel(options.specsDir, artifact.path)),
    ...runs.map((filePath) => rel(options.specsDir, filePath)),
  ];

  return {
    task_id: options.taskId,
    task_dir: rel(options.specsDir, taskDir),
    goal: brief.goal || null,
    selected_workflow: brief.selected_workflow || null,
    task_class: brief.task_class || null,
    implementation_status: implementation.status || null,
    scope_reconciliation: scopeReconciliationStatus(implementation.scope_reconciliation),
    verification_status: testReport.verification_status || null,
    review_decision: reviewReport.decision || null,
    acceptance_status: acceptance.status || null,
    accepted_by_human: acceptedByHuman,
    changed_files: asList(implementation.changed_files),
    created_artifact_files: asList(implementation.created_artifact_files),
    skipped_checks: asList(testReport.skipped_checks),
    blockers: asList(reviewReport.blockers),
    residual_risk: uniqueNormalized(displayResidualRisk),
    evidence_reviewed: asList(acceptance.evidence_reviewed),
    evidence_available: evidence,
    report_entry: reportEntry,
    report_entry_exists: reportEntryExists,
    missing_artifacts: missing,
    missing_report: options.requireReport && !reportEntryExists
      ? [reportEntry]
      : [],
    needs_human_acceptance: needsHumanAcceptance,
    confirmation_to_record: needsHumanAcceptance
      ? {
          target_file: rel(options.specsDir, artifacts['08-acceptance.md'].path),
          required_fields: [
            'accepted_by_human',
            'accepted_at',
            'accepted_scope',
            'evidence_reviewed',
            'residual_risk_accepted',
            'Gate G6 human_accepter',
          ],
        }
      : null,
  };
}

function isPendingAcceptanceRisk(item) {
  const text = String(item).toLowerCase();
  return (
    text.includes('pending human acceptance') ||
    text.includes('pending raymond') ||
    text.includes('final acceptance is not complete')
  );
}

function uniqueNormalized(items) {
  const seen = new Set();
  const result = [];
  for (const item of items) {
    const key = String(item).toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
    if (seen.has(key)) continue;
    seen.add(key);
    result.push(item);
  }
  return result;
}

function printList(items, fallback = 'None') {
  if (!items || items.length === 0) {
    console.log(`- ${fallback}`);
    return;
  }
  for (const item of items) {
    console.log(`- ${item}`);
  }
}

function printMarkdown(summary) {
  console.log(`# Acceptance Summary: ${summary.task_id}`);
  console.log('');
  console.log(`Goal: ${summary.goal || 'Unknown'}`);
  console.log(`Workflow: ${summary.selected_workflow || 'Unknown'}`);
  console.log(`Task class: ${summary.task_class || 'Unknown'}`);
  console.log(`Implementation: ${summary.implementation_status || 'Unknown'}`);
  console.log(`Scope reconciliation: ${summary.scope_reconciliation || 'Unknown'}`);
  console.log(`Verification: ${summary.verification_status || 'Unknown'}`);
  console.log(`Review decision: ${summary.review_decision || 'Unknown'}`);
  console.log(`Acceptance: ${summary.acceptance_status || 'Unknown'}`);
  console.log(`Accepted by: ${summary.accepted_by_human || 'Not recorded'}`);

  console.log('\n## Changed Files');
  printList(summary.changed_files);

  console.log('\n## Created Artifact Files');
  printList(summary.created_artifact_files);

  console.log('\n## Skipped Checks');
  printList(summary.skipped_checks);

  console.log('\n## Blockers');
  printList(summary.blockers);

  console.log('\n## Residual Risk');
  printList(summary.residual_risk);

  console.log('\n## Evidence Available');
  printList(summary.evidence_available);

  console.log('\n## Browsable Report');
  console.log(`- ${summary.report_entry}${summary.report_entry_exists ? '' : ' (missing)'}`);

  if (summary.missing_artifacts.length > 0) {
    console.log('\n## Missing Artifacts');
    printList(summary.missing_artifacts);
  }

  if (summary.missing_report.length > 0) {
    console.log('\n## Missing Report');
    printList(summary.missing_report);
    console.log('Run `scripts/generate-spec-report.mjs --specs-dir specs/records --report-dir specs/report` before requesting Human acceptance.');
  }

  console.log('\n## Human Confirmation');
  if (summary.needs_human_acceptance) {
    console.log(`A named Human acceptance is still required. Record confirmation in ${summary.confirmation_to_record.target_file}.`);
    console.log('Required fields:');
    printList(summary.confirmation_to_record.required_fields);
  } else {
    console.log(`Acceptance is already recorded for ${summary.accepted_by_human}.`);
  }
}

try {
  const options = parseArgs(process.argv.slice(2));
  const summary = summarize(options);
  if (options.json) {
    console.log(JSON.stringify(summary, null, 2));
  } else {
    printMarkdown(summary);
  }
  if (summary.missing_artifacts.length > 0 || summary.missing_report.length > 0) {
    process.exit(1);
  }
} catch (error) {
  console.error(`ERROR ${error.message}`);
  console.error('Run with --help for usage.');
  process.exit(2);
}
