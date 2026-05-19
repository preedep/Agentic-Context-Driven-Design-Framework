# OpenAI / ChatGPT — Getting Started Guide

> **Before you begin:** Complete [QUICKSTART.md](../../QUICKSTART.md) first — copy the example project and fill your placeholder values. Come back here when that's done.

---

## What is this guide for?

OpenAI tools (ChatGPT UI and the OpenAI API) do not read files from disk automatically. You must paste context into the chat or inject it via the API system message. This guide covers both modes.

**Two ways to use this guide:**
- **Chat UI** — paste context blocks manually into ChatGPT
- **API / Python** — automate with the included `run_agent.py` helper

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

**Alternative: same repository**
```
your-project/
├── agent-framework/   ← this framework
├── src/
└── scripts/
    └── run_agent.py
```

---

### Step 2 — Save the Python helper (API mode only)

Save as `scripts/run_agent.py`:

```python
import os
from openai import OpenAI
from pathlib import Path

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])
FRAMEWORK_ROOT = Path(os.environ.get("AI_FRAMEWORK_PATH", "agent-framework"))

def run_agent(agents_md_path, prompt_path, user_message, model="gpt-4o", max_tokens=8000):
    agents_md   = (FRAMEWORK_ROOT / agents_md_path).read_text()
    prompt_file = (FRAMEWORK_ROOT / prompt_path).read_text() if prompt_path else ""
    system = f"--- AGENT CONTEXT ---\n{agents_md}"
    if prompt_file:
        system += f"\n\n--- TASK INSTRUCTIONS ---\n{prompt_file}"
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system},
            {"role": "user",   "content": user_message},
        ],
        max_tokens=max_tokens,
    )
    return response.choices[0].message.content

def save_output(content, out_path):
    p = Path(out_path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(content)
    print(f"Written → {p}")
```

---

### Step 3 — Choose your model

| Task | Recommended model |
|---|---|
| Tech spec, BA analysis, code review | `gpt-4o` |
| Unit test generation | `gpt-4o-mini` |
| Dependency update config | `gpt-4o-mini` |

---

### Step 4 — ChatGPT Projects (optional, no API needed)

Create one ChatGPT Project per task type — files are loaded automatically into every conversation:

1. ChatGPT → **Projects** → **New Project**
2. Upload the AGENTS.md files relevant to that task
3. Every conversation in that project has those files loaded — no pasting needed

| Project name | Upload these files |
|---|---|
| Tech Spec | `projects/acme-pay/AGENTS.md` + `core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md` |
| Code Review | `core/code-review/REVIEW_STANDARD.md` + `projects/acme-pay/backend/AGENTS.md` |
| Backend Tests | `projects/acme-pay/backend/AGENTS.md` |
| E2E Tests | `core/e2e-test/AGENTS.md` + `core/e2e-test/GEN_SCRIPT_FROM_TC.md` |

---

## Part 2 — Running Tasks

### How to use the Chat UI blocks

Each task below has a **System** block and a **User** block.

- Paste the **System** block at the top of a new conversation (or into the system message field if your UI supports it)
- Paste the **User** block as your first message
- Replace all `[paste content of ...]` with the actual file content

Replace `acme-pay` with your own project folder name.

---

### Task 1 — Write an FSD

**System:**
```
You are a business analyst.
[paste content of agent-framework/core/fsd/AGENTS.md]

Project context:
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
```

**User:**
```
Use the FSD_TEMPLATE.md structure to write an FSD for:
- FEATURE_NAME: Payment Gateway
- FEATURE_SLUG: payment-gateway
- DESCRIPTION: Allow operators to submit outbound payment transactions with validation and audit logging

Fill all required sections. Flag open questions you cannot answer.
```

---

### Task 2 — Extract user stories from FSD

**System:**
```
You are a business analyst. Follow this process:
[paste content of agent-framework/core/ba-analysis/AGENTS.md]

Project context:
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
```

**User:**
```
Analyze this FSD and produce:
1. Numbered user stories (US-001...) in As a / I want / So that format
2. Given/When/Then acceptance criteria — at least 2 scenarios per story
3. Open questions list

FSD:
[paste FSD content]
```

**API:**
```python
ba_agents   = (FRAMEWORK_ROOT / "core/ba-analysis/AGENTS.md").read_text()
proj_agents = (FRAMEWORK_ROOT / "projects/acme-pay/AGENTS.md").read_text()
fsd         = Path("projects/acme-pay/fsd/payment-gateway-fsd.md").read_text()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": ba_agents + "\n\n" + proj_agents},
        {"role": "user",   "content": f"Analyze this FSD:\n\n{fsd}"},
    ]
)
save_output(response.choices[0].message.content, "output/payment-gateway/ba/user-stories.md")
```

---

### Task 3 — Generate tech spec from FSD

**System:**
```
You are a technical writer generating API specifications.

Project context:
[paste content of agent-framework/projects/acme-pay/AGENTS.md]

NFR standards:
[paste content of agent-framework/core/nfr/AGENTS.md]

Tech stack:
[paste content of agent-framework/core/tech-stack/AGENTS.md]

Generation rules:
[paste content of agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md]
```

**User:**
```
FEATURE_SLUG: payment-gateway

FSD:
[paste FSD content]

Generate the full technical specification:
1. api-specification.md — endpoints, request/response, field mapping
2. database-schema.md
3. validation-rules.md
4. error-codes.md (prefix: PAY)
5. sequence-diagrams.md (PlantUML)
```

**API:**
```python
system = "\n\n".join([
    (FRAMEWORK_ROOT / "projects/acme-pay/AGENTS.md").read_text(),
    (FRAMEWORK_ROOT / "core/nfr/AGENTS.md").read_text(),
    (FRAMEWORK_ROOT / "core/tech-stack/AGENTS.md").read_text(),
    (FRAMEWORK_ROOT / "core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md").read_text(),
])
fsd = Path("projects/acme-pay/fsd/payment-gateway-fsd.md").read_text()

response = client.chat.completions.create(
    model="gpt-4o", max_tokens=8000,
    messages=[
        {"role": "system", "content": system},
        {"role": "user",   "content": f"FEATURE_SLUG: payment-gateway\n\nFSD:\n{fsd}"},
    ]
)
save_output(response.choices[0].message.content,
            "output/payment-gateway/technical-spec/api-specification.md")
```

---

### Task 4 — Generate all tests (RED phase — before any code)

**4a — Unit tests**

**System:**
```
You are a Java test engineer practising TDD.
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
[paste content of agent-framework/projects/acme-pay/backend/AGENTS.md]
[paste Phase 1a section from agent-framework/core/tdd/TDD_CYCLE.md]
```

**User:**
```
Generate JUnit 5 unit test stubs for:
- PaymentGatewayController
- CreatePaymentUseCaseImpl
- ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep

Spec reference:
[paste content of output/payment-gateway/technical-spec/validation-rules.md]
[paste content of output/payment-gateway/technical-spec/error-codes.md]

Rules:
- Tests must COMPILE but FAIL — production classes do not exist yet
- @ExtendWith(MockitoExtension.class) only
- Never mock the Context object — instantiate with new
- Add traceability comment mapping each test to a spec requirement
```

**4b — Integration tests (repository)**

**User:**
```
Generate @JdbcTest integration test stubs for PaymentRepository.

DB schema:
[paste content of output/payment-gateway/technical-spec/database-schema.md]

Rules:
- Use real H2 schema (schema.sql mirroring production)
- Never @MockBean the datasource
- Cover all query methods, null handling, empty results, boundary values
- Tests must COMPILE but FAIL
```

**4c — E2E acceptance tests**

**User:**
```
Generate Playwright TypeScript E2E acceptance tests for payment-gateway.

BASE_URL: https://acme-pay-sit.example.com
AUTH_SESSION_FILE: playwright/.auth/session.json

Acceptance criteria:
[paste content of output/payment-gateway/ba/user-stories.md]

Cover every Given/When/Then scenario. Tests will FAIL at runtime — the feature does not exist yet.
Output file: e2e/tests/payment-gateway.spec.ts
```

---

### Task 5 — Implement code (GREEN phase)

**System:**
```
You are a Java developer following the Usecase → Step pattern.
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
[paste content of agent-framework/projects/acme-pay/backend/AGENTS.md]
[paste content of agent-framework/core/nfr/AGENTS.md — Sections 1 and 5]
```

**User:**
```
Implement in dependency order:
1. PaymentRepository — minimum code to make integration tests green
2. ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep — make unit tests green
3. CreatePaymentUseCaseImpl — orchestrate steps; make unit tests green
4. PaymentGatewayController — routing only; make unit tests green

For each class, write ONLY enough code to pass its tests.

[paste the failing test file for the class being implemented]
```

---

### Task 6 — Refactor

**User:**
```
Refactor the implementation:
[paste each production class]

Check:
- Naming follows AGENTS.md conventions
- App log entries include all 3 NFR mandatory fields (event_date_time, log_type, level)
- Error messages to client are generic — no stack traces, no internal paths
- Account numbers masked server-side

After each change: run the FULL test suite. All tests must stay green.
```

---

### Task 7 — Code review

**System:**
```
You are a senior Java code reviewer.
[paste content of agent-framework/core/code-review/REVIEW_STANDARD.md]
[paste content of agent-framework/projects/acme-pay/backend/AGENTS.md]
[paste content of agent-framework/core/nfr/AGENTS.md]
```

**User:**
```
Review this code diff for the payment-gateway feature.

Spec reference:
[paste api-specification.md]

Diff:
[paste output of: git diff origin/main...feature/payment-gateway]

Cover all 7 dimensions:
Performance, Code smell, Security, Structure, Spec mapping, Business logic, Test coverage.
```

**API:**
```python
import subprocess

system = "\n\n".join([
    (FRAMEWORK_ROOT / "core/code-review/REVIEW_STANDARD.md").read_text(),
    (FRAMEWORK_ROOT / "projects/acme-pay/backend/AGENTS.md").read_text(),
    (FRAMEWORK_ROOT / "core/nfr/AGENTS.md").read_text(),
])
diff = subprocess.check_output(
    ["git", "diff", "origin/main...feature/payment-gateway"], text=True
)

response = client.chat.completions.create(
    model="gpt-4o", max_tokens=6000,
    messages=[
        {"role": "system", "content": system},
        {"role": "user",   "content": f"Branch: feature/payment-gateway\n\nDiff:\n{diff}"},
    ]
)
save_output(response.choices[0].message.content,
            "output/payment-gateway/review/review-report.md")
```

---

### Task 8 — E2E execution and reporting

**User:**
```
The E2E tests from Task 4c have been run against SIT.

BASE_URL: https://acme-pay-sit.example.com
RESULT_DIR: e2e/test-results/payment-gateway

Report PASS/FAIL per acceptance criterion from user-stories.md.
Include screenshot references and a summary of failures.
```

---

## One-off tasks

### Generate spec from existing code

**API:**
```python
system = "\n\n".join([
    (FRAMEWORK_ROOT / "core/code-to-spec/AGENTS.md").read_text(),
    (FRAMEWORK_ROOT / "core/code-to-spec/GENERATE_API_SPEC.md").read_text(),
    (FRAMEWORK_ROOT / "projects/acme-pay/AGENTS.md").read_text(),
])
controller = Path(
    "src/main/java/com/acme/pay/restapi/paymentgateway/controller/PaymentGatewayController.java"
).read_text()

response = client.chat.completions.create(
    model="gpt-4o", max_tokens=8000,
    messages=[
        {"role": "system", "content": system},
        {"role": "user",   "content": f"HTTP_METHOD: POST\nAPI_PATH: /api/acme-pay/v1/payment/submit\n\nController:\n{controller}"},
    ]
)
save_output(response.choices[0].message.content,
            "output/payment-gateway/technical-spec/api-specification.md")
```

### Record an architecture decision (ADR)

**System:**
```
You are an experienced software architect.
[paste content of agent-framework/core/adr/AGENTS.md]
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
[paste content of agent-framework/projects/acme-pay/adr/INDEX.md]
```

**User:**
```
Use the ADR_TEMPLATE to author an ADR for:
- DECISION_TOPIC: Choice of message broker for payment event publishing
- NEXT_ADR_ID: ADR-PAY-003

List at least two options with honest pros and cons.
```

---

## Context window tips

| Strategy | When to use |
|---|---|
| Summarise source code | Send method signatures only; full body for the target class only |
| Chunk the FSD | Process one section at a time |
| Use `gpt-4o` 128k context | For full-feature FSDs in a single call |
| Split outputs | Generate spec sections in separate calls |
