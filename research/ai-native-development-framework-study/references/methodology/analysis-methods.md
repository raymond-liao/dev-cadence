# Analysis Methods Guide

## Analysis Framework

Use five complementary analysis lenses:

1. Conceptual coherence.
2. Software delivery alignment.
3. Multi-agent workflow design.
4. Skill delivery design.
5. Risk, evaluation, and adoption path.

## Required Analysis Products

### Framework Map

Output path:

```text
workspace/01.materials/framework_map.md
```

Purpose:

- Extract the current proposal's core concepts.
- Identify assumptions, design principles, roles, artifacts, workflows, gates, and open questions.

### External Research Notes

Output path:

```text
workspace/01.materials/external_sources.md
```

Purpose:

- Collect relevant external evidence if browsing or local references are available.
- Record source IDs and credibility.
- Do not rely on search snippets alone.

### Comparative Analysis

Output path:

```text
workspace/02.analysis/comparative_analysis.md
```

Purpose:

- Compare the proposal with established software delivery practices.
- Identify where the proposal is aligned, where it diverges, and where clarification is needed.

### Skill Delivery Design

Output path:

```text
workspace/02.analysis/skill_delivery_design.md
```

Purpose:

- Define what the reusable team Skill should contain.
- Separate MVP Skill scope from later platform scope.
- Identify required references, templates, and generated repo-local artifacts.

### Risk and Evaluation Analysis

Output path:

```text
workspace/02.analysis/risk_and_evaluation.md
```

Purpose:

- Identify failure modes.
- Define MVP experiments and evaluation metrics.
- Recommend quality gates and human escalation rules.

### Argument Verification

Output path:

```text
workspace/03.verification/argument_verification_report.md
```

Purpose:

- Verify that analysis conclusions are supported by internal or external evidence.
- Flag overclaims, missing citations, contradictions, and weak assumptions.

### Final Report

Output path:

```text
workspace/04.reports/final_report.md
```

Purpose:

- Synthesize all analysis into a proposal-improvement research report.
- Include prioritized recommendations and next-step plan.

## Analysis Quality Requirements

- Clearly distinguish facts, interpretations, and recommendations.
- Every major conclusion must cite either `SRC-PROPOSAL-README`, a collected `SRC-*` source, or a generated analysis artifact ID.
- Prefer specific design changes over generic advice.
- Preserve uncertainty when evidence is insufficient.
- Include tradeoffs, not only benefits.

## Analysis ID Format

Use IDs for major analysis findings:

```text
ANA-MAP-001
ANA-CMP-001
ANA-SKILL-001
ANA-RISK-001
```

Each finding should include:

```markdown
## [ANA-XXX] Finding Title

**Evidence**:
**Reasoning**:
**Implication**:
**Recommendation**:
```

