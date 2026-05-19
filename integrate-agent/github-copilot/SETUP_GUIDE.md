# SETUP_GUIDE — GitHub Copilot Integration

## Overview

GitHub Copilot Chat picks up repository-level instructions from `.github/copilot-instructions.md`. This file acts like Claude Code's `CLAUDE.md` — it is injected into every Copilot Chat session automatically. Use `#file:` to attach any framework file as explicit context in a chat message.

---

## Repository Scenarios

### Scenario A — Framework and project in the same repository

The framework lives inside the project repo. `copilot-instructions.md` references `agent-framework/` by relative path and VS Code indexes everything in one workspace automatically.

```
your-project/
├── .github/
│   └── copilot-instructions.md      ← references agent-framework/ by relative path
├── agent-framework/
│   ├── core/
│   ├── projects/rems/
│   └── integrate-agent/
└── src/
```

Skip to **Step 1**.

---

### Scenario B — Framework and project in separate repositories

Copilot only indexes files inside the VS Code workspace. Add the framework via one of these options:

| Option | How | Best For |
|---|---|---|
| **Git submodule** (recommended) | `git submodule add <framework-repo-url> agent-framework` | Teams — fully indexed by `@workspace` |
| **Multi-root workspace** | Add framework folder via `.code-workspace` file | Framework in a sibling folder |
| **Copy relevant folders** | Copy `projects/<name>/` + needed `core/` into repo | Air-gapped or no submodule support |

**Git submodule setup:**

```bash
git submodule add https://your-gitlab/agent-framework.git agent-framework
git submodule update --init --recursive
```

**Multi-root workspace setup (no submodule):**

Create `project.code-workspace` at a parent folder level:

```json
{
  "folders": [
    { "path": "rems-backend",    "name": "REMS Backend" },
    { "path": "agent-framework", "name": "AI Framework" }
  ]
}
```

Open with: `code project.code-workspace`

**Keeping the submodule updated:**

```bash
git submodule update --remote agent-framework
git add agent-framework
git commit -m "chore: update agent-framework submodule"
```

---

## Step 1 — Create `.github/copilot-instructions.md`

Place this file at your project root. It is automatically injected into every Copilot Chat session.

```markdown
# Copilot Instructions

This project uses the Multi-Agent AI Automation Framework in `agent-framework/`.

## How to use the framework
1. When asked to perform a structured task, first read the relevant AGENTS.md using `#file:`.
2. Follow the inputs listed in the AGENTS.md and invoke the prompt file.
3. Validate output against the quality checklist inside the prompt.

## Module map
| Task | Entry AGENTS.md |
|---|---|
| Business analysis (FSD → user stories) | `agent-framework/core/ba-analysis/AGENTS.md` |
| Generate API/Batch/DB tech spec        | `agent-framework/core/tech-spec/AGENTS.md` |
| Code review                            | `agent-framework/core/code-review/AGENTS.md` |
| Generate spec from source code         | `agent-framework/core/code-to-spec/AGENTS.md` |
| Developer coding standards             | `agent-framework/core/developer-coding/AGENTS.md` |
| Unit test generation                   | `agent-framework/core/unit-test/AGENTS.md` |
| E2E test / Playwright                  | `agent-framework/core/e2e-test/AGENTS.md` |
| Dependency update (multi-repo)         | `agent-framework/core/dependency-update/AGENTS.md` |
| REMS all tasks                         | `agent-framework/projects/rems/AGENTS.md` |

## Rules
- Always read AGENTS.md before starting a task — it defines architecture rules that override your defaults.
- For REMS: read `agent-framework/projects/rems/AGENTS.md` before any backend or frontend task.
- Use {{PLACEHOLDER}} variables exactly as documented in each AGENTS.md.
```

---

## Step 2 — Open Copilot Chat

- **VS Code:** `⌃⌘I` (Mac) or `Ctrl+Alt+I` (Windows/Linux)
- **JetBrains:** `⌥⇧G`

Attach files with `#file:path/to/file` in the chat input. Drag files from the Explorer into the chat for quick attachment.

---

## Step 3 — Use `@workspace` for Discovery

```
@workspace What agent modules are available for REMS backend tasks?
```

```
@workspace Which prompt file should I use to generate a Playwright E2E test for the block-word search page?
```

---

## Step 4 — Use Copilot Edits for Multi-File Output

For tasks that produce multiple files (e.g., a tech spec with 5 sections):

1. Open **Copilot Edits** panel: VS Code `⇧⌘I` / JetBrains `⌥⇧G`
2. Drag the prompt file and relevant source files into the Edits context
3. Describe the task — Copilot Edits will propose file changes to apply or reject

---

## How to Trigger Each Core Module

The standard loading order for **REMS tasks** — always attach AGENTS.md first, then the prompt file:

```
#file:agent-framework/projects/rems/AGENTS.md              ← REMS rules (always first)
#file:agent-framework/projects/rems/<domain>/AGENTS.md     ← backend or frontend rules
#file:agent-framework/projects/rems/<task-prompt>.md       ← REMS-specific prompt (preferred)
  OR #file:agent-framework/core/<module>/<PROMPT>.md       ← core prompt (when no REMS version exists)
```

> **`core/` vs `projects/rems/`** — Use `projects/rems/*` prompt files for all actual REMS work.
> The `core/` modules are generic templates for building new project adapters.
> REMS has its own prompt files for tech-spec, unit-test, and e2e-test that include REMS-specific rules.

---

### Module 1 — `ba-analysis` (FSD → User Stories)

> Instructions are inline in AGENTS.md — no separate prompt file.

```
#file:agent-framework/core/ba-analysis/AGENTS.md
#file:docs/fsd-block-word.pdf

Follow the 6 Process Steps defined in AGENTS.md against this requirement document.
Project context: REMS — Spring Boot backend, React 18 frontend.

Produce:
1. user-stories.md — numbered user stories in As a / I want / So that format
2. data-flow.md — PlantUML sequence diagram
3. glossary.md — domain terms table
4. open-questions.md — ambiguities and risk flags
```

---

### Module 2 — `tech-spec` (FSD → Technical Specification)

> **REMS:** Use `projects/rems/tech-spec/REMS_API_TECH_SPEC.md` (or BATCH / DATABASE variant).
> The `core/` router is for non-REMS projects only.

```
#file:agent-framework/projects/rems/AGENTS.md
#file:agent-framework/projects/rems/tech-spec/REMS_API_TECH_SPEC.md
#file:docs/fsd-block-word.pdf

Run REMS_API_TECH_SPEC with:
- FEATURE_NAME: block-word
- HTTP_METHOD: POST
- API_PATH: /api/rems-parameterandconfig/v1/block-word/search
- CURRENT_DATE: 2026-04-30

Generate the full REMS API technical specification in Confluence-ready Markdown, section by section.
```

---

### Module 3 — `code-to-spec` (Source Code → API Specification)

```
#file:agent-framework/core/code-to-spec/AGENTS.md
#file:agent-framework/core/code-to-spec/GENERATE_API_SPEC.md
#file:src/main/java/th/co/scb/rems/restapi/controller/RemsParameterAndConfigController.java

Run GENERATE_API_SPEC with:
- HTTP_METHOD: GET
- API_PATH: /api/rems-parameterandconfig/v1/block-word/search
- SOURCE_ROOT: src/main/java

Trace controller → usecase → steps and generate the full API specification document.
```

---

### Module 4 — `code-review` (Branch Changes → Review Report)

```
#file:agent-framework/core/code-review/AGENTS.md
#file:agent-framework/core/code-review/REVIEW_STANDARD.md
#file:agent-framework/projects/rems/backend/AGENTS.md

Review the current branch changes for the block-word search feature.
BRANCH_NAME: feature/block-word-search
SPEC_FILE: [attach #file:output/block-word/technical-spec/api-specification.md if available]

Apply the 7-dimension review standard:
1. Performance  2. Code smell  3. Structure compliance
4. Spec mapping  5. Business logic  6. Error handling  7. Test coverage

Produce a Markdown table review report.
```

---

### Module 5 — `developer-coding` (Standards-Guided Code Generation)

> Instructions are inline in AGENTS.md — no separate prompt file.
> Load `projects/rems/backend/AGENTS.md` — it overrides generic rules with REMS-specific ones (`@Autowired`, `JdbcTemplate`, `@PostMapping`, Vavr Try, etc.).

```
#file:agent-framework/projects/rems/AGENTS.md
#file:agent-framework/projects/rems/backend/AGENTS.md
#file:src/main/java/th/co/scb/rems/restapi/parameterandconfig/usecase/systemconfig/RemsSystemConfigSearchUsecaseImpl.java

Implement a new POST endpoint following the REMS Usecase/Step architecture.

Feature: Block Word Search
API_PATH: /api/rems-parameterandconfig/v1/block-word/search
HTTP_METHOD: POST (all REMS endpoints are POST)
Request fields: keyword, pageNo, pageSize, accessFunction

Generate all layers: Controller method, Usecase interface + impl, Context, Steps, Service, Repository, Entity, Mapper, DTOs.
Mirror the package structure of the attached usecase file.
```

---

### Module 6 — `unit-test` (Source → JUnit 5 / Playwright Tests)

**Backend (JUnit 5):**

```
#file:agent-framework/projects/rems/backend/AGENTS.md
#file:agent-framework/projects/rems/backend/BE_UNIT_TEST.md
#file:src/main/java/th/co/scb/rems/restapi/usecase/blockword/RemsBlockWordSearchUsecaseImpl.java

Run BE_UNIT_TEST for the usecase class above.
Generate JUnit 5 tests covering:
- Happy path — full pipeline executes, response not null
- User step throws exception
- Feature step throws exception
Target coverage ≥ 80%.
```

**Frontend (Playwright):**

```
#file:agent-framework/projects/rems/frontend/AGENTS.md
#file:agent-framework/projects/rems/frontend/FE_UNIT_TEST.md
#file:src/features/block-word/BlockWordSearchPage.tsx

Run FE_UNIT_TEST for BlockWordSearchPage.
BASE_URL: https://rems-sit.se.scb.co.th
AUTH_SESSION_FILE: playwright/.auth/session.json

Generate Playwright TypeScript tests covering:
1. Search with valid inputs → results table shown
2. Search returns no results → empty state shown
3. Submit with empty required field → validation error shown
```

---

### Module 7 — `e2e-test` (Test Cases → Playwright Script)

> **REMS:** Use `projects/rems/e2e-test/REMS_E2E_CONFIG.md` — single prompt with REMS-specific Playwright config, auth, and selector conventions built in.
> The 2-step `core/e2e-test/` process is for non-REMS projects only.

```
#file:agent-framework/projects/rems/AGENTS.md
#file:agent-framework/projects/rems/e2e-test/REMS_E2E_CONFIG.md
#file:test-cases/block-word-test-cases.xlsx

Generate REMS E2E Playwright scripts with:
- BASE_URL: https://rems-sit.se.scb.co.th
- AUTH_SESSION_FILE: playwright/.auth/session.json
- FEATURE_NAME: block-word

Output file: e2e/tests/block-word-e2e.spec.ts
```

---

### Module 8 — `dependency-update` (Multi-Repo Maven Library Bump)

> Process is defined inline in AGENTS.md. Output is a YAML config + Python script run.

```
#file:agent-framework/core/dependency-update/AGENTS.md

Help me write the config/update-dependencies.yaml for:
- LIBRARY: spring-boot-starter-parent
- GROUP_ID: org.springframework.boot
- ARTIFACT_ID: spring-boot-starter-parent
- NEW_VERSION: 3.5.10
- TARGET_REPOS: [rems-backend, rems-frontend-bff]
- GIT_TOKEN: env var GIT_TOKEN
- RUN_TESTS: true

Show the complete YAML and the command to run the Python update script.
```

---

## Tips

**Attach multiple files in one message:**

Drag files from the VS Code Explorer into the Copilot Chat input. Or type `#file:` for each:

```
#file:agent-framework/projects/rems/AGENTS.md #file:agent-framework/core/tech-spec/AGENTS.md #file:docs/fsd-block-word.pdf
```

**Find relevant source files first:**

```
@workspace Which files implement the block-word search usecase step?
```

Then attach those files with `#file:` in your follow-up prompt.

**Iterative refinement:**

```
The sequence diagram in the spec is missing the error path. Add a Vavr Try failure
branch showing the @ControllerAdvice handler response.
```

**Apply Copilot Edits to save output:**

Switch to Copilot Edits (`⇧⌘I`), paste the generated spec, and Copilot will propose creating the output file — click Apply All.

---

## Limitations vs Claude Code

| Capability | Copilot Chat | Claude Code |
|---|---|---|
| Auto-reads files | ❌ Manual `#file:` per message | ✅ Reads automatically via `@file` |
| Multi-file agentic edits | ⚠️ Copilot Edits (propose/apply) | ✅ Writes directly without confirmation |
| Hooks / automation | ❌ Not supported | ✅ `hooks` in settings.json |
| Persistent session context | ⚠️ Chat history only | ✅ CLAUDE.md loaded every session |
| CI/CD invocation | ❌ Editor only | ✅ `claude -p` headless CLI mode |
