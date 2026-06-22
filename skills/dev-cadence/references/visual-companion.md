# Visual Companion

Use this reference when visual inspection or visual comparison would materially improve intent alignment during `intake`, `requirements`, or design-sensitive clarification.

This is an optional capability. It is not a mode, gate, or substitute for requirements.

## When to Use

Use the visual companion when the question is easier to answer by seeing the options:

- UI mockups, wireframes, layouts, navigation, or component structure;
- architecture, state, data-flow, or relationship diagrams;
- side-by-side visual alternatives;
- visual hierarchy, spacing, or look-and-feel decisions.

Do not use it for:

- text-only requirements;
- scope and non-goal clarification;
- ordinary backend behavior;
- simple bugfixes;
- tradeoff lists or conceptual choices that are clearer in text.

A topic being about UI is not enough. Use the companion only when the specific question benefits from visual treatment.

## Consent and Gate Boundary

Offer the companion before using it when upcoming questions will likely be visual:

```text
Some of what we are working on might be easier to explain if I can show it in a local browser. I can put together mockups, diagrams, comparisons, and other visuals as we go. Want to try it? This requires opening a local URL.
```

Ask this as its own message. If the user declines, continue text-only.

Do not make companion usage a G1 requirement. G1 passes on clarified intent, accepted requirements, and named Human decisions, not on whether a browser session was opened.

## Environment Requirements

The scripts use Node.js built-in modules only. No `npm install` is required.

Required:

- `node`;
- shell access to run the scripts;
- a browser that can reach the printed local URL.

If any requirement is missing or the URL is unreachable, use the fallback path.

## Start a Session

From the skill directory:

```bash
scripts/visual-companion/start-server.sh --project-dir /path/to/project
```

The script prints JSON:

```json
{"type":"server-started","port":52341,"url":"http://localhost:52341","screen_dir":"/path/to/project/.dev-cadence/visual-companion/123/content","state_dir":"/path/to/project/.dev-cadence/visual-companion/123/state"}
```

Record `screen_dir`, `state_dir`, `url`, and the session directory in Harness evidence when this runs inside a Dev Cadence task.

If persistent project files are not desired, omit `--project-dir`; the session is created under `/tmp` and removed by `stop-server.sh`.

For remote or containerized environments:

```bash
scripts/visual-companion/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

If the environment reaps background processes, use foreground mode and keep the command session alive:

```bash
scripts/visual-companion/start-server.sh --project-dir /path/to/project --foreground
```

The script auto-selects foreground mode in known Codex-style environments through `CODEX_CI`.

## Interaction Loop

1. Check that `$STATE_DIR/server-info` exists and `$STATE_DIR/server-stopped` does not exist.
2. Write a new `.html` file to `screen_dir`.
3. Tell the user what is on screen, give the URL, and ask them to respond in the terminal after viewing or clicking.
4. On the next turn, read `$STATE_DIR/events` if it exists.
5. Merge browser events with terminal feedback. Terminal feedback remains primary.
6. Iterate with a new filename or return to text-only work.

Never reuse screen filenames. Use semantic names:

```text
layout.html
layout-v2.html
architecture-options.html
visual-style.html
```

## Writing Screens

Write content fragments by default. The server wraps fragments in the frame template and injects the client helper.

Minimal example:

```html
<h2>Which layout communicates the workflow better?</h2>
<p class="subtitle">Consider scanability and handoff clarity.</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Linear Pipeline</h3>
      <p>Best when the workflow is mostly sequential.</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>State Machine</h3>
      <p>Best when gates, loops, and blocked states matter.</p>
    </div>
  </div>
</div>
```

Only write a full HTML document when you need full page control.

## Events

Browser interactions are appended to:

```text
$STATE_DIR/events
```

Format:

```jsonl
{"type":"click","choice":"a","text":"A Linear Pipeline Best when...","timestamp":1706000101}
```

When a new screen file is added, the server clears previous events. If no events file exists, use only terminal feedback.

## Fallback Path

If the server cannot start, Node is unavailable, the user cannot open the URL, or the session is interrupted:

1. Record the failure and reason in Harness evidence when a task is active.
2. Continue with text-only clarification.
3. Use Markdown tables, ASCII diagrams, or Mermaid-style diagrams in documents when useful.
4. Do not block G1 solely because visual companion was unavailable.

## Cleanup

Stop a session:

```bash
scripts/visual-companion/stop-server.sh "$SESSION_DIR"
```

`/tmp` sessions are deleted on stop. Sessions under `.dev-cadence/visual-companion/` persist for later review.

When initializing or maintaining a repository, ensure `.dev-cadence/visual-companion/` is ignored if persistent sessions are used.

## Harness Evidence

When used inside Dev Cadence task execution, record:

```yaml
visual_companion:
  used: true
  session_dir:
  url:
  screens:
  events_file:
  fallback_used:
  fallback_reason:
```

Do not treat click events as final acceptance. They are clarification evidence that must be reconciled into requirements, design, or a named Human Gate decision.
