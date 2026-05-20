# Tech Stack — Java (Spring Boot)

Load after [`AGENTS.md`](AGENTS.md) and alongside [`core/coding/java/AGENTS.md`](../coding/java/AGENTS.md).

---

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Language | Java 17 | LTS; use records, sealed classes, pattern matching |
| Framework | Spring Boot 3.x | Annotation-only config — no XML |
| Data Access | JdbcTemplate | No JPA / Hibernate — explicit SQL only |
| Build | Maven | Multi-module POM supported |
| Testing | JUnit 5 + Mockito | `@ExtendWith(MockitoExtension.class)` only — no JUnit 4 |
| API Style | REST / JSON | OpenAPI 3 spec generated from code |
| Auth | Spring Security + OAuth 2 / OIDC | SSO via Identity Provider |
| Containerization | Docker | Multi-stage build; non-root user |
| Orchestration | Kubernetes | Resource limits, probes, graceful shutdown required |

---

## Usecase → Step Pattern (Java Implementation)

```java
// Controller — thin HTTP layer
@RestController
public class PaymentController {
    private final CreatePaymentUseCase useCase;
    public ResponseEntity<ApiResponse> create(@RequestBody CreatePaymentRequest req) {
        CreatePaymentContext ctx = new CreatePaymentContext(req);
        useCase.execute(ctx);
        return ResponseEntity.ok(ApiResponse.success(ctx.getResponse()));
    }
}

// UseCase interface
public interface CreatePaymentUseCase {
    void execute(CreatePaymentContext ctx);
}

// UseCase implementation — orchestrates steps
@Service
public class CreatePaymentUseCaseImpl implements CreatePaymentUseCase {
    private final ValidatePaymentStep validate;
    private final SavePaymentStep save;
    private final PublishPaymentEventStep publish;

    @Transactional
    public void execute(CreatePaymentContext ctx) {
        validate.execute(ctx);
        save.execute(ctx);
        publish.execute(ctx);
    }
}

// Step — one atomic action
@Component
public class ValidatePaymentStep {
    public void execute(CreatePaymentContext ctx) { ... }
}

// Context — shared state carrier
public class CreatePaymentContext {
    private final CreatePaymentRequest request;
    private CreatePaymentResponse response;
    // getters + setters
}
```

---

## Database Access

- All SQL via `JdbcTemplate` or `NamedParameterJdbcTemplate` — no ORM
- Repositories are the only classes allowed to call `JdbcTemplate`
- Use named parameters for all parameterized queries — no string concatenation
- Stored procedures: use only for complex batch operations; document the reason

---

## Placeholder Reference

| Placeholder | Source |
|---|---|
| `{{BASE_PACKAGE}}` | Service `AGENTS.md` |
| `{{BUILD_TOOL}}` | Service `AGENTS.md` |
| `{{JAVA_VERSION}}` | Service `AGENTS.md` |

---

## DO NOT

- Do not use JPA, Hibernate, or Spring Data JPA — use `JdbcTemplate` only
- Do not use class-level `@Transactional` on Steps — annotate only at UseCase Impl level
- Do not use `System.out.println()` — use SLF4J logger only
- Do not use JUnit 4 — use JUnit 5 with `@ExtendWith(MockitoExtension.class)` only
