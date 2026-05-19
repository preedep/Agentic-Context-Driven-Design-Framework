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
│   ├── projects/rems/
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
| Developer coding standards             | `agent-framework/core/developer-coding/AGENTS.md` |
| Unit test generation                   | `agent-framework/core/unit-test/AGENTS.md` |
| E2E test / Playwright                  | `agent-framework/core/e2e-test/AGENTS.md` |
| Dependency update (multi-repo)         | `agent-framework/core/dependency-update/AGENTS.md` |
| REMS (all tasks)                       | `agent-framework/projects/rems/AGENTS.md` |
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
      "Write(agent-framework/projects/rems/**)",
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

The standard loading order for **REMS tasks**:

```
1. @agent-framework/projects/rems/AGENTS.md              ← REMS architecture rules (always first)
2. @agent-framework/projects/rems/<domain>/AGENTS.md     ← backend or frontend rules
3. @agent-framework/projects/rems/<task-prompt>.md       ← REMS-specific prompt (preferred)
   OR @agent-framework/core/<module>/<PROMPT>.md         ← core prompt (when no REMS version exists)
```

> **`core/` vs `projects/rems/`** — Use `projects/rems/*` prompt files for all actual REMS work.
> The `core/` modules are generic templates for building new project adapters.
> REMS has its own prompt files for tech-spec, unit-test, and e2e-test that include REMS-specific rules.

---

### Module 1 — `ba-analysis` (FSD → User Stories)

> Instructions are inline in AGENTS.md — no separate prompt file.

```
Read @agent-framework/core/ba-analysis/AGENTS.md.

Follow the Process Steps (1–6) with:
- Document: @docs/fsd-block-word.pdf
- Project context: REMS, Spring Boot backend, React 18 frontend

Produce: user-stories.md, data-flow.md, glossary.md, open-questions.md
Save all four files to output/block-word/ba/
```

---

### Module 2 — `tech-spec` (FSD → Technical Specification)

> **REMS:** Use `projects/rems/tech-spec/REMS_API_TECH_SPEC.md` (or BATCH / DATABASE variant).
> The `core/` router is for non-REMS projects that don't have a project-specific prompt yet.

```
Read @agent-framework/projects/rems/AGENTS.md.

Run @agent-framework/projects/rems/tech-spec/REMS_API_TECH_SPEC.md with:
- FSD: @docs/fsd-block-word.pdf
- FEATURE_NAME: block-word
- HTTP_METHOD: POST
- API_PATH: /api/rems-parameterandconfig/v1/block-word/search
- CURRENT_DATE: 2026-04-30

Generate the full REMS API technical specification.
Write output to output/block-word/technical-spec/api-specification.md
```

---

### Module 3 — `code-to-spec` (Source Code → API Specification)

```
Read @agent-framework/core/code-to-spec/AGENTS.md.

Run @agent-framework/core/code-to-spec/GENERATE_API_SPEC.md with:
- HTTP_METHOD: GET
- API_PATH: /api/rems-parameterandconfig/v1/block-word/search
- SOURCE_ROOT: src/main/java

Trace the controller → usecase → steps and generate the API specification document.
Write output to output/block-word/technical-spec/api-specification.md
```

---

### Module 4 — `code-review` (Branch → Review Report)

```
Read @agent-framework/core/code-review/AGENTS.md.

Run @agent-framework/core/code-review/REVIEW_STANDARD.md with:
- BRANCH_NAME: feature/block-word-search
- SPEC_FILE: @output/block-word/technical-spec/api-specification.md
- AGENTS_REF: @agent-framework/projects/rems/backend/AGENTS.md

Perform all 7 review dimensions and write the review report to
output/block-word/review/review-report-2026-04-30.md
```

---

### Module 5 — `developer-coding` (Standards-Guided Code Generation)

> Instructions are inline in AGENTS.md — no separate prompt file.
> Load `projects/rems/backend/AGENTS.md` first — it overrides generic coding rules with REMS-specific ones (`@Autowired`, `JdbcTemplate`, `@PostMapping`, Vavr Try, etc.).

```
Read @agent-framework/projects/rems/AGENTS.md.
Read @agent-framework/projects/rems/backend/AGENTS.md.

Implement a new POST endpoint:
- API_PATH: /api/rems-parameterandconfig/v1/block-word/search
- HTTP_METHOD: POST (all REMS endpoints are POST)
- Feature: search block words by keyword with pagination
- Mirror existing pattern from: @src/main/java/th/co/scb/rems/restapi/parameterandconfig/usecase/systemconfig/

Generate all layers: Controller method, Usecase interface + impl, Context, Steps, Service, Repository, Entity, Mapper, DTOs.
Place files in the correct package path under src/main/java/
```

---

### Module 6 — `unit-test` (Source → JUnit 5 / Playwright Tests)

> Core module defines rules; actual prompt files are in `projects/rems/`.

**Backend (JUnit 5):**

```
Read @agent-framework/projects/rems/backend/AGENTS.md.

Run @agent-framework/projects/rems/backend/BE_UNIT_TEST.md with:
- TARGET: RemsBlockWordSearchGetBlockWordStep
- SOURCE_ROOT: src/main/java/th/co/scb/rems
- TEST_ROOT: src/test/java/th/co/scb/rems

Generate JUnit 5 tests for the Step class.
Coverage target ≥ 80%. Include happy path, business exception, SQL exception cases.
Write output to the correct path under TEST_ROOT.
```

**Frontend (Playwright):**

```
Read @agent-framework/projects/rems/frontend/AGENTS.md.

Run @agent-framework/projects/rems/frontend/FE_UNIT_TEST.md with:
- COMPONENT: BlockWordSearchPage
- COMPONENT_PATH: src/features/block-word/BlockWordSearchPage.tsx
- BASE_URL: https://rems-sit.se.scb.co.th
- AUTH_SESSION_FILE: playwright/.auth/session.json

Generate Playwright TypeScript tests covering:
1. Search with valid inputs → results table shown
2. Search returns no results → empty state shown
3. Submit with empty required field → validation error shown
Write to e2e/tests/block-word.spec.ts
```

---

### Module 7 — `e2e-test` (Test Cases → Playwright Script)

> **REMS:** Use `projects/rems/e2e-test/REMS_E2E_CONFIG.md` — it bundles the REMS-specific Playwright config, auth session, and selector conventions in one prompt.
> The 2-step `core/e2e-test/` process is for non-REMS projects only.

```
Read @agent-framework/projects/rems/AGENTS.md.

Run @agent-framework/projects/rems/e2e-test/REMS_E2E_CONFIG.md with:
- TEST_CASE_FILE: @test-cases/block-word-test-cases.xlsx
- BASE_URL: https://rems-sit.se.scb.co.th
- AUTH_SESSION_FILE: playwright/.auth/session.json
- FEATURE_NAME: block-word

Generate the Playwright TypeScript E2E test file.
Write to e2e/tests/block-word-e2e.spec.ts
```

---

### Module 8 — `dependency-update` (Multi-Repo Maven Library Bump)

> Process is inline in AGENTS.md. Executed by a Python script.

```
Read @agent-framework/core/dependency-update/AGENTS.md.

Help me configure config/update-dependencies.yaml for:
- LIBRARY: spring-boot-starter-parent
- NEW_VERSION: 3.5.10
- TARGET_REPOS: [rems-backend, rems-frontend-bff]
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
Read @agent-framework/projects/rems/AGENTS.md and @docs/fsd-block-word.pdf
then run @agent-framework/projects/rems/tech-spec/REMS_API_TECH_SPEC.md.
```

**Tell Claude Code where to write output:**

```
Write the output to output/block-word/technical-spec/ using the UPPER_SNAKE_CASE.md naming convention.
```

**Resume a session mid-task:**

```
Continue from where we left off — we were generating the API spec for block-word.
The controller analysis is done. Now analyze the usecase and steps.
```

**Apply the quality checklist after generation:**

```
Apply the quality checklist from @agent-framework/projects/rems/tech-spec/REMS_API_TECH_SPEC.md
to the output you just produced. List any items that fail.
```

**CI/CD mode (`claude -p`):**

```bash
claude -p "Read @agent-framework/core/code-review/AGENTS.md and \
@agent-framework/core/code-review/REVIEW_STANDARD.md. \
Review branch feature/block-word-search against \
@output/block-word/technical-spec/api-specification.md"
```

---

## Updating Framework Content

When you add or update prompt files in `agent-framework/`, no Claude Code restart is needed — it reads files fresh on each `@file` reference. Update `CLAUDE.md`'s module map table if you add a new core module.
