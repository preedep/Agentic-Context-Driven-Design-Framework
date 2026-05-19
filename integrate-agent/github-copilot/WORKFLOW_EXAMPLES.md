# WORKFLOW_EXAMPLES — GitHub Copilot Integration

Copy these prompts into Copilot Chat (`⌃⌘I` VS Code / `⌥⇧G` JetBrains). Attach context files using `#file:` before the instruction.

Examples use the `acme-pay` project. Replace with your own project folder name.

---

## Full TDD Workflow Overview

```
Step 1: FSD                  → core/fsd/FSD_TEMPLATE.md
Step 2: BA Analysis          → core/ba-analysis/AGENTS.md
Step 3: Tech Spec            → core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md
Step 4: Test Cases (RED)     → unit tests + integration tests + E2E acceptance tests
Step 5: Implement (GREEN)    → core/tdd/TDD_CYCLE.md  [Repository → Step → UseCase → Controller]
Step 6: Refactor             → core/tdd/TDD_CYCLE.md  [full suite must stay green]
Step 7: Code Review          → core/code-review/REVIEW_STANDARD.md
Step 8: E2E Execution        → projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
```

> **Step 4 writes all test layers before any production code.**
> E2E acceptance tests are authored alongside unit and integration tests — not after implementation.

---

## Step 1 — Write or Review an FSD

**Author a new FSD:**
```
#file:core/fsd/AGENTS.md
#file:projects/acme-pay/AGENTS.md

Use the FSD_TEMPLATE.md structure to write an FSD for:
- FEATURE_NAME: Payment Gateway
- FEATURE_SLUG: payment-gateway
- DESCRIPTION: Allow operators to submit outbound payment transactions with validation and audit logging

Fill all required sections. Flag open questions you cannot answer from the description.
```

**Review an existing FSD:**
```
#file:core/fsd/AGENTS.md
#file:projects/acme-pay/fsd/payment-gateway-fsd.md

Review this FSD for completeness:
- Are all sections present?
- Are acceptance criteria written in Given/When/Then format?
- Are there unresolved open questions?
- Do business rules cover all error scenarios?

Produce a review checklist report.
```

---

## Step 2 — BA Analysis (FSD → User Stories)

```
#file:core/ba-analysis/AGENTS.md
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/fsd/payment-gateway-fsd.md

Run BA Analysis:
1. Extract actors and personas
2. Write numbered user stories (US-001...) in As a / I want / So that format
3. Write Given/When/Then acceptance criteria — minimum 2 scenarios per story
4. List open questions

Output format: Markdown with clear sections per user story.
```

---

## Step 3 — Generate Tech Spec from FSD

```
#file:projects/acme-pay/AGENTS.md
#file:core/nfr/AGENTS.md
#file:core/tech-stack/AGENTS.md
#file:core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md
#file:projects/acme-pay/fsd/payment-gateway-fsd.md

Run the tech spec router.
Classify the FSD type (api/batch/db) and generate:
- api-specification.md (endpoints, request/response, field mapping)
- database-schema.md
- validation-rules.md
- error-codes.md (prefix: PAY)
- sequence-diagrams.md (PlantUML)

Apply NFR rules: structured JSON logging fields, server-side data masking, generic error messages to client.
```

---

## Step 4 — Generate All Test Cases (RED)

**All three layers written together — before any production code.**

### 4a — Unit Tests (Controller, UseCase Impl, Steps)

```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/backend/AGENTS.md
#file:output/payment-gateway/technical-spec/api-specification.md
#file:output/payment-gateway/technical-spec/validation-rules.md
#file:output/payment-gateway/technical-spec/error-codes.md

Generate JUnit 5 unit test stubs for:
- PaymentGatewayController
- CreatePaymentUseCaseImpl
- ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep

Rules:
- @ExtendWith(MockitoExtension.class) — no JUnit 4
- Tests must compile but FAIL — no production code exists yet
- Never mock the Context object — always instantiate with new
- Cover Context field contracts: if a Step writes a field another Step reads, include a handoff test
- Add traceability comment: which spec requirement each test covers
- Coverage target ≥ 80% per class
```

### 4b — Integration Tests (Repository layer)

```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/backend/AGENTS.md
#file:output/payment-gateway/technical-spec/database-schema.md

Generate integration test stubs for PaymentRepository:
- Use @JdbcTest with a real H2 schema (schema.sql mirroring production)
- Never @MockBean the datasource — SQL behavior must run against a real schema
- Cover: all query methods, null column handling, empty result set, boundary data
- Tests must compile but FAIL — repository class does not exist yet
```

### 4c — E2E Acceptance Tests (Playwright)

```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
#file:output/payment-gateway/ba/user-stories.md

Generate Playwright TypeScript E2E acceptance tests for payment-gateway.

- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- Cover every Given/When/Then scenario from user-stories.md (happy path + all error paths)
- Tests will FAIL at runtime — the feature endpoint does not exist yet

Output file: e2e/tests/payment-gateway.spec.ts
```

---

## Step 5 — Implement to Pass Tests (GREEN)

**Implement in order: Repository → Step → UseCase → Controller**

```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/backend/AGENTS.md
#file:core/tdd/TDD_CYCLE.md
#file:src/test/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStepTest.java

Run TDD_CYCLE.md Phase 2 (GREEN).

Implement in dependency order:
1. PaymentRepository — make integration tests green first
2. ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep — make unit tests green
3. CreatePaymentUseCaseImpl — make unit tests green
4. PaymentGatewayController — make unit tests green

After each layer: confirm that layer's tests are green before moving to the next.
After all layers: run the FULL test suite (unit + integration). All must be green.
Write only enough code to make the failing tests pass. No extra logic.
Follow the Usecase → Step pattern from AGENTS.md.
```

---

## Step 6 — Refactor

```
#file:core/nfr/AGENTS.md
#file:projects/acme-pay/backend/AGENTS.md
#file:core/tdd/TDD_CYCLE.md
#file:src/main/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStep.java

Run TDD_CYCLE.md Phase 3 (REFACTOR).

Review and refactor:
- Naming conventions match AGENTS.md rules
- Logging includes all 3 NFR mandatory fields (event_date_time, log_type, level)
- Error messages to client are generic — no stack traces, no internal paths
- Account numbers masked server-side before any response
- Context field contracts documented — fields shared between Steps have named constants

After each change: run the FULL test suite (unit + integration) — not just the changed class.
All tests must remain green. Report final coverage per layer.
```

---

## Step 7 — Code Review

```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/backend/AGENTS.md
#file:core/code-review/REVIEW_STANDARD.md
#file:core/nfr/AGENTS.md
#file:output/payment-gateway/technical-spec/api-specification.md

Review the current branch changes for payment-gateway.

Produce a Markdown report covering all 7 dimensions:
1. Performance (N+1 queries, unbounded collections, missing indexes)
2. Code smell (naming, duplication, complexity)
3. Security (NFR Section 5: injection, masking, error disclosure)
4. Structure (Usecase → Step pattern compliance)
5. Spec-to-code mapping (every endpoint in spec is implemented)
6. Business logic (validation rules match spec)
7. Test coverage (unit ≥ 80% per class, integration covers all repository methods, E2E covers all FSD scenarios)
```

---

## Step 8 — E2E Execution & Reporting

```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
#file:output/payment-gateway/ba/user-stories.md

Run the Playwright E2E tests from Step 4c against SIT:
- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- FEATURE_NAME: payment-gateway

After the run: report PASS/FAIL per acceptance criterion with screenshots.
```

---

## Standalone Examples

### Non-TDD: Generate Spec from Existing Source Code

```
#file:core/code-to-spec/AGENTS.md
#file:core/code-to-spec/GENERATE_API_SPEC.md
#file:projects/acme-pay/AGENTS.md
#file:src/main/java/com/acme/pay/restapi/paymentgateway/controller/PaymentGatewayController.java

Run GENERATE_API_SPEC for:
- HTTP_METHOD: POST
- API_PATH: /api/acme-pay/v1/payment/submit

Trace controller → usecase → steps and generate the API specification document.
```

### Non-TDD: Add Tests to Existing Code

```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/backend/AGENTS.md
#file:core/tdd/TDD_CYCLE.md
#file:src/main/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStep.java

Analyse the existing production class and generate:
1. JUnit 5 unit tests covering happy path, each exception path, boundary values
2. Integration test if the class accesses the database directly

Coverage target ≥ 80%.
```

### Non-TDD: Check NFR Compliance

```
#file:core/nfr/AGENTS.md
#file:src/main/java/com/acme/pay/restapi/paymentgateway/step/SavePaymentStep.java

Check this Step class for NFR compliance:
- Section 1: Are application log entries structured JSON with all 3 mandatory fields?
- Section 2: Is PII access being logged in pipe-delimited format to the correct logger?
- Section 5: Is account number masked server-side before any response?
- Section 5: Are error messages generic (no stack traces, no internal paths)?

Report each violation with the specific NFR rule reference.
```

### Architecture Decision Record — Author a New ADR

```
#file:core/adr/AGENTS.md
#file:core/adr/ADR_TEMPLATE.md
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/adr/INDEX.md

Author an ADR for:
- DECISION_TOPIC: Choice of message broker for payment event publishing
- NEXT_ADR_ID: ADR-PAY-003

Fill all sections. List at least two options with honest pros and cons.
Save as: projects/acme-pay/adr/ADR-PAY-003-{{slug}}.md
Then add a row to INDEX.md.
```

### Architecture Decision Record — Query Before Starting a Feature

```
#file:core/adr/AGENTS.md
#file:core/adr/ADR_QUERY.md
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/adr/INDEX.md
#file:projects/acme-pay/adr/ADR-PAY-001-jdbc-template-over-jpa.md
#file:projects/acme-pay/adr/ADR-PAY-002-usecase-step-pattern.md

Run ADR_QUERY for:
- QUERY_TOPIC: database access
- FEATURE_SLUG: payment-gateway

List all applicable ADRs with their compliance checks.
```

---

## Tips

**Attach multiple files by dragging from the VS Code Explorer** directly into the Copilot Chat input box.

**Use `@workspace` to locate files first:**
```
@workspace Which files implement the PaymentGateway usecase step?
```
Then attach results with `#file:` in your follow-up.

**Switch to Copilot Edits for file creation:**
Open Copilot Edits (`⇧⌘I`), paste generated code — Copilot proposes creating the file and you click Apply.

**Iterative refinement:**
```
The integration test is missing a boundary value case for amount = 0. Add it.
```
