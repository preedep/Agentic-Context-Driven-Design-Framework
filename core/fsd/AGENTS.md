# AGENTS.md — Functional Specification Document (FSD)

## Purpose

Provide a tool-agnostic template and authoring guide for writing Functional Specification Documents (FSDs). The FSD is the primary input artifact for the AI workflow: FSD → Test Cases → Tech Spec → Code.

This module lives in `core/` — the structure and sections are generic and apply to any project. Project-specific FSD examples and completed documents belong in `projects/<name>/fsd/`.

---

## FSD Role in the Workflow

```
FSD (authored here)
  → core/ba-analysis/     (extract user stories + acceptance criteria)
  → core/tech-spec/       (generate API / Batch / DB technical spec)
  → core/unit-test/       (generate test cases from spec)
  → core/tdd/             (implement code guided by tests)
  → core/code-review/     (review implementation against FSD + spec)
```

---

## Prompt Files

| File | Purpose |
|---|---|
| `FSD_TEMPLATE.md` | Blank FSD template with all required sections and `{{PLACEHOLDER}}` fields |
| `FSD_REVIEW.md` | Prompt to review a draft FSD for completeness before it enters the workflow |

---

## FSD Structure — Required Sections

Every FSD MUST contain these sections. Use `{{PLACEHOLDER}}` for all project-specific values when writing a generic/reusable FSD.

| Section | Content |
|---|---|
| **Overview** | Feature name, module, version, author, date, status |
| **Business Context** | Why this feature exists; business goal; impacted personas |
| **Scope** | What is IN scope and explicitly what is OUT of scope |
| **Actors & Personas** | Who interacts with the feature and their access level |
| **Functional Requirements** | Numbered list of what the system must do |
| **UI / Screen Flow** | Screen names, navigation paths, form fields, button labels |
| **Business Rules** | Validation rules, conditional logic, calculation formulas |
| **API Contract** | HTTP method, path, request/response shape (preliminary) |
| **Data Requirements** | Entities, key fields, relationships, constraints |
| **Error Scenarios** | Expected failure cases and required system behavior |
| **Non-Functional Notes** | Performance targets, security constraints, logging requirements |
| **Open Questions** | Unresolved items that must be answered before development |
| **Acceptance Criteria** | Given/When/Then scenarios that define "done" |

---

## Standard Inputs

| Input | Required |
|---|---|
| Feature or change request description | Yes |
| Project AGENTS.md (for domain terminology and tech stack) | Yes |
| Persona / role list | Recommended |
| Existing FSD from a previous feature (as style reference) | Optional |

---

## Outputs

| Output | Location |
|---|---|
| Completed FSD document | `projects/{{PROJECT_NAME}}/fsd/{{FEATURE_SLUG}}-fsd.md` |
| FSD review report | `projects/{{PROJECT_NAME}}/fsd/{{FEATURE_SLUG}}-fsd-review.md` |

---

## Placeholder Reference

| Placeholder | Required | Possible Values / Format | Example |
|---|---|---|---|
| `{{PROJECT_NAME}}` | Yes | kebab-case folder name under `projects/` | `acme-pay` |
| `{{FEATURE_NAME}}` | Yes | Human-readable feature title | `Payment Gateway` |
| `{{FEATURE_SLUG}}` | Yes | kebab-case, used in file names and API paths | `payment-gateway` |
| `{{MODULE_NAME}}` | Yes | Service or module this feature belongs to | `acme-pay` |
| `{{VERSION}}` | Yes | Semantic version string | `1.0` |
| `{{STATUS}}` | Yes | `Draft` \| `In Review` \| `Approved` | `Draft` |
| `{{AUTHOR}}` | Yes | Full name or team name of the author | `Jane Smith` |
| `{{DATE}}` | Yes | ISO 8601 `YYYY-MM-DD` | `2026-05-19` |
| `{{HTTP_METHOD}}` | Yes | `GET` \| `POST` \| `PUT` \| `PATCH` \| `DELETE` | `POST` |
| `{{API_PATH}}` | Yes | URL path starting with `/api/` | `/api/acme-pay/v1/payment/submit` |
| `{{AUTH_METHOD}}` | Yes | `Bearer JWT` \| `API Key` \| `OAuth2` \| `None` | `Bearer JWT` |

---

## Quality Checklist

Before an FSD exits this stage and enters the workflow, verify:

- [ ] All `{{PLACEHOLDER}}` values replaced with real content
- [ ] Every functional requirement is numbered and testable
- [ ] Business rules are explicit — no "TBD" or "as usual"
- [ ] All error scenarios have defined system behavior
- [ ] Acceptance criteria written in Given/When/Then format
- [ ] Open questions list is empty or explicitly deferred with owner assigned
- [ ] NFR notes reference any logging, security, or Kubernetes requirements that apply

---

## DO NOT

- Do not put completed project FSD files in `core/fsd/` — those belong in `projects/<name>/fsd/`
- Do not proceed to tech-spec generation if open questions remain unresolved
- Do not write implementation details in the FSD — that belongs in the tech spec
