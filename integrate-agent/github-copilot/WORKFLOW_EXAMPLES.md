# WORKFLOW_EXAMPLES — GitHub Copilot Integration

Copy these chat prompts into Copilot Chat (VS Code `⌃⌘I` / JetBrains `⌥⇧G`). Always attach the relevant files using `#file:` before the instruction.

---

## 1. Generate API Technical Spec from FSD

> **REMS:** Use `projects/rems/tech-spec/REMS_API_TECH_SPEC.md` — includes REMS-specific rules. The `core/` router is for non-REMS projects only.

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

## 2. Generate API Spec from Source Code

```
#file:agent-framework/core/code-to-spec/AGENTS.md
#file:agent-framework/core/code-to-spec/GENERATE_API_SPEC.md
#file:src/main/java/th/co/scb/rems/restapi/controller/RemsParameterAndConfigController.java

Run the GENERATE_API_SPEC prompt for:
- HTTP_METHOD: GET
- API_PATH: /api/rems-parameterandconfig/v1/block-word/search

Trace the controller → usecase → steps and generate the API specification.
```

---

## 3. Code Review

```
#file:agent-framework/core/code-review/AGENTS.md
#file:agent-framework/core/code-review/REVIEW_STANDARD.md
#file:agent-framework/projects/rems/backend/AGENTS.md

Review the current branch changes for the block-word search feature.
Use the REVIEW_STANDARD.md 7-step process:
1. Performance
2. Code smell
3. Structure compliance (vs AGENTS.md architecture)
4. Spec-to-code mapping
5. Business logic
6. Error handling
7. Test coverage

Produce a review report in Markdown table format.
```

---

## 4. Generate REMS Backend Unit Tests

```
#file:agent-framework/projects/rems/backend/AGENTS.md
#file:agent-framework/projects/rems/backend/BE_UNIT_TEST.md
#file:src/main/java/th/co/scb/rems/restapi/usecase/blockword/RemsBlockWordSearchUsecaseImpl.java

Run the BE_UNIT_TEST prompt for the usecase class above.
Generate JUnit 5 tests for:
- Happy path
- Business exception case
- SQL exception case
Target coverage ≥ 80%.
```

---

## 5. Generate Frontend Unit Tests

```
#file:agent-framework/projects/rems/frontend/AGENTS.md
#file:agent-framework/projects/rems/frontend/FE_UNIT_TEST.md
#file:src/features/block-word/BlockWordSearchPage.tsx

Run FE_UNIT_TEST prompt for the BlockWordSearchPage component.
Generate Playwright E2E tests covering:
- Search with valid inputs → results table shown
- Search with no results → empty state shown
- Validation error on empty required field
```

---

## 6. Generate E2E Playwright Script

> **REMS:** Use `projects/rems/e2e-test/REMS_E2E_CONFIG.md` — single prompt with REMS auth, selectors, and session timeout handling built in. The `core/e2e-test/` 2-step process is for non-REMS projects only.

```
#file:agent-framework/projects/rems/AGENTS.md
#file:agent-framework/projects/rems/e2e-test/REMS_E2E_CONFIG.md
#file:test-cases/block-word-test-cases.xlsx

Run REMS_E2E_CONFIG with:
- BASE_URL: https://rems-sit.se.scb.co.th
- AUTH_SESSION_FILE: playwright/.auth/session.json
- FEATURE_NAME: block-word

Generate the Playwright TypeScript E2E test file.
Output: e2e/tests/block-word-e2e.spec.ts
```

---

## Tips

**Attach multiple source files at once:**
Drag files from the VS Code Explorer directly into the Copilot Chat input box.

**Use @workspace to find relevant files:**
```
@workspace Which files implement the block-word search usecase step?
```
Then attach the results with `#file:` in your follow-up.

**Iterative refinement:**
```
The sequence diagram in the spec is missing the error path. Add a Vavr Try failure branch showing the @ControllerAdvice handler.
```

**Apply output to files:**
Switch to Copilot Edits (`⇧⌘I`), paste the generated spec, and Copilot will propose creating the output file — click Apply.
