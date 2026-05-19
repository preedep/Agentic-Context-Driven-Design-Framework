# Architecture Decision Record

> **How to use this template:**
> Replace every `{{PLACEHOLDER}}` with real values. Do not leave any placeholder in a finalized ADR.
> Delete this instruction block before publishing.

---

## Document Info

| Field | Value |
|---|---|
| **ADR ID** | `ADR-{{PROJECT_PREFIX}}-{{ADR_NUMBER}}` |
| **Title** | `{{ADR_TITLE}}` (short noun phrase — what was decided) |
| **Status** | `Draft` \| `In Review` \| `Accepted` \| `Superseded by ADR-{{SUPERSEDED_BY}}` \| `Deprecated` |
| **Date** | `{{DATE}}` (ISO 8601: `YYYY-MM-DD`) |
| **Deciders** | `{{DECIDER_1}}`, `{{DECIDER_2}}` |
| **Feature / Context Area** | `{{FEATURE_OR_AREA}}` (e.g., Authentication, Database Access, API Gateway) |

---

## 1. Context

> What situation forced this decision? Describe the problem, constraints, and forces at play.
> Do NOT describe the solution here — only why a decision was needed.

`{{CONTEXT_DESCRIPTION}}`

### Constraints

- `{{CONSTRAINT_1}}` (e.g., must run on Kubernetes, must not use JPA)
- `{{CONSTRAINT_2}}`

### Forces

- `{{FORCE_1}}` (e.g., team has no ORM expertise, regulatory requirement)
- `{{FORCE_2}}`

---

## 2. Options Considered

> List at least two options. For each: a short description, pros, and cons.
> Be honest about trade-offs — one-sided analysis is not useful.

### Option 1 — `{{OPTION_1_NAME}}`

`{{OPTION_1_DESCRIPTION}}`

**Pros:**
- `{{OPTION_1_PRO_1}}`
- `{{OPTION_1_PRO_2}}`

**Cons:**
- `{{OPTION_1_CON_1}}`
- `{{OPTION_1_CON_2}}`

---

### Option 2 — `{{OPTION_2_NAME}}`

`{{OPTION_2_DESCRIPTION}}`

**Pros:**
- `{{OPTION_2_PRO_1}}`
- `{{OPTION_2_PRO_2}}`

**Cons:**
- `{{OPTION_2_CON_1}}`
- `{{OPTION_2_CON_2}}`

---

### Option 3 — `{{OPTION_3_NAME}}` *(optional — delete if not applicable)*

`{{OPTION_3_DESCRIPTION}}`

**Pros:**
- `{{OPTION_3_PRO_1}}`

**Cons:**
- `{{OPTION_3_CON_1}}`

---

## 3. Decision

> State the chosen option in one clear, unambiguous sentence.

We will use **`{{CHOSEN_OPTION}}`**.

---

## 4. Rationale

> Why this option over the alternatives? Reference the constraints and forces from Section 1.

`{{RATIONALE}}`

---

## 5. Consequences

### Positive

- `{{POSITIVE_CONSEQUENCE_1}}`
- `{{POSITIVE_CONSEQUENCE_2}}`

### Negative / Trade-offs

- `{{NEGATIVE_CONSEQUENCE_1}}`
- `{{NEGATIVE_CONSEQUENCE_2}}`

### Newly Required

> What must now be done, built, or monitored as a result of this decision?

- `{{NEW_REQUIREMENT_1}}`
- `{{NEW_REQUIREMENT_2}}`

---

## 6. Compliance Notes

> How can a code reviewer or automated check verify that this decision is being followed?

| Check | Where to look | Pass criterion |
|---|---|---|
| `{{COMPLIANCE_CHECK_1}}` | `{{LOCATION_1}}` | `{{PASS_CRITERION_1}}` |
| `{{COMPLIANCE_CHECK_2}}` | `{{LOCATION_2}}` | `{{PASS_CRITERION_2}}` |

---

## 7. References

| Type | Reference |
|---|---|
| Supersedes | *(none)* or `ADR-{{PROJECT_PREFIX}}-{{SUPERSEDED_ADR}}` |
| Related ADRs | `ADR-{{PROJECT_PREFIX}}-{{RELATED_ADR}}` |
| FSD section | `projects/{{PROJECT_NAME}}/fsd/{{FEATURE_SLUG}}-fsd.md` — Section {{FSD_SECTION}} |
| Tech Spec | `output/{{FEATURE_SLUG}}/technical-spec/api-specification.md` |
| External | `{{EXTERNAL_LINK}}` |
