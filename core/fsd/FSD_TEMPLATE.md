# Functional Specification Document (FSD)

> **How to use this template:**
> Replace every `{{PLACEHOLDER}}` with real values. Do not leave any placeholder in a finalized FSD.
> Delete this instruction block before publishing.

---

## Document Info

| Field | Value |
|---|---|
| **Feature Name** | `{{FEATURE_NAME}}` |
| **Feature Slug** | `{{FEATURE_SLUG}}` (kebab-case, used in file names and API paths) |
| **Module / Service** | `{{MODULE_NAME}}` |
| **Version** | `{{VERSION}}` (e.g., `1.0`) |
| **Status** | `Draft` \| `In Review` \| `Approved` |
| **Author** | `{{AUTHOR}}` |
| **Date** | `{{DATE}}` (ISO 8601: `YYYY-MM-DD`) |
| **Reviewers** | `{{REVIEWER_1}}`, `{{REVIEWER_2}}` |

---

## 1. Business Context

### 1.1 Background

> Why does this feature exist? What business problem does it solve?

`{{BUSINESS_BACKGROUND}}`

### 1.2 Business Goal

> One sentence stating the measurable outcome this feature delivers.

`{{BUSINESS_GOAL}}`

### 1.3 Impacted Personas

| Persona | Role | How Impacted |
|---|---|---|
| `{{PERSONA_1}}` | `{{ROLE_1}}` | `{{IMPACT_1}}` |
| `{{PERSONA_2}}` | `{{ROLE_2}}` | `{{IMPACT_2}}` |

---

## 2. Scope

### In Scope

- `{{IN_SCOPE_ITEM_1}}`
- `{{IN_SCOPE_ITEM_2}}`

### Out of Scope

- `{{OUT_OF_SCOPE_ITEM_1}}`
- `{{OUT_OF_SCOPE_ITEM_2}}`

---

## 3. Actors & Access Control

| Actor | System Role / Permission | Actions Allowed |
|---|---|---|
| `{{ACTOR_1}}` | `{{PERMISSION_1}}` | `{{ACTIONS_1}}` |
| `{{ACTOR_2}}` | `{{PERMISSION_2}}` | `{{ACTIONS_2}}` |

---

## 4. Functional Requirements

> Number each requirement. Each must be independently testable.

| ID | Requirement |
|---|---|
| FR-001 | `{{REQUIREMENT_1}}` |
| FR-002 | `{{REQUIREMENT_2}}` |
| FR-003 | `{{REQUIREMENT_3}}` |

---

## 5. UI / Screen Flow

### 5.1 Navigation Path

```
{{MENU_PATH}}  →  {{SCREEN_NAME}}
```

### 5.2 Screen: {{SCREEN_NAME}}

**Form Fields:**

| Field Label | Field Name | Type | Required | Default | Notes |
|---|---|---|---|---|---|
| `{{LABEL_1}}` | `{{FIELD_1}}` | `{{TYPE_1}}` | Yes/No | `{{DEFAULT_1}}` | `{{NOTES_1}}` |
| `{{LABEL_2}}` | `{{FIELD_2}}` | `{{TYPE_2}}` | Yes/No | `{{DEFAULT_2}}` | `{{NOTES_2}}` |

**Actions:**

| Button | Behavior |
|---|---|
| `{{BUTTON_1}}` | `{{BEHAVIOR_1}}` |
| `{{BUTTON_2}}` | `{{BEHAVIOR_2}}` |

---

## 6. Business Rules

| ID | Rule | Where Enforced |
|---|---|---|
| BR-001 | `{{RULE_1}}` | Backend / Frontend / Both |
| BR-002 | `{{RULE_2}}` | Backend / Frontend / Both |
| BR-003 | `{{RULE_3}}` | Backend / Frontend / Both |

---

## 7. API Contract (Preliminary)

> This is the initial contract. The full spec is generated in `core/tech-spec/`.

| Field | Value |
|---|---|
| HTTP Method | `{{HTTP_METHOD}}` |
| Path | `{{API_PATH}}` |
| Auth | `{{AUTH_METHOD}}` |
| Permission | `{{PERMISSION_CODE}}` |

**Request Body (summary):**

```json
{
  "{{REQUEST_FIELD_1}}": "{{TYPE_1}}",
  "{{REQUEST_FIELD_2}}": "{{TYPE_2}}"
}
```

**Response Body (summary):**

```json
{
  "statusCode": "{{SUCCESS_CODE}}",
  "items": [...]
}
```

---

## 8. Data Requirements

### 8.1 Entities Involved

| Entity / Table | Operation | Key Fields |
|---|---|---|
| `{{TABLE_1}}` | READ / WRITE | `{{KEY_FIELDS_1}}` |
| `{{TABLE_2}}` | READ / WRITE | `{{KEY_FIELDS_2}}` |

### 8.2 New Fields / Schema Changes

| Table | Column | Type | Nullable | Notes |
|---|---|---|---|---|
| `{{TABLE}}` | `{{COLUMN}}` | `{{TYPE}}` | Yes/No | `{{NOTES}}` |

---

## 9. Error Scenarios

| ID | Scenario | Expected System Behavior | Error Code |
|---|---|---|---|
| ERR-001 | `{{ERROR_SCENARIO_1}}` | `{{BEHAVIOR_1}}` | `{{ERROR_CODE_1}}` |
| ERR-002 | `{{ERROR_SCENARIO_2}}` | `{{BEHAVIOR_2}}` | `{{ERROR_CODE_2}}` |

---

## 10. Non-Functional Notes

> Reference `core/nfr/AGENTS.md` for full NFR standards. Note only exceptions or emphasis relevant to this feature.

| Category | Requirement |
|---|---|
| Performance | `{{PERFORMANCE_TARGET}}` (e.g., p95 response ≤ 500ms) |
| Logging | `{{LOGGING_NOTE}}` (e.g., log PII access for search operation) |
| Security | `{{SECURITY_NOTE}}` (e.g., mask account number in response) |
| Data Retention | `{{RETENTION_NOTE}}` |

---

## 11. Open Questions

> All items must be resolved before this FSD is marked `Approved`.

| ID | Question | Owner | Due Date | Status |
|---|---|---|---|---|
| OQ-001 | `{{QUESTION_1}}` | `{{OWNER_1}}` | `{{DATE_1}}` | Open |

---

## 12. Acceptance Criteria

> Written in Given/When/Then format. These become the basis for test cases.

### Scenario: {{HAPPY_PATH_SCENARIO_NAME}}

```
Given {{PRECONDITION}}
When  {{ACTION}}
Then  {{EXPECTED_OUTCOME}}
And   {{ADDITIONAL_ASSERTION}}
```

### Scenario: {{ERROR_SCENARIO_NAME}}

```
Given {{PRECONDITION}}
When  {{ACTION}}
Then  {{EXPECTED_ERROR_BEHAVIOR}}
```

### Scenario: {{EDGE_CASE_SCENARIO_NAME}}

```
Given {{PRECONDITION}}
When  {{ACTION}}
Then  {{EXPECTED_OUTCOME}}
```
