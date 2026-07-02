#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {
  markdownSection,
  parseTopLevelYaml,
  readArtifactData,
  readGateData,
} from './markdown-artifacts.mjs';
import { normalizeSpecsDir, resolveDefaultSpecsDir } from './specs-paths.mjs';

const SPEC_FILES = {
  brief: '00-brief.md',
  requirements: '01-requirements.md',
  design: '02-design.md',
  researchReport: 'research-report.md',
  tasks: '03-tasks.md',
  implementation: '05-implementation.md',
  testReport: '06-test-report.md',
  reviewReport: '07-review-report.md',
  acceptance: '08-acceptance.md',
};

function printHelp() {
  console.log(`Usage: check-gates.mjs --task-id <task-id> [options]

Validates Dev Cadence Quality Gate and Human Gate state for one task.

Required:
  --task-id <id>       Task directory name under the specs directory.

Options:
  --specs-dir <dir>    Specs records directory. Defaults to specs/records,
                       or legacy specs when it already contains task dirs.
  --allow-pending-acceptance
                       Report missing final Human acceptance without failing.
                       Use only when the Human explicitly asks to proceed
                       without accepting the result.
  --json               Print machine-readable JSON.
  -h, --help           Show this help text.

The checker is read-only. It does not write acceptance or approve gates.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    specsDir: resolveDefaultSpecsDir(),
    taskId: null,
    allowPendingAcceptance: false,
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
    } else if (arg === '--allow-pending-acceptance') {
      options.allowPendingAcceptance = true;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  validateId('task-id', options.taskId);
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

function readArtifact(taskDir, fileName, specsDir) {
  const filePath = path.join(taskDir, fileName);
  if (!fs.existsSync(filePath)) {
    return { fileName, path: filePath, relativePath: rel(specsDir, filePath), exists: false, data: {}, text: '' };
  }
  const text = fs.readFileSync(filePath, 'utf8');
  return {
    fileName,
    path: filePath,
    relativePath: rel(specsDir, filePath),
    exists: true,
    data: readArtifactData(text),
    text,
  };
}

function readGate(artifact, gateId) {
  if (!artifact.exists) return {};
  return readGateData(artifact.text, gateId);
}

function asList(value) {
  if (Array.isArray(value)) return value;
  if (value === null || value === undefined || value === '') return [];
  return [value];
}

function nonEmpty(value) {
  if (Array.isArray(value)) return value.length > 0;
  if (value === null || value === undefined) return false;
  if (typeof value === 'boolean') return value;
  return String(value).trim() !== '';
}

function boolTrue(value) {
  return value === true || String(value).toLowerCase() === 'true';
}

function gatePassed(gate) {
  return String(gate.status || '').toLowerCase() === 'passed';
}

function hasNamedHuman(value) {
  if (!nonEmpty(value)) return false;
  if (typeof value === 'boolean') return false;
  const text = String(value).trim().toLowerCase();
  return ![
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

function hasHumanOverride(gate) {
  return hasNamedHuman(gate.human_override) || hasNamedHuman(gate.human_accepter);
}

function recordGate(result, gateId, status, evidence = []) {
  result.gates[gateId] = {
    status,
    evidence,
  };
}

function fail(result, gateId, message, evidence = []) {
  result.failures.push({ gate_id: gateId, message, evidence });
  if (!result.gates[gateId]) {
    recordGate(result, gateId, 'failed', evidence);
  }
}

function warn(result, gateId, message, evidence = []) {
  result.warnings.push({ gate_id: gateId, message, evidence });
  if (!result.gates[gateId]) {
    recordGate(result, gateId, 'warning', evidence);
  }
}

function requiredFilesFor(taskClass) {
  if (taskClass === 'S0') {
    return ['brief', 'implementation', 'testReport', 'acceptance'];
  }
  if (taskClass === 'S1') {
    return ['brief', 'requirements', 'tasks', 'implementation', 'testReport', 'reviewReport', 'acceptance'];
  }
  if (taskClass === 'S2') {
    return ['brief', 'requirements', 'design', 'tasks', 'implementation', 'testReport', 'reviewReport', 'acceptance'];
  }
  if (taskClass === 'incident') {
    return ['brief', 'implementation', 'testReport', 'reviewReport', 'acceptance'];
  }
  if (taskClass === 'research-spike') {
    return ['brief', 'requirements', 'researchReport', 'acceptance'];
  }
  return ['brief', 'implementation', 'testReport', 'acceptance'];
}

function runDirectories(taskDir) {
  const runsDir = path.join(taskDir, 'runs');
  if (!fs.existsSync(runsDir)) return [];
  return fs.readdirSync(runsDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => path.join(runsDir, entry.name));
}

function runEvidenceFiles(runDir) {
  return [
    'run-context.md',
    'execution-report.md',
    'tool-log.md',
    'permission-decisions.md',
  ].map((name) => path.join(runDir, name));
}

function implementationEvidencePresent(implementation) {
  return nonEmpty(implementation.status)
    || asList(implementation.changed_files).length > 0
    || asList(implementation.created_artifact_files).length > 0;
}

function productChanged(implementation) {
  return asList(implementation.changed_files).length > 0
    || asList(implementation.deleted_files).length > 0
    || asList(implementation.unplanned_changed_files).length > 0;
}

function checkRequiredArtifacts(result, artifacts, taskClass) {
  for (const key of requiredFilesFor(taskClass)) {
    const artifact = artifacts[key];
    if (!artifact || !artifact.exists) {
      fail(result, 'artifacts', `Missing required artifact ${SPEC_FILES[key]}`, artifact ? [artifact.relativePath] : []);
    }
  }
}

function checkHarnessEvidence(result, taskDir, taskClass, implementation, specsDir) {
  if (!['S1', 'S2'].includes(taskClass)) return;
  if (!implementationEvidencePresent(implementation)) return;

  const runs = runDirectories(taskDir);
  if (runs.length === 0) {
    fail(result, 'G4', 'S1/S2 implementation evidence requires at least one Harness run directory');
    return;
  }

  for (const runDir of runs) {
    for (const filePath of runEvidenceFiles(runDir)) {
      if (!fs.existsSync(filePath)) {
        fail(result, 'G4', `Missing Harness evidence ${rel(specsDir, filePath)}`, [rel(specsDir, filePath)]);
      }
    }
    if (productChanged(implementation)) {
      const baselinePath = path.join(runDir, 'pre-implementation-status.md');
      if (!fs.existsSync(baselinePath)) {
        fail(result, 'G4', `Missing pre-implementation baseline ${rel(specsDir, baselinePath)}`, [rel(specsDir, baselinePath)]);
      } else {
        const baseline = readArtifactData(fs.readFileSync(baselinePath, 'utf8'));
        if (!boolTrue(baseline.implementation_authorized)) {
          fail(result, 'G4', `${rel(specsDir, baselinePath)} must set implementation_authorized: true`, [rel(specsDir, baselinePath)]);
        }
        if (boolTrue(baseline.post_hoc_backfill) && !hasNamedHuman(baseline.post_hoc_human_override_by)) {
          fail(result, 'G4', `${rel(specsDir, baselinePath)} post_hoc_backfill requires named Human override`, [rel(specsDir, baselinePath)]);
        }
      }
    }
  }
}

function checkG1(result, artifacts, taskClass) {
  if (!['S1', 'S2'].includes(taskClass)) {
    recordGate(result, 'G1', 'skipped', ['not required for task class']);
    return;
  }

  const readiness = parseReadiness(artifacts.requirements.text);
  const gate = readGate(artifacts.requirements, 'G1');
  const evidence = [artifacts.requirements.relativePath];

  if (!artifacts.requirements.exists) {
    fail(result, 'G1', 'Missing requirements artifact', evidence);
    return;
  }
  if (!boolTrue(readiness.ready_for_implementation)) {
    fail(result, 'G1', 'Requirements Readiness Check must set ready_for_implementation: true', evidence);
  }
  if (!hasNamedHuman(readiness.accepted_by_human)) {
    fail(result, 'G1', 'Requirements Readiness Check must name accepted_by_human', evidence);
  }
  if (asList(readiness.blocking_questions).length > 0) {
    fail(result, 'G1', 'Requirements Readiness Check has blocking_questions', evidence);
  }
  if (!gatePassed(gate)) {
    fail(result, 'G1', 'Gate G1 must have status: passed', evidence);
  }
  if (!result.failures.some((failure) => failure.gate_id === 'G1')) {
    recordGate(result, 'G1', 'passed', evidence);
  }
}

function parseReadiness(text) {
  const pattern = /^##\s+Requirements Readiness Check\b[\s\S]*?```ya?ml\n([\s\S]*?)```/im;
  const match = text.match(pattern);
  const yaml = parseTopLevelYaml(match ? match[1] : '');
  const section = markdownSection(text, 'Requirements Readiness Check\\b');
  return { ...yaml, ...readArtifactData(section) };
}

function checkG2(result, artifacts, taskClass) {
  if (taskClass !== 'S2') {
    recordGate(result, 'G2', 'skipped', ['not required for task class']);
    return;
  }
  const gate = readGate(artifacts.design, 'G2');
  const evidence = [artifacts.design.relativePath];
  if (!artifacts.design.exists) {
    fail(result, 'G2', 'S2 work requires design artifact', evidence);
    return;
  }
  if (!gatePassed(gate) && !hasHumanOverride(gate)) {
    fail(result, 'G2', 'S2 Gate G2 must pass or name a Human override', evidence);
  } else {
    recordGate(result, 'G2', 'passed', evidence);
  }
}

function checkG3(result, artifacts, taskClass) {
  if (!['S1', 'S2'].includes(taskClass)) {
    recordGate(result, 'G3', 'skipped', ['not required for task class']);
    return;
  }
  const gate = readGate(artifacts.tasks, 'G3');
  const evidence = [artifacts.tasks.relativePath];
  if (!artifacts.tasks.exists) {
    fail(result, 'G3', 'Missing tasks artifact', evidence);
    return;
  }
  const taskStatus = artifacts.tasks.data.status;
  const verificationPlan = asList(artifacts.tasks.data.verification_plan);
  if (!nonEmpty(taskStatus)) {
    fail(result, 'G3', 'Tasks artifact must record status', evidence);
  }
  if (verificationPlan.length === 0) {
    fail(result, 'G3', 'Tasks artifact must include verification_plan', evidence);
  }
  if (asList(artifacts.implementation.data.unplanned_changed_files).length > 0) {
    fail(result, 'G3', 'Implementation artifact has unplanned_changed_files; update scope/tasks or record a named Human decision before gates can pass', [artifacts.implementation.relativePath]);
  }
  if (!gatePassed(gate)) {
    fail(result, 'G3', 'Gate G3 must have status: passed', evidence);
  }
  if (!result.failures.some((failure) => failure.gate_id === 'G3')) {
    recordGate(result, 'G3', 'passed', evidence);
  }
}

function checkG4(result, artifacts, taskClass) {
  if (taskClass === 'research-spike') {
    recordGate(result, 'G4', 'skipped', ['not required for research-spike']);
    return;
  }

  const gate = readGate(artifacts.testReport, 'G4');
  const evidence = [artifacts.testReport.relativePath];
  if (!artifacts.testReport.exists) {
    fail(result, 'G4', 'Missing test report artifact', evidence);
    return;
  }

  const verified = artifacts.testReport.data.verification_status === 'verified';
  const overridden = hasHumanOverride(gate);
  if (!verified && !overridden) {
    fail(result, 'G4', 'Verification status must be verified or Gate G4 must name a Human override', evidence);
  }
  if (!gatePassed(gate)) {
    fail(result, 'G4', 'Gate G4 must have status: passed', evidence);
  }
  if (!result.failures.some((failure) => failure.gate_id === 'G4')) {
    recordGate(result, 'G4', 'passed', evidence);
  }
}

function checkG5(result, artifacts, taskClass) {
  if (taskClass === 'research-spike') {
    recordGate(result, 'G5', 'skipped', ['not required for research-spike']);
    return;
  }

  const gate = readGate(artifacts.reviewReport, 'G5');
  const evidence = [artifacts.reviewReport.relativePath];
  if (!artifacts.reviewReport.exists) {
    fail(result, 'G5', 'Missing review report artifact', evidence);
    return;
  }
  if (!['approved', 'approved_with_minor_notes'].includes(String(artifacts.reviewReport.data.decision || ''))) {
    fail(result, 'G5', 'Review decision must be approved or approved_with_minor_notes', evidence);
  }
  if (asList(artifacts.reviewReport.data.blockers).length > 0) {
    fail(result, 'G5', 'Review report still has blockers', evidence);
  }
  if (asList(artifacts.reviewReport.data.major_issues).length > 0) {
    fail(result, 'G5', 'Review report still has major_issues', evidence);
  }
  if (!gatePassed(gate)) {
    fail(result, 'G5', 'Gate G5 must have status: passed', evidence);
  }
  if (!result.failures.some((failure) => failure.gate_id === 'G5')) {
    recordGate(result, 'G5', 'passed', evidence);
  }
}

function checkG6(result, artifacts, allowPendingAcceptance) {
  const gate = readGate(artifacts.acceptance, 'G6');
  const evidence = [artifacts.acceptance.relativePath];
  if (!artifacts.acceptance.exists) {
    fail(result, 'G6', 'Missing acceptance artifact', evidence);
    return;
  }

  const acceptedBy = artifacts.acceptance.data.accepted_by_human || gate.human_accepter;
  const accepted = hasNamedHuman(acceptedBy) && gatePassed(gate);
  if (!accepted && allowPendingAcceptance) {
    warn(result, 'G6', 'Final Human acceptance is pending; continuing only because --allow-pending-acceptance was supplied', evidence);
    result.pending_acceptance = true;
    return;
  }
  if (!hasNamedHuman(acceptedBy)) {
    fail(result, 'G6', 'Acceptance must name accepted_by_human or Gate G6 human_accepter', evidence);
  }
  if (!gatePassed(gate)) {
    fail(result, 'G6', 'Gate G6 must have status: passed', evidence);
  }
  if (!result.failures.some((failure) => failure.gate_id === 'G6')) {
    recordGate(result, 'G6', 'passed', evidence);
  }
}

function summarize(options) {
  const taskDir = path.join(options.specsDir, options.taskId);
  if (!fs.existsSync(taskDir)) {
    throw new Error(`Task artifacts not found: ${taskDir}`);
  }

  const artifacts = Object.fromEntries(
    Object.entries(SPEC_FILES).map(([key, fileName]) => [key, readArtifact(taskDir, fileName, options.specsDir)]),
  );
  const taskClass = String(artifacts.tasks.data.task_class || artifacts.brief.data.task_class || '').trim();
  const workflow = String(artifacts.tasks.data.selected_workflow || artifacts.brief.data.selected_workflow || '').trim();
  const result = {
    task_id: options.taskId,
    task_dir: rel(options.specsDir, taskDir),
    task_class: taskClass || null,
    selected_workflow: workflow || null,
    status: 'passed',
    pending_acceptance: false,
    gates: {},
    failures: [],
    warnings: [],
  };

  checkRequiredArtifacts(result, artifacts, taskClass);
  checkG1(result, artifacts, taskClass);
  checkG2(result, artifacts, taskClass);
  checkG3(result, artifacts, taskClass);
  checkHarnessEvidence(result, taskDir, taskClass, artifacts.implementation.data, options.specsDir);
  checkG4(result, artifacts, taskClass);
  checkG5(result, artifacts, taskClass);
  checkG6(result, artifacts, options.allowPendingAcceptance);

  if (result.failures.length > 0) {
    result.status = 'failed';
  } else if (result.pending_acceptance) {
    result.status = 'pending_acceptance';
  }
  return result;
}

function printText(result) {
  console.log(`Task: ${result.task_id}`);
  console.log(`Class: ${result.task_class || 'unknown'}`);
  console.log(`Workflow: ${result.selected_workflow || 'unknown'}`);
  console.log(`Gate status: ${result.status}`);
  for (const [gateId, gate] of Object.entries(result.gates)) {
    console.log(`${gateId}: ${gate.status}`);
  }
  for (const warning of result.warnings) {
    console.error(`WARN ${warning.gate_id}: ${warning.message}`);
  }
  for (const failure of result.failures) {
    console.error(`FAIL ${failure.gate_id}: ${failure.message}`);
  }
}

try {
  const options = parseArgs(process.argv.slice(2));
  const result = summarize(options);
  if (options.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    printText(result);
  }
  if (result.failures.length > 0) {
    process.exit(1);
  }
} catch (error) {
  console.error(`ERROR ${error.message}`);
  console.error('Run with --help for usage.');
  process.exit(2);
}
