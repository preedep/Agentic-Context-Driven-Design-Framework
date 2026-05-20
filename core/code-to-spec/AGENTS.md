# AGENTS.md — Code to Spec

## Purpose

Generate a complete Confluence Storage Format (XHTML) API specification document by reading an existing Spring Boot codebase. The agent traces the full request/response pipeline — Controller → Usecase → Steps → Services → Repositories — and fills a Confluence HTML template with real values extracted from the code.

---

## When to Use

Use this agent when you need to:
- Produce a Confluence API spec page from existing (already implemented) Spring Boot code
- Backfill documentation for an endpoint that was built without a spec
- Regenerate a spec after significant code changes

---

## Prompt Files

| File | Purpose |
|---|---|
| `GENERATE_API_SPEC.md` | Full prompt for generating Confluence Storage Format HTML from Spring Boot code |

---

## Standard Inputs

| Input | Required |
|---|---|
| HTTP method and API path (e.g., `POST /api/{{PROJECT}}/v1/feature/action`) | Yes |
| Path to the project's Controller Java file | Yes |
| Path to the project's AGENTS.md (architecture guide) | Yes |
| Path to the Confluence HTML template file | Yes |

---

## Placeholder Reference

| Placeholder | Required | Possible Values / Format | Example |
|---|---|---|---|
| `{{PROJECT}}` | Yes | kebab-case project name; used in API path construction | `acme-pay` |
| `{{HTTP_METHOD}}` | Yes | `GET` \| `POST` \| `PUT` \| `PATCH` \| `DELETE` | `POST` |
| `{{API_PATH}}` | Yes | Full URL path starting with `/api/` | `/api/acme-pay/v1/payment/submit` |
| `{{ARCHITECTURE_PATTERN}}` | Yes | `hexagonal` \| `microservice` \| `hexagonal+microservice` \| `usecase-step` (default Spring Boot pattern) | `usecase-step` |
| `{{CURRENT_DATE}}` | Yes | ISO 8601 `YYYY-MM-DD` | `2026-05-19` |

---

## Outputs

| Output | Description |
|---|---|
| Confluence Storage Format XHTML | Complete `<body>` content ready to paste or upload to Confluence |

---

## Architecture Requirements

The agent works best when the target project follows a layered architecture with:
- `Controller` → thin routing layer
- `Usecase` → orchestrates a pipeline of Steps using a functional monad (Vavr Try or similar)
- `Step` → atomic operations (validate, query DB, call external API, map response)
- `Service` → data access abstraction
- `Repository` → raw DB queries with RowMapper or JPA

If the project uses a different architecture, configure the `{{ARCHITECTURE_PATTERN}}` placeholder in the prompt file.

---

## Dependencies

- Source code access (read all relevant Java files)
- Confluence HTML template file
- Project AGENTS.md for architecture context
- `GENERATE_API_SPEC.md` in this directory

---

## DO NOT

- Do not generate specs without reading the actual source code — all values must come from code
- Do not assume table/column names — always read Entity annotations or RowMapper
- Do not leave `{{PLACEHOLDER}}` values in the output — all must be replaced
- Do not invent error codes — extract from exception classes and constant files
