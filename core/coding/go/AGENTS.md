# AGENTS.md — Go Developer Coding

## Purpose

Guide AI-assisted development of Go backend services. Provides coding standards, architectural patterns, and conventions that AI must follow when writing new code or modifying existing code.

---

## When to Use

Use this agent when you need to:
- Write new Go HTTP handlers, services, or repositories
- Add a new endpoint to an existing router (Gin / Echo / Chi)
- Refactor existing code to match project architecture
- Generate boilerplate (structs, interfaces, validators) for a new feature

---

## Prompt Files

| File | Purpose |
|---|---|
| _(no standalone prompt file — instructions are inline below)_ | Follow the standards defined in this AGENTS.md |

---

## Standard Inputs

| Input | Required |
|---|---|
| Feature description or FSD | Yes |
| Project AGENTS.md (project-specific overrides) | Yes |
| Service AGENTS.md (`projects/<name>/services/<svc>/AGENTS.md`) | Yes |
| `core/architecture/AGENTS.md` (layer boundary rules) | Recommended |
| `core/nfr/AGENTS.md` (security controls, OWASP Top 10, logging rules) | Recommended |
| Existing example files to mirror | Recommended |

---

## Outputs

| Output | Location |
|---|---|
| Handler, service, repository `.go` files | `internal/<feature>/` |
| Request / response structs | `internal/<feature>/dto/` |
| Unit test files | `internal/<feature>/<file>_test.go` |

---

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Language | Go 1.22+ | See `{{GO_VERSION}}` in service AGENTS.md |
| HTTP Framework | Gin / Echo / Chi | See `{{HTTP_FRAMEWORK}}` in service AGENTS.md |
| Data Access | `database/sql` + `pgx` / `sqlx` | Parameterized queries only |
| Build | `go build` | Multi-stage Docker build |
| Testing | `testing` + `testify` | Table-driven tests preferred |
| API Style | REST / JSON | OpenAPI 3 spec via `swaggo` or `ogen` |
| Auth | JWT middleware | SSO via Identity Provider |
| Containerization | Docker | Multi-stage build; non-root user |
| Orchestration | Kubernetes | Resource limits, probes, graceful shutdown required |

---

## Project Structure

```
<service>/
├── cmd/
│   └── main.go                  ← entry point
├── internal/
│   ├── <feature>/
│   │   ├── handler.go           ← HTTP handler (thin — delegates to service)
│   │   ├── service.go           ← business logic
│   │   ├── repository.go        ← data access
│   │   ├── dto/
│   │   │   ├── request.go
│   │   │   └── response.go
│   │   └── <feature>_test.go
│   └── middleware/              ← auth, logging, recovery
├── pkg/
│   └── logger/                  ← structured logger (slog / zap / zerolog)
└── go.mod
```

---

## Coding Standards

### Naming
- Packages: short, lowercase, no underscores — `payment`, `auth`, `repository`
- Exported types: `PascalCase` — `CreatePaymentRequest`, `PaymentService`
- Unexported identifiers: `camelCase` — `validateAmount`, `buildResponse`
- Interfaces: noun or `-er` suffix — `PaymentRepository`, `Logger`
- Test files: `<file>_test.go` in the same package

### Error Handling
- Always return `error` as the last return value
- Wrap errors with context: `fmt.Errorf("validatePayment: %w", err)`
- Define sentinel errors as package-level vars: `var ErrNotFound = errors.New("not found")`
- Never swallow errors — log or return, never both

### Dependency Injection
- Pass dependencies via constructor functions, not `init()` or globals
- Use interfaces for all external dependencies (DB, HTTP clients, loggers)
- Wire dependencies in `main.go` or a dedicated `wire.go`

### HTTP Layer (Handler)
- Handlers must be thin: parse request → call service → write response
- No business logic in handlers
- Use `{{HTTP_FRAMEWORK}}` router conventions (Gin: `c.ShouldBindJSON`, Echo: `c.Bind`)
- Always validate input before passing to service layer

### Service Layer
- One file per feature domain: `payment_service.go`
- Accept and return domain structs — not raw DB types or HTTP types
- All methods on a struct that implements the service interface

### Repository Layer
- One file per aggregate: `payment_repository.go`
- Accept and return domain structs
- Use `database/sql` or `pgx` with parameterized queries — no string interpolation
- Return `ErrNotFound` (not a DB driver error) when a row is not found

### Logging
- Use the structured logger from `pkg/logger/` — never `fmt.Println()` or `log.Print()`
- Required fields on every log entry: `event_date_time`, `log_type`, `level`
- Log at service layer entry/exit for traceability; not inside repository loops

### Testing
- Use `testing` standard library + `testify/assert` for assertions
- Table-driven tests for all validation and business rule paths
- Mock interfaces with `testify/mock` or hand-written fakes — never mock concrete structs
- Integration tests for repository layer using `dockertest` or `testcontainers-go`

---

## Placeholder Reference

| Placeholder | Source |
|---|---|
| `{{GO_MODULE}}` | Service `AGENTS.md` |
| `{{GO_VERSION}}` | Service `AGENTS.md` |
| `{{HTTP_FRAMEWORK}}` | Service `AGENTS.md` (gin / echo / chi / net-http) |
| `{{CODING_AGENT}}` | `core/coding/go/AGENTS.md` |

---

## Do NOT

- Do not use `fmt.Println()` or `log.Print()` for logging — use the structured logger
- Do not put business logic in HTTP handler functions — delegate to service layer
- Do not use `interface{}` / `any` unless unavoidable — prefer typed structs
- Do not use `init()` for dependency wiring — use constructor functions
- Do not use global variables for shared state — pass via dependency injection
- Do not use raw SQL string formatting — always use parameterized queries (`$1`, `?`)
- Do not return HTTP framework types (`gin.Context`, `echo.Context`) from service or repository layers
- Do not hardcode environment URLs or credentials — use environment variables
- Do not create new error codes without updating the project error code registry
