# acme-pay — Master Entry Point

> **Example project (Java backend + React frontend).**
> This file shows the structure for a single-language backend.
> For multi-service projects (Java + Node.js + Go), run `./onboard.sh` — it generates
> one `services/<name>/AGENTS.md` per service, each with its own language-specific placeholders.

Load this file first before running any prompt in the acme-pay project.

---

## System Context

| Field | Value |
|---|---|
| **Project Name** | acme-pay |
| **Description** | ACME Payment Processing System |
| **Organization** | ACME Corp |
| **Architecture** | hexagonal+microservice |
| **Database** | Azure SQL (Microsoft SQL Server) |
| **Auth Provider** | Azure AD SSO |

---

## Placeholder Values — Shared (all services)

| Placeholder | Value |
|---|---|
| `{{PROJECT_NAME}}` | `acme-pay` |
| `{{BASE_URL_SIT}}` | `https://acme-pay-sit.example.com` |
| `{{BASE_URL_DEV}}` | `https://acme-pay-dev.example.com` |
| `{{BASE_URL_UAT}}` | `https://acme-pay-uat.example.com` |
| `{{CONFLUENCE_SPACE}}` | `ACMEPAY` |
| `{{CONFLUENCE_PARENT_PAGE_ID}}` | `123456789` |
| `{{DB_SCHEMA}}` | `dbo` |
| `{{ERROR_CODE_PREFIX}}` | `PAY` |
| `{{API_BASE_PATH}}` | `/api/acme-pay` |
| `{{AUTH_SESSION_FILE}}` | `playwright/.auth/session.json` |

> Language-specific placeholders (base package, build tool, etc.) are defined
> in each service's own `services/<name>/AGENTS.md` (or `backend/AGENTS.md` for single-service projects).

---

## Architecture Pattern

**Pattern:** `hexagonal+microservice`

Each service is structured with Hexagonal Architecture (domain core, ports, adapters)
and deployed as an independent microservice.

Layer boundary rules: `core/architecture/AGENTS.md`
NFR standards (logging, OWASP, security, Kubernetes): `core/nfr/AGENTS.md`

---

## Architecture Decisions

- All database access via `JdbcTemplate` — no JPA, no Hibernate.
- Business logic follows **Usecase → Step** pattern: UseCase = application port impl, Steps = domain services, Repository = driven adapter.
- Each `Step` is independently unit-testable and receives a shared `Context` object.
- Error codes follow format `PAY001`, `PAY002` — prefix `PAY` + 3-digit number.
- All API responses use a common `ApiResponse<T>` wrapper with `statusCode`, `data`, and `errors` fields.
- Each service owns its own database schema — no cross-service direct DB access.

---

## Sub-Module Map

| Service / Domain | AGENTS.md | Description |
|---|---|---|
| Backend (Java) | [`backend/AGENTS.md`](backend/AGENTS.md) | Spring Boot 3 / Java 17 — payment processing API |
| Frontend (React) | [`frontend/AGENTS.md`](frontend/AGENTS.md) | React 18 / TypeScript / MUI v6 frontend |
| ADR | [`adr/INDEX.md`](adr/INDEX.md) | Architecture decision records |
| Tech Spec | [`tech-spec/ACMEPAY_TECH_SPEC_ROUTER.md`](tech-spec/ACMEPAY_TECH_SPEC_ROUTER.md) | Generate API/Batch/DB specs from FSD |
| E2E Test | [`e2e-test/ACMEPAY_E2E_CONFIG.md`](e2e-test/ACMEPAY_E2E_CONFIG.md) | Playwright test setup and script generation |

---

## Do NOT

- Do not use JPA or Hibernate — all SQL via `JdbcTemplate` only.
- Do not add `@Transactional` outside the UseCase layer.
- Do not hardcode environment URLs — always use `{{BASE_URL_SIT}}` placeholder.
- Do not create new error codes without updating the error code registry.
- Do not allow cross-service direct database access — communicate via API only.
- Do not commit real credentials, tokens, or internal URLs to the framework repo.
