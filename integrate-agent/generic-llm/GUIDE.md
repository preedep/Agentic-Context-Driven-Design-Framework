# Any LLM — Getting Started Guide

> **Before you begin:** Complete [QUICKSTART.md](../../QUICKSTART.md) first — copy the example project and fill your placeholder values. Come back here when that's done.

---

## What is this guide for?

This guide works with **any LLM** — ChatGPT, Claude.ai, Gemini, Ollama, LM Studio, or any API-compatible model. No tool-specific features required.

The pattern is always the same:

```
1. Build a context block — paste AGENTS.md + prompt file into the chat
2. Fill placeholders     — replace {{PLACEHOLDER}} with real values
3. Send and save output  — copy result to the correct output file
```

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

**Alternative: clone alongside**

```
parent/
├── your-project/       ← your project
└── agent-framework/    ← this framework
```

**Air-gapped: copy only what you need**

Copy `projects/<name>/` + the specific `core/` modules you use into your project repo.

---

### Step 2 — Save the shell helper (optional but recommended)

Save as `run-prompt.sh`. Combines two files → clipboard, ready to paste.

```bash
#!/bin/bash
# Usage: ./run-prompt.sh <agents-md-path> <prompt-file-path>
AGENTS="$1"
PROMPT="$2"

{
  echo "=== AGENT CONTEXT ==="
  echo ""
  cat "$AGENTS"
  if [ -n "$PROMPT" ]; then
    echo ""
    echo "=== TASK INSTRUCTIONS ==="
    echo ""
    cat "$PROMPT"
  fi
} | pbcopy   # macOS — use xclip on Linux

echo "Copied to clipboard. Paste into your LLM chat."
```

```bash
chmod +x run-prompt.sh
```

---

### Step 3 — Verify

Paste the content of `agent-framework/projects/acme-pay/AGENTS.md` into your LLM and ask:

```
List the placeholder values defined for this project.
```

The model should return the placeholder table from the file.

---

## Part 2 — Running Tasks

### How to use the blocks below

Each task has a **Context block** and a **User message**.

- Paste the Context block at the top of a new conversation (or as the system message if your tool supports it)
- Paste the User message as your first prompt
- Replace all `[paste content of ...]` with the actual file content
- Replace `{{PLACEHOLDER}}` values with your real values

Replace `acme-pay` with your own project folder name.

---

### Task 1 — Write an FSD

**Context block:**
```
=== AGENT CONTEXT ===
[paste content of agent-framework/core/fsd/AGENTS.md]

=== PROJECT CONTEXT ===
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
```

**User message:**
```
Use the FSD_TEMPLATE.md structure to write an FSD for:
- FEATURE_NAME: Payment Gateway
- FEATURE_SLUG: payment-gateway
- DESCRIPTION: Allow operators to submit outbound payment transactions with validation and audit logging

Fill all required sections. Flag open questions you cannot answer.
```

**Shell helper:**
```bash
./run-prompt.sh agent-framework/core/fsd/AGENTS.md agent-framework/projects/acme-pay/AGENTS.md
```

---

### Task 2 — Extract user stories from FSD

**Context block:**
```
=== AGENT CONTEXT ===
[paste content of agent-framework/core/ba-analysis/AGENTS.md]

=== PROJECT CONTEXT ===
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
```

**User message:**
```
Analyze this FSD and produce:
1. Numbered user stories (US-001...) in As a / I want / So that format
2. Given/When/Then acceptance criteria — at least 2 scenarios per story
3. Open questions list

FSD:
[paste FSD content]
```

---

### Task 3 — Generate tech spec from FSD

**Context block:**
```
=== PROJECT CONTEXT ===
[paste content of agent-framework/projects/acme-pay/AGENTS.md]

=== NFR STANDARDS ===
[paste content of agent-framework/core/nfr/AGENTS.md]

=== TECH STACK ===
[paste content of agent-framework/core/tech-stack/AGENTS.md]

=== TASK INSTRUCTIONS ===
[paste content of agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md]
```

**User message:**
```
FEATURE_SLUG: payment-gateway

FSD:
[paste FSD content]

Generate the full technical specification:
1. api-specification.md
2. database-schema.md
3. validation-rules.md
4. error-codes.md (prefix: PAY)
5. sequence-diagrams.md (PlantUML)
```

---

### Task 4 — Generate all tests (RED phase — before any code)

**4a — Unit tests**

**Context block:**
```
=== PROJECT CONTEXT ===
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
[paste content of agent-framework/projects/acme-pay/backend/AGENTS.md]

=== TDD RULES ===
[paste Phase 1a section from agent-framework/core/tdd/TDD_CYCLE.md]
```

**User message:**
```
Generate JUnit 5 unit test stubs for:
- PaymentGatewayController
- CreatePaymentUseCaseImpl
- ValidatePaymentStep, SavePaymentStep, PublishPaymentEventStep

Spec reference:
[paste validation-rules.md and error-codes.md]

Rules:
- Tests must COMPILE but FAIL — production classes do not exist yet
- @ExtendWith(MockitoExtension.class) only
- Never mock the Context object — instantiate with new
- Add traceability comment mapping each test to a spec requirement
```

**4b — Integration tests (repository)**

**User message (same session):**
```
Generate @JdbcTest integration test stubs for PaymentRepository.

DB schema:
[paste database-schema.md]

Rules:
- Use real H2 schema (schema.sql mirroring production)
- Never @MockBean the datasource
- Cover all query methods, null handling, empty results, boundary values
- Tests must COMPILE but FAIL
```

**4c — E2E acceptance tests**

**User message (same session):**
```
Generate Playwright TypeScript E2E acceptance tests for payment-gateway.

BASE_URL: https://acme-pay-sit.example.com
AUTH_SESSION_FILE: playwright/.auth/session.json

Acceptance criteria:
[paste user-stories.md]

Cover every Given/When/Then scenario. Tests will FAIL at runtime — the feature does not exist yet.
Output file: e2e/tests/payment-gateway.spec.ts
```

---

### Task 5 — Implement code (GREEN phase)

**Context block:**
```
=== PROJECT CONTEXT ===
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
[paste content of agent-framework/projects/acme-pay/backend/AGENTS.md]

=== NFR (Sections 1 and 5 only) ===
[paste relevant sections from agent-framework/core/nfr/AGENTS.md]
```

**User message:**
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

**User message:**
```
Refactor the implementation:
[paste each production class]

Check:
- Naming follows AGENTS.md conventions
- App log entries include all 3 NFR mandatory fields (event_date_time, log_type, level)
- Error messages to client are generic — no stack traces, no internal paths
- Account numbers masked server-side

After each change: confirm all tests still pass.
```

---

### Task 7 — Code review

**Context block:**
```
=== REVIEW STANDARD ===
[paste content of agent-framework/core/code-review/REVIEW_STANDARD.md]

=== ARCHITECTURE CONTEXT ===
[paste content of agent-framework/projects/acme-pay/backend/AGENTS.md]

=== NFR STANDARDS ===
[paste content of agent-framework/core/nfr/AGENTS.md]
```

**User message:**
```
Review this code diff for payment-gateway.

Spec reference:
[paste api-specification.md]

Diff:
[paste output of: git diff origin/main...feature/payment-gateway]

Cover all 7 dimensions:
Performance, Code smell, Security, Structure, Spec mapping, Business logic, Test coverage.
```

---

### Task 8 — E2E execution and reporting

**User message:**
```
The E2E tests from Task 4c have been run against SIT.

BASE_URL: https://acme-pay-sit.example.com

Acceptance criteria (from user-stories.md):
[paste user-stories.md]

Test results:
[paste test run output]

Report PASS/FAIL per acceptance criterion with a summary of failures.
```

---

## One-off tasks

### Generate spec from existing code

**Context block:**
```
=== AGENT CONTEXT ===
[paste content of agent-framework/core/code-to-spec/AGENTS.md]
[paste content of agent-framework/core/code-to-spec/GENERATE_API_SPEC.md]

=== PROJECT CONTEXT ===
[paste content of agent-framework/projects/acme-pay/AGENTS.md]
```

**User message:**
```
HTTP_METHOD: POST
API_PATH: /api/acme-pay/v1/payment/submit

Controller source:
[paste controller Java file]

Usecase source:
[paste usecase Java file]

Step sources:
[paste each step Java file]

Trace the call chain and generate the API specification.
```

### Record an architecture decision (ADR)

**Context block:**
```
=== ADR MODULE ===
[paste content of agent-framework/core/adr/AGENTS.md]

=== PROJECT CONTEXT ===
[paste content of agent-framework/projects/acme-pay/AGENTS.md]

=== EXISTING ADRs ===
[paste content of agent-framework/projects/acme-pay/adr/INDEX.md]
```

**User message:**
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
| Prioritise prompt file | Include prompt file always; include source code only for the target class |
| Local models (Ollama) | llama3:70b for specs/BA; codestral for code review and tests |

---

## Compare tools

See [TOOL_COMPARISON.md](TOOL_COMPARISON.md) for a side-by-side comparison of Claude Code, Copilot, OpenAI, and generic LLMs.
