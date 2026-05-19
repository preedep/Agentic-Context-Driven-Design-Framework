# acme-pay — Master Entry Point

Load this file first before running any prompt in the acme-pay project.

---

## System Context

| Field | Value |
|---|---|
| **Project Name** | acme-pay (ACME Payment Processing System) |
| **Organization** | ACME Corp |
| **Type** | Enterprise back-office system for payment transaction processing |
| **Backend** | Spring Boot 3 / Java 17 / JdbcTemplate (no JPA/ORM) |
| **Frontend** | React 18 / TypeScript / MUI v6 |
| **Database** | Azure SQL (Microsoft SQL Server) |
| **Auth** | SSO via Azure AD |

---

## Placeholder Values

These replace `{{PLACEHOLDERS}}` in all `core/` prompt files.

| Placeholder | Value |
|---|---|
| `{{PROJECT_NAME}}` | `acme-pay` |
| `{{BASE_PACKAGE}}` | `com.acme.pay.restapi` |
| `{{BASE_URL_SIT}}` | `https://acme-pay-sit.example.com` |
| `{{BASE_URL_DEV}}` | `https://acme-pay-dev.example.com` |
| `{{BASE_URL_UAT}}` | `https://acme-pay-uat.example.com` |
| `{{CONFLUENCE_SPACE}}` | `ACMEPAY` |
| `{{CONFLUENCE_PARENT_PAGE_ID}}` | `123456789` |
| `{{DB_SCHEMA}}` | `dbo` |
| `{{ERROR_CODE_PREFIX}}` | `PAY` |
| `{{API_BASE_PATH}}` | `/api/acme-pay` |
| `{{AUTH_SESSION_FILE}}` | `playwright/.auth/session.json` |

---

## Architecture Pattern

| Field | Value |
|---|---|
| `{{ARCHITECTURE_PATTERN}}` | `hexagonal+microservice` |

Active patterns: each service is structured with Hexagonal Architecture (domain core, ports, adapters) and deployed as an independent microservice. See `core/architecture/AGENTS.md` for layer boundary rules and code review checklists.

## Architecture Decisions

- All database access via `JdbcTemplate` — no JPA, no Hibernate.
- Business logic follows **Usecase → Step** pattern mapped to Hexagonal layers: UseCase = application port impl, Steps = domain services, Repository = driven adapter.
- Each `Step` is independently unit-testable and receives a shared `Context` object.
- Error codes follow format `PAY001`, `PAY002` — prefix `PAY` + 3-digit number.
- All API responses use a common `ApiResponse<T>` wrapper.

---

## Sub-Module Map

| Domain | AGENTS.md | Use When |
|---|---|---|
| ADR | [`adr/INDEX.md`](adr/INDEX.md) | Query or add architecture decision records |
| Backend | [`backend/AGENTS.md`](backend/AGENTS.md) | Spring Boot code, unit tests, code review |
| Frontend | [`frontend/AGENTS.md`](frontend/AGENTS.md) | React code, component tests, FSD specs |
| Tech Spec | [`tech-spec/ACMEPAY_TECH_SPEC_ROUTER.md`](tech-spec/ACMEPAY_TECH_SPEC_ROUTER.md) | Generate API/Batch/DB specs from FSD |
| E2E Test | [`e2e-test/ACMEPAY_E2E_CONFIG.md`](e2e-test/ACMEPAY_E2E_CONFIG.md) | Playwright test setup and script generation |

---

## Do NOT

- Do not use JPA or Hibernate — all SQL via `JdbcTemplate` only.
- Do not add `@Transactional` outside the Usecase layer.
- Do not hardcode environment URLs — always use `{{BASE_URL_SIT}}` placeholder.
- Do not create new error codes without updating the error code registry.
