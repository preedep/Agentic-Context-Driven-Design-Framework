# WORKFLOW_EXAMPLES — Claude Code Integration

Real, end-to-end workflow examples covering the full TDD lifecycle. Copy the session starter, replace `{{PLACEHOLDER}}` values, and paste into a Claude Code session.

The examples use the `acme-pay` example project. Replace with your own project folder name.

---

## Full TDD Workflow Overview

```
Step 1: FSD                  → core/fsd/FSD_TEMPLATE.md
Step 2: BA Analysis          → core/ba-analysis/AGENTS.md
Step 3: Tech Spec            → core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md
Step 4: Test Cases (RED)     → unit tests + integration tests + E2E acceptance tests
                               core/unit-test/AGENTS.md
                               core/e2e-test/ANALYZE_TEST_CASE.md + GEN_SCRIPT_FROM_TC.md
Step 5: Implement (GREEN)    → core/tdd/TDD_CYCLE.md  [Repository → Step → UseCase → Controller]
Step 6: Refactor             → core/tdd/TDD_CYCLE.md  [full suite must stay green]
Step 7: Code Review          → core/code-review/REVIEW_STANDARD.md
Step 8: E2E Execution        → projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
```

> **Step 4 writes all test layers before any production code.**
> E2E acceptance tests are authored alongside unit and integration tests — not after implementation.

---

## Step 1 — Write or Review an FSD

**Module:** `core/fsd/`

**Session starter (author new FSD):**
```
Read @core/fsd/AGENTS.md
Read @projects/acme-pay/AGENTS.md

Use @core/fsd/FSD_TEMPLATE.md to author an FSD for:
- FEATURE_NAME: Payment Gateway
- FEATURE_SLUG: payment-gateway
- MODULE_NAME: acme-pay
- DESCRIPTION: Allow operators to submit outbound payment transactions with validation and audit logging

Fill all sections. Flag any open questions you cannot answer from the description above.
Write output to: projects/acme-pay/fsd/payment-gateway-fsd.md
```

**Session starter (review existing FSD):**
```
Read @core/fsd/AGENTS.md
Read @projects/acme-pay/fsd/payment-gateway-fsd.md

Review this FSD for completeness using the quality checklist in AGENTS.md.
Report: missing sections, unresolved open questions, acceptance criteria that are not testable.
Write review to: projects/acme-pay/fsd/payment-gateway-fsd-review.md
```

---

## Step 2 — BA Analysis (FSD → User Stories)

**Module:** `core/ba-analysis/`

**Session starter:**
```
Read @core/ba-analysis/AGENTS.md
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/fsd/payment-gateway-fsd.md

Run the BA Analysis process:
1. Extract all actors and personas
2. Generate numbered user stories (US-001, US-002, ...) in As a / I want / So that format
3. Write Given/When/Then acceptance criteria — minimum 2 scenarios per story
4. List all open questions

Write output to: output/payment-gateway/ba/user-stories.md
```

---

## Step 3 — Generate Tech Spec from FSD

**Module:** `core/tech-spec/`

**Session starter:**
```
Read @projects/acme-pay/AGENTS.md
Read @core/nfr/AGENTS.md
Read @core/tech-stack/AGENTS.md
Read @projects/acme-pay/fsd/payment-gateway-fsd.md

Run @core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md

Inputs:
- FEATURE_SLUG: payment-gateway
- CURRENT_DATE: {{TODAY}}

Generate the full technical specification. Write all output files to:
output/payment-gateway/technical-spec/
```

**What Claude Code produces:**
1. Classifies the FSD as API / Batch / DB
2. Reads project constants from `AGENTS.md` (package root, error prefix, API base path)
3. Applies NFR rules (logging fields, masking, error message format)
4. Writes: `api-specification.md`, `database-schema.md`, `validation-rules.md`, `error-codes.md`, `sequence-diagrams.md`

---

## Step 4 — Generate All Test Cases (RED)

**All three layers written together — before any production code.**

**Module:** `core/unit-test/` + `core/e2e-test/` + `core/tdd/`

### 4a — Unit Tests (Controller, UseCase Impl, Steps)

```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/backend/AGENTS.md
Read @output/payment-gateway/technical-spec/api-specification.md
Read @output/payment-gateway/technical-spec/validation-rules.md
Read @output/payment-gateway/technical-spec/error-codes.md

Run Phase 1a of @core/tdd/TDD_CYCLE.md

Generate JUnit 5 unit test stubs for:
- Controller: PaymentGatewayController
- UseCase Impl: CreatePaymentUseCaseImpl
- Steps: ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep

Rules:
- Tests must COMPILE but FAIL (production classes do not exist yet)
- @ExtendWith(MockitoExtension.class) only — no JUnit 4
- Never mock the Context object — always instantiate with new
- Cover Context field contracts: if a Step writes a field another Step reads, include a handoff test
- Every test maps to a spec requirement — add traceability comment at the top

Write test files to: src/test/java/com/acme/pay/restapi/paymentgateway/
```

### 4b — Integration Tests (Repository layer)

```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/backend/AGENTS.md
Read @output/payment-gateway/technical-spec/database-schema.md

Run Phase 1b of @core/tdd/TDD_CYCLE.md

Generate integration test stubs for:
- PaymentRepository

Rules:
- Use @JdbcTest with a real H2 schema (src/test/resources/schema.sql mirroring production)
- Never @MockBean the datasource — SQL behavior must be tested against a real schema
- Cover: all query methods, null column handling, empty result set, boundary data values
- Tests must COMPILE but FAIL (repository class does not exist yet)

Write test files to: src/test/java/com/acme/pay/restapi/paymentgateway/repository/
```

### 4c — E2E Acceptance Tests (Playwright)

```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
Read @output/payment-gateway/ba/user-stories.md

Run Phase 1c of @core/tdd/TDD_CYCLE.md

Generate Playwright TypeScript E2E acceptance tests for payment-gateway.
- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- Cover every Given/When/Then scenario from user-stories.md (happy path + all error paths)
- Tests will FAIL at runtime — the feature endpoint does not exist yet

Write to: e2e/tests/payment-gateway.spec.ts
```

---

## Step 5 — Implement to Pass Tests (GREEN)

**Module:** `core/tdd/`

**Implement in order: Repository → Step → UseCase → Controller**

```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/backend/AGENTS.md
Read @core/tdd/TDD_CYCLE.md
Read @core/nfr/AGENTS.md

Run TDD_CYCLE.md Phase 2 (GREEN) for:
- FEATURE_SLUG: payment-gateway
- TARGET_CLASS: ValidatePaymentStep
- TEST_FILE: src/test/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStepTest.java
- SOURCE_ROOT: src/main/java/com/acme/pay/restapi

Implement in dependency order:
1. PaymentRepository (make integration tests green)
2. ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep (make unit tests green)
3. CreatePaymentUseCaseImpl (make unit tests green)
4. PaymentGatewayController (make unit tests green)

After each layer: run that layer's tests — must be green before moving to the next.
After all layers: run the FULL test suite (unit + integration). Print results summary.
```

---

## Step 6 — Refactor

**Module:** `core/tdd/`

```
Read @projects/acme-pay/backend/AGENTS.md
Read @core/nfr/AGENTS.md
Read @core/tdd/TDD_CYCLE.md

Run TDD_CYCLE.md Phase 3 (REFACTOR) for feature: payment-gateway

Check each production class:
- Naming follows AGENTS.md conventions
- Application log entries include all 3 NFR mandatory fields (event_date_time, log_type, level)
- Error messages to client are generic (no stack traces, no internal paths)
- Account numbers masked server-side before any response
- Context field contracts documented — fields written by one Step and read by another have named constants

After each change: run the FULL test suite (unit + integration) — not just the changed class.
All tests must remain green. Print final coverage per layer.
```

---

## Step 7 — Code Review Against Spec

**Module:** `core/code-review/`

```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/backend/AGENTS.md
Read @core/code-review/REVIEW_STANDARD.md
Read @core/nfr/AGENTS.md
Read @output/payment-gateway/technical-spec/api-specification.md

Review branch: feature/payment-gateway

Perform all 7 review dimensions:
1. Performance
2. Code smell
3. Security (per NFR Section 5)
4. Structure compliance (Usecase → Step pattern)
5. Spec-to-code mapping
6. Business logic correctness
7. Test coverage (unit ≥ 80%, integration covers all repository methods, E2E covers all FSD scenarios)

Write report to: output/payment-gateway/review/review-report-{{TIMESTAMP}}.md
```

---

## Step 8 — E2E Execution & Reporting

**Module:** `projects/acme-pay/e2e-test/`

```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
Read @output/payment-gateway/ba/user-stories.md

Run the Playwright E2E tests written in Step 4c against SIT:
- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- FEATURE_NAME: payment-gateway
- RESULT_DIR: e2e/test-results/payment-gateway

After the run: embed screenshots and PASS/FAIL status into the test report.
Write to: output/payment-gateway/e2e/e2e-report-{{TIMESTAMP}}.md
```

---

## Standalone Examples

### Non-TDD: Generate API Spec from Existing Source Code

Use this when you have existing code and need to reverse-engineer the spec.

```
Read @core/code-to-spec/AGENTS.md
Read @projects/acme-pay/AGENTS.md
Read @core/code-to-spec/GENERATE_API_SPEC.md

HTTP_METHOD: POST
API_PATH: /api/acme-pay/v1/payment/submit
SOURCE_ROOT: src/main/java

Trace controller → usecase → steps and generate the API specification document.
Write output to: output/payment-gateway/technical-spec/api-specification.md
```

### Non-TDD: Code Review on an Existing Branch

Use this when reviewing code that was written without the TDD workflow.

```
Read @core/code-review/REVIEW_STANDARD.md
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/backend/AGENTS.md

BRANCH_NAME: feature/payment-gateway
SPEC_FILE: @output/payment-gateway/technical-spec/api-specification.md

Perform all 7 review dimensions.
Write report to: output/payment-gateway/review/review-report-{{TIMESTAMP}}.md
```

### Non-TDD: Add Tests to Existing Code

Use this when production code exists but test coverage is missing or low.

```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/backend/AGENTS.md
Read @core/tdd/TDD_CYCLE.md

TARGET_CLASS: ValidatePaymentStep
SOURCE_FILE: src/main/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStep.java

Analyse the existing production class and generate:
1. JUnit 5 unit tests covering happy path, each exception path, boundary values
2. Integration test if the class accesses the database directly

Coverage target ≥ 80%. Write tests to the correct path under src/test/java/
```

### Architecture Decision Record — Author a New ADR

Use this when recording a significant architectural decision before or after it is made.

```
Read @core/adr/AGENTS.md
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/adr/INDEX.md

Use @core/adr/ADR_TEMPLATE.md to author an ADR for:
- DECISION_TOPIC: Choice of message broker for payment event publishing
- NEXT_ADR_ID: ADR-PAY-003

Fill all sections. List at least two options with honest pros and cons.
Write output to: projects/acme-pay/adr/ADR-PAY-003-{{slug}}.md
Then add a row to projects/acme-pay/adr/INDEX.md.
```

### Architecture Decision Record — Review a Draft ADR

```
Read @core/adr/AGENTS.md
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/adr/INDEX.md
Read @projects/acme-pay/adr/ADR-PAY-003-{{slug}}.md

Run @core/adr/ADR_REVIEW.md

ADR_FILE_PATH: projects/acme-pay/adr/ADR-PAY-003-{{slug}}.md
PROJECT_NAME: acme-pay

Write review report to: projects/acme-pay/adr/ADR-PAY-003-review.md
```

### Architecture Decision Record — Query Before Starting a Feature

Use this to discover which existing ADRs apply to a feature before writing the tech spec.

```
Read @core/adr/AGENTS.md
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/adr/INDEX.md

Run @core/adr/ADR_QUERY.md

QUERY_TOPIC: database access
FEATURE_SLUG: payment-gateway

List all applicable ADRs with their compliance checks.
```

### Dependency Update

```
Read @core/dependency-update/AGENTS.md

Help configure update-dependencies.yaml for:
- LIBRARY: spring-boot-starter-parent
- NEW_VERSION: 3.5.0
- TARGET_REPOS: [acme-pay-backend, acme-pay-bff]
- GIT_TOKEN: (provided via env var GIT_TOKEN)

Show the config file and the command to run the update script.
```

---

## Tips

**Load multiple context files at once:**
```
Read @projects/acme-pay/AGENTS.md, @core/nfr/AGENTS.md, @core/tech-stack/AGENTS.md, then ...
```

**Tell Claude Code where to write output:**
```
Write all output to output/payment-gateway/technical-spec/ using UPPER_SNAKE_CASE.md naming.
```

**Resume a session mid-task:**
```
Continue from where we left off — we finished the unit tests for ValidatePaymentStep.
Now generate unit tests for SavePaymentStep.
```

**Apply the quality checklist:**
```
Apply the quality checklist from @core/tdd/TDD_CYCLE.md to the output you just produced.
```

**CI/CD mode (`claude -p`):**
```bash
claude -p "Read @agent-framework/projects/acme-pay/AGENTS.md and \
@agent-framework/core/code-review/REVIEW_STANDARD.md. \
Review branch feature/payment-gateway against \
@output/payment-gateway/technical-spec/api-specification.md"
```
