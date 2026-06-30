# Defense-in-Depth Validation

Use this technique when a bug is caused by invalid data, unsafe state, missing
boundary checks, or a dangerous operation reached with bad inputs.

## Core Rule

Validate at every layer where invalid data can enter, transform, or become
dangerous. Make the bug structurally difficult to reintroduce.

## Why Multiple Layers

One validation point can be bypassed by a different code path, a mock, a
future refactor, or a platform-specific edge case. Multiple layers catch
different failure modes:

- entry validation catches bad external input;
- business logic validation catches inconsistent internal state;
- environment guards prevent context-specific dangerous operations;
- diagnostics make future failures explainable.

## Process

1. Trace the data flow from original input to dangerous operation.
2. List every checkpoint the data passes through.
3. Add validation at the source and at dangerous downstream boundaries.
4. Add environment guards when a dangerous operation must not run in tests, CI,
   production, migrations, or other sensitive contexts.
5. Add diagnostic evidence when future failures would be hard to understand.
6. Test attempts to bypass earlier layers.
7. Record which layer catches which failure.

## Layer Checklist

### Entry Point Validation

Reject obviously invalid input at API, CLI, UI, public function, or task
boundary.

### Business Logic Validation

Check that data still makes sense for the operation being performed.

### Environment Guards

Prevent dangerous operations in contexts where they are unsafe or unintended.

### Diagnostic Evidence

Log or record enough context to diagnose future failures without guessing.

## Warning

Do not stop at one validation point when the failure mode is dangerous. Add
enough layers that the same class of bug cannot silently reach the dangerous
operation again.
