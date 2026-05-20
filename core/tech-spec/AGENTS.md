# AGENTS.md — Tech Spec

## Purpose

Generate complete technical specification documents from Functional Specification Documents (FSDs), Confluence pages, or plain text requirements. Supports API specs, Batch job specs, and Database specs. Automatically routes to the correct prompt based on the FSD type.

---

## When to Use

Use this agent when you need to:
- Generate an API technical spec from an FSD (new endpoints, request/response structure, DB schema)
- Generate a Batch job technical spec (scheduled jobs, ShedLock, cron configuration)
- Generate a Database specification page (Confluence-ready DDL, column changes, linked APIs)
- Auto-detect the FSD type and route to the correct sub-prompt

---

## Prompt Files

| File | Purpose |
|---|---|
| `GENERATE_TECH_SPEC_ROUTER.md` | Auto-discovers available prompts and routes based on FSD type |
| `GENERATE_API_TECH_SPEC.md` | Generate API technical specification (endpoints, request/response, DB schema) |
| `GENERATE_BATCH_TECH_SPEC.md` | Generate Batch job technical specification |
| `GENERATE_DATABASE_SPEC.md` | Generate database specification Confluence page |

---

## Standard Inputs

| Input | Required |
|---|---|
| FSD document (`.pdf`, `.docx`, `.md`, Confluence HTML) | Yes |
| Project AGENTS.md | Yes |
| Feature slug (e.g., `block-word`, `system-config`) | Yes |
| IA document (Information Architecture) | Optional |
| Data dictionary (`.xlsx`) | Optional |
| Confluence space key | Optional — required for upload |
| Parent page ID | Optional — required for upload |
| Auto-upload flag (`Yes` / `No`) | Optional |

---

## Placeholder Reference

| Placeholder | Required | Possible Values / Format | Example |
|---|---|---|---|
| `{{feature-slug}}` | Yes | kebab-case feature identifier; becomes the output folder name and file prefix | `payment-gateway`, `refund-processing` |
| `{{CURRENT_DATE}}` | Yes | ISO 8601 `YYYY-MM-DD` | `2026-05-19` |
| `{{CONFLUENCE_SPACE}}` | Conditional | Confluence space key; required only when auto-upload is enabled | `ACMEPAY` |
| `{{CONFLUENCE_PARENT_PAGE_ID}}` | Conditional | Numeric Confluence page ID of the parent page | `123456789` |

---

## Outputs

| Output | Description |
|---|---|
| `output/{{feature-slug}}/technical-spec/README.md` | Module overview, all operations |
| `output/{{feature-slug}}/technical-spec/database-schema.md` | DDL, entity classes, RowMapper |
| `output/{{feature-slug}}/technical-spec/api-specification.md` | All endpoints, request/response, SQL |
| `output/{{feature-slug}}/technical-spec/validation-rules.md` | Field-level and cross-field rules |
| `output/{{feature-slug}}/technical-spec/error-codes.md` | Error codes, HTTP status mapping |
| `output/{{feature-slug}}/technical-spec/sequence-diagrams.md` | PlantUML diagrams per operation |

For batch specs: single Markdown file with sections 0–8.
For database specs: Confluence Storage Format XHTML.

---

## Routing Logic

The router (`GENERATE_TECH_SPEC_ROUTER.md`) classifies the FSD as:

| Type | Signals |
|---|---|
| `api` | "Endpoint", "Request/Response", "REST/SOAP", synchronous caller contract |
| `batch` | "Schedule", "Cron", "Daily/Hourly job", "Trigger time", file-based processing |
| `listener` | "Topic", "Queue", "Consumer", Kafka/MQ/JMS, webhook receiver |
| `db` | DB-only: `dbo.<Table> - MVP*`, DDL / Add column / Drop column, no API or job schedule |

---

## Dependencies

- Project AGENTS.md (required before reading any FSD)
- Existing codebase access (for naming convention and pattern discovery)
- Confluence credentials (if auto-upload is enabled)
- `GENERATE_TECH_SPEC_ROUTER.md`, `GENERATE_API_TECH_SPEC.md`, `GENERATE_BATCH_TECH_SPEC.md`, `GENERATE_DATABASE_SPEC.md` in this directory

---

## DO NOT

- Do not generate spec content for operations NOT confirmed in the input document — ask first
- Do not hardcode output paths — resolve dynamically relative to the prompt file location
- Do not invent table names, column names, or error codes — derive from AGENTS.md and codebase
- Do not skip the AGENTS.md read step — AGENTS.md conventions override everything in the spec prompts
