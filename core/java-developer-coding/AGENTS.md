# AGENTS.md — Developer Coding

## Purpose

Guide AI-assisted development of Spring Boot backend services. Provides coding standards, architectural patterns, and conventions that AI must follow when writing new code or modifying existing code.

---

## When to Use

Use this agent when you need to:
- Write new Spring Boot controllers, services, or repositories
- Add a new endpoint to an existing controller
- Refactor existing code to match project architecture
- Generate boilerplate (DTOs, mappers, validators) for a new feature

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
| Existing example files to mirror | Recommended |

---

## Outputs

New or modified Java source files placed in the correct package path.

---

## Technical Requirements

### Core Technologies
- **Java:** 1.8 or later (check project AGENTS.md for exact version)
- **Spring Boot:** Check project AGENTS.md for version
- **Database:** MySQL, SQL Server, DB2, or Azure SQL — check project
- **Build Tool:** Maven
- **Containerization:** Docker

### Dependency Injection
Use constructor injection for all required dependencies. Declare dependency fields as `private final`.

```java
@Service
public class ExampleServiceImpl implements ExampleService {
    private final ExampleRepository repository;
    private final AnotherService anotherService;

    public ExampleServiceImpl(ExampleRepository repository, AnotherService anotherService) {
        this.repository = repository;
        this.anotherService = anotherService;
    }
}
```

> **Project override:** Some projects mandate `@Autowired` field injection instead of constructor injection. Always check the project's AGENTS.md and mirror existing code in the project.

---

## Project Structure

### Module: entity (DTOs and domain constants)

```
{{MODULE}}.entity
  constant/
    {{ModuleName}}APIDomainConstants.java    (API domain-level constants: error codes, status values)
  domain/
    {{ApiName}}/
      {{ApiName}}Request.java               (Request DTO with @Valid annotations)
      {{ApiName}}Response.java              (Response DTO — no validation annotations)
```

### Module: web (Controllers, services, repositories)

```
{{MODULE}}.web
  config/
    {{ModuleName}}Configuration.java
  constant/
    {{ModuleName}}Constants.java
    {{ModuleName}}ErrorConstants.java
  controller/
    {{ApiName}}API.java                     (@RestController, @RequestMapping)
  service/
    {{ApiName}}Service.java                 (Service INTERFACE)
  impl/
    {{ApiName}}ServiceImpl.java             (@Service implementation)
  mapping/
    {{ApiName}}RequestMapper.java           (Request DTO → Entity/BO)
    {{ApiName}}ResponseMapper.java          (Entity/BO → Response DTO)
  validation/
    {{ApiName}}Validator.java               (Business rule validation)
  repository/
    {{EntityName}}Repository.java           (extends JpaRepository or JdbcTemplate)
  exception/
    {{ModuleName}}ExceptionHandler.java
    {{ModuleName}}ExceptionHandlerImpl.java (@ControllerAdvice)
  util/
    {{ModuleName}}Util.java                 (final class, private constructor)
  {{ModuleName}}App.java                    (@SpringBootApplication)
```

---

## Controller Layer

**Responsibility:** Thin routing and request/response mapping only. No business logic.

```java
@RestController
@RequestMapping("/api/v1/{{feature}}")
public class {{ApiName}}API {
    private final {{ApiName}}Service service;

    @PostMapping("/action")
    public ResponseEntity<{{ApiName}}Response> action(
        @Valid @RequestBody {{ApiName}}Request request
    ) {
        // 1. Optional custom validation
        {{ApiName}}Validator.validate(request);
        // 2. Call service
        {{BusinessObject}} result = service.performAction(request);
        // 3. Map to response
        {{ApiName}}Response response = {{ApiName}}ResponseMapper.toResponse(result);
        return ResponseEntity.ok(response);
    }
}
```

Rules:
- `@RestController` for all REST APIs
- `@RequestMapping` at class level + `@GetMapping`/`@PostMapping`/`@PutMapping`/`@DeleteMapping` for methods
- Accept Request DTOs with `@Valid` annotation
- Return Response DTOs — never expose JPA entities
- Do NOT catch exceptions here; let them bubble to `@ControllerAdvice`

---

## Service Layer

**Responsibility:** All business logic, orchestration, and data transformation.

**Interface** (in `service/`):
- Method signatures only — no `@Service` annotation

**Implementation** (in `impl/`):
- Mark with `@Service`
- Inject dependencies via constructor (marked `private final`)
- Services are stateless and testable
- Use `@Transactional` to manage transaction boundaries
- Throw custom exceptions: `BusinessProcessingException`, `InputValidationException`, `ResourceConflictException`, `ResourceNotFoundException`

```java
@Service
public class {{ApiName}}ServiceImpl implements {{ApiName}}Service {
    private final {{EntityName}}Repository repository;

    @Transactional
    @Override
    public {{BusinessObject}} performAction({{ApiName}}Request request) {
        // Business logic here
        if (conditionFails) {
            throw new InputValidationException("VALIDATION_CODE");
        }
        {{Entity}} entity = {{ApiName}}RequestMapper.toEntity(request);
        repository.save(entity);
        return {{ApiName}}RequestMapper.toBusinessObject(entity);
    }
}
```

---

## Repository Layer

**Responsibility:** Data access only — no business logic.

```java
@Repository
public interface {{EntityName}}Repository extends JpaRepository<{{EntityName}}, {{IdType}}> {
    Optional<{{EntityName}}> findBy{{Field}}({{FieldType}} value);
    List<{{EntityName}}> findByStatus(String status);

    @Query("SELECT e FROM {{EntityName}} e WHERE e.customerId = ?1 AND e.status = ?2")
    List<{{EntityName}}> findByCustomerIdAndStatus(String customerId, String status);
}
```

Rules:
- One repository per JPA entity/database table
- Use method naming convention for simple queries; `@Query` for complex ones
- Always use parameterized queries — never string concatenation with user input

---

## Logging

Use SLF4J only — never `System.out.println()` or concrete logging implementations.

```java
private static final Logger logger = LoggerFactory.getLogger(MyClass.class);

// Always use parameterized logging:
logger.info("Processing request for account: {}", accountNo);
logger.error("Error updating account: {}", accountNo, exception);

// WRONG — string concatenation:
logger.info("Processing request for account: " + accountNo);  // Never do this
```

---

## Validation Layer

```java
public class {{ApiName}}Validator {
    public static void validate({{ApiName}}Request request) throws InputValidationException {
        // JSR-380 annotations (@Valid) handle field-level validation
        // This layer handles business rule validation only

        if (!isValidStatusTransition(request.getCurrentStatus(), request.getNewStatus())) {
            throw new InputValidationException("INVALID_STATUS_TRANSITION");
        }
    }
}
```

---

## DTO Guidelines

### Request DTOs (with validation annotations)

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class {{ApiName}}Request {
    @NotBlank(message = "Account number is required")
    @Size(min = 1, max = 50)
    private String accountNo;

    @NotNull
    @DecimalMin("0.01")
    private BigDecimal amount;

    @NotNull
    @Valid  // Recursively validate nested object
    private AccountDetails details;
}
```

### Response DTOs (no validation annotations)

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class {{ApiName}}Response {
    private String referenceId;
    private String accountNo;
    private String status;
    private LocalDateTime updatedAt;
    // NO @NotNull, @Size, or validation annotations
}
```

---

## Mapper Layer

```java
public class {{ApiName}}ResponseMapper {
    public static {{ApiName}}Response toResponse({{BusinessObject}} bo) {
        {{ApiName}}Response response = new {{ApiName}}Response();
        response.setReferenceId(bo.getReferenceId());
        response.setAccountNo(bo.getAccountNo());
        response.setStatus(bo.getStatus());
        return response;
    }
}
```

Rules:
- Static methods or `@Component` beans
- Pure transformation only — no business logic, no database queries
- Handle null checks and default values

---

## Exception Handling

```java
@ControllerAdvice
public class {{ModuleName}}ExceptionHandlerImpl {
    @ExceptionHandler(InputValidationException.class)
    public ResponseEntity<ErrorInfo> handleValidation(InputValidationException ex) {
        ErrorInfo error = new ErrorInfo(ex.getCode(), ex.getMessage());
        return ResponseEntity.badRequest().body(error);
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorInfo> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.notFound().build();
    }
}
```

**Error response format:**
```json
{
  "errors": [
    {
      "code": "NF006",
      "message": "Account not found.",
      "description": "Account not found.",
      "moreInfo": "TS9260: Account not found",
      "originalErrorCode": "NF006",
      "originalErrorDesc": "Account not found."
    }
  ]
}
```

---

## Security and Input Handling

- Always use parameterized queries — `NamedParameterJdbcTemplate` or Spring Data JPA
- JSR-380 validation (`@NotNull`, `@Size`) is first line of defense on Request DTOs
- Never trust user input — always validate before service call
- Sanitize string inputs if used in external APIs or logs

---

## File Naming Rules

| Artifact | Convention | Example |
|---|---|---|
| Classes | PascalCase | `UpdateAccountRequest`, `UpdateAccountService` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `STATUS_PENDING` |
| Methods | camelCase | `findByAccountId()`, `validateRequest()` |
| Packages | lowercase | `controller`, `service`, `repository` |

---

## Build and Verification

After adding or modifying code:
- Maven: run `mvn clean package`
- Gradle: run `./gradlew build`
- Ensure all tests pass as part of the build

---

## Unit Testing

### Framework and libraries

| Library | Purpose |
|---|---|
| JUnit 5 (`junit-jupiter`) | Test runner |
| Mockito (`mockito-core`) | Mocking dependencies |
| AssertJ (`assertj-core`) | Fluent assertions |
| Spring Boot Test (`@SpringBootTest`) | Integration tests only |

### Run all tests

```bash
# Maven
mvn test

# Gradle
./gradlew test
```

### Run a single test class

```bash
# Maven
mvn test -Dtest=PaymentServiceImplTest

# Gradle
./gradlew test --tests "com.acme.pay.service.PaymentServiceImplTest"
```

### Run a single test method

```bash
# Maven
mvn test -Dtest=PaymentServiceImplTest#should_throwException_when_duplicateReference

# Gradle
./gradlew test --tests "com.acme.pay.service.PaymentServiceImplTest.should_throwException_when_duplicateReference"
```

### Test report

```bash
# Maven — HTML report generated at:
target/surefire-reports/

# Gradle — HTML report generated at:
build/reports/tests/test/index.html
```

### Unit test structure

```java
@ExtendWith(MockitoExtension.class)
class PaymentServiceImplTest {

    @Mock
    private PaymentRepository repository;

    @InjectMocks
    private PaymentServiceImpl service;

    @Test
    @DisplayName("should return saved payment when input is valid")
    void should_returnSavedPayment_when_inputIsValid() {
        // Arrange
        SubmitPaymentRequest request = new SubmitPaymentRequest("REF001", BigDecimal.TEN, "THB");
        PaymentDomain saved = new PaymentDomain("REF001", "PENDING");
        when(repository.findByReferenceId("REF001")).thenReturn(Optional.empty());
        when(repository.save(any())).thenReturn(saved);

        // Act
        PaymentDomain result = service.submitPayment(request);

        // Assert
        assertThat(result.getReferenceId()).isEqualTo("REF001");
        assertThat(result.getStatus()).isEqualTo("PENDING");
        verify(repository).save(any());
    }

    @Test
    @DisplayName("should throw InputValidationException when reference already exists")
    void should_throwException_when_duplicateReference() {
        when(repository.findByReferenceId("REF001"))
            .thenReturn(Optional.of(new PaymentDomain("REF001", "PENDING")));

        assertThatThrownBy(() -> service.submitPayment(new SubmitPaymentRequest("REF001", BigDecimal.TEN, "THB")))
            .isInstanceOf(InputValidationException.class)
            .hasMessageContaining("already exists");
    }
}
```

Rules:
- `@ExtendWith(MockitoExtension.class)` — never JUnit 4 (`@RunWith`)
- Method naming: `should_{{expectedBehavior}}_when_{{condition}}`
- `@DisplayName` on every test method
- Never mock the class under test — only its dependencies
- One logical assertion group per test — do not assert unrelated things in the same test

---

## Code Formatting

### Tool: Checkstyle + google-java-format (or project-configured formatter)

```bash
# Maven — check formatting (fails build on violation)
mvn checkstyle:check

# Apply google-java-format to a single file
java -jar google-java-format.jar --replace src/main/java/com/acme/pay/service/PaymentServiceImpl.java

# Apply to all files under src/
find src/ -name "*.java" | xargs java -jar google-java-format.jar --replace
```

> **Project override:** Check the project's AGENTS.md for the configured formatter. Some projects use Spotless, EditorConfig, or an IDE-exported formatter profile (`.editorconfig`, `eclipse-formatter.xml`).

### Spotless (if configured)

```bash
# Maven — check only
mvn spotless:check

# Maven — apply formatting
mvn spotless:apply

# Gradle — check only
./gradlew spotlessCheck

# Gradle — apply formatting
./gradlew spotlessApply
```

### Key formatting rules (Google Java Style)

- Indentation: 2 spaces (not tabs)
- Line length: 100 characters
- Braces: always on the same line (`if (x) {`)
- Import order: static imports first, then third-party, then project
- No wildcard imports (`import java.util.*` is forbidden)

---

## DO NOT

- Do not put business logic in controllers
- Do not put database queries in service implementations — delegate to repositories
- Do not expose JPA entities directly in API responses
- Do not hardcode environment-specific URLs or credentials
- Do not use `System.out.println()` for logging
- Do not use string concatenation in SQL queries
- Do not skip `@Valid` on `@RequestBody` parameters
- Do not create a new service implementation file if the same-version class already exists — add a new method instead
