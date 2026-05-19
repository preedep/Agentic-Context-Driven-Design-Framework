# WORKFLOW_EXAMPLES — Claude Code Integration

Real, end-to-end workflow examples for each core agent module. Copy the session starter prompt, adjust the `{{PLACEHOLDER}}` values, and paste into a Claude Code session.

---

## 1. Generate API Technical Spec from FSD

**Module:** `projects/rems/tech-spec/` → `REMS_API_TECH_SPEC.md`

> Use `projects/rems/tech-spec/REMS_API_TECH_SPEC.md` for REMS — it includes REMS-specific rules (Vavr, JdbcTemplate, error codes, Confluence space). The `core/` router is for non-REMS projects only.

**Session starter:**
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

**What Claude Code does:**
1. Reads `projects/rems/AGENTS.md` (REMS architecture rules + stack)
2. Reads the REMS_API_TECH_SPEC prompt
3. Reads the FSD file
4. Generates REMS-specific spec with correct error codes, Confluence format, PlantUML
5. Writes output to `output/block-word/technical-spec/`

---

## 2. Generate API Spec from Existing Source Code

**Module:** `core/code-to-spec/` → `GENERATE_API_SPEC.md`

**Session starter:**
```
Read @agent-framework/core/code-to-spec/AGENTS.md.

Run @agent-framework/core/code-to-spec/GENERATE_API_SPEC.md with:
- HTTP_METHOD: GET
- API_PATH: /api/rems-parameterandconfig/v1/block-word/search
- SOURCE_ROOT: src/main/java

Trace the controller → usecase → steps and generate the API specification document.
```

**What Claude Code does:**
1. Reads AGENTS.md for inputs/outputs
2. Reads controller, usecase, step files automatically
3. Generates Confluence-ready spec document

---

## 3. Code Review Against Spec

**Module:** `core/code-review/` → `REVIEW_STANDARD.md`

**Session starter:**
```
Read @agent-framework/core/code-review/AGENTS.md.

Run @agent-framework/core/code-review/REVIEW_STANDARD.md with:
- BRANCH_NAME: feature/block-word-search
- SPEC_FILE: @output/block-word/technical-spec/api-specification.md
- AGENTS_REF: @agent-framework/projects/rems/backend/AGENTS.md

Perform all 7 review dimensions and produce the review report.
```

---

## 4. Generate Backend Unit Tests (REMS)

**Module:** `projects/rems/backend/` → `BE_UNIT_TEST.md`

**Session starter:**
```
Read @agent-framework/projects/rems/backend/AGENTS.md.

Run @agent-framework/projects/rems/backend/BE_UNIT_TEST.md with:
- TARGET: RemsBlockWordSearchGetBlockWordStep
- SOURCE_ROOT: src/main/java/th/co/scb/rems
- TEST_ROOT: src/test/java/th/co/scb/rems

Generate JUnit 5 tests for the Step class. Coverage target ≥ 80%.
```

---

## 5. Generate Frontend Unit Tests (REMS)

**Module:** `projects/rems/frontend/` → `FE_UNIT_TEST.md`

**Session starter:**
```
Read @agent-framework/projects/rems/frontend/AGENTS.md.

Run @agent-framework/projects/rems/frontend/FE_UNIT_TEST.md with:
- COMPONENT: BlockWordSearchPage
- COMPONENT_PATH: src/features/block-word/BlockWordSearchPage.tsx

Generate Playwright E2E tests and Jest unit tests for the component.
```

---

## 6. Generate E2E Playwright Scripts

**Module:** `projects/rems/e2e-test/` → `REMS_E2E_CONFIG.md`

> Use `projects/rems/e2e-test/REMS_E2E_CONFIG.md` for REMS — single prompt with REMS auth, selector conventions, and session timeout handling built in. The 2-step `core/e2e-test/` process is for non-REMS projects only.

**Session starter:**
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

## 7. Dependency Update Across Repos

**Module:** `core/dependency-update/` → (Python script, guided by AGENTS.md)

**Session starter:**
```
Read @agent-framework/core/dependency-update/AGENTS.md.

Help me configure the update-dependencies.yaml for:
- LIBRARY: spring-boot-starter-parent
- NEW_VERSION: 3.5.10
- TARGET_REPOS: [repo-a, repo-b, repo-c]
- GITLAB_TOKEN: (I will provide via env var GITLAB_TOKEN)

Show the config file content and the command to run the update script.
```

---

## Tips

**Reference multiple files in one message:**
```
Read @agent-framework/projects/rems/AGENTS.md, @agent-framework/core/tech-spec/AGENTS.md, and @path/to/fsd.pdf then...
```

**Tell Claude Code where to write output:**
```
Write the output to agent-framework/projects/rems/tech-spec/ using the UPPER_SNAKE_CASE.md naming convention.
```

**Resume a session mid-task:**
```
Continue from where we left off — we were generating the API spec for block-word. The controller analysis is done. Now analyze the usecase and steps.
```

**Check output quality:**
```
Apply the quality checklist from @agent-framework/core/tech-spec/GENERATE_API_TECH_SPEC.md to the output you just produced.
```
