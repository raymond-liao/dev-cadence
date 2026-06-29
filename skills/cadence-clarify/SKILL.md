---
name: cadence-clarify
description: Clarify delivery intent, requirements, and design before planning or implementation. Use for feature requests, behavior changes, ambiguous fixes, design-sensitive work, UI or visual alignment, unclear expected behavior, missing acceptance criteria, or any task that needs requirements readiness.
---

# Cadence Clarify

Help turn delivery ideas into approved requirements and designs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the goal. Once you understand what should change, present the requirements or design and get Human approval.

<HARD-GATE>
Do NOT plan implementation, write code, scaffold work, invoke execution Skills, or take implementation action until requirements readiness is satisfied and the named Human has approved the clarified intent. For design-sensitive work, do not proceed until the design or accepted option is approved. This applies to every delivery task regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every delivery task goes through this process. A single-function utility, a config change, or a narrow fix can have a short clarification, but it still needs explicit enough scope, non-goals, acceptance criteria, and verification to prevent invented requirements.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context with limited read-only analysis** — check files, docs, and recent commits only enough to clarify the request
2. **Offer the visual companion just-in-time** — NOT upfront. The first time a question would genuinely be clearer shown than described, offer it then (its own message); on approval its browser tab opens for you. If no visual question ever arises, never offer it. See the Visual Companion section below.
3. **Assess scope size. If the request spans independent subsystems or is too large for one delivery task, propose decomposition** — pick the first approved sub-task before continuing
4. **Ask focused clarification questions one at a time.** Understand goal, constraints, non-goals, success criteria, and verification
5. **Present 2-3 viable interpretations or approaches with tradeoffs and a recommendation** when the request has meaningful alternatives
6. **Present requirements or design in sections scaled to complexity** and get Human approval after each section when needed
7. **Spec self-review** — quick inline check for placeholders, contradictions, ambiguity, scope (see below)
8. **Ask the Human to review the written artifacts when persistent artifacts are used.**
9. **Transition to planning handoff** — return to `using-dev-cadence` with evidence, gate status, unresolved blockers, and a recommendation for `cadence-plan`

## Process Flow

```dot
digraph cadence-clarify {
    "Explore project context" [shape=box];
    "Scope needs decomposition?" [shape=diamond];
    "Ask clarifying questions" [shape=box];
    "Propose 2-3 approaches" [shape=box];
    "Present design sections" [shape=box];
    "User approves design?" [shape=diamond];
    "Write/update artifacts if needed" [shape=box];
    "Spec self-review\n(fix inline)" [shape=box];
    "Human reviews artifacts?" [shape=diamond];
    "Handoff to using-dev-cadence\nrecommend cadence-plan" [shape=doublecircle];

    "Explore project context" -> "Scope needs decomposition?";
    "Scope needs decomposition?" -> "Ask clarifying questions" [label="no"];
    "Scope needs decomposition?" -> "Present design sections" [label="yes, decompose"];
    "Ask clarifying questions" -> "Propose 2-3 approaches";
    "Propose 2-3 approaches" -> "Present design sections";
    "Present design sections" -> "User approves design?";
    "User approves design?" -> "Present design sections" [label="no, revise"];
    "User approves design?" -> "Write/update artifacts if needed" [label="yes"];
    "Write/update artifacts if needed" -> "Spec self-review\n(fix inline)";
    "Spec self-review\n(fix inline)" -> "Human reviews artifacts?";
    "Human reviews artifacts?" -> "Write/update artifacts if needed" [label="changes requested"];
    "Human reviews artifacts?" -> "Handoff to using-dev-cadence\nrecommend cadence-plan" [label="approved"];
}
```

**The terminal state is a handoff to `using-dev-cadence` recommending `cadence-plan`.** Do not invoke `cadence-plan`, `cadence-executing-plans`, `cadence-tdd`, or implementation actions directly from this Skill.

## The Process

**Understanding the idea:**

- Check out the current project state first with limited read-only analysis (files, docs, recent commits)
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately. Don't spend questions refining details of a project that needs to be decomposed first.
- If the project is too large for a single delivery task, help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built? Then clarify the first approved sub-project through the normal design flow. Each sub-project gets its own requirements/design -> plan -> implementation cycle.
- For appropriately-scoped projects, ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**

- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

**Design for isolation and clarity:**

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit, you should be able to answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.
- Smaller, well-bounded units are also easier for you to work with - you reason better about code you can hold in context at once, and your edits are more reliable when files are focused. When a file grows large, that's often a signal that it's doing too much.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work (e.g., a file that's grown too large, unclear boundaries, tangled responsibilities), include targeted improvements as part of the design - the way a good developer improves code they're working in.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

## After the Design

**Documentation:**

- For standard or high-risk tasks, write or update task artifacts under `specs/records/{task_id}/`, especially `00-brief.md`, `01-requirements.md`, and `02-design.md`.
  - User or repository preferences for artifact location override this default.
- Do not commit artifacts unless the Human explicitly asks for a commit.

**Spec Self-Review:**
After writing the spec document, look at it with fresh eyes:

1. **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency:** Do any sections contradict each other? Does the architecture match the feature descriptions?
3. **Scope check:** Is this focused enough for a single implementation plan, or does it need decomposition?
4. **Ambiguity check:** Could any requirement be interpreted two different ways? If so, pick one and make it explicit.

Fix any issues inline. No need to re-review — just fix and move on.

**User Review Gate:**
After the spec review loop passes, ask the Human to review the written artifacts before handoff:

> "Artifacts written to `<path>`. Please review them and let me know if you want changes before I hand this back for planning."

Wait for the Human response. If they request changes, make them and re-run the spec review loop. Only hand off as ready for planning when the Human approves the clarified requirements and required design.

**Implementation:**

- Return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state.
- Do not select the next cadence Skill from here.

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Multiple choice preferred** - Easier to answer than open-ended when possible
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design, get approval before moving on
- **Be flexible** - Go back and clarify when something doesn't make sense

## Visual Companion

Visual companion is optional and just-in-time. It is a browser-based companion for showing mockups, diagrams, and visual options during cadence-clarify. Available as a tool, not a mode. Accepting the companion means it's available for questions that benefit from visual treatment; it does NOT mean every question goes through the browser.

**Offering the companion (just-in-time):** Do NOT offer it upfront. Wait until a question would genuinely be clearer shown than told — a real mockup / layout / diagram question, not merely a UI *topic*. The first time that happens, offer it then, as its own message:
> "This next part might be easier if I show you — I can put together mockups, diagrams, and comparisons in a browser tab as we go. It's still new and can be token-intensive. Want me to? I'll open it for you."

**This offer MUST be its own message.** Only the offer — no clarifying question, summary, or other content. Wait for the user's response. If they accept, start the server and give them the returned URL. If they decline, continue text-only and don't offer again unless they raise it.

**Per-question decision:** Even after the user accepts, decide FOR EACH QUESTION whether to use the browser or the terminal. The test: **would the user understand this better by seeing it than reading it?**

- **Use the browser** for content that IS visual — mockups, wireframes, layout comparisons, architecture diagrams, side-by-side visual designs
- **Use the terminal** for content that is text — requirements questions, conceptual choices, tradeoff lists, A/B/C/D text options, scope decisions

A question about a UI topic is not automatically a visual question. "What does personality mean in this context?" is a conceptual question — use the terminal. "Which wizard layout works better?" is a visual question — use the browser.

If they agree to the companion, read the detailed guide before proceeding:
`skills/cadence-clarify/visual-companion.md`

## Human Review Gate

Only hand off as ready for planning when the Human approves the clarified requirements and required design. If unresolved ambiguity could materially change implementation or acceptance, enter Human Gate `info_required` and block implementation.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
