# AGENTS.md — Test-Driven Development (TDD)

## Purpose

Guide AI agents and developers through the TDD practice within the framework's workflow. TDD here means: test cases are derived from the FSD and tech spec **before** implementation code is written, and implementation is driven by making those tests pass.

---

## TDD Workflow — Step by Step

This is the full workflow from business requirement to deployed, reviewed code:

```
Step 1: FSD
  └─ Author or receive Functional Specification Document
     Tool: core/fsd/FSD_TEMPLATE.md
     Output: projects/{{PROJECT}}/fsd/{{FEATURE_SLUG}}-fsd.md

Step 2: BA Analysis
  └─ Extract user stories and acceptance criteria from FSD
     Tool: core/ba-analysis/AGENTS.md
     Output: user-stories.md, open-questions.md

Step 3: Tech Spec
  └─ Generate API / Batch / DB technical specification from FSD
     Tool: core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md
     Output: api-specification.md, database-schema.md, validation-rules.md,
             error-codes.md, sequence-diagrams.md

Step 4: Test Cases (TDD — write tests FIRST)
  └─ Generate unit test cases from tech spec and acceptance criteria
     Tool: core/unit-test/AGENTS.md
     Output: test stubs for Controller, UseCase Impl, each Step (backend)
             and component tests (frontend)
     ⚠️  Tests must be written and committed BEFORE implementation code

Step 5: E2E Test Cases
  └─ Analyze FSD acceptance criteria and generate Playwright test scripts
     Tool: core/e2e-test/ANALYZE_TEST_CASE.md → core/e2e-test/GEN_SCRIPT_FROM_TC.md
     Output: .spec.ts files covering happy path + error scenarios

Step 6: Implementation
  └─ Write code to make the failing tests pass
     Tool: core/developer-coding/AGENTS.md
     Constraint: follow tech-stack patterns (Usecase → Step), NFR requirements
     Output: Controller, UseCase, Steps, Repository, model classes

Step 7: Code Review
  └─ Review implementation against FSD, tech spec, and NFR
     Tool: core/code-review/REVIEW_STANDARD.md
     Output: review-report.md (7 dimensions: performance, code smell, security,
             structure, mapping, business logic, test coverage)

Step 8: E2E Execution & Reporting
  └─ Run Playwright tests; embed screenshots into Excel report
     Tool: projects/{{PROJECT}}/e2e-test/{{PROJECT}}_E2E_CONFIG.md → PRE_SCRIPT_EXCEL.md
     Output: Updated Excel test case with PASS/FAIL status and screenshots
```

---

## Prompt Files

| File | Purpose |
|---|---|
| `TDD_CYCLE.md` | Prompt to run a full Red→Green→Refactor cycle for a single Step or UseCase |

---

## TDD Rules

### Red Phase — Write Failing Tests First
- Generate test stubs from the tech spec before writing any production code
- Each test MUST fail for the right reason (not a compile error, but an assertion failure)
- Test names MUST describe the behavior being tested: `should_returnError_when_inputIsNull()`
- Cover: happy path, each validation rule, each error code defined in `error-codes.md`

### Green Phase — Write Minimum Code to Pass
- Write only enough code to make the currently failing test pass
- Do not add logic not covered by a test
- If a test cannot be made to pass without changing other tests, revisit the spec — not the tests

### Refactor Phase — Clean Without Changing Behavior
- Refactor production code and test code separately
- All tests must remain green after refactoring
- Apply tech-stack patterns (Usecase → Step, JdbcTemplate, Context object)
- Check NFR compliance: logging, data masking, error message format

---

## Coverage Requirements

| Layer | Minimum Coverage |
|---|---|
| Step (unit) | ≥ 80% line coverage |
| UseCase Impl (unit) | ≥ 80% line coverage |
| Controller (unit) | ≥ 80% line coverage |
| E2E (Playwright) | Happy path + all error scenarios from FSD |

---

## Test Case Traceability

Every test case MUST be traceable back to the FSD:

| Test ID | FSD Reference | Scenario |
|---|---|---|
| UT-BE-001 | FR-001, BR-001 | Success: valid input returns expected response |
| UT-BE-002 | ERR-001 | Error: missing required field returns error code |
| E2E-001 | AC-001 (happy path) | User submits form → success message shown |

Use the `{{FEATURE_SLUG}}` prefix in all test IDs for traceability.

---

## What Changes When a Test Fails After Implementation

1. **Do not delete or weaken the test** — the test reflects the spec
2. Check if production code diverged from the tech spec
3. If the spec itself was wrong, update the FSD → re-run Steps 3–4 → update the test
4. Record the spec change in the FSD under a new version entry

---

## DO NOT

- Do not write implementation code before test cases exist
- Do not mock the database in unit tests if the test is validating SQL behavior — use integration tests
- Do not write tests that only assert the test framework works (e.g., `assertEquals(1, 1)`)
- Do not skip the Red phase — if a test passes immediately without implementation, it is not testing anything
- Do not commit code with failing tests (unless the PR is explicitly a WIP)
