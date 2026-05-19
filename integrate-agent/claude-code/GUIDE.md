# Claude Code — Getting Started Guide

> **Before you begin:** Complete [QUICKSTART.md](../../QUICKSTART.md) first — copy the example project and fill your placeholder values. Come back here when that's done.

---

## What is Claude Code?

Claude Code is a CLI + IDE extension that reads files, writes code, and runs tasks autonomously. It auto-reads `CLAUDE.md` at startup so it always knows your project context — no manual pasting required.

Use `@file` to inject any framework file directly into a prompt.

> **Headless / scripted usage:** See [RUN_STEP_GUIDE.md](RUN_STEP_GUIDE.md) — a shell script runner (`run-step.sh`) that assembles context files and calls `claude -p` for each workflow step automatically.

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

**Alternative: framework already inside your repo**

```
your-project/
├── CLAUDE.md
├── agent-framework/   ← this framework
└── src/
```

---

### Step 2 — Add this block to your `CLAUDE.md`

```markdown
## AI Framework

This project uses the Agentic Context-Driven Design Framework in `agent-framework/`.

### Rule: loading order for every task
1. Read @agent-framework/projects/<your-project>/AGENTS.md  ← ALWAYS first
2. Read @agent-framework/projects/<your-project>/<domain>/AGENTS.md  (if needed)
3. Run  @agent-framework/core/<module>/<PROMPT>.md

### Module map
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

### Step 3 — Add permissions to `.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Read(agent-framework/**)",
      "Write(projects/<your-project>/**)",
      "Write(output/**)"
    ]
  }
}
```

---

### Step 4 — Verify

Start Claude Code and ask:

```
What agent modules are available in this project?
```

Claude Code should list the modules from `CLAUDE.md` without you naming any file.

```bash
cd /path/to/your-project
claude
```

---

## Part 2 — Running Tasks (copy, fill, send)

The golden rule for every task:

```
1. Load  @agent-framework/projects/<your-project>/AGENTS.md   ← always first
2. Load  @agent-framework/projects/<your-project>/<domain>/AGENTS.md  (if needed)
3. Run   @agent-framework/core/<module>/<PROMPT>.md
```

Replace `acme-pay` below with your own project folder name.

---

### Task 1 — Write an FSD

```
Read @agent-framework/core/fsd/AGENTS.md
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/fsd/existing-feature-fsd.md   # optional: style reference

Use @agent-framework/core/fsd/FSD_TEMPLATE.md to write an FSD for:
- FEATURE_NAME: Payment Gateway
- FEATURE_SLUG: payment-gateway
- DESCRIPTION: Allow operators to submit outbound payment transactions with validation and audit logging

Fill all sections. Flag any open questions you cannot answer.
Write output to: projects/acme-pay/fsd/payment-gateway-fsd.md
```

---

### Task 2 — Extract user stories from FSD

```
Read @agent-framework/core/ba-analysis/AGENTS.md
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/fsd/payment-gateway-fsd.md

Run the BA Analysis process:
1. Extract actors and personas
2. Write numbered user stories (US-001, US-002...) in As a / I want / So that format
3. Write Given/When/Then acceptance criteria — at least 2 scenarios per story
4. List open questions

Write output to: output/payment-gateway/ba/user-stories.md
```

---

### Task 3 — Generate tech spec from FSD

```
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/core/nfr/AGENTS.md
Read @agent-framework/core/tech-stack/AGENTS.md
Read @agent-framework/projects/acme-pay/fsd/payment-gateway-fsd.md

Run @agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md

Inputs:
- FEATURE_SLUG: payment-gateway
- CURRENT_DATE: {{TODAY}}

Write all output to: output/payment-gateway/technical-spec/
```

---

### Task 4 — Generate all tests (RED phase — before any code)

**4a — Unit tests**

```
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/backend/AGENTS.md
Read @agent-framework/output/payment-gateway/technical-spec/api-specification.md
Read @agent-framework/output/payment-gateway/technical-spec/validation-rules.md

Run Phase 1a of @agent-framework/core/tdd/TDD_CYCLE.md

Generate JUnit 5 unit test stubs for:
- PaymentGatewayController
- CreatePaymentUseCaseImpl
- ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep

Rules:
- Tests must COMPILE but FAIL — production classes do not exist yet
- @ExtendWith(MockitoExtension.class) only — no JUnit 4
- Never mock the Context object — instantiate with new
- Every test maps to a spec requirement — add traceability comment

Write to: src/test/java/com/acme/pay/restapi/paymentgateway/
```

**4b — Integration tests (repository layer)**

```
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/backend/AGENTS.md
Read @agent-framework/output/payment-gateway/technical-spec/database-schema.md

Run Phase 1b of @agent-framework/core/tdd/TDD_CYCLE.md

Generate @JdbcTest integration test stubs for PaymentRepository:
- Use real H2 schema (schema.sql mirroring production)
- Never @MockBean the datasource
- Cover all query methods, null handling, empty results, boundary values
- Tests must COMPILE but FAIL

Write to: src/test/java/com/acme/pay/restapi/paymentgateway/repository/
```

**4c — E2E acceptance tests (Playwright)**

```
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
Read @agent-framework/output/payment-gateway/ba/user-stories.md

Run Phase 1c of @agent-framework/core/tdd/TDD_CYCLE.md

Generate Playwright TypeScript E2E tests for payment-gateway:
- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- Cover every Given/When/Then scenario from user-stories.md
- Tests will FAIL at runtime — the feature does not exist yet

Write to: e2e/tests/payment-gateway.spec.ts
```

---

### Task 5 — Implement code (GREEN phase)

Implement in this order: Repository → Steps → UseCase → Controller

```
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/backend/AGENTS.md
Read @agent-framework/core/tdd/TDD_CYCLE.md
Read @agent-framework/core/nfr/AGENTS.md

Run TDD_CYCLE.md Phase 2 (GREEN) for feature: payment-gateway

Implement in dependency order:
1. PaymentRepository — make integration tests green
2. ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep — make unit tests green
3. CreatePaymentUseCaseImpl — make unit tests green
4. PaymentGatewayController — make unit tests green

After each layer: run that layer's tests — must be green before moving on.
After all layers: run the FULL suite (unit + integration). Print results summary.
```

---

### Task 6 — Refactor

```
Read @agent-framework/projects/acme-pay/backend/AGENTS.md
Read @agent-framework/core/nfr/AGENTS.md
Read @agent-framework/core/tdd/TDD_CYCLE.md

Run TDD_CYCLE.md Phase 3 (REFACTOR) for feature: payment-gateway

Check each production class:
- Naming follows AGENTS.md conventions
- App log entries include all 3 NFR mandatory fields (event_date_time, log_type, level)
- Error messages to client are generic — no stack traces, no internal paths
- Account numbers masked server-side before any response

After every change: run the FULL test suite. All tests must stay green.
```

---

### Task 7 — Code review

```
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/backend/AGENTS.md
Read @agent-framework/core/code-review/REVIEW_STANDARD.md
Read @agent-framework/core/nfr/AGENTS.md
Read @agent-framework/output/payment-gateway/technical-spec/api-specification.md

Review branch: feature/payment-gateway

Cover all 7 dimensions:
1. Performance  2. Code smell  3. Security (NFR Section 5)
4. Structure (Usecase → Step compliance)  5. Spec-to-code mapping
6. Business logic  7. Test coverage (unit ≥ 80%, integration, E2E)

Write report to: output/payment-gateway/review/review-report-{{TIMESTAMP}}.md
```

---

### Task 8 — E2E execution and reporting

```
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
Read @agent-framework/output/payment-gateway/ba/user-stories.md

Run E2E tests from Task 4c against SIT:
- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- FEATURE_NAME: payment-gateway

After the run: embed screenshots and PASS/FAIL per acceptance criterion.
Write to: output/payment-gateway/e2e/e2e-report-{{TIMESTAMP}}.md
```

---

## One-off tasks

### Generate spec from existing code

```
Read @agent-framework/core/code-to-spec/AGENTS.md
Read @agent-framework/projects/acme-pay/AGENTS.md

Run @agent-framework/core/code-to-spec/GENERATE_API_SPEC.md with:
- HTTP_METHOD: POST
- API_PATH: /api/acme-pay/v1/payment/submit
- SOURCE_ROOT: src/main/java

Trace controller → usecase → steps.
Write output to: output/payment-gateway/technical-spec/api-specification.md
```

### Add tests to existing code (no TDD)

```
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/backend/AGENTS.md

Analyse the existing production class:
@src/main/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStep.java

Generate JUnit 5 tests covering: happy path, each exception path, boundary values.
Add an integration test if the class accesses the database.
Coverage target ≥ 80%.
```

### Record an architecture decision (ADR)

```
Read @agent-framework/core/adr/AGENTS.md
Read @agent-framework/projects/acme-pay/AGENTS.md
Read @agent-framework/projects/acme-pay/adr/INDEX.md

Use @agent-framework/core/adr/ADR_TEMPLATE.md to author an ADR for:
- DECISION_TOPIC: Choice of message broker for payment event publishing
- NEXT_ADR_ID: ADR-PAY-003

List at least two options with honest pros and cons.
Write to: projects/acme-pay/adr/ADR-PAY-003-{{slug}}.md
Update: projects/acme-pay/adr/INDEX.md
```

### Bump a Maven dependency across repos

```
Read @agent-framework/core/dependency-update/AGENTS.md

Configure update-dependencies.yaml for:
- LIBRARY: spring-boot-starter-parent
- NEW_VERSION: 3.5.0
- TARGET_REPOS: [acme-pay-backend, acme-pay-bff]
- GIT_TOKEN: env var GIT_TOKEN (do not hardcode)

Show the YAML and the command to run the update script.
```

---

## CI/CD mode

For scripted or pipeline usage, use [`run-step.sh`](RUN_STEP_GUIDE.md) — it assembles context files and calls `claude -p` per step, with a progress spinner for interactive runs and clean output in CI.

```bash
# Run a single step headless
./run-step.sh code-review -p acme-pay -f payment-gateway

# Or run all steps in one command
./run-step.sh run-all -p acme-pay -f payment-gateway \
  -n "Payment Gateway" -d "Allow operators to submit outbound payment transactions"
```

See [RUN_STEP_GUIDE.md](RUN_STEP_GUIDE.md) for all parameters and examples.

Alternatively, call `claude -p` directly:

```bash
claude -p "Read @agent-framework/projects/acme-pay/AGENTS.md and \
@agent-framework/core/code-review/REVIEW_STANDARD.md. \
Review branch feature/payment-gateway against \
@output/payment-gateway/technical-spec/api-specification.md"
```

---

## Useful tips

**Load multiple files at once:**
```
Read @agent-framework/projects/acme-pay/AGENTS.md, @agent-framework/core/nfr/AGENTS.md, then ...
```

**Tell Claude Code where to write output:**
```
Write all output to output/payment-gateway/technical-spec/ using UPPER_SNAKE_CASE.md naming.
```

**Resume a session mid-task:**
```
Continue from where we left off — unit tests for ValidatePaymentStep are done.
Now generate unit tests for SavePaymentStep.
```
