# WORKFLOW_EXAMPLES — OpenAI / ChatGPT Integration

Two formats per example: **Chat UI** (paste into ChatGPT) and **API** (Python snippet).

Examples use the `acme-pay` project. Replace with your own project folder name and file paths.

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

**Chat UI — system block:**
```
You are a business analyst following this FSD standard:
[paste content of core/fsd/AGENTS.md]

Project context:
[paste content of projects/acme-pay/AGENTS.md]
```

**Chat UI — follow-up (author):**
```
Write an FSD using the template structure for:
- FEATURE_NAME: Payment Gateway
- FEATURE_SLUG: payment-gateway
- DESCRIPTION: Allow operators to submit outbound payment transactions with validation and audit logging

Fill all required sections. Flag any open questions.
```

**Chat UI — follow-up (review):**
```
Review this FSD for completeness. Check: all sections present, Given/When/Then acceptance criteria,
no unresolved open questions, business rules cover all error scenarios.

[paste FSD content]
```

---

## Step 2 — BA Analysis (FSD → User Stories)

**Chat UI — system block:**
```
You are a business analyst. Follow this process:
[paste content of core/ba-analysis/AGENTS.md]
```

**Chat UI — follow-up:**
```
Analyze this FSD and produce:
1. Numbered user stories (US-001...) in As a / I want / So that format
2. Given/When/Then acceptance criteria — minimum 2 scenarios per story
3. Open questions list

[paste FSD content]
```

**API call:**
```python
from openai import OpenAI
from pathlib import Path

client = OpenAI()
FRAMEWORK = Path("agent-framework")

ba_agents   = (FRAMEWORK / "core/ba-analysis/AGENTS.md").read_text()
proj_agents = (FRAMEWORK / "projects/acme-pay/AGENTS.md").read_text()
fsd         = (FRAMEWORK / "projects/acme-pay/fsd/payment-gateway-fsd.md").read_text()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": ba_agents + "\n\n" + proj_agents},
        {"role": "user",   "content": f"Analyze this FSD:\n\n{fsd}"},
    ]
)
Path("output/payment-gateway/ba/user-stories.md").write_text(
    response.choices[0].message.content
)
```

---

## Step 3 — Generate Tech Spec from FSD

**Chat UI — system block:**
```
You are a technical writer generating API specifications.

Project context:
[paste content of projects/acme-pay/AGENTS.md]

NFR standards (apply to all generated specs):
[paste content of core/nfr/AGENTS.md]

Tech stack reference:
[paste content of core/tech-stack/AGENTS.md]

Generation rules:
[paste content of core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md]
```

**Chat UI — follow-up:**
```
FEATURE_SLUG: payment-gateway
CURRENT_DATE: {{TODAY}}

FSD: [paste FSD content]

Generate the full technical specification:
1. Classify FSD type (api/batch/db)
2. api-specification.md — endpoints, request/response models, field mapping
3. database-schema.md — tables, columns, constraints
4. validation-rules.md — field-level and business rules
5. error-codes.md — new error codes using PAY prefix
6. sequence-diagrams.md — PlantUML per operation

Apply NFR rules: structured JSON logging fields, server-side account masking, generic error messages.
```

**API call:**
```python
proj_agents  = (FRAMEWORK / "projects/acme-pay/AGENTS.md").read_text()
nfr          = (FRAMEWORK / "core/nfr/AGENTS.md").read_text()
tech_stack   = (FRAMEWORK / "core/tech-stack/AGENTS.md").read_text()
spec_router  = (FRAMEWORK / "core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md").read_text()
fsd          = (FRAMEWORK / "projects/acme-pay/fsd/payment-gateway-fsd.md").read_text()

system = "\n\n".join([proj_agents, nfr, tech_stack, spec_router])

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": system},
        {"role": "user",   "content": f"FEATURE_SLUG: payment-gateway\n\nFSD:\n{fsd}"},
    ],
    max_tokens=8000,
)
```

---

## Step 4 — Generate All Test Cases (RED)

**All three layers written together — before any production code.**

### 4a — Unit Tests

**Chat UI — system block:**
```
You are a Java test engineer practicing TDD.

Project context:
[paste content of projects/acme-pay/AGENTS.md]
[paste content of projects/acme-pay/backend/AGENTS.md]

TDD rules:
[paste Phase 1a from core/tdd/TDD_CYCLE.md]
```

**Chat UI — follow-up:**
```
Generate JUnit 5 unit test stubs for:
- PaymentGatewayController
- CreatePaymentUseCaseImpl
- ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep

Spec reference:
[paste content of output/payment-gateway/technical-spec/validation-rules.md]
[paste content of output/payment-gateway/technical-spec/error-codes.md]

Rules:
- @ExtendWith(MockitoExtension.class) — no JUnit 4
- Tests must compile but FAIL — production classes do not exist yet
- Never mock the Context object — always instantiate with new
- Cover Context field contracts: if a Step writes a field another Step reads, include a handoff test
- Add traceability comment mapping each test to a spec requirement
```

**API call:**
```python
proj_agents  = (FRAMEWORK / "projects/acme-pay/AGENTS.md").read_text()
backend      = (FRAMEWORK / "projects/acme-pay/backend/AGENTS.md").read_text()
tdd_cycle    = (FRAMEWORK / "core/tdd/TDD_CYCLE.md").read_text()
val_rules    = Path("output/payment-gateway/technical-spec/validation-rules.md").read_text()
error_codes  = Path("output/payment-gateway/technical-spec/error-codes.md").read_text()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": proj_agents + "\n\n" + backend + "\n\n" + tdd_cycle},
        {"role": "user",   "content": (
            "Generate JUnit 5 unit test stubs for ValidatePaymentStep.\n\n"
            f"Validation rules:\n{val_rules}\n\nError codes:\n{error_codes}"
        )},
    ],
    max_tokens=6000,
)
```

### 4b — Integration Tests (Repository)

**Chat UI — follow-up:**
```
Generate integration test stubs for PaymentRepository.

DB schema:
[paste content of output/payment-gateway/technical-spec/database-schema.md]

Rules:
- @JdbcTest with real H2 schema (schema.sql mirroring production)
- Never @MockBean the datasource — SQL behavior must run against a real schema
- Cover: all query methods, null column handling, empty result set, boundary data
- Tests must compile but FAIL — repository class does not exist yet
```

**API call:**
```python
db_schema = Path("output/payment-gateway/technical-spec/database-schema.md").read_text()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": proj_agents + "\n\n" + backend},
        {"role": "user",   "content": (
            "Generate @JdbcTest integration test stubs for PaymentRepository.\n\n"
            f"DB schema:\n{db_schema}\n\n"
            "Use H2 in-memory DB. Never mock the datasource. "
            "Cover all query methods and null/boundary cases."
        )},
    ],
    max_tokens=4000,
)
```

### 4c — E2E Acceptance Tests

**Chat UI — follow-up:**
```
Generate Playwright TypeScript E2E acceptance tests for payment-gateway.

BASE_URL: https://acme-pay-sit.example.com
AUTH_SESSION_FILE: playwright/.auth/session.json

Acceptance criteria to cover (every Given/When/Then — happy path + all error paths):
[paste user-stories.md content]

Output: e2e/tests/payment-gateway.spec.ts
Tests will FAIL at runtime — the feature endpoint does not exist yet.
```

**API call:**
```python
e2e_config   = (FRAMEWORK / "projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md").read_text()
user_stories = Path("output/payment-gateway/ba/user-stories.md").read_text()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": proj_agents + "\n\n" + e2e_config},
        {"role": "user",   "content": (
            "BASE_URL: https://acme-pay-sit.example.com\n"
            "AUTH_SESSION_FILE: playwright/.auth/session.json\n\n"
            f"User stories (cover every Given/When/Then):\n{user_stories}\n\n"
            "Generate the Playwright TypeScript E2E acceptance test file."
        )},
    ],
    max_tokens=6000,
)
Path("e2e/tests/payment-gateway.spec.ts").write_text(
    response.choices[0].message.content
)
```

---

## Step 5 — Implement to Pass Tests (GREEN)

**Implement in order: Repository → Step → UseCase → Controller**

**Chat UI — system block:**
```
You are a Java developer following the Usecase → Step pattern.

Project context:
[paste content of projects/acme-pay/AGENTS.md]
[paste content of projects/acme-pay/backend/AGENTS.md]
[paste content of core/nfr/AGENTS.md — Sections 1 and 5 only]
```

**Chat UI — follow-up (GREEN per layer):**
```
Implement in dependency order:
1. PaymentRepository — write minimum code to make integration tests green
2. ValidatePaymentStep — write minimum code to make unit tests green
3. SavePaymentStep, PublishPaymentEventStep — same
4. CreatePaymentUseCaseImpl — orchestrate steps; make unit tests green
5. PaymentGatewayController — routing only; make unit tests green

For each class, write ONLY enough code to pass its tests. No extra logic.

[paste the failing test file for the class being implemented]
```

---

## Step 6 — Refactor

**Chat UI — follow-up:**
```
Refactor the implementation:
[paste each production class]

Check:
- Naming follows AGENTS.md conventions
- Application log entries include all 3 NFR mandatory fields (event_date_time, log_type, level)
- Error messages to client are generic — no stack traces, no internal paths
- Account numbers masked server-side before any response
- Context field contracts documented — fields shared between Steps have named constants

After each change: run the FULL test suite (unit + integration) — not just the changed class.
All tests must remain green. Report final coverage per layer.
```

---

## Step 7 — Code Review

**Chat UI — system block:**
```
You are a senior Java code reviewer.

Review standard:
[paste content of core/code-review/REVIEW_STANDARD.md]

Architecture context:
[paste content of projects/acme-pay/backend/AGENTS.md]

NFR standards:
[paste content of core/nfr/AGENTS.md]
```

**Chat UI — follow-up:**
```
Review the following code diff for the payment-gateway feature.
Reference spec: [paste api-specification.md]

Produce a Markdown report covering all 7 dimensions:
Performance, Code Smell, Security, Structure, Spec Mapping, Business Logic, Test Coverage.

Test coverage dimension must check:
- Unit ≥ 80% per class
- Integration tests cover all repository methods (no mocked datasource)
- E2E covers all FSD Given/When/Then scenarios

[paste git diff output]
```

**API call:**
```python
import subprocess

review_std  = (FRAMEWORK / "core/code-review/REVIEW_STANDARD.md").read_text()
backend_ref = (FRAMEWORK / "projects/acme-pay/backend/AGENTS.md").read_text()
diff        = subprocess.check_output(
    ["git", "diff", "origin/main...feature/payment-gateway"], text=True
)

response = client.chat.completions.create(
    model="gpt-4o", max_tokens=6000,
    messages=[
        {"role": "system", "content": review_std + "\n\nArchitecture:\n" + backend_ref},
        {"role": "user",   "content": f"BRANCH: feature/payment-gateway\n\nDiff:\n{diff}"},
    ],
)
Path("output/payment-gateway/review/review-report.md").write_text(
    response.choices[0].message.content
)
```

---

## Step 8 — E2E Execution & Reporting

**Chat UI — follow-up:**
```
The E2E tests from Step 4c have been run against SIT.

BASE_URL: https://acme-pay-sit.example.com
RESULT_DIR: e2e/test-results/payment-gateway

Report PASS/FAIL per acceptance criterion from user-stories.md.
Include screenshot references and a summary of failures.
```

---

## Standalone Examples

### Non-TDD: Generate Spec from Existing Source Code

```python
agents_md   = (FRAMEWORK / "core/code-to-spec/AGENTS.md").read_text()
prompt_file = (FRAMEWORK / "core/code-to-spec/GENERATE_API_SPEC.md").read_text()
controller  = Path(
    "src/main/java/com/acme/pay/restapi/paymentgateway/controller/PaymentGatewayController.java"
).read_text()

response = client.chat.completions.create(
    model="gpt-4o", max_tokens=8000,
    messages=[
        {"role": "system", "content": agents_md + "\n\n" + prompt_file},
        {"role": "user",   "content": (
            "HTTP_METHOD: POST\nAPI_PATH: /api/acme-pay/v1/payment/submit\n\n"
            f"Controller:\n{controller}"
        )},
    ],
)
```

### Non-TDD: Add Tests to Existing Code

```python
backend     = (FRAMEWORK / "projects/acme-pay/backend/AGENTS.md").read_text()
tdd_cycle   = (FRAMEWORK / "core/tdd/TDD_CYCLE.md").read_text()
step_src    = Path(
    "src/main/java/com/acme/pay/restapi/paymentgateway/step/ValidatePaymentStep.java"
).read_text()

response = client.chat.completions.create(
    model="gpt-4o", max_tokens=6000,
    messages=[
        {"role": "system", "content": backend + "\n\n" + tdd_cycle},
        {"role": "user",   "content": (
            f"Existing production class:\n{step_src}\n\n"
            "Generate JUnit 5 unit tests covering happy path, each exception path, boundary values. "
            "Also generate an integration test if the class accesses the database. "
            "Coverage target ≥ 80%."
        )},
    ],
)
```

### Architecture Decision Record — Author a New ADR

**Chat UI — system block:**
```
You are an experienced software architect.

ADR module rules:
[paste content of core/adr/AGENTS.md]

Project context:
[paste content of projects/acme-pay/AGENTS.md]

Existing ADRs:
[paste content of projects/acme-pay/adr/INDEX.md]
```

**Chat UI — follow-up:**
```
Use the ADR_TEMPLATE to author an ADR for:
- DECISION_TOPIC: Choice of message broker for payment event publishing
- NEXT_ADR_ID: ADR-PAY-003

Fill all sections. List at least two options with honest pros and cons.
```

**API call:**
```python
adr_agents = (FRAMEWORK / "core/adr/AGENTS.md").read_text()
adr_tpl    = (FRAMEWORK / "core/adr/ADR_TEMPLATE.md").read_text()
proj       = (FRAMEWORK / "projects/acme-pay/AGENTS.md").read_text()
index      = (FRAMEWORK / "projects/acme-pay/adr/INDEX.md").read_text()

response = client.chat.completions.create(
    model="gpt-4o", max_tokens=4000,
    messages=[
        {"role": "system", "content": "\n\n".join([adr_agents, proj, index])},
        {"role": "user",   "content": (
            f"Use this template:\n{adr_tpl}\n\n"
            "Author ADR-PAY-003 for: Choice of message broker for payment event publishing.\n"
            "List at least two options with honest pros and cons."
        )},
    ],
)
Path("projects/acme-pay/adr/ADR-PAY-003-message-broker.md").write_text(
    response.choices[0].message.content
)
```

### Architecture Decision Record — Query Before Starting a Feature

**API call:**
```python
adr_agents = (FRAMEWORK / "core/adr/AGENTS.md").read_text()
adr_query  = (FRAMEWORK / "core/adr/ADR_QUERY.md").read_text()
proj       = (FRAMEWORK / "projects/acme-pay/AGENTS.md").read_text()
adrs       = "\n\n".join(
    f.read_text() for f in (FRAMEWORK / "projects/acme-pay/adr").glob("ADR-*.md")
)

response = client.chat.completions.create(
    model="gpt-4o", max_tokens=2000,
    messages=[
        {"role": "system", "content": "\n\n".join([adr_agents, proj])},
        {"role": "user",   "content": (
            f"Existing ADRs:\n{adrs}\n\n"
            + adr_query +
            "\nQUERY_TOPIC: database access\nFEATURE_SLUG: payment-gateway"
        )},
    ],
)
```

### Batch Script — Generate Specs for Multiple Features

```python
import os
from openai import OpenAI
from pathlib import Path

client     = OpenAI(api_key=os.environ["OPENAI_API_KEY"])
FRAMEWORK  = Path("agent-framework")

features = [
    {"slug": "payment-gateway",   "fsd": "projects/acme-pay/fsd/payment-gateway-fsd.md"},
    {"slug": "refund-processing",  "fsd": "projects/acme-pay/fsd/refund-processing-fsd.md"},
]

proj_agents = (FRAMEWORK / "projects/acme-pay/AGENTS.md").read_text()
nfr         = (FRAMEWORK / "core/nfr/AGENTS.md").read_text()
spec_router = (FRAMEWORK / "core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md").read_text()
system      = "\n\n".join([proj_agents, nfr, spec_router])

for feat in features:
    fsd  = (FRAMEWORK / feat["fsd"]).read_text()
    resp = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system},
            {"role": "user",   "content": f"FEATURE_SLUG: {feat['slug']}\n\nFSD:\n{fsd}"},
        ],
        max_tokens=8000,
    )
    out = Path(f"output/{feat['slug']}/technical-spec/api-specification.md")
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(resp.choices[0].message.content)
    print(f"✅ {feat['slug']} → {out}")
```

---

## Tips

**For very long FSDs:** split by section and make multiple API calls; combine outputs afterward.

**Structured JSON output (for pipeline processing):**
```python
response = client.chat.completions.create(
    model="gpt-4o",
    response_format={"type": "json_object"},
    messages=[
        {"role": "system", "content": "Return spec as JSON with keys: overview, endpoints, validation, errors, diagrams"},
        {"role": "user",   "content": user_message},
    ]
)
```

**Track token usage:**
```python
usage = response.usage
print(f"Tokens: {usage.prompt_tokens} in / {usage.completion_tokens} out")
```
