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
    'templates/prompts/plan-document-reviewer.md',
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
    '## Control Rule',
    'Before any response or action for software delivery work',
    'If there is any reasonable chance a cadence Skill applies',
    'before answering, asking clarification questions, reading files, running commands, or editing code.',
    '## Instruction Priority',
    'explicit user instructions, repository instructions, and direct constraints',
    'Dev Cadence Supervisor, Harness, Quality Gate, Human Gate, and cadence Skill rules',
    '## Skill Activation',
    'Use Codex native skill activation.',
    'When Dev Cadence is embedded in a target repository under `.dev-cadence/`, repository instructions may require reading `.dev-cadence/skills/using-dev-cadence/SKILL.md` as the activation path.',
    'Do not read `SKILL.md` files with ordinary file tools as a substitute for activating an applicable Skill.',
    '## Supervisor Routing',
    'If multiple Skills apply, use them in workflow order.',
    'These Skills are cumulative, not alternatives.',
    'Common sequences:',
    'research spike: `cadence-clarify` when the research question or decision boundary is unclear -> `cadence-research` -> Human decision or `cadence-clarify`/`cadence-plan` for approved delivery follow-up',
    'feature or behavior change: `cadence-clarify` -> `cadence-plan` -> `cadence-tdd` or `cadence-executing-plans` -> `cadence-request-code-review` -> `cadence-code-review` when code findings require fixes -> `cadence-request-code-review` -> `cadence-verify` -> Human acceptance',
    'bug, incident, failing test, or regression: `cadence-debug` -> `cadence-tdd` or `cadence-executing-plans` -> `cadence-request-code-review` -> `cadence-code-review` when code findings require fixes -> `cadence-request-code-review` -> `cadence-verify` -> Human acceptance',
    'code review feedback, PR comments, or code reviewer findings to fix -> `cadence-code-review`;',
    'non-code review feedback or requested changes -> classify by what changed:',
    'intent/acceptance -> `cadence-clarify`, design/plan -> `cadence-plan`, implementation behavior -> `cadence-tdd` or `cadence-executing-plans`, evidence/completion -> `cadence-verify`;',
    '## Red Flags',
    'reading files, checking git, or exploring the repository before checking the applicable cadence Skill',
    'thinking the request is too small, too obvious, or too urgent for a cadence Skill',
    'relying on memory of a Skill instead of activating the current Skill',
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
  const concreteSkills = EXPECTED_SKILLS.filter((name) => name !== 'using-dev-cadence');
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
