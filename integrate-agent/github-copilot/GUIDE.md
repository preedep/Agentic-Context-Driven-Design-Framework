# GitHub Copilot — Getting Started Guide

> **Before you begin:** Complete [QUICKSTART.md](../../QUICKSTART.md) first — copy the example project and fill your placeholder values. Come back here when that's done.

---

## What is GitHub Copilot?

GitHub Copilot Chat is built into VS Code and JetBrains. It picks up your repository context via `.github/copilot-instructions.md` — injected automatically into every session. Attach any framework file using `#file:` in your chat message.

**Open Copilot Chat:**
- VS Code: `⌃⌘I` (Mac) / `Ctrl+Alt+I` (Windows/Linux)
- JetBrains: `⌥⇧G`

---

## Part 1 — One-Time Setup (do this once)

### Step 1 — Add the framework to your project

**Recommended: git submodule**

```bash
git submodule add https://github.com/preedep/Agentic-Context-Driven-Design-Framework agent-framework
git submodule set-branch --branch main agent-framework
git submodule update --init --recursive
```

Update later with:
```bash
git submodule update --remote agent-framework
git add agent-framework && git commit -m "chore: update agent-framework"
```

**Alternative: multi-root workspace (framework in a sibling folder)**

Create `project.code-workspace`:
```json
{
  "folders": [
    { "path": "your-project",    "name": "Project" },
    { "path": "agent-framework", "name": "AI Framework" }
  ]
}
```
Open with: `code project.code-workspace`

---

### Step 2 — Create `.github/copilot-instructions.md`

Create this file at your project root. Copilot injects it into every chat session automatically.

```markdown
# Copilot Instructions

This project uses the Agentic Context-Driven Design Framework in `agent-framework/`.

## Rule: loading order for every task
1. #file:agent-framework/projects/<your-project>/AGENTS.md  ← ALWAYS first
2. #file:agent-framework/projects/<your-project>/<domain>/AGENTS.md  (if needed)
3. #file:agent-framework/core/<module>/<PROMPT>.md

## Module map
| Task | File to run |
|---|---|
| Write / review FSD                  | `agent-framework/core/fsd/FSD_TEMPLATE.md` |
| FSD → user stories                  | `agent-framework/core/ba-analysis/AGENTS.md` |
| User stories → tech spec            | `agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md` |
| TDD cycle (RED → GREEN → REFACTOR)  | `agent-framework/core/tdd/TDD_CYCLE.md` |
| Generate unit tests                 | `agent-framework/core/unit-test/AGENTS.md` |
| Generate E2E Playwright tests       | `agent-framework/core/e2e-test/GEN_SCRIPT_FROM_TC.md` |
| Write Java Spring Boot code         | `agent-framework/core/java-developer-coding/AGENTS.md` |
| Write Node.js / TypeScript code     | `agent-framework/core/nodejs-developer-coding/AGENTS.md` |
| Code review (7 dimensions)          | `agent-framework/core/code-review/REVIEW_STANDARD.md` |
| Reverse-engineer spec from code     | `agent-framework/core/code-to-spec/GENERATE_API_SPEC.md` |
| Architecture decisions (ADR)        | `agent-framework/core/adr/ADR_TEMPLATE.md` |
| NFR / security / OWASP check        | `agent-framework/core/nfr/AGENTS.md` |
| Bump Maven dependency across repos  | `agent-framework/core/dependency-update/AGENTS.md` |
```

---

### Step 3 — Verify

In Copilot Chat, type:

```
@workspace What agent modules are available for backend tasks?
```

Copilot should list the modules from `copilot-instructions.md` without you attaching any file manually.

---

## Part 2 — Running Tasks (copy, fill, send)

The golden rule: **always attach project AGENTS.md first**, then domain AGENTS.md if needed, then the prompt file.

Attach files by typing `#file:path` or dragging them from the VS Code Explorer into the chat.

Replace `acme-pay` below with your own project folder name.

---

### Task 1 — Write an FSD

```
#file:agent-framework/core/fsd/AGENTS.md
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/fsd/existing-feature-fsd.md   // optional: style reference

Use the FSD_TEMPLATE.md structure to write an FSD for:
- FEATURE_NAME: Payment Gateway
- FEATURE_SLUG: payment-gateway
- DESCRIPTION: Allow operators to submit outbound payment transactions with validation and audit logging

Fill all required sections. Flag open questions you cannot answer.
```

---

### Task 2 — Extract user stories from FSD

```
#file:agent-framework/core/ba-analysis/AGENTS.md
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/fsd/payment-gateway-fsd.md

Run BA Analysis:
1. Extract actors and personas
2. Write numbered user stories (US-001...) in As a / I want / So that format
3. Write Given/When/Then acceptance criteria — at least 2 scenarios per story
4. List open questions
```

---

### Task 3 — Generate tech spec from FSD

```
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/core/nfr/AGENTS.md
#file:agent-framework/core/tech-stack/AGENTS.md
#file:agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md
#file:agent-framework/projects/acme-pay/fsd/payment-gateway-fsd.md

Run the tech spec router.
FEATURE_SLUG: payment-gateway

Generate:
- api-specification.md (endpoints, request/response, field mapping)
- database-schema.md
- validation-rules.md
- error-codes.md (prefix: PAY)
- sequence-diagrams.md (PlantUML)

Apply NFR rules: structured JSON logging, server-side data masking, generic error messages.
```

---

### Task 4 — Generate all tests (RED phase — before any code)

**4a — Unit tests**

```
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/backend/AGENTS.md
#file:output/payment-gateway/technical-spec/api-specification.md
#file:output/payment-gateway/technical-spec/validation-rules.md

Generate JUnit 5 unit test stubs for:
- PaymentGatewayController
- CreatePaymentUseCaseImpl
- ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep

Rules:
- Tests must COMPILE but FAIL — production classes do not exist yet
- @ExtendWith(MockitoExtension.class) only
- Never mock the Context object — instantiate with new
- Add traceability comment mapping each test to a spec requirement
```

**4b — Integration tests (repository layer)**

```
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/backend/AGENTS.md
#file:output/payment-gateway/technical-spec/database-schema.md

Generate @JdbcTest integration test stubs for PaymentRepository:
- Use real H2 schema (schema.sql mirroring production)
- Never @MockBean the datasource
- Cover all query methods, null handling, empty results, boundary values
- Tests must COMPILE but FAIL
```

**4c — E2E acceptance tests (Playwright)**

```
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
#file:output/payment-gateway/ba/user-stories.md

Generate Playwright TypeScript E2E tests for payment-gateway:
- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- Cover every Given/When/Then scenario from user-stories.md
- Tests will FAIL at runtime — the feature does not exist yet

Output file: e2e/tests/payment-gateway.spec.ts
```

---

### Task 5 — Implement code (GREEN phase)

```
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/backend/AGENTS.md
#file:agent-framework/core/tdd/TDD_CYCLE.md
#file:src/test/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStepTest.java

Run TDD_CYCLE.md Phase 2 (GREEN).

Implement in dependency order:
1. PaymentRepository — make integration tests green first
2. ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep — make unit tests green
3. CreatePaymentUseCaseImpl — make unit tests green
4. PaymentGatewayController — make unit tests green

After each layer: confirm tests are green before moving on.
Write only enough code to pass the failing tests. No extra logic.
```

---

### Task 6 — Refactor

```
#file:agent-framework/core/nfr/AGENTS.md
#file:agent-framework/projects/acme-pay/backend/AGENTS.md
#file:agent-framework/core/tdd/TDD_CYCLE.md

Run TDD_CYCLE.md Phase 3 (REFACTOR).

Check each production class:
- Naming follows AGENTS.md conventions
- App log entries include all 3 NFR mandatory fields (event_date_time, log_type, level)
- Error messages to client are generic — no stack traces, no internal paths
- Account numbers masked server-side

After every change: run the FULL test suite. All tests must stay green.
```

---

### Task 7 — Code review

```
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/backend/AGENTS.md
#file:agent-framework/core/code-review/REVIEW_STANDARD.md
#file:agent-framework/core/nfr/AGENTS.md
#file:output/payment-gateway/technical-spec/api-specification.md

Review the current branch changes for payment-gateway.

Cover all 7 dimensions:
1. Performance  2. Code smell  3. Security (NFR Section 5)
4. Structure (Usecase → Step compliance)  5. Spec-to-code mapping
6. Business logic  7. Test coverage (unit ≥ 80%, integration, E2E)

Produce a Markdown table report.
```

---

### Task 8 — E2E execution and reporting

```
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
#file:output/payment-gateway/ba/user-stories.md

Run the Playwright E2E tests from Task 4c against SIT:
- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json

Report PASS/FAIL per acceptance criterion with screenshots.
```

---

## One-off tasks

### Generate spec from existing code

```
#file:agent-framework/core/code-to-spec/AGENTS.md
#file:agent-framework/core/code-to-spec/GENERATE_API_SPEC.md
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:src/main/java/com/acme/pay/restapi/paymentgateway/controller/PaymentGatewayController.java

Run GENERATE_API_SPEC for:
- HTTP_METHOD: POST
- API_PATH: /api/acme-pay/v1/payment/submit

Trace controller → usecase → steps and generate the API spec.
```

### Add tests to existing code (no TDD)

```
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/backend/AGENTS.md
#file:src/main/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStep.java

Generate JUnit 5 tests covering: happy path, each exception path, boundary values.
Add an integration test if the class accesses the database.
Coverage target ≥ 80%.
```

### Record an architecture decision (ADR)

```
#file:agent-framework/core/adr/AGENTS.md
#file:agent-framework/core/adr/ADR_TEMPLATE.md
#file:agent-framework/projects/acme-pay/AGENTS.md
#file:agent-framework/projects/acme-pay/adr/INDEX.md

Author an ADR for:
- DECISION_TOPIC: Choice of message broker for payment event publishing
- NEXT_ADR_ID: ADR-PAY-003

List at least two options with honest pros and cons.
```

---

## Useful tips

**Find files first, then attach:**
```
@workspace Which files implement the PaymentGateway usecase step?
```
Then attach results with `#file:` in your follow-up.

**Use Copilot Edits for multi-file output:**
Open Copilot Edits (`⇧⌘I`), drag the prompt file and relevant source files into context. Copilot proposes file changes to apply or reject.

**Iterative refinement:**
```
The sequence diagram is missing the error path. Add a failure branch showing the exception handler response.
```
