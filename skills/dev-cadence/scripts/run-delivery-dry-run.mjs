#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

function printHelp() {
  console.log(`Usage: run-delivery-dry-run.mjs --task-id <task-id> --goal <goal> [options]

Creates a minimal Dev Cadence delivery dry run in an initialized repository.

Required:
  --task-id <id>          Task directory name under specs.
  --goal <text>           Requested task goal.

Options:
  --repo-dir <dir>        Target initialized repository. Defaults to current working directory.
  --skill-dir <dir>       Dev Cadence skill package directory. Defaults to parent directory.
  --run-id <id>           Harness run id. Defaults to <task-id>-dry-run-1.
  --requested-by <name>   Requesting Human name. Defaults to Unknown.
  --accepted-by <name>    Named Human accepter. If omitted, G6 remains blocked.
  --json                  Print machine-readable JSON report.
  -h, --help              Show this help text.

This script does not modify product files. It initializes artifacts and records a
dry-run evidence loop for route, artifact, scope, verification, review, and
acceptance behavior.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    repoDir: process.cwd(),
    skillDir: path.resolve(path.join(import.meta.dirname, '..')),
    taskId: null,
    runId: null,
    goal: null,
    requestedBy: 'Unknown',
    acceptedBy: null,
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--task-id') {
      options.taskId = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--goal') {
      options.goal = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--repo-dir') {
      options.repoDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--skill-dir') {
      options.skillDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--run-id') {
      options.runId = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--requested-by') {
      options.requestedBy = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--accepted-by') {
      options.acceptedBy = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  validateId('task-id', options.taskId);
  if (!options.goal) {
    throw new Error('Missing required --goal');
  }
  if (!options.runId) {
    options.runId = `${options.taskId}-dry-run-1`;
  }
  validateId('run-id', options.runId);

  options.repoDir = path.resolve(options.repoDir);
  options.skillDir = path.resolve(options.skillDir);
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

function readText(filePath) {
  return fs.readFileSync(filePath, 'utf8');
}

function writeText(filePath, text) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, text);
}

function assertInitialized(repoDir) {
  const required = [
    'AGENTS.md',
    '.ai/config.yaml',
    '.ai/local.yaml',
    '.ai/overrides',
    'specs',
  ];

  const missing = required.filter((item) => !fs.existsSync(path.join(repoDir, item)));
  if (missing.length > 0) {
    throw new Error(`Repository is not initialized with Dev Cadence thin contract: missing ${missing.join(', ')}`);
  }

  const agents = readText(path.join(repoDir, 'AGENTS.md'));
  if (!agents.includes('Dev Cadence plugin')) {
    throw new Error('Repository AGENTS.md does not route delivery to Dev Cadence');
  }
}

function inferWorkflow(goal) {
  const text = goal.toLowerCase();
  if (/\b(review|code review|pr|pull request|diff|patch)\b/.test(text)) {
    return ['code-review', 'Goal mentions review, PR, diff, or patch.'];
  }
  if (/\b(bug|fix|defect|broken|incorrect|regression|error|failure)\b/.test(text)) {
    return ['bugfix', 'Goal mentions bugfix or incorrect behavior.'];
  }
  if (/\b(refactor|cleanup|rename|restructure|reorganize)\b/.test(text)) {
    return ['refactor', 'Goal mentions refactor or structural cleanup.'];
  }
  if (/\b(research|compare|evaluate|feasibility|recommend|spike)\b/.test(text)) {
    return ['research-spike', 'Goal asks for research, comparison, or recommendation.'];
  }
  if (/\b(incident|outage|production|critical|urgent)\b/.test(text)) {
    return ['incident-fix', 'Goal mentions incident, production, critical, or urgent recovery.'];
  }
  return ['feature-dev', 'Defaulted to feature development for new or changed behavior.'];
}

function inferTaskClass(goal) {
  const text = goal.toLowerCase();
  if (/\b(incident|outage|production|critical|urgent)\b/.test(text)) return 'incident';
  if (/\b(research|compare|evaluate|feasibility|recommend|spike)\b/.test(text)) return 'research-spike';
  if (/\b(security|permission|secret|database|migration|ci|deploy|release|architecture|public api|cross-module)\b/.test(text)) return 'S2';
  if (text.length < 80 && /\b(text|typo|comment|docs?|readme)\b/.test(text)) return 'S0';
  return 'S1';
}

function today() {
  return new Date().toISOString().slice(0, 10);
}

function now() {
  return new Date().toISOString();
}

function yamlValue(value) {
  if (value === null || value === undefined) return 'null';
  if (Array.isArray(value)) {
    if (value.length === 0) return '[]';
    return `\n${value.map((item) => `  - ${item}`).join('\n')}`;
  }
  if (typeof value === 'boolean') return value ? 'true' : 'false';
  if (typeof value === 'number') return String(value);
  const stringValue = String(value).replaceAll('"', '\\"');
  if (!stringValue || /[:#\n\[\]{}]|^\s|\s$/.test(stringValue)) {
    return `"${stringValue}"`;
  }
  return stringValue;
}

function block(title, fields, body = '') {
  const yaml = Object.entries(fields)
    .map(([key, value]) => `${key}: ${yamlValue(value)}`)
    .join('\n');
  return `# ${title}\n\n\`\`\`yaml\n${yaml}\n\`\`\`\n${body ? `\n${body.trim()}\n` : ''}`;
}

function initArtifacts(options) {
  const script = path.join(options.skillDir, 'scripts', 'init-task-artifacts.mjs');
  const result = spawnSync(process.execPath, [
    script,
    '--task-id',
    options.taskId,
    '--run-id',
    options.runId,
    '--specs-dir',
    path.join(options.repoDir, 'specs'),
    '--skill-dir',
    options.skillDir,
    '--json',
  ], { encoding: 'utf8' });

  if (result.status !== 0) {
    throw new Error(`Artifact initialization failed: ${result.stderr || result.stdout}`);
  }

  return JSON.parse(result.stdout);
}

function writeArtifacts(options, workflow, selectionReason, taskClass, artifactReport) {
  const taskDir = path.join(options.repoDir, 'specs', options.taskId);
  const runDir = path.join(taskDir, 'runs', options.runId);
  const artifactFiles = [
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
  const runFiles = [
    'run-context.md',
    'execution-report.md',
    'tool-log.md',
    'test-log.md',
    'diff-summary.md',
    'permission-decisions.md',
  ];
  const artifactPaths = artifactFiles.map((file) => `specs/${options.taskId}/${file}`);
  const runPaths = runFiles.map((file) => `specs/${options.taskId}/runs/${options.runId}/${file}`);
  const acceptanceBlocked = !options.acceptedBy;
  const timestamp = now();

  writeText(path.join(taskDir, '00-brief.md'), block('Brief', {
    task_id: options.taskId,
    requested_by: options.requestedBy,
    date: today(),
    goal: options.goal,
    background: 'Delivery dry run generated by Dev Cadence runtime script.',
    constraints: ['No product files are changed by this dry run.'],
    initial_risks: ['Dry run evidence does not prove product behavior.'],
    assumptions: [],
    open_questions: acceptanceBlocked ? ['Final acceptance requires a named Human accepter.'] : [],
    workflow_hint: null,
    selected_workflow: workflow,
    selection_reason: selectionReason,
    task_class: taskClass,
  }, `## Notes

This artifact set validates Dev Cadence delivery routing and evidence generation. It is not a product implementation.

## Skipped States

- Product implementation was skipped by design for dry-run validation.`));

  writeText(path.join(taskDir, '01-requirements.md'), block('Requirements', {
    status: 'accepted_for_dry_run',
    goal: options.goal,
    scope: ['Validate delivery runtime artifact generation.'],
    non_goals: ['Modify product source files.', 'Claim real product behavior is verified.'],
    users_or_stakeholders: [options.requestedBy],
    acceptance_criteria: [
      'Task artifacts are generated from bundled templates.',
      'Harness run evidence is generated.',
      'Workflow and task class are inferred.',
      'Final acceptance blocks without a named Human accepter.',
    ],
    constraints: ['Dry run only.'],
    assumptions: [],
    open_questions: acceptanceBlocked ? ['Who is the named Human accepter?'] : [],
    human_decisions: options.acceptedBy ? [`accepted_by_human: ${options.acceptedBy}`] : [],
  }, `## Source Notes

Generated from CLI inputs and repo-local Dev Cadence thin contract.

## Ambiguity Check

\`\`\`yaml
unresolved_ambiguity: false
material_to_implementation: false
clarification_required: false
analysis_performed:
  - Checked initialized repo contract.
  - Inferred workflow and task class from goal text.
evidence_paths:
  - AGENTS.md
  - .ai/config.yaml
candidate_interpretations: []
recommended_option: ${workflow}
clarified_by_human: ${yamlValue(options.requestedBy)}
clarified_at: ${timestamp}
decision: dry_run_scope
\`\`\`

## Requirements Readiness Check

\`\`\`yaml
expected_behavior_explicit: true
expected_behavior_source: CLI --goal
reference_behavior_explicit: true
reference_behavior_source: Dev Cadence templates and references
scope_confirmed: true
non_goals_confirmed: true
acceptance_criteria_confirmed: true
verification_approach_confirmed: true
accepted_by_human: ${yamlValue(options.requestedBy)}
human_decision_reference: dry_run_cli_input
ready_for_implementation: true
blocking_questions: []
\`\`\`

## Gate G1

G1 is treated as passed for the dry-run scope only.`));

  writeText(path.join(taskDir, '02-design.md'), block('Design', {
    status: taskClass === 'S2' ? 'required_for_real_work' : 'not_required_for_dry_run',
    problem: 'Validate delivery runtime without product edits.',
    chosen_approach: 'Generate minimal artifacts and Harness evidence using bundled templates.',
    alternatives_considered: ['Manual artifact writing', 'Full product implementation'],
    architecture_constraints: ['Do not change product files.', 'Keep evidence explicit.'],
    affected_components: ['specs artifacts', 'Harness run artifacts'],
    data_or_control_flow: ['CLI input -> workflow inference -> template initialization -> artifact fill -> gate summary'],
    risks: ['Dry run cannot verify product behavior.'],
    required_adrs: [],
    human_decisions: [],
  }, `## Rationale

The dry run validates orchestration surfaces before real Worker execution.

## Gate G2

G2 is not required for this dry-run task unless real high-risk product work is added.`));

  writeText(path.join(taskDir, '03-tasks.md'), block('Tasks', {
    status: 'complete_for_dry_run',
    task_class: taskClass,
    selected_workflow: workflow,
    previous_task_class: null,
    task_class_change_reason: null,
    required_extra_gates: taskClass === 'S2' ? ['Human risk approval before real implementation'] : [],
    tasks: [
      'Initialize task and run artifacts.',
      'Record workflow and task class inference.',
      'Record dry-run implementation evidence.',
      'Record verification and review evidence.',
      'Block final acceptance when no named Human accepter is provided.',
    ],
    dependencies: ['Initialized Dev Cadence thin repo-local contract'],
    planned_components: ['specs artifact tree'],
    target_files: [],
    planned_artifact_files: artifactPaths,
    forbidden_actions: ['Modify product files', 'Claim product verification'],
    acceptance_mapping: ['All generated artifacts are listed in implementation and diff summary.'],
    verification_plan: ['Run check-spec-artifacts on the generated specs directory.'],
    verification_coverage_matrix: ['artifact_schema: covered', 'product_behavior: not_applicable'],
  }, `## Execution Notes

Executed as delivery runtime dry run.

## Gate G3

G3 passed for dry-run execution because tasks, artifacts, forbidden actions, and verification plan are explicit.`));

  writeText(path.join(taskDir, '04-test-plan.md'), block('Test Plan', {
    status: 'complete_for_dry_run',
    scope: ['Generated artifacts and run evidence'],
    test_strategy: ['Validate YAML-like artifact blocks with check-spec-artifacts.mjs'],
    test_commands: [`node ${path.relative(options.repoDir, path.join(options.skillDir, 'scripts', 'check-spec-artifacts.mjs'))} specs`],
    test_data: [`specs/${options.taskId}`],
    environment: ['local fixture repository'],
    coverage_targets: ['Task artifact schema', 'Harness evidence schema'],
    changed_component_coverage: ['No product components changed'],
    skipped_component_checks: ['Product behavior verification skipped by dry-run scope'],
    risks: ['Dry run can pass while product implementation remains untested.'],
  }, '## Planned Evidence\n\nGenerated artifacts plus checker command output.'));

  writeText(path.join(taskDir, '05-implementation.md'), block('Implementation', {
    status: 'dry_run_complete',
    planned_files: [],
    planned_artifact_files: artifactPaths,
    changed_files: [],
    created_artifact_files: [...artifactPaths, ...runPaths],
    unplanned_changed_files: [],
    deleted_files: [],
    added_components: [],
    scope_reconciliation: 'passed_no_product_changes',
    rationale: 'Validate delivery runtime artifact generation without product edits.',
    implementation_notes: ['Initialized artifacts and populated dry-run evidence.'],
    tdd_or_feedback_evidence: 'Not applicable to dry-run orchestration.',
    red_evidence: null,
    green_evidence: null,
    refactor_evidence: null,
    tdd_exception: 'No product behavior implemented.',
    substitute_feedback: ['Artifact checker used as validation feedback.'],
    test_commands: ['check-spec-artifacts on generated specs directory'],
    test_results: ['pending_until_checker_runs'],
    known_limitations: ['No product behavior is verified.'],
    follow_up_needed: ['Run real delivery workflow for product work.'],
  }, `## Diff Summary

No product files changed. Artifact initialization report created ${artifactReport.created.length} files and skipped ${artifactReport.skipped_existing.length} existing files.

## Harness Runs

- ${options.runId}`));

  writeText(path.join(taskDir, '06-test-report.md'), block('Test Report', {
    status: 'complete_for_dry_run',
    verification_status: 'partially_verified',
    commands_run: ['check-spec-artifacts on generated specs directory'],
    environment: ['local fixture repository'],
    results: ['Artifact structure is expected to be machine-checkable.'],
    coverage_scope: ['Artifact schema', 'Harness evidence schema'],
    changed_component_coverage: ['No product components changed'],
    skipped_component_checks: ['Product behavior verification'],
    defects: [],
    skipped_checks: ['Product tests were not run because dry run makes no product changes.'],
    residual_risk: ['Dry run evidence cannot prove product behavior.'],
    recommendation: acceptanceBlocked ? 'Block final acceptance until named Human accepts dry-run residual risk.' : 'Accept dry-run scope only.',
  }, `## Evidence

Run \`check-spec-artifacts.mjs\` against the repository specs directory.

## Gate G4

\`\`\`yaml
gate_id: G4
status: ${options.acceptedBy ? 'human_override_for_dry_run' : 'blocked_pending_human_acceptance'}
required_inputs:
  - 04-test-plan.md
  - 06-test-report.md
evidence:
  - specs/${options.taskId}
verification_status: partially_verified
component_coverage_complete: false
human_override: ${yamlValue(options.acceptedBy)}
residual_risk:
  - Product behavior is not verified.
escalation: ${acceptanceBlocked ? 'named Human acceptance required' : 'dry-run risk accepted by named Human'}
\`\`\``));

  writeText(path.join(taskDir, '07-review-report.md'), block('Review Report', {
    status: acceptanceBlocked ? 'blocked_pending_acceptance' : 'approved_for_dry_run_scope',
    review_scope: ['Generated dry-run artifacts', 'Harness evidence'],
    evidence_reviewed: [...artifactPaths, ...runPaths],
    scope_reconciliation_reviewed: true,
    verification_coverage_reviewed: true,
    findings: [],
    blockers: acceptanceBlocked ? ['Final acceptance requires a named Human accepter.'] : [],
    major_issues: [],
    minor_notes: ['Dry run does not verify product behavior.'],
    security_notes: [],
    architecture_notes: [],
    decision: acceptanceBlocked ? 'blocked' : 'approved_with_minor_notes',
    residual_risk: ['Product behavior remains unverified.'],
  }, `## Findings

No code findings because no product files changed.

## Gate G5

\`\`\`yaml
gate_id: G5
status: ${acceptanceBlocked ? 'blocked' : 'passed_for_dry_run_scope'}
required_inputs:
  - 06-test-report.md
  - 07-review-report.md
evidence:
  - specs/${options.taskId}
g4_status: ${options.acceptedBy ? 'human_override_for_dry_run' : 'blocked_pending_human_acceptance'}
scope_reconciliation_status: passed_no_product_changes
verification_coverage_status: product_behavior_not_applicable_to_dry_run
decision: ${acceptanceBlocked ? 'blocked' : 'approved_with_minor_notes'}
residual_risk:
  - Product behavior is not verified.
escalation: ${acceptanceBlocked ? 'named Human acceptance required' : 'none'}
\`\`\``));

  writeText(path.join(taskDir, '08-acceptance.md'), block('Acceptance', {
    status: acceptanceBlocked ? 'blocked_pending_named_human' : 'accepted_for_dry_run_scope',
    accepted_by_human: options.acceptedBy,
    accepted_at: options.acceptedBy ? timestamp : null,
    accepted_scope: options.acceptedBy ? ['Delivery runtime dry-run artifacts only'] : [],
    evidence_reviewed: options.acceptedBy ? [...artifactPaths, ...runPaths] : [],
    human_gate_decisions: options.acceptedBy ? [`${options.acceptedBy} accepted dry-run residual risk.`] : [],
    residual_risk_accepted: options.acceptedBy ? ['Product behavior not verified by dry run.'] : [],
    merge_or_release_decision: 'not_applicable',
    follow_up: ['Use real delivery workflow for product implementation.'],
  }, `## Gate G6

\`\`\`yaml
gate_id: G6
status: ${acceptanceBlocked ? 'blocked' : 'passed_for_dry_run_scope'}
required_inputs:
  - 08-acceptance.md
evidence:
  - specs/${options.taskId}
human_accepter: ${yamlValue(options.acceptedBy)}
decision: ${acceptanceBlocked ? 'blocked_pending_named_human' : 'accepted_for_dry_run_scope'}
residual_risk:
  - Product behavior is not verified.
escalation: ${acceptanceBlocked ? 'named Human acceptance required' : 'none'}
\`\`\``));

  writeText(path.join(runDir, 'run-context.md'), block('Run Context', {
    run_id: options.runId,
    task_id: options.taskId,
    agent_role: 'Supervisor',
    blueprint_path: 'references/supervisor-state-machine.md',
    context_pack_path: `specs/${options.taskId}/00-brief.md`,
    workspace_path: rel(options.repoDir, options.repoDir),
    allowed_read_paths: ['AGENTS.md', '.ai/config.yaml', '.ai/overrides/**', 'specs/**'],
    allowed_write_paths: [`specs/${options.taskId}/**`],
    denied_paths: ['product source files'],
    allowed_tools: ['node', 'filesystem writes under specs'],
    denied_tools: ['network', 'production actions', 'database writes'],
    network_policy: 'disabled',
    secret_policy: 'do_not_request_or_record_secrets',
    permission_policy: 'no elevated permissions required',
    budget: 'local dry run',
    timeout: 'not enforced',
    max_iterations: 1,
    required_evidence: runPaths,
    expected_artifacts: artifactPaths,
    log_paths: runPaths,
  }));

  writeText(path.join(runDir, 'execution-report.md'), block('Execution Report', {
    run_id: options.runId,
    task_id: options.taskId,
    agent_role: 'Supervisor',
    state: 'delivery_dry_run',
    started_at: timestamp,
    ended_at: timestamp,
    inputs: ['CLI goal', 'repo-local Dev Cadence thin contract'],
    outputs: [...artifactPaths, ...runPaths],
    planned_files: [],
    planned_artifact_files: artifactPaths,
    files_changed: [],
    created_artifact_files: [...artifactPaths, ...runPaths],
    unplanned_changed_files: [],
    deleted_files: [],
    added_components: [],
    scope_reconciliation_status: 'passed_no_product_changes',
    commands_run: ['init-task-artifacts.mjs'],
    tests_run: ['check-spec-artifacts.mjs should be run after generation'],
    verification_status: 'partially_verified',
    permissions_requested: [],
    permissions_granted: [],
    permissions_denied: [],
    skipped_checks: ['Product tests skipped; dry run has no product implementation.'],
    errors: [],
    residual_risk: ['Product behavior is unverified.'],
    handoff_target: acceptanceBlocked ? 'Human Gate G6' : 'Done for dry-run scope',
  }));

  writeText(path.join(runDir, 'tool-log.md'), block('Tool Log', {
    run_id: options.runId,
    commands_or_tools: ['init-task-artifacts.mjs', 'run-delivery-dry-run.mjs'],
    outputs: ['Task artifacts populated.', 'Harness run evidence populated.'],
    errors: [],
    omissions: ['No product tool execution.'],
  }));

  writeText(path.join(runDir, 'test-log.md'), block('Test Log', {
    run_id: options.runId,
    commands: ['check-spec-artifacts.mjs specs'],
    environment: ['local fixture repository'],
    results: ['pending_external_command_capture'],
    failures: [],
    skipped: ['Product test suite skipped by dry-run scope.'],
  }));

  writeText(path.join(runDir, 'diff-summary.md'), block('Diff Summary', {
    run_id: options.runId,
    planned_files: [],
    planned_artifact_files: artifactPaths,
    files_changed: [],
    created_artifact_files: [...artifactPaths, ...runPaths],
    unplanned_changed_files: [],
    deleted_files: [],
    added_components: [],
    scope_reconciliation_status: 'passed_no_product_changes',
    behavior_changes: [],
    non_behavior_changes: ['Generated delivery dry-run artifacts.'],
    risk_notes: ['No product behavior verified.'],
  }));

  writeText(path.join(runDir, 'permission-decisions.md'), block('Permission Decisions', {
    run_id: options.runId,
    requests: [],
    decisions: [],
    denials: [],
    conditions: ['No elevated permissions requested.'],
    residual_risk: [],
  }));

  return { artifact_paths: artifactPaths, run_paths: runPaths, acceptance_blocked: acceptanceBlocked };
}

function run(options) {
  if (!fs.existsSync(options.repoDir)) {
    throw new Error(`Repository directory not found: ${options.repoDir}`);
  }
  assertInitialized(options.repoDir);

  const [workflow, selectionReason] = inferWorkflow(options.goal);
  const taskClass = inferTaskClass(options.goal);
  const artifactReport = initArtifacts(options);
  const writeReport = writeArtifacts(options, workflow, selectionReason, taskClass, artifactReport);

  return {
    task_id: options.taskId,
    run_id: options.runId,
    repository: options.repoDir,
    selected_workflow: workflow,
    selection_reason: selectionReason,
    task_class: taskClass,
    artifact_report: artifactReport,
    artifact_paths: writeReport.artifact_paths,
    run_paths: writeReport.run_paths,
    acceptance_status: writeReport.acceptance_blocked ? 'blocked_pending_named_human' : 'accepted_for_dry_run_scope',
    verification_status: 'partially_verified',
    scope_reconciliation_status: 'passed_no_product_changes',
    next_steps: writeReport.acceptance_blocked
      ? ['Provide --accepted-by <name> only when a named Human accepts dry-run residual risk.']
      : ['Dry-run scope accepted; use real delivery workflow for product implementation.'],
  };
}

function printReport(report) {
  console.log(`Task: ${report.task_id}`);
  console.log(`Run: ${report.run_id}`);
  console.log(`Workflow: ${report.selected_workflow}`);
  console.log(`Task class: ${report.task_class}`);
  console.log(`Acceptance: ${report.acceptance_status}`);
  console.log(`Verification: ${report.verification_status}`);
  console.log(`Scope reconciliation: ${report.scope_reconciliation_status}`);
  console.log('\nArtifacts:');
  for (const item of report.artifact_paths) console.log(`- ${item}`);
  console.log('\nRun evidence:');
  for (const item of report.run_paths) console.log(`- ${item}`);
  console.log('\nNext steps:');
  for (const item of report.next_steps) console.log(`- ${item}`);
}

try {
  const options = parseArgs(process.argv.slice(2));
  const report = run(options);
  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    printReport(report);
  }
} catch (error) {
  console.error(`ERROR ${error.message}`);
  console.error('Run with --help for usage.');
  process.exit(2);
}
