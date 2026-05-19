# WORKFLOW_EXAMPLES — Claude Code Integration

Real, end-to-end workflow examples covering the full TDD lifecycle. Copy the session starter, replace `{{PLACEHOLDER}}` values, and paste into a Claude Code session.

The examples use the `acme-pay` example project. Replace with your own project folder name.

---

## Full TDD Workflow Overview

```
Step 1: Write FSD          → core/fsd/FSD_TEMPLATE.md
Step 2: BA Analysis        → core/ba-analysis/AGENTS.md
Step 3: Tech Spec          → core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md
Step 4: Test Cases (RED)   → core/unit-test/AGENTS.md
Step 5: Implement (GREEN)  → core/tdd/TDD_CYCLE.md
Step 6: Code Review        → core/code-review/REVIEW_STANDARD.md
Step 7: E2E Test           → projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
```

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

**What Claude Code does:**
1. Classifies the FSD as API / Batch / DB (or multiple)
2. Reads project constants from `AGENTS.md` (package root, error code prefix, API base path)
3. Applies NFR rules (logging fields, masking, error message format)
4. Writes: `api-specification.md`, `database-schema.md`, `validation-rules.md`, `error-codes.md`, `sequence-diagrams.md`

---

## Step 4 — Generate Failing Tests (RED)

**Module:** `core/unit-test/` + `core/tdd/`

**Session starter:**
```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/backend/AGENTS.md
Read @output/payment-gateway/technical-spec/api-specification.md
Read @output/payment-gateway/technical-spec/validation-rules.md
Read @output/payment-gateway/technical-spec/error-codes.md

Generate JUnit 5 test stubs for:
- Controller: PaymentGatewayController
- UseCase Impl: CreatePaymentUseCaseImpl
- Steps: ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep

Rules:
- Tests must COMPILE but FAIL (production classes do not exist yet)
- @ExtendWith(MockitoExtension.class) only — no JUnit 4
- Never mock the Context object — always instantiate with new
- Every test maps to a spec requirement — add traceability comment at the top

Write test files to: src/test/java/com/acme/pay/restapi/paymentgateway/
```

---

## Step 5 — Implement to Pass Tests (GREEN + REFACTOR)

**Module:** `core/tdd/`

**Session starter:**
```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/backend/AGENTS.md
Read @core/tdd/TDD_CYCLE.md
Read @core/nfr/AGENTS.md

Run TDD_CYCLE.md Phase 2 (GREEN) for:
- TARGET_CLASS: ValidatePaymentStep
- TEST_FILE: src/test/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStepTest.java
- SOURCE_ROOT: src/main/java/com/acme/pay/restapi

Write minimum implementation to make all tests pass.
Then run Phase 3 (REFACTOR): clean naming, verify NFR logging fields, check error message format.
```

---

## Step 6 — Code Review Against Spec

**Module:** `core/code-review/`

**Session starter:**
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
7. Test coverage (≥ 80%)

Write report to: output/payment-gateway/review/review-report-{{TIMESTAMP}}.md
```

---

## Step 7 — E2E Test Generation

**Module:** `projects/acme-pay/e2e-test/`

**Session starter:**
```
Read @projects/acme-pay/AGENTS.md
Read @projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
Read @output/payment-gateway/ba/user-stories.md

Generate Playwright TypeScript E2E tests for:
- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- FEATURE_NAME: payment-gateway

Cover all acceptance criteria from user-stories.md.
Write to: e2e/tests/payment-gateway.spec.ts
```

---

## Standalone Examples

### Generate API Spec from Existing Source Code

```
Read @core/code-to-spec/AGENTS.md
Read @projects/acme-pay/AGENTS.md
Read @core/code-to-spec/GENERATE_API_SPEC.md

HTTP_METHOD: POST
API_PATH: /api/acme-pay/v1/payment/submit
SOURCE_ROOT: src/main/java

Trace controller → usecase → steps and generate the API specification document.
```

### Dependency Update

```
Read @core/dependency-update/AGENTS.md

Help configure update-dependencies.yaml for:
- LIBRARY: spring-boot-starter-parent
- NEW_VERSION: 3.5.0
- TARGET_REPOS: [service-a, service-b, service-c]
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

**Apply the quality checklist:**
```
Apply the quality checklist from @core/tech-spec/GENERATE_API_TECH_SPEC.md to the output you just produced.
```

**Resume a session mid-task:**
```
Continue from where we left off — we finished the controller analysis. Now analyze the usecase and each step.
```
