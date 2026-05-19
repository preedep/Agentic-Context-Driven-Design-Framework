# SETUP_GUIDE — Generic LLM Integration

> **New to the framework?** Complete [QUICKSTART.md](../../QUICKSTART.md) first — copy the example project and fill your placeholder values before running any prompt.

## Overview

This guide works with **any LLM** — ChatGPT, Gemini, Claude.ai, Ollama, LM Studio, or any API-compatible model. No tool-specific features required. The pattern is always:

1. **Build a context block** — combine AGENTS.md + prompt file content
2. **Fill placeholders** — replace all `{{PLACEHOLDER}}` with real values
3. **Send and collect output** — save result to the correct output file

---

## Step 1 — Add the framework to your project

### Option A — Git submodule (recommended for teams)

```bash
git submodule add https://github.com/preedep/Agentic-Context-Driven-Design-Framework agent-framework
git submodule set-branch --branch main agent-framework
git submodule update --init --recursive
```

**Update later:**
```bash
git submodule update --remote agent-framework
git add agent-framework
git commit -m "chore: update agent-framework submodule"
```

### Option B — Clone alongside (no submodule)

```
parent/
├── your-project/       ← your project
└── agent-framework/    ← this framework (separate clone)
```

### Option C — Copy only what you need

Copy `projects/<name>/` + the specific `core/` modules you use into your project repo. Best for air-gapped environments.

---

## Step 2 — Build your context block

Open the relevant AGENTS.md and prompt file. Combine into a single block:

```
=== AGENT CONTEXT ===

[Paste full content of: agent-framework/projects/acme-pay/AGENTS.md]

=== TASK INSTRUCTIONS ===

[Paste full content of: agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md]
```

If the model supports a **system message** (API or advanced chat UI), put the context block there. Otherwise paste it at the very top of the first user message.

---

## Step 3 — Fill placeholders

Before sending, replace all `{{PLACEHOLDER}}` variables with real values. Use find-and-replace in your text editor.

Common substitutions:

| Placeholder | Example value |
|---|---|
| `{{PROJECT_NAME}}` | `acme-pay` |
| `{{FEATURE_NAME}}` | `payment-gateway` |
| `{{HTTP_METHOD}}` | `POST` |
| `{{API_PATH}}` | `/api/acme-pay/v1/payment/submit` |
| `{{BASE_URL}}` | `https://acme-pay-sit.example.com` |
| `{{CURRENT_DATE}}` | `2026-05-19` |

---

## Step 4 — Shell helper (optional)

Save as `run-prompt.sh`. Combines AGENTS.md + prompt file → clipboard.

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
} | pbcopy   # macOS — replace with xclip on Linux

echo "Copied to clipboard. Paste into your LLM chat."
```

```bash
chmod +x run-prompt.sh
```

**Example:**
```bash
./run-prompt.sh \
  agent-framework/projects/acme-pay/AGENTS.md \
  agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md
```

---

## Step 5 — Verify setup

Paste the content of `agent-framework/projects/acme-pay/AGENTS.md` into your LLM and ask:

```
List the placeholder values defined for this project.
```

The model should return the placeholder table from the file.

---

## You're ready

See **[WORKFLOW_EXAMPLES.md](WORKFLOW_EXAMPLES.md)** for ready-to-use context blocks covering the full TDD lifecycle — FSD → BA Analysis → Tech Spec → Tests → Implementation → Code Review → E2E.

For a comparison of all tools, see **[TOOL_COMPARISON.md](TOOL_COMPARISON.md)**.

---

## Local model notes (Ollama, LM Studio)

Local models typically have 8k–32k context windows. Priority order when space is tight:

1. The prompt file instructions (required)
2. The project AGENTS.md (recommended)
3. The specific source class (for code tasks)

Skip large FSD content — summarise to bullet points instead.

| Model | Best for |
|---|---|
| `llama3:70b` | Structured Markdown generation (tech spec, BA) |
| `codestral` | Code review and unit test generation |
| `mistral-large` | Balanced context and quality |
