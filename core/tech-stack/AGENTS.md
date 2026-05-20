# AGENTS.md — Technology Stack & Architecture

## Purpose

Define the reference architectural patterns and constraints used across all projects in this framework. This module is **language-agnostic** — it describes *how* services are structured, not *which* language implements them.

Project-specific stack values (versions, package names, cloud provider, Kubernetes namespace) are declared in `projects/<name>/AGENTS.md` and `projects/<name>/services/<name>/AGENTS.md`.

For language-specific stack details, coding standards, and code examples, load the matching coding module:

| Language | Coding Module |
|---|---|
| Java (Spring Boot) | [`core/coding/java/AGENTS.md`](../coding/java/AGENTS.md) |
| Node.js (TypeScript) | [`core/coding/nodejs/AGENTS.md`](../coding/nodejs/AGENTS.md) |
| Go | [`core/coding/go/AGENTS.md`](../coding/go/AGENTS.md) |
| Python | [`core/coding/python/AGENTS.md`](../coding/python/AGENTS.md) |
| .NET (C#) | [`core/coding/dotnet/AGENTS.md`](../coding/dotnet/AGENTS.md) |

---

## Reference Architecture

The framework targets **cloud-native, Kubernetes-deployed, API-first enterprise backend systems**.

```
┌──────────────────────────────────────────────────┐
│  Client (SPA / Mobile / External System)         │
└────────────────────┬─────────────────────────────┘
                     │ HTTPS / TLS 1.2+
┌────────────────────▼─────────────────────────────┐
│  API Gateway / Ingress (Kubernetes)               │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│  Backend Service                                  │
│  ┌──────────────────────────────────────────────┐ │
│  │ Handler / Controller   (HTTP in/out)         │ │
│  │ UseCase / Service      (business orchestration)│ │
│  │ Steps / Domain Logic   (atomic business units)│ │
│  │ Repository             (data access only)    │ │
│  └──────────────────────────────────────────────┘ │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│  Database (SQL / NoSQL — project-specific)        │
└──────────────────────────────────────────────────┘
```

---

## Architectural Patterns (Language-Agnostic)

### Handler → UseCase → Step Pattern

Every feature endpoint follows this strict layering regardless of language:

```
Handler / Controller
  └── UseCase / Service (interface + implementation)
        └── Step 1: ValidateInputStep
        └── Step 2: CheckBusinessRuleStep
        └── Step 3: PersistDataStep
        └── Step 4: PublishEventStep  (if applicable)
```

**Rules (apply to all languages):**
- One UseCase / Service per operation — `CreatePayment`, `SearchTransaction`
- Each Step performs exactly one atomic business action
- A shared Context / state object carries data between steps — no method parameters for inter-step data
- Steps MUST be independently unit-testable in isolation
- Business logic lives only in Steps / Service layer — never in Handlers or Repositories

### Layer Boundary Rules

| Layer | Allowed dependencies | Forbidden |
|---|---|---|
| Handler | UseCase interface only | Repository, DB, business logic |
| UseCase | Steps, Repository interface | HTTP types, DB drivers |
| Step | Repository interface, domain models | HTTP types, other Steps directly |
| Repository | DB driver / ORM | HTTP types, UseCase, Step |

See `core/architecture/AGENTS.md` for full hexagonal and microservice boundary rules.

### API Response Envelope

All services use a standard response wrapper:

```json
{
  "statusCode": "{{ERROR_CODE_PREFIX}}000",
  "statusDescription": "Success",
  "items": [],
  "totalRecords": 0
}
```

Error response:

```json
{
  "statusCode": "{{ERROR_CODE_PREFIX}}001",
  "statusDescription": "{{ERROR_DESCRIPTION}}"
}
```

### Cloud-Agnostic Adapter Rule

Business logic MUST NOT import cloud-vendor SDKs directly. Use adapter interfaces for:
- Secret management (ESO / CSI Driver)
- Object storage (CSI NFS/SMB or Fuse Driver)
- Messaging (abstract behind interface; Kafka or cloud MQ underneath)

See `core/nfr/AGENTS.md` Section 4 for full cloud-agnostic NFR rules.

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

## Project-Specific Overrides

Each project's `projects/<name>/AGENTS.md` MUST declare:

| Field | Placeholder |
|---|---|
| Database schema | `{{DB_SCHEMA}}` |
| Error code prefix | `{{ERROR_CODE_PREFIX}}` |
| API base path | `{{API_BASE_PATH}}` |
| Auth provider | `{{AUTH_PROVIDER}}` |

Each service's `projects/<name>/services/<svc>/AGENTS.md` MUST declare:

| Field | Placeholder |
|---|---|
| Language / runtime | `{{CODING_AGENT}}` path |
| Language-specific package / module | see service AGENTS.md |

---

## DO NOT

- Do not place business logic in Handlers / Controllers or Repositories
- Do not bypass the Handler → UseCase → Step pattern for "simple" endpoints
- Do not import cloud-vendor SDKs in business logic classes
- Do not allow cross-service direct database access — communicate via API only
- Do not hardcode environment URLs or credentials — use environment variables
