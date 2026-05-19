# SETUP_GUIDE — OpenAI Codex / ChatGPT Integration

## Overview

OpenAI tools do not auto-read files from disk. The integration pattern is:

1. **Read** the AGENTS.md and prompt file content (via script or manually)
2. **Inject** as the system message (API) or paste at the top of a new chat (ChatGPT UI)
3. **Fill placeholders** with real values before sending
4. **Collect output** and write it to the correct output file

Two modes are covered: **Chat UI** (manual) and **API / Python script** (automated / CI).

---

## Repository Scenarios

### Scenario A — Framework and project in the same repository

The framework is in the same repo. Python scripts resolve `agent-framework/` as a relative path from the project root.

```
your-project/
├── agent-framework/
│   ├── core/
│   └── projects/rems/
├── src/
└── scripts/
    └── run_agent.py          ← FRAMEWORK_ROOT = Path("agent-framework")
```

All script examples use `FRAMEWORK_ROOT = Path("agent-framework")` — no changes needed.

---

### Scenario B — Framework and project in separate repositories

| Option | How | Best For |
|---|---|---|
| **Git submodule** (recommended) | `git submodule add <framework-repo-url> agent-framework` | CI/CD pipelines |
| **Absolute path** | `FRAMEWORK_ROOT = Path("/shared/agent-framework")` | Developer machine |
| **Environment variable** | `FRAMEWORK_ROOT = Path(os.environ["AI_FRAMEWORK_PATH"])` | Multi-developer teams |

**Git submodule setup:**

```bash
git submodule add https://your-gitlab/agent-framework.git agent-framework
git submodule update --init --recursive
```

**Update script constant for Scenario B:**

```python
# Scenario A — same repo
FRAMEWORK_ROOT = Path("agent-framework")

# Scenario B — environment variable (flexible, recommended for teams)
FRAMEWORK_ROOT = Path(os.environ.get("AI_FRAMEWORK_PATH", "agent-framework"))
```

**Keeping the submodule updated:**

```bash
git submodule update --remote agent-framework
git add agent-framework
git commit -m "chore: update agent-framework submodule"
```

---

## Core Python Helper

Save this as `scripts/run_agent.py`. Use it as the base for all module calls.

```python
import os, sys
from openai import OpenAI
from pathlib import Path

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])
FRAMEWORK_ROOT = Path(os.environ.get("AI_FRAMEWORK_PATH", "agent-framework"))

def run_agent(agents_md_path: str, prompt_path: str, user_message: str,
              model: str = "gpt-4o", max_tokens: int = 8000) -> str:
    agents_md    = (FRAMEWORK_ROOT / agents_md_path).read_text()
    prompt_file  = (FRAMEWORK_ROOT / prompt_path).read_text() if prompt_path else ""
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

def fill_prompt(template_path: str, values: dict) -> str:
    text = (FRAMEWORK_ROOT / template_path).read_text()
    for key, value in values.items():
        text = text.replace(f"{{{{{key}}}}}", value)
    return text

def save_output(content: str, out_path: str):
    p = Path(out_path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(content)
    print(f"Written → {p}")
```

---

## Placeholder Filling Helper

```python
def fill_prompt(template_path: str, values: dict) -> str:
    text = (FRAMEWORK_ROOT / template_path).read_text()
    for key, value in values.items():
        text = text.replace(f"{{{{{key}}}}}", value)
    return text
```

---

## Model Selection

| Task | Recommended Model | Why |
|---|---|---|
| Tech spec generation | `gpt-4o` | Long context, structured Markdown |
| Code review | `gpt-4o` or `o3` | Reasoning depth for logic analysis |
| Unit test generation | `gpt-4o-mini` | Fast, cost-effective for repetitive output |
| BA analysis | `gpt-4o` | Needs document comprehension |
| Dependency update config | `gpt-4o-mini` | YAML generation is straightforward |

---

## How to Trigger Each Core Module

> **`core/` vs `projects/rems/`** — Use `projects/rems/*` prompt files for all actual REMS work.
> The `core/` modules are generic templates for building new project adapters.
> REMS has its own prompt files for tech-spec, unit-test, and e2e-test that include REMS-specific rules.

---

### Module 1 — `ba-analysis` (FSD → User Stories)

> Instructions are inline in AGENTS.md — no separate prompt file.

**Chat UI:**

```
System (paste at top of new conversation):
[paste full content of agent-framework/core/ba-analysis/AGENTS.md]

User:
Run the 6 Process Steps against this requirement document.
Project context: REMS — Spring Boot backend, React 18 frontend.

FSD:
[paste FSD content]

Produce: user-stories.md, data-flow.md, glossary.md, open-questions.md
```

**API:**

```python
agents_md = (FRAMEWORK_ROOT / "core/ba-analysis/AGENTS.md").read_text()
fsd       = Path("docs/fsd-block-word.md").read_text()

result = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": agents_md},
        {"role": "user",   "content": f"Project: REMS\nFSD:\n{fsd}\n\nRun Steps 1–6. Produce all 4 output documents."},
    ],
    max_tokens=8000,
)
save_output(result.choices[0].message.content, "output/block-word/ba/analysis.md")
```

---

### Module 2 — `tech-spec` (FSD → Technical Specification)

> **REMS:** Use `projects/rems/tech-spec/REMS_API_TECH_SPEC.md` (or BATCH / DATABASE variant).
> The `core/` router is for non-REMS projects only.

**Chat UI:**

```
System:
[paste content of agent-framework/projects/rems/AGENTS.md]
[paste content of agent-framework/projects/rems/tech-spec/REMS_API_TECH_SPEC.md]

User:
FEATURE_NAME: block-word
HTTP_METHOD: POST
API_PATH: /api/rems-parameterandconfig/v1/block-word/search
CURRENT_DATE: 2026-04-30

FSD:
[paste FSD content]

Generate the full REMS API technical specification section by section.
```

**API:**

```python
agents_md   = (FRAMEWORK_ROOT / "projects/rems/AGENTS.md").read_text()
rems_prompt = (FRAMEWORK_ROOT / "projects/rems/tech-spec/REMS_API_TECH_SPEC.md").read_text()
fsd         = Path("docs/fsd-block-word.md").read_text()

system = f"{agents_md}\n\n{rems_prompt}"
user   = (
    "FEATURE_NAME: block-word\n"
    "HTTP_METHOD: POST\n"
    "API_PATH: /api/rems-parameterandconfig/v1/block-word/search\n"
    "CURRENT_DATE: 2026-04-30\n\n"
    f"FSD:\n{fsd}"
)

result = client.chat.completions.create(
    model="gpt-4o", max_tokens=8000,
    messages=[
        {"role": "system", "content": system},
        {"role": "user",   "content": user},
    ],
)
save_output(result.choices[0].message.content,
            "output/block-word/technical-spec/api-specification.md")
```

---

### Module 3 — `code-to-spec` (Source Code → API Specification)

**Chat UI:**

```
System:
[paste content of agent-framework/core/code-to-spec/AGENTS.md]
[paste content of agent-framework/core/code-to-spec/GENERATE_API_SPEC.md]

User:
HTTP_METHOD: GET
API_PATH: /api/rems-parameterandconfig/v1/block-word/search
SOURCE_ROOT: src/main/java

Controller source:
[paste controller Java source]

Usecase source:
[paste usecase Java source]

Step sources:
[paste each step Java source]

Trace the call chain and generate the API specification document.
```

**API:**

```python
agents_md    = (FRAMEWORK_ROOT / "core/code-to-spec/AGENTS.md").read_text()
prompt_file  = (FRAMEWORK_ROOT / "core/code-to-spec/GENERATE_API_SPEC.md").read_text()
controller   = Path("src/main/java/th/co/scb/rems/restapi/controller/RemsParameterAndConfigController.java").read_text()

user = f"""HTTP_METHOD: GET
API_PATH: /api/rems-parameterandconfig/v1/block-word/search

Controller:
{controller}
"""

result = client.chat.completions.create(
    model="gpt-4o", max_tokens=8000,
    messages=[
        {"role": "system", "content": agents_md + "\n\n" + prompt_file},
        {"role": "user",   "content": user},
    ],
)
save_output(result.choices[0].message.content,
            "output/block-word/technical-spec/api-specification.md")
```

---

### Module 4 — `code-review` (Branch Changes → Review Report)

**Chat UI:**

```
System:
You are a senior Java code reviewer.
[paste content of agent-framework/core/code-review/REVIEW_STANDARD.md]

Architecture context:
[paste content of agent-framework/projects/rems/backend/AGENTS.md]

User:
BRANCH_NAME: feature/block-word-search

Git diff:
[paste output of: git diff origin/main...feature/block-word-search]

Produce a report covering all 7 review dimensions in a Markdown table.
```

**API:**

```python
import subprocess

review_std  = (FRAMEWORK_ROOT / "core/code-review/REVIEW_STANDARD.md").read_text()
backend_ref = (FRAMEWORK_ROOT / "projects/rems/backend/AGENTS.md").read_text()
diff        = subprocess.check_output(
    ["git", "diff", "origin/main...feature/block-word-search"],
    text=True
)

result = client.chat.completions.create(
    model="gpt-4o", max_tokens=6000,
    messages=[
        {"role": "system", "content": review_std + "\n\nArchitecture:\n" + backend_ref},
        {"role": "user",   "content": f"BRANCH: feature/block-word-search\n\nDiff:\n{diff}"},
    ],
)
save_output(result.choices[0].message.content,
            "output/block-word/review/review-report-2026-04-30.md")
```

---

### Module 5 — `developer-coding` (Standards-Guided Code Generation)

> Instructions are inline in AGENTS.md — no separate prompt file.
> Load `projects/rems/backend/AGENTS.md` — it overrides generic rules with REMS-specific ones (`@Autowired`, `JdbcTemplate`, `@PostMapping`, Vavr Try, etc.).

**Chat UI:**

```
System:
You are a Java Spring Boot developer.
[paste content of agent-framework/projects/rems/AGENTS.md]
[paste content of agent-framework/projects/rems/backend/AGENTS.md]

User:
Implement a new POST endpoint. (All REMS endpoints use POST — never GET, PUT, DELETE)
API_PATH: /api/rems-parameterandconfig/v1/block-word/search
HTTP_METHOD: POST
Request fields: keyword (String), pageNo (int), pageSize (int), accessFunction (String)

Generate all layers: Controller method, Usecase interface + impl, Context, Steps, Service, Repository, Entity, Mapper, DTOs.
Follow the Usecase/Step pattern with @Autowired, NamedParameterJdbcTemplate, Vavr Try.
```

**API:**

```python
rems_main    = (FRAMEWORK_ROOT / "projects/rems/AGENTS.md").read_text()
rems_backend = (FRAMEWORK_ROOT / "projects/rems/backend/AGENTS.md").read_text()

result = client.chat.completions.create(
    model="gpt-4o", max_tokens=8000,
    messages=[
        {"role": "system", "content": rems_main + "\n\n" + rems_backend},
        {"role": "user",   "content": (
            "Implement POST /api/rems-parameterandconfig/v1/block-word/search\n"
            "Request fields: keyword, pageNo, pageSize, accessFunction\n"
            "Generate all layers: Controller, Usecase, Context, Steps, Service, Repository, Entity, Mapper, DTOs"
        )},
    ],
)
print(result.choices[0].message.content)
```

---

### Module 6 — `unit-test` (Source → JUnit 5 / Playwright Tests)

**Backend — Chat UI:**

```
System:
You are a Java test engineer generating JUnit 5 unit tests.
[paste content of agent-framework/projects/rems/backend/BE_UNIT_TEST.md]

User:
Generate unit tests for this Step class:
[paste Java source of the Step class]

Target: ≥ 80% line coverage.
Include: happy path, business exception, SQL exception cases.
```

**Backend — API:**

```python
be_prompt = (FRAMEWORK_ROOT / "projects/rems/backend/BE_UNIT_TEST.md").read_text()
step_src  = Path(
    "src/main/java/th/co/scb/rems/restapi/step/blockword/"
    "RemsBlockWordSearchGetBlockWordStep.java"
).read_text()

result = client.chat.completions.create(
    model="gpt-4o", max_tokens=6000,
    messages=[
        {"role": "system", "content": be_prompt},
        {"role": "user",   "content": f"Step class:\n{step_src}\n\nCoverage target ≥ 80%."},
    ],
)
save_output(result.choices[0].message.content,
            "src/test/java/th/co/scb/rems/restapi/step/blockword/"
            "RemsBlockWordSearchGetBlockWordStepTest.java")
```

**Frontend — Chat UI:**

```
System:
You are a frontend test engineer using Playwright with TypeScript.
[paste content of agent-framework/projects/rems/frontend/FE_UNIT_TEST.md]

User:
Generate Playwright tests for this React component:
[paste TSX component source]

BASE_URL: https://rems-sit.se.scb.co.th
AUTH_SESSION_FILE: playwright/.auth/session.json
Cover: search success, empty results, required field validation error.
```

---

### Module 7 — `e2e-test` (Test Cases → Playwright Script)

> **REMS:** Use `projects/rems/e2e-test/REMS_E2E_CONFIG.md` — single prompt with REMS-specific Playwright config, auth, and selector conventions built in.
> The 2-step `core/e2e-test/` process is for non-REMS projects only.

**Chat UI:**

```
System:
[paste content of agent-framework/projects/rems/AGENTS.md]
[paste content of agent-framework/projects/rems/e2e-test/REMS_E2E_CONFIG.md]

User:
FEATURE_NAME: block-word
BASE_URL: https://rems-sit.se.scb.co.th
AUTH_SESSION_FILE: playwright/.auth/session.json

Test cases:
[paste Excel rows as text table]

Generate the Playwright TypeScript E2E test file.
```

**API:**

```python
rems_main  = (FRAMEWORK_ROOT / "projects/rems/AGENTS.md").read_text()
e2e_prompt = (FRAMEWORK_ROOT / "projects/rems/e2e-test/REMS_E2E_CONFIG.md").read_text()
# Extract test case rows from Excel to text/CSV before calling
test_cases = "[TC-001 | Search valid keyword | ...]\n[TC-002 | ...]"

result = client.chat.completions.create(
    model="gpt-4o", max_tokens=8000,
    messages=[
        {"role": "system", "content": rems_main + "\n\n" + e2e_prompt},
        {"role": "user",   "content": (
            "FEATURE_NAME: block-word\n"
            "BASE_URL: https://rems-sit.se.scb.co.th\n"
            "AUTH_SESSION_FILE: playwright/.auth/session.json\n\n"
            f"Test cases:\n{test_cases}\n\n"
            "Generate the Playwright TypeScript E2E test file."
        )},
    ],
)
save_output(result.choices[0].message.content,
            "e2e/tests/block-word-e2e.spec.ts")
```

---

### Module 8 — `dependency-update` (Multi-Repo Maven Library Bump)

> The agent produces a YAML config. The actual update is run via the Python script locally.

**Chat UI:**

```
System:
[paste content of agent-framework/core/dependency-update/AGENTS.md]

User:
Generate the config/update-dependencies.yaml for:
- LIBRARY: spring-boot-starter-parent
- GROUP_ID: org.springframework.boot
- ARTIFACT_ID: spring-boot-starter-parent
- NEW_VERSION: 3.5.10
- TARGET_REPOS: [rems-backend, rems-frontend-bff]
- GIT_TOKEN: env var GIT_TOKEN (do not hardcode)
- RUN_TESTS: true
- SKIP_ITS: true

Show the complete YAML. Also show the shell command to run the update script.
```

**API:**

```python
dep_update_md = (FRAMEWORK_ROOT / "core/dependency-update/AGENTS.md").read_text()

result = client.chat.completions.create(
    model="gpt-4o-mini", max_tokens=2000,
    messages=[
        {"role": "system", "content": dep_update_md},
        {"role": "user",   "content": (
            "Generate config/update-dependencies.yaml for:\n"
            "- spring-boot-starter-parent → 3.5.10\n"
            "- Repos: rems-backend, rems-frontend-bff\n"
            "- GIT_TOKEN via env var\n"
            "- runTests: true, skipITs: true"
        )},
    ],
)
save_output(result.choices[0].message.content, "config/update-dependencies.yaml")
```

---

## Batch Script — Run Multiple Features in One Go

```python
import os, json
from openai import OpenAI
from pathlib import Path

client         = OpenAI(api_key=os.environ["OPENAI_API_KEY"])
FRAMEWORK_ROOT = Path("agent-framework")

features = [
    {"slug": "block-word",   "fsd": "docs/fsd-block-word.md"},
    {"slug": "swift-config", "fsd": "docs/fsd-swift-config.md"},
]

agents_md = (FRAMEWORK_ROOT / "projects/rems/AGENTS.md").read_text()
router    = (FRAMEWORK_ROOT / "core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md").read_text()
system    = agents_md + "\n\n" + router

for feat in features:
    fsd  = Path(feat["fsd"]).read_text()
    resp = client.chat.completions.create(
        model="gpt-4o", max_tokens=8000,
        messages=[
            {"role": "system", "content": system},
            {"role": "user",   "content": f"FEATURE_NAME: {feat['slug']}\nFSD:\n{fsd}"},
        ],
    )
    out = Path(f"output/{feat['slug']}/technical-spec/api-specification.md")
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(resp.choices[0].message.content)
    print(f"Done → {out}")
```

---

## ChatGPT Projects (Persistent Context)

In ChatGPT, create a **Project** for each framework module:

1. Open ChatGPT → **Projects** → **New Project** → name it (e.g., "REMS Tech Spec")
2. Upload `agent-framework/projects/rems/AGENTS.md` and the relevant prompt file as project files
3. The model will reference them in every conversation in that project — no manual pasting needed

Recommended project setup:

| Project Name | Upload Files |
|---|---|
| REMS Tech Spec | `projects/rems/AGENTS.md` + `core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md` |
| REMS Code Review | `core/code-review/REVIEW_STANDARD.md` + `projects/rems/backend/AGENTS.md` |
| REMS Backend Tests | `projects/rems/backend/AGENTS.md` + `projects/rems/backend/BE_UNIT_TEST.md` |
| REMS E2E Tests | `core/e2e-test/AGENTS.md` + `core/e2e-test/GEN_SCRIPT_FROM_TC.md` |

---

## Prompt Length Management

Framework prompts + FSD + source code can exceed 32k tokens. Strategies:

| Strategy | When to Use |
|---|---|
| Chunk the FSD | Process one section at a time; accumulate output across messages |
| Summarise source code | Send method signatures only; include full body for the target class only |
| Use `gpt-4o` 128k context | Fits most single-feature FSDs in one call |
| Split outputs | Generate spec sections separately in multiple API calls |

---

## Structured JSON Output (for Pipeline Processing)

```python
response = client.chat.completions.create(
    model="gpt-4o",
    response_format={"type": "json_object"},
    messages=[
        {"role": "system", "content": "Return the spec as JSON with keys: overview, endpoints, validation, errors, diagrams"},
        {"role": "user",   "content": user_message},
    ],
)
spec = json.loads(response.choices[0].message.content)
```
