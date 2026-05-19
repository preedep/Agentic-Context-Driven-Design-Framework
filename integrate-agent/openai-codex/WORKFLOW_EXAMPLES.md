# WORKFLOW_EXAMPLES — OpenAI Codex / ChatGPT Integration

Two formats per example: **Chat UI** (paste into ChatGPT) and **API** (Python snippet).

---

## 1. Generate API Technical Spec

> **REMS:** Use `projects/rems/tech-spec/REMS_API_TECH_SPEC.md` — includes REMS-specific rules (Vavr, JdbcTemplate, error codes, Confluence space). The `core/` prompt is for non-REMS projects only.

**Chat UI — system block (paste first):**
```
[paste content of agent-framework/projects/rems/AGENTS.md]
[paste content of agent-framework/projects/rems/tech-spec/REMS_API_TECH_SPEC.md]
```

**Chat UI — follow-up:**
```
FEATURE_NAME: block-word
HTTP_METHOD: POST
API_PATH: /api/rems-parameterandconfig/v1/block-word/search
CURRENT_DATE: 2026-04-30

FSD: [paste FSD content]

Generate the full REMS API technical specification:
1. Overview & scope
2. API endpoint definition (request/response fields table)
3. Validation rules
4. Sequence diagram (PlantUML)
5. Error codes
6. Database queries (Azure SQL, PascalCase columns)
```

**API call:**
```python
agents_md   = Path("agent-framework/projects/rems/AGENTS.md").read_text()
rems_prompt = Path("agent-framework/projects/rems/tech-spec/REMS_API_TECH_SPEC.md").read_text()
fsd         = Path("docs/fsd-block-word.md").read_text()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": agents_md + "\n\n" + rems_prompt},
        {"role": "user",   "content": (
            "FEATURE_NAME: block-word\n"
            "HTTP_METHOD: POST\n"
            "API_PATH: /api/rems-parameterandconfig/v1/block-word/search\n"
            f"FSD:\n{fsd}"
        )},
    ]
)
```

---

## 2. Code Review

**Chat UI — system block:**
```
You are a senior Java code reviewer. Follow this review standard:
[paste content of agent-framework/core/code-review/REVIEW_STANDARD.md]

Architecture context:
[paste content of agent-framework/projects/rems/backend/AGENTS.md]
```

**Chat UI — follow-up:**
```
Review the following code diff for the block-word search feature:
[paste git diff output]

Produce a report covering all 7 dimensions in a Markdown table.
```

---

## 3. Backend Unit Test Generation

**Chat UI — system block:**
```
You are a Java test engineer generating JUnit 5 tests.
[paste content of agent-framework/projects/rems/backend/BE_UNIT_TEST.md]
```

**Chat UI — follow-up:**
```
Generate unit tests for this Step class:
[paste Java source of the Step class]

Target: ≥ 80% line coverage. Include happy path, business exception, and SQL exception cases.
```

---

## 4. Frontend Test Generation

**Chat UI — system block:**
```
You are a frontend test engineer using Playwright with TypeScript.
[paste content of agent-framework/projects/rems/frontend/FE_UNIT_TEST.md]
```

**Chat UI — follow-up:**
```
Generate Playwright tests for this React component:
[paste TSX component source]

Cover: search success, empty results, validation error on required field.
```

---

## 5. Batch Script — Generate Specs for Multiple Features

```python
import os, json
from openai import OpenAI
from pathlib import Path

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])

FRAMEWORK_ROOT = Path("agent-framework")
features = [
    {"slug": "block-word",   "fsd": "docs/fsd-block-word.md"},
    {"slug": "swift-config", "fsd": "docs/fsd-swift-config.md"},
]

agents_md   = (FRAMEWORK_ROOT / "projects/rems/AGENTS.md").read_text()
rems_prompt = (FRAMEWORK_ROOT / "projects/rems/tech-spec/REMS_API_TECH_SPEC.md").read_text()
system      = agents_md + "\n\n" + rems_prompt

for feat in features:
    fsd = Path(feat["fsd"]).read_text()
    resp = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system},
            {"role": "user",   "content": f"Feature: {feat['slug']}\nFSD:\n{fsd}"},
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

**For very long FSDs:** split by section and make multiple API calls. Combine outputs afterward.

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
spec = json.loads(response.choices[0].message.content)
```

**Track token usage per prompt:**
```python
usage = response.usage
print(f"Tokens: {usage.prompt_tokens} in / {usage.completion_tokens} out")
```
