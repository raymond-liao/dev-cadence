---
name: cadence-dispatch-parallel
description: Dispatch parallel Dev Cadence Workers for independent domains. Use when there are two or more independent failures, subsystems, investigation tracks, research options, or review slices that can run concurrently without shared mutable state, file conflicts, or sequencing dependencies.
---

# Cadence Dispatch Parallel

Dispatch parallel Dev Cadence Workers only for independent problem domains. The purpose is speed without context bleed: each Worker receives exactly the context needed for one domain and nothing from the current chat history unless you explicitly include it.

Core principle: one Worker per independent problem domain, running concurrently, followed by controller-side integration verification.

## Required References

- `../../references/execution-orchestration.md`
- `../../references/harness.md`
- `../../references/context-pack.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

Load `../../references/debugging-discipline.md` when the Supervisor-selected work includes bug, incident, failing-test, or root-cause investigations.

## Parallel Dispatch Gate

Before dispatching, answer the gate explicitly:

1. Are there two or more domains?
2. Can each domain be understood without findings from another domain?
3. Can each Worker operate without editing the same files, mutating the same state, or depending on another Worker's output?
4. Can the controller integrate and verify all results after they return?

If any answer is no, do not use parallel dispatch. Return the reason to `using-dev-cadence` and recommend inline or sequential execution instead.

## When to Use

Use parallel dispatch when all of these are true:

- multiple independent failing test files, subsystems, investigation tracks, research options, or review slices exist;
- each problem domain has a focused scope and a clear success condition;
- Workers can receive self-contained prompts without needing inherited chat history;
- allowed files, forbidden actions, commands, and evidence expectations can be stated per Worker;
- no Worker needs another Worker's result before starting.

Examples of valid independent domains:

- one Worker investigates parser failures while another investigates UI rendering failures;
- one Worker reviews database migration code while another reviews unrelated API routing code;
- three Workers test three independent research options, each returning evidence and tradeoffs.

## When Not to Use

Do not parallelize when:

- failures may share one root cause or one fix may change another domain;
- the work requires a whole-system mental model before decomposition;
- Workers would edit the same files, schemas, migrations, fixtures, generated artifacts, or shared test infrastructure;
- Workers would mutate the same database, service, queue, local environment, branch state, or external account;
- the controller cannot run integrated verification afterward;
- the request is exploratory debugging and you do not yet know the independent domains.

Related failures must be investigated together first. Parallelism is not a substitute for root-cause analysis.

## Required Behavior

Before dispatch:

1. Group work by independent problem domain.
2. Confirm each domain can be understood without findings from another domain.
3. Confirm Workers will not edit the same files, mutate shared state, or require a whole-system mental model.
4. Confirm each Worker has a self-contained context package and does not need current-chat history.
5. Write focused Worker prompts with scope, constraints, expected evidence, forbidden actions, stop conditions, and required output.

Do not dispatch one Worker, wait for it, then dispatch the next when the domains are truly independent. Parallel dispatch means issuing all Worker requests in the same controller step or tool batch so they run concurrently.

Dispatch one Worker per independent domain. Each Worker gets isolated context and must return:

- summary of findings;
- changed files, if any;
- commands and verification results;
- residual risk;
- blockers or follow-up questions.

## Worker Prompt Structure

Each Worker prompt must include:

1. **Specific scope:** one problem domain, file group, test file, subsystem, research option, or review slice.
2. **Clear goal:** the exact outcome expected for that domain.
3. **Self-contained context:** relevant files, failing test names, error messages, accepted requirements, constraints, and commands.
4. **Allowed and forbidden actions:** what may be edited or inspected, what must not be touched, and whether the Worker is read-only.
5. **Discipline requirements:** Supervisor-selected debugging, implementation, review, or research evidence expectations for this domain.
6. **Output contract:** findings, changes, commands/results, residual risk, blockers, and recommended controller action.

Prompt anti-patterns:

- ❌ "Fix all failures." Too broad; the Worker loses domain focus.
- ✅ "Fix the three failures in `src/agents/agent-tool-abort.test.ts`; do not touch batch completion tests."
- ❌ "Investigate the race condition." No concrete context.
- ✅ "Investigate these test names and failure messages; determine whether timing or product code is the cause."
- ❌ "Fix it and tell me what happened." Vague output.
- ✅ "Return root cause, changed files, verification command output, skipped checks, and residual risk."
- ❌ "Use any approach needed." Missing constraints.
- ✅ "Do not change production code unless you first prove the test expectation matches accepted behavior."

## Dispatch Pattern

1. Build the domain list.
2. For each domain, write one focused Worker prompt.
3. Issue all independent Worker dispatches in the same controller step or tool batch.
4. Continue controller coordination only after all required Workers have returned or a real blocker is reported.
5. Treat every Worker report as a claim until integrated verification proves it.

The controller must preserve its own context for coordination. Do not paste the full current conversation into each Worker. Include only the context that the Worker needs to succeed.

## Integration

After Workers return:

1. Review every summary and changed file list.
2. Inspect the actual diff or artifacts for each domain; do not trust summaries alone.
3. Check for overlapping edits, semantic conflicts, inconsistent assumptions, and shared-resource side effects.
4. Run domain-specific verification when needed, then run integrated verification that proves the combined result.
5. Spot-check for systematic Worker errors such as all Workers using the same invalid assumption.
6. If conflicts or verification gaps exist, stop and return the gap to `using-dev-cadence` instead of claiming success.
7. Return integration evidence and unresolved risks for Supervisor/Harness recording.

Do not continue to review, verify completion, or ask for Human acceptance until conflicts and verification gaps are resolved or explicitly handed off as residual risk.

## Common Mistakes

- Dispatching by number of files instead of independent domains.
- Giving every Worker the whole plan or whole chat history.
- Letting Workers edit shared setup, fixtures, migrations, or generated files in parallel.
- Treating read-only review slices as permission to mutate code.
- Accepting Worker summaries without checking actual changes and evidence.
- Running only per-domain tests and skipping integrated verification.
- Using parallel dispatch to avoid deciding whether failures are related.

## Verification Requirements

Parallel work is not complete until the controller verifies the integrated result.

Minimum verification:

- every Worker report was read;
- every changed file list was inspected against actual diff or artifacts;
- overlap/conflict check was performed;
- required per-domain commands were run or explicitly marked skipped with reason;
- integrated command or review proved the combined result, or the residual risk was returned to the Supervisor/Harness.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with dispatch domains, Worker outcomes, changed files, commands and verification results, skipped checks, residual risks, blockers, gate-relevant observations, and recommended next state. Do not select the next cadence Skill from here.
