# WORKFLOW_EXAMPLES — OpenAI / ChatGPT Integration

Two formats per example: **Chat UI** (paste into ChatGPT) and **API** (Python snippet).

Examples use the `acme-pay` project. Replace with your own project folder name and file paths.

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
3. validation-rules.md — field-level and business rules
4. error-codes.md — new error codes using PAY prefix
5. sequence-diagrams.md — PlantUML per operation

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

## Step 4 — Generate Failing Unit Tests (RED)

**Chat UI — system block:**
```
You are a Java test engineer practicing TDD.

Project context:
[paste content of projects/acme-pay/AGENTS.md]
[paste content of projects/acme-pay/backend/AGENTS.md]

TDD rules:
[paste content of core/tdd/TDD_CYCLE.md — Phase 1 section only]
```

**Chat UI — follow-up:**
```
Generate JUnit 5 test stubs for ValidatePaymentStep.

Spec reference:
[paste content of output/payment-gateway/technical-spec/validation-rules.md]
[paste content of output/payment-gateway/technical-spec/error-codes.md]

Rules:
- @ExtendWith(MockitoExtension.class) — no JUnit 4
- Tests must compile but FAIL — production class does not exist yet
- Never mock Context — always new CreatePaymentContext(...)
- Add traceability comment mapping each test to a spec requirement
```

---

## Step 5 — Implement to Pass Tests (GREEN + REFACTOR)

**Chat UI — system block:**
```
You are a Java developer following the Usecase → Step pattern.

Project context:
[paste content of projects/acme-pay/AGENTS.md]
[paste content of projects/acme-pay/backend/AGENTS.md]
[paste content of core/nfr/AGENTS.md — Sections 1 and 5 only]
```

**Chat UI — follow-up (GREEN):**
```
Write ValidatePaymentStep.java to make all these tests pass:

[paste test file content]

Write ONLY enough code to pass the tests. No extra logic.
```

**Chat UI — follow-up (REFACTOR):**
```
Refactor this implementation:
[paste Step class]

Check:
- Naming follows AGENTS.md conventions
- Application log entry includes event_date_time, log_type, level
- Error messages to client are generic (no internal paths, no stack traces)
- Account numbers masked server-side before response
```

---

## Step 6 — Code Review

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

[paste git diff output]
```

---

## Step 7 — E2E Test Generation

**Chat UI — system block:**
```
You are an E2E test engineer using Playwright with TypeScript.

Project context:
[paste content of projects/acme-pay/AGENTS.md]
[paste content of projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md]
```

**Chat UI — follow-up:**
```
Generate Playwright TypeScript E2E tests for payment-gateway.

BASE_URL: https://acme-pay-sit.example.com
AUTH_SESSION_FILE: playwright/.auth/session.json

Acceptance criteria to cover:
[paste user-stories.md content]

Output: e2e/tests/payment-gateway.spec.ts
```

---

## Batch Script — Generate Specs for Multiple Features

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
