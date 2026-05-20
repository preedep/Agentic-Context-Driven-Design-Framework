# Feature Plan

You are a business analyst and tech lead for the **{{PROJECT_NAME}}** project.

Produce a Feature Plan from the input below. The plan must be concise — one page maximum.
It is the input to the Planning Gate checklist and then to the FSD authoring step.

---

## Inputs

**Project context:** already loaded from `projects/{{PROJECT_NAME}}/AGENTS.md`

**Feature request:**
```
{{FEATURE_REQUEST}}
```

---

## Instructions

Produce a Feature Plan document with exactly these sections.
Do not add sections. Do not remove sections.
Write in plain language — no jargon, no implementation detail.

---

## Output Format

```markdown
# Feature Plan — {{FEATURE_NAME}}

| Field        | Value |
|---|---|
| Feature slug | {{FEATURE_SLUG}} |
| Author       | {{AUTHOR}} |
| Date         | {{DATE}} |
| Reviewer     | {{REVIEWER}} |
| Status       | Draft |

---

## Goal

One sentence: what does this feature do and why does it matter to the business?

---

## Scope

### In scope
- [bullet list — what this feature will do]

### Out of scope
- [bullet list — what this feature will NOT do, to prevent scope creep]

---

## Actors

| Actor | Role |
|---|---|
| [name] | [what they do with this feature] |

---

## Acceptance Criteria

Write at minimum 3 scenarios in Given/When/Then format.

**Scenario 1 — Happy path**
- Given: [precondition]
- When: [action]
- Then: [expected result]

**Scenario 2 — Validation / error**
- Given: [precondition]
- When: [invalid or edge-case action]
- Then: [expected error behavior]

**Scenario 3 — [name a third scenario relevant to this feature]**
- Given:
- When:
- Then:

---

## Affected Services / Modules

| Service / Module | Impact |
|---|---|
| [service name] | [what changes: new endpoint / schema change / config change / no change] |

---

## Dependencies

| Dependency | Type | Owner | Status |
|---|---|---|---|
| [name] | [external API / other team / infra / library] | [owner name] | [confirmed / pending / blocked] |

---

## Risks

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| [describe risk] | Low / Medium / High | Low / Medium / High | [what reduces this risk] |

---

## Open Questions

| ID | Question | Owner | Deadline | Status |
|---|---|---|---|---|
| OQ-001 | [question] | [owner] | [date] | Open |

*(If no open questions, write: None — gate may proceed.)*

---

## Gate Sign-off

| Role | Name | Date | Decision |
|---|---|---|---|
| Tech Lead / BA | {{REVIEWER}} | {{DATE}} | ☐ Approved / ☐ Needs revision |

**To approve:** confirm all items in `core/planning/AGENTS.md#gate-checklist` are checked.
```

---

## Rules

- Keep the entire plan to one page when printed — if it is longer, the scope is too large; split it
- Acceptance criteria must be testable — avoid "the system should work correctly"
- Every open question must have an owner; "TBD" without an owner is not acceptable
- If a dependency status is "blocked", flag it prominently at the top of the plan before the Goal section
- Do not invent business rules not stated in the feature request — flag gaps as open questions instead
