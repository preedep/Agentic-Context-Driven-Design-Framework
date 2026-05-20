# AGENTS.md — Technology Stack & Architecture

## Purpose

Define the reference technology stack and architectural patterns used across projects in this framework. This module is tool-agnostic and technology-agnostic at the `core/` level — it describes the **patterns and constraints**, not specific vendor choices.

Project-specific stack values (package names, versions, Kubernetes namespace, cloud provider) are declared in `projects/<name>/AGENTS.md` and override or extend this context.

---

## Reference Architecture

The framework targets **cloud-native, Kubernetes-deployed, API-first enterprise backend systems** with a React SPA frontend. The architectural layers from outer to inner:

```
┌──────────────────────────────────────────────────┐
│  Client (React SPA / Mobile / External System)    │
└────────────────────┬─────────────────────────────┘
                     │ HTTPS / TLS 1.2+
┌────────────────────▼─────────────────────────────┐
│  API Gateway / Ingress (Kubernetes)               │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│  Backend Service                                  │
│  ┌──────────────────────────────────────────────┐ │
│  │ Controller Layer       (HTTP in/out)         │ │
│  │ Usecase Layer          (business orchestration) │ │
│  │ Step Layer             (atomic business units)│ │
│  │ Repository Layer       (data access only)    │ │
│  └──────────────────────────────────────────────┘ │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│  Database (Azure SQL / PostgreSQL / MySQL)        │
└──────────────────────────────────────────────────┘
```

---

## Backend Stack (Reference)

| Layer | Technology | Notes |
|---|---|---|
| Language | Java 17 | LTS; use records, sealed classes, pattern matching where appropriate |
| Framework | Spring Boot 3.x | No Spring MVC XML config — annotation-only |
| Data Access | JdbcTemplate | No JPA / Hibernate — explicit SQL only |
| Build | Maven | Multi-module POM supported |
| Testing | JUnit 5 + Mockito | `@ExtendWith(MockitoExtension.class)` only — no JUnit 4 |
| API Style | REST / JSON | OpenAPI 3 spec generated from code |
| Auth | Spring Security + OAuth 2 / OIDC | SSO via Identity Provider |
| Containerization | Docker | Multi-stage build; non-root user |
| Orchestration | Kubernetes | Resource limits, probes, graceful shutdown required (see NFR) |

---

## Frontend Stack (Reference)

| Layer | Technology | Notes |
|---|---|---|
| Language | TypeScript | Strict mode enabled |
| Framework | React 18 | Functional components + hooks only |
| UI Library | MUI v6 | Use MUI components; no raw HTML form elements |
| State | Zustand | No Redux |
| API Client | Axios + custom hooks | |
| Testing | Vitest + React Testing Library | |
| E2E | Playwright | |
| Build | Vite | |

---

## Architectural Patterns

### Backend: Usecase → Step Pattern

Every feature endpoint follows this strict layering:

```
Controller
  └── UseCase (interface + impl)
        └── Step 1: ValidateInputStep
        └── Step 2: CheckBusinessRuleStep
        └── Step 3: PersistDataStep
        └── Step 4: PublishEventStep (if applicable)
```

**Rules:**
- One `UseCase` per operation (e.g., `CreatePaymentUseCase`, `SearchTransactionUseCase`)
- Each `Step` is a Spring-managed bean with a single `execute(Context)` method
- `Context` object carries request + response + shared state across all steps — never use method parameters for inter-step data
- Steps MUST be independently unit-testable
- Business logic lives only in Steps — never in Controllers or Repositories

### Database Access

- All SQL via `JdbcTemplate` — no ORM
- Repositories are the only classes allowed to call `JdbcTemplate`
- Use named parameters (`NamedParameterJdbcTemplate`) for all parameterized queries
- Stored procedures: use only for complex batch operations; document the reason

### API Response Envelope

All responses use a standard wrapper:

```json
{
  "statusCode": "{{PROJECT_SUCCESS_CODE}}",
  "statusDescription": "Success",
  "items": [...],
  "totalRecords": 0
}
```

Error responses:

```json
{
  "statusCode": "{{PROJECT_ERROR_CODE}}",
  "statusDescription": "{{ERROR_DESCRIPTION}}"
}
```

### Cloud Agnostic

Per `core/nfr/AGENTS.md` Section 4: business logic MUST NOT import cloud-vendor SDKs. Use adapter interfaces for:
- Secret management (ESO / CSI Driver)
- Object storage (CSI NFS/SMB or Fuse Driver)
- Messaging (abstract behind interface; Kafka or cloud MQ underneath)

---

## Project-Specific Overrides

Each project's `projects/<name>/AGENTS.md` MUST declare:

| Field | Placeholder |
|---|---|
| Java package root | `{{BASE_PACKAGE}}` |
| Database schema | `{{DB_SCHEMA}}` |
| Error code prefix | `{{ERROR_CODE_PREFIX}}` |
| API base path | `{{API_BASE_PATH}}` |
| Cloud provider | `{{CLOUD_PROVIDER}}` |
| Container registry | `{{CONTAINER_REGISTRY}}` |
| Kubernetes namespace | `{{K8S_NAMESPACE}}` |

---

## DO NOT

- Do not use JPA, Hibernate, or Spring Data JPA — use `JdbcTemplate` only
- Do not place business logic in Controllers or Repositories
- Do not bypass the Usecase → Step pattern for "simple" endpoints
- Do not import cloud-vendor SDKs in business logic classes
- Do not use class-level `@Transactional` on Steps — annotate only at UseCase Impl level
