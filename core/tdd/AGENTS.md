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

Step 4: Test Cases — ALL layers written together (TDD — tests FIRST)
  ├─ Unit tests: Controller, UseCase Impl, each Step
  │    Tool: core/unit-test/AGENTS.md
  │    Output: *Test.java stubs — compile but FAIL (no production code yet)
  ├─ Integration tests: Repository SQL behavior against real DB schema
  │    Output: *RepositoryIT.java — validates queries, not mocked
  └─ E2E acceptance tests: Playwright scripts from FSD acceptance criteria
       Tool: core/e2e-test/ANALYZE_TEST_CASE.md → core/e2e-test/GEN_SCRIPT_FROM_TC.md
       Output: *.spec.ts covering happy path + all error scenarios
  ⚠️  All test files committed to the branch BEFORE any implementation code

Step 5: Implementation (GREEN)
  └─ Write minimum code to make the failing unit tests pass — layer by layer
     Tool: core/java-developer-coding/AGENTS.md + core/tdd/TDD_CYCLE.md
     Constraint: follow Usecase → Step pattern, NFR requirements
     Output: Controller, UseCase, Steps, Repository, model classes
     Gate: full test suite (unit + integration) must be green before moving on

Step 6: Refactor
  └─ Clean production code and test code without changing behavior
     Constraint: re-run the FULL suite after every refactor — not just the changed class
     Check: naming conventions, NFR logging fields, data masking, error message format
     Gate: all tests still green; coverage ≥ 80% per layer maintained

Step 7: Code Review
  └─ Review implementation against FSD, tech spec, and NFR
     Tool: core/code-review/REVIEW_STANDARD.md
     Output: review-report.md (7 dimensions: performance, code smell, security,
             structure, mapping, business logic, test coverage)

Step 8: E2E Execution & Reporting
  └─ Run Playwright tests against SIT; embed screenshots into test report
     Tool: projects/{{PROJECT}}/e2e-test/{{PROJECT}}_E2E_CONFIG.md
     Output: PASS/FAIL status per acceptance criterion with screenshots
     Note: this step runs automatically on PR merge in CI — not a manual gate
```

---

## Prompt Files

| File | Purpose |
|---|---|
| `TDD_CYCLE.md` | Prompt to run a full Red→Green→Refactor cycle for a single Step or UseCase |

---

## Placeholder Reference

| Placeholder | Required | Possible Values / Format | Example |
|---|---|---|---|
| `{{PROJECT}}` | Yes | kebab-case project folder name under `projects/` | `acme-pay` |
| `{{FEATURE_SLUG}}` | Yes | kebab-case feature identifier; used as test ID prefix and output folder | `payment-gateway` |
| `{{TARGET_CLASS}}` | Yes | Simple class name of the Step, UseCase, or Controller being implemented | `ValidatePaymentStep`, `CreatePaymentUseCaseImpl` |
| `{{TEST_ROOT}}` | Yes | Absolute or relative path to the test source root | `src/test/java/com/acme/pay/restapi` |
| `{{SOURCE_ROOT}}` | Yes | Absolute or relative path to the main source root | `src/main/java/com/acme/pay/restapi` |
| `{{BASE_PACKAGE}}` | Yes | Java base package path matching the project's package root | `com.acme.pay.restapi` |

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
- Run the **full test suite** (unit + integration) after every refactor — not just the changed class
- Apply tech-stack patterns (Usecase → Step, JdbcTemplate, Context object)
- Check NFR compliance: logging fields present, data masking applied, error messages generic
- Verify Context field contracts: if Step A writes a field that Step B reads, a test must cover the handoff

---

## Coverage Requirements

| Layer | Type | Minimum Coverage |
|---|---|---|
| Step | Unit | ≥ 80% line coverage |
| UseCase Impl | Unit | ≥ 80% line coverage |
| Controller | Unit | ≥ 80% line coverage |
| Repository | Integration (real DB) | All query methods covered; no mock substitution |
| E2E (Playwright) | Acceptance | Happy path + all error scenarios defined in FSD |

> **Integration tests must use a real database schema** — not mocked repositories. SQL behavior (column names, null handling, edge-case data) cannot be validated by Mockito stubs. Use an in-memory DB (H2) or a test container matching the production schema.

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

- Do not write implementation code before test cases exist for all layers (unit + integration + E2E)
- Do not mock the database for repository tests — SQL behavior requires a real schema
- Do not write tests that only assert the test framework works (e.g., `assertEquals(1, 1)`)
- Do not skip the Red phase — if a test passes immediately without implementation, it is not testing anything
- Do not run only the changed class's tests after a refactor — always run the full suite
- Do not commit code with failing tests (unless the PR is explicitly marked WIP)
- Do not skip Context field contract tests — if Step A sets a field and Step B reads it, that contract needs a test
- Do not update the spec silently — if a failing test reveals a spec error, update the FSD and record it in the revision history
