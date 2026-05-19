# SETUP_GUIDE — OpenAI / ChatGPT Integration

> **New to the framework?** Complete [QUICKSTART.md](../../QUICKSTART.md) first — copy the example project and fill your placeholder values before setting up the API integration.

## Overview

OpenAI tools do not auto-read files from disk. The integration pattern is:

1. **Read** the AGENTS.md and prompt file content (via script or manually)
2. **Inject** as the system message (API) or paste at the top of a new chat (ChatGPT UI)
3. **Fill placeholders** with real values before sending
4. **Collect output** and save it to the correct output file

Two modes are covered: **Chat UI** (manual) and **API / Python script** (automated / CI).

---

## Step 1 — Add the framework to your project

### Option A — Git submodule (recommended for teams / CI)

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

### Option B — Same repository

```
your-project/
├── agent-framework/     ← this framework
│   ├── core/
│   ├── projects/
│   └── integrate-agent/
├── src/
└── scripts/
    └── run_agent.py     ← FRAMEWORK_ROOT = Path("agent-framework")
```

### Option C — Environment variable (multi-developer teams)

```python
import os
from pathlib import Path
FRAMEWORK_ROOT = Path(os.environ.get("AI_FRAMEWORK_PATH", "agent-framework"))
```

---

## Step 2 — Install the Python helper

Save this as `scripts/run_agent.py`. Use it as the base for all module calls.

```python
import os
from openai import OpenAI
from pathlib import Path

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])
FRAMEWORK_ROOT = Path(os.environ.get("AI_FRAMEWORK_PATH", "agent-framework"))

def run_agent(agents_md_path: str, prompt_path: str, user_message: str,
              model: str = "gpt-4o", max_tokens: int = 8000) -> str:
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

def save_output(content: str, out_path: str):
    p = Path(out_path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(content)
    print(f"Written → {p}")
```

---

## Step 3 — Choose your model

| Task | Recommended model |
|---|---|
| Tech spec generation | `gpt-4o` |
| Code review | `gpt-4o` or `o3` |
| Unit test generation | `gpt-4o-mini` |
| BA analysis | `gpt-4o` |
| Dependency update config | `gpt-4o-mini` |

---

## Step 4 — Verify setup

```python
agents_md = (FRAMEWORK_ROOT / "projects/acme-pay/AGENTS.md").read_text()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": agents_md},
        {"role": "user",   "content": "List the placeholder values defined for this project."},
    ],
)
print(response.choices[0].message.content)
```

The model should return the placeholder table from `projects/acme-pay/AGENTS.md`.

---

## ChatGPT Projects (persistent context — no API needed)

In ChatGPT, create a **Project** per module so files are loaded automatically:

1. Open ChatGPT → **Projects** → **New Project**
2. Upload `agent-framework/projects/<your-project>/AGENTS.md` and the relevant prompt file
3. Every conversation in that project has these files loaded — no pasting needed

Recommended project setup:

| Project name | Upload files |
|---|---|
| Tech Spec | `projects/acme-pay/AGENTS.md` + `core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md` |
| Code Review | `core/code-review/REVIEW_STANDARD.md` + `projects/acme-pay/backend/AGENTS.md` |
| Backend Tests | `projects/acme-pay/backend/AGENTS.md` |
| E2E Tests | `core/e2e-test/AGENTS.md` + `core/e2e-test/GEN_SCRIPT_FROM_TC.md` |

---

## You're ready

See **[WORKFLOW_EXAMPLES.md](WORKFLOW_EXAMPLES.md)** for ready-to-use Chat UI blocks and Python API snippets covering the full TDD lifecycle — FSD → BA Analysis → Tech Spec → Tests → Implementation → Code Review → E2E.

---

## Context window tips

Framework prompts + FSD + source code can consume 20k–60k tokens.

| Strategy | When to use |
|---|---|
| Summarise source code | Send method signatures only; include full body for the target class only |
| Chunk the FSD | Process one section at a time |
| Use `gpt-4o` 128k context | For full-feature FSDs in a single call |
| Split outputs | Generate spec sections in separate API calls |
