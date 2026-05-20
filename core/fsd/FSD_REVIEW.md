# FSD_REVIEW.md — Functional Specification Document Review

## Purpose

Review a draft FSD for completeness, clarity, and readiness to enter the AI workflow. Run this prompt after authoring an FSD with `FSD_TEMPLATE.md` and before proceeding to BA Analysis or Tech Spec generation.

---

## Pre-condition

A completed FSD draft must exist at:
```
projects/{{PROJECT_NAME}}/fsd/{{FEATURE_SLUG}}-fsd.md
```

---

## Instructions

You are reviewing the attached FSD. Work through each checklist category below. For every item:
- **PASS** — the FSD satisfies the criterion
- **FAIL** — the FSD is missing or unclear; provide a specific, actionable comment
- **N/A** — not applicable for this feature type

At the end, produce a **Review Summary** with:
1. Overall status: `READY` (all items PASS or N/A) or `NEEDS REVISION` (any FAIL)
2. A numbered list of required changes (FAILs only)
3. A numbered list of optional improvements (nice-to-have)

---

## Review Checklist

### 1. Metadata & Status
- [ ] Feature name, module, version, author, date, and status are all filled in
- [ ] No `{{PLACEHOLDER}}` tokens remain anywhere in the document
- [ ] Status is one of: `Draft` | `In Review` | `Approved`

### 2. Business Context
- [ ] Business goal is stated in one clear sentence
- [ ] Impacted personas are identified
- [ ] The "why" is distinct from the "what" — not just a feature description

### 3. Scope
- [ ] In-scope items are explicit and bounded
- [ ] Out-of-scope items are explicitly listed (not just "everything else")
- [ ] No implementation details in the scope section

### 4. Actors & Personas
- [ ] Every actor who interacts with the feature is listed
- [ ] Access level / role for each actor is defined
- [ ] At least one primary actor is identified

### 5. Functional Requirements
- [ ] Every requirement is numbered (FR-001, FR-002 …)
- [ ] Each requirement is independently testable (starts with "The system shall…")
- [ ] No requirement contains "TBD", "as usual", or vague language
- [ ] Requirements cover the full happy path end-to-end

### 6. UI / Screen Flow
- [ ] Screen names and navigation paths are defined (or marked N/A for non-UI features)
- [ ] All form fields and their types are listed
- [ ] Button labels and their actions are specified

### 7. Business Rules
- [ ] All validation rules are explicit with exact constraints (min/max, format, allowed values)
- [ ] Conditional logic is written as `IF <condition> THEN <action>` — no ambiguity
- [ ] Calculation formulas are precise — no "calculated as expected"

### 8. API Contract
- [ ] HTTP method and path are specified
- [ ] Request body / query parameters are defined with types
- [ ] Success response shape is defined
- [ ] Auth method is specified

### 9. Data Requirements
- [ ] Key entities and their fields are listed
- [ ] Relationships between entities are described
- [ ] Any new tables or schema changes are identified

### 10. Error Scenarios
- [ ] Every error case maps to a specific error code (from the project error code registry)
- [ ] System behavior for each error is defined (what the API returns, what the user sees)
- [ ] No error scenario says only "return error" without specifying which one

### 11. Non-Functional Notes
- [ ] Performance targets are stated if applicable (response time, throughput)
- [ ] Security constraints are noted (auth required, PII fields, masking rules)
- [ ] Logging requirements reference the NFR standard (`core/nfr/AGENTS.md`)

### 12. Open Questions
- [ ] Every open question has an assigned owner
- [ ] Every open question has a resolution deadline
- [ ] No open question blocks a core functional requirement (or the FSD is marked Draft until resolved)

### 13. Acceptance Criteria
- [ ] Every AC is written in Given/When/Then format
- [ ] At least one AC covers the primary happy path
- [ ] At least one AC covers each major error scenario
- [ ] ACs are traceable to functional requirements (FR-001 → AC-001)

---

## Output Format

```
## FSD Review — {{FEATURE_NAME}}

**Reviewed by:** [AI reviewer]
**Date:** {{DATE}}
**Overall Status:** READY | NEEDS REVISION

---

### Required Changes
1. [Section] [Item] — [Specific action needed]
2. ...

### Optional Improvements
1. [Section] [Item] — [Suggestion]
2. ...

### Checklist Summary
| Category | Status |
|---|---|
| Metadata & Status | PASS / FAIL |
| Business Context | PASS / FAIL |
| Scope | PASS / FAIL |
| Actors & Personas | PASS / FAIL |
| Functional Requirements | PASS / FAIL |
| UI / Screen Flow | PASS / N/A / FAIL |
| Business Rules | PASS / FAIL |
| API Contract | PASS / FAIL |
| Data Requirements | PASS / FAIL |
| Error Scenarios | PASS / FAIL |
| Non-Functional Notes | PASS / FAIL |
| Open Questions | PASS / FAIL |
| Acceptance Criteria | PASS / FAIL |
```
