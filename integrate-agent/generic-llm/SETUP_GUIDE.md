# SETUP_GUIDE — Generic LLM Integration

## Overview

This guide works with **any LLM** — ChatGPT, Gemini, Claude.ai, Ollama, LM Studio, or any API-compatible model. No tool-specific features required. The pattern is always:

1. **Build a context block** — combine AGENTS.md + prompt file content
2. **Fill placeholders** — replace all `{{PLACEHOLDER}}` with real values
3. **Send and collect output** — copy result to the correct output file

---

## Repository Scenarios

### Scenario A — Framework and project in the same repository

```
your-project/
├── agent-framework/
│   ├── core/
│   └── projects/acme-pay/
└── src/
```

Use paths like: `agent-framework/projects/acme-pay/AGENTS.md`

---

### Scenario B — Framework and project in separate repositories

| Option | How | Best For |
|---|---|---|
| **Git submodule** (recommended) | `git submodule add <framework-repo-url> agent-framework` | Teams — always in sync |
| **Clone alongside** | Clone framework into a sibling folder | Developer machine |
| **Copy relevant folders** | Copy only `projects/<name>/` + needed `core/` modules | Air-gapped |

**Git submodule setup:**

```bash
git submodule add https://your-gitlab/agent-framework.git agent-framework
git submodule update --init --recursive
```

**Clone alongside (no submodule):**

```bash
# Parent folder structure
parent/
├── acme-pay-backend/   ← your project
└── agent-framework/    ← framework (separate clone)
```

Use the shell helper with absolute paths pointing to the sibling folder.

**Keeping the submodule updated:**

```bash
git submodule update --remote agent-framework
git add agent-framework
git commit -m "chore: update agent-framework submodule"
```

---

## The Universal 3-Step Workflow

### Step 1 — Build Your Context Block

Open the relevant AGENTS.md and prompt file. Copy their full content into a single block:

```
=== AGENT CONTEXT ===

[Paste full content of: agent-framework/projects/acme-pay/AGENTS.md]

=== TASK INSTRUCTIONS ===

[Paste full content of: agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md]
```

If the model supports a **system message** (API or advanced chat UI), put the context block there. Otherwise paste it at the very top of the first user message.

---

### Step 2 — Fill Placeholders

Before sending, replace all `{{PLACEHOLDER}}` variables with real values. Use find-and-replace in your text editor.

Common substitutions:

| Placeholder | Example value |
|---|---|
| `{{PROJECT_NAME}}` | `acme-pay` |
| `{{FEATURE_NAME}}` | `payment-gateway` |
| `{{HTTP_METHOD}}` | `POST` |
| `{{API_PATH}}` | `/api/acme-pay/v1/payment/submit` |
| `{{BRANCH_NAME}}` | `feature/payment-gateway` |
| `{{SPEC_FILE}}` | *(paste spec content inline)* |
| `{{FSD_CONTENT}}` | *(paste FSD text inline)* |
| `{{BASE_URL}}` | `https://acme-pay-sit.example.com` |
| `{{CURRENT_DATE}}` | `2026-05-19` |

---

### Step 3 — Send and Collect Output

Send the filled prompt. For long outputs (e.g., a full tech spec), ask the model to continue section by section:

```
Continue with the next section: Validation Rules.
```

Copy the final output and save it:

```
output/{{feature-slug}}/technical-spec/api-specification.md
```

---

## Reusable Shell Helper

Save as `run-prompt.sh`. Combines AGENTS.md + prompt file → clipboard.

```bash
#!/bin/bash
# Usage: ./run-prompt.sh <agents-md-path> <prompt-file-path>
# Combines AGENTS.md + prompt into clipboard for pasting into any LLM chat

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
} | pbcopy   # macOS — replace with xclip on Linux

echo "Context block copied to clipboard. Paste into your LLM chat."
```

```bash
chmod +x run-prompt.sh
```

---

## How to Trigger Each Core Module

> Always load `projects/<name>/AGENTS.md` first — it provides the package root, error code prefix, API base path, and naming conventions that every prompt depends on.

---

### Module 1 — `ba-analysis` (FSD → User Stories)

> Instructions are inline in AGENTS.md — no separate prompt file.

```bash
./run-prompt.sh agent-framework/core/ba-analysis/AGENTS.md ""
# Paste clipboard into LLM, then append your FSD content
```

**Paste into chat:**

```
=== AGENT CONTEXT ===
[paste ba-analysis/AGENTS.md content]

=== INPUTS ===
Project context: acme-pay — Spring Boot backend, React 18 frontend
FSD:
[paste FSD text]

Run Steps 1–6. Produce all 4 output documents:
user-stories.md, data-flow.md, glossary.md, open-questions.md
```

---

### Module 2 — `tech-spec` (FSD → Technical Specification)

```bash
./run-prompt.sh \
  agent-framework/projects/acme-pay/AGENTS.md \
  agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md
```

**Follow-up message:**

```
FEATURE_SLUG: payment-gateway
CURRENT_DATE: 2026-05-19

FSD:
[paste FSD content]

Generate the full technical specification.
```

---

### Module 3 — `code-to-spec` (Source Code → API Specification)

```bash
./run-prompt.sh \
  agent-framework/projects/acme-pay/AGENTS.md \
  agent-framework/core/code-to-spec/GENERATE_API_SPEC.md
```

**Follow-up message:**

```
HTTP_METHOD: POST
API_PATH: /api/acme-pay/v1/payment/submit
SOURCE_ROOT: src/main/java

Controller source:
[paste controller Java file]

Usecase source:
[paste usecase Java file]

Step sources:
[paste each step Java file]

Trace the call chain and generate the API specification document.
```

---

### Module 4 — `code-review` (Branch Changes → Review Report)

```bash
./run-prompt.sh \
  agent-framework/projects/acme-pay/backend/AGENTS.md \
  agent-framework/core/code-review/REVIEW_STANDARD.md
```

**Follow-up message:**

```
BRANCH_NAME: feature/payment-gateway

Git diff:
[paste output of: git diff origin/main...feature/payment-gateway]

Apply all 7 review dimensions and produce a Markdown table report.
```

---

### Module 5 — `java-developer-coding` (Standards-Guided Code Generation)

> Instructions are inline in AGENTS.md — no separate prompt file.
> Load `projects/acme-pay/backend/AGENTS.md` — it defines the Usecase/Step pattern, `@Autowired`, `JdbcTemplate`, and Vavr Try conventions.

```bash
./run-prompt.sh \
  agent-framework/projects/acme-pay/AGENTS.md \
  agent-framework/projects/acme-pay/backend/AGENTS.md
```

**Follow-up message:**

```
Implement a new POST endpoint:
API_PATH: /api/acme-pay/v1/payment/submit
HTTP_METHOD: POST
Request fields: accountNumber (String), amount (BigDecimal), currency (String), reference (String)

Generate all layers: Controller, Usecase, Steps, Service, Repository, DTOs.
Follow the Usecase/Step pattern defined in AGENTS.md.

Existing controller to mirror:
[paste existing controller Java source]
```

---

### Module 6 — `unit-test` (Source → JUnit 5 Tests)

```bash
./run-prompt.sh \
  agent-framework/projects/acme-pay/backend/AGENTS.md \
  ""
```

**Follow-up:**

```
Generate JUnit 5 unit tests for this Step class:
[paste Java source of the Step class]

Coverage target ≥ 80%.
Include: happy path, business exception, SQL exception cases.
```

---

### Module 7 — `e2e-test` (Test Cases → Playwright Script)

```bash
./run-prompt.sh \
  agent-framework/projects/acme-pay/AGENTS.md \
  agent-framework/projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md
```

**Follow-up:**

```
FEATURE_NAME: payment-gateway
BASE_URL: https://acme-pay-sit.example.com
AUTH_SESSION_FILE: playwright/.auth/session.json

Test cases (from Excel):
[paste rows as a table]

Generate the Playwright TypeScript E2E test file.
```

---

### Module 8 — `dependency-update` (Multi-Repo Maven Library Bump)

> Process is inline in AGENTS.md. After the LLM generates the YAML, run the Python script locally.

```bash
./run-prompt.sh \
  agent-framework/core/dependency-update/AGENTS.md ""
```

**Follow-up:**

```
Generate the config/update-dependencies.yaml for:
- LIBRARY: spring-boot-starter-parent
- GROUP_ID: org.springframework.boot
- ARTIFACT_ID: spring-boot-starter-parent
- NEW_VERSION: 3.5.10
- TARGET_REPOS: [acme-pay-backend, acme-pay-bff]
- GIT_TOKEN: env var GIT_TOKEN (do not hardcode)
- RUN_TESTS: true
- SKIP_ITS: true

Show the complete YAML. Show the shell command to run the update script.
```

After copying the YAML output to `config/update-dependencies.yaml`:

```bash
export GIT_TOKEN=your_personal_access_token
python update_dependencies.py
```

---

## Context Window Management

Tech specs, code review, and FSD analysis can consume 20k–60k tokens.

| Strategy | When to Use |
|---|---|
| Summarise source code | Send method signatures + class names; include full body only for the target class |
| Chunk the FSD | Send one FSD section at a time; accumulate output across messages |
| Reference, don't paste | Describe file structure in words instead of pasting all files |
| Use 128k+ context model | For full-feature specs with large codebases (GPT-4o, Claude 3.5+ Sonnet, Gemini 1.5 Pro) |

---

## Context Block Size Guide

| Content | Approximate Tokens |
|---|---|
| `AGENTS.md` (one module) | 500 – 2,000 |
| Prompt file (e.g., `GENERATE_TECH_SPEC_ROUTER.md`) | 3,000 – 8,000 |
| A single Java class (200 lines) | ~1,500 |
| A full FSD (10 pages) | ~8,000 – 15,000 |
| Playwright test Excel (50 rows) | ~3,000 |

---

## Local Model Notes (Ollama, LM Studio)

Local models typically have smaller context windows (8k–32k). Prioritise:

1. The prompt file instructions (required)
2. The project AGENTS.md (recommended)
3. The specific source class (for code tasks)

Skip large FSD content — summarise to bullet points instead.

**Recommended local models:**

| Model | Best for |
|---|---|
| `llama3:70b` / `llama3.1:70b` | Structured Markdown generation (tech spec, BA) |
| `codestral` | Code review and unit test generation |
| `mistral-large` | Balanced context and quality |

**Run locally:**

```bash
ollama run llama3:70b
```

Then paste the context block + filled prompt into the terminal or Ollama web UI.

---

## Tool Comparison Summary

| Feature | Claude Code | GitHub Copilot | ChatGPT / OpenAI | Generic LLM |
|---|---|---|---|---|
| Auto-reads files | ✅ `@file` | ❌ Manual `#file:` | ❌ Paste manually | ❌ Paste manually |
| Persistent session context | ✅ CLAUDE.md | ✅ copilot-instructions.md | ⚠️ ChatGPT Projects | ❌ Rebuild each time |
| Multi-file agentic edits | ✅ Direct writes | ⚠️ Propose/apply | ❌ Copy manually | ❌ Copy manually |
| CI/CD automation | ✅ `claude -p` | ❌ | ✅ Python API | ✅ Any API |
| Local / air-gapped | ❌ | ❌ | ❌ | ✅ Ollama / LM Studio |
| Enterprise approval (common) | ⚠️ Varies | ✅ Common | ⚠️ Varies | ✅ Self-hosted |

Use `TOOL_COMPARISON.md` for the full feature matrix with per-task recommendations.
