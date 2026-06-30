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

## Four Layers

### Entry Point Validation

Reject obviously invalid input at API, CLI, UI, public function, or task
boundary.

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === "") {
    throw new Error("workingDirectory cannot be empty");
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }

  return initializeProject(name, workingDirectory);
}
```

### Business Logic Validation

Check that data still makes sense for the operation being performed, even when
callers already performed entry validation.

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error("projectDir required for workspace initialization");
  }
  if (!sessionId) {
    throw new Error("sessionId required for workspace initialization");
  }

  return createWorkspace(projectDir, sessionId);
}
```

### Environment Guards

Prevent dangerous operations in contexts where they are unsafe or unintended,
such as tests, CI, production migrations, or local source directories.

```typescript
async function gitInit(directory: string) {
  if (process.env.NODE_ENV === "test") {
    const normalizedDirectory = normalize(resolve(directory));
    const normalizedTemp = normalize(resolve(tmpdir()));

    if (!normalizedDirectory.startsWith(normalizedTemp)) {
      throw new Error(`Refusing git init outside temp dir during tests: ${directory}`);
    }
  }

  await execFile("git", ["init"], { cwd: directory });
}
```

### Diagnostic Evidence

Log or record enough context to diagnose future failures without guessing.

```typescript
async function gitInit(directory: string) {
  logger.debug("About to git init", {
    directory,
    cwd: process.cwd(),
    stack: new Error().stack,
  });

  await execFile("git", ["init"], { cwd: directory });
}
```

## Example Flow

Bug: an empty project directory caused a dangerous operation to run in the
source tree.

Data flow:

1. Test setup produced an empty string.
2. Public project creation accepted the empty path.
3. Workspace initialization propagated it.
4. The dangerous operation interpreted it as the current working directory.

Defense:

- entry validation rejected empty and non-directory paths;
- business logic validation rejected missing project state even when callers
  bypassed entry validation;
- environment guards refused dangerous test operations outside temporary
  directories;
- diagnostics captured path, cwd, and stack when future failures occur.

Test each layer by attempting to bypass the previous one. Do not assume a
single validation point proves the class of bug is gone.

## Warning

Do not stop at one validation point when the failure mode is dangerous. Add
enough layers that the same class of bug cannot silently reach the dangerous
operation again.
