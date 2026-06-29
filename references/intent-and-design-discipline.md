# Intent and Design Discipline

Use this reference in `intake`, `requirements`, and design-sensitive states before product edits.

## Core Rule

Do not start implementation until the requested outcome, scope, non-goals, constraints, expected behavior, acceptance criteria, and verification approach are clear enough to build and review.

If ambiguity could materially change implementation or acceptance, enter Human Gate `info_required`.

## Context First

Before asking broad clarification questions:

1. Inspect relevant repository instructions, docs, existing specs, tests, and code.
2. Identify evidence paths that may explain the request.
3. Prepare candidate interpretations.
4. Recommend one option when evidence supports it.

Ask the user to choose or correct a concrete interpretation. Do not make the user discover the ambiguity from scratch.

## Clarification Checklist

Complete before G1 passes:

- goal is explicit;
- scope is explicit;
- non-goals are explicit;
- users or stakeholders are known when relevant;
- expected behavior is explicit;
- reference behavior or comparison dimension is explicit when the request uses comparative wording;
- acceptance criteria are testable or reviewable;
- constraints and risks are recorded;
- assumptions are separated from accepted requirements;
- unresolved questions are recorded;
- named Human decision is recorded when clarification was required.

## Design Check

Use design or ADR before implementation when the task touches:

- public contracts;
- architecture or module boundaries;
- data model, schema, persistence, or migrations;
- security, permissions, secrets, CI/CD, release, or production behavior;
- cross-module behavior;
- broad refactors;
- high-risk operational or compatibility concerns.

Design output should include:

- chosen approach;
- alternatives considered;
- affected components;
- data or control flow;
- risks and mitigations;
- required Human Gate decisions;
- verification implications.

## Spec Self-Review

After writing `01-requirements.md` or `02-design.md`, review it before moving on:

- placeholders such as `TBD`, `TODO`, or incomplete sections;
- internal contradictions;
- requirements that can be interpreted two materially different ways;
- scope too broad for one implementation plan;
- unrequested features or over-engineering;
- assumptions recorded as requirements without Human decision;
- acceptance criteria that cannot be verified.

For a reusable reviewer prompt, use `skills/cadence-clarify/spec-document-reviewer-prompt.md`.

## Visual Companion Boundary

A visual companion can help when seeing the choice materially improves clarification:

- UI layouts, wireframes, navigation, or component structure;
- architecture diagrams or data-flow diagrams;
- side-by-side design alternatives;
- visual hierarchy, spacing, or look-and-feel decisions.

Do not use a visual companion for text-only requirements, ordinary backend work, simple bugfixes, or decisions that are clearer as a written tradeoff table.

Visual companion tooling is an optional capability, not a G1 requirement. G1 passes on clarified requirements and named Human decisions, not on whether a browser session was opened.

When running `cadence-clarify`, load `skills/cadence-clarify/visual-companion.md` before offering or using the browser-based companion. If the environment cannot run it, record the fallback when a task is active and continue text-only.
