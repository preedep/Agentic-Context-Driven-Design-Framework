# acme-pay — Tech Spec Router

Load after [`../AGENTS.md`](../AGENTS.md).

---

## Purpose

Classify an FSD document and route it to the correct tech spec prompt.

---

## How to Use

1. Paste or attach the FSD document.
2. This router reads the FSD and determines the spec type.
3. It then invokes the appropriate prompt below.

---

## Routing Rules

| If FSD describes... | Route to |
|---|---|
| REST API endpoints, request/response models | [`ACMEPAY_API_TECH_SPEC.md`](ACMEPAY_API_TECH_SPEC.md) |
| Batch job, scheduled task, file processing | [`ACMEPAY_BATCH_TECH_SPEC.md`](ACMEPAY_BATCH_TECH_SPEC.md) |
| Database schema, table design, indexes | [`ACMEPAY_DATABASE_SPEC.md`](ACMEPAY_DATABASE_SPEC.md) |
| Sequence / flow diagrams | [`ACMEPAY_PLANTUML_GENERATION.md`](ACMEPAY_PLANTUML_GENERATION.md) |

---

## Instructions

Read the attached FSD. Identify the primary spec type from the routing table above.
State which type you identified and why (one sentence), then run the matching prompt file.
If the FSD covers multiple types, generate each spec in sequence.
