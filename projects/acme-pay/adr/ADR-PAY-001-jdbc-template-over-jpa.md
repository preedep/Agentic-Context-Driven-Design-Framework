# Architecture Decision Record

## Document Info

| Field | Value |
|---|---|
| **ADR ID** | `ADR-PAY-001` |
| **Title** | Use JdbcTemplate for all database access — no JPA or Hibernate |
| **Status** | `Accepted` |
| **Date** | `2024-01-15` |
| **Deciders** | Platform Architect, Tech Lead |
| **Feature / Context Area** | Database Access Layer |

---

## 1. Context

acme-pay processes high-volume payment transactions against a Microsoft SQL Server database. The team evaluated ORM frameworks during the initial architecture phase.

### Constraints

- Azure SQL (MSSQL) with stored procedures for audit trail compliance — ORM lazy-loading patterns conflict with explicit transaction boundaries required by the payment processor SLA
- Team has strong SQL expertise but limited JPA/Hibernate production experience
- Regulatory requirement: all SQL executed against payment tables must be auditable and visible in monitoring tools without ORM query translation

### Forces

- JPA/Hibernate generates non-deterministic SQL that is difficult to audit and tune for high-volume OLTP workloads
- Complex ORM session management introduces risk of unintended lazy-load N+1 queries on payment records
- Integration tests with ORM require heavier Testcontainers setup vs. lightweight H2 schema matching

---

## 2. Options Considered

### Option 1 — JdbcTemplate (Spring JDBC)

Direct SQL with named parameters, `RowMapper`, and explicit transaction boundaries via `@Transactional` on the UseCase layer.

**Pros:**
- SQL is explicit, readable, auditable, and tunable
- No lazy-loading surprises
- Integration tests run against a real H2 schema — fast and deterministic
- Team already proficient

**Cons:**
- More boilerplate than JPA for CRUD operations
- No automatic schema migration support (Flyway required separately)

---

### Option 2 — Spring Data JPA / Hibernate

Repository interfaces with auto-generated SQL; `@Entity` classes mapped to tables.

**Pros:**
- Less boilerplate for simple CRUD
- Automatic dirty checking reduces explicit update calls

**Cons:**
- Hibernate generates non-deterministic SQL — hard to audit in compliance context
- N+1 query risk with payment record relationships (PaymentHeader → PaymentLine)
- `@OneToMany` fetch strategies require expert tuning to avoid performance regressions under load
- Session management interacts poorly with explicit MSSQL stored procedure calls

---

### Option 3 — MyBatis

XML or annotation-based SQL mapping with explicit query control.

**Pros:**
- Explicit SQL, similar audit benefits to JdbcTemplate
- More concise than raw JdbcTemplate for complex queries

**Cons:**
- Additional dependency; team has no MyBatis experience
- XML mapping files add maintenance overhead without benefit over JdbcTemplate + RowMapper
- Smaller community support for Azure SQL edge cases

---

## 3. Decision

We will use **`JdbcTemplate`** for all database access in acme-pay.

---

## 4. Rationale

JPA's non-deterministic SQL generation is incompatible with the audit and compliance requirements for payment table access. The team's existing SQL expertise means JdbcTemplate boilerplate cost is low, and explicit queries make performance issues observable and fixable without ORM configuration expertise. The H2 integration test pattern works cleanly with JdbcTemplate and provides fast, reliable CI feedback.

---

## 5. Consequences

### Positive

- All database queries are explicit, auditable, and performance-tunable
- Integration tests are fast and deterministic (H2 schema matching production)
- No N+1 query risk — every query is intentional

### Negative / Trade-offs

- CRUD operations require more code than JPA repository interfaces
- No automatic dirty checking — updates must be explicit
- Schema evolution requires Flyway migration scripts (cannot rely on `ddl-auto`)

### Newly Required

- Flyway must be configured for all schema changes
- All `RowMapper` implementations must be tested for null column handling
- Repository integration tests must use a real schema (H2 or Testcontainers) — never mocked

---

## 6. Compliance Notes

| Check | Where to look | Pass criterion |
|---|---|---|
| No JPA annotations | All `src/main/java/` | Zero `@Entity`, `@Repository` (Spring Data), `@OneToMany`, `@ManyToOne` annotations |
| No Spring Data imports | All `src/main/java/` | No `import org.springframework.data.jpa` or `import javax.persistence` |
| JdbcTemplate injection | All repository classes | Each repository class injects `JdbcTemplate` via constructor |
| No mocked datasource | `src/test/java/` | No `@MockBean DataSource` or `@MockBean JdbcTemplate` in any test class |

---

## 7. References

| Type | Reference |
|---|---|
| Supersedes | *(none — first decision on this topic)* |
| Related ADRs | `ADR-PAY-002` (Usecase → Step pattern) |
| FSD section | *(applies to all features)* |
| External | [Spring JdbcTemplate docs](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/jdbc/core/JdbcTemplate.html) |
