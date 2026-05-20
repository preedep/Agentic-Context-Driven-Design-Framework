# AGENTS.md — Architecture Decision Records (ADR)

## Purpose

Guide AI agents and developers in authoring, reviewing, and querying Architecture Decision Records. An ADR captures a significant architectural or technology decision: the context that made it necessary, the options considered, the chosen option, and the consequences.

ADRs provide a durable audit trail of *why* the system is built the way it is — not what it does (that is the FSD) or how to implement it (that is the tech spec).

This module lives in `core/` — structure and format are generic. Project ADR files belong in `projects/<name>/adr/`.

---

## ADR Role in the Workflow

```
Architecture Decision
  → core/adr/ADR_TEMPLATE.md    (author the record)
  → core/adr/ADR_REVIEW.md      (review for completeness)
  → projects/<name>/adr/        (store approved records)
  → core/fsd/                   (reference in FSD Business Context)
  → core/tech-spec/             (reference in API/DB/Batch spec constraints)
  → core/code-review/           (validate implementation complies with decision)
```

ADRs are referenced — not regenerated. Once approved, an ADR is immutable except for status changes (`Accepted` → `Superseded`). Append a new ADR rather than editing an old one.

---

## Prompt Files

| File | Purpose |
|---|---|
| `ADR_TEMPLATE.md` | Blank ADR template with all required sections and `{{PLACEHOLDER}}` fields |
| `ADR_REVIEW.md` | Prompt to review a draft ADR for completeness and quality |
| `ADR_QUERY.md` | Prompt to search existing ADRs for decisions relevant to a current task |

---

## ADR Structure — Required Sections

Every ADR MUST contain these sections:

| Section | Content |
|---|---|
| **Title** | Short noun phrase: what was decided, not why |
| **ID** | Sequential number: `ADR-{{PROJECT_PREFIX}}-NNN` |
| **Status** | `Draft` \| `In Review` \| `Accepted` \| `Superseded by ADR-NNN` \| `Deprecated` |
| **Date** | ISO 8601: `YYYY-MM-DD` |
| **Deciders** | Names / roles who made the decision |
| **Context** | Problem statement: what forced this decision; constraints and forces at play |
| **Options Considered** | At least two options with pros and cons each |
| **Decision** | The chosen option, stated clearly |
| **Rationale** | Why this option over the others |
| **Consequences** | What becomes easier, harder, or newly required as a result |
| **Compliance Notes** | How the implementation should enforce or validate this decision |
| **References** | Related ADRs, FSD sections, tech specs, external links |

---

## ADR ID Convention

```
ADR-{{PROJECT_PREFIX}}-NNN
```

- `{{PROJECT_PREFIX}}` comes from the project `AGENTS.md` (e.g., `PAY` for acme-pay)
- `NNN` is zero-padded to 3 digits, starting at `001`
- Example: `ADR-PAY-001`, `ADR-PAY-002`

When adding an ADR to a project, check the existing ADRs folder and increment from the highest existing number.

---

## Standard Inputs

| Input | Required |
|---|---|
| Project `AGENTS.md` (for prefix, tech stack, architectural constraints) | Yes |
| Description of the decision to be recorded | Yes |
| Options already considered by the team | Recommended |
| Related FSD or tech spec section | Optional |
| Existing ADRs (to check for conflicts) | Optional |

---

## Placeholder Reference

| Placeholder | Required | Possible Values / Format | Example |
|---|---|---|---|
| `{{PROJECT_NAME}}` | Yes | kebab-case folder name under `projects/` | `acme-pay` |
| `{{PROJECT_PREFIX}}` | Yes | UPPER short code declared in project `AGENTS.md` | `PAY` |
| `{{ADR_NUMBER}}` | Yes | 3-digit zero-padded integer; increment from highest in `INDEX.md` | `003` |
| `{{slug}}` | Yes | kebab-case summary of the decision, used in the filename | `jdbc-template-over-jpa` |
| `{{FEATURE_SLUG}}` | Conditional | kebab-case feature identifier; required when querying ADRs for a feature | `payment-gateway` |
| `{{ADR_FILE_PATH}}` | Yes (review only) | Relative path to the draft ADR | `projects/acme-pay/adr/ADR-PAY-003-message-broker.md` |
| `{{ADR_ID}}` | Yes (review only) | Full ADR identifier `ADR-PREFIX-NNN` | `ADR-PAY-003` |
| `{{QUERY_TOPIC}}` | Yes (query only) | Free text — area of interest to search | `database access`, `authentication`, `error handling` |
| `{{DATE}}` | Yes | ISO 8601 `YYYY-MM-DD` | `2026-05-19` |

---

## Outputs

| Output | Location |
|---|---|
| New ADR document | `projects/{{PROJECT_NAME}}/adr/ADR-{{PROJECT_PREFIX}}-NNN-{{slug}}.md` |
| ADR review report | `projects/{{PROJECT_NAME}}/adr/ADR-{{PROJECT_PREFIX}}-NNN-review.md` |
| ADR query result | `output/{{FEATURE_SLUG}}/adr/relevant-adrs.md` |

---

## Quality Checklist

Before an ADR is marked `Accepted`:

- [ ] ID follows `ADR-{{PROJECT_PREFIX}}-NNN` convention
- [ ] Context section explains the forcing function — not just background
- [ ] At least two options were considered with explicit pros and cons
- [ ] Decision is stated in one unambiguous sentence
- [ ] Rationale explains why this option over the alternatives
- [ ] Consequences cover both positive and negative outcomes
- [ ] Compliance Notes describe how a code reviewer can verify this decision was followed
- [ ] Superseded ADRs (if any) are updated with `Superseded by ADR-NNN`
- [ ] Related ADRs listed in References

---

## DO NOT

- Do not edit an accepted ADR to change the decision — write a new ADR that supersedes it
- Do not leave Status as `Draft` indefinitely — incomplete ADRs must be resolved or discarded
- Do not omit the Options Considered section — a decision with only one option recorded is not an ADR, it is a constraint
- Do not put implementation details in the ADR — those belong in the tech spec
- Do not duplicate information from the FSD — reference the FSD section instead
- Do not store real project ADRs in `core/adr/` — those belong in `projects/<name>/adr/`
