# AGENTS.md — .NET Developer Coding

## Purpose

Guide AI-assisted development of .NET (ASP.NET Core) backend services. Provides coding standards, architectural patterns, and conventions that AI must follow when writing new code or modifying existing code.

---

## When to Use

Use this agent when you need to:
- Write new ASP.NET Core controllers, services, or repositories
- Add a new endpoint to an existing controller
- Refactor existing code to match project architecture
- Generate boilerplate (DTOs, validators, mappers) for a new feature

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
| Controller, service, repository `.cs` files | `src/{{ROOT_NAMESPACE}}.<Feature>/` |
| Request / response DTOs | `src/{{ROOT_NAMESPACE}}.<Feature>/Dtos/` |
| Unit test files | `tests/{{ROOT_NAMESPACE}}.<Feature>.Tests/` |

---

## Project Structure

```
<service>/
├── src/
│   └── {{ROOT_NAMESPACE}}/
│       ├── Program.cs                   ← entry point + DI wiring
│       ├── <Feature>/
│       │   ├── <Feature>Controller.cs   ← thin HTTP layer
│       │   ├── I<Feature>Service.cs     ← service interface
│       │   ├── <Feature>Service.cs      ← business logic
│       │   ├── I<Feature>Repository.cs  ← repository interface
│       │   ├── <Feature>Repository.cs   ← data access (Dapper / EF Core)
│       │   └── Dtos/
│       │       ├── Create<Feature>Request.cs
│       │       └── <Feature>Response.cs
│       └── Common/
│           ├── Logging/                 ← structured logger setup
│           └── Exceptions/              ← domain exception types
└── tests/
    └── {{ROOT_NAMESPACE}}.Tests/
        └── <Feature>/
            └── <Feature>ServiceTests.cs
```

---

## Coding Standards

### Naming
- Classes / interfaces: `PascalCase` — `PaymentService`, `IPaymentRepository`
- Methods / properties: `PascalCase` — `CreatePaymentAsync`, `Amount`
- Private fields: `_camelCase` — `_repository`, `_logger`
- Local variables / parameters: `camelCase` — `paymentRequest`, `result`
- Async methods: suffix `Async` — `GetByIdAsync`, `CreatePaymentAsync`

### Dependency Injection
- Register all services and repositories in `Program.cs` using `builder.Services`
- Always program to interfaces — inject `IPaymentService`, not `PaymentService`
- Use constructor injection — never `ServiceLocator` or static dependencies

### Controller Layer
- Controllers must be thin: parse request → call service → return `ActionResult<T>`
- No business logic in controllers
- Use `[ApiController]` + route attributes; return typed `ActionResult<T>`
- Validate input via `FluentValidation` or data annotations — not manual `if` checks

### Service Layer
- One class per feature domain implementing its interface
- Accept and return DTOs — never EF Core entities
- Raise typed domain exceptions (`NotFoundException`, `ValidationException`)
- HTTP response translation happens in the controller via exception middleware

### Repository Layer
- One class per aggregate implementing its interface
- Use Dapper with parameterized queries OR EF Core — not raw ADO.NET string SQL
- Return `null` or throw `NotFoundException` — never return DB-level exceptions to callers
- Never import controller or service namespaces from the repository layer

### Logging
- Use `ILogger<T>` from `Microsoft.Extensions.Logging` — never `Console.WriteLine()`
- Required fields on every log entry: `event_date_time`, `log_type`, `level`
- Use Serilog with structured JSON output in production

### Testing
- Use `xUnit` + `FluentAssertions` for unit tests
- Mock interfaces with `Moq` or `NSubstitute`
- Integration tests use `WebApplicationFactory<Program>` + a real test database
- Repository integration tests use a real DB schema — not mocked `DbContext`

---

## Placeholder Reference

| Placeholder | Source |
|---|---|
| `{{ROOT_NAMESPACE}}` | Service `AGENTS.md` |
| `{{DOTNET_VERSION}}` | Service `AGENTS.md` |
| `{{CODING_AGENT}}` | `core/coding/dotnet/AGENTS.md` |

---

## Do NOT

- Do not expose EF Core entities directly in API responses — always map to DTOs
- Do not put business logic in controllers — delegate to service layer
- Do not hardcode connection strings — use `IConfiguration` / environment variables
- Do not use `static` classes for shared state — use dependency injection
- Do not use `Console.WriteLine()` for logging — use `ILogger<T>`
- Do not raise HTTP exceptions (`BadRequestObjectResult`) from the service layer — raise domain exceptions
- Do not use raw string concatenation in SQL queries — use parameterized queries
- Do not create new error codes without updating the project error code registry
