# ADR Query Prompt

> **Generic prompt. Load `projects/{{PROJECT_NAME}}/AGENTS.md` first.**
> Use this prompt when starting a new feature or tech spec to discover existing architectural decisions that apply.

---

## Required Context

| File | Purpose |
|---|---|
| `projects/{{PROJECT_NAME}}/AGENTS.md` | Project prefix, tech stack |
| `projects/{{PROJECT_NAME}}/adr/` | All existing ADR files |

---

## Inputs

| Input | Required |
|---|---|
| `{{PROJECT_NAME}}` | Yes |
| `{{QUERY_TOPIC}}` | Yes — the area of interest (e.g., "database access", "authentication", "error handling", "logging") |
| `{{FEATURE_SLUG}}` | Optional — narrows results to ADRs relevant to a specific feature |

---

## Query Instructions

1. Read all ADR files in `projects/{{PROJECT_NAME}}/adr/`.
2. Filter to those whose **Feature / Context Area** or **Context** section is relevant to `{{QUERY_TOPIC}}`.
3. Exclude ADRs with status `Deprecated`.
4. For ADRs with status `Superseded`, include only the superseding ADR, not the original.

---

## Output Format

Produce a Markdown summary with two sections:

### Directly Applicable ADRs

For each matching ADR:

```
**ADR-{{ID}}** — {{Title}}
Status: {{Status}} | Date: {{Date}}
Decision: {{one-sentence decision}}
Compliance: {{key compliance note}}
```

### Possibly Relevant ADRs

ADRs that partially overlap — list ID, title, and one sentence on why it may apply.

### No Matching ADRs

If no ADRs are relevant, state that explicitly and note that a new ADR may be needed before proceeding.

---

## How to Use Results

- Load directly applicable ADRs as context before running `core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md`
- Reference their IDs in the tech spec under the "Architectural Constraints" section
- If the current task would violate an `Accepted` ADR, raise a flag before writing code — do not proceed without team sign-off
