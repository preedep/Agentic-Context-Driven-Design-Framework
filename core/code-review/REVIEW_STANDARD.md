# Code Review Standard

## Required Context

Load these files before running this prompt:

| File | Purpose |
|---|---|
| `agent-framework/projects/acme-pay/AGENTS.md` | Project architecture rules, error codes |
| `agent-framework/projects/acme-pay/backend/AGENTS.md` | Project coding standards — the review validates against these rules |

> Replace the paths above with your own project's AGENTS.md files.
> If you have not loaded the files above, stop and load them first.
> The instructions below assume that context is already present.

---

## Review Configuration

### Branch Specification
- **Target Branch**: `{{BRANCH_NAME}}` *(Required: Specify the branch to review)*

### Reference Documentation
- **Structure/Logic/Mapping Files**: *(Specify one or more .md files to validate code against)*
   - `AGENTS.md`
   - `{{SPEC_FILE}}`
   - *(Add more as needed)*

### Report Output
- **Report Filename**: `review-report-{timestamp}.md`
- **Report Location**: `{{PROJECT_NAME}}/review/`

### Checklist Output
- **Checklist Filename**: `review-checklist-{timestamp}.md`
- **Checklist Location**: `{{PROJECT_NAME}}/review/`

---

## Review Checklist

### 1. Performance

#### 1.1 Database Queries
- [ ] **N+1 Query Issues**: Check for queries executed inside loops that should be batch queries
- [ ] **Missing Indexes**: Verify indexes exist for frequently queried columns (WHERE, JOIN, ORDER BY)
- [ ] **Unnecessary Joins**: Review JOIN operations for necessity; consider lazy loading alternatives

#### 1.2 Memory Usage
- [ ] **Object Creation in Loops**: Avoid creating new objects inside loops; reuse or move outside
- [ ] **Large Collections**: Check for unbounded collections; consider pagination or streaming
- [ ] **Memory Leaks**: Verify proper resource cleanup (streams, connections, listeners)

#### 1.3 Algorithm Efficiency
- [ ] **Unnecessary Iterations**: Review loops for redundant passes over data
- [ ] **Caching Opportunities**: Identify repeated expensive operations that could be cached

#### 1.4 Logging
- [ ] **Excessive Logging in Loops**: Avoid logging inside tight loops; log summaries instead
- [ ] **Missing Parameterized Logging**: Use `logger.info("value: {}", var)` instead of string concatenation

---

### 2. Code Smell

#### 2.1 Long Methods
- [ ] **Method Length > 30 Lines**: Refactor methods exceeding 30 lines into smaller, focused methods

#### 2.2 Large Classes
- [ ] **Class Size**: Identify classes with too many responsibilities; apply Single Responsibility Principle

#### 2.3 Duplicate Code
- [ ] **Code Duplication**: Find repeated code blocks and extract into reusable methods/classes

#### 2.4 Dead Code
- [ ] **Unused Code**: Remove unreachable code, unused variables, and commented-out code

#### 2.5 Magic Numbers
- [ ] **Hardcoded Values**: Replace magic numbers/strings with named constants

#### 2.6 Deep Nesting
- [ ] **Excessive Nesting**: Refactor deeply nested code (> 3 levels) using early returns or extraction

#### 2.7 God Objects
- [ ] **Overly Large Objects**: Break down classes that do too much into smaller, cohesive classes

#### 2.8 Primitive Obsession
- [ ] **Overuse of Primitives**: Consider using value objects instead of multiple primitive parameters

---

### 3. Security — OWASP Top 10 (2025/2026)

#### A01 — Broken Access Control
- [ ] **Missing Authorization**: Every endpoint that modifies data or accesses sensitive resources must verify user permissions
- [ ] **Insecure Direct Object Reference (IDOR)**: Verify that object IDs in requests are scoped to the authenticated user's accessible data
- [ ] **Path Traversal**: Validate file paths; reject `../` sequences in any file-related input
- [ ] **Privilege Escalation**: Users must not be able to elevate their own permissions via API calls

#### A02 — Cryptographic Failures
- [ ] **Sensitive Data in Logs**: PII, tokens, passwords, and account numbers must never appear in log statements
- [ ] **Weak Hashing**: Do not use MD5 or SHA-1 for security-sensitive hashing; use SHA-256 or stronger
- [ ] **Plaintext Secrets**: Credentials, API keys, and secrets must not be hardcoded or committed to version control
- [ ] **Insecure Transport**: All external HTTP calls must use HTTPS

#### A03 — Injection
- [ ] **SQL Injection**: All database queries must use parameterized queries or prepared statements — never string concatenation with user input
- [ ] **LDAP / NoSQL / XML Injection**: Any query language receiving external input must use parameterized or escaped input
- [ ] **Command Injection**: External process invocations (Runtime.exec, ProcessBuilder) must not include untrusted input

#### A04 — Insecure Design
- [ ] **Missing Rate Limiting**: High-frequency endpoints (login, OTP, search) should have rate limiting or throttling
- [ ] **Business Logic Flaws**: Verify that business rules (e.g., maximum amounts, state transitions) cannot be bypassed via API parameter manipulation

#### A05 — Security Misconfiguration
- [ ] **Debug Endpoints Exposed**: Actuator, debug, and admin endpoints must be restricted or disabled in production profiles
- [ ] **Default Credentials**: No default usernames or passwords in shipped configuration
- [ ] **CORS Misconfiguration**: Verify that CORS `allowedOrigins` is not set to `*` for authenticated endpoints
- [ ] **Verbose Error Messages**: Error responses must not expose stack traces, internal class names, or SQL details to callers

#### A06 — Vulnerable and Outdated Components
- [ ] **Outdated Dependencies**: Check `pom.xml` / `package.json` for libraries with known CVEs
- [ ] **Transitive Vulnerabilities**: Run `mvn dependency:tree` or `npm audit` and review flagged transitive dependencies

#### A07 — Identification and Authentication Failures
- [ ] **JWT Validation**: JWT tokens must be validated for signature, expiry, issuer, and audience
- [ ] **Session Fixation**: Session tokens must be rotated upon login
- [ ] **Brute Force Protection**: Login and OTP endpoints must lock out or slow down after repeated failures
- [ ] **Insecure Remember Me**: Persistent tokens must be stored securely (hashed, scoped, revocable)

#### A08 — Software and Data Integrity Failures
- [ ] **Unsigned Artifacts**: Build artifacts and deployment packages should be signed or verified
- [ ] **Insecure Deserialization**: Do not deserialize untrusted data using `ObjectInputStream` or similar; validate type before deserialization

#### A09 — Security Logging and Monitoring Failures
- [ ] **Missing Audit Logs**: Authentication events, permission denials, and data modifications must be logged with user identity and timestamp
- [ ] **Log Injection**: User-supplied values written to logs must be sanitized to prevent log forging (newline injection)
- [ ] **Insufficient Monitoring**: Verify that alerts or monitoring exist for repeated authentication failures or anomalous query patterns

#### A10 — Server-Side Request Forgery (SSRF)
- [ ] **Unvalidated URLs**: Any endpoint that accepts a URL and performs a server-side fetch must validate the URL against an allowlist of permitted hosts
- [ ] **Cloud Metadata Endpoints**: SSRF payloads targeting `169.254.169.254` (AWS/Azure metadata) must be blocked

---

### 4. Structural Compliance

- [ ] **Layering**: Controller → Service/Usecase → Repository — no layer skipping
- [ ] **Controller Thinness**: Controllers contain no business logic; only routing, header extraction, and response wrapping
- [ ] **Service Boundaries**: Services do not call other service's repositories directly
- [ ] **Dependency Direction**: Inner layers do not import from outer layers
- [ ] **Naming Conventions**: Class, method, constant, and file names follow the project's naming rules (see project AGENTS.md)
- [ ] **Package Structure**: New files placed in the correct package/directory per architecture guide

---

### 5. Input/Output Mapping

- [ ] **All Required Fields Mapped**: Every required request field is read and used
- [ ] **No Redundant Fields**: Response does not include fields not in the spec
- [ ] **Nested Object Handling**: Nested objects and arrays are fully mapped — no partial mapping
- [ ] **Type Correctness**: Field types in code match spec (String, BigDecimal, Integer, Boolean)
- [ ] **Null Safety**: Null checks present for all nullable fields before use
- [ ] **DTO ↔ Entity Mapping**: All entity fields that should be in the response are mapped to the DTO

---

### 6. Business Logic Compliance

- [ ] **Spec Alignment**: Implementation matches every functional requirement in the spec
- [ ] **Conditional Flows**: All branching conditions (if/else, switch) are covered and match spec
- [ ] **Edge Cases**: Boundary values, empty collections, and zero amounts are handled
- [ ] **State Transitions**: Only valid state transitions are permitted (e.g., PENDING → APPROVED, not COMPLETED → PENDING)
- [ ] **No Undocumented Behavior**: Code does not implement business logic not present in the spec

---

### 7. Unit Test Coverage

- [ ] **Core Business Logic Covered**: Every non-trivial method in the service/usecase layer has at least one test
- [ ] **Happy Path Tested**: Success scenario test exists for each method
- [ ] **Failure Paths Tested**: Exception, null input, and validation failure scenarios tested
- [ ] **Boundary Conditions**: Min/max values, empty strings, empty lists tested
- [ ] **Test Data Realistic**: Tests use realistic data values — not placeholder strings like "test", "value1", "abc"
- [ ] **No Test Logic Duplication**: Shared setup in @BeforeEach; no repeated mock setup across tests
- [ ] **Assertions Meaningful**: Each test asserts something specific — no `assertTrue(true)` or empty tests

---

## Review Process

1. **Checkout Branch**: Switch to the specified target branch
2. **Load References**: Read all specified .md files for structure/logic/mapping validation
3. **Execute Checklist**: Run through all checklist items (Sections 1–7)
4. **Document Findings**: Record issues with file path, line number, and description
5. **Generate Report**: Output findings to the specified report file
6. **Generate Checklist**: Output completed checklist with pass/fail per item

---

## Detailed Process per Section

### 1. Execute Performance Review
- Validate all items defined under the *Performance* section.
- Assess database query efficiency, memory utilization, algorithm complexity, and logging practices.
- Ensure no performance anti-patterns exist (e.g., N+1 queries, excessive object creation, unnecessary iterations).

### 2. Execute Code Quality and Code Smell Review
- Review the codebase against all defined *Code Smell* criteria.
- Identify maintainability, readability, and structural concerns.
- Ensure adherence to clean code principles and SOLID design principles.

### 3. Execute Security Review (OWASP)
- For each OWASP category, check whether the code exhibits the listed vulnerability pattern.
- Reference OWASP Top 10 (2025/2026) as the baseline.
- Severity: Critical for A01/A03/A07, High for A02/A04/A05, Medium for A06/A08/A09/A10.

### 4. Validate Structural Compliance
- Cross-check the implementation against the structural definition provided in the reference `.md` documentation.
- Ensure correct layering (Controller, Service/Usecase, Repository, External Integration).
- Confirm separation of concerns and proper dependency direction.

### 5. Validate Input and Output Mapping
- Verify request and response models against the mapping definitions in the reference documentation.
- Ensure:
   - All nested objects are correctly mapped.
   - All arrays and collections are properly handled.
   - No missing or redundant fields exist.
   - Data types match the specification.
   - Null-safety is properly handled in all mappings.

### 6. Validate Business Logic Compliance
- Ensure the implemented business logic strictly follows the functional requirements.
- Validate conditional flows, rule enforcement, and edge case handling.
- Confirm no deviation from the documented specification.

### 7. Validate Unit Test Coverage
- Confirm unit tests adequately cover:
   - Core business logic paths
   - Edge cases
   - Error scenarios
   - Null handling and boundary conditions
- Ensure test cases reflect expected behavior defined in the reference documentation.
- Verify no critical logic is left untested.

---

## Report Template

```markdown
# Code Review Report

**Branch**: {{BRANCH_NAME}}
**Review Date**: [timestamp]
**Reference Documents**: [list of .md files used]
**Reviewer**: AI Code Review Agent

## Checklist Summary

| Section | Status | Issues Found |
|---|---|---|
| 1. Performance | PASS / FAIL / PARTIAL | N |
| 2. Code Smell | PASS / FAIL / PARTIAL | N |
| 3. Security (OWASP) | PASS / FAIL / PARTIAL | N |
| 4. Structural Compliance | PASS / FAIL / PARTIAL | N |
| 5. Input/Output Mapping | PASS / FAIL / PARTIAL | N |
| 6. Business Logic | PASS / FAIL / PARTIAL | N |
| 7. Unit Test Coverage | PASS / FAIL / PARTIAL | N |

## Summary
- **Total Issues Found**: [count]
- **Critical**: [count]
- **High**: [count]
- **Medium**: [count]
- **Low**: [count]

## Findings

### Performance Issues

| File | Line | Issue Type | Description | Severity |
|---|---|---|---|---|
| path/to/file.java | 45 | N+1 Query | Query inside loop | High |

### Code Smell Issues

| File | Line | Issue Type | Description | Severity |
|---|---|---|---|---|
| path/to/file.java | 120 | Long Method | Method exceeds 30 lines (45 lines) | Medium |

### Security Issues

| File | Line | OWASP Category | Description | Severity |
|---|---|---|---|---|
| path/to/file.java | 88 | A03 Injection | String concatenation in SQL query | Critical |

### Structural Issues

| File | Line | Issue Type | Description | Severity |
|---|---|---|---|---|

### Mapping Issues

| File | Line | Issue Type | Description | Severity |
|---|---|---|---|---|

### Business Logic Issues

| File | Line | Issue Type | Description | Severity |
|---|---|---|---|---|

### Test Coverage Issues

| File | Line | Issue Type | Description | Severity |
|---|---|---|---|---|

## Recommendations

[Ordered list of recommended actions, highest severity first]
```
