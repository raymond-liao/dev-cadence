# Generated Status Presentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add consistent visual status presentation while preserving canonical workflow status contracts.

**Architecture:** The shared document-conventions skill owns the complete status mapping. Individual workflows name the output surfaces that must apply it, while contract tests verify ownership, symmetry, and canonical preservation.

**Tech Stack:** Markdown skills, Bash contract tests, repository build/install scripts.

## Global Constraints

- Keep canonical status enums unchanged and visible as inline code.
- Do not place emoji in machine-sensitive values.
- Do not directly edit `dist/.dev-cadence`; regenerate it with `bash scripts/build.sh`.

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Status contract | Establish failing coverage for mapping and adoption. | `tests/document-conventions-contract.sh` | Focused test fails for missing rules. |
| Task 2: Shared and workflow rules | Implement single-source mapping and symmetric output guidance. | `src/skills/document-conventions/SKILL.md`, workflow skills | Focused test passes. |
| Task 3: Package and documentation | Synchronize user docs, version, distribution, and dogfood install. | `README.md`, `README.zh-CN.md`, `version`, `dist/` | Full checks and install contract pass. |

## Detailed Tasks

### Task 1: Status contract

- [x] Add literal checks for every required marker/status group and inline-code presentation.
- [x] Add checks that all four workflows apply the shared mapping to generated status summaries.
- [x] Run `bash tests/document-conventions-contract.sh` and confirm failure is caused by missing S-009 behavior.

### Task 2: Shared and workflow rules

- [x] Add the stable mapping and usage boundaries to `document-conventions`.
- [x] Add symmetric generated-status guidance to Feature Dev, Bug Fix, Refactor, and Discovery.
- [x] Run `bash tests/document-conventions-contract.sh` and confirm it passes.
- [x] Run `bash tests/workflow-symmetry.sh` and confirm existing workflow symmetry remains green.

### Task 3: Package and documentation

- [x] Document the user-visible convention in both READMEs.
- [x] Bump the minor version because installable workflow behavior changes.
- [x] Run `bash scripts/build.sh` and verify source/distribution synchronization with `rg --no-ignore`.
- [x] Dogfood install into a temporary target repository and run install/package checks.
- [x] Run `bash scripts/check-whitespace.sh` and `bash scripts/check-all.sh`.
- [x] Perform whole-change review and record the final verification evidence.

## Self-Review

- Spec coverage: every S-009 acceptance criterion maps to Tasks 1-3.
- Placeholder scan: no implementation placeholder remains.
- Interface consistency: the workflows consume the exact shared `document-conventions` mapping and do not own copies.

## Confirmation

Delegated by the user's instruction to proceed without implementation-time confirmation.
