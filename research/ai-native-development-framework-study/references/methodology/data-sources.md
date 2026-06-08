# Data Sources Guide

## Internal Sources

### Current Proposal

- ID: `SRC-PROPOSAL-README`
- Location: root `README.md`
- Priority: High
- Credibility: Authoritative for the current project intent
- Use: Framework goals, principles, architecture, roles, workflows, Skill delivery shape, MVP roadmap

## External Source Types

External sources are optional but recommended for a high-quality run.

### Official Documentation

- Priority: High
- Credibility: High
- Examples: vendor docs for agent frameworks, coding agents, CI platforms, model APIs
- Use: Verify tool capabilities and integration constraints

### Academic or Industry Research

- Priority: High
- Credibility: Medium-High to High
- Examples: papers or reports about agentic software engineering, AI coding agents, software quality, human-AI collaboration
- Use: Compare framework assumptions against existing research

### Engineering Practice References

- Priority: Medium-High
- Credibility: Medium-High
- Examples: documentation on ADR, trunk-based development, code review, CI/CD, platform engineering, incident management
- Use: Ground the framework in known software delivery practices

### Product or Community Examples

- Priority: Medium
- Credibility: Medium
- Examples: public examples of AI coding workflows, agent platforms, team automation playbooks
- Use: Identify practical patterns and failure modes

## Sources to Use Cautiously

- Unsourced blog posts.
- Marketing claims without technical details.
- Benchmarks without methodology.
- Social media anecdotes.
- Search result snippets not backed by fetched source content.

## Source Recording Format

Each collected external source must be recorded as:

```markdown
## [SRC-XXX] Title

**Source URL**:
**Source Type**:
**Collection Time**:
**Publication Time**:
**Credibility**: High / Medium-High / Medium / Low

**Relevant Claims**:

**Key Evidence**:

**Relevance to Framework**:

**Limitations**:
```

## Citation Rules

- Every non-trivial external claim must cite a `SRC-*` ID.
- Current proposal claims should cite `SRC-PROPOSAL-README`.
- If external browsing is unavailable, explicitly mark external research as not executed and avoid inventing sources.

