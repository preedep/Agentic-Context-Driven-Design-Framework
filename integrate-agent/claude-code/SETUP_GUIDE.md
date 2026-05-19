# SETUP_GUIDE — Claude Code Integration

## Overview

Claude Code reads `CLAUDE.md` at startup and uses it as persistent context for the entire session. The setup wires the framework's AGENTS.md files into that context so Claude Code knows the module map without being told each time. Use `@file` to reference any file directly in a prompt — Claude Code reads and injects the full content automatically.

---

## Repository Scenarios

### Scenario A — Framework and project in the same repository

The framework lives inside the project repo. `CLAUDE.md` references `agent-framework/` by relative path — no extra configuration needed.

```
your-project/
├── CLAUDE.md                        ← references agent-framework/ by relative path
├── agent-framework/
│   ├── core/
│   ├── projects/acme-pay/
│   └── integrate-agent/
└── src/
```

Skip to **Step 1** — the path in every example is `agent-framework/...`.

---

### Scenario B — Framework and project in separate repositories

The project code lives in its own repo. Claude Code only auto-loads `CLAUDE.md` from the working directory — it cannot read outside it by default.

| Option | How | Best For |
|---|---|---|
| **Git submodule** (recommended) | `git submodule add <framework-repo-url> agent-framework` | Teams — always in sync |
| **Absolute path** | Reference `/Users/team/agent-framework/` in CLAUDE.md | Solo developer on one machine |
| **Copy relevant folders** | Copy `projects/<name>/` + needed `core/` into project repo | Air-gapped or no submodule support |

**Git submodule setup:**

```bash
git submodule add https://your-gitlab/agent-framework.git agent-framework
git submodule update --init --recursive
```

**Keeping the submodule updated:**

```bash
git submodule update --remote agent-framework
git add agent-framework
git commit -m "chore: update agent-framework submodule"
```

---

## Step 1 — CLAUDE.md at Repo Root

Add this block to the `CLAUDE.md` at your project root:

```markdown
## AI Framework

This project uses the Multi-Agent AI Automation Framework in `agent-framework/`.

### How to use an agent
1. Read the module's AGENTS.md for required inputs and prompt file names.
2. Invoke the prompt file with @file, filling all {{PLACEHOLDER}} variables.
3. Validate output against the quality checklist inside the prompt.

### Module map
| Task | Entry point |
|---|---|
| Business analysis (FSD → user stories) | `agent-framework/core/ba-analysis/AGENTS.md` |
| Generate API/Batch/DB tech spec        | `agent-framework/core/tech-spec/AGENTS.md` |
| Code review                            | `agent-framework/core/code-review/AGENTS.md` |
| Generate spec from source code         | `agent-framework/core/code-to-spec/AGENTS.md` |
| Java developer coding standards             | `agent-framework/core/java-developer-coding/AGENTS.md` |
| Unit test generation                   | `agent-framework/core/unit-test/AGENTS.md` |
| E2E test / Playwright                  | `agent-framework/core/e2e-test/AGENTS.md` |
| Dependency update (multi-repo)         | `agent-framework/core/dependency-update/AGENTS.md` |
| Project context (all tasks)            | `agent-framework/projects/acme-pay/AGENTS.md` |
```

---

## Step 2 — Permissions (settings.json)

Pre-approve common paths to avoid permission prompts during a session.

Add to `.claude/settings.json` (project-level):

```json
{
  "permissions": {
    "allow": [
      "Read(agent-framework/**)",
      "Write(agent-framework/projects/acme-pay/**)",
      "Write(output/**)"
    ]
  }
}
```

Or approve globally in `~/.claude/settings.json` if the framework is shared across projects.

---

## Step 3 — Verify Setup

Start Claude Code from the project root and run:

```
What agent modules are available in this project's AI framework?
```

Claude Code should enumerate the modules from `CLAUDE.md` without you referencing any file manually.

```bash
cd /path/to/your-project
claude
```

---

## How to Trigger Each Core Module

The standard loading order for any project task:

```
1. @agent-framework/projects/<name>/AGENTS.md              ← project architecture rules (always first)
2. @agent-framework/projects/<name>/<domain>/AGENTS.md     ← backend or frontend rules
3. @agent-framework/core/<module>/<PROMPT>.md              ← core prompt
```

> Always load the project AGENTS.md first — it provides the package root, error code prefix, API base path, and naming conventions that every prompt depends on.

---

### Module 1 — `ba-analysis` (FSD → User Stories)

> Instructions are inline in AGENTS.md — no separate prompt file.

```
Read @agent-framework/core/ba-analysis/AGENTS.md.

Follow the Process Steps (1–6) with:
- Document: @projects/acme-pay/fsd/payment-gateway-fsd.md
- Project context: acme-pay, Spring Boot backend, React 18 frontend

Produce: user-stories.md, data-flow.md, glossary.md, open-questions.md
Save all four files to output/payment-gateway/ba/
```

---

### Module 2 — `tech-spec` (FSD → Technical Specification)

```
Read @agent-framework/projects/acme-pay/AGENTS.md.
Read @agent-framework/core/nfr/AGENTS.md.
Read @agent-framework/core/tech-stack/AGENTS.md.

Run @agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md with:
- FSD: @projects/acme-pay/fsd/payment-gateway-fsd.md
- FEATURE_SLUG: payment-gateway
- CURRENT_DATE: {{TODAY}}

Generate the full technical specification.
Write output to output/payment-gateway/technical-spec/
```

---

### Module 3 — `code-to-spec` (Source Code → API Specification)

```
Read @agent-framework/core/code-to-spec/AGENTS.md.

Run @agent-framework/core/code-to-spec/GENERATE_API_SPEC.md with:
- HTTP_METHOD: POST
- API_PATH: /api/acme-pay/v1/payment/submit
- SOURCE_ROOT: src/main/java

Trace the controller → usecase → steps and generate the API specification document.
Write output to output/payment-gateway/technical-spec/api-specification.md
```

---

### Module 4 — `code-review` (Branch → Review Report)

```
Read @agent-framework/core/code-review/AGENTS.md.

Run @agent-framework/core/code-review/REVIEW_STANDARD.md with:
- BRANCH_NAME: feature/payment-gateway
- SPEC_FILE: @output/payment-gateway/technical-spec/api-specification.md
- AGENTS_REF: @agent-framework/projects/acme-pay/backend/AGENTS.md

Perform all 7 review dimensions and write the review report to
output/payment-gateway/review/review-report-{{TIMESTAMP}}.md
```

---

### Module 5 — `java-developer-coding` (Standards-Guided Code Generation)

> Instructions are inline in AGENTS.md — no separate prompt file.
> Load `projects/acme-pay/backend/AGENTS.md` first — it defines the Usecase/Step pattern, `@Autowired`, `JdbcTemplate`, and Vavr Try conventions.

```
Read @agent-framework/projects/acme-pay/AGENTS.md.
Read @agent-framework/projects/acme-pay/backend/AGENTS.md.

Implement a new POST endpoint:
- API_PATH: /api/acme-pay/v1/payment/submit
- HTTP_METHOD: POST
- Feature: submit outbound payment transaction with validation and audit logging

Generate all layers: Controller method, Usecase interface + impl, Context, Steps, Service, Repository, Entity, Mapper, DTOs.
Place files in the correct package path under src/main/java/
```

---

### Module 6 — `unit-test` (Source → JUnit 5 Tests)

```
Read @agent-framework/projects/acme-pay/AGENTS.md.
Read @agent-framework/projects/acme-pay/backend/AGENTS.md.
Read @output/payment-gateway/technical-spec/api-specification.md.
Read @output/payment-gateway/technical-spec/validation-rules.md.
Read @output/payment-gateway/technical-spec/error-codes.md.

Generate JUnit 5 test stubs for:
- Controller: PaymentGatewayController
- UseCase Impl: CreatePaymentUseCaseImpl
- Steps: ValidatePaymentStep, SavePaymentStep

Rules:
- Tests must COMPILE but FAIL (production classes do not exist yet)
- @ExtendWith(MockitoExtension.class) only — no JUnit 4
- Never mock the Context object — always instantiate with new
- Every test maps to a spec requirement — add traceability comment at the top

Write test files to: src/test/java/com/acme/pay/restapi/paymentgateway/
```

---

### Module 7 — `e2e-test` (Test Cases → Playwright Script)

```
Read @agent-framework/projects/acme-pay/AGENTS.md.
Read @agent-framework/projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md.
Read @output/payment-gateway/ba/user-stories.md.

Generate Playwright TypeScript E2E tests for:
- BASE_URL: https://acme-pay-sit.example.com
- AUTH_SESSION_FILE: playwright/.auth/session.json
- FEATURE_NAME: payment-gateway

Cover all acceptance criteria from user-stories.md.
Write to: e2e/tests/payment-gateway.spec.ts
```

---

### Module 8 — `dependency-update` (Multi-Repo Maven Library Bump)

> Process is inline in AGENTS.md. Executed by a Python script.

```
Read @agent-framework/core/dependency-update/AGENTS.md.

Help me configure config/update-dependencies.yaml for:
- LIBRARY: spring-boot-starter-parent
- NEW_VERSION: 3.5.10
- TARGET_REPOS: [acme-pay-backend, acme-pay-bff]
- GIT_TOKEN: (set as env var GIT_TOKEN — do not hardcode)

Show the complete YAML config and the command to run the update script.
```

After the YAML is confirmed, run the script:

```bash
export GIT_TOKEN=your_personal_access_token
python update_dependencies.py
```

---

## Tips

**Reference multiple files in one message:**

```
Read @agent-framework/projects/acme-pay/AGENTS.md and @projects/acme-pay/fsd/payment-gateway-fsd.md
then run @agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md.
```

**Tell Claude Code where to write output:**

```
Write the output to output/payment-gateway/technical-spec/ using the UPPER_SNAKE_CASE.md naming convention.
```

**Resume a session mid-task:**

```
Continue from where we left off — we were generating the API spec for payment-gateway.
The controller analysis is done. Now analyze the usecase and steps.
```

**Apply the quality checklist after generation:**

```
Apply the quality checklist from @agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md
to the output you just produced. List any items that fail.
```

**CI/CD mode (`claude -p`):**

```bash
claude -p "Read @agent-framework/core/code-review/AGENTS.md and \
@agent-framework/core/code-review/REVIEW_STANDARD.md. \
Review branch feature/payment-gateway against \
@output/payment-gateway/technical-spec/api-specification.md"
```

---

## Updating Framework Content

When you add or update prompt files in `agent-framework/`, no Claude Code restart is needed — it reads files fresh on each `@file` reference. Update `CLAUDE.md`'s module map table if you add a new core module.
