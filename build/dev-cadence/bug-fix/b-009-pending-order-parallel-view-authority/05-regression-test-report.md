# B-009 Regression Verification Report

- Status: ✅ `confirmed`
- Verification revision: `9e5983a8bc5ea6be36327d47b05a9b3854551a93`
- Baseline revision: `6e18954624df1df45f9afd9141191b002605b724`

## Regression Matrix

| Requirement | Evidence | Result |
|---|---|---|
| 待处理行顺序唯一权威 | `tests/work-item-planning-contract.sh`, `tests/parallel-work-table-contract.sh` | ✅ `passed` |
| 并行视图保持待处理相对顺序且不独立排序 | Backlog order assertions and source contract | ✅ `passed` |
| 首项不可推进不得静默跳过 | Work Item Planning source contract | ✅ `passed` |
| 并行表无逐行 Workflow / 入口门禁列 | four-column Backlog assertion and absence check | ✅ `passed` |
| 状态只表达生命周期，路由归入口与 workflow | source planning/routing contracts | ✅ `passed` |
| source/dist/version synchronization | build, `cmp`, package contract | ✅ `passed` |
| Existing workflow contract regression | `bash scripts/check-all.sh` | ✅ `passed` |

## Commands And Results

```text
bash tests/work-item-planning-contract.sh       -> Work item planning contract checks passed.
bash tests/parallel-work-table-contract.sh     -> Parallel work table contract checks passed.
bash tests/routing-contract.sh                  -> Routing contract checks passed.
bash scripts/build.sh                           -> exit 0
bash scripts/check-whitespace.sh               -> exit 0
bash scripts/check-all.sh                       -> exit 0; all contract checks passed.
```

## Verification Decision

✅ `ready`: the original B-009 reproduction is covered by passing contracts, the repaired source and generated package agree, and no regression failure or residual blocking finding was observed.

## Residual Risk

This change governs Markdown rules and contract tests; it does not add a runtime automatic order calculator. Future planning edits still require Work Item Planning confirmation as stated by the repaired rule.
