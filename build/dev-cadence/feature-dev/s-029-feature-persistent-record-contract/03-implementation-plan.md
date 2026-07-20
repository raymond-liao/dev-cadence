# S-029 Feature Persistent Record Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give confirmed feature-dev Requirements and Technical Solution records verifiable identities and deterministic interruption recovery.

**Architecture:** Keep manifest as run index, requirements as scope authority, and technical solution as design authority. Add a feature-dev-only read-only Bash validator that calculates the earliest recovery target from confirmation continuity and record identities.

**Tech Stack:** Bash, Git, `rg`, `awk`, `shasum -a 256`, temporary Git fixture tests.

## Global Constraints

- Modify only `src/workflows/feature-dev/**`, `tests/**`, `version`, and this S-029 run directory.
- Do not change Bug Fix, Refactor, vendored Superpowers, Story content, Backlog, or tracked `dist/` files.
- Create only `src/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh`; it is read-only and must not choose workflows, write records, or replace user confirmation.
- Use repository-relative paths and lowercase SHA-256. Stage Table remains the sole owner of confirmation and checkpoint facts.
- Identity validation and the existing Pre-Implementation Design Freshness Gate remain separate gates.
- Update `version` from `0.28.0` to `0.29.0`, then use `bash scripts/build.sh` to generate ignored distribution files.

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Fixture RED | Define recovery behavior first | `tests/feature-persistent-record-recovery-contract.sh` | Fixture fails because validator is missing |
| Task 2: Validator GREEN | Implement feature-only recovery target calculation | validator script and fixture test | Fixture mode passes nine cases |
| Task 3: Workflow/package integration | Publish source and install contract | workflow skill, runner/package/install tests, version | Focused checks pass |
| Task 4: Full regression | Generate dist and verify repository compatibility | generated `dist/.dev-cadence/**` | `bash scripts/check-all.sh` passes |

## Detailed Tasks

### Task 1: Fixture RED

**Files:**
- Create: `tests/feature-persistent-record-recovery-contract.sh`

**Interfaces:**
- Consumes: `src/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh RUN_DIR`.
- Produces: `Recovery Target: Requirements Confirmation`, `Recovery Target: Technical Solution`, or `Recovery Target: Implementation Plan`, plus the matching fixed `Reason` value.

- [x] **Step 1: Create temporary-Git fixture helpers and expected targets.**

Begin the file with `#!/usr/bin/env bash`, `set -euo pipefail`, `ROOT_DIR`, `VALIDATOR`, `fail`, `assert_contains`, `sha256_file`, `init_repo`, `write_file`, `commit_paths`, `write_requirements`, `write_solution`, and `write_manifest`. `sha256_file` must use `shasum -a 256 "$1" | awk '{print $1}'`. The fixture manifest must contain both the fixed Stage Table header and `Confirmed Stage Record Identities` with `Stage | Record Path | SHA-256`.

Implement these exact cases: requirements-only hash checkpoint returns `Technical Solution` / `requirements identity is valid`; two confirmed stages return `Implementation Plan` / `requirements and technical solution identities are valid`; requirements-only skipped checkpoint returns `Technical Solution`; missing `## 验收标准`, requirements SHA mismatch, work-item drift, and dependency drift return `Requirements Confirmation`; mismatched solution requirements identity returns `Technical Solution`; Solution confirmed before Requirements returns `Requirements Confirmation` / `stage confirmation is not continuous`.

Default mode must assert `src/workflows/feature-dev/SKILL.md` contains `Confirmed Stage Record Identities`, `validate-persistent-record-recovery.sh`, `SHA-256`, `Requirements Confirmation`, `Technical Solution`, and `Pre-Implementation Design Freshness Gate`.

- [x] **Step 2: Run RED and preserve the evidence.**

Run `bash tests/feature-persistent-record-recovery-contract.sh fixtures`. Expected: exit `1` because the validator is absent. Record command, exit status, and missing-validator evidence in `04-implementation-record.md`; do not weaken any case.

### Task 2: Validator GREEN

**Files:**
- Create: `src/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh`
- Test: `tests/feature-persistent-record-recovery-contract.sh`

**Interfaces:**
- Consumes: a feature-dev run directory with manifest, records, checkpoints, and direct input identities.
- Produces: exit `0` and the two fixed target/reason output lines.

- [x] **Step 1: Implement the script entry and parser.**

Use `set -euo pipefail`; define `fail`, `target`, and `sha256_file`; require exactly one `RUN_DIR`; require `manifest.md`; resolve `repo_root` using `git -C "$run_dir" rev-parse --show-toplevel`. Parse only the fixed Stage Table and identity-table headers with `awk -F'|'`, extracting canonical status values from backticks. A confirmed stage after an unconfirmed predecessor returns the earliest predecessor with reason `stage confirmation is not continuous`.

- [x] **Step 2: Implement Requirements validation.**

For a confirmed Requirements stage, require a relative path and 64-character lowercase SHA-256, reject absolute or `../` paths, validate current file hash, Git checkpoint tree when the checkpoint is a hash, and direct input relative paths plus SHA-256. A `skipped` checkpoint omits only the tree lookup. Require these fields: `工作项`, `工作项类型`, `工作项 Version`, `当前 Status`, `selected scope`, `## 目标`, `## ✅ 范围`, `## ❌ 非范围`, `## 验收标准`, `## 业务规则`, `假设`, `Open Questions`, and `直接依赖输入身份`. Any failure returns `Requirements Confirmation` with its specific reason. Unconfirmed Requirements returns `Requirements Confirmation` / `requirements are not confirmed` without requiring records.

- [x] **Step 3: Implement Solution validation and GREEN.**

After valid Requirements and unconfirmed Solution, return `Technical Solution` / `requirements identity is valid`; missing solution is normal. For confirmed Solution validate identity, SHA, checkpoint, and `已确认需求来源`, `Requirements SHA-256`, `已选方案`, `备选方案`, `受影响边界`, `关键约束`, `Open Questions`, `验收标准到验证策略映射`. Its requirements path and SHA must match the validated identity; mismatch returns `Technical Solution` / `solution requirements identity mismatch`; success returns `Implementation Plan` / `requirements and technical solution identities are valid`.

Run `chmod +x src/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh` and `bash tests/feature-persistent-record-recovery-contract.sh fixtures`. Expected: all nine cases pass. Stage only validator and focused test, run `git diff --cached --check`, then commit `feat(flow): validate feature record recovery`.

### Task 3: Workflow and Package Integration

**Files:**
- Modify: `src/workflows/feature-dev/SKILL.md:189-232`
- Modify: `src/workflows/feature-dev/SKILL.md:316-365`
- Modify: `tests/run-all.sh`, `tests/package-contract.sh`, `tests/install-contract.sh`, `version`
- Test: `tests/feature-persistent-record-recovery-contract.sh`

**Interfaces:**
- Consumes: Task 2 validator and fixtures.
- Produces: source/dist/install contract at version `0.29.0`.

- [x] **Step 1: Run source-contract RED.**

Run `bash tests/feature-persistent-record-recovery-contract.sh`. Expected: exit `1` because feature-dev has not declared the identity table and recovery command; fixture mode remains GREEN.

- [x] **Step 2: Add the confirmed feature-dev rules.**

Add `Confirmed Stage Record Identities` with `Stage | Record Path | SHA-256`, written only after Requirements/Solution confirmation. State that manifest never copies record bodies and Stage Table retains confirmation/checkpoint. Add the command whose second argument is the active run directory under `build/dev-cadence/feature-dev/`, immediately after the fixed validator path `.dev-cadence/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh`. Specify manifest-first continuous confirmation, requirements-only normal recovery, two-stage plan recovery, earliest-stage fallback, direct-input drift, and continued use of the existing freshness gate. Add the precise Requirements and Solution field lists from Task 2. Do not modify Bug Fix or Refactor.

- [x] **Step 3: Add test/package/install/version integration.**

Insert `bash "$ROOT_DIR/tests/feature-persistent-record-recovery-contract.sh"` after `delivery-record-contract.sh` in `tests/run-all.sh`. Add `dist/.dev-cadence/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh` to required package files and source/dist `assert_same_file`. Add first-install `test -f` and update-install `cmp -s` for `workflows/feature-dev/scripts/validate-persistent-record-recovery.sh`. Replace `version` with `0.29.0`.

- [x] **Step 4: Run integration GREEN and commit.**

Run `bash scripts/build.sh`, the default new contract test, `bash tests/package-contract.sh`, and `bash tests/install-contract.sh`. Expected: each exits `0`; `dist/` remains unstaged. Stage only Task 3 source/test/version paths, run `git diff --cached --check`, then commit `feat(flow): preserve feature record identities`.

### Task 4: Full Regression

**Files:**
- Generated: `dist/.dev-cadence/workflows/feature-dev/SKILL.md`
- Generated: `dist/.dev-cadence/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh`

- [x] **Step 1: Build and prove source/dist parity.**

Run `bash scripts/build.sh`; search both source and dist feature skills for `Confirmed Stage Record Identities`, `validate-persistent-record-recovery.sh`, and `SHA-256`; then compare the source and distribution validator with `cmp -s`. Expected: all rules occur in both skills and the script comparison exits `0`.

- [x] **Step 2: Run full regression and scope review.**

Run `git diff --check`, `bash scripts/check-whitespace.sh`, `bash scripts/check-all.sh`, `git diff --name-only e31db56b88aabdf6854bbc8454101d24e01a852a..HEAD`, and `git status --short`. Expected: all checks pass; committed scope contains only S-029 source/test/version changes and S-029 records; dist remains ignored and unstaged.

## Plan Self-Review

- Spec coverage: Tasks 1-3 cover all six S-029 criteria; Task 4 proves source/dist/install synchronization.
- Placeholder scan: every action names exact files, commands, field names, target stages, and expected reasons.
- Interface consistency: all tasks use the same target/reason output, identity table, SHA algorithm, canonical stage names, and `skipped` handling.
- Completion condition: RED is recorded, focused and full checks are GREEN, and each implementation commit receives staged-only review evidence.

## Stage Decision

- Status: ✅ `confirmed`
- User confirmation: `user selected option 1 at 2026-07-20T17:35:04+0800`
- Decision: 按本计划开始 Development Implementation。
