# External Sources

## Execution Status

External research was performed on 2026-06-08 using current web-accessible primary sources where possible.

The collected sources focus on:

- Multi-agent orchestration.
- Human-in-the-loop approval.
- Agent state, tracing, guardrails, and persistence.
- AI coding agent workflow and review.
- Coding-agent benchmark limitations and failure modes.
- Human-agent collaboration as process and infrastructure.

## Source Summary

| ID | Source | Type | Relevance |
|---|---|---|---|
| SRC-001 | LangGraph Persistence docs | Official documentation | Supports explicit state, checkpointing, resume, HITL |
| SRC-002 | LangChain Human-in-the-loop docs | Official documentation | Supports tool approval policy and pause/resume |
| SRC-003 | Microsoft Agent Framework workflow orchestration docs | Official documentation | Supports orchestration pattern taxonomy |
| SRC-004 | OpenAI Agents SDK guide | Official documentation | Supports application-owned orchestration, state, approvals |
| SRC-005 | OpenAI Agents SDK guardrails docs | Official documentation | Supports layered guardrail design |
| SRC-006 | OpenAI Agents SDK tracing docs | Official documentation | Supports auditability and workflow tracing |
| SRC-007 | SWE-bench paper | Academic paper | Grounds coding-agent evaluation in real GitHub issues |
| SRC-008 | SWE-bench-Live paper | Academic paper | Shows static benchmark limitations and need for fresh evaluation |
| SRC-009 | Failure modes of LLMs resolving GitHub issues | Academic paper | Supports explicit failure-mode and repair-pipeline analysis |
| SRC-010 | Human-Agent Collaboration framework | Research paper | Supports process as first-class representation |
| SRC-011 | GitHub Copilot cloud agent docs | Official documentation | Shows productized coding-agent PR workflow |
| SRC-012 | GitHub Copilot output review docs | Official documentation | Supports human review and workflow permission gates |

## Collected Sources

### [SRC-001] LangGraph Persistence

**Source URL**: https://docs.langchain.com/oss/python/langgraph/persistence  
**Source Type**: Official Documentation  
**Collection Time**: 2026-06-08  
**Publication Time**: Continuously updated documentation  
**Credibility**: High

**Relevant Claims**:

- LangGraph persists graph state as checkpoints.
- Persistence supports human-in-the-loop workflows, memory, time travel debugging, and fault-tolerant execution.
- Checkpointers let humans inspect, interrupt, approve, and resume graph steps.

**Key Evidence**:

The documentation describes checkpoints saved at each graph step and explicitly ties persistence to human-in-the-loop, memory, time travel, and fault tolerance.

**Relevance to Framework**:

Supports the proposal's need for explicit run state, workflow checkpoints, human gates, and auditable state transitions.

**Limitations**:

This is framework documentation, not evidence that all teams should use LangGraph.

### [SRC-002] LangChain Human-in-the-loop

**Source URL**: https://docs.langchain.com/oss/python/langchain/human-in-the-loop  
**Source Type**: Official Documentation  
**Collection Time**: 2026-06-08  
**Publication Time**: Continuously updated documentation  
**Credibility**: High

**Relevant Claims**:

- HITL middleware can pause agent tool calls that require review.
- Human decisions include approve, edit, reject, and respond.
- HITL requires graph state persistence so execution can pause and resume.
- Documentation includes an example of pausing writes outside a workspace path.

**Key Evidence**:

The docs describe policy-based interrupts over tool calls and use checkpointing to preserve state across human review.

**Relevance to Framework**:

Supports the proposal's permission gates, workspace isolation, and explicit human approval points.

**Limitations**:

The docs describe implementation mechanics, not a complete software delivery methodology.

### [SRC-003] Microsoft Agent Framework Workflow Orchestrations

**Source URL**: https://learn.microsoft.com/en-us/agent-framework/workflows/orchestrations/  
**Source Type**: Official Documentation  
**Collection Time**: 2026-06-08  
**Publication Time**: Last updated 2026-03-31  
**Credibility**: High

**Relevant Claims**:

- Agent Framework provides built-in multi-agent orchestration patterns: Sequential, Concurrent, Handoff, Group Chat, and Magentic.
- Orchestrations support human-in-the-loop interactions through approval-required tools and request-info patterns.

**Key Evidence**:

The documentation lists multiple orchestration patterns and explicitly mentions approval-required tools.

**Relevance to Framework**:

Supports the proposal's distinction between topology types and the recommendation to use Supervisor + graph workflow for controlled delivery.

**Limitations**:

The source is product documentation and does not evaluate which pattern is best for this project's exact needs.

### [SRC-004] OpenAI Agents SDK Guide

**Source URL**: https://developers.openai.com/api/docs/guides/agents  
**Source Type**: Official Documentation  
**Collection Time**: 2026-06-08  
**Publication Time**: Continuously updated documentation  
**Credibility**: High

**Relevant Claims**:

- Agents can plan, call tools, collaborate across specialists, and keep enough state for multi-step work.
- The SDK is appropriate when the application owns orchestration, tool execution, approvals, and state.
- The guide points to specialist ownership, guardrails, human review, results, state, tracing, and evaluation.

**Key Evidence**:

The guide defines the SDK track around code-first agent applications with direct control over tools, MCP, runtime behavior, storage, and approvals.

**Relevance to Framework**:

Supports separating orchestration/runtime concerns from coding executor concerns.

**Limitations**:

This is an SDK capability map, not a direct validation of this framework's role model.

### [SRC-005] OpenAI Agents SDK Guardrails

**Source URL**: https://openai.github.io/openai-agents-python/guardrails/  
**Source Type**: Official Documentation  
**Collection Time**: 2026-06-08  
**Publication Time**: Continuously updated documentation  
**Credibility**: High

**Relevant Claims**:

- Input guardrails, output guardrails, and tool guardrails run at different workflow boundaries.
- Tool guardrails run on every custom function-tool invocation.
- In workflows with managers, handoffs, or delegated specialists, tool-level checks may be needed instead of relying only on agent-level guardrails.

**Key Evidence**:

The docs explicitly describe guardrail execution boundaries and warn that not all guardrails apply throughout a multi-agent chain.

**Relevance to Framework**:

Supports the proposal's need for layered quality gates and permission checks rather than a single final approval.

**Limitations**:

Guardrails are SDK mechanisms; project policy still needs to define what should be guarded.

### [SRC-006] OpenAI Agents SDK Tracing

**Source URL**: https://github.com/openai/openai-agents-python/blob/main/docs/tracing.md  
**Source Type**: Official Documentation / Source Repository Documentation  
**Collection Time**: 2026-06-08  
**Publication Time**: Continuously updated repository documentation  
**Credibility**: High

**Relevant Claims**:

- Built-in tracing records LLM generations, tool calls, handoffs, guardrails, and custom events.
- Tracing helps debug, visualize, and monitor agent workflows.
- Sensitive data handling must be considered because tracing may include sensitive data by default depending on configuration.

**Key Evidence**:

The tracing docs list spans for agent runs, generations, function calls, guardrails, and handoffs.

**Relevance to Framework**:

Supports audit, observability, quality review, and governance requirements.

**Limitations**:

Tracing is useful only if teams define what to inspect and how long traces should be retained.

### [SRC-007] SWE-bench: Can Language Models Resolve Real-World GitHub Issues?

**Source URL**: https://arxiv.org/abs/2310.06770  
**Source Type**: Academic Paper  
**Collection Time**: 2026-06-08  
**Publication Time**: 2023-10-10; updated 2024-11-11  
**Credibility**: High

**Relevant Claims**:

- SWE-bench evaluates models on real GitHub issues and corresponding pull requests.
- The original benchmark includes 2,294 software engineering problems across 12 Python repositories.
- Resolving issues often requires understanding long context and coordinating changes across multiple functions, classes, and files.

**Key Evidence**:

The abstract frames real-world software engineering as a challenging testbed beyond traditional code generation.

**Relevance to Framework**:

Supports the proposal's claim that coding agents need context, tests, review, and workflow rather than simple code generation prompts.

**Limitations**:

SWE-bench measures issue resolution, not full team collaboration or governance.

### [SRC-008] SWE-bench Goes Live

**Source URL**: https://arxiv.org/abs/2505.23419  
**Source Type**: Academic Paper  
**Collection Time**: 2026-06-08  
**Publication Time**: 2025-05-29  
**Credibility**: High

**Relevant Claims**:

- Static SWE-bench variants can become stale, narrow, and vulnerable to overfitting or contamination.
- SWE-bench-Live introduces live-updatable tasks from real GitHub issues created since 2024.
- The initial release includes 1,319 tasks across 93 repositories and Docker images for reproducible execution.
- The paper reports a performance gap versus static benchmarks.

**Key Evidence**:

The abstract directly identifies limitations of static benchmarks and argues for fresh, dynamic evaluation.

**Relevance to Framework**:

Supports the proposal's need for project-specific evaluation, regression cases, and continuous improvement rather than relying only on public benchmark scores.

**Limitations**:

This is an evaluation benchmark paper, not a process framework for team adoption.

### [SRC-009] Characterizing the Failure Modes of LLMs in Resolving Real-World GitHub Issues

**Source URL**: https://arxiv.org/abs/2605.12270  
**Source Type**: Academic Paper  
**Collection Time**: 2026-06-08  
**Publication Time**: 2026-05-18  
**Credibility**: Medium-High

**Relevant Claims**:

- LLMs are increasingly deployed to resolve real-world GitHub issues.
- The paper studies 243 failed attempts across 900 trials on SWE-bench Verified.
- It identifies a failure taxonomy across five stages of a repair pipeline.

**Key Evidence**:

The abstract reports manual analysis of failed attempts and a staged failure taxonomy.

**Relevance to Framework**:

Supports explicit failure-mode tracking, staged quality gates, and repair-loop evaluation.

**Limitations**:

As a recent arXiv preprint, conclusions should be treated as useful but not definitive.

### [SRC-010] Interaction, Process, Infrastructure: A Unified Framework for Human-Agent Collaboration

**Source URL**: https://www.microsoft.com/en-us/research/wp-content/uploads/2025/12/Human_Agent_Framework.pdf  
**Source Type**: Research Paper  
**Collection Time**: 2026-06-08  
**Publication Time**: 2025-12  
**Credibility**: Medium-High

**Relevant Claims**:

- Human-agent collaboration requires explicit representation and management of collaborative work structure.
- The paper elevates process to a first-class concern.
- It argues that many current systems focus on AI-to-AI or AI-to-tool orchestration while sidelining humans.
- Professional workflows evolve as goals and constraints shift.

**Key Evidence**:

The introduction frames missing process representation as a root problem in current human-agent systems.

**Relevance to Framework**:

Strongly supports the proposal's emphasis on process, artifacts, human gates, and adaptive collaboration.

**Limitations**:

This is conceptual research rather than a validated software delivery framework.

### [SRC-011] GitHub Copilot Cloud Agent Overview

**Source URL**: https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-cloud-agent  
**Source Type**: Official Documentation  
**Collection Time**: 2026-06-08  
**Publication Time**: Continuously updated documentation  
**Credibility**: High

**Relevant Claims**:

- Copilot cloud agent can research a repository, create implementation plans, fix bugs, implement incremental features, improve tests, update docs, and address technical debt.
- It works in an ephemeral GitHub Actions-powered development environment.
- It can plan and make code changes on a branch before opening a pull request.
- GitHub emphasizes PR workflow transparency, logs, commits, and metrics such as created/merged pull requests and median time to merge.

**Key Evidence**:

The docs describe background task delegation, branch work, PR creation, logs, and usage metrics.

**Relevance to Framework**:

Supports the proposal's distinction between coding executor and orchestration/process layer.

**Limitations**:

This documents one product workflow and should not be treated as a universal architecture.

### [SRC-012] GitHub Copilot Output Review

**Source URL**: https://docs.github.com/en/copilot/how-tos/copilot-on-github/use-copilot-agents/review-copilot-output  
**Source Type**: Official Documentation  
**Collection Time**: 2026-06-08  
**Publication Time**: Continuously updated documentation  
**Credibility**: High

**Relevant Claims**:

- Copilot pull requests should receive the same thorough review as any contribution.
- A user's approval of a Copilot PR may not count toward required PR approvals.
- GitHub Actions workflows do not run automatically by default when Copilot pushes changes.
- Reviewers should inspect workflow changes before approving privileged CI execution.

**Key Evidence**:

The docs explicitly require careful PR review and human approval for workflow runs.

**Relevance to Framework**:

Supports independent human review, CI permission gates, and special caution around `.github/workflows/` changes.

**Limitations**:

This is specific to GitHub's product controls.

## Gaps and Recommended Follow-Up Sources

- More empirical evidence on team-level AI coding adoption in closed-source enterprise codebases.
- More direct studies on multi-agent software delivery workflows, not only single-agent issue resolution.
- Security research on prompt injection and agentic workflow injection in CI/CD.
- Case studies comparing spec-driven AI workflows versus ad hoc coding-agent usage.
- Team Skill or prompt package maintenance practices across organizations.

