# WORKFLOW_EXAMPLES — GitHub Copilot Integration

Copy these prompts into Copilot Chat (`⌃⌘I` VS Code / `⌥⇧G` JetBrains). Attach context files using `#file:` before the instruction.

Examples use the `acme-pay` project. Replace with your own project folder name.

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
- validation-rules.md
- error-codes.md (prefix: PAY)
- sequence-diagrams.md (PlantUML)

Apply NFR rules: structured JSON logging fields, server-side data masking, generic error messages to client.
```

---

## Step 4 — Generate Failing Unit Tests (RED)

```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/backend/AGENTS.md
#file:output/payment-gateway/technical-spec/api-specification.md
#file:output/payment-gateway/technical-spec/validation-rules.md
#file:output/payment-gateway/technical-spec/error-codes.md

Generate JUnit 5 test stubs for:
- PaymentGatewayController
- CreatePaymentUseCaseImpl
- ValidatePaymentStep
- SavePaymentStep

Rules:
- @ExtendWith(MockitoExtension.class) — no JUnit 4
- Tests must compile but FAIL — no production code exists yet
- Never mock the Context object — always instantiate with new
- Add traceability comment: which spec requirement each test covers
- Coverage target ≥ 80% per class
```

---

## Step 5 — Implement to Pass Tests (GREEN + REFACTOR)

**GREEN — write minimum implementation:**
```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/backend/AGENTS.md
#file:core/tdd/TDD_CYCLE.md
#file:src/test/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStepTest.java

Write ValidatePaymentStep.java at:
src/main/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStep.java

Write only enough code to make all tests in the test file pass.
Follow Usecase → Step pattern from AGENTS.md.
```

**REFACTOR — clean without breaking tests:**
```
#file:core/nfr/AGENTS.md
#file:projects/acme-pay/backend/AGENTS.md
#file:src/main/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStep.java

Review and refactor this Step class:
- Naming conventions match AGENTS.md rules
- Logging includes required NFR fields (event_date_time, log_type, level)
- Error messages to client are generic — no stack traces
- Data masking applied server-side for any account numbers in response

Confirm all tests still pass after changes.
```

---

## Step 6 — Code Review

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
7. Test coverage (≥ 80% per class, all error codes covered)
```

---

## Step 7 — E2E Test Generation

```
#file:projects/acme-pay/AGENTS.md
#file:projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
#file:output/payment-gateway/ba/user-stories.md

Generate Playwright TypeScript E2E tests for the payment-gateway feature.

- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- Cover all acceptance criteria from user-stories.md

Output file: e2e/tests/payment-gateway.spec.ts
```

---

## Standalone Examples

### Generate Spec from Existing Source Code

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

### Check NFR Compliance

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
The sequence diagram is missing the error path. Add a failure branch showing the exception handler.
```
