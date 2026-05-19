# AGENTS.md — Architecture Patterns

## Purpose

Provide AI agents with the architectural pattern rules for the current project so that generated code, tech specs, and reviews automatically enforce correct layer boundaries and dependency directions.

Load this file whenever the task involves: designing a new feature, generating a tech spec, implementing code, or reviewing code for structural compliance.

---

## When to Use

Load this module when you need to:
- Enforce correct layer boundaries during code generation
- Review code for architectural violations
- Design a new service or domain module
- Explain which layer a class belongs to and why

---

## Required Context (load before this file)

| File | Purpose |
|---|---|
| `projects/{{PROJECT_NAME}}/AGENTS.md` | Declares `{{ARCHITECTURE_PATTERN}}` and project-specific layer names |

---

## Inputs

| Placeholder | Required | Description | Example |
|---|---|---|---|
| `{{ARCHITECTURE_PATTERN}}` | Yes | Active pattern for this project | `hexagonal` \| `microservice` \| `hexagonal+microservice` |
| `{{PROJECT_NAME}}` | Yes | Project folder name | `acme-pay` |

---

## Pattern 1 — Hexagonal Architecture (Ports & Adapters)

### Core Idea

Business logic lives in the **domain core** and knows nothing about how it is called or what infrastructure it uses. All external interactions — HTTP, database, messaging, file system — are behind interfaces (ports). Concrete implementations (adapters) plug into those interfaces.

```
┌─────────────────────────────────────────────────────────────┐
│                        Domain Core                           │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Domain Entities  │  Use Cases  │  Domain Services  │   │
│   └─────────────────────────────────────────────────────┘   │
│        ▲  Port (interface)        Port (interface)  ▲        │
│        │  (Driving / Primary)     (Driven / Secondary)│      │
└────────┼──────────────────────────────────────────────┼──────┘
         │                                              │
┌────────┴─────────┐                       ┌───────────┴──────┐
│  Driving Adapters │                       │ Driven Adapters  │
│  (inbound)        │                       │ (outbound)       │
│  - REST Controller│                       │ - DB Repository  │
│  - CLI Handler    │                       │ - Message Client │
│  - gRPC Server    │                       │ - File Storage   │
│  - Event Consumer │                       │ - External API   │
└───────────────────┘                       └──────────────────┘
```

### Layers and Responsibilities

| Layer | Package / Folder | Responsibility | Allowed Dependencies |
|---|---|---|---|
| **Domain** | `domain/` | Entities, value objects, domain rules | None — pure Java/TS |
| **Application** | `application/` | Use cases, port interfaces, orchestration | Domain only |
| **Adapter — Inbound** | `adapter/in/` | REST controllers, event consumers, CLI | Application (calls use case) |
| **Adapter — Outbound** | `adapter/out/` | DB repos, HTTP clients, message publishers | Application (implements port) |
| **Infrastructure** | `infrastructure/` | Framework config, DI wiring, schema migrations | Adapters + Application |

### Dependency Rule

**Dependencies point inward only.** Domain has no imports from any other layer. Application imports Domain. Adapters import Application. Infrastructure imports everything.

```
Infrastructure → Adapter → Application → Domain
```

A violation is any import that points outward (e.g., a Domain class importing a Spring annotation, an Application class importing `JdbcTemplate`).

### Port Naming Convention

| Type | Naming | Example |
|---|---|---|
| Driving port (inbound) | `{{UseCase}}UseCase` interface | `SubmitPaymentUseCase` |
| Driven port (outbound) | `{{Entity}}Repository` or `{{Service}}Port` | `PaymentRepository`, `NotificationPort` |
| Inbound adapter | `{{UseCase}}Controller` / `{{Event}}Consumer` | `PaymentController` |
| Outbound adapter | `{{Entity}}RepositoryImpl` / `{{Service}}Adapter` | `PaymentRepositoryImpl` |

### Code Review Checklist — Hexagonal

- [ ] Domain classes have zero framework imports (`@Component`, `@Entity`, `JdbcTemplate`, etc.)
- [ ] Application use cases only import from `domain/` — never from `adapter/` or `infrastructure/`
- [ ] All database access flows through a port interface in `application/` — never called directly from use cases
- [ ] Inbound adapters call use cases via the port interface — never the implementation class
- [ ] Outbound adapter implementations live in `adapter/out/` and depend on no domain details beyond the port contract

---

## Pattern 2 — Microservice Architecture

### Core Idea

The system is decomposed into independently deployable services, each owning its own data and communicating over the network. Each service is responsible for one bounded context and can be scaled, deployed, and failed independently.

```
┌─────────────────────────────────────────────────────────────────┐
│  API Gateway / BFF                                              │
│  (route, auth, rate-limit, aggregate)                           │
└──────┬──────────────────────────┬──────────────────────────────┘
       │                          │
┌──────▼──────────┐      ┌────────▼────────┐      ┌──────────────┐
│ Payment Service │      │ Account Service │      │ Audit Service│
│ owns: payments  │      │ owns: accounts  │      │ owns: logs   │
│ DB: payment_db  │      │ DB: account_db  │      │ DB: audit_db │
└──────┬──────────┘      └────────┬────────┘      └──────┬───────┘
       │                          │                       │
       └──────────────────────────┴───────────────────────┘
                      Message Broker (async events)
```

### Service Design Rules

| Rule | Detail |
|---|---|
| **Single bounded context** | Each service owns one domain — no shared domain models between services |
| **Database per service** | Services MUST NOT share a database schema or table; integration is via API or events |
| **API-first contract** | Service interfaces are HTTP REST or async message contracts — never in-process calls |
| **Independent deployability** | Each service has its own CI/CD pipeline, Dockerfile, and Kubernetes Deployment |
| **Failure isolation** | A service MUST tolerate downstream failures — use circuit breakers, retries with backoff, and fallbacks |

### Inter-Service Communication

| Type | Use When | Pattern |
|---|---|---|
| Synchronous (HTTP/gRPC) | Caller needs an immediate response | REST with OpenAPI contract; set timeout + retry |
| Asynchronous (events) | Caller does not need immediate response | Publish domain event; consumers are decoupled |
| Saga (distributed tx) | Multi-service write must be atomic | Choreography (events) or Orchestration (saga coordinator) |

### Service Internal Structure

Each microservice follows the same internal layering regardless of language:

```
src/
  {{service-name}}/
    api/           ← inbound: HTTP controllers, gRPC handlers, event consumers
    domain/        ← business entities, value objects, domain services
    application/   ← use cases, port interfaces
    infrastructure/← DB adapters, HTTP clients, message publishers, DI config
```

This aligns with Hexagonal Architecture inside each service — the two patterns are complementary, not competing.

### Distributed System Checklist

- [ ] Service owns its own database — no cross-service table joins
- [ ] All synchronous calls have a configured timeout and retry policy
- [ ] Downstream failure does not bring down the calling service (circuit breaker or graceful degradation)
- [ ] Async event schema is versioned and backward-compatible
- [ ] Each service has its own `correlation_id` propagation for distributed tracing
- [ ] No shared library that contains business logic — only shared contracts (OpenAPI schemas, event schemas)
- [ ] Service can be deployed independently without coordinating with other services

### Code Review Checklist — Microservice

- [ ] No direct database query against another service's schema
- [ ] No synchronous in-process call to a class from a different service's codebase
- [ ] Circuit breaker / timeout configured on all outbound HTTP/gRPC calls
- [ ] `correlation_id` extracted from inbound request and forwarded to all outbound calls and log entries
- [ ] Domain events published after successful persistence — not before (avoid ghost events on rollback)
- [ ] API contract changes are backward-compatible or versioned under a new path

---

## Combined Pattern — Hexagonal + Microservice

The most common production setup: each microservice is structured internally using Hexagonal Architecture.

```
Microservice boundary          Hexagonal boundary (inside each service)
─────────────────────          ──────────────────────────────────────────
Payment Service       →        domain/ + application/ + adapter/ + infrastructure/
Account Service       →        domain/ + application/ + adapter/ + infrastructure/
```

When `{{ARCHITECTURE_PATTERN}}` is `hexagonal+microservice`, apply both checklists during code review.

---

## Project Declaration

Each project's `AGENTS.md` MUST declare the active pattern:

```markdown
## Architecture Pattern

| Field | Value |
|---|---|
| `{{ARCHITECTURE_PATTERN}}` | `hexagonal` OR `microservice` OR `hexagonal+microservice` |
```

If not declared, default to the `core/tech-stack/AGENTS.md` layering (Controller → UseCase → Step → Repository).

---

## DO NOT

- Do not place business logic in inbound adapters (controllers, event consumers)
- Do not let domain entities import framework annotations (`@Entity`, `@Component`, `@Table`)
- Do not call another service's database directly — go through its published API or event
- Do not share a domain model class between two microservices — duplicate and own separately
- Do not deploy two services from the same Deployment manifest as a workaround — keep them separate
- Do not use synchronous calls for long-running cross-service operations — use async events or saga
