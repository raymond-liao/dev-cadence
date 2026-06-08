# AI Native Development Framework Study

This directory contains a declarative multi-agent research system for systematically studying the AI Native Development Framework proposal.

The research goal is to strengthen the framework before turning it into a reusable team Skill or implementation blueprint.

## Research Topic

Systematic research on a Supervisor-controlled, artifact-first, spec-driven, quality-gated multi-agent software development framework.

## Core Questions

1. Is the framework conceptually coherent as a development collaboration model?
2. Are the proposed Agent roles, workflow stages, quality gates, and human approval points sufficient for practical software delivery?
3. What should be included in the first reusable team Skill, and what should be deferred to later platformization?
4. What risks, failure modes, and evaluation criteria should guide the MVP?
5. How should the current proposal be revised based on research findings?

## Directory Structure

```text
agents/
  00.orchestrator.md
  01.framework_mapper.md
  02.external_researcher.md
  03.comparative_analyst.md
  04.skill_delivery_designer.md
  05.risk_and_evaluation_analyst.md
  06.argument_verifier.md
  07.reporter.md
references/
  domain/
    current-proposal.md
  methodology/
    research-overview.md
    data-sources.md
    analysis-methods.md
    output-template.md
workspace/
  01.materials/
  02.analysis/
  03.verification/
  04.reports/
_output/
wip/
  notes.md
```

## How to Run

Use an intelligent coding/research runtime from this project root and ask it:

```text
Please read `research/ai-native-development-framework-study/agents/00.orchestrator.md`
and execute strictly according to that Blueprint.

Parameters:
- PROJECT_ID: ai-native-development-framework-study
- PROJECT_ROOT: research/ai-native-development-framework-study
- REPORT_LANGUAGE: Chinese
- RESEARCH_DEPTH: MVP-oriented systematic study
```

The Orchestrator will create intermediate artifacts under `workspace/` and a final report under `workspace/04.reports/`.

## Adopted System Properties

- Agent behavior is defined by Markdown Blueprints.
- Reference knowledge and methodology are externalized under `references/`.
- Agents exchange data through filesystem artifacts.
- Evidence and conclusions are traceable through source IDs and analysis IDs.
- Verification is performed by a separate Agent before final reporting.
