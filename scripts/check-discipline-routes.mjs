#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

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
  'cadence-request-code-review',
  'cadence-code-review',
  'cadence-verify',
  'cadence-sync',
];

function printHelp() {
  console.log(`Usage: check-discipline-routes.mjs [plugin-dir]

Validates Dev Cadence discipline routing and bundled resource references.

Arguments:
  plugin-dir  dev-cadence source directory to check. Defaults to the parent directory
              of this script.

Checks:
  - referenced references/, templates/, and scripts/ paths exist
  - delivery-disciplines.md routes to required discipline references
  - required prompt templates exist and are referenced
  - visual companion resources exist and are indexed
  - entrypoint skills reference required shared resources
  - using-dev-cadence preserves Supervisor sequencing rules
  - concrete cadence skills return control to using-dev-cadence`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

const pluginDir = path.resolve(process.argv[2] || path.join(import.meta.dirname, '..'));
const embeddedRuntime = fs.existsSync(path.join(pluginDir, 'manifest.json')) &&
  fs.existsSync(path.join(pluginDir, 'VERSION')) &&
  !fs.existsSync(path.join(pluginDir, '.codex-plugin'));
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
    if (embeddedRuntime && referencedPath.startsWith('references/source-maintenance/')) {
      continue;
    }
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
    'planning-discipline.md',
    'implementation-discipline.md',
    'execution-orchestration.md',
    'debugging-discipline.md',
    'review-discipline.md',
    'verification-discipline.md',
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

  const skillLocalRoutes = [
    'skills/cadence-clarify/visual-companion.md',
    'skills/cadence-tdd/SKILL.md',
    'skills/cadence-tdd/testing-anti-patterns.md',
    'skills/cadence-verify/SKILL.md',
    'skills/cadence-debug/SKILL.md',
    'skills/cadence-debug/root-cause-tracing.md',
    'skills/cadence-debug/condition-based-waiting.md',
    'skills/cadence-debug/defense-in-depth.md',
  ];
  for (const relativePath of skillLocalRoutes) {
    if (!text.includes(relativePath)) {
      fail(`${sourceFile}: missing required route to ${relativePath}`);
    }
    if (!exists(relativePath)) {
      fail(`${sourceFile}: route target missing: ${relativePath}`);
    }
  }

  const sourceOnlyRequired = [
    'references/source-maintenance/authoring-discipline.md',
    'references/source-maintenance/skill-pressure-testing.md',
  ];
  if (embeddedRuntime) {
    for (const relativePath of sourceOnlyRequired) {
      if (exists(relativePath)) {
        fail(`${sourceFile}: source-maintenance reference must not be bundled in embedded runtime: ${relativePath}`);
      }
      if (text.includes(relativePath)) {
        fail(`${sourceFile}: source-maintenance route must not be bundled in embedded runtime: ${relativePath}`);
      }
    }
  } else {
    for (const relativePath of sourceOnlyRequired) {
      if (!text.includes(relativePath)) {
        fail(`${sourceFile}: missing source-maintenance route to ${relativePath}`);
      }
      if (!exists(relativePath)) {
        fail(`${sourceFile}: source-maintenance route target missing: ${relativePath}`);
      }
    }
  }
}

function checkSourceMaintenanceContract() {
  if (embeddedRuntime) return;

  const sourceFile = 'references/source-maintenance/authoring-discipline.md';
  const text = readText(sourceFile);
  const required = [
    'parity or reference-derived content preserves file-level structure and',
    'behavioral force, not just topic coverage',
    'anti-patterns, gate functions, examples, red flags, quick references',
    'visual markers such as `✅ GOOD` / `❌ BAD` are retained',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing source maintenance contract phrase: ${phrase}`);
    }
  }
}

function checkPromptTemplates() {
  const required = [
    'skills/cadence-clarify/spec-document-reviewer-prompt.md',
    'skills/cadence-request-code-review/spec-compliance-reviewer.md',
    'skills/cadence-request-code-review/code-quality-reviewer.md',
    'skills/cadence-request-code-review/code-reviewer.md',
    'skills/cadence-plan/plan-document-reviewer.md',
    'templates/prompts/implementer.md',
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
    'skills/cadence-plan/SKILL.md',
  ];
  const combined = refs.map(readText).join('\n');
  const referencedRequired = required.filter((relativePath) => !relativePath.startsWith('skills/cadence-clarify/'));
  for (const relativePath of referencedRequired) {
    if (!combined.includes(relativePath)) {
      fail(`prompt template is not referenced by discipline or blueprint: ${relativePath}`);
    }
  }
  const clarifySkill = readText('skills/cadence-clarify/SKILL.md');
  if (!combined.includes('skills/cadence-clarify/spec-document-reviewer-prompt.md') && !clarifySkill.includes('spec-document-reviewer-prompt.md')) {
    fail('skills/cadence-clarify/spec-document-reviewer-prompt.md: missing reference from clarify discipline or skill');
  }
}

function checkArtifactTemplates() {
  const required = [
    'templates/spec/00-brief.md',
    'templates/spec/01-requirements.md',
    'templates/spec/02-design.md',
    'templates/spec/research-report.md',
    'templates/spec/03-tasks.md',
    'templates/spec/04-test-plan.md',
    'templates/spec/05-implementation.md',
    'templates/spec/06-test-report.md',
    'templates/spec/07-review-report.md',
    'templates/spec/08-acceptance.md',
    'templates/runs/run-context.md',
    'templates/runs/pre-implementation-status.md',
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

  const tasksTemplate = readText('templates/spec/03-tasks.md');
  const taskTemplateRequired = [
    'For Dev Cadence Workers:',
    '### Task N:',
    '**Files:**',
    '**Interfaces:**',
    '- [ ] **Step 1: Write the failing test or characterization**',
    'Example only — replace with this repository\'s language and test framework:',
    '- [ ] **Step 2: Run test to verify it fails**',
    '- [ ] **Step 3: Write minimal implementation**',
    'Example only — replace with this repository\'s language and implementation style:',
    '- [ ] **Step 4: Run test to verify it passes**',
  ];
  for (const phrase of taskTemplateRequired) {
    if (!tasksTemplate.includes(phrase)) {
      fail(`templates/spec/03-tasks.md: missing Markdown task template phrase: ${phrase}`);
    }
  }
}

function checkVisualCompanionScripts() {
  const required = [
    'skills/cadence-clarify/visual-companion.md',
    'skills/cadence-clarify/scripts/start-server.sh',
    'skills/cadence-clarify/scripts/stop-server.sh',
    'skills/cadence-clarify/scripts/server.cjs',
    'skills/cadence-clarify/scripts/helper.js',
    'skills/cadence-clarify/scripts/frame-template.html',
  ];

  for (const relativePath of required) {
    if (!exists(relativePath)) {
      fail(`missing visual companion resource: ${relativePath}`);
    }
  }

  const visualRef = readText('skills/cadence-clarify/visual-companion.md');
  for (const relativePath of required.slice(1)) {
    const skillLocalPath = relativePath.replace('skills/cadence-clarify/', '');
    if (!visualRef.includes(relativePath) && !visualRef.includes(skillLocalPath)) {
      fail(`skills/cadence-clarify/visual-companion.md: missing script reference ${relativePath}`);
    }
  }

  const requiredText = [
    '--open',
    '--foreground',
    'do not use --background for user URLs',
    "curl --noproxy '*' -sS -D - <url>",
    '.dev-cadence/visual-companion/',
    'devCadenceVisual',
    '$STATE_DIR/server-info',
    '$STATE_DIR/events',
  ];
  for (const text of requiredText) {
    if (!visualRef.includes(text)) {
      fail(`skills/cadence-clarify/visual-companion.md: missing visual companion guidance '${text}'`);
    }
  }

  const clarifySkill = readText('skills/cadence-clarify/SKILL.md');
  if (!clarifySkill.includes("I'll open it for you")) {
    fail('skills/cadence-clarify/SKILL.md: visual companion offer must preserve auto-open behavior');
  }
  if (!clarifySkill.includes('start the server with `--open`; still give them the returned URL as a fallback')) {
    fail('skills/cadence-clarify/SKILL.md: visual companion offer must require URL fallback');
  }
}

function checkEntrypointReferenceMap() {
  const skillText = EXPECTED_SKILLS.map((name) => readText(`skills/${name}/SKILL.md`)).join('\n');
  const expected = [
    'references/delivery-disciplines.md',
    'references/repository-rule-sync.md',
    'references/skill-layout.md',
    'references/harness.md',
    'references/quality-gates.md',
    'references/human-gates.md',
    'scripts/check-gates.mjs',
    'scripts/check-before-commit.mjs',
  ];
  for (const item of expected) {
    if (!skillText.includes(item)) {
      fail(`entrypoint skills: missing reference to ${item}`);
    }
  }
}
function checkEntrypointSkills() {
  const required = EXPECTED_SKILLS.map((name) => `skills/${name}/SKILL.md`);

  for (const relativePath of required) {
    if (!exists(relativePath)) {
      fail(`missing entrypoint skill resource: ${relativePath}`);
    }
  }

  const layoutText = readText('references/skill-layout.md');
  for (const skillName of EXPECTED_SKILLS) {
    if (!layoutText.includes(`${skillName}/`) && !layoutText.includes(`\`${skillName}\``)) {
      fail(`references/skill-layout.md: missing target entrypoint ${skillName}`);
    }
  }
}

function checkUsingDevCadenceContract() {
  const sourceFile = 'skills/using-dev-cadence/SKILL.md';
  const text = readText(sourceFile);
  const required = [
    'Supervisor entrypoint',
    '## Worker Dispatch Boundary',
    'If you were dispatched by a Dev Cadence Supervisor or Harness as a Worker',
    'do not start a new Supervisor workflow unless the Worker prompt explicitly asks you to.',
    'This boundary prevents nested Supervisors from overriding the controller that dispatched the Worker.',
    '## Control Rule',
    'Before any response or action for software delivery work',
    'If there is even a small chance a cadence Skill applies',
    'If a cadence Skill applies to the task, using it is mandatory.',
    'not something to rationalize away because the task looks small or urgent.',
    'before answering, asking clarification questions, reading files, running commands, or editing code.',
    '## Instruction Priority',
    'explicit user instructions, repository instructions, and direct constraints',
    'Dev Cadence Supervisor, Harness, Quality Gate, Human Gate, and cadence Skill rules',
    '## Skill Activation',
    "Use the host platform's Skill activation mechanism when available.",
    'Do not treat manually reading a `SKILL.md` file as equivalent to activating an applicable Skill.',
    'On platforms where reading `SKILL.md` is the documented activation mechanism, use the platform\'s required activation signal or repository-defined embedded activation path',
    'When Dev Cadence is embedded in a target repository under `.dev-cadence/`, repository instructions may require reading `.dev-cadence/skills/using-dev-cadence/SKILL.md` as the activation path.',
    'Activation sequence:',
    'Check whether any cadence Skill may apply before any other response or action.',
    'Activate the selected concrete Skill through this Supervisor entrypoint.',
    'If the concrete Skill has a checklist, track each required item as explicit work.',
    'If the selected Skill turns out not to fit after activation, return to Supervisor routing with the reason',
    '## Supervisor Routing',
    'If multiple Skills apply, use them in workflow order.',
    'These Skills are cumulative, not alternatives.',
    'Process Skills come first because they define how to approach the work:',
    'unclear intent, design, or acceptance -> clarify before planning or implementation;',
    'unknown cause, bug, incident, failing test, or regression -> debug before fixing;',
    'Do not skip a process Skill because you already see a plausible implementation path.',
    'Common sequences:',
    'research spike: `cadence-clarify` when the research question or decision boundary is unclear -> `cadence-research` -> Human decision or `cadence-clarify`/`cadence-plan` for approved delivery follow-up',
    'feature or behavior change: `cadence-clarify` -> `cadence-plan` -> `cadence-tdd` or `cadence-executing-plans` -> `cadence-request-code-review` -> `cadence-code-review` when code findings require fixes -> `cadence-request-code-review` -> `cadence-verify` -> Human acceptance',
    'bug, incident, failing test, or regression: `cadence-debug` -> `cadence-tdd` or `cadence-executing-plans` -> `cadence-request-code-review` -> `cadence-code-review` when code findings require fixes -> `cadence-request-code-review` -> `cadence-verify` -> Human acceptance',
    'code review feedback, PR comments, or code reviewer findings to fix -> `cadence-code-review`;',
    'non-code review feedback or requested changes -> classify by what changed:',
    'intent/acceptance -> `cadence-clarify`, design/plan -> `cadence-plan`, implementation behavior -> `cadence-tdd` or `cadence-executing-plans`, evidence/completion -> `cadence-verify`;',
    '## Red Flags',
    'reading files, checking git, or exploring the repository before checking the applicable cadence Skill',
    'thinking "this is just a simple question" even though it affects delivery work',
    'thinking "I need more context first" before checking which Skill controls context gathering',
    'thinking "I remember this Skill" instead of activating the current version',
    'thinking "the Skill is overkill" or "just this once"',
    'thinking "I know what the user means" when scope, acceptance, or expected behavior has multiple reasonable interpretations',
    'thinking the request is too small, too obvious, or too urgent for a cadence Skill',
    'relying on memory of a Skill instead of activating the current Skill',
    'Questions are tasks when answering them changes delivery direction, design, implementation, review, verification, acceptance, or repository contract state.',
    'Do not collapse the workflow to a single Skill when later Skills are required.',
    'Do not self-accept final results.',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing Supervisor sequencing contract phrase: ${phrase}`);
    }
  }
}

function checkCadenceClarifyContract() {
  const sourceFile = 'skills/cadence-clarify/SKILL.md';
  const text = readText(sourceFile);
  const required = [
    '## Checklist',
    'Explore project context with limited read-only analysis',
    'Assess scope size. If the request spans independent subsystems or is too large for one delivery task, propose decomposition',
    'Ask focused clarification questions one at a time.',
    'Present 2-3 viable interpretations or approaches with tradeoffs and a recommendation',
    'Present requirements or design in sections scaled to complexity',
    'Ask the Human to review clarified requirements/design when persistent artifacts are used.',
    '## Process Flow',
    'The terminal state is a handoff to `using-dev-cadence` recommending `cadence-plan`',
    'Do not invoke `cadence-plan`, `cadence-executing-plans`, `cadence-tdd`, or implementation actions directly from this Skill.',
    '## Human Review Gate',
    'Only hand off as ready for planning when the Human approves the clarified requirements and required design',
    '## Visual Companion',
    'Visual companion is optional and just-in-time.',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing clarify process phrase: ${phrase}`);
    }
  }
}

function checkCadencePlanContract() {
  const sourceFile = 'skills/cadence-plan/SKILL.md';
  const text = readText(sourceFile);
  const required = [
    'Create executable implementation plans.',
    'A Worker with no chat history and limited context must be able to complete one task',
    'Vague plans fail planning review.',
    '## Scope Check',
    'multiple independent subsystems',
    'return a decomposition recommendation to `using-dev-cadence`',
    '## File Structure Planning',
    'map created and modified files',
    'Each task should produce a self-contained change',
    '## Task Right-Sizing',
    'smallest unit that carries its own test cycle and is worth an independent review gate',
    '## Plan Document Shape',
    '## Global Constraints',
    'Replace bracketed placeholders with actual accepted values in the final handoff content.',
    '## Task Structure',
    '**Interfaces:**',
    '**Acceptance Mapping:**',
    '**Test-First Plan:**',
    'Red behavior or characterization:',
    'Expected Red result:',
    'Expected Green result:',
    '**Test-First Exception:**',
    '**Implementation Detail:**',
    'Test detail: [test name, fixture/data shape, assertion, and expected failure]',
    'Code detail: [function/type/API signatures, data fields, config keys, or pseudocode required]',
    'New/changed surface: [exports, commands, user-visible behavior, or integration contract]',
    'Use checkbox (`- [ ]`) steps so execution can track progress.',
    'Do not include commit steps unless the Human explicitly asked this workflow to plan commits.',
    '## No Placeholders',
    'These are plan failures:',
    '"handle edge cases" without listing the edge cases',
    'code-changing steps that lack enough test/code detail to prevent a Worker from inventing signatures, fields, or behavior',
    'references to functions, types, files, commands, APIs, or dependencies',
    '## Test Plan Requirements',
    'Do not let "tests pass" stand in for acceptance mapping.',
    '## Self-Review',
    'Requirement coverage',
    'File/interface consistency',
    'Implementation specificity',
    'A fresh Worker can execute one task without chat history or guessing.',
    '## Execution Handoff',
    'implementation plan content;',
    'serial or parallel execution candidates with dependency notes;',
    'End with the plan handoff.',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing planning process phrase: ${phrase}`);
    }
  }
}

function checkCadenceExecutingPlansContract() {
  const sourceFile = 'skills/cadence-executing-plans/SKILL.md';
  const text = readText(sourceFile);
  const required = [
    'Read the approved plan, review it critically, execute task steps in order, run specified verification, and stop when blocked.',
    'Do not route workflow, select other cadence Skills, mark gates complete, write persistent records, accept risk, or claim completion.',
    '## Step 1: Load and Review Plan',
    'Read the approved plan and Supervisor-selected execution context:',
    'Check task order, target files, dependencies, acceptance mapping, verification commands, expected results, and forbidden actions.',
    'If the plan has critical gaps, unapproved scope, missing target files, unclear instructions, impossible verification, missing approvals, or a required discipline/gate not present in the Supervisor context',
    'Do not implement or switch Skills directly.',
    'Create local todos only after review finds no blocker.',
    '## Step 2: Execute Tasks',
    'Apply only the implementation discipline selected by `using-dev-cadence` for this run.',
    'Task status is one of: `implemented`, `verification_failed`, `blocked`, `needs_plan_update`.',
    'Do not treat local task progress as gate or workflow completion.',
    '## Stop Conditions',
    'Ask for clarification or a named Human decision through the Supervisor rather than guessing.',
    'If the plan changes, return to Step 1 before continuing.',
    '## Handoff',
    'recommended next state for Supervisor consideration.',
    'Do not approve, accept, commit, mark gates complete, or say done/fixed/passing/ready from this Skill.',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing executing-plans process phrase: ${phrase}`);
    }
  }
}

function checkCadenceSubagentDevelopmentContract() {
  const sourceFile = 'skills/cadence-subagent-development/SKILL.md';
  const text = readText(sourceFile);
  const requiredFiles = [
    'skills/cadence-subagent-development/implementer-prompt.md',
    'skills/cadence-subagent-development/task-reviewer-prompt.md',
    'skills/cadence-subagent-development/scripts/sdd-workspace',
    'skills/cadence-subagent-development/scripts/task-brief',
    'skills/cadence-subagent-development/scripts/review-package',
  ];

  for (const relativePath of requiredFiles) {
    if (!exists(relativePath)) {
      fail(`missing cadence-subagent-development resource: ${relativePath}`);
      continue;
    }
    if (relativePath.includes('/scripts/')) {
      const mode = fs.statSync(path.join(pluginDir, relativePath)).mode;
      if ((mode & 0o111) === 0) {
        fail(`${relativePath}: script must be executable`);
      }
    }
  }

  const required = [
    'Fresh Worker per task + file-based task brief and report + task-scoped review after each task.',
    'does not route workflow, select another cadence Skill, write persistent records, mark gates complete, accept risk, commit by default, or claim final completion.',
    '## When to Use',
    'each task has enough files, interfaces, acceptance mapping, test/code detail, dependencies, and verification commands for a fresh Worker',
    '## Continuous Execution Boundary',
    'continue through the selected task list without asking “should I continue?” between tasks.',
    '## Pre-Flight Plan Review',
    'Check that each task is small enough for one fresh Worker and has sufficient context to avoid invention.',
    '## Context Construction',
    'A fresh Worker must not need chat history.',
    'Do not paste accumulated prior-task summaries into later dispatches',
    'task brief: use `scripts/task-brief PLAN_FILE TASK_NUMBER [OUTFILE]`',
    'implementer report: one file under `.dev-cadence/sdd/` containing implementation summary, changed files, verification output, discipline evidence, skipped checks, and concerns;',
    'review package: use `scripts/review-package BASE HEAD [OUTFILE]` for committed ranges or `scripts/review-package --worktree BASE [OUTFILE]` for no-commit working tree review;',
    'skills/cadence-subagent-development/scripts/sdd-workspace',
    'skills/cadence-subagent-development/scripts/task-brief',
    'skills/cadence-subagent-development/scripts/review-package',
    '<repo-root>/.dev-cadence/sdd/',
    'scripts/task-brief PLAN_FILE TASK_NUMBER [OUTFILE]',
    'scripts/review-package --worktree BASE [OUTFILE]',
    'local progress ledger: `.dev-cadence/sdd/progress.md` is a resume map',
    'Never use the local progress ledger to claim done, accepted, ready, or gate-passed.',
    '## Per-Task Loop',
    'Ensure the local workspace exists with `skills/cadence-subagent-development/scripts/sdd-workspace`.',
    'Generate the task brief from the approved Markdown plan with `skills/cadence-subagent-development/scripts/task-brief`.',
    'Dispatch one fresh implementer Worker using `skills/cadence-subagent-development/implementer-prompt.md`, passing the task brief path and an expected implementer report path.',
    'Dispatch one read-only task reviewer Worker using `skills/cadence-subagent-development/task-reviewer-prompt.md`, passing the task brief path, implementer report path, and review package path.',
    'Build a focused review package with `skills/cadence-subagent-development/scripts/review-package`; use `--worktree BASE` when the task did not create commits.',
    'Do not dispatch multiple implementer Workers in parallel from this Skill.',
    '## Worker Status Handling',
    'Never force the same Worker to retry unchanged after a real blocker.',
    '## Review Rules',
    'Task review is mandatory after each implementer Worker and before the next task.',
    'spec compliance: whether the actual change matches the accepted task, constraints, and acceptance mapping;',
    'task quality: whether the task is well built, maintainable, verified, and safe enough to proceed.',
    'Reviewer Workers are read-only.',
    'Do not let implementer self-review replace independent review.',
    '## Prompt Construction Rules',
    'exact test/code detail needed to avoid invention',
    'Supervisor-selected implementation discipline and evidence expectations;',
    'Do not pre-judge findings for the reviewer.',
    '## Red Flags',
    'local progress is treated as gate completion, final acceptance, or persistent evidence.',
    '## Handoff',
    'Do not approve, accept, commit, mark gates complete, write persistent records, or say done/fixed/passing/ready from this Skill.',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing subagent-development process phrase: ${phrase}`);
    }
  }

  const implementerPrompt = readText('skills/cadence-subagent-development/implementer-prompt.md');
  const promptRequired = [
    'You are the implementer Worker for one Dev Cadence task.',
    'Do not use prior chat history as requirements.',
    'stop with `NEEDS_CONTEXT`',
    'Do not guess and do not invent scope.',
    'Follow the Supervisor-selected implementation discipline for this task.',
    'Return the evidence required by that discipline. Do not infer, weaken, rename, or replace the discipline requirements.',
    'IMPLEMENTER_REPORT_PATH: {IMPLEMENTER_REPORT_PATH}',
    'Write the full implementation report to `IMPLEMENTER_REPORT_PATH` when a path is provided',
    'Do not commit unless the Human or approved plan explicitly authorized commits.',
    'Full report path:',
    'Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED',
    'Recommended controller action:',
  ];

  for (const phrase of promptRequired) {
    if (!implementerPrompt.includes(phrase)) {
      fail(`skills/cadence-subagent-development/implementer-prompt.md: missing implementer prompt phrase: ${phrase}`);
    }
  }

  const taskReviewerPrompt = readText('skills/cadence-subagent-development/task-reviewer-prompt.md');
  const reviewerRequired = [
    'You are the task reviewer Worker for one Dev Cadence task.',
    'Your review is read-only.',
    'Do not use prior chat history as review input.',
    'REVIEW_PACKAGE_PATH: {REVIEW_PACKAGE_PATH}',
    'When `REVIEW_PACKAGE_PATH` is supplied, inspect it before opening additional files.',
    '## Part 1: Spec Compliance',
    '## Part 2: Code Quality',
    'spec_compliance: compliant | issues_found | cannot_verify | blocked',
    'quality_decision: approved | approved_with_minor_notes | changes_requested | blocked',
    'recommended_controller_action:',
  ];

  for (const phrase of reviewerRequired) {
    if (!taskReviewerPrompt.includes(phrase)) {
      fail(`skills/cadence-subagent-development/task-reviewer-prompt.md: missing task reviewer prompt phrase: ${phrase}`);
    }
  }

  const forbidden = [
    'skills/cadence-request-code-review/spec-compliance-reviewer.md',
    'skills/cadence-request-code-review/code-quality-reviewer.md',
    'TDD evidence',
    'RED:',
    'GREEN:',
    'required Red/Green',
  ];

  for (const phrase of forbidden) {
    if (text.includes(phrase) || implementerPrompt.includes(phrase)) {
      fail(`cadence-subagent-development must stay Skill-local and not hard-code TDD evidence vocabulary: ${phrase}`);
    }
  }

  const scriptExpectations = [
    {
      file: 'skills/cadence-subagent-development/scripts/sdd-workspace',
      phrases: [
        '.dev-cadence/sdd',
        'progress.md',
        'not Harness evidence, gate status, Human acceptance, or a persistent source of truth',
      ],
    },
    {
      file: 'skills/cadence-subagent-development/scripts/task-brief',
      phrases: [
        'usage: task-brief PLAN_FILE TASK_NUMBER [OUTFILE]',
        'Task[[:space:]]+',
        'expected Markdown heading like',
      ],
    },
    {
      file: 'skills/cadence-subagent-development/scripts/review-package',
      phrases: [
        'review-package --worktree BASE [OUTFILE]',
        'git diff -U10 "$base" --',
        'git ls-files --others --exclude-standard',
        '## Untracked file contents',
      ],
    },
  ];

  for (const expectation of scriptExpectations) {
    const scriptText = readText(expectation.file);
    for (const phrase of expectation.phrases) {
      if (!scriptText.includes(phrase)) {
        fail(`${expectation.file}: missing script contract phrase: ${phrase}`);
      }
    }
  }
}

function checkCadenceDispatchParallelContract() {
  const sourceFile = 'skills/cadence-dispatch-parallel/SKILL.md';
  const text = readText(sourceFile);
  const required = [
    'Dispatch parallel Dev Cadence Workers only for independent problem domains.',
    'Core principle: one Worker per independent problem domain, running concurrently, followed by controller-side integration verification.',
    '## Parallel Dispatch Gate',
    'Are there two or more domains?',
    'Can each domain be understood without findings from another domain?',
    'Can the controller integrate and verify all results after they return?',
    'recommend inline or sequential execution instead.',
    '## When to Use',
    'multiple independent failing test files, subsystems, investigation tracks, research options, or review slices exist;',
    'Workers can receive self-contained prompts without needing inherited chat history;',
    'no Worker needs another Worker\'s result before starting.',
    '## When Not to Use',
    'failures may share one root cause or one fix may change another domain;',
    'Workers would edit the same files, schemas, migrations, fixtures, generated artifacts, or shared test infrastructure;',
    'Related failures must be investigated together first. Parallelism is not a substitute for root-cause analysis.',
    'Confirm each Worker has a self-contained context package and does not need current-chat history.',
    'Parallel dispatch means issuing all Worker requests in the same controller step or tool batch so they run concurrently.',
    '## Worker Prompt Structure',
    '**Specific scope:**',
    '**Self-contained context:**',
    '**Allowed and forbidden actions:**',
    '**Output contract:**',
    'Prompt anti-patterns:',
    '❌ "Fix all failures." Too broad; the Worker loses domain focus.',
    '✅ "Return root cause, changed files, verification command output, skipped checks, and residual risk."',
    '## Dispatch Pattern',
    'Issue all independent Worker dispatches in the same controller step or tool batch.',
    'Do not paste the full current conversation into each Worker.',
    '## Integration',
    'Inspect the actual diff or artifacts for each domain; do not trust summaries alone.',
    'Spot-check for systematic Worker errors such as all Workers using the same invalid assumption.',
    'If conflicts or verification gaps exist, stop and return the gap to `using-dev-cadence` instead of claiming success.',
    '## Common Mistakes',
    'Running only per-domain tests and skipping integrated verification.',
    '## Verification Requirements',
    'Parallel work is not complete until the controller verifies the integrated result.',
    'overlap/conflict check was performed;',
    'integrated command or review proved the combined result, or the residual risk was returned to the Supervisor/Harness.',
    'gate-relevant observations',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing dispatch-parallel process phrase: ${phrase}`);
    }
  }

  const forbidden = [
    'gate status',
    'write persistent records',
    'mark gates complete',
  ];
  for (const phrase of forbidden) {
    if (text.includes(phrase)) {
      fail(`${sourceFile}: dispatch Skill must return handoff fields, not own gate or persistent record state: ${phrase}`);
    }
  }
}

function checkCadenceDebugContract() {
  const sourceFile = 'skills/cadence-debug/SKILL.md';
  const text = readText(sourceFile);
  const requiredFiles = [
    'skills/cadence-debug/root-cause-tracing.md',
    'skills/cadence-debug/condition-based-waiting.md',
    'skills/cadence-debug/defense-in-depth.md',
  ];

  for (const relativePath of requiredFiles) {
    if (!exists(relativePath)) {
      fail(`missing cadence-debug resource: ${relativePath}`);
    }
  }

  const required = [
    'NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST',
    'If you have not completed Phase 1, you cannot propose fixes.',
    'You MUST complete each phase before proceeding to the next.',
    '### Phase 1: Root Cause Investigation',
    '### Phase 2: Pattern Analysis',
    '### Phase 3: Hypothesis and Testing',
    '### Phase 4: Implementation',
    'Use `cadence-tdd` for testable code changes.',
    'Examples are illustrative only.',
    'Do not introduce a language, framework, toolchain, or dependency only because',
    'If three fix attempts fail',
    '## Red Flags',
    '## Human Correction Signals',
    '## Common Rationalizations',
    '## Evidence',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing debug process phrase: ${phrase}`);
    }
  }

  const techniqueExpectations = [
    {
      file: 'skills/cadence-debug/root-cause-tracing.md',
      phrases: [
        'Trace backward through the call chain',
        'NEVER fix just where the error appears',
      ],
    },
    {
      file: 'skills/cadence-debug/condition-based-waiting.md',
      phrases: [
        'Wait for the actual condition you care about',
        '## Quick Patterns',
        '## When a Fixed Delay Is Correct',
        'If you cannot name the triggering condition and documented interval, the delay',
        'do not increase arbitrary delays as a flaky-test fix',
      ],
    },
    {
      file: 'skills/cadence-debug/defense-in-depth.md',
      phrases: [
        'Validate at every layer',
        '## Four Layers',
        '### Entry Point Validation',
        '### Business Logic Validation',
        '### Environment Guards',
        '### Diagnostic Evidence',
        'Test each layer by attempting to bypass the previous one.',
        'Do not stop at one validation point',
      ],
    },
  ];

  for (const item of techniqueExpectations) {
    if (!exists(item.file)) continue;
    const resourceText = readText(item.file);
    for (const phrase of item.phrases) {
      if (!resourceText.includes(phrase)) {
        fail(`${item.file}: missing debug technique phrase: ${phrase}`);
      }
    }
  }
}

function checkCadenceTddContract() {
  const sourceFile = 'skills/cadence-tdd/SKILL.md';
  const text = readText(sourceFile);
  const required = [
    'NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST',
    'Writing production code before the failing test invalidates normal TDD evidence.',
    'do not keep it as "reference"',
    'do not adapt it while writing tests',
    '## Pre-Implementation Baseline',
    '### RED: Write a Failing Test',
    '### GREEN: Minimal Code',
    '### REFACTOR: Clean Up While Green',
    'If the test passes immediately, it is not Red evidence.',
    'Do not add behavior during refactor.',
    '## Example: Bug Fix',
    "test('rejects empty email'",
    'FAIL expected "Email required", got undefined',
    '## Why Order Matters',
    '## Common Rationalizations',
    '## Red Flags',
    '## When Stuck',
    '## Debugging Integration',
    'Never fix a testable bug without a failing test or named Human exception.',
    '## Testing Anti-Patterns',
    'testing-anti-patterns.md',
    '## Completion Checklist',
    'each accepted behavior has Red evidence or a named Human exception',
    '## Evidence',
    'Production code -> test exists and failed first.',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing TDD process phrase: ${phrase}`);
    }
  }

  const antiPatternsFile = 'skills/cadence-tdd/testing-anti-patterns.md';
  if (!exists(antiPatternsFile)) {
    fail(`${antiPatternsFile}: missing TDD anti-patterns reference`);
    return;
  }

  const antiPatternsText = readText(antiPatternsFile);
  const antiPatternRequired = [
    '## Anti-Pattern 1: Testing Mock Behavior',
    '## Anti-Pattern 2: Test-Only Methods in Production',
    '## Anti-Pattern 3: Mocking Without Understanding',
    '## Anti-Pattern 4: Incomplete Mocks',
    '## Anti-Pattern 5: Integration Tests as Afterthought',
    '### Gate Function',
    'BEFORE asserting on any mock element:',
    'BEFORE adding any method to production class:',
    'BEFORE mocking any method:',
    'BEFORE creating mock responses:',
    '❌ BAD: Testing that the mock exists',
    '✅ GOOD: Test the real component',
    '✅ Implementation complete',
    '❌ No tests written',
    '## TDD Prevents These Anti-Patterns',
    '## Quick Reference',
    '## Red Flags',
    '## Bottom Line',
    'Mocks are tools to isolate, not things to test.',
  ];

  for (const phrase of antiPatternRequired) {
    if (!antiPatternsText.includes(phrase)) {
      fail(`${antiPatternsFile}: missing TDD anti-pattern phrase: ${phrase}`);
    }
  }
}

function checkImplementationDisciplineBoundary() {
  const sourceFile = 'references/implementation-discipline.md';
  const text = readText(sourceFile);
  const required = [
    'shared implementation evidence and exception contract',
    'skills/cadence-tdd/SKILL.md',
    '## Shared Evidence Contract',
    '## Exception Contract',
    '## Test Quality Boundary',
    'When a change is testable, enter `cadence-tdd` and follow its full Red-Green-Refactor workflow before changing production code.',
    'skills/cadence-tdd/testing-anti-patterns.md',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing implementation boundary phrase: ${phrase}`);
    }
  }
}

function checkCadenceVerifyContract() {
  const sourceFile = 'skills/cadence-verify/SKILL.md';
  const text = readText(sourceFile);
  const required = [
    'NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE',
    'Core principle: evidence before claims, always.',
    'Unverified completion claims are a process failure, not efficiency.',
    'If the claim depends on a command, and that command has not run',
    '## Core Rule',
    '### Gate Function',
    '1. IDENTIFY: what command, artifact, or documented check proves the claim.',
    '2. RUN: execute the full relevant command',
    '3. READ: inspect the full output, exit code, failure count, skipped checks, and',
    '4. COMPARE: decide whether the evidence actually proves the claim.',
    '5. STATE: report the verified result with evidence',
    'If any step is missing, do not make the claim.',
    '### Claim Matrix',
    'linter clean',
    'regression test works',
    'Worker or delegated task completed',
    '### Fresh Evidence Rules',
    'After any file change, old verification output is stale for affected claims.',
    'Do not trust Worker, reviewer, or tool summaries without checking',
    '### Commit and Gate Verification',
    '`scripts/check-before-commit.mjs` is read-only and must not create specs.',
    '### Human Acceptance Summary',
    'Do not merely say "G6 is pending".',
    '### Incomplete Verification',
    '## Red Flags',
    'expressing satisfaction before verification',
    'about to commit, open a PR, merge, or ask for acceptance without verification',
    'any wording that implies success without current evidence',
    '## Rationalization Prevention',
    'Just this once.',
    'Different wording avoids the rule.',
    '## Key Patterns',
    '**Tests:**',
    '✅ [Run test command] [See: 34/34 pass] "All tests pass"',
    '**Regression tests (TDD Red-Green):**',
    'Run (MUST FAIL)',
    '**Build:**',
    '"Linter passed" when build or compile did not run',
    '**Requirements:**',
    'Re-read plan -> Create checklist -> Verify each -> Report gaps or completion',
    '**Delegated Work:**',
    'Worker reports success -> Check diff -> Verify artifacts -> Report actual state',
    '**Bug Fix:**',
    '## When to Apply',
    'any expression of satisfaction about work state',
    'The rule applies to exact words, synonyms, paraphrases, and implications',
    '## Why This Matters',
    'False completion claims cause:',
    '## Bottom Line',
    'No shortcuts for verification.',
    '## Handoff Evidence',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing verification process phrase: ${phrase}`);
    }
  }
}

function checkVerificationDisciplineBoundary() {
  const sourceFile = 'references/verification-discipline.md';
  const text = readText(sourceFile);
  const required = [
    'shared verification gate semantics',
    'skills/cadence-verify/SKILL.md',
    'No completion claims without fresh verification evidence.',
    'Unverified completion claims are process failures, not efficiency.',
    'Fresh evidence means evidence produced after the final relevant change.',
    'Linter clean',
    'Regression test works',
    'Worker or delegated task completed',
    'Worker report plus independent diff/artifact verification',
    '## Rationalization Prevention',
    'Confidence is not evidence.',
    'Partial check supports only a partial claim.',
    '## Bottom Line',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing verification boundary phrase: ${phrase}`);
    }
  }
}

function checkCadenceCodeReviewBoundary() {
  const sourceFile = 'skills/cadence-code-review/SKILL.md';
  const text = readText(sourceFile);
  const required = [
    'Code review feedback requires technical evaluation, not emotional performance.',
    'Core principle: verify before implementing. Ask before assuming. Technical',
    'correctness over social comfort.',
    'Use this Skill after code review findings exist',
    'This Skill is not a generic review-feedback bucket.',
    'Non-code feedback returns to',
    '`using-dev-cadence` for routing',
    'WHEN receiving code review feedback:',
    'First read all code review feedback before making changes.',
    '## Forbidden Responses',
    '"Let me implement that now" before verification.',
    '"Thanks for catching that" or any gratitude-only response.',
    '## Handling Unclear Code Review Feedback',
    'STOP - do not implement anything yet',
    'Partial understanding = wrong implementation.',
    'Check: technically correct for this codebase?',
    'If you cannot verify it, say what evidence is missing',
    '## YAGNI Check for Professionalized Suggestions',
    'search the codebase for actual callers or users',
    'Do not add speculative functionality only because a review comment sounds',
    'Clarify anything unclear FIRST',
    'Verify no regressions',
    '## When To Push Back',
    'use technical reasoning, not defensiveness;',
    '## Acknowledging Correct Feedback',
    'When code review feedback is correct:',
    '✅ "Fixed. [Brief description of what changed and what verification passed]"',
    '❌ "Thanks for [anything]"',
    '❌ Any gratitude-only response.',
    'Actions and evidence are the acknowledgment.',
    'If you push back and later prove yourself wrong, correct course factually:',
    '## GitHub Thread Replies',
    '## Dev Cadence Boundary',
    '## Common Mistakes',
    'Cannot verify but proceeds anyway',
    'Bottom line: verify, question, then implement.',
    'Do not load or apply',
    '`cadence-tdd` test-writing resources from this Skill.',
    'If a valid finding requires production behavior changes, test changes, mocks, or',
    'return a handoff to `using-dev-cadence` so the Supervisor can',
    'route the work to `cadence-tdd` or `cadence-executing-plans`.',
    'it does not own the test-writing or artifact-writing',
    'If feedback is not a code review finding, do not handle it here:',
    'requested production behavior changes outside a code review finding -> `using-dev-cadence`',
  ];
  const forbidden = [
    '../../references/testing-anti-patterns.md',
    'skills/cadence-tdd/testing-anti-patterns.md',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing review boundary phrase: ${phrase}`);
    }
  }
  for (const phrase of forbidden) {
    if (text.includes(phrase)) {
      fail(`${sourceFile}: must not directly load TDD test-writing resource: ${phrase}`);
    }
  }
}

function checkCadenceRequestCodeReviewContract() {
  const sourceFile = 'skills/cadence-request-code-review/SKILL.md';
  const text = readText(sourceFile);
  const required = [
    'review the work product, not the implementer',
    'Provide precise context and keep reviewer execution read-only.',
    '## Reviewer Context',
    'Do not pass the current chat history as reviewer context.',
    'Reviewer Workers are read-only:',
    'do not mutate the working tree, index, branch state, specs, or run evidence;',
    '## Reviewer Prompt Selection',
    'Use `spec-compliance-reviewer.md` for the first review stage.',
    '`code-quality-reviewer.md` for the second stage after spec compliance passes.',
    'Every reviewer request must include a concrete review target',
    'Reviewers must inspect the',
    'actual work product, artifacts, and evidence',
    '## Review Output',
    'findings grouped by `blocker`, `major`, `minor`, and `note`',
    'explicit verdict: `approved`, `approved_with_minor_notes`,',
    '`changes_requested`, or `blocked`',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing request-code-review contract phrase: ${phrase}`);
    }
  }
}

function checkReviewDisciplineContract() {
  const sourceFile = 'references/review-discipline.md';
  const text = readText(sourceFile);
  const required = [
    'Reviewer Workers are read-only.',
    'Do not pass the current chat history as reviewer context.',
    'Reviewers must not mutate the working tree, index, branch state, specs, or run',
    '`approved`, `approved_with_minor_notes`, `changes_requested`, or `blocked`',
    'Receiving code review feedback is a separate action from producing review findings.',
    'Do not use `cadence-code-review` as a generic feedback handler.',
    'Route non-code feedback by the object being changed',
    'Do not blindly apply feedback.',
    'Read all feedback first, clarify unclear items',
    'If a valid finding requires production behavior changes, test changes, mocks, or',
    'return to the Supervisor so the work can enter `cadence-tdd` or',
    'Review handling does',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing review discipline phrase: ${phrase}`);
    }
  }
}

function checkStagedReviewerPromptContract() {
  const expectations = [
    {
      file: 'skills/cadence-request-code-review/spec-compliance-reviewer.md',
      phrases: [
        '## Review Target',
        'CHANGED_FILES: {CHANGED_FILES}',
        'DIFF_PATH_OR_RANGE: {DIFF_PATH_OR_RANGE}',
        '## Read-Only Review',
        'Do not mutate the working tree, index, HEAD, branch',
        'Do not trust the implementer report by itself.',
        'Do not rely on chat history or implementer',
        'verdict: compliant | issues_found | blocked',
      ],
    },
    {
      file: 'skills/cadence-request-code-review/code-quality-reviewer.md',
      phrases: [
        '## Read-Only Review',
        'Do not mutate the working tree, index, HEAD, branch',
        'Inspect the actual diff or revision range',
        'decision: approved | approved_with_minor_notes | changes_requested | blocked',
      ],
    },
  ];

  for (const expectation of expectations) {
    const text = readText(expectation.file);
    for (const phrase of expectation.phrases) {
      if (!text.includes(phrase)) {
        fail(`${expectation.file}: missing staged reviewer prompt phrase: ${phrase}`);
      }
    }
  }
}

function checkCodeReviewerPromptContract() {
  const sourceFile = 'skills/cadence-request-code-review/code-reviewer.md';
  const text = readText(sourceFile);
  const required = [
    '## Read-Only Review',
    'Do not mutate the working tree, the',
    'index, HEAD, branch state, specs, or run evidence.',
    'Review the supplied work product and artifacts.',
    'Do not rely on chat history',
    '## Calibration',
    'Categorize issues by actual severity.',
    'Do not give feedback on code, tests, artifacts, or requirements you did not',
    'Give a clear verdict',
    'decision: approved | approved_with_minor_notes | changes_requested | blocked',
    '## Critical Rules',
  ];

  for (const phrase of required) {
    if (!text.includes(phrase)) {
      fail(`${sourceFile}: missing reviewer prompt phrase: ${phrase}`);
    }
  }
}

function checkConcreteSkillSupervisorBoundary() {
  const concreteSkills = EXPECTED_SKILLS.filter((name) => name !== 'using-dev-cadence' && name !== 'cadence-plan');
  const required = [
    '## Supervisor Boundary',
    'This Skill must run under `using-dev-cadence` Supervisor control.',
    'If it was selected directly, first enter `using-dev-cadence`',
    'When this Skill finishes, return a concise handoff to `using-dev-cadence`',
    'Do not select the next cadence Skill from here.',
  ];

  for (const skillName of concreteSkills) {
    const sourceFile = `skills/${skillName}/SKILL.md`;
    const text = readText(sourceFile);
    for (const phrase of required) {
      if (!text.includes(phrase)) {
        fail(`${sourceFile}: missing Supervisor boundary phrase: ${phrase}`);
      }
    }
  }
}

function checkConcreteSkillResponsibilityBoundary() {
  const supervisorHarnessSkills = new Set([
    'using-dev-cadence',
    'cadence-verify',
    'cadence-sync',
  ]);
  const concreteBehaviorSkills = EXPECTED_SKILLS.filter((name) => !supervisorHarnessSkills.has(name));
  const forbiddenPatterns = [
    /\b(?:write|update|create)\s+or\s+(?:update|create)\s+`?specs\/records/i,
    /\bwrite\/update\s+artifacts/i,
    /\bupdate\s+artifacts\b/i,
    /\bupdate\s+task\s+artifacts\b/i,
    /\brecord\s+Harness\s+evidence\b/i,
    /\brecording\s+persistent\s+run\s+evidence\b/i,
    /\bwhen\s+artifacts\s+are\s+being\s+written,\s+record\b/i,
    /\brecord\s+required\s+pre-implementation\s+status\b/i,
    /\brecord\s+integration\s+evidence\b/i,
  ];

  for (const skillName of concreteBehaviorSkills) {
    const sourceFile = `skills/${skillName}/SKILL.md`;
    const text = readText(sourceFile);
    const lines = text.split('\n');
    lines.forEach((line, index) => {
      for (const pattern of forbiddenPatterns) {
        if (pattern.test(line)) {
          fail(`${sourceFile}:${index + 1}: concrete Skill must return handoff data, not own Supervisor/Harness artifact work: ${line.trim()}`);
        }
      }
    });
  }
}

function checkPluginSurface() {
  if (embeddedRuntime) {
    const required = [
      'manifest.json',
      'VERSION',
    ];
    for (const relativePath of required) {
      if (!exists(relativePath)) {
        fail(`missing embedded runtime resource: ${relativePath}`);
      }
    }
    return;
  }

  const required = [
    '.codex-plugin/plugin.json',
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
checkPathReferences('skills/cadence-clarify/visual-companion.md');
checkPathReferences('references/skill-layout.md');
checkDeliveryStateTable();
checkSourceMaintenanceContract();
checkPromptTemplates();
checkArtifactTemplates();
checkVisualCompanionScripts();
checkEntrypointReferenceMap();
checkEntrypointSkills();
checkUsingDevCadenceContract();
checkCadenceClarifyContract();
checkCadencePlanContract();
checkCadenceExecutingPlansContract();
checkCadenceSubagentDevelopmentContract();
checkCadenceDispatchParallelContract();
checkCadenceDebugContract();
checkCadenceTddContract();
checkImplementationDisciplineBoundary();
checkCadenceVerifyContract();
checkVerificationDisciplineBoundary();
checkCadenceRequestCodeReviewContract();
checkCadenceCodeReviewBoundary();
checkReviewDisciplineContract();
checkStagedReviewerPromptContract();
checkCodeReviewerPromptContract();
checkConcreteSkillSupervisorBoundary();
checkConcreteSkillResponsibilityBoundary();

if (errors.length > 0) {
  for (const message of errors) {
    console.error(`FAIL ${message}`);
  }
  console.error(`\n${errors.length} failure(s)`);
  process.exit(1);
}

console.log(`OK discipline routes verified for ${path.relative(process.cwd(), pluginDir) || pluginDir}`);
